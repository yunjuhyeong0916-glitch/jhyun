`timescale 1ns/1ps
// ============================================================================
// rx_bd_shim_raw1024_to_bitplanes
// - Top wrapper:
//   in_data_16b[1023:0] -> unpack -> trunc -> gray decode -> rx_bits0/1/2
// ============================================================================
module rx_bd_shim_raw1024_to_bitplanes (
    input  wire          aclk,
    input  wire          aresetn,

    input  wire [1:0]    mode,        // 00=NRZ, 01=PAM4, 10=PAM8
    input  wire [1023:0] in_data_16b,  // packed 64*16b

    output wire [63:0]   rx_bits0,
    output wire [63:0]   rx_bits1,
    output wire [63:0]   rx_bits2
);

    // unpacked 16b lanes
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

    // truncated 8b lanes
    wire signed [7:0] rx8_0,  rx8_1,  rx8_2,  rx8_3,  rx8_4,  rx8_5,  rx8_6,  rx8_7;
    wire signed [7:0] rx8_8,  rx8_9,  rx8_10, rx8_11, rx8_12, rx8_13, rx8_14, rx8_15;
    wire signed [7:0] rx8_16, rx8_17, rx8_18, rx8_19, rx8_20, rx8_21, rx8_22, rx8_23;
    wire signed [7:0] rx8_24, rx8_25, rx8_26, rx8_27, rx8_28, rx8_29, rx8_30, rx8_31;
    wire signed [7:0] rx8_32, rx8_33, rx8_34, rx8_35, rx8_36, rx8_37, rx8_38, rx8_39;
    wire signed [7:0] rx8_40, rx8_41, rx8_42, rx8_43, rx8_44, rx8_45, rx8_46, rx8_47;
    wire signed [7:0] rx8_48, rx8_49, rx8_50, rx8_51, rx8_52, rx8_53, rx8_54, rx8_55;
    wire signed [7:0] rx8_56, rx8_57, rx8_58, rx8_59, rx8_60, rx8_61, rx8_62, rx8_63;

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

    rx_gray_decode64lane_bitplanes u_dec (
        .aclk(aclk),
        .aresetn(aresetn),
        .mode(mode),

        .rx8_0(rx8_0),   .rx8_1(rx8_1),   .rx8_2(rx8_2),   .rx8_3(rx8_3),
        .rx8_4(rx8_4),   .rx8_5(rx8_5),   .rx8_6(rx8_6),   .rx8_7(rx8_7),
        .rx8_8(rx8_8),   .rx8_9(rx8_9),   .rx8_10(rx8_10), .rx8_11(rx8_11),
        .rx8_12(rx8_12), .rx8_13(rx8_13), .rx8_14(rx8_14), .rx8_15(rx8_15),
        .rx8_16(rx8_16), .rx8_17(rx8_17), .rx8_18(rx8_18), .rx8_19(rx8_19),
        .rx8_20(rx8_20), .rx8_21(rx8_21), .rx8_22(rx8_22), .rx8_23(rx8_23),
        .rx8_24(rx8_24), .rx8_25(rx8_25), .rx8_26(rx8_26), .rx8_27(rx8_27),
        .rx8_28(rx8_28), .rx8_29(rx8_29), .rx8_30(rx8_30), .rx8_31(rx8_31),
        .rx8_32(rx8_32), .rx8_33(rx8_33), .rx8_34(rx8_34), .rx8_35(rx8_35),
        .rx8_36(rx8_36), .rx8_37(rx8_37), .rx8_38(rx8_38), .rx8_39(rx8_39),
        .rx8_40(rx8_40), .rx8_41(rx8_41), .rx8_42(rx8_42), .rx8_43(rx8_43),
        .rx8_44(rx8_44), .rx8_45(rx8_45), .rx8_46(rx8_46), .rx8_47(rx8_47),
        .rx8_48(rx8_48), .rx8_49(rx8_49), .rx8_50(rx8_50), .rx8_51(rx8_51),
        .rx8_52(rx8_52), .rx8_53(rx8_53), .rx8_54(rx8_54), .rx8_55(rx8_55),
        .rx8_56(rx8_56), .rx8_57(rx8_57), .rx8_58(rx8_58), .rx8_59(rx8_59),
        .rx8_60(rx8_60), .rx8_61(rx8_61), .rx8_62(rx8_62), .rx8_63(rx8_63),

        .rx_bits0(rx_bits0),
        .rx_bits1(rx_bits1),
        .rx_bits2(rx_bits2)
    );

endmodule