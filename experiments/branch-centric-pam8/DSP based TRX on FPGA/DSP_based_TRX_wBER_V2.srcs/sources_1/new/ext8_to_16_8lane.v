`timescale 1ns/1ps

// ============================================================================
// ext8_to_16_64lane (explicit ports, full-scale mapping)
// - 8bit signed -> 16bit signed
// - 8bit full-scale (-128~127) -> 16bit full-scale (~¡¾32768)
// ============================================================================

module ext8_to_16_64lane (
    input  signed [7:0]  din8_0,
    input  signed [7:0]  din8_1,
    input  signed [7:0]  din8_2,
    input  signed [7:0]  din8_3,
    input  signed [7:0]  din8_4,
    input  signed [7:0]  din8_5,
    input  signed [7:0]  din8_6,
    input  signed [7:0]  din8_7,
    input  signed [7:0]  din8_8,
    input  signed [7:0]  din8_9,
    input  signed [7:0]  din8_10,
    input  signed [7:0]  din8_11,
    input  signed [7:0]  din8_12,
    input  signed [7:0]  din8_13,
    input  signed [7:0]  din8_14,
    input  signed [7:0]  din8_15,
    input  signed [7:0]  din8_16,
    input  signed [7:0]  din8_17,
    input  signed [7:0]  din8_18,
    input  signed [7:0]  din8_19,
    input  signed [7:0]  din8_20,
    input  signed [7:0]  din8_21,
    input  signed [7:0]  din8_22,
    input  signed [7:0]  din8_23,
    input  signed [7:0]  din8_24,
    input  signed [7:0]  din8_25,
    input  signed [7:0]  din8_26,
    input  signed [7:0]  din8_27,
    input  signed [7:0]  din8_28,
    input  signed [7:0]  din8_29,
    input  signed [7:0]  din8_30,
    input  signed [7:0]  din8_31,
    input  signed [7:0]  din8_32,
    input  signed [7:0]  din8_33,
    input  signed [7:0]  din8_34,
    input  signed [7:0]  din8_35,
    input  signed [7:0]  din8_36,
    input  signed [7:0]  din8_37,
    input  signed [7:0]  din8_38,
    input  signed [7:0]  din8_39,
    input  signed [7:0]  din8_40,
    input  signed [7:0]  din8_41,
    input  signed [7:0]  din8_42,
    input  signed [7:0]  din8_43,
    input  signed [7:0]  din8_44,
    input  signed [7:0]  din8_45,
    input  signed [7:0]  din8_46,
    input  signed [7:0]  din8_47,
    input  signed [7:0]  din8_48,
    input  signed [7:0]  din8_49,
    input  signed [7:0]  din8_50,
    input  signed [7:0]  din8_51,
    input  signed [7:0]  din8_52,
    input  signed [7:0]  din8_53,
    input  signed [7:0]  din8_54,
    input  signed [7:0]  din8_55,
    input  signed [7:0]  din8_56,
    input  signed [7:0]  din8_57,
    input  signed [7:0]  din8_58,
    input  signed [7:0]  din8_59,
    input  signed [7:0]  din8_60,
    input  signed [7:0]  din8_61,
    input  signed [7:0]  din8_62,
    input  signed [7:0]  din8_63,

    output signed [15:0] dout16_0,
    output signed [15:0] dout16_1,
    output signed [15:0] dout16_2,
    output signed [15:0] dout16_3,
    output signed [15:0] dout16_4,
    output signed [15:0] dout16_5,
    output signed [15:0] dout16_6,
    output signed [15:0] dout16_7,
    output signed [15:0] dout16_8,
    output signed [15:0] dout16_9,
    output signed [15:0] dout16_10,
    output signed [15:0] dout16_11,
    output signed [15:0] dout16_12,
    output signed [15:0] dout16_13,
    output signed [15:0] dout16_14,
    output signed [15:0] dout16_15,
    output signed [15:0] dout16_16,
    output signed [15:0] dout16_17,
    output signed [15:0] dout16_18,
    output signed [15:0] dout16_19,
    output signed [15:0] dout16_20,
    output signed [15:0] dout16_21,
    output signed [15:0] dout16_22,
    output signed [15:0] dout16_23,
    output signed [15:0] dout16_24,
    output signed [15:0] dout16_25,
    output signed [15:0] dout16_26,
    output signed [15:0] dout16_27,
    output signed [15:0] dout16_28,
    output signed [15:0] dout16_29,
    output signed [15:0] dout16_30,
    output signed [15:0] dout16_31,
    output signed [15:0] dout16_32,
    output signed [15:0] dout16_33,
    output signed [15:0] dout16_34,
    output signed [15:0] dout16_35,
    output signed [15:0] dout16_36,
    output signed [15:0] dout16_37,
    output signed [15:0] dout16_38,
    output signed [15:0] dout16_39,
    output signed [15:0] dout16_40,
    output signed [15:0] dout16_41,
    output signed [15:0] dout16_42,
    output signed [15:0] dout16_43,
    output signed [15:0] dout16_44,
    output signed [15:0] dout16_45,
    output signed [15:0] dout16_46,
    output signed [15:0] dout16_47,
    output signed [15:0] dout16_48,
    output signed [15:0] dout16_49,
    output signed [15:0] dout16_50,
    output signed [15:0] dout16_51,
    output signed [15:0] dout16_52,
    output signed [15:0] dout16_53,
    output signed [15:0] dout16_54,
    output signed [15:0] dout16_55,
    output signed [15:0] dout16_56,
    output signed [15:0] dout16_57,
    output signed [15:0] dout16_58,
    output signed [15:0] dout16_59,
    output signed [15:0] dout16_60,
    output signed [15:0] dout16_61,
    output signed [15:0] dout16_62,
    output signed [15:0] dout16_63
);

    // sign-extend + full-scale shift (<<8)
    assign dout16_0  = {{8{din8_0[7]}},  din8_0 } <<< 8;
    assign dout16_1  = {{8{din8_1[7]}},  din8_1 } <<< 8;
    assign dout16_2  = {{8{din8_2[7]}},  din8_2 } <<< 8;
    assign dout16_3  = {{8{din8_3[7]}},  din8_3 } <<< 8;
    assign dout16_4  = {{8{din8_4[7]}},  din8_4 } <<< 8;
    assign dout16_5  = {{8{din8_5[7]}},  din8_5 } <<< 8;
    assign dout16_6  = {{8{din8_6[7]}},  din8_6 } <<< 8;
    assign dout16_7  = {{8{din8_7[7]}},  din8_7 } <<< 8;
    assign dout16_8  = {{8{din8_8[7]}},  din8_8 } <<< 8;
    assign dout16_9  = {{8{din8_9[7]}},  din8_9 } <<< 8;
    assign dout16_10 = {{8{din8_10[7]}}, din8_10} <<< 8;
    assign dout16_11 = {{8{din8_11[7]}}, din8_11} <<< 8;
    assign dout16_12 = {{8{din8_12[7]}}, din8_12} <<< 8;
    assign dout16_13 = {{8{din8_13[7]}}, din8_13} <<< 8;
    assign dout16_14 = {{8{din8_14[7]}}, din8_14} <<< 8;
    assign dout16_15 = {{8{din8_15[7]}}, din8_15} <<< 8;
    assign dout16_16 = {{8{din8_16[7]}}, din8_16} <<< 8;
    assign dout16_17 = {{8{din8_17[7]}}, din8_17} <<< 8;
    assign dout16_18 = {{8{din8_18[7]}}, din8_18} <<< 8;
    assign dout16_19 = {{8{din8_19[7]}}, din8_19} <<< 8;
    assign dout16_20 = {{8{din8_20[7]}}, din8_20} <<< 8;
    assign dout16_21 = {{8{din8_21[7]}}, din8_21} <<< 8;
    assign dout16_22 = {{8{din8_22[7]}}, din8_22} <<< 8;
    assign dout16_23 = {{8{din8_23[7]}}, din8_23} <<< 8;
    assign dout16_24 = {{8{din8_24[7]}}, din8_24} <<< 8;
    assign dout16_25 = {{8{din8_25[7]}}, din8_25} <<< 8;
    assign dout16_26 = {{8{din8_26[7]}}, din8_26} <<< 8;
    assign dout16_27 = {{8{din8_27[7]}}, din8_27} <<< 8;
    assign dout16_28 = {{8{din8_28[7]}}, din8_28} <<< 8;
    assign dout16_29 = {{8{din8_29[7]}}, din8_29} <<< 8;
    assign dout16_30 = {{8{din8_30[7]}}, din8_30} <<< 8;
    assign dout16_31 = {{8{din8_31[7]}}, din8_31} <<< 8;
    assign dout16_32 = {{8{din8_32[7]}}, din8_32} <<< 8;
    assign dout16_33 = {{8{din8_33[7]}}, din8_33} <<< 8;
    assign dout16_34 = {{8{din8_34[7]}}, din8_34} <<< 8;
    assign dout16_35 = {{8{din8_35[7]}}, din8_35} <<< 8;
    assign dout16_36 = {{8{din8_36[7]}}, din8_36} <<< 8;
    assign dout16_37 = {{8{din8_37[7]}}, din8_37} <<< 8;
    assign dout16_38 = {{8{din8_38[7]}}, din8_38} <<< 8;
    assign dout16_39 = {{8{din8_39[7]}}, din8_39} <<< 8;
    assign dout16_40 = {{8{din8_40[7]}}, din8_40} <<< 8;
    assign dout16_41 = {{8{din8_41[7]}}, din8_41} <<< 8;
    assign dout16_42 = {{8{din8_42[7]}}, din8_42} <<< 8;
    assign dout16_43 = {{8{din8_43[7]}}, din8_43} <<< 8;
    assign dout16_44 = {{8{din8_44[7]}}, din8_44} <<< 8;
    assign dout16_45 = {{8{din8_45[7]}}, din8_45} <<< 8;
    assign dout16_46 = {{8{din8_46[7]}}, din8_46} <<< 8;
    assign dout16_47 = {{8{din8_47[7]}}, din8_47} <<< 8;
    assign dout16_48 = {{8{din8_48[7]}}, din8_48} <<< 8;
    assign dout16_49 = {{8{din8_49[7]}}, din8_49} <<< 8;
    assign dout16_50 = {{8{din8_50[7]}}, din8_50} <<< 8;
    assign dout16_51 = {{8{din8_51[7]}}, din8_51} <<< 8;
    assign dout16_52 = {{8{din8_52[7]}}, din8_52} <<< 8;
    assign dout16_53 = {{8{din8_53[7]}}, din8_53} <<< 8;
    assign dout16_54 = {{8{din8_54[7]}}, din8_54} <<< 8;
    assign dout16_55 = {{8{din8_55[7]}}, din8_55} <<< 8;
    assign dout16_56 = {{8{din8_56[7]}}, din8_56} <<< 8;
    assign dout16_57 = {{8{din8_57[7]}}, din8_57} <<< 8;
    assign dout16_58 = {{8{din8_58[7]}}, din8_58} <<< 8;
    assign dout16_59 = {{8{din8_59[7]}}, din8_59} <<< 8;
    assign dout16_60 = {{8{din8_60[7]}}, din8_60} <<< 8;
    assign dout16_61 = {{8{din8_61[7]}}, din8_61} <<< 8;
    assign dout16_62 = {{8{din8_62[7]}}, din8_62} <<< 8;
    assign dout16_63 = {{8{din8_63[7]}}, din8_63} <<< 8;

endmodule
