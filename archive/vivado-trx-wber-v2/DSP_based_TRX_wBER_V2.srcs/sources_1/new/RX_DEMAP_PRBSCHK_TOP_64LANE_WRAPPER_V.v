`timescale 1ns/1ps
// ============================================================================
// Verilog wrapper for BD
// ============================================================================

module RX_DEMAP_PRBSCHK_TOP_64LANE_WRAPPER_V #(
    parameter integer TOTCNT_W = 48,
    parameter integer ERRCNT_W = 48
)(
    input  wire                 clk,
    input  wire                 rstn,
    input  wire [1:0]           mode,
    input  wire [1:0]           sel_prbs,
    input  wire [511:0]         rx_din_flat,

    output wire                 locked,
    output wire                 lock_pulse,
    output wire [TOTCNT_W-1:0]  total_bits,
    output wire [ERRCNT_W-1:0]  error_bits,

    output wire [191:0]         prbs_aligned,
    output wire [191:0]         prbs_valid_mask,
    output wire [8:0]           prbs_valid_bits
);

    RX_DEMAP_PRBSCHK_TOP_64LANE #(
        .TOTCNT_W (TOTCNT_W),
        .ERRCNT_W (ERRCNT_W)
    ) u_top (
        .clk            (clk),
        .rstn           (rstn),
        .mode           (mode),
        .sel_prbs       (sel_prbs),
        .rx_din_flat    (rx_din_flat),

        .locked         (locked),
        .lock_pulse     (lock_pulse),
        .total_bits     (total_bits),
        .error_bits     (error_bits),

        .prbs_aligned    (prbs_aligned),
        .prbs_valid_mask (prbs_valid_mask),
        .prbs_valid_bits (prbs_valid_bits)
    );

endmodule