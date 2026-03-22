`timescale 1ns/1ps

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
