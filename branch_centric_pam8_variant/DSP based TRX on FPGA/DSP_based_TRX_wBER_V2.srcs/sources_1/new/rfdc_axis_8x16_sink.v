`timescale 1ns/1ps
// ============================================================================
// rfdc_axis_8x16_sink
// - AXI4-Stream 128b input (from RFDC ADC)
// - Outputs native 128b + wr_en for FIFO Generator
// ============================================================================

module rfdc_axis_8x16_sink (
    input  wire         aclk,
    input  wire         aresetn,

    // AXI4-Stream Slave
    input  wire [127:0] s_axis_tdata,
    input  wire         s_axis_tvalid,
    output wire         s_axis_tready,

    // Native FIFO write interface
    output reg  [127:0] fifo_din,
    output reg          fifo_wr_en
);

    // Always ready (FIFO backpressure는 FIFO full로 제어)
    assign s_axis_tready = 1'b1;

    always @(posedge aclk) begin
        if (!aresetn) begin
            fifo_din   <= 128'd0;
            fifo_wr_en <= 1'b0;
        end else begin
            // handshake = one valid sample
            fifo_wr_en <= s_axis_tvalid & s_axis_tready;

            if (s_axis_tvalid & s_axis_tready)
                fifo_din <= s_axis_tdata;
        end
    end

endmodule