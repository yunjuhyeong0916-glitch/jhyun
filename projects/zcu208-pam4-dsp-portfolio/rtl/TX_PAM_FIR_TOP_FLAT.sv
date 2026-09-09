`timescale 1ns/1ps

// ============================================================================
// TX_PAM_FIR_TOP_FLAT_MODE
// - 32-symbol flat wrapper for TX_PAM_FIR_TOP.
// - Exposes only the 32 valid 8-bit symbol outputs used by the 512-bit TX FIFO.
// - ext_ptrn ports drive the PRBS generator override path.
// - ext_ptrn_en selects the AXI GPIO pattern instead of PRBS bits.
// ============================================================================

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: DAC/ADC DSP-Based PAM4 Transceiver
// Module Name: TX_PAM_FIR_TOP_FLAT_MODE
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Applies flat packed FIR coefficient control to the PAM4 TX FIR path.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module TX_PAM_FIR_TOP_FLAT_MODE (
    input  wire         rstb,
    input  wire         i_clk,
    input  wire         ffe_en,
    input  wire [1:0]   sel_prbs,
    input  wire         ext_ptrn_en,
    input  wire [1:0]   mode,
    input  wire [63:0]  ext_ptrn,
    input  wire [63:0]  h_flat,

    output wire signed [7:0] dout8_0,
    output wire signed [7:0] dout8_1,
    output wire signed [7:0] dout8_2,
    output wire signed [7:0] dout8_3,
    output wire signed [7:0] dout8_4,
    output wire signed [7:0] dout8_5,
    output wire signed [7:0] dout8_6,
    output wire signed [7:0] dout8_7,
    output wire signed [7:0] dout8_8,
    output wire signed [7:0] dout8_9,
    output wire signed [7:0] dout8_10,
    output wire signed [7:0] dout8_11,
    output wire signed [7:0] dout8_12,
    output wire signed [7:0] dout8_13,
    output wire signed [7:0] dout8_14,
    output wire signed [7:0] dout8_15,
    output wire signed [7:0] dout8_16,
    output wire signed [7:0] dout8_17,
    output wire signed [7:0] dout8_18,
    output wire signed [7:0] dout8_19,
    output wire signed [7:0] dout8_20,
    output wire signed [7:0] dout8_21,
    output wire signed [7:0] dout8_22,
    output wire signed [7:0] dout8_23,
    output wire signed [7:0] dout8_24,
    output wire signed [7:0] dout8_25,
    output wire signed [7:0] dout8_26,
    output wire signed [7:0] dout8_27,
    output wire signed [7:0] dout8_28,
    output wire signed [7:0] dout8_29,
    output wire signed [7:0] dout8_30,
    output wire signed [7:0] dout8_31
);

    wire signed [7:0] h0 = h_flat[ 7: 0];
    wire signed [7:0] h1 = h_flat[15: 8];
    wire signed [7:0] h2 = h_flat[23:16];
    wire signed [7:0] h3 = h_flat[31:24];
    wire signed [7:0] h4 = h_flat[39:32];
    wire signed [7:0] h5 = h_flat[47:40];
    wire signed [7:0] h6 = h_flat[55:48];
    wire signed [7:0] h7 = h_flat[63:56];

    wire signed [7:0] tx_out [0:31];

    TX_PAM_FIR_TOP u_tx32 (
        .rstb     (rstb),
        .i_clk    (i_clk),
        .ffe_en   (ffe_en),
        .sel_prbs (sel_prbs),
        .ext_ptrn_en (ext_ptrn_en),
        .ext_ptrn (ext_ptrn),
        .mode     (mode),
        .h0       (h0),
        .h1       (h1),
        .h2       (h2),
        .h3       (h3),
        .h4       (h4),
        .h5       (h5),
        .h6       (h6),
        .h7       (h7),
        .dout     (tx_out)
    );

    assign dout8_0  = tx_out[0];
    assign dout8_1  = tx_out[1];
    assign dout8_2  = tx_out[2];
    assign dout8_3  = tx_out[3];
    assign dout8_4  = tx_out[4];
    assign dout8_5  = tx_out[5];
    assign dout8_6  = tx_out[6];
    assign dout8_7  = tx_out[7];
    assign dout8_8  = tx_out[8];
    assign dout8_9  = tx_out[9];
    assign dout8_10 = tx_out[10];
    assign dout8_11 = tx_out[11];
    assign dout8_12 = tx_out[12];
    assign dout8_13 = tx_out[13];
    assign dout8_14 = tx_out[14];
    assign dout8_15 = tx_out[15];
    assign dout8_16 = tx_out[16];
    assign dout8_17 = tx_out[17];
    assign dout8_18 = tx_out[18];
    assign dout8_19 = tx_out[19];
    assign dout8_20 = tx_out[20];
    assign dout8_21 = tx_out[21];
    assign dout8_22 = tx_out[22];
    assign dout8_23 = tx_out[23];
    assign dout8_24 = tx_out[24];
    assign dout8_25 = tx_out[25];
    assign dout8_26 = tx_out[26];
    assign dout8_27 = tx_out[27];
    assign dout8_28 = tx_out[28];
    assign dout8_29 = tx_out[29];
    assign dout8_30 = tx_out[30];
    assign dout8_31 = tx_out[31];

endmodule
