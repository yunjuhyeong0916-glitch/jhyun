`timescale 1ns/1ps

module RX_GRAY_DEMAP_64LANE_8B_CFG #(
    // =========================
    // Embedded thresholds
    // =========================
    parameter logic signed [7:0] THR_NRZ = 8'sd0,

    parameter logic signed [7:0] THR4_0  = -8'sd85,
    parameter logic signed [7:0] THR4_1  =  8'sd0,
    parameter logic signed [7:0] THR4_2  =  8'sd85,

    parameter logic signed [7:0] THR8_0  = -8'sd108,
    parameter logic signed [7:0] THR8_1  = -8'sd72,
    parameter logic signed [7:0] THR8_2  = -8'sd36,
    parameter logic signed [7:0] THR8_3  =  8'sd0,
    parameter logic signed [7:0] THR8_4  =  8'sd36,
    parameter logic signed [7:0] THR8_5  =  8'sd72,
    parameter logic signed [7:0] THR8_6  =  8'sd108
)(
    input  logic [1:0]    mode,
    input  logic [511:0]  rx_din_flat,

    output logic [63:0]   bits64,
    output logic [127:0]  bits128,
    output logic [191:0]  bits192
);

    function automatic logic [1:0] pam4_gray_from_x(input logic signed [7:0] x);
        begin
            if      (x < THR4_0) pam4_gray_from_x = 2'b00;
            else if (x < THR4_1) pam4_gray_from_x = 2'b01;
            else if (x < THR4_2) pam4_gray_from_x = 2'b11;
            else                 pam4_gray_from_x = 2'b10;
        end
    endfunction

    function automatic logic [2:0] pam8_gray_from_x(input logic signed [7:0] x);
        begin
            if      (x < THR8_0) pam8_gray_from_x = 3'b000;
            else if (x < THR8_1) pam8_gray_from_x = 3'b001;
            else if (x < THR8_2) pam8_gray_from_x = 3'b011;
            else if (x < THR8_3) pam8_gray_from_x = 3'b010;
            else if (x < THR8_4) pam8_gray_from_x = 3'b110;
            else if (x < THR8_5) pam8_gray_from_x = 3'b111;
            else if (x < THR8_6) pam8_gray_from_x = 3'b101;
            else                 pam8_gray_from_x = 3'b100;
        end
    endfunction

    int i;
    logic signed [7:0] x;
    logic [1:0] g4;
    logic [2:0] g8;

    // mode input is kept for top-level compatibility.
    logic [1:0] mode_unused;

    always_comb begin
        mode_unused = mode;

        bits64  = '0;
        bits128 = '0;
        bits192 = '0;

        for (i = 0; i < 64; i++) begin
            x = $signed(rx_din_flat[8*i +: 8]);

            // NRZ
            bits64[i] = (x >= THR_NRZ);

            // PAM4 (LSB first)
            g4 = pam4_gray_from_x(x);
            bits128[2*i + 0] = g4[0];
            bits128[2*i + 1] = g4[1];

            // PAM8 (LSB first)
            g8 = pam8_gray_from_x(x);
            bits192[3*i + 0] = g8[0];
            bits192[3*i + 1] = g8[1];
            bits192[3*i + 2] = g8[2];
        end
    end

endmodule
