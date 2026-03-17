`timescale 1ns/1ps

module RX_PRBSCHK_MULTI_TOP_64LANE_BER_AUTO_WRAPPER #(
    parameter integer BITCNT_W = 48,
    parameter integer ERRCNT_W = 48
)(
    input               rstb,
    input               i_clk,

    input      [1:0]    sel_prbs,
    input      [1:0]    mode,
    input signed [7:0]  cfg_thr_nrz,
    input signed [7:0]  cfg_thr4_0,
    input signed [7:0]  cfg_thr4_1,
    input signed [7:0]  cfg_thr4_2,
    input signed [7:0]  cfg_thr8_0,
    input signed [7:0]  cfg_thr8_1,
    input signed [7:0]  cfg_thr8_2,
    input signed [7:0]  cfg_thr8_3,
    input signed [7:0]  cfg_thr8_4,
    input signed [7:0]  cfg_thr8_5,
    input signed [7:0]  cfg_thr8_6,
    input               cfg_thr_en,

    input      [511:0]  rx_din_flat,

    output              lock,

    // ALL OBSERVED BITS (includes pre-lock)
    output     [BITCNT_W-1:0] bit_cnt_seen_total,

    // TOTAL (accumulated across all lock sections)
    output     [BITCNT_W-1:0] bit_cnt_total,
    output     [ERRCNT_W-1:0] err_cnt_total,

    // STREAK (current lock section)
    output     [BITCNT_W-1:0] bit_cnt_streak,
    output     [ERRCNT_W-1:0] err_cnt_streak,

    output     [8:0]    err_popcnt,
    output     [7:0]    best_slip,

    // RAW
    output     [63:0]   rx_bits64_raw,
    output     [127:0]  rx_bits128_raw,
    output     [191:0]  rx_bits192_raw,

    // Expected PRBS
    output     [63:0]   exp64,
    output     [127:0]  exp128,
    output     [191:0]  exp192,

    // DEBUG split by mode
    output     [63:0]   rxW_aligned64_dbg,
    output     [127:0]  rxW_aligned128_dbg,
    output     [191:0]  rxW_aligned192_dbg,

    output     [63:0]   expW_raw64_dbg,
    output     [127:0]  expW_raw128_dbg,
    output     [191:0]  expW_raw192_dbg
);

    RX_PRBSCHK_MULTI_TOP_64LANE_BER_AUTO #(
        .BITCNT_W (BITCNT_W),
        .ERRCNT_W (ERRCNT_W)
    ) u_core (
        .rstb               (rstb),
        .i_clk              (i_clk),
        .sel_prbs           (sel_prbs),
        .mode               (mode),
        .cfg_thr_nrz        (cfg_thr_nrz),
        .cfg_thr4_0         (cfg_thr4_0),
        .cfg_thr4_1         (cfg_thr4_1),
        .cfg_thr4_2         (cfg_thr4_2),
        .cfg_thr8_0         (cfg_thr8_0),
        .cfg_thr8_1         (cfg_thr8_1),
        .cfg_thr8_2         (cfg_thr8_2),
        .cfg_thr8_3         (cfg_thr8_3),
        .cfg_thr8_4         (cfg_thr8_4),
        .cfg_thr8_5         (cfg_thr8_5),
        .cfg_thr8_6         (cfg_thr8_6),
        .cfg_thr_en         (cfg_thr_en),
        .rx_din_flat        (rx_din_flat),

        .lock               (lock),

        .bit_cnt_seen_total (bit_cnt_seen_total),

        // STREAK (core: bit_cnt/err_cnt)
        .bit_cnt            (bit_cnt_streak),
        .err_cnt            (err_cnt_streak),

        // TOTAL
        .bit_cnt_total      (bit_cnt_total),
        .err_cnt_total      (err_cnt_total),

        .err_popcnt         (err_popcnt),
        .best_slip          (best_slip),

        .rx_bits64_raw      (rx_bits64_raw),
        .rx_bits128_raw     (rx_bits128_raw),
        .rx_bits192_raw     (rx_bits192_raw),

        .exp64              (exp64),
        .exp128             (exp128),
        .exp192             (exp192),

        .rxW_aligned64_dbg  (rxW_aligned64_dbg),
        .rxW_aligned128_dbg (rxW_aligned128_dbg),
        .rxW_aligned192_dbg (rxW_aligned192_dbg),

        .expW_raw64_dbg     (expW_raw64_dbg),
        .expW_raw128_dbg    (expW_raw128_dbg),
        .expW_raw192_dbg    (expW_raw192_dbg)
    );

endmodule
