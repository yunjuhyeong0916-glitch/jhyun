`timescale 1ns/1ps

// PAM4-only 64-lane 8b slicer retained for legacy compatibility.
//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 Data Formatting and Demapping
// Module Name: RX_GRAY_DEMAP_64LANE_8B_PAM4_CFG
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Demaps 64 lanes of signed 8-bit PAM4 samples into Gray-coded bit lanes using configurable thresholds.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module RX_GRAY_DEMAP_64LANE_8B_PAM4_CFG (
    input  logic signed [7:0] cfg_thr4_0,
    input  logic signed [7:0] cfg_thr4_1,
    input  logic signed [7:0] cfg_thr4_2,
    input  logic [511:0]      rx_din_flat,

    output logic [127:0]      bits128
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

    int i;
    logic signed [7:0] x;
    logic [1:0] g4;

    always_comb begin
        bits128 = '0;

        for (i = 0; i < 64; i++) begin
            x  = lane_x(i);
            g4 = pam4_gray_from_x(x, cfg_thr4_0, cfg_thr4_1, cfg_thr4_2);

            bits128[2*i + 0] = g4[0];
            bits128[2*i + 1] = g4[1];
        end
    end

endmodule

// PAM4-only 32-lane 8b slicer used by the active 32-symbol PRBS checker.
//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 Data Formatting and Demapping
// Module Name: RX_GRAY_DEMAP_32LANE_8B_PAM4_CFG
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Demaps 32 lanes of signed 8-bit PAM4 samples into Gray-coded bit lanes using configurable thresholds.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module RX_GRAY_DEMAP_32LANE_8B_PAM4_CFG (
    input  logic signed [7:0] cfg_thr4_0,
    input  logic signed [7:0] cfg_thr4_1,
    input  logic signed [7:0] cfg_thr4_2,
    input  logic [255:0]      rx_din_flat,

    output logic [63:0]       bits64
);

    function automatic logic signed [7:0] lane_x(input int idx);
        logic [255:0] sh;
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

    int i;
    logic signed [7:0] x;
    logic [1:0] g4;

    always_comb begin
        bits64 = '0;

        for (i = 0; i < 32; i++) begin
            x  = lane_x(i);
            g4 = pam4_gray_from_x(x, cfg_thr4_0, cfg_thr4_1, cfg_thr4_2);

            bits64[2*i + 0] = g4[0];
            bits64[2*i + 1] = g4[1];
        end
    end

endmodule

// Compatibility shell for older test/debug tops. Only thr4 is configurable now:
// bits64 uses cfg_thr4_1 as a middle-threshold fallback, bits128 is PAM4, and
// bits192 is tied to zero.
//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 Data Formatting and Demapping
// Module Name: RX_GRAY_DEMAP_64LANE_8B_CFG
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Demaps 64 lanes of signed 8-bit NRZ/PAM4 samples into binary bit lanes using configurable thresholds.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module RX_GRAY_DEMAP_64LANE_8B_CFG (
    input  logic signed [7:0] cfg_thr4_0,
    input  logic signed [7:0] cfg_thr4_1,
    input  logic signed [7:0] cfg_thr4_2,
    input  logic [511:0]      rx_din_flat,

    output logic [63:0]       bits64,
    output logic [127:0]      bits128,
    output logic [191:0]      bits192
);

    function automatic logic signed [7:0] legacy_lane_x(input int idx);
        logic [511:0] sh;
        begin
            sh            = rx_din_flat >> (idx*8);
            legacy_lane_x = sh[7:0];
        end
    endfunction

    logic [127:0] bits128_pam4;

    RX_GRAY_DEMAP_64LANE_8B_PAM4_CFG u_pam4 (
        .cfg_thr4_0  (cfg_thr4_0),
        .cfg_thr4_1  (cfg_thr4_1),
        .cfg_thr4_2  (cfg_thr4_2),
        .rx_din_flat (rx_din_flat),
        .bits128     (bits128_pam4)
    );

    int j;
    logic signed [7:0] x;

    always_comb begin
        bits64  = '0;
        bits128 = bits128_pam4;
        bits192 = '0;

        for (j = 0; j < 64; j++) begin
            x = legacy_lane_x(j);

            bits64[j] = (x >= cfg_thr4_1);
        end
    end

endmodule
