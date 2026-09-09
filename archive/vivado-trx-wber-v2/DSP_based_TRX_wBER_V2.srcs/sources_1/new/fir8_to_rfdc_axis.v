`timescale 1ns/1ps

module fir8_axis_8x16 #(
    parameter CW                 = 16,
    parameter COEFF_FRAC         = 13,
    parameter NTAPS              = 21,
    parameter SAT_EN             = 1,
    parameter ROUND_EN           = 1,
    parameter ADVANCE_ON_INVALID = 1
)(
    input                           aclk,
    input                           aresetn,

    input      [127:0]              s_axis_tdata,
    input                           s_axis_tvalid,
    output                          s_axis_tready,

    input                           cfg_bypass,
    input      [NTAPS*CW-1:0]       coeffs_flat,

    output reg [127:0]              m_axis_tdata,
    output reg                      m_axis_tvalid,
    input                           m_axis_tready
);

    wire signed [15:0] in0 = s_axis_tdata[15:0];
    wire signed [15:0] in1 = s_axis_tdata[31:16];
    wire signed [15:0] in2 = s_axis_tdata[47:32];
    wire signed [15:0] in3 = s_axis_tdata[63:48];
    wire signed [15:0] in4 = s_axis_tdata[79:64];
    wire signed [15:0] in5 = s_axis_tdata[95:80];
    wire signed [15:0] in6 = s_axis_tdata[111:96];
    wire signed [15:0] in7 = s_axis_tdata[127:112];

    wire accept_in;
    assign s_axis_tready = (m_axis_tready || !m_axis_tvalid);
    assign accept_in     = s_axis_tvalid && s_axis_tready;

    wire v0, v1, v2, v3, v4, v5, v6, v7;
    wire signed [15:0] y0, y1, y2, y3, y4, y5, y6, y7;

    fir_siso_wide #(.IW(16), .OW(16), .CW(CW), .COEFF_FRAC(COEFF_FRAC), .NTAPS(NTAPS), .SAT_EN(SAT_EN), .ROUND_EN(ROUND_EN), .ADVANCE_ON_INVALID(ADVANCE_ON_INVALID))
    u_fir0 (.clk(aclk), .rst_n(aresetn), .in_valid(accept_in), .cfg_bypass(cfg_bypass), .in_samp(in0), .coeffs_flat(coeffs_flat), .out_valid(v0), .out_samp(y0));

    fir_siso_wide #(.IW(16), .OW(16), .CW(CW), .COEFF_FRAC(COEFF_FRAC), .NTAPS(NTAPS), .SAT_EN(SAT_EN), .ROUND_EN(ROUND_EN), .ADVANCE_ON_INVALID(ADVANCE_ON_INVALID))
    u_fir1 (.clk(aclk), .rst_n(aresetn), .in_valid(accept_in), .cfg_bypass(cfg_bypass), .in_samp(in1), .coeffs_flat(coeffs_flat), .out_valid(v1), .out_samp(y1));

    fir_siso_wide #(.IW(16), .OW(16), .CW(CW), .COEFF_FRAC(COEFF_FRAC), .NTAPS(NTAPS), .SAT_EN(SAT_EN), .ROUND_EN(ROUND_EN), .ADVANCE_ON_INVALID(ADVANCE_ON_INVALID))
    u_fir2 (.clk(aclk), .rst_n(aresetn), .in_valid(accept_in), .cfg_bypass(cfg_bypass), .in_samp(in2), .coeffs_flat(coeffs_flat), .out_valid(v2), .out_samp(y2));

    fir_siso_wide #(.IW(16), .OW(16), .CW(CW), .COEFF_FRAC(COEFF_FRAC), .NTAPS(NTAPS), .SAT_EN(SAT_EN), .ROUND_EN(ROUND_EN), .ADVANCE_ON_INVALID(ADVANCE_ON_INVALID))
    u_fir3 (.clk(aclk), .rst_n(aresetn), .in_valid(accept_in), .cfg_bypass(cfg_bypass), .in_samp(in3), .coeffs_flat(coeffs_flat), .out_valid(v3), .out_samp(y3));

    fir_siso_wide #(.IW(16), .OW(16), .CW(CW), .COEFF_FRAC(COEFF_FRAC), .NTAPS(NTAPS), .SAT_EN(SAT_EN), .ROUND_EN(ROUND_EN), .ADVANCE_ON_INVALID(ADVANCE_ON_INVALID))
    u_fir4 (.clk(aclk), .rst_n(aresetn), .in_valid(accept_in), .cfg_bypass(cfg_bypass), .in_samp(in4), .coeffs_flat(coeffs_flat), .out_valid(v4), .out_samp(y4));

    fir_siso_wide #(.IW(16), .OW(16), .CW(CW), .COEFF_FRAC(COEFF_FRAC), .NTAPS(NTAPS), .SAT_EN(SAT_EN), .ROUND_EN(ROUND_EN), .ADVANCE_ON_INVALID(ADVANCE_ON_INVALID))
    u_fir5 (.clk(aclk), .rst_n(aresetn), .in_valid(accept_in), .cfg_bypass(cfg_bypass), .in_samp(in5), .coeffs_flat(coeffs_flat), .out_valid(v5), .out_samp(y5));

    fir_siso_wide #(.IW(16), .OW(16), .CW(CW), .COEFF_FRAC(COEFF_FRAC), .NTAPS(NTAPS), .SAT_EN(SAT_EN), .ROUND_EN(ROUND_EN), .ADVANCE_ON_INVALID(ADVANCE_ON_INVALID))
    u_fir6 (.clk(aclk), .rst_n(aresetn), .in_valid(accept_in), .cfg_bypass(cfg_bypass), .in_samp(in6), .coeffs_flat(coeffs_flat), .out_valid(v6), .out_samp(y6));

    fir_siso_wide #(.IW(16), .OW(16), .CW(CW), .COEFF_FRAC(COEFF_FRAC), .NTAPS(NTAPS), .SAT_EN(SAT_EN), .ROUND_EN(ROUND_EN), .ADVANCE_ON_INVALID(ADVANCE_ON_INVALID))
    u_fir7 (.clk(aclk), .rst_n(aresetn), .in_valid(accept_in), .cfg_bypass(cfg_bypass), .in_samp(in7), .coeffs_flat(coeffs_flat), .out_valid(v7), .out_samp(y7));

    wire [127:0] y_pack   = {y7, y6, y5, y4, y3, y2, y1, y0};
    wire         y_valid  = v0 & v1 & v2 & v3 & v4 & v5 & v6 & v7;

    always @(posedge aclk) begin
        if (!aresetn) begin
            m_axis_tdata  <= 128'd0;
            m_axis_tvalid <= 1'b0;
        end else if (m_axis_tready || !m_axis_tvalid) begin
            if (y_valid)
                m_axis_tdata <= y_pack;
            m_axis_tvalid <= y_valid;
        end
    end

endmodule
