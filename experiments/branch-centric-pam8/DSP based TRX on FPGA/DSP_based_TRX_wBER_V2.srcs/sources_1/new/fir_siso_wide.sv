`timescale 1ns/1ps

module fir_siso_wide #(
    parameter IW                 = 8,
    parameter OW                 = 16,
    parameter CW                 = 16,
    parameter COEFF_FRAC         = 13,
    parameter NTAPS              = 21,
    parameter SAT_EN             = 1,
    parameter ROUND_EN           = 1,
    parameter ADVANCE_ON_INVALID = 1
)(
    input                          clk,
    input                          rst_n,
    input                          in_valid,
    input                          cfg_bypass,
    input      signed [IW-1:0]     in_samp,
    input             [NTAPS*CW-1:0] coeffs_flat,
    output reg                     out_valid,
    output reg signed [OW-1:0]     out_samp
);

    localparam HISTN = (NTAPS > 1) ? (NTAPS-1) : 1;
    localparam ACCW  = IW + CW + $clog2((NTAPS < 2) ? 2 : NTAPS) + 3;

    reg signed [IW-1:0]   hist      [0:HISTN-1];
    reg signed [CW-1:0]   coeffs_arr[0:NTAPS-1];
    reg signed [ACCW-1:0] acc_c;

    integer c, k, t;

    initial begin
        if (NTAPS < 1) begin
            $display("NTAPS must be >= 1");
            $finish;
        end
        if (COEFF_FRAC < 1) begin
            $display("COEFF_FRAC must be >= 1");
            $finish;
        end
        if (OW > ACCW) begin
            $display("OW (%0d) must be <= ACCW (%0d)", OW, ACCW);
            $finish;
        end
    end

    function signed [OW-1:0] sx_in_to_out;
        input signed [IW-1:0] x;
        begin
            sx_in_to_out = x;
        end
    endfunction

    function signed [ACCW-1:0] mul_to_accw;
        input signed [IW-1:0] a;
        input signed [CW-1:0] b;
        reg signed [IW+CW-1:0] p;
        begin
            p = a * b;
            mul_to_accw = {{(ACCW-(IW+CW)){p[IW+CW-1]}}, p};
        end
    endfunction

    function signed [OW-1:0] qsat_from_acc;
        input signed [ACCW-1:0] x;
        reg signed [ACCW-1:0] xr;
        reg signed [ACCW-1:0] xs;
        reg signed [ACCW-1:0] max_ext;
        reg signed [ACCW-1:0] min_ext;
        begin
            if (ROUND_EN) begin
                if (x >= 0)
                    xr = x + ($signed(1) <<< (COEFF_FRAC-1));
                else
                    xr = x - ($signed(1) <<< (COEFF_FRAC-1));
            end else begin
                xr = x;
            end

            xs = xr >>> COEFF_FRAC;

            if (!SAT_EN) begin
                qsat_from_acc = xs[OW-1:0];
            end else begin
                max_ext = {{(ACCW-OW){1'b0}}, {1'b0, {(OW-1){1'b1}}}};
                min_ext = {{(ACCW-OW){1'b1}}, {1'b1, {(OW-1){1'b0}}}};

                if (xs > max_ext)
                    qsat_from_acc = {1'b0, {(OW-1){1'b1}}};
                else if (xs < min_ext)
                    qsat_from_acc = {1'b1, {(OW-1){1'b0}}};
                else
                    qsat_from_acc = xs[OW-1:0];
            end
        end
    endfunction

    always @(*) begin
        for (c = 0; c < NTAPS; c = c + 1)
            coeffs_arr[c] = coeffs_flat[c*CW +: CW];
    end

    always @(*) begin
        acc_c = {ACCW{1'b0}};
        for (k = 0; k < NTAPS; k = k + 1) begin
            if (k == 0)
                acc_c = acc_c + mul_to_accw(in_samp, coeffs_arr[k]);
            else
                acc_c = acc_c + mul_to_accw(hist[k-1], coeffs_arr[k]);
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_valid <= 1'b0;
            out_samp  <= {OW{1'b0}};
            for (t = 0; t < HISTN; t = t + 1)
                hist[t] <= {IW{1'b0}};
        end else begin
            out_valid <= in_valid;

            if (in_valid) begin
                if (cfg_bypass)
                    out_samp <= sx_in_to_out(in_samp);
                else
                    out_samp <= qsat_from_acc(acc_c);
            end

            if (NTAPS > 1) begin
                if (in_valid || ADVANCE_ON_INVALID) begin
                    for (t = HISTN-1; t > 0; t = t - 1)
                        hist[t] <= hist[t-1];
                    if (in_valid)
                        hist[0] <= in_samp;
                    else
                        hist[0] <= {IW{1'b0}};
                end
            end
        end
    end

endmodule
