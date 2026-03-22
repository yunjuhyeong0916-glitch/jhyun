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
    input  logic signed [7:0] cfg_thr_nrz,
    input  logic signed [7:0] cfg_thr4_0,
    input  logic signed [7:0] cfg_thr4_1,
    input  logic signed [7:0] cfg_thr4_2,
    input  logic signed [7:0] cfg_thr8_0,
    input  logic signed [7:0] cfg_thr8_1,
    input  logic signed [7:0] cfg_thr8_2,
    input  logic signed [7:0] cfg_thr8_3,
    input  logic signed [7:0] cfg_thr8_4,
    input  logic signed [7:0] cfg_thr8_5,
    input  logic signed [7:0] cfg_thr8_6,
    input  logic              cfg_thr_en,
    input  logic [1:0]        mode,
    input  logic [511:0]      rx_din_flat,

    output logic [63:0]       bits64,
    output logic [127:0]      bits128,
    output logic [191:0]      bits192
);

    function automatic logic signed [7:0] lane_x(input int idx);
        logic [511:0] sh;
        begin
            sh     = rx_din_flat >> (idx*8);
            lane_x = sh[7:0];
        end
    endfunction

    function automatic logic [1:0] pam4_gray_from_x(
        input logic signed [7:0] x,
        input logic signed [7:0] t0,
        input logic signed [7:0] t1,
        input logic signed [7:0] t2
    );
        begin
            if      (x < t0) pam4_gray_from_x = 2'b00;
            else if (x < t1) pam4_gray_from_x = 2'b01;
            else if (x < t2) pam4_gray_from_x = 2'b11;
            else             pam4_gray_from_x = 2'b10;
        end
    endfunction

    function automatic logic [2:0] pam8_gray_from_x(
        input logic signed [7:0] x,
        input logic signed [7:0] t0,
        input logic signed [7:0] t1,
        input logic signed [7:0] t2,
        input logic signed [7:0] t3,
        input logic signed [7:0] t4,
        input logic signed [7:0] t5,
        input logic signed [7:0] t6
    );
        begin
            if      (x < t0) pam8_gray_from_x = 3'b000;
            else if (x < t1) pam8_gray_from_x = 3'b001;
            else if (x < t2) pam8_gray_from_x = 3'b011;
            else if (x < t3) pam8_gray_from_x = 3'b010;
            else if (x < t4) pam8_gray_from_x = 3'b110;
            else if (x < t5) pam8_gray_from_x = 3'b111;
            else if (x < t6) pam8_gray_from_x = 3'b101;
            else             pam8_gray_from_x = 3'b100;
        end
    endfunction

    int i;
    logic signed [7:0] x;
    logic [1:0] g4;
    logic [2:0] g8;
    logic signed [7:0] thr_nrz_use;
    logic signed [7:0] thr4_0_use;
    logic signed [7:0] thr4_1_use;
    logic signed [7:0] thr4_2_use;
    logic signed [7:0] thr8_0_use;
    logic signed [7:0] thr8_1_use;
    logic signed [7:0] thr8_2_use;
    logic signed [7:0] thr8_3_use;
    logic signed [7:0] thr8_4_use;
    logic signed [7:0] thr8_5_use;
    logic signed [7:0] thr8_6_use;

    always_comb begin
        if (cfg_thr_en) begin
            thr_nrz_use = cfg_thr_nrz;
            thr4_0_use  = cfg_thr4_0;
            thr4_1_use  = cfg_thr4_1;
            thr4_2_use  = cfg_thr4_2;
            thr8_0_use  = cfg_thr8_0;
            thr8_1_use  = cfg_thr8_1;
            thr8_2_use  = cfg_thr8_2;
            thr8_3_use  = cfg_thr8_3;
            thr8_4_use  = cfg_thr8_4;
            thr8_5_use  = cfg_thr8_5;
            thr8_6_use  = cfg_thr8_6;
        end else begin
            thr_nrz_use = THR_NRZ;
            thr4_0_use  = THR4_0;
            thr4_1_use  = THR4_1;
            thr4_2_use  = THR4_2;
            thr8_0_use  = THR8_0;
            thr8_1_use  = THR8_1;
            thr8_2_use  = THR8_2;
            thr8_3_use  = THR8_3;
            thr8_4_use  = THR8_4;
            thr8_5_use  = THR8_5;
            thr8_6_use  = THR8_6;
        end

        bits64  = '0;
        bits128 = '0;
        bits192 = '0;

        for (i = 0; i < 64; i++) begin
            x = lane_x(i);

            // NRZ
            bits64[i] = (x >= thr_nrz_use);

            // PAM4 (LSB first)
            g4 = pam4_gray_from_x(x, thr4_0_use, thr4_1_use, thr4_2_use);
            bits128[2*i + 0] = g4[0];
            bits128[2*i + 1] = g4[1];

            // PAM8 (LSB first)
            g8 = pam8_gray_from_x(
                x,
                thr8_0_use, thr8_1_use, thr8_2_use, thr8_3_use,
                thr8_4_use, thr8_5_use, thr8_6_use
            );
            bits192[3*i + 0] = g8[0];
            bits192[3*i + 1] = g8[1];
            bits192[3*i + 2] = g8[2];
        end
    end

endmodule
