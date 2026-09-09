`timescale 1ns/1ps

module fir8_axis_8x16 #(
    parameter CW                 = 16,
    parameter COEFF_FRAC         = 13,
    parameter NTAPS              = 21,
    parameter SAT_EN             = 1,
    parameter ROUND_EN           = 1,
    parameter ADVANCE_ON_INVALID = 0
)(
    input                           aclk,
    input                           aresetn,

    input      [127:0]              s_axis_tdata,
    input                           s_axis_tvalid,
    output                          s_axis_tready,

    input                           cfg_bypass,

    output reg [127:0]              m_axis_tdata,
    output reg                      m_axis_tvalid,
    input                           m_axis_tready
);

    localparam IW    = 16;
    localparam OW    = 16;
    localparam HISTN = (NTAPS > 1) ? (NTAPS-1) : 1;
    localparam ACCW  = IW + CW + $clog2((NTAPS < 2) ? 2 : NTAPS) + 3;

    reg  signed [IW-1:0]            hist [0:HISTN-1];
    reg  signed [CW-1:0]            ch_coeffs [0:NTAPS-1];
    reg  signed [OW-1:0]            y_next [0:7];

    wire                             accept_in;
    wire        [127:0]              y_pack;

    reg  signed [ACCW-1:0]           acc_tmp;
    reg  signed [IW-1:0]             sample_k;
    integer                          ci, j, k, h;

    assign s_axis_tready = (m_axis_tready || !m_axis_tvalid);
    assign accept_in     = s_axis_tvalid && s_axis_tready;
    assign y_pack        = {y_next[7], y_next[6], y_next[5], y_next[4], y_next[3], y_next[2], y_next[1], y_next[0]};

    function signed [IW-1:0] get_in_samp;
        input integer idx;
        begin
            case (idx)
                0: get_in_samp = s_axis_tdata[15:0];
                1: get_in_samp = s_axis_tdata[31:16];
                2: get_in_samp = s_axis_tdata[47:32];
                3: get_in_samp = s_axis_tdata[63:48];
                4: get_in_samp = s_axis_tdata[79:64];
                5: get_in_samp = s_axis_tdata[95:80];
                6: get_in_samp = s_axis_tdata[111:96];
                7: get_in_samp = s_axis_tdata[127:112];
                default: get_in_samp = {IW{1'b0}};
            endcase
        end
    endfunction

    function signed [OW-1:0] sx_in_to_out;
        input signed [IW-1:0] x;
        begin
            sx_in_to_out = x;
        end
    endfunction

    function signed [ACCW-1:0] mul_to_accw;
        input signed [IW-1:0] a;
        input signed [CW-1:0] b;
        reg   signed [IW+CW-1:0] p;
        begin
            p = a * b;
            mul_to_accw = {{(ACCW-(IW+CW)){p[IW+CW-1]}}, p};
        end
    endfunction

    function signed [OW-1:0] qsat_from_acc;
        input signed [ACCW-1:0] x;
        reg   signed [ACCW-1:0] xr;
        reg   signed [ACCW-1:0] xs;
        reg   signed [ACCW-1:0] max_ext;
        reg   signed [ACCW-1:0] min_ext;
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

    initial begin
        for (ci = 0; ci < NTAPS; ci = ci + 1)
            ch_coeffs[ci] = {CW{1'b0}};

        ch_coeffs[0] = 16'sd4915;
        ch_coeffs[1] = 16'sd1638;
        ch_coeffs[2] = 16'sd819;
        ch_coeffs[3] = 16'sd410;
        ch_coeffs[4] = 16'sd205;
        ch_coeffs[5] = 16'sd102;
        ch_coeffs[6] = 16'sd51;
    end

    always @(*) begin
        for (j = 0; j < 8; j = j + 1) begin
            if (cfg_bypass) begin
                y_next[j] = sx_in_to_out(get_in_samp(j));
            end else begin
                acc_tmp = {ACCW{1'b0}};
                for (k = 0; k < NTAPS; k = k + 1) begin
                    if (k <= j)
                        sample_k = get_in_samp(j-k);
                    else
                        sample_k = hist[k-j-1];
                    acc_tmp = acc_tmp + mul_to_accw(sample_k, ch_coeffs[k]);
                end
                y_next[j] = qsat_from_acc(acc_tmp);
            end
        end
    end

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            m_axis_tdata  <= 128'd0;
            m_axis_tvalid <= 1'b0;
            for (h = 0; h < HISTN; h = h + 1)
                hist[h] <= {IW{1'b0}};
        end else if (m_axis_tready || !m_axis_tvalid) begin
            if (accept_in)
                m_axis_tdata <= y_pack;
            m_axis_tvalid <= accept_in;

            if (NTAPS > 1) begin
                if (accept_in || ADVANCE_ON_INVALID) begin
                    for (h = HISTN-1; h >= 0; h = h - 1) begin
                        if (h < 8) begin
                            if (accept_in)
                                hist[h] <= get_in_samp(7-h);
                            else
                                hist[h] <= {IW{1'b0}};
                        end else begin
                            hist[h] <= hist[h-8];
                        end
                    end
                end
            end
        end
    end

endmodule
