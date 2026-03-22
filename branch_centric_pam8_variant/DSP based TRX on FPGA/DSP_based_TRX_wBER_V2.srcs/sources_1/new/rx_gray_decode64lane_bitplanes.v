`timescale 1ns/1ps
// ============================================================================
// rx_gray_decode64lane_bitplanes
// - Input : 64lane signed 8b (rx8_0..rx8_63)
// - Output: rx_bits0/1/2 (bit-planes matching TX PRBS64 streams)
// - mode: 00=NRZ, 01=PAM4, 10=PAM8
//
// Uses mid-point thresholds derived from your TX mapping:
// PAM4 levels: -127, -43, +43, +127  => thresholds -85, 0, +85
// PAM8 levels: -126, -90, -54, -18, +18, +54, +90, +126
//            => thresholds -108, -72, -36, 0, +36, +72, +108
//
// Produces Gray bits exactly matching TX input bits:
// PAM4 Gray mapping: 00,01,11,10
// PAM8 Gray mapping: 000,001,011,010,110,111,101,100
// ============================================================================
module rx_gray_decode64lane_bitplanes (
    input  wire         aclk,
    input  wire         aresetn,
    input  wire [1:0]   mode,

    input  wire signed [7:0] rx8_0,
    input  wire signed [7:0] rx8_1,
    input  wire signed [7:0] rx8_2,
    input  wire signed [7:0] rx8_3,
    input  wire signed [7:0] rx8_4,
    input  wire signed [7:0] rx8_5,
    input  wire signed [7:0] rx8_6,
    input  wire signed [7:0] rx8_7,
    input  wire signed [7:0] rx8_8,
    input  wire signed [7:0] rx8_9,
    input  wire signed [7:0] rx8_10,
    input  wire signed [7:0] rx8_11,
    input  wire signed [7:0] rx8_12,
    input  wire signed [7:0] rx8_13,
    input  wire signed [7:0] rx8_14,
    input  wire signed [7:0] rx8_15,
    input  wire signed [7:0] rx8_16,
    input  wire signed [7:0] rx8_17,
    input  wire signed [7:0] rx8_18,
    input  wire signed [7:0] rx8_19,
    input  wire signed [7:0] rx8_20,
    input  wire signed [7:0] rx8_21,
    input  wire signed [7:0] rx8_22,
    input  wire signed [7:0] rx8_23,
    input  wire signed [7:0] rx8_24,
    input  wire signed [7:0] rx8_25,
    input  wire signed [7:0] rx8_26,
    input  wire signed [7:0] rx8_27,
    input  wire signed [7:0] rx8_28,
    input  wire signed [7:0] rx8_29,
    input  wire signed [7:0] rx8_30,
    input  wire signed [7:0] rx8_31,
    input  wire signed [7:0] rx8_32,
    input  wire signed [7:0] rx8_33,
    input  wire signed [7:0] rx8_34,
    input  wire signed [7:0] rx8_35,
    input  wire signed [7:0] rx8_36,
    input  wire signed [7:0] rx8_37,
    input  wire signed [7:0] rx8_38,
    input  wire signed [7:0] rx8_39,
    input  wire signed [7:0] rx8_40,
    input  wire signed [7:0] rx8_41,
    input  wire signed [7:0] rx8_42,
    input  wire signed [7:0] rx8_43,
    input  wire signed [7:0] rx8_44,
    input  wire signed [7:0] rx8_45,
    input  wire signed [7:0] rx8_46,
    input  wire signed [7:0] rx8_47,
    input  wire signed [7:0] rx8_48,
    input  wire signed [7:0] rx8_49,
    input  wire signed [7:0] rx8_50,
    input  wire signed [7:0] rx8_51,
    input  wire signed [7:0] rx8_52,
    input  wire signed [7:0] rx8_53,
    input  wire signed [7:0] rx8_54,
    input  wire signed [7:0] rx8_55,
    input  wire signed [7:0] rx8_56,
    input  wire signed [7:0] rx8_57,
    input  wire signed [7:0] rx8_58,
    input  wire signed [7:0] rx8_59,
    input  wire signed [7:0] rx8_60,
    input  wire signed [7:0] rx8_61,
    input  wire signed [7:0] rx8_62,
    input  wire signed [7:0] rx8_63,

    output reg  [63:0]  rx_bits0,
    output reg  [63:0]  rx_bits1,
    output reg  [63:0]  rx_bits2
);

    // thresholds (fixed)
    localparam signed [7:0] P4_T0 = -8'sd85;
    localparam signed [7:0] P4_T1 =  8'sd0;
    localparam signed [7:0] P4_T2 =  8'sd85;

    localparam signed [7:0] P8_T0 = -8'sd108;
    localparam signed [7:0] P8_T1 = -8'sd72;
    localparam signed [7:0] P8_T2 = -8'sd36;
    localparam signed [7:0] P8_T3 =  8'sd0;
    localparam signed [7:0] P8_T4 =  8'sd36;
    localparam signed [7:0] P8_T5 =  8'sd72;
    localparam signed [7:0] P8_T6 =  8'sd108;

    function [0:0] nrz_bit;
        input signed [7:0] x;
        begin
            nrz_bit = (x >= 0);
        end
    endfunction

    function [1:0] pam4_gray;
        input signed [7:0] x;
        begin
            if      (x < P4_T0) pam4_gray = 2'b00; // -127
            else if (x < P4_T1) pam4_gray = 2'b01; // -43
            else if (x < P4_T2) pam4_gray = 2'b11; // +43
            else                pam4_gray = 2'b10; // +127
        end
    endfunction

    function [2:0] pam8_gray;
        input signed [7:0] x;
        begin
            if      (x < P8_T0) pam8_gray = 3'b000; // -126
            else if (x < P8_T1) pam8_gray = 3'b001; // -90
            else if (x < P8_T2) pam8_gray = 3'b011; // -54
            else if (x < P8_T3) pam8_gray = 3'b010; // -18
            else if (x < P8_T4) pam8_gray = 3'b110; // +18
            else if (x < P8_T5) pam8_gray = 3'b111; // +54
            else if (x < P8_T6) pam8_gray = 3'b101; // +90
            else                pam8_gray = 3'b100; // +126
        end
    endfunction

    task do_lane;
        input integer idx;
        input signed [7:0] x;
        reg [2:0] g8;
        reg [1:0] g4;
        reg       b1;
        begin
            case (mode)
                2'b00: begin // NRZ
                    b1 = nrz_bit(x);
                    rx_bits0[idx] <= b1;
                    rx_bits1[idx] <= 1'b0;
                    rx_bits2[idx] <= 1'b0;
                end
                2'b01: begin // PAM4
                    g4 = pam4_gray(x);
                    rx_bits0[idx] <= g4[0];
                    rx_bits1[idx] <= g4[1];
                    rx_bits2[idx] <= 1'b0;
                end
                2'b10: begin // PAM8
                    g8 = pam8_gray(x);
                    rx_bits0[idx] <= g8[0];
                    rx_bits1[idx] <= g8[1];
                    rx_bits2[idx] <= g8[2];
                end
                default: begin
                    rx_bits0[idx] <= 1'b0;
                    rx_bits1[idx] <= 1'b0;
                    rx_bits2[idx] <= 1'b0;
                end
            endcase
        end
    endtask

    always @(posedge aclk) begin
        if (!aresetn) begin
            rx_bits0 <= 64'd0;
            rx_bits1 <= 64'd0;
            rx_bits2 <= 64'd0;
        end else begin
            do_lane(0,  rx8_0);  do_lane(1,  rx8_1);  do_lane(2,  rx8_2);  do_lane(3,  rx8_3);
            do_lane(4,  rx8_4);  do_lane(5,  rx8_5);  do_lane(6,  rx8_6);  do_lane(7,  rx8_7);
            do_lane(8,  rx8_8);  do_lane(9,  rx8_9);  do_lane(10, rx8_10); do_lane(11, rx8_11);
            do_lane(12, rx8_12); do_lane(13, rx8_13); do_lane(14, rx8_14); do_lane(15, rx8_15);
            do_lane(16, rx8_16); do_lane(17, rx8_17); do_lane(18, rx8_18); do_lane(19, rx8_19);
            do_lane(20, rx8_20); do_lane(21, rx8_21); do_lane(22, rx8_22); do_lane(23, rx8_23);
            do_lane(24, rx8_24); do_lane(25, rx8_25); do_lane(26, rx8_26); do_lane(27, rx8_27);
            do_lane(28, rx8_28); do_lane(29, rx8_29); do_lane(30, rx8_30); do_lane(31, rx8_31);
            do_lane(32, rx8_32); do_lane(33, rx8_33); do_lane(34, rx8_34); do_lane(35, rx8_35);
            do_lane(36, rx8_36); do_lane(37, rx8_37); do_lane(38, rx8_38); do_lane(39, rx8_39);
            do_lane(40, rx8_40); do_lane(41, rx8_41); do_lane(42, rx8_42); do_lane(43, rx8_43);
            do_lane(44, rx8_44); do_lane(45, rx8_45); do_lane(46, rx8_46); do_lane(47, rx8_47);
            do_lane(48, rx8_48); do_lane(49, rx8_49); do_lane(50, rx8_50); do_lane(51, rx8_51);
            do_lane(52, rx8_52); do_lane(53, rx8_53); do_lane(54, rx8_54); do_lane(55, rx8_55);
            do_lane(56, rx8_56); do_lane(57, rx8_57); do_lane(58, rx8_58); do_lane(59, rx8_59);
            do_lane(60, rx8_60); do_lane(61, rx8_61); do_lane(62, rx8_62); do_lane(63, rx8_63);
        end
    end

endmodule