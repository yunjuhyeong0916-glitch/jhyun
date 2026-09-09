`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 Data Formatting and Demapping
// Module Name: NRZ_to_8b
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Maps NRZ input bits into signed 8-bit output levels.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module NRZ_to_8b (
    input  logic              din,
    output logic signed [7:0]  dout
);

    always_comb begin
        if (din)
            dout =  8'sd127;
        else
            dout = -8'sd127;
    end

endmodule
