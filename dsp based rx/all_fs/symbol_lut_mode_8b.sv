`timescale 1ns/1ps

module symbol_lut_mode_8b #(
    parameter logic signed [7:0] NRZ_NEG = -8'sd127,
    parameter logic signed [7:0] NRZ_POS =  8'sd127,

    parameter logic signed [7:0] PAM4_L0 = -8'sd96,
    parameter logic signed [7:0] PAM4_L1 = -8'sd32,
    parameter logic signed [7:0] PAM4_L2 =  8'sd32,
    parameter logic signed [7:0] PAM4_L3 =  8'sd96,

    parameter logic signed [7:0] PAM8_L0 = -8'sd112,
    parameter logic signed [7:0] PAM8_L1 = -8'sd80,
    parameter logic signed [7:0] PAM8_L2 = -8'sd48,
    parameter logic signed [7:0] PAM8_L3 = -8'sd16,
    parameter logic signed [7:0] PAM8_L4 =  8'sd16,
    parameter logic signed [7:0] PAM8_L5 =  8'sd48,
    parameter logic signed [7:0] PAM8_L6 =  8'sd80,
    parameter logic signed [7:0] PAM8_L7 =  8'sd112
)(
    input  logic [1:0]        mode,
    input  logic [2:0]        sym_idx,
    output logic signed [7:0] sym_amp
);

    always_comb begin
        sym_amp = 8'sd0;

        unique case (mode)
            2'b00: begin
                sym_amp = sym_idx[0] ? NRZ_POS : NRZ_NEG;
            end

            2'b01: begin
                unique case (sym_idx[1:0])
                    2'd0: sym_amp = PAM4_L0;
                    2'd1: sym_amp = PAM4_L1;
                    2'd2: sym_amp = PAM4_L2;
                    2'd3: sym_amp = PAM4_L3;
                    default: sym_amp = PAM4_L0;
                endcase
            end

            2'b10: begin
                unique case (sym_idx)
                    3'd0: sym_amp = PAM8_L0;
                    3'd1: sym_amp = PAM8_L1;
                    3'd2: sym_amp = PAM8_L2;
                    3'd3: sym_amp = PAM8_L3;
                    3'd4: sym_amp = PAM8_L4;
                    3'd5: sym_amp = PAM8_L5;
                    3'd6: sym_amp = PAM8_L6;
                    3'd7: sym_amp = PAM8_L7;
                    default: sym_amp = PAM8_L0;
                endcase
            end

            default: begin
                sym_amp = 8'sd0;
            end
        endcase
    end

endmodule
