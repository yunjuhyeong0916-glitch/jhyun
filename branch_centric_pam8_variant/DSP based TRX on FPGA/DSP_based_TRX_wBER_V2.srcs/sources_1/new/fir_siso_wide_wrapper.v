`timescale 1ns/1ps

module fir_siso_wide_wrapper #(
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
    output                         out_valid,
    output     signed [OW-1:0]     out_samp
);

    fir_siso_wide #(
        .IW(IW),
        .OW(OW),
        .CW(CW),
        .COEFF_FRAC(COEFF_FRAC),
        .NTAPS(NTAPS),
        .SAT_EN(SAT_EN),
        .ROUND_EN(ROUND_EN),
        .ADVANCE_ON_INVALID(ADVANCE_ON_INVALID)
    ) u_fir_siso_wide (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .cfg_bypass(cfg_bypass),
        .in_samp(in_samp),
        .coeffs_flat(coeffs_flat),
        .out_valid(out_valid),
        .out_samp(out_samp)
    );

endmodule
