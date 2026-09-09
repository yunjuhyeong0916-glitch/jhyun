`timescale 1ns/1ps

// ============================================================================
// TX_PAM_FIR_TOP
// - Active 32-symbol TX path.
// - PRBS64 supplies one 64-bit PRBS frame, mapped into 32 PAM4 8-bit symbols.
// - FFE state advances over exactly those 32 valid symbols per clock.
// ============================================================================

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: DAC/ADC DSP-Based PAM4 Transceiver
// Module Name: TX_PAM_FIR_TOP
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Selects PRBS or external-pattern TX data and applies the PAM4 TX FIR path.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module TX_PAM_FIR_TOP (
    input  wire        rstb,
    input  wire        i_clk,
    input  wire        ffe_en,
    input  wire [1:0]  sel_prbs,
    input  wire        ext_ptrn_en,
    input  wire [63:0] ext_ptrn,

    // 00 = NRZ, 01 = PAM4, 10 = PAM4 fallback in this PRBS64 mode
    input  wire [1:0]  mode,

    input  wire signed [7:0] h0,
    input  wire signed [7:0] h1,
    input  wire signed [7:0] h2,
    input  wire signed [7:0] h3,
    input  wire signed [7:0] h4,
    input  wire signed [7:0] h5,
    input  wire signed [7:0] h6,
    input  wire signed [7:0] h7,

    output logic signed [7:0] dout [0:31]
);

    logic signed [7:0]  tx_raw [0:31];
    logic signed [7:0]  tx_fir [0:31];
    logic signed [63:0] h_packed_d;
    logic signed [63:0] h_packed_q;

    TX_PRBS_MULTI_TOP_32LANE u_prbs_mod (
        .rstb     (rstb),
        .i_clk    (i_clk),
        .sel_prbs (sel_prbs),
        .ext_ptrn_en (ext_ptrn_en),
        .ext_ptrn (ext_ptrn),
        .mode     (mode),
        .dout     (tx_raw)
    );

    always_comb begin
        h_packed_d = {h7, h6, h5, h4, h3, h2, h1, h0};
    end

    always_ff @(posedge i_clk or negedge rstb) begin
        if (!rstb)
            h_packed_q <= 64'b0;
        else
            h_packed_q <= h_packed_d;
    end

    FIR_8TAP_TRANSPOSED_32LANE #(
        .SHIFT(7)
    ) u_fir32 (
        .clk      (i_clk),
        .rst_n    (rstb),
        .din      (tx_raw),
        .h_packed (h_packed_q),
        .dout     (tx_fir)
    );

    genvar lane_i;
    generate
        for (lane_i = 0; lane_i < 32; lane_i = lane_i + 1) begin : GEN_OUT_MUX
            assign dout[lane_i] = ffe_en ? tx_fir[lane_i] : tx_raw[lane_i];
        end
    endgenerate

endmodule
