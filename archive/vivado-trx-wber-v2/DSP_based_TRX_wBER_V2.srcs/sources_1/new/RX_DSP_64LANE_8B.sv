`timescale 1ns/1ps
// ============================================================================
// RX_DSP_64LANE_8B
// - Placeholder / passthrough version (synth/BD friendly)
// - 64 lanes, 8-bit signed
// - 1-cycle register (optional). You can replace with real DSP later.
// ============================================================================

module RX_DSP_64LANE_8B (
    input  wire          aclk,
    input  wire          aresetn,

    input  wire signed [7:0] din_0,  input  wire signed [7:0] din_1,
    input  wire signed [7:0] din_2,  input  wire signed [7:0] din_3,
    input  wire signed [7:0] din_4,  input  wire signed [7:0] din_5,
    input  wire signed [7:0] din_6,  input  wire signed [7:0] din_7,
    input  wire signed [7:0] din_8,  input  wire signed [7:0] din_9,
    input  wire signed [7:0] din_10, input  wire signed [7:0] din_11,
    input  wire signed [7:0] din_12, input  wire signed [7:0] din_13,
    input  wire signed [7:0] din_14, input  wire signed [7:0] din_15,
    input  wire signed [7:0] din_16, input  wire signed [7:0] din_17,
    input  wire signed [7:0] din_18, input  wire signed [7:0] din_19,
    input  wire signed [7:0] din_20, input  wire signed [7:0] din_21,
    input  wire signed [7:0] din_22, input  wire signed [7:0] din_23,
    input  wire signed [7:0] din_24, input  wire signed [7:0] din_25,
    input  wire signed [7:0] din_26, input  wire signed [7:0] din_27,
    input  wire signed [7:0] din_28, input  wire signed [7:0] din_29,
    input  wire signed [7:0] din_30, input  wire signed [7:0] din_31,
    input  wire signed [7:0] din_32, input  wire signed [7:0] din_33,
    input  wire signed [7:0] din_34, input  wire signed [7:0] din_35,
    input  wire signed [7:0] din_36, input  wire signed [7:0] din_37,
    input  wire signed [7:0] din_38, input  wire signed [7:0] din_39,
    input  wire signed [7:0] din_40, input  wire signed [7:0] din_41,
    input  wire signed [7:0] din_42, input  wire signed [7:0] din_43,
    input  wire signed [7:0] din_44, input  wire signed [7:0] din_45,
    input  wire signed [7:0] din_46, input  wire signed [7:0] din_47,
    input  wire signed [7:0] din_48, input  wire signed [7:0] din_49,
    input  wire signed [7:0] din_50, input  wire signed [7:0] din_51,
    input  wire signed [7:0] din_52, input  wire signed [7:0] din_53,
    input  wire signed [7:0] din_54, input  wire signed [7:0] din_55,
    input  wire signed [7:0] din_56, input  wire signed [7:0] din_57,
    input  wire signed [7:0] din_58, input  wire signed [7:0] din_59,
    input  wire signed [7:0] din_60, input  wire signed [7:0] din_61,
    input  wire signed [7:0] din_62, input  wire signed [7:0] din_63,

    output reg  signed [7:0] dout_0,  output reg  signed [7:0] dout_1,
    output reg  signed [7:0] dout_2,  output reg  signed [7:0] dout_3,
    output reg  signed [7:0] dout_4,  output reg  signed [7:0] dout_5,
    output reg  signed [7:0] dout_6,  output reg  signed [7:0] dout_7,
    output reg  signed [7:0] dout_8,  output reg  signed [7:0] dout_9,
    output reg  signed [7:0] dout_10, output reg  signed [7:0] dout_11,
    output reg  signed [7:0] dout_12, output reg  signed [7:0] dout_13,
    output reg  signed [7:0] dout_14, output reg  signed [7:0] dout_15,
    output reg  signed [7:0] dout_16, output reg  signed [7:0] dout_17,
    output reg  signed [7:0] dout_18, output reg  signed [7:0] dout_19,
    output reg  signed [7:0] dout_20, output reg  signed [7:0] dout_21,
    output reg  signed [7:0] dout_22, output reg  signed [7:0] dout_23,
    output reg  signed [7:0] dout_24, output reg  signed [7:0] dout_25,
    output reg  signed [7:0] dout_26, output reg  signed [7:0] dout_27,
    output reg  signed [7:0] dout_28, output reg  signed [7:0] dout_29,
    output reg  signed [7:0] dout_30, output reg  signed [7:0] dout_31,
    output reg  signed [7:0] dout_32, output reg  signed [7:0] dout_33,
    output reg  signed [7:0] dout_34, output reg  signed [7:0] dout_35,
    output reg  signed [7:0] dout_36, output reg  signed [7:0] dout_37,
    output reg  signed [7:0] dout_38, output reg  signed [7:0] dout_39,
    output reg  signed [7:0] dout_40, output reg  signed [7:0] dout_41,
    output reg  signed [7:0] dout_42, output reg  signed [7:0] dout_43,
    output reg  signed [7:0] dout_44, output reg  signed [7:0] dout_45,
    output reg  signed [7:0] dout_46, output reg  signed [7:0] dout_47,
    output reg  signed [7:0] dout_48, output reg  signed [7:0] dout_49,
    output reg  signed [7:0] dout_50, output reg  signed [7:0] dout_51,
    output reg  signed [7:0] dout_52, output reg  signed [7:0] dout_53,
    output reg  signed [7:0] dout_54, output reg  signed [7:0] dout_55,
    output reg  signed [7:0] dout_56, output reg  signed [7:0] dout_57,
    output reg  signed [7:0] dout_58, output reg  signed [7:0] dout_59,
    output reg  signed [7:0] dout_60, output reg  signed [7:0] dout_61,
    output reg  signed [7:0] dout_62, output reg  signed [7:0] dout_63
);

    always @(posedge aclk) begin
        if (!aresetn) begin
            dout_0  <= '0;  dout_1  <= '0;  dout_2  <= '0;  dout_3  <= '0;
            dout_4  <= '0;  dout_5  <= '0;  dout_6  <= '0;  dout_7  <= '0;
            dout_8  <= '0;  dout_9  <= '0;  dout_10 <= '0;  dout_11 <= '0;
            dout_12 <= '0;  dout_13 <= '0;  dout_14 <= '0;  dout_15 <= '0;
            dout_16 <= '0;  dout_17 <= '0;  dout_18 <= '0;  dout_19 <= '0;
            dout_20 <= '0;  dout_21 <= '0;  dout_22 <= '0;  dout_23 <= '0;
            dout_24 <= '0;  dout_25 <= '0;  dout_26 <= '0;  dout_27 <= '0;
            dout_28 <= '0;  dout_29 <= '0;  dout_30 <= '0;  dout_31 <= '0;
            dout_32 <= '0;  dout_33 <= '0;  dout_34 <= '0;  dout_35 <= '0;
            dout_36 <= '0;  dout_37 <= '0;  dout_38 <= '0;  dout_39 <= '0;
            dout_40 <= '0;  dout_41 <= '0;  dout_42 <= '0;  dout_43 <= '0;
            dout_44 <= '0;  dout_45 <= '0;  dout_46 <= '0;  dout_47 <= '0;
            dout_48 <= '0;  dout_49 <= '0;  dout_50 <= '0;  dout_51 <= '0;
            dout_52 <= '0;  dout_53 <= '0;  dout_54 <= '0;  dout_55 <= '0;
            dout_56 <= '0;  dout_57 <= '0;  dout_58 <= '0;  dout_59 <= '0;
            dout_60 <= '0;  dout_61 <= '0;  dout_62 <= '0;  dout_63 <= '0;
        end else begin
            dout_0  <= din_0;   dout_1  <= din_1;   dout_2  <= din_2;   dout_3  <= din_3;
            dout_4  <= din_4;   dout_5  <= din_5;   dout_6  <= din_6;   dout_7  <= din_7;
            dout_8  <= din_8;   dout_9  <= din_9;   dout_10 <= din_10;  dout_11 <= din_11;
            dout_12 <= din_12;  dout_13 <= din_13;  dout_14 <= din_14;  dout_15 <= din_15;
            dout_16 <= din_16;  dout_17 <= din_17;  dout_18 <= din_18;  dout_19 <= din_19;
            dout_20 <= din_20;  dout_21 <= din_21;  dout_22 <= din_22;  dout_23 <= din_23;
            dout_24 <= din_24;  dout_25 <= din_25;  dout_26 <= din_26;  dout_27 <= din_27;
            dout_28 <= din_28;  dout_29 <= din_29;  dout_30 <= din_30;  dout_31 <= din_31;
            dout_32 <= din_32;  dout_33 <= din_33;  dout_34 <= din_34;  dout_35 <= din_35;
            dout_36 <= din_36;  dout_37 <= din_37;  dout_38 <= din_38;  dout_39 <= din_39;
            dout_40 <= din_40;  dout_41 <= din_41;  dout_42 <= din_42;  dout_43 <= din_43;
            dout_44 <= din_44;  dout_45 <= din_45;  dout_46 <= din_46;  dout_47 <= din_47;
            dout_48 <= din_48;  dout_49 <= din_49;  dout_50 <= din_50;  dout_51 <= din_51;
            dout_52 <= din_52;  dout_53 <= din_53;  dout_54 <= din_54;  dout_55 <= din_55;
            dout_56 <= din_56;  dout_57 <= din_57;  dout_58 <= din_58;  dout_59 <= din_59;
            dout_60 <= din_60;  dout_61 <= din_61;  dout_62 <= din_62;  dout_63 <= din_63;
        end
    end

endmodule