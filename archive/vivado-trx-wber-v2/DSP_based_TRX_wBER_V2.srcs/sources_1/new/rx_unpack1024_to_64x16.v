`timescale 1ns/1ps
// ============================================================================
// rx_unpack1024_to_64x16
// - Inverse of TX packing rule:
//   TX: out_data_16b[(7-g)*128 + i*16 +:16] <= tx16[g*8+i];
//   RX: rx16[g*8+i] = in_data_16b[(7-g)*128 + i*16 +:16];
// ============================================================================
module rx_unpack1024_to_64x16 (
    input  wire [1023:0] in_data_16b,

    output wire signed [15:0] rx16_0,
    output wire signed [15:0] rx16_1,
    output wire signed [15:0] rx16_2,
    output wire signed [15:0] rx16_3,
    output wire signed [15:0] rx16_4,
    output wire signed [15:0] rx16_5,
    output wire signed [15:0] rx16_6,
    output wire signed [15:0] rx16_7,
    output wire signed [15:0] rx16_8,
    output wire signed [15:0] rx16_9,
    output wire signed [15:0] rx16_10,
    output wire signed [15:0] rx16_11,
    output wire signed [15:0] rx16_12,
    output wire signed [15:0] rx16_13,
    output wire signed [15:0] rx16_14,
    output wire signed [15:0] rx16_15,
    output wire signed [15:0] rx16_16,
    output wire signed [15:0] rx16_17,
    output wire signed [15:0] rx16_18,
    output wire signed [15:0] rx16_19,
    output wire signed [15:0] rx16_20,
    output wire signed [15:0] rx16_21,
    output wire signed [15:0] rx16_22,
    output wire signed [15:0] rx16_23,
    output wire signed [15:0] rx16_24,
    output wire signed [15:0] rx16_25,
    output wire signed [15:0] rx16_26,
    output wire signed [15:0] rx16_27,
    output wire signed [15:0] rx16_28,
    output wire signed [15:0] rx16_29,
    output wire signed [15:0] rx16_30,
    output wire signed [15:0] rx16_31,
    output wire signed [15:0] rx16_32,
    output wire signed [15:0] rx16_33,
    output wire signed [15:0] rx16_34,
    output wire signed [15:0] rx16_35,
    output wire signed [15:0] rx16_36,
    output wire signed [15:0] rx16_37,
    output wire signed [15:0] rx16_38,
    output wire signed [15:0] rx16_39,
    output wire signed [15:0] rx16_40,
    output wire signed [15:0] rx16_41,
    output wire signed [15:0] rx16_42,
    output wire signed [15:0] rx16_43,
    output wire signed [15:0] rx16_44,
    output wire signed [15:0] rx16_45,
    output wire signed [15:0] rx16_46,
    output wire signed [15:0] rx16_47,
    output wire signed [15:0] rx16_48,
    output wire signed [15:0] rx16_49,
    output wire signed [15:0] rx16_50,
    output wire signed [15:0] rx16_51,
    output wire signed [15:0] rx16_52,
    output wire signed [15:0] rx16_53,
    output wire signed [15:0] rx16_54,
    output wire signed [15:0] rx16_55,
    output wire signed [15:0] rx16_56,
    output wire signed [15:0] rx16_57,
    output wire signed [15:0] rx16_58,
    output wire signed [15:0] rx16_59,
    output wire signed [15:0] rx16_60,
    output wire signed [15:0] rx16_61,
    output wire signed [15:0] rx16_62,
    output wire signed [15:0] rx16_63
);

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

endmodule