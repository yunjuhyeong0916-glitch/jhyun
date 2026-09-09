`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: Control and Coefficient Interface
// Module Name: gpio_hflat_unpack_sync
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Synchronizes and unpacks flattened FIR coefficient control data from GPIO.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module gpio_hflat_unpack_sync (
    input  wire        clk,
    input  wire        rstn,

    // TX AXI GPIO dual channel input
    input  wire [31:0] gpio_hflat_ch1,
    input  wire [31:0] gpio_hflat_ch2,

    // RX AXI GPIO dual channel input
    input  wire [31:0] gpio_rx_hflat_ch1,
    input  wire [31:0] gpio_rx_hflat_ch2,

    // packed 8-tap x 8-bit FIR coefficients
    output reg  [63:0] h_flat,
    output reg  [63:0] ext_ptrn_flat,
    output reg  [63:0] rx_h_flat
);

    wire [63:0] tx_coeff_flat = {gpio_hflat_ch2,    gpio_hflat_ch1};
    wire [63:0] rx_coeff_flat = {gpio_rx_hflat_ch2, gpio_rx_hflat_ch1};

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            h_flat        <= 64'h0;
            ext_ptrn_flat <= 64'h0;
            rx_h_flat     <= 64'h0;
        end else begin
            h_flat        <= tx_coeff_flat;
            ext_ptrn_flat <= tx_coeff_flat;
            rx_h_flat     <= rx_coeff_flat;
        end
    end

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: Control and Coefficient Interface
// Module Name: gpio_hflat_extptrn_unpack_sync
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Synchronizes and unpacks external-pattern control data from GPIO.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module gpio_hflat_extptrn_unpack_sync (
    input  wire        clk,
    input  wire        rstn,

    // TX AXI GPIO dual channel input
    input  wire [31:0] gpio_hflat_ch1,
    input  wire [31:0] gpio_hflat_ch2,

    // RX AXI GPIO dual channel input
    input  wire [31:0] gpio_rx_hflat_ch1,
    input  wire [31:0] gpio_rx_hflat_ch2,

    // EXT_PTRN AXI GPIO dual channel input
    input  wire [31:0] gpio_ext_ptrn_ch1,
    input  wire [31:0] gpio_ext_ptrn_ch2,

    // packed 8-tap x 8-bit FIR coefficients and external pattern
    output reg  [63:0] h_flat,
    output reg  [63:0] ext_ptrn_flat,
    output reg  [63:0] rx_h_flat
);

    wire [63:0] tx_coeff_flat = {gpio_hflat_ch2,    gpio_hflat_ch1};
    wire [63:0] rx_coeff_flat = {gpio_rx_hflat_ch2, gpio_rx_hflat_ch1};
    wire [63:0] ext_ptrn_in   = {gpio_ext_ptrn_ch2, gpio_ext_ptrn_ch1};

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            h_flat        <= 64'h0;
            ext_ptrn_flat <= 64'h0;
            rx_h_flat     <= 64'h0;
        end else begin
            h_flat        <= tx_coeff_flat;
            ext_ptrn_flat <= ext_ptrn_in;
            rx_h_flat     <= rx_coeff_flat;
        end
    end

endmodule
