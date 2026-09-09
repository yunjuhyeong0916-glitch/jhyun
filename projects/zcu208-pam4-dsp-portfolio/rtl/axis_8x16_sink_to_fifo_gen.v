`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: RFDC AXIS Sink/FIFO Adapter
// Module Name: rfdc_axis_8x16_sink_to_fifo_gen
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Captures 8x16-bit RFDC AXIS samples into a FIFO-generator compatible write interface.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module rfdc_axis_8x16_sink_to_fifo_gen (
    input               aclk,
    input               aresetn,

    // AXI4-Stream Slave (입력)
    input  wire [127:0] s_axis_tdata,
    input  wire         s_axis_tvalid,
    output wire         s_axis_tready,

    // FIFO Generator data only (출력)
    output reg  [127:0] fifo_din
);

    // 항상 받을 준비 (backpressure 없음)
    assign s_axis_tready = 1'b1;

    always @(posedge aclk) begin
        if (!aresetn) begin
            fifo_din <= 128'd0;
        end else begin
            // valid 들어오면 데이터 갱신
            if (s_axis_tvalid)
                fifo_din <= s_axis_tdata;
        end
    end

endmodule
