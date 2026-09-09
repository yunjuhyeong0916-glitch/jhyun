`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: RFDC AXIS Source Adapter
// Module Name: rfdc_axis_8x16_src
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Packs FIFO-generator read data into an 8x16-bit RFDC AXIS source stream.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module rfdc_axis_8x16_src (
    input               aclk,
    input               aresetn,

    // 8 samples per cycle packed into 128-bit
    // [15:0]=sample0, [31:16]=sample1, ... [127:112]=sample7
    input  wire [127:0]  samp128,

    // AXI4-Stream Master
    output reg  [127:0]  m_axis_tdata,
    output reg           m_axis_tvalid,
    input  wire          m_axis_tready
);

    always @(posedge aclk) begin
        if (!aresetn) begin
            m_axis_tdata  <= 128'd0;
            m_axis_tvalid <= 1'b0;
        end else begin
            // Always streaming (hold tvalid high once started)
            if (m_axis_tready || !m_axis_tvalid) begin
                m_axis_tdata  <= samp128;
                m_axis_tvalid <= 1'b1;
            end
        end
    end

endmodule
