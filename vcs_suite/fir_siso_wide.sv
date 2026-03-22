`timescale 1ns/1ps

module fir_siso_wide #(
    parameter int IW                 = 8,
    parameter int OW                 = 16,
    parameter int CW                 = 16,
    parameter int COEFF_FRAC         = 13,
    parameter int NTAPS              = 21,
    parameter bit SAT_EN             = 1'b1,
    parameter bit ROUND_EN           = 1'b1,
    parameter bit ADVANCE_ON_INVALID = 1'b1
)(
    input  logic                     clk,
    input  logic                     rst_n,
    input  logic                     in_valid,
    input  logic                     cfg_bypass,
    input  logic signed [IW-1:0]     in_samp,
    input  logic signed [CW-1:0]     coeffs [0:NTAPS-1],
    output logic                     out_valid,
    output logic signed [OW-1:0]     out_samp
);

    localparam int HISTN = (NTAPS > 1) ? (NTAPS - 1) : 1;
    localparam int ACCW  = IW + CW + $clog2((NTAPS < 2) ? 2 : NTAPS) + 3;

    logic signed [IW-1:0]   hist [0:HISTN-1];
    logic signed [ACCW-1:0] acc_c;

    integer k;
    integer t;

    initial begin
        if (NTAPS < 1)      $fatal(1, "NTAPS must be >= 1");
        if (COEFF_FRAC < 1) $fatal(1, "COEFF_FRAC must be >= 1");
        if (OW > ACCW)      $fatal(1, "OW (%0d) must be <= ACCW (%0d)", OW, ACCW);
    end

    function automatic logic signed [OW-1:0] sx_in_to_out(
        input logic signed [IW-1:0] x
    );
        begin
            sx_in_to_out = x;
        end
    endfunction

    function automatic logic signed [ACCW-1:0] mul_to_accw(
        input logic signed [IW-1:0] a,
        input logic signed [CW-1:0] b
    );
        logic signed [IW+CW-1:0] p;
        begin
            p = a * b;
            mul_to_accw = {{(ACCW-(IW+CW)){p[IW+CW-1]}}, p};
        end
    endfunction

    function automatic logic signed [OW-1:0] qsat_from_acc(
        input logic signed [ACCW-1:0] x
    );
        logic signed [ACCW-1:0] xr;
        logic signed [ACCW-1:0] xs;
        logic signed [ACCW-1:0] max_ext;
        logic signed [ACCW-1:0] min_ext;
        begin
            if (ROUND_EN) begin
                if (x >= 0)
                    xr = x + ($signed(1) <<< (COEFF_FRAC - 1));
                else
                    xr = x - ($signed(1) <<< (COEFF_FRAC - 1));
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

    always_comb begin
        acc_c = '0;
        for (k = 0; k < NTAPS; k = k + 1) begin
            if (k == 0)
                acc_c += mul_to_accw(in_samp, coeffs[k]);
            else
                acc_c += mul_to_accw(hist[k-1], coeffs[k]);
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_valid <= 1'b0;
            out_samp  <= '0;
            for (t = 0; t < HISTN; t = t + 1)
                hist[t] <= '0;
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
                    for (t = HISTN - 1; t > 0; t = t - 1)
                        hist[t] <= hist[t-1];
                    hist[0] <= in_valid ? in_samp : '0;
                end
            end
        end
    end

endmodule
