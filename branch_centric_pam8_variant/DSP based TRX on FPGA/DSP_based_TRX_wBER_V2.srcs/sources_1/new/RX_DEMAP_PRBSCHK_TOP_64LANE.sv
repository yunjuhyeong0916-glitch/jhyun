`timescale 1ns/1ps
// ============================================================================
// RX_DEMAP_PRBSCHK_TOP_64LANE
// - Includes:
//      RX_GRAY_DEMAP_64LANE_8B_CFG
//      RX_PRBSCHK_LOCK_BER_TXMATCH_SUM
// - TX bit ordering confirmed matched
// ============================================================================

module RX_DEMAP_PRBSCHK_TOP_64LANE #(
    parameter int TOTCNT_W = 48,
    parameter int ERRCNT_W = 48
)(
    input  logic        clk,
    input  logic        rstn,

    input  logic [1:0]  mode,
    input  logic [1:0]  sel_prbs,

    input  logic [511:0] rx_din_flat,

    output logic        locked,
    output logic        lock_pulse,
    output logic [TOTCNT_W-1:0] total_bits,
    output logic [ERRCNT_W-1:0] error_bits,

    // Debug
    output logic [191:0] prbs_aligned,
    output logic [191:0] prbs_valid_mask,
    output logic [8:0]   prbs_valid_bits
);

    logic [63:0]  bits64;
    logic [127:0] bits128;
    logic [191:0] bits192;

    // ---------------------------
    // DEMAP
    // ---------------------------
    RX_GRAY_DEMAP_64LANE_8B_CFG u_demap (
        .mode        (mode),
        .rx_din_flat (rx_din_flat),
        .bits64      (bits64),
        .bits128     (bits128),
        .bits192     (bits192)
    );

    // ---------------------------
    // PRBS CHECKER
    // ---------------------------
    RX_PRBSCHK_LOCK_BER_TXMATCH_SUM_V2 #(
        .TOTCNT_W (TOTCNT_W),
        .ERRCNT_W (ERRCNT_W)
    ) u_chk (
        .clk            (clk),
        .rstn           (rstn),
        .mode           (mode),
        .sel_prbs       (sel_prbs),

        .rx_bits64      (bits64),
        .rx_bits128     (bits128),
        .rx_bits192     (bits192),

        .locked         (locked),
        .lock_pulse     (lock_pulse),
        .total_bits     (total_bits),
        .error_bits     (error_bits),

        .prbs_aligned    (prbs_aligned),
        .prbs_valid_mask (prbs_valid_mask),
        .prbs_valid_bits (prbs_valid_bits)
    );

endmodule