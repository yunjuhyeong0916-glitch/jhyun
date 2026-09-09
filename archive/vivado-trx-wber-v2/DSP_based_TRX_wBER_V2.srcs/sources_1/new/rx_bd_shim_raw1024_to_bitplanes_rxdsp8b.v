`timescale 1ns/1ps
// ============================================================================
// rx_bd_shim_raw1024_to_bitplanes_rxdsp8b
// - Top: in_data_16b(1024) -> unpack -> trunc(8b) -> RX DSP (8b) -> Gray decode
//
// FIX (Vivado BD friendly):
// - Do NOT export unpacked array port
// - Export trunc(pre-RX-DSP) 64-lane 8b as a single packed vector:
//      out_rx8p_packed[8*i +: 8] = lane i (i=0..63)
//   => total 64*8 = 512 bits
// ============================================================================

module rx_bd_shim_raw1024_to_bitplanes_rxdsp8b (
    input  wire          aclk,
    input  wire          aresetn,

    input  wire [1:0]    mode,        // 00=NRZ, 01=PAM4, 10=PAM8
    input  wire [1023:0] in_data_16b,

    // NEW (BD-friendly): trunc output (pre-RX-DSP) 64lane 8b packed vector
    // lane i = out_rx8p_packed[8*i +: 8]
    output wire signed [511:0] out_rx8p_packed,

    output wire [63:0]   rx_bits0,
    output wire [63:0]   rx_bits1,
    output wire [63:0]   rx_bits2
);

    // ------------------------------------------------------------------------
    // unpacked rx16
    // ------------------------------------------------------------------------
    wire signed [15:0] rx16_0,  rx16_1,  rx16_2,  rx16_3,  rx16_4,  rx16_5,  rx16_6,  rx16_7;
    wire signed [15:0] rx16_8,  rx16_9,  rx16_10, rx16_11, rx16_12, rx16_13, rx16_14, rx16_15;
    wire signed [15:0] rx16_16, rx16_17, rx16_18, rx16_19, rx16_20, rx16_21, rx16_22, rx16_23;
    wire signed [15:0] rx16_24, rx16_25, rx16_26, rx16_27, rx16_28, rx16_29, rx16_30, rx16_31;
    wire signed [15:0] rx16_32, rx16_33, rx16_34, rx16_35, rx16_36, rx16_37, rx16_38, rx16_39;
    wire signed [15:0] rx16_40, rx16_41, rx16_42, rx16_43, rx16_44, rx16_45, rx16_46, rx16_47;
    wire signed [15:0] rx16_48, rx16_49, rx16_50, rx16_51, rx16_52, rx16_53, rx16_54, rx16_55;
    wire signed [15:0] rx16_56, rx16_57, rx16_58, rx16_59, rx16_60, rx16_61, rx16_62, rx16_63;

    rx_unpack1024_to_64x16 u_unp (
        .in_data_16b(in_data_16b),
        .rx16_0(rx16_0),   .rx16_1(rx16_1),   .rx16_2(rx16_2),   .rx16_3(rx16_3),
        .rx16_4(rx16_4),   .rx16_5(rx16_5),   .rx16_6(rx16_6),   .rx16_7(rx16_7),
        .rx16_8(rx16_8),   .rx16_9(rx16_9),   .rx16_10(rx16_10), .rx16_11(rx16_11),
        .rx16_12(rx16_12), .rx16_13(rx16_13), .rx16_14(rx16_14), .rx16_15(rx16_15),
        .rx16_16(rx16_16), .rx16_17(rx16_17), .rx16_18(rx16_18), .rx16_19(rx16_19),
        .rx16_20(rx16_20), .rx16_21(rx16_21), .rx16_22(rx16_22), .rx16_23(rx16_23),
        .rx16_24(rx16_24), .rx16_25(rx16_25), .rx16_26(rx16_26), .rx16_27(rx16_27),
        .rx16_28(rx16_28), .rx16_29(rx16_29), .rx16_30(rx16_30), .rx16_31(rx16_31),
        .rx16_32(rx16_32), .rx16_33(rx16_33), .rx16_34(rx16_34), .rx16_35(rx16_35),
        .rx16_36(rx16_36), .rx16_37(rx16_37), .rx16_38(rx16_38), .rx16_39(rx16_39),
        .rx16_40(rx16_40), .rx16_41(rx16_41), .rx16_42(rx16_42), .rx16_43(rx16_43),
        .rx16_44(rx16_44), .rx16_45(rx16_45), .rx16_46(rx16_46), .rx16_47(rx16_47),
        .rx16_48(rx16_48), .rx16_49(rx16_49), .rx16_50(rx16_50), .rx16_51(rx16_51),
        .rx16_52(rx16_52), .rx16_53(rx16_53), .rx16_54(rx16_54), .rx16_55(rx16_55),
        .rx16_56(rx16_56), .rx16_57(rx16_57), .rx16_58(rx16_58), .rx16_59(rx16_59),
        .rx16_60(rx16_60), .rx16_61(rx16_61), .rx16_62(rx16_62), .rx16_63(rx16_63)
    );

    // ------------------------------------------------------------------------
    // trunc -> rx8_pre
    // ------------------------------------------------------------------------
    wire signed [7:0] rx8p_0,  rx8p_1,  rx8p_2,  rx8p_3,  rx8p_4,  rx8p_5,  rx8p_6,  rx8p_7;
    wire signed [7:0] rx8p_8,  rx8p_9,  rx8p_10, rx8p_11, rx8p_12, rx8p_13, rx8p_14, rx8p_15;
    wire signed [7:0] rx8p_16, rx8p_17, rx8p_18, rx8p_19, rx8p_20, rx8p_21, rx8p_22, rx8p_23;
    wire signed [7:0] rx8p_24, rx8p_25, rx8p_26, rx8p_27, rx8p_28, rx8p_29, rx8p_30, rx8p_31;
    wire signed [7:0] rx8p_32, rx8p_33, rx8p_34, rx8p_35, rx8p_36, rx8p_37, rx8p_38, rx8p_39;
    wire signed [7:0] rx8p_40, rx8p_41, rx8p_42, rx8p_43, rx8p_44, rx8p_45, rx8p_46, rx8p_47;
    wire signed [7:0] rx8p_48, rx8p_49, rx8p_50, rx8p_51, rx8p_52, rx8p_53, rx8p_54, rx8p_55;
    wire signed [7:0] rx8p_56, rx8p_57, rx8p_58, rx8p_59, rx8p_60, rx8p_61, rx8p_62, rx8p_63;

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

        .dout8_0(rx8p_0),   .dout8_1(rx8p_1),   .dout8_2(rx8p_2),   .dout8_3(rx8p_3),
        .dout8_4(rx8p_4),   .dout8_5(rx8p_5),   .dout8_6(rx8p_6),   .dout8_7(rx8p_7),
        .dout8_8(rx8p_8),   .dout8_9(rx8p_9),   .dout8_10(rx8p_10), .dout8_11(rx8p_11),
        .dout8_12(rx8p_12), .dout8_13(rx8p_13), .dout8_14(rx8p_14), .dout8_15(rx8p_15),
        .dout8_16(rx8p_16), .dout8_17(rx8p_17), .dout8_18(rx8p_18), .dout8_19(rx8p_19),
        .dout8_20(rx8p_20), .dout8_21(rx8p_21), .dout8_22(rx8p_22), .dout8_23(rx8p_23),
        .dout8_24(rx8p_24), .dout8_25(rx8p_25), .dout8_26(rx8p_26), .dout8_27(rx8p_27),
        .dout8_28(rx8p_28), .dout8_29(rx8p_29), .dout8_30(rx8p_30), .dout8_31(rx8p_31),
        .dout8_32(rx8p_32), .dout8_33(rx8p_33), .dout8_34(rx8p_34), .dout8_35(rx8p_35),
        .dout8_36(rx8p_36), .dout8_37(rx8p_37), .dout8_38(rx8p_38), .dout8_39(rx8p_39),
        .dout8_40(rx8p_40), .dout8_41(rx8p_41), .dout8_42(rx8p_42), .dout8_43(rx8p_43),
        .dout8_44(rx8p_44), .dout8_45(rx8p_45), .dout8_46(rx8p_46), .dout8_47(rx8p_47),
        .dout8_48(rx8p_48), .dout8_49(rx8p_49), .dout8_50(rx8p_50), .dout8_51(rx8p_51),
        .dout8_52(rx8p_52), .dout8_53(rx8p_53), .dout8_54(rx8p_54), .dout8_55(rx8p_55),
        .dout8_56(rx8p_56), .dout8_57(rx8p_57), .dout8_58(rx8p_58), .dout8_59(rx8p_59),
        .dout8_60(rx8p_60), .dout8_61(rx8p_61), .dout8_62(rx8p_62), .dout8_63(rx8p_63)
    );

    // ------------------------------------------------------------------------
    // NEW: expose trunc outputs as packed vector (combinational)
    // lane i = out_rx8p_packed[8*i +: 8]
    // ------------------------------------------------------------------------
    assign out_rx8p_packed[  0 +: 8] = rx8p_0;
    assign out_rx8p_packed[  8 +: 8] = rx8p_1;
    assign out_rx8p_packed[ 16 +: 8] = rx8p_2;
    assign out_rx8p_packed[ 24 +: 8] = rx8p_3;
    assign out_rx8p_packed[ 32 +: 8] = rx8p_4;
    assign out_rx8p_packed[ 40 +: 8] = rx8p_5;
    assign out_rx8p_packed[ 48 +: 8] = rx8p_6;
    assign out_rx8p_packed[ 56 +: 8] = rx8p_7;
    assign out_rx8p_packed[ 64 +: 8] = rx8p_8;
    assign out_rx8p_packed[ 72 +: 8] = rx8p_9;
    assign out_rx8p_packed[ 80 +: 8] = rx8p_10;
    assign out_rx8p_packed[ 88 +: 8] = rx8p_11;
    assign out_rx8p_packed[ 96 +: 8] = rx8p_12;
    assign out_rx8p_packed[104 +: 8] = rx8p_13;
    assign out_rx8p_packed[112 +: 8] = rx8p_14;
    assign out_rx8p_packed[120 +: 8] = rx8p_15;
    assign out_rx8p_packed[128 +: 8] = rx8p_16;
    assign out_rx8p_packed[136 +: 8] = rx8p_17;
    assign out_rx8p_packed[144 +: 8] = rx8p_18;
    assign out_rx8p_packed[152 +: 8] = rx8p_19;
    assign out_rx8p_packed[160 +: 8] = rx8p_20;
    assign out_rx8p_packed[168 +: 8] = rx8p_21;
    assign out_rx8p_packed[176 +: 8] = rx8p_22;
    assign out_rx8p_packed[184 +: 8] = rx8p_23;
    assign out_rx8p_packed[192 +: 8] = rx8p_24;
    assign out_rx8p_packed[200 +: 8] = rx8p_25;
    assign out_rx8p_packed[208 +: 8] = rx8p_26;
    assign out_rx8p_packed[216 +: 8] = rx8p_27;
    assign out_rx8p_packed[224 +: 8] = rx8p_28;
    assign out_rx8p_packed[232 +: 8] = rx8p_29;
    assign out_rx8p_packed[240 +: 8] = rx8p_30;
    assign out_rx8p_packed[248 +: 8] = rx8p_31;
    assign out_rx8p_packed[256 +: 8] = rx8p_32;
    assign out_rx8p_packed[264 +: 8] = rx8p_33;
    assign out_rx8p_packed[272 +: 8] = rx8p_34;
    assign out_rx8p_packed[280 +: 8] = rx8p_35;
    assign out_rx8p_packed[288 +: 8] = rx8p_36;
    assign out_rx8p_packed[296 +: 8] = rx8p_37;
    assign out_rx8p_packed[304 +: 8] = rx8p_38;
    assign out_rx8p_packed[312 +: 8] = rx8p_39;
    assign out_rx8p_packed[320 +: 8] = rx8p_40;
    assign out_rx8p_packed[328 +: 8] = rx8p_41;
    assign out_rx8p_packed[336 +: 8] = rx8p_42;
    assign out_rx8p_packed[344 +: 8] = rx8p_43;
    assign out_rx8p_packed[352 +: 8] = rx8p_44;
    assign out_rx8p_packed[360 +: 8] = rx8p_45;
    assign out_rx8p_packed[368 +: 8] = rx8p_46;
    assign out_rx8p_packed[376 +: 8] = rx8p_47;
    assign out_rx8p_packed[384 +: 8] = rx8p_48;
    assign out_rx8p_packed[392 +: 8] = rx8p_49;
    assign out_rx8p_packed[400 +: 8] = rx8p_50;
    assign out_rx8p_packed[408 +: 8] = rx8p_51;
    assign out_rx8p_packed[416 +: 8] = rx8p_52;
    assign out_rx8p_packed[424 +: 8] = rx8p_53;
    assign out_rx8p_packed[432 +: 8] = rx8p_54;
    assign out_rx8p_packed[440 +: 8] = rx8p_55;
    assign out_rx8p_packed[448 +: 8] = rx8p_56;
    assign out_rx8p_packed[456 +: 8] = rx8p_57;
    assign out_rx8p_packed[464 +: 8] = rx8p_58;
    assign out_rx8p_packed[472 +: 8] = rx8p_59;
    assign out_rx8p_packed[480 +: 8] = rx8p_60;
    assign out_rx8p_packed[488 +: 8] = rx8p_61;
    assign out_rx8p_packed[496 +: 8] = rx8p_62;
    assign out_rx8p_packed[504 +: 8] = rx8p_63;

    // ------------------------------------------------------------------------
    // RX DSP (8b) output -> rx8d_*
    // ------------------------------------------------------------------------
    wire signed [7:0] rx8d_0,  rx8d_1,  rx8d_2,  rx8d_3,  rx8d_4,  rx8d_5,  rx8d_6,  rx8d_7;
    wire signed [7:0] rx8d_8,  rx8d_9,  rx8d_10, rx8d_11, rx8d_12, rx8d_13, rx8d_14, rx8d_15;
    wire signed [7:0] rx8d_16, rx8d_17, rx8d_18, rx8d_19, rx8d_20, rx8d_21, rx8d_22, rx8d_23;
    wire signed [7:0] rx8d_24, rx8d_25, rx8d_26, rx8d_27, rx8d_28, rx8d_29, rx8d_30, rx8d_31;
    wire signed [7:0] rx8d_32, rx8d_33, rx8d_34, rx8d_35, rx8d_36, rx8d_37, rx8d_38, rx8d_39;
    wire signed [7:0] rx8d_40, rx8d_41, rx8d_42, rx8d_43, rx8d_44, rx8d_45, rx8d_46, rx8d_47;
    wire signed [7:0] rx8d_48, rx8d_49, rx8d_50, rx8d_51, rx8d_52, rx8d_53, rx8d_54, rx8d_55;
    wire signed [7:0] rx8d_56, rx8d_57, rx8d_58, rx8d_59, rx8d_60, rx8d_61, rx8d_62, rx8d_63;

    RX_DSP_64LANE_8B u_rxdsp (
        .aclk(aclk), .aresetn(aresetn),

        .din_0(rx8p_0),   .din_1(rx8p_1),   .din_2(rx8p_2),   .din_3(rx8p_3),
        .din_4(rx8p_4),   .din_5(rx8p_5),   .din_6(rx8p_6),   .din_7(rx8p_7),
        .din_8(rx8p_8),   .din_9(rx8p_9),   .din_10(rx8p_10), .din_11(rx8p_11),
        .din_12(rx8p_12), .din_13(rx8p_13), .din_14(rx8p_14), .din_15(rx8p_15),
        .din_16(rx8p_16), .din_17(rx8p_17), .din_18(rx8p_18), .din_19(rx8p_19),
        .din_20(rx8p_20), .din_21(rx8p_21), .din_22(rx8p_22), .din_23(rx8p_23),
        .din_24(rx8p_24), .din_25(rx8p_25), .din_26(rx8p_26), .din_27(rx8p_27),
        .din_28(rx8p_28), .din_29(rx8p_29), .din_30(rx8p_30), .din_31(rx8p_31),
        .din_32(rx8p_32), .din_33(rx8p_33), .din_34(rx8p_34), .din_35(rx8p_35),
        .din_36(rx8p_36), .din_37(rx8p_37), .din_38(rx8p_38), .din_39(rx8p_39),
        .din_40(rx8p_40), .din_41(rx8p_41), .din_42(rx8p_42), .din_43(rx8p_43),
        .din_44(rx8p_44), .din_45(rx8p_45), .din_46(rx8p_46), .din_47(rx8p_47),
        .din_48(rx8p_48), .din_49(rx8p_49), .din_50(rx8p_50), .din_51(rx8p_51),
        .din_52(rx8p_52), .din_53(rx8p_53), .din_54(rx8p_54), .din_55(rx8p_55),
        .din_56(rx8p_56), .din_57(rx8p_57), .din_58(rx8p_58), .din_59(rx8p_59),
        .din_60(rx8p_60), .din_61(rx8p_61), .din_62(rx8p_62), .din_63(rx8p_63),

        .dout_0(rx8d_0),   .dout_1(rx8d_1),   .dout_2(rx8d_2),   .dout_3(rx8d_3),
        .dout_4(rx8d_4),   .dout_5(rx8d_5),   .dout_6(rx8d_6),   .dout_7(rx8d_7),
        .dout_8(rx8d_8),   .dout_9(rx8d_9),   .dout_10(rx8d_10), .dout_11(rx8d_11),
        .dout_12(rx8d_12), .dout_13(rx8d_13), .dout_14(rx8d_14), .dout_15(rx8d_15),
        .dout_16(rx8d_16), .dout_17(rx8d_17), .dout_18(rx8d_18), .dout_19(rx8d_19),
        .dout_20(rx8d_20), .dout_21(rx8d_21), .dout_22(rx8d_22), .dout_23(rx8d_23),
        .dout_24(rx8d_24), .dout_25(rx8d_25), .dout_26(rx8d_26), .dout_27(rx8d_27),
        .dout_28(rx8d_28), .dout_29(rx8d_29), .dout_30(rx8d_30), .dout_31(rx8d_31),
        .dout_32(rx8d_32), .dout_33(rx8d_33), .dout_34(rx8d_34), .dout_35(rx8d_35),
        .dout_36(rx8d_36), .dout_37(rx8d_37), .dout_38(rx8d_38), .dout_39(rx8d_39),
        .dout_40(rx8d_40), .dout_41(rx8d_41), .dout_42(rx8d_42), .dout_43(rx8d_43),
        .dout_44(rx8d_44), .dout_45(rx8d_45), .dout_46(rx8d_46), .dout_47(rx8d_47),
        .dout_48(rx8d_48), .dout_49(rx8d_49), .dout_50(rx8d_50), .dout_51(rx8d_51),
        .dout_52(rx8d_52), .dout_53(rx8d_53), .dout_54(rx8d_54), .dout_55(rx8d_55),
        .dout_56(rx8d_56), .dout_57(rx8d_57), .dout_58(rx8d_58), .dout_59(rx8d_59),
        .dout_60(rx8d_60), .dout_61(rx8d_61), .dout_62(rx8d_62), .dout_63(rx8d_63)
    );

    // ------------------------------------------------------------------------
    // Gray decode -> bitplanes
    // ------------------------------------------------------------------------
    rx_gray_decode64lane_bitplanes u_dec (
        .aclk(aclk), .aresetn(aresetn), .mode(mode),

        .rx8_0(rx8d_0),   .rx8_1(rx8d_1),   .rx8_2(rx8d_2),   .rx8_3(rx8d_3),
        .rx8_4(rx8d_4),   .rx8_5(rx8d_5),   .rx8_6(rx8d_6),   .rx8_7(rx8d_7),
        .rx8_8(rx8d_8),   .rx8_9(rx8d_9),   .rx8_10(rx8d_10), .rx8_11(rx8d_11),
        .rx8_12(rx8d_12), .rx8_13(rx8d_13), .rx8_14(rx8d_14), .rx8_15(rx8d_15),
        .rx8_16(rx8d_16), .rx8_17(rx8d_17), .rx8_18(rx8d_18), .rx8_19(rx8d_19),
        .rx8_20(rx8d_20), .rx8_21(rx8d_21), .rx8_22(rx8d_22), .rx8_23(rx8d_23),
        .rx8_24(rx8d_24), .rx8_25(rx8d_25), .rx8_26(rx8d_26), .rx8_27(rx8d_27),
        .rx8_28(rx8d_28), .rx8_29(rx8d_29), .rx8_30(rx8d_30), .rx8_31(rx8d_31),
        .rx8_32(rx8d_32), .rx8_33(rx8d_33), .rx8_34(rx8d_34), .rx8_35(rx8d_35),
        .rx8_36(rx8d_36), .rx8_37(rx8d_37), .rx8_38(rx8d_38), .rx8_39(rx8d_39),
        .rx8_40(rx8d_40), .rx8_41(rx8d_41), .rx8_42(rx8d_42), .rx8_43(rx8d_43),
        .rx8_44(rx8d_44), .rx8_45(rx8d_45), .rx8_46(rx8d_46), .rx8_47(rx8d_47),
        .rx8_48(rx8d_48), .rx8_49(rx8d_49), .rx8_50(rx8d_50), .rx8_51(rx8d_51),
        .rx8_52(rx8d_52), .rx8_53(rx8d_53), .rx8_54(rx8d_54), .rx8_55(rx8d_55),
        .rx8_56(rx8d_56), .rx8_57(rx8d_57), .rx8_58(rx8d_58), .rx8_59(rx8d_59),
        .rx8_60(rx8d_60), .rx8_61(rx8d_61), .rx8_62(rx8d_62), .rx8_63(rx8d_63),

        .rx_bits0(rx_bits0),
        .rx_bits1(rx_bits1),
        .rx_bits2(rx_bits2)
    );

endmodule