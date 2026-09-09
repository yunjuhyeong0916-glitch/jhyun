`timescale 1ns/1ps

module TX_PAM_FIR_TOP_FLAT_MODE (
    input  wire         rstb,
    input  wire         i_clk,
    input  wire         ffe_en,

    // ------------------------------------------------------------
    // PRBS / external pattern (64b direct)
    // ------------------------------------------------------------
    input  wire [1:0]   sel_prbs,
    
    

    // ------------------------------------------------------------
    // NEW: modulation mode
    // 00 = NRZ, 01 = PAM4, 10 = PAM8
    // ------------------------------------------------------------
    input  wire [1:0]   mode,

    // ------------------------------------------------------------
    // 8tap ¢Æ~W 8bit = 64bit flat coefficients
    // ------------------------------------------------------------
    input  wire [63:0]  h_flat,

    // ------------------------------------------------------------
    // 64-lane scalar outputs
    // ------------------------------------------------------------
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
    output wire signed [7:0] dout8_31,
    output wire signed [7:0] dout8_32,
    output wire signed [7:0] dout8_33,
    output wire signed [7:0] dout8_34,
    output wire signed [7:0] dout8_35,
    output wire signed [7:0] dout8_36,
    output wire signed [7:0] dout8_37,
    output wire signed [7:0] dout8_38,
    output wire signed [7:0] dout8_39,
    output wire signed [7:0] dout8_40,
    output wire signed [7:0] dout8_41,
    output wire signed [7:0] dout8_42,
    output wire signed [7:0] dout8_43,
    output wire signed [7:0] dout8_44,
    output wire signed [7:0] dout8_45,
    output wire signed [7:0] dout8_46,
    output wire signed [7:0] dout8_47,
    output wire signed [7:0] dout8_48,
    output wire signed [7:0] dout8_49,
    output wire signed [7:0] dout8_50,
    output wire signed [7:0] dout8_51,
    output wire signed [7:0] dout8_52,
    output wire signed [7:0] dout8_53,
    output wire signed [7:0] dout8_54,
    output wire signed [7:0] dout8_55,
    output wire signed [7:0] dout8_56,
    output wire signed [7:0] dout8_57,
    output wire signed [7:0] dout8_58,
    output wire signed [7:0] dout8_59,
    output wire signed [7:0] dout8_60,
    output wire signed [7:0] dout8_61,
    output wire signed [7:0] dout8_62,
    output wire signed [7:0] dout8_63
);

    // ------------------------------------------------------------
    // Unpack FIR taps (h0 = LSB)
    // ------------------------------------------------------------
    wire signed [7:0] h0 = h_flat[ 7: 0];
    wire signed [7:0] h1 = h_flat[15: 8];
    wire signed [7:0] h2 = h_flat[23:16];
    wire signed [7:0] h3 = h_flat[31:24];
    wire signed [7:0] h4 = h_flat[39:32];
    wire signed [7:0] h5 = h_flat[47:40];
    wire signed [7:0] h6 = h_flat[55:48];
    wire signed [7:0] h7 = h_flat[63:56];

    // ------------------------------------------------------------
    // Internal array (TX core output)
    // ------------------------------------------------------------
    wire signed [7:0] tx_out [0:63];

    // ------------------------------------------------------------
    // TX core (MULTI-MODE VERSION)
    // - PRBS: NRZ/PAM4/PAM8 supported
    // - ext_ptrn: 64b external pattern port
    // ------------------------------------------------------------



    TX_PAM_FIR_TOP u_tx_multi (
        .rstb        (rstb),
        .i_clk       (i_clk),
        .ffe_en      (ffe_en),

        .sel_prbs    (sel_prbs),

        .mode        (mode),

        .h0          (h0),
        .h1          (h1),
        .h2          (h2),
        .h3          (h3),
        .h4          (h4),
        .h5          (h5),
        .h6          (h6),
        .h7          (h7),

        .dout        (tx_out)
    );

    // ------------------------------------------------------------
    // Array ¢Æ~F~R scalar outputs
    // ------------------------------------------------------------
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
    assign dout8_32 = tx_out[32];
    assign dout8_33 = tx_out[33];
    assign dout8_34 = tx_out[34];
    assign dout8_35 = tx_out[35];
    assign dout8_36 = tx_out[36];
    assign dout8_37 = tx_out[37];
    assign dout8_38 = tx_out[38];
    assign dout8_39 = tx_out[39];
    assign dout8_40 = tx_out[40];
    assign dout8_41 = tx_out[41];
    assign dout8_42 = tx_out[42];
    assign dout8_43 = tx_out[43];
    assign dout8_44 = tx_out[44];
    assign dout8_45 = tx_out[45];
    assign dout8_46 = tx_out[46];
    assign dout8_47 = tx_out[47];
    assign dout8_48 = tx_out[48];
    assign dout8_49 = tx_out[49];
    assign dout8_50 = tx_out[50];
    assign dout8_51 = tx_out[51];
    assign dout8_52 = tx_out[52];
    assign dout8_53 = tx_out[53];
    assign dout8_54 = tx_out[54];
    assign dout8_55 = tx_out[55];
    assign dout8_56 = tx_out[56];
    assign dout8_57 = tx_out[57];
    assign dout8_58 = tx_out[58];
    assign dout8_59 = tx_out[59];
    assign dout8_60 = tx_out[60];
    assign dout8_61 = tx_out[61];
    assign dout8_62 = tx_out[62];
    assign dout8_63 = tx_out[63];

endmodule
