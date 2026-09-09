`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 Data Formatting and Demapping
// Module Name: PAM4_2b_to_8b
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Maps 2-bit PAM4 symbols into signed 8-bit amplitude levels.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module PAM4_2b_to_8b (
    input  logic [1:0]          din,
    output logic signed [7:0]   dout
);

    always_comb begin
        case (din)
            2'b00: dout = -8'sd96;  // Level -3
            2'b01: dout = -8'sd32;  // Level -1
            2'b11: dout =  8'sd32;  // Level +1
            2'b10: dout =  8'sd96;  // Level +3
            default: dout = -8'sd96;
        endcase
    end

endmodule

