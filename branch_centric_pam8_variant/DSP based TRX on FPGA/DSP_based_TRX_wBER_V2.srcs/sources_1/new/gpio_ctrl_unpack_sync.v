`timescale 1ns/1ps

module gpio_ctrl_unpack_sync (
    input  wire        clk,
    input  wire        rstn,
    input  wire [31:0] gpio_ctrl,

    output reg  [1:0]  sel_prbs,
    output reg  [1:0]  mode,
    output reg         ffe_en,
    output reg         ch_bypass
);

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            sel_prbs    <= 2'b00;
            mode        <= 2'b00;
            ffe_en      <= 1'b0;
            ch_bypass   <= 1'b0;
        end else begin
            sel_prbs    <= gpio_ctrl[1:0];
            mode        <= gpio_ctrl[3:2];
            ffe_en      <= gpio_ctrl[4];
            ch_bypass   <= gpio_ctrl[5];
        end
    end

endmodule
