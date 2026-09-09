`timescale 1ns/1ps

module gpio_hflat_unpack_sync (
    input  wire        clk,
    input  wire        rstn,

    // AXI GPIO dual channel input
    input  wire [31:0] gpio_hflat_ch1,
    input  wire [31:0] gpio_hflat_ch2,

    // packed 8-tap x 8-bit FIR coefficients
    output reg  [63:0] h_flat
);

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            h_flat <= 64'h0;
        end else begin
            h_flat <= {gpio_hflat_ch2, gpio_hflat_ch1};
        end
    end

endmodule
