`timescale 1ns/1ps
// ============================================================================
// rx_bd_shim_raw1024_to_bits64 (Verilog-2001 TOP for IP packaging)
// - Input  : in_data_16b[1023:0] (packed 64*16b = 1024b)
// - Unpack : rx16_0..63 using inverse of TX FIFO ordering compensation
// - Trunc  : rx16 -> rx8 using trunc16_to_8_64lane (>>>8)
// - Decode : rx8 -> rx_bits[63:0] (sign-based or threshold-based)
// - Valid  : rx_bits_valid pulses with frame_valid
//
// Unpack rule (inverse of TX pack):
//   TX: out_data_16b[(7-g)*128 + i*16 +:16] <= tx16[g*8+i];
//   RX: rx16[g*8+i] = in_data_16b[(7-g)*128 + i*16 +:16];
// ============================================================================

module rx_bd_shim_raw1024_to_bits64 #(
    parameter integer USE_THRESHOLD = 0  // 0: sign-based, 1: threshold-based
)(
    input  wire         aclk,
    input  wire         aresetn,

    input  wire         frame_valid,
    input  wire [1023:0] in_data_16b,

    input  wire signed [7:0] th,          // used only when USE_THRESHOLD=1

    output reg  [63:0]  rx_bits,
    output reg          rx_bits_valid
);

    // ------------------------------------------------------------------------
    // 1) UNPACK 1024b -> 64 x 16b (explicit wires)
    // ------------------------------------------------------------------------
    wire signed [15:0] rx16_0;
    wire signed [15:0] rx16_1;
    wire signed [15:0] rx16_2;
    wire signed [15:0] rx16_3;
    wire signed [15:0] rx16_4;
    wire signed [15:0] rx16_5;
    wire signed [15:0] rx16_6;
    wire signed [15:0] rx16_7;
    wire signed [15:0] rx16_8;
    wire signed [15:0] rx16_9;
    wire signed [15:0] rx16_10;
    wire signed [15:0] rx16_11;
    wire signed [15:0] rx16_12;
    wire signed [15:0] rx16_13;
    wire signed [15:0] rx16_14;
    wire signed [15:0] rx16_15;
    wire signed [15:0] rx16_16;
    wire signed [15:0] rx16_17;
    wire signed [15:0] rx16_18;
    wire signed [15:0] rx16_19;
    wire signed [15:0] rx16_20;
    wire signed [15:0] rx16_21;
    wire signed [15:0] rx16_22;
    wire signed [15:0] rx16_23;
    wire signed [15:0] rx16_24;
    wire signed [15:0] rx16_25;
    wire signed [15:0] rx16_26;
    wire signed [15:0] rx16_27;
    wire signed [15:0] rx16_28;
    wire signed [15:0] rx16_29;
    wire signed [15:0] rx16_30;
    wire signed [15:0] rx16_31;
    wire signed [15:0] rx16_32;
    wire signed [15:0] rx16_33;
    wire signed [15:0] rx16_34;
    wire signed [15:0] rx16_35;
    wire signed [15:0] rx16_36;
    wire signed [15:0] rx16_37;
    wire signed [15:0] rx16_38;
    wire signed [15:0] rx16_39;
    wire signed [15:0] rx16_40;
    wire signed [15:0] rx16_41;
    wire signed [15:0] rx16_42;
    wire signed [15:0] rx16_43;
    wire signed [15:0] rx16_44;
    wire signed [15:0] rx16_45;
    wire signed [15:0] rx16_46;
    wire signed [15:0] rx16_47;
    wire signed [15:0] rx16_48;
    wire signed [15:0] rx16_49;
    wire signed [15:0] rx16_50;
    wire signed [15:0] rx16_51;
    wire signed [15:0] rx16_52;
    wire signed [15:0] rx16_53;
    wire signed [15:0] rx16_54;
    wire signed [15:0] rx16_55;
    wire signed [15:0] rx16_56;
    wire signed [15:0] rx16_57;
    wire signed [15:0] rx16_58;
    wire signed [15:0] rx16_59;
    wire signed [15:0] rx16_60;
    wire signed [15:0] rx16_61;
    wire signed [15:0] rx16_62;
    wire signed [15:0] rx16_63;

    // g=0 base=896 : lanes 0..7
    assign rx16_0  = $signed(in_data_16b[ 896 +: 16]);
    assign rx16_1  = $signed(in_data_16b[ 912 +: 16]);
    assign rx16_2  = $signed(in_data_16b[ 928 +: 16]);
    assign rx16_3  = $signed(in_data_16b[ 944 +: 16]);
    assign rx16_4  = $signed(in_data_16b[ 960 +: 16]);
    assign rx16_5  = $signed(in_data_16b[ 976 +: 16]);
    assign rx16_6  = $signed(in_data_16b[ 992 +: 16]);
    assign rx16_7  = $signed(in_data_16b[1008 +: 16]);

    // g=1 base=768 : lanes 8..15
    assign rx16_8  = $signed(in_data_16b[ 768 +: 16]);
    assign rx16_9  = $signed(in_data_16b[ 784 +: 16]);
    assign rx16_10 = $signed(in_data_16b[ 800 +: 16]);
    assign rx16_11 = $signed(in_data_16b[ 816 +: 16]);
    assign rx16_12 = $signed(in_data_16b[ 832 +: 16]);
    assign rx16_13 = $signed(in_data_16b[ 848 +: 16]);
    assign rx16_14 = $signed(in_data_16b[ 864 +: 16]);
    assign rx16_15 = $signed(in_data_16b[ 880 +: 16]);

    // g=2 base=640 : lanes 16..23
    assign rx16_16 = $signed(in_data_16b[ 640 +: 16]);
    assign rx16_17 = $signed(in_data_16b[ 656 +: 16]);
    assign rx16_18 = $signed(in_data_16b[ 672 +: 16]);
    assign rx16_19 = $signed(in_data_16b[ 688 +: 16]);
    assign rx16_20 = $signed(in_data_16b[ 704 +: 16]);
    assign rx16_21 = $signed(in_data_16b[ 720 +: 16]);
    assign rx16_22 = $signed(in_data_16b[ 736 +: 16]);
    assign rx16_23 = $signed(in_data_16b[ 752 +: 16]);

    // g=3 base=512 : lanes 24..31
    assign rx16_24 = $signed(in_data_16b[ 512 +: 16]);
    assign rx16_25 = $signed(in_data_16b[ 528 +: 16]);
    assign rx16_26 = $signed(in_data_16b[ 544 +: 16]);
    assign rx16_27 = $signed(in_data_16b[ 560 +: 16]);
    assign rx16_28 = $signed(in_data_16b[ 576 +: 16]);
    assign rx16_29 = $signed(in_data_16b[ 592 +: 16]);
    assign rx16_30 = $signed(in_data_16b[ 608 +: 16]);
    assign rx16_31 = $signed(in_data_16b[ 624 +: 16]);

    // g=4 base=384 : lanes 32..39
    assign rx16_32 = $signed(in_data_16b[ 384 +: 16]);
    assign rx16_33 = $signed(in_data_16b[ 400 +: 16]);
    assign rx16_34 = $signed(in_data_16b[ 416 +: 16]);
    assign rx16_35 = $signed(in_data_16b[ 432 +: 16]);
    assign rx16_36 = $signed(in_data_16b[ 448 +: 16]);
    assign rx16_37 = $signed(in_data_16b[ 464 +: 16]);
    assign rx16_38 = $signed(in_data_16b[ 480 +: 16]);
    assign rx16_39 = $signed(in_data_16b[ 496 +: 16]);

    // g=5 base=256 : lanes 40..47
    assign rx16_40 = $signed(in_data_16b[ 256 +: 16]);
    assign rx16_41 = $signed(in_data_16b[ 272 +: 16]);
    assign rx16_42 = $signed(in_data_16b[ 288 +: 16]);
    assign rx16_43 = $signed(in_data_16b[ 304 +: 16]);
    assign rx16_44 = $signed(in_data_16b[ 320 +: 16]);
    assign rx16_45 = $signed(in_data_16b[ 336 +: 16]);
    assign rx16_46 = $signed(in_data_16b[ 352 +: 16]);
    assign rx16_47 = $signed(in_data_16b[ 368 +: 16]);

    // g=6 base=128 : lanes 48..55
    assign rx16_48 = $signed(in_data_16b[ 128 +: 16]);
    assign rx16_49 = $signed(in_data_16b[ 144 +: 16]);
    assign rx16_50 = $signed(in_data_16b[ 160 +: 16]);
    assign rx16_51 = $signed(in_data_16b[ 176 +: 16]);
    assign rx16_52 = $signed(in_data_16b[ 192 +: 16]);
    assign rx16_53 = $signed(in_data_16b[ 208 +: 16]);
    assign rx16_54 = $signed(in_data_16b[ 224 +: 16]);
    assign rx16_55 = $signed(in_data_16b[ 240 +: 16]);

    // g=7 base=0 : lanes 56..63
    assign rx16_56 = $signed(in_data_16b[   0 +: 16]);
    assign rx16_57 = $signed(in_data_16b[  16 +: 16]);
    assign rx16_58 = $signed(in_data_16b[  32 +: 16]);
    assign rx16_59 = $signed(in_data_16b[  48 +: 16]);
    assign rx16_60 = $signed(in_data_16b[  64 +: 16]);
    assign rx16_61 = $signed(in_data_16b[  80 +: 16]);
    assign rx16_62 = $signed(in_data_16b[  96 +: 16]);
    assign rx16_63 = $signed(in_data_16b[ 112 +: 16]);

    // ------------------------------------------------------------------------
    // 2) TRUNC 64x16b -> 64x8b (explicit wires)
    // ------------------------------------------------------------------------
    wire signed [7:0] rx8_0;
    wire signed [7:0] rx8_1;
    wire signed [7:0] rx8_2;
    wire signed [7:0] rx8_3;
    wire signed [7:0] rx8_4;
    wire signed [7:0] rx8_5;
    wire signed [7:0] rx8_6;
    wire signed [7:0] rx8_7;
    wire signed [7:0] rx8_8;
    wire signed [7:0] rx8_9;
    wire signed [7:0] rx8_10;
    wire signed [7:0] rx8_11;
    wire signed [7:0] rx8_12;
    wire signed [7:0] rx8_13;
    wire signed [7:0] rx8_14;
    wire signed [7:0] rx8_15;
    wire signed [7:0] rx8_16;
    wire signed [7:0] rx8_17;
    wire signed [7:0] rx8_18;
    wire signed [7:0] rx8_19;
    wire signed [7:0] rx8_20;
    wire signed [7:0] rx8_21;
    wire signed [7:0] rx8_22;
    wire signed [7:0] rx8_23;
    wire signed [7:0] rx8_24;
    wire signed [7:0] rx8_25;
    wire signed [7:0] rx8_26;
    wire signed [7:0] rx8_27;
    wire signed [7:0] rx8_28;
    wire signed [7:0] rx8_29;
    wire signed [7:0] rx8_30;
    wire signed [7:0] rx8_31;
    wire signed [7:0] rx8_32;
    wire signed [7:0] rx8_33;
    wire signed [7:0] rx8_34;
    wire signed [7:0] rx8_35;
    wire signed [7:0] rx8_36;
    wire signed [7:0] rx8_37;
    wire signed [7:0] rx8_38;
    wire signed [7:0] rx8_39;
    wire signed [7:0] rx8_40;
    wire signed [7:0] rx8_41;
    wire signed [7:0] rx8_42;
    wire signed [7:0] rx8_43;
    wire signed [7:0] rx8_44;
    wire signed [7:0] rx8_45;
    wire signed [7:0] rx8_46;
    wire signed [7:0] rx8_47;
    wire signed [7:0] rx8_48;
    wire signed [7:0] rx8_49;
    wire signed [7:0] rx8_50;
    wire signed [7:0] rx8_51;
    wire signed [7:0] rx8_52;
    wire signed [7:0] rx8_53;
    wire signed [7:0] rx8_54;
    wire signed [7:0] rx8_55;
    wire signed [7:0] rx8_56;
    wire signed [7:0] rx8_57;
    wire signed [7:0] rx8_58;
    wire signed [7:0] rx8_59;
    wire signed [7:0] rx8_60;
    wire signed [7:0] rx8_61;
    wire signed [7:0] rx8_62;
    wire signed [7:0] rx8_63;

    trunc16_to_8_64lane u_trunc (
        .din16_0(rx16_0),   .din16_1(rx16_1),   .din16_2(rx16_2),   .din16_3(rx16_3),
        .din16_4(rx16_4),   .din16_5(rx16_5),   .din16_6(rx16_6),   .din16_7(rx16_7),
        .din16_8(rx16_8),   .din16_9(rx16_9),   .din16_10(rx16_10), .din16_11(rx16_11),
        .din16_12(rx16_12), .din16_13(rx16_13), .din16_14(rx16_14), .din16_15(rx16_15),
        .din16_16(rx16_16), .din16_17(rx16_17), .din16_18(rx16_18), .din16_19(rx16_19),
        .din16_20(rx16_20), .din16_21(rx16_21), .din16_22(rx16_22), .din16_23(rx16_23),
        .din16_24(rx16_24), .din16_25(rx16_25), .din16_26(rx16_26), .din16_27(rx16_27),
        .din16_28(rx16_28), .din16_29(rx16_29), .din16_30(rx16_30), .din16_31(rx16_31),
        .din16_32(rx16_32), .din16_33(rx16_33), .din16_34(rx16_34), .din16_35(rx16_35),
        .din16_36(rx16_36), .din16_37(rx16_37), .din16_38(rx16_38), .din16_39(rx16_39),
        .din16_40(rx16_40), .din16_41(rx16_41), .din16_42(rx16_42), .din16_43(rx16_43),
        .din16_44(rx16_44), .din16_45(rx16_45), .din16_46(rx16_46), .din16_47(rx16_47),
        .din16_48(rx16_48), .din16_49(rx16_49), .din16_50(rx16_50), .din16_51(rx16_51),
        .din16_52(rx16_52), .din16_53(rx16_53), .din16_54(rx16_54), .din16_55(rx16_55),
        .din16_56(rx16_56), .din16_57(rx16_57), .din16_58(rx16_58), .din16_59(rx16_59),
        .din16_60(rx16_60), .din16_61(rx16_61), .din16_62(rx16_62), .din16_63(rx16_63),

        .dout8_0(rx8_0),   .dout8_1(rx8_1),   .dout8_2(rx8_2),   .dout8_3(rx8_3),
        .dout8_4(rx8_4),   .dout8_5(rx8_5),   .dout8_6(rx8_6),   .dout8_7(rx8_7),
        .dout8_8(rx8_8),   .dout8_9(rx8_9),   .dout8_10(rx8_10), .dout8_11(rx8_11),
        .dout8_12(rx8_12), .dout8_13(rx8_13), .dout8_14(rx8_14), .dout8_15(rx8_15),
        .dout8_16(rx8_16), .dout8_17(rx8_17), .dout8_18(rx8_18), .dout8_19(rx8_19),
        .dout8_20(rx8_20), .dout8_21(rx8_21), .dout8_22(rx8_22), .dout8_23(rx8_23),
        .dout8_24(rx8_24), .dout8_25(rx8_25), .dout8_26(rx8_26), .dout8_27(rx8_27),
        .dout8_28(rx8_28), .dout8_29(rx8_29), .dout8_30(rx8_30), .dout8_31(rx8_31),
        .dout8_32(rx8_32), .dout8_33(rx8_33), .dout8_34(rx8_34), .dout8_35(rx8_35),
        .dout8_36(rx8_36), .dout8_37(rx8_37), .dout8_38(rx8_38), .dout8_39(rx8_39),
        .dout8_40(rx8_40), .dout8_41(rx8_41), .dout8_42(rx8_42), .dout8_43(rx8_43),
        .dout8_44(rx8_44), .dout8_45(rx8_45), .dout8_46(rx8_46), .dout8_47(rx8_47),
        .dout8_48(rx8_48), .dout8_49(rx8_49), .dout8_50(rx8_50), .dout8_51(rx8_51),
        .dout8_52(rx8_52), .dout8_53(rx8_53), .dout8_54(rx8_54), .dout8_55(rx8_55),
        .dout8_56(rx8_56), .dout8_57(rx8_57), .dout8_58(rx8_58), .dout8_59(rx8_59),
        .dout8_60(rx8_60), .dout8_61(rx8_61), .dout8_62(rx8_62), .dout8_63(rx8_63)
    );

    // ------------------------------------------------------------------------
    // 3) DECODE rx8 -> bits_next[63:0]
    // ------------------------------------------------------------------------
    wire [63:0] bits_next;

    generate
        if (USE_THRESHOLD) begin : G_TH
            assign bits_next[0]  = (rx8_0  > th);
            assign bits_next[1]  = (rx8_1  > th);
            assign bits_next[2]  = (rx8_2  > th);
            assign bits_next[3]  = (rx8_3  > th);
            assign bits_next[4]  = (rx8_4  > th);
            assign bits_next[5]  = (rx8_5  > th);
            assign bits_next[6]  = (rx8_6  > th);
            assign bits_next[7]  = (rx8_7  > th);
            assign bits_next[8]  = (rx8_8  > th);
            assign bits_next[9]  = (rx8_9  > th);
            assign bits_next[10] = (rx8_10 > th);
            assign bits_next[11] = (rx8_11 > th);
            assign bits_next[12] = (rx8_12 > th);
            assign bits_next[13] = (rx8_13 > th);
            assign bits_next[14] = (rx8_14 > th);
            assign bits_next[15] = (rx8_15 > th);
            assign bits_next[16] = (rx8_16 > th);
            assign bits_next[17] = (rx8_17 > th);
            assign bits_next[18] = (rx8_18 > th);
            assign bits_next[19] = (rx8_19 > th);
            assign bits_next[20] = (rx8_20 > th);
            assign bits_next[21] = (rx8_21 > th);
            assign bits_next[22] = (rx8_22 > th);
            assign bits_next[23] = (rx8_23 > th);
            assign bits_next[24] = (rx8_24 > th);
            assign bits_next[25] = (rx8_25 > th);
            assign bits_next[26] = (rx8_26 > th);
            assign bits_next[27] = (rx8_27 > th);
            assign bits_next[28] = (rx8_28 > th);
            assign bits_next[29] = (rx8_29 > th);
            assign bits_next[30] = (rx8_30 > th);
            assign bits_next[31] = (rx8_31 > th);
            assign bits_next[32] = (rx8_32 > th);
            assign bits_next[33] = (rx8_33 > th);
            assign bits_next[34] = (rx8_34 > th);
            assign bits_next[35] = (rx8_35 > th);
            assign bits_next[36] = (rx8_36 > th);
            assign bits_next[37] = (rx8_37 > th);
            assign bits_next[38] = (rx8_38 > th);
            assign bits_next[39] = (rx8_39 > th);
            assign bits_next[40] = (rx8_40 > th);
            assign bits_next[41] = (rx8_41 > th);
            assign bits_next[42] = (rx8_42 > th);
            assign bits_next[43] = (rx8_43 > th);
            assign bits_next[44] = (rx8_44 > th);
            assign bits_next[45] = (rx8_45 > th);
            assign bits_next[46] = (rx8_46 > th);
            assign bits_next[47] = (rx8_47 > th);
            assign bits_next[48] = (rx8_48 > th);
            assign bits_next[49] = (rx8_49 > th);
            assign bits_next[50] = (rx8_50 > th);
            assign bits_next[51] = (rx8_51 > th);
            assign bits_next[52] = (rx8_52 > th);
            assign bits_next[53] = (rx8_53 > th);
            assign bits_next[54] = (rx8_54 > th);
            assign bits_next[55] = (rx8_55 > th);
            assign bits_next[56] = (rx8_56 > th);
            assign bits_next[57] = (rx8_57 > th);
            assign bits_next[58] = (rx8_58 > th);
            assign bits_next[59] = (rx8_59 > th);
            assign bits_next[60] = (rx8_60 > th);
            assign bits_next[61] = (rx8_61 > th);
            assign bits_next[62] = (rx8_62 > th);
            assign bits_next[63] = (rx8_63 > th);
        end else begin : G_SIGN
            assign bits_next[0]  = ~rx8_0[7];
            assign bits_next[1]  = ~rx8_1[7];
            assign bits_next[2]  = ~rx8_2[7];
            assign bits_next[3]  = ~rx8_3[7];
            assign bits_next[4]  = ~rx8_4[7];
            assign bits_next[5]  = ~rx8_5[7];
            assign bits_next[6]  = ~rx8_6[7];
            assign bits_next[7]  = ~rx8_7[7];
            assign bits_next[8]  = ~rx8_8[7];
            assign bits_next[9]  = ~rx8_9[7];
            assign bits_next[10] = ~rx8_10[7];
            assign bits_next[11] = ~rx8_11[7];
            assign bits_next[12] = ~rx8_12[7];
            assign bits_next[13] = ~rx8_13[7];
            assign bits_next[14] = ~rx8_14[7];
            assign bits_next[15] = ~rx8_15[7];
            assign bits_next[16] = ~rx8_16[7];
            assign bits_next[17] = ~rx8_17[7];
            assign bits_next[18] = ~rx8_18[7];
            assign bits_next[19] = ~rx8_19[7];
            assign bits_next[20] = ~rx8_20[7];
            assign bits_next[21] = ~rx8_21[7];
            assign bits_next[22] = ~rx8_22[7];
            assign bits_next[23] = ~rx8_23[7];
            assign bits_next[24] = ~rx8_24[7];
            assign bits_next[25] = ~rx8_25[7];
            assign bits_next[26] = ~rx8_26[7];
            assign bits_next[27] = ~rx8_27[7];
            assign bits_next[28] = ~rx8_28[7];
            assign bits_next[29] = ~rx8_29[7];
            assign bits_next[30] = ~rx8_30[7];
            assign bits_next[31] = ~rx8_31[7];
            assign bits_next[32] = ~rx8_32[7];
            assign bits_next[33] = ~rx8_33[7];
            assign bits_next[34] = ~rx8_34[7];
            assign bits_next[35] = ~rx8_35[7];
            assign bits_next[36] = ~rx8_36[7];
            assign bits_next[37] = ~rx8_37[7];
            assign bits_next[38] = ~rx8_38[7];
            assign bits_next[39] = ~rx8_39[7];
            assign bits_next[40] = ~rx8_40[7];
            assign bits_next[41] = ~rx8_41[7];
            assign bits_next[42] = ~rx8_42[7];
            assign bits_next[43] = ~rx8_43[7];
            assign bits_next[44] = ~rx8_44[7];
            assign bits_next[45] = ~rx8_45[7];
            assign bits_next[46] = ~rx8_46[7];
            assign bits_next[47] = ~rx8_47[7];
            assign bits_next[48] = ~rx8_48[7];
            assign bits_next[49] = ~rx8_49[7];
            assign bits_next[50] = ~rx8_50[7];
            assign bits_next[51] = ~rx8_51[7];
            assign bits_next[52] = ~rx8_52[7];
            assign bits_next[53] = ~rx8_53[7];
            assign bits_next[54] = ~rx8_54[7];
            assign bits_next[55] = ~rx8_55[7];
            assign bits_next[56] = ~rx8_56[7];
            assign bits_next[57] = ~rx8_57[7];
            assign bits_next[58] = ~rx8_58[7];
            assign bits_next[59] = ~rx8_59[7];
            assign bits_next[60] = ~rx8_60[7];
            assign bits_next[61] = ~rx8_61[7];
            assign bits_next[62] = ~rx8_62[7];
            assign bits_next[63] = ~rx8_63[7];
        end
    endgenerate

    // ------------------------------------------------------------------------
    // 4) REGISTER OUTPUTS
    // ------------------------------------------------------------------------
    always @(posedge aclk) begin
        if (!aresetn) begin
            rx_bits       <= 64'd0;
            rx_bits_valid <= 1'b0;
        end else begin
            rx_bits_valid <= frame_valid;
            if (frame_valid) begin
                rx_bits <= bits_next;
            end
        end
    end

endmodule