`timescale 1ns/1ps

// ============================================================================
// trunc16_to_8_64lane (explicit ports, inverse of ext8_to_16_64lane)
// - 16bit signed -> 8bit signed
// - arithmetic right shift >>>7 followed by signed 8-bit saturation
// - prevents large 4GS/s RFDC samples from wrapping when shifted value exceeds
//   the signed 8-bit output range.
// ============================================================================

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 Data Formatting and Demapping
// Module Name: trunc16_to_8_64lane
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Truncates and saturates 64 lanes of signed 16-bit samples to signed 8-bit samples.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module trunc16_to_8_64lane (

    input  signed [15:0] din16_0,
    input  signed [15:0] din16_1,
    input  signed [15:0] din16_2,
    input  signed [15:0] din16_3,
    input  signed [15:0] din16_4,
    input  signed [15:0] din16_5,
    input  signed [15:0] din16_6,
    input  signed [15:0] din16_7,
    input  signed [15:0] din16_8,
    input  signed [15:0] din16_9,
    input  signed [15:0] din16_10,
    input  signed [15:0] din16_11,
    input  signed [15:0] din16_12,
    input  signed [15:0] din16_13,
    input  signed [15:0] din16_14,
    input  signed [15:0] din16_15,
    input  signed [15:0] din16_16,
    input  signed [15:0] din16_17,
    input  signed [15:0] din16_18,
    input  signed [15:0] din16_19,
    input  signed [15:0] din16_20,
    input  signed [15:0] din16_21,
    input  signed [15:0] din16_22,
    input  signed [15:0] din16_23,
    input  signed [15:0] din16_24,
    input  signed [15:0] din16_25,
    input  signed [15:0] din16_26,
    input  signed [15:0] din16_27,
    input  signed [15:0] din16_28,
    input  signed [15:0] din16_29,
    input  signed [15:0] din16_30,
    input  signed [15:0] din16_31,
    input  signed [15:0] din16_32,
    input  signed [15:0] din16_33,
    input  signed [15:0] din16_34,
    input  signed [15:0] din16_35,
    input  signed [15:0] din16_36,
    input  signed [15:0] din16_37,
    input  signed [15:0] din16_38,
    input  signed [15:0] din16_39,
    input  signed [15:0] din16_40,
    input  signed [15:0] din16_41,
    input  signed [15:0] din16_42,
    input  signed [15:0] din16_43,
    input  signed [15:0] din16_44,
    input  signed [15:0] din16_45,
    input  signed [15:0] din16_46,
    input  signed [15:0] din16_47,
    input  signed [15:0] din16_48,
    input  signed [15:0] din16_49,
    input  signed [15:0] din16_50,
    input  signed [15:0] din16_51,
    input  signed [15:0] din16_52,
    input  signed [15:0] din16_53,
    input  signed [15:0] din16_54,
    input  signed [15:0] din16_55,
    input  signed [15:0] din16_56,
    input  signed [15:0] din16_57,
    input  signed [15:0] din16_58,
    input  signed [15:0] din16_59,
    input  signed [15:0] din16_60,
    input  signed [15:0] din16_61,
    input  signed [15:0] din16_62,
    input  signed [15:0] din16_63,

    output signed [7:0] dout8_0,
    output signed [7:0] dout8_1,
    output signed [7:0] dout8_2,
    output signed [7:0] dout8_3,
    output signed [7:0] dout8_4,
    output signed [7:0] dout8_5,
    output signed [7:0] dout8_6,
    output signed [7:0] dout8_7,
    output signed [7:0] dout8_8,
    output signed [7:0] dout8_9,
    output signed [7:0] dout8_10,
    output signed [7:0] dout8_11,
    output signed [7:0] dout8_12,
    output signed [7:0] dout8_13,
    output signed [7:0] dout8_14,
    output signed [7:0] dout8_15,
    output signed [7:0] dout8_16,
    output signed [7:0] dout8_17,
    output signed [7:0] dout8_18,
    output signed [7:0] dout8_19,
    output signed [7:0] dout8_20,
    output signed [7:0] dout8_21,
    output signed [7:0] dout8_22,
    output signed [7:0] dout8_23,
    output signed [7:0] dout8_24,
    output signed [7:0] dout8_25,
    output signed [7:0] dout8_26,
    output signed [7:0] dout8_27,
    output signed [7:0] dout8_28,
    output signed [7:0] dout8_29,
    output signed [7:0] dout8_30,
    output signed [7:0] dout8_31,
    output signed [7:0] dout8_32,
    output signed [7:0] dout8_33,
    output signed [7:0] dout8_34,
    output signed [7:0] dout8_35,
    output signed [7:0] dout8_36,
    output signed [7:0] dout8_37,
    output signed [7:0] dout8_38,
    output signed [7:0] dout8_39,
    output signed [7:0] dout8_40,
    output signed [7:0] dout8_41,
    output signed [7:0] dout8_42,
    output signed [7:0] dout8_43,
    output signed [7:0] dout8_44,
    output signed [7:0] dout8_45,
    output signed [7:0] dout8_46,
    output signed [7:0] dout8_47,
    output signed [7:0] dout8_48,
    output signed [7:0] dout8_49,
    output signed [7:0] dout8_50,
    output signed [7:0] dout8_51,
    output signed [7:0] dout8_52,
    output signed [7:0] dout8_53,
    output signed [7:0] dout8_54,
    output signed [7:0] dout8_55,
    output signed [7:0] dout8_56,
    output signed [7:0] dout8_57,
    output signed [7:0] dout8_58,
    output signed [7:0] dout8_59,
    output signed [7:0] dout8_60,
    output signed [7:0] dout8_61,
    output signed [7:0] dout8_62,
    output signed [7:0] dout8_63
);

    function signed [7:0] sat8_shift7;
        input signed [15:0] din;
        reg signed [15:0] shifted;
        begin
            shifted = din >>> 7;
            if (shifted > 16'sd127)
                sat8_shift7 = 8'sd127;
            else if (shifted < -16'sd128)
                sat8_shift7 = 8'sh80;
            else
                sat8_shift7 = shifted[7:0];
        end
    endfunction

    assign dout8_0  = sat8_shift7(din16_0);
    assign dout8_1  = sat8_shift7(din16_1);
    assign dout8_2  = sat8_shift7(din16_2);
    assign dout8_3  = sat8_shift7(din16_3);
    assign dout8_4  = sat8_shift7(din16_4);
    assign dout8_5  = sat8_shift7(din16_5);
    assign dout8_6  = sat8_shift7(din16_6);
    assign dout8_7  = sat8_shift7(din16_7);
    assign dout8_8  = sat8_shift7(din16_8);
    assign dout8_9  = sat8_shift7(din16_9);
    assign dout8_10 = sat8_shift7(din16_10);
    assign dout8_11 = sat8_shift7(din16_11);
    assign dout8_12 = sat8_shift7(din16_12);
    assign dout8_13 = sat8_shift7(din16_13);
    assign dout8_14 = sat8_shift7(din16_14);
    assign dout8_15 = sat8_shift7(din16_15);
    assign dout8_16 = sat8_shift7(din16_16);
    assign dout8_17 = sat8_shift7(din16_17);
    assign dout8_18 = sat8_shift7(din16_18);
    assign dout8_19 = sat8_shift7(din16_19);
    assign dout8_20 = sat8_shift7(din16_20);
    assign dout8_21 = sat8_shift7(din16_21);
    assign dout8_22 = sat8_shift7(din16_22);
    assign dout8_23 = sat8_shift7(din16_23);
    assign dout8_24 = sat8_shift7(din16_24);
    assign dout8_25 = sat8_shift7(din16_25);
    assign dout8_26 = sat8_shift7(din16_26);
    assign dout8_27 = sat8_shift7(din16_27);
    assign dout8_28 = sat8_shift7(din16_28);
    assign dout8_29 = sat8_shift7(din16_29);
    assign dout8_30 = sat8_shift7(din16_30);
    assign dout8_31 = sat8_shift7(din16_31);
    assign dout8_32 = sat8_shift7(din16_32);
    assign dout8_33 = sat8_shift7(din16_33);
    assign dout8_34 = sat8_shift7(din16_34);
    assign dout8_35 = sat8_shift7(din16_35);
    assign dout8_36 = sat8_shift7(din16_36);
    assign dout8_37 = sat8_shift7(din16_37);
    assign dout8_38 = sat8_shift7(din16_38);
    assign dout8_39 = sat8_shift7(din16_39);
    assign dout8_40 = sat8_shift7(din16_40);
    assign dout8_41 = sat8_shift7(din16_41);
    assign dout8_42 = sat8_shift7(din16_42);
    assign dout8_43 = sat8_shift7(din16_43);
    assign dout8_44 = sat8_shift7(din16_44);
    assign dout8_45 = sat8_shift7(din16_45);
    assign dout8_46 = sat8_shift7(din16_46);
    assign dout8_47 = sat8_shift7(din16_47);
    assign dout8_48 = sat8_shift7(din16_48);
    assign dout8_49 = sat8_shift7(din16_49);
    assign dout8_50 = sat8_shift7(din16_50);
    assign dout8_51 = sat8_shift7(din16_51);
    assign dout8_52 = sat8_shift7(din16_52);
    assign dout8_53 = sat8_shift7(din16_53);
    assign dout8_54 = sat8_shift7(din16_54);
    assign dout8_55 = sat8_shift7(din16_55);
    assign dout8_56 = sat8_shift7(din16_56);
    assign dout8_57 = sat8_shift7(din16_57);
    assign dout8_58 = sat8_shift7(din16_58);
    assign dout8_59 = sat8_shift7(din16_59);
    assign dout8_60 = sat8_shift7(din16_60);
    assign dout8_61 = sat8_shift7(din16_61);
    assign dout8_62 = sat8_shift7(din16_62);
    assign dout8_63 = sat8_shift7(din16_63);

endmodule
