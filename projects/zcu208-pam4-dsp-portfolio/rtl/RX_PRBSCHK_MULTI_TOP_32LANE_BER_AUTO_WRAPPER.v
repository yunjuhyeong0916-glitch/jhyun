`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PRBS Generation and BER Checking
// Module Name: RX_PRBSCHK_MULTI_TOP_64LANE_BER_AUTO_WRAPPER
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Wraps the active 32-lane PRBS checker with packed GPIO/debug control and status interfaces.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module RX_PRBSCHK_MULTI_TOP_64LANE_BER_AUTO_WRAPPER #(
    parameter integer BITCNT_W = 48,
    parameter integer ERRCNT_W = 48,
    // Implementation-compare mode. This keeps the checker-facing debug ports
    // alive but removes the full PRBS lock/BER core from the routed design.
    parameter integer CODEX_PRBS_LIGHT_MODE = 0
)(
    input               rstb,
    input               i_clk,
    input               rx_valid,
    input               tx_accept_valid,

    input      [1:0]    sel_prbs,
    input signed [7:0]  cfg_thr4_0,
    input signed [7:0]  cfg_thr4_1,
    input signed [7:0]  cfg_thr4_2,
    input      [255:0]  rx_din_flat,

    output              lock,
    output     [BITCNT_W-1:0] bit_cnt_seen_total,
    output     [BITCNT_W-1:0] bit_cnt_total,
    output     [ERRCNT_W-1:0] err_cnt_total,
    output     [BITCNT_W-1:0] bit_cnt_streak,
    output     [ERRCNT_W-1:0] err_cnt_streak,
    output     [1:0]    err_popcnt,
    output     [6:0]    best_slip,
    output     [63:0]   rx_bits0,
    output     [63:0]   rx_bits0_natural,
    output     [63:0]   exp_bits0_natural,
    output     [63:0]   err_bits0_natural,
    output     [1:0]    rx_prbs_bits,
    output     [1:0]    exp_prbs_bits,
    output              prbs_pair_match
);

// Use the full checker so both PRBS7 and PRBS15 modes are available on-board.
localparam integer CODEX_PRBS_FORCE_LIGHT_MODE = 0;
localparam integer CODEX_PRBS_FORCE_STUB_MODE = 0;
localparam integer CODEX_PRBS_LIGHT_MODE_EFF =
    (CODEX_PRBS_LIGHT_MODE != 0) || (CODEX_PRBS_FORCE_LIGHT_MODE != 0);
localparam signed [7:0] CODEX_PAM4_HARD_THR4_0 = -8'sd64;
localparam signed [7:0] CODEX_PAM4_HARD_THR4_1 =  8'sd0;
localparam signed [7:0] CODEX_PAM4_HARD_THR4_2 =  8'sd64;
localparam [126:0] CODEX_PRBS7_PERIOD = 127'h2a6774b1bdad92385f2b9a278a18207f;
localparam [1:0] CODEX_PRBS7_ST_WAIT = 2'd0;
localparam [1:0] CODEX_PRBS7_ST_SCAN = 2'd1;
localparam [1:0] CODEX_PRBS7_ST_LOCK = 2'd2;
localparam integer CODEX_PRBS_CHECK_LANE = 0;
localparam integer CODEX_PRBS_CHECK_LANE_EFF =
    (CODEX_PRBS_CHECK_LANE < 0) ? 0 :
    ((CODEX_PRBS_CHECK_LANE > 31) ? 31 : CODEX_PRBS_CHECK_LANE);
localparam integer CODEX_PRBS_CHECK_BIT_BASE =
    ((3 - (CODEX_PRBS_CHECK_LANE_EFF / 8)) * 16) +
    ((CODEX_PRBS_CHECK_LANE_EFF % 8) * 2);
localparam [6:0] CODEX_PRBS_CHECK_BIT_BASE_MOD = CODEX_PRBS_CHECK_BIT_BASE;
localparam integer CODEX_PRBS7_CONFIRM_FRAMES = 8;
localparam [7:0] CODEX_PRBS7_UNLOCK_ERR_MAX = 8'd0;
localparam integer CODEX_PRBS7_UNLOCK_BAD_FRAMES = 8;
localparam [6:0] CODEX_PRBS7_FRAME_ADV = 7'd64;

// Preserve the historical ILA rx_bits0 ordering while sourcing bits from the
// checker-owned demapper.
wire [127:0] codex_rx_bits128_export_w;

genvar codex_rx_bits0_idx;
generate
for (codex_rx_bits0_idx = 0; codex_rx_bits0_idx < 64; codex_rx_bits0_idx = codex_rx_bits0_idx + 1) begin : GEN_CODEX_RX_BITS0_EXPORT
    assign rx_bits0[63-codex_rx_bits0_idx] = codex_rx_bits128_export_w[codex_rx_bits0_idx];
end
endgenerate

assign rx_bits0_natural = codex_rx_bits128_export_w[63:0];

function [7:0] codex_rx_lane_byte;
    input [255:0] din;
    input integer idx;
    begin
        codex_rx_lane_byte = din[(idx*8) +: 8];
    end
endfunction

function codex_is_pam4_hard_level;
    input [7:0] x;
    begin
        // -96, -32, +32, +96 are A0, E0, 20, 60; all have low bits 6'h20.
        codex_is_pam4_hard_level = (x[5:0] == 6'h20);
    end
endfunction

function codex_rx_din_is_hard_pam4;
    input [255:0] din;
    integer lane;
    reg hard;
    begin
        hard = 1'b1;
        for (lane = 0; lane < 32; lane = lane + 1)
            hard = hard && codex_is_pam4_hard_level(codex_rx_lane_byte(din, lane));
        codex_rx_din_is_hard_pam4 = hard;
    end
endfunction

function [1:0] codex_pam4_gray_from_x;
    input signed [7:0] x;
    input signed [7:0] t0;
    input signed [7:0] t1;
    input signed [7:0] t2;
    begin
        if      (x < t0) codex_pam4_gray_from_x = 2'b00;
        else if (x < t1) codex_pam4_gray_from_x = 2'b01;
        else if (x < t2) codex_pam4_gray_from_x = 2'b11;
        else             codex_pam4_gray_from_x = 2'b10;
    end
endfunction

function [127:0] codex_bits128_from_din;
    input [255:0] din;
    input signed [7:0] t0;
    input signed [7:0] t1;
    input signed [7:0] t2;
    integer lane;
        reg [1:0] g4;
    begin
        codex_bits128_from_din = 128'd0;
        for (lane = 0; lane < 32; lane = lane + 1) begin
            g4 = codex_pam4_gray_from_x(codex_rx_lane_byte(din, lane), t0, t1, t2);
            codex_bits128_from_din[(2*lane) + 0] = g4[0];
            codex_bits128_from_din[(2*lane) + 1] = g4[1];
        end
    end
endfunction

function [127:0] codex_rx_seq_from_din;
    input [255:0] din;
    input signed [7:0] t0;
    input signed [7:0] t1;
    input signed [7:0] t2;
    integer chunk_idx;
    integer bit_idx;
    integer serial_idx;
    reg [127:0] bits128_nat;
    begin
        bits128_nat = codex_bits128_from_din(din, t0, t1, t2);
        codex_rx_seq_from_din = 128'd0;
        serial_idx = 0;
        for (chunk_idx = 3; chunk_idx >= 0; chunk_idx = chunk_idx - 1) begin
            for (bit_idx = 0; bit_idx < 16; bit_idx = bit_idx + 1) begin
                codex_rx_seq_from_din[serial_idx] = bits128_nat[(chunk_idx*16) + bit_idx];
                serial_idx = serial_idx + 1;
            end
        end
    end
endfunction

function [6:0] codex_mod127_add;
    input [6:0] a;
    input [6:0] b;
    reg [7:0] sum;
    begin
        sum = {1'b0, a} + {1'b0, b};
        if (sum >= 8'd127)
            codex_mod127_add = sum - 8'd127;
        else
            codex_mod127_add = sum[6:0];
    end
endfunction

function codex_prbs7_bit;
    input [6:0] idx;
    begin
        codex_prbs7_bit = CODEX_PRBS7_PERIOD[idx];
    end
endfunction

function [1:0] codex_prbs7_pair_for_phase;
    input [6:0] phase;
    reg [6:0] idx;
    begin
        idx = codex_mod127_add(phase, CODEX_PRBS_CHECK_BIT_BASE_MOD);
        codex_prbs7_pair_for_phase[0] = codex_prbs7_bit(idx);
        idx = codex_mod127_add(idx, 7'd1);
        codex_prbs7_pair_for_phase[1] = codex_prbs7_bit(idx);
    end
endfunction

function [63:0] codex_prbs7_64_for_phase;
    input [6:0] phase;
    integer chunk_idx;
    integer bit_idx;
    integer out_idx;
    reg [6:0] chunk_offset;
    reg [6:0] step;
    reg [6:0] idx;
    reg [6:0] rel_idx;
    begin
        codex_prbs7_64_for_phase = 64'd0;
        for (chunk_idx = 0; chunk_idx < 4; chunk_idx = chunk_idx + 1) begin
            case (chunk_idx)
                0: chunk_offset = 7'd96;
                1: chunk_offset = 7'd80;
                2: chunk_offset = 7'd64;
                default: chunk_offset = 7'd48;
            endcase
            for (bit_idx = 0; bit_idx < 16; bit_idx = bit_idx + 1) begin
                out_idx = (chunk_idx * 16) + bit_idx;
                step = bit_idx;
                rel_idx = chunk_offset + step;
                idx = codex_mod127_add(phase, rel_idx);
                codex_prbs7_64_for_phase[out_idx] = codex_prbs7_bit(idx);
            end
        end
    end
endfunction

function [7:0] codex_popcount2;
    input [1:0] x;
    begin
        codex_popcount2 = {7'd0, x[0]} + {7'd0, x[1]};
    end
endfunction

generate
if (CODEX_PRBS_FORCE_STUB_MODE != 0) begin : GEN_CODEX_PRBS_STUB
    assign lock               = 1'b0;
    assign bit_cnt_seen_total = {BITCNT_W{1'b0}};
    assign bit_cnt_total      = {BITCNT_W{1'b0}};
    assign err_cnt_total      = {ERRCNT_W{1'b0}};
    assign bit_cnt_streak     = {BITCNT_W{1'b0}};
    assign err_cnt_streak     = {ERRCNT_W{1'b0}};
    assign err_popcnt         = 2'd0;
    assign best_slip          = 7'd0;
    assign codex_rx_bits128_export_w = 128'd0;
    assign exp_bits0_natural  = 64'd0;
    assign err_bits0_natural  = 64'd0;
    assign rx_prbs_bits       = 2'd0;
    assign exp_prbs_bits      = 2'd0;
    assign prbs_pair_match    = 1'b0;
end else if (CODEX_PRBS_LIGHT_MODE_EFF != 0) begin : GEN_CODEX_PRBS_LIGHT
    localparam [BITCNT_W-1:0] CODEX_BITS_PER_FRAME = 2;

    reg                  lock_q;
    reg [1:0]            state_q;
    reg [1:0]            sel_prbs_meta_q;
    reg [1:0]            sel_prbs_sync_q;
    reg [1:0]            sel_prbs_prev_q;
    reg signed [7:0]     cfg_thr4_0_meta_q;
    reg signed [7:0]     cfg_thr4_1_meta_q;
    reg signed [7:0]     cfg_thr4_2_meta_q;
    reg signed [7:0]     cfg_thr4_0_sync_q;
    reg signed [7:0]     cfg_thr4_1_sync_q;
    reg signed [7:0]     cfg_thr4_2_sync_q;
    reg [BITCNT_W-1:0]   bit_cnt_seen_total_q;
    reg [BITCNT_W-1:0]   bit_cnt_total_q;
    reg [ERRCNT_W-1:0]   err_cnt_total_q;
    reg [BITCNT_W-1:0]   bit_cnt_streak_q;
    reg [ERRCNT_W-1:0]   err_cnt_streak_q;
    reg [1:0]            err_popcnt_q;
    reg [6:0]            best_slip_q;
    reg [6:0]            phase_q;
    reg [6:0]            scan_phase_q;
    reg [6:0]            scan_test_phase_q;
    reg [3:0]            confirm_frames_q;
    reg [3:0]            bad_frames_q;
    reg [127:0]          rx_bits128_raw_q;
    reg [63:0]           exp_bits0_natural_q;
    reg [1:0]            exp_prbs_bits_q;

    wire                 rx_din_hard_pam4_w;
    wire signed [7:0]    demap_thr4_0_w;
    wire signed [7:0]    demap_thr4_1_w;
    wire signed [7:0]    demap_thr4_2_w;
    wire [127:0]         rx_seq_w;
    wire [1:0]           rx_check_pair_w;
    wire [1:0]           scan_expected_pair_w;
    wire [1:0]           lock_expected_pair_w;
    wire [63:0]          scan_expected64_w;
    wire [63:0]          lock_expected64_w;
    wire [7:0]           scan_err_w;
    wire [7:0]           lock_err_w;
    wire [6:0]           scan_reject_phase_next_w;
    wire [6:0]           scan_test_phase_next_w;
    wire [6:0]           phase_next_w;
    wire                 sel_prbs_changed_w;
    wire                 prbs7_mode_w;

    assign rx_din_hard_pam4_w = 1'b0;
    assign demap_thr4_0_w = rx_din_hard_pam4_w ? CODEX_PAM4_HARD_THR4_0 : cfg_thr4_0_sync_q;
    assign demap_thr4_1_w = rx_din_hard_pam4_w ? CODEX_PAM4_HARD_THR4_1 : cfg_thr4_1_sync_q;
    assign demap_thr4_2_w = rx_din_hard_pam4_w ? CODEX_PAM4_HARD_THR4_2 : cfg_thr4_2_sync_q;
    assign rx_seq_w = codex_rx_seq_from_din(rx_din_flat, demap_thr4_0_w, demap_thr4_1_w, demap_thr4_2_w);
    assign rx_check_pair_w = rx_seq_w[CODEX_PRBS_CHECK_BIT_BASE +: 2];
    assign scan_expected_pair_w = codex_prbs7_pair_for_phase(scan_test_phase_q);
    assign lock_expected_pair_w = codex_prbs7_pair_for_phase(phase_q);
    assign scan_expected64_w = codex_prbs7_64_for_phase(scan_test_phase_q);
    assign lock_expected64_w = codex_prbs7_64_for_phase(phase_q);
    assign scan_err_w = codex_popcount2(rx_check_pair_w ^ scan_expected_pair_w);
    assign lock_err_w = codex_popcount2(rx_check_pair_w ^ lock_expected_pair_w);
    assign scan_reject_phase_next_w = (scan_test_phase_q == 7'd126) ? 7'd0 : (scan_test_phase_q + 7'd1);
    assign scan_test_phase_next_w = codex_mod127_add(scan_test_phase_q, CODEX_PRBS7_FRAME_ADV);
    assign phase_next_w = codex_mod127_add(phase_q, CODEX_PRBS7_FRAME_ADV);
    assign sel_prbs_changed_w = (sel_prbs_sync_q != sel_prbs_prev_q);
    assign prbs7_mode_w = (sel_prbs_sync_q == 2'b00);

    always @(posedge i_clk or negedge rstb) begin
        if (!rstb) begin
            lock_q                 <= 1'b0;
            state_q                <= CODEX_PRBS7_ST_WAIT;
            sel_prbs_meta_q        <= 2'b00;
            sel_prbs_sync_q        <= 2'b00;
            sel_prbs_prev_q        <= 2'b00;
            cfg_thr4_0_meta_q      <= CODEX_PAM4_HARD_THR4_0;
            cfg_thr4_1_meta_q      <= CODEX_PAM4_HARD_THR4_1;
            cfg_thr4_2_meta_q      <= CODEX_PAM4_HARD_THR4_2;
            cfg_thr4_0_sync_q      <= CODEX_PAM4_HARD_THR4_0;
            cfg_thr4_1_sync_q      <= CODEX_PAM4_HARD_THR4_1;
            cfg_thr4_2_sync_q      <= CODEX_PAM4_HARD_THR4_2;
            bit_cnt_seen_total_q   <= {BITCNT_W{1'b0}};
            bit_cnt_total_q        <= {BITCNT_W{1'b0}};
            err_cnt_total_q        <= {ERRCNT_W{1'b0}};
            bit_cnt_streak_q       <= {BITCNT_W{1'b0}};
            err_cnt_streak_q       <= {ERRCNT_W{1'b0}};
            err_popcnt_q           <= 2'd0;
            best_slip_q            <= 7'd0;
            phase_q                <= 7'd0;
            scan_phase_q           <= 7'd0;
            scan_test_phase_q      <= 7'd0;
            confirm_frames_q       <= 4'd0;
            bad_frames_q           <= 4'd0;
            rx_bits128_raw_q       <= 128'd0;
            exp_bits0_natural_q    <= 64'd0;
            exp_prbs_bits_q        <= 2'd0;
        end else begin
            sel_prbs_meta_q   <= sel_prbs;
            sel_prbs_sync_q   <= sel_prbs_meta_q;
            sel_prbs_prev_q   <= sel_prbs_sync_q;
            cfg_thr4_0_meta_q <= cfg_thr4_0;
            cfg_thr4_1_meta_q <= cfg_thr4_1;
            cfg_thr4_2_meta_q <= cfg_thr4_2;
            cfg_thr4_0_sync_q <= cfg_thr4_0_meta_q;
            cfg_thr4_1_sync_q <= cfg_thr4_1_meta_q;
            cfg_thr4_2_sync_q <= cfg_thr4_2_meta_q;

            if (sel_prbs_changed_w || !prbs7_mode_w) begin
                lock_q           <= 1'b0;
                state_q          <= CODEX_PRBS7_ST_WAIT;
                bit_cnt_streak_q <= {BITCNT_W{1'b0}};
                err_cnt_streak_q <= {ERRCNT_W{1'b0}};
                scan_phase_q     <= 7'd0;
                scan_test_phase_q <= 7'd0;
                confirm_frames_q <= 4'd0;
                bad_frames_q     <= 4'd0;
                exp_bits0_natural_q <= 64'd0;
            end else begin
                if (rx_valid) begin
                    bit_cnt_seen_total_q <= bit_cnt_seen_total_q + CODEX_BITS_PER_FRAME;
                    rx_bits128_raw_q     <= rx_seq_w;
                end

                case (state_q)
                    CODEX_PRBS7_ST_WAIT: begin
                        lock_q <= 1'b0;
                        if (rx_valid) begin
                            scan_phase_q     <= 7'd0;
                            scan_test_phase_q <= 7'd0;
                            confirm_frames_q <= 4'd0;
                            err_popcnt_q     <= 2'd0;
                            best_slip_q      <= 7'd0;
                            bad_frames_q     <= 4'd0;
                            state_q          <= CODEX_PRBS7_ST_SCAN;
                        end
                    end

                    CODEX_PRBS7_ST_SCAN: begin
                        lock_q <= 1'b0;
                        if (rx_valid) begin
                            err_popcnt_q <= scan_err_w[1:0];
                            exp_prbs_bits_q <= scan_expected_pair_w;
                            exp_bits0_natural_q <= scan_expected64_w;
                            best_slip_q <= scan_phase_q;

                            if (scan_err_w == 8'd0) begin
                                if (confirm_frames_q >= (CODEX_PRBS7_CONFIRM_FRAMES-1)) begin
                                    phase_q <= scan_test_phase_next_w;
                                    lock_q <= 1'b1;
                                    state_q <= CODEX_PRBS7_ST_LOCK;
                                    bit_cnt_streak_q <= {BITCNT_W{1'b0}};
                                    err_cnt_streak_q <= {ERRCNT_W{1'b0}};
                                    confirm_frames_q <= 4'd0;
                                    bad_frames_q <= 4'd0;
                                end else begin
                                    confirm_frames_q <= confirm_frames_q + 4'd1;
                                    scan_test_phase_q <= scan_test_phase_next_w;
                                end
                            end else begin
                                scan_phase_q <= scan_reject_phase_next_w;
                                scan_test_phase_q <= scan_reject_phase_next_w;
                                confirm_frames_q <= 4'd0;
                            end
                        end
                    end

                    CODEX_PRBS7_ST_LOCK: begin
                        lock_q <= 1'b1;
                        if (rx_valid) begin
                            exp_prbs_bits_q <= lock_expected_pair_w;
                            exp_bits0_natural_q <= lock_expected64_w;
                            err_popcnt_q <= lock_err_w[1:0];
                            bit_cnt_total_q <= bit_cnt_total_q + CODEX_BITS_PER_FRAME;
                            bit_cnt_streak_q <= bit_cnt_streak_q + CODEX_BITS_PER_FRAME;
                            err_cnt_total_q <= err_cnt_total_q + {{(ERRCNT_W-8){1'b0}}, lock_err_w};
                            err_cnt_streak_q <= err_cnt_streak_q + {{(ERRCNT_W-8){1'b0}}, lock_err_w};
                            phase_q <= phase_next_w;

                            if (lock_err_w > CODEX_PRBS7_UNLOCK_ERR_MAX) begin
                                if (bad_frames_q >= (CODEX_PRBS7_UNLOCK_BAD_FRAMES-1)) begin
                                    lock_q <= 1'b0;
                                    state_q <= CODEX_PRBS7_ST_WAIT;
                                    bit_cnt_streak_q <= {BITCNT_W{1'b0}};
                                    err_cnt_streak_q <= {ERRCNT_W{1'b0}};
                                    bad_frames_q <= 4'd0;
                                end else begin
                                    bad_frames_q <= bad_frames_q + 4'd1;
                                end
                            end else begin
                                bad_frames_q <= 4'd0;
                            end
                        end
                    end

                    default: begin
                        lock_q <= 1'b0;
                        state_q <= CODEX_PRBS7_ST_WAIT;
                    end
                endcase
            end
        end
    end

    assign lock               = lock_q;
    assign bit_cnt_seen_total = bit_cnt_seen_total_q;
    assign bit_cnt_total      = bit_cnt_total_q;
    assign err_cnt_total      = err_cnt_total_q;
    assign bit_cnt_streak     = bit_cnt_streak_q;
    assign err_cnt_streak     = err_cnt_streak_q;
    assign err_popcnt         = err_popcnt_q;
    assign best_slip          = best_slip_q;
    assign codex_rx_bits128_export_w = rx_bits128_raw_q;
    assign exp_bits0_natural = exp_bits0_natural_q;
    assign err_bits0_natural = rx_bits128_raw_q[63:0] ^ exp_bits0_natural_q;
    assign rx_prbs_bits      = rx_bits128_raw_q[CODEX_PRBS_CHECK_BIT_BASE +: 2];
    assign exp_prbs_bits     = exp_prbs_bits_q;
    assign prbs_pair_match   = (rx_prbs_bits == exp_prbs_bits);
end else begin : GEN_FULL_PRBS
    wire [8:0]   core_err_popcnt_w;
    wire [7:0]   core_best_slip_w;
    wire [127:0] core_rx_bits128_raw_w;
    wire [127:0] core_exp128_w;
    wire [127:0] core_rxW_aligned128_dbg_w;
    wire [127:0] core_expW_raw128_dbg_w;

    RX_PRBSCHK_MULTI_TOP_64LANE_BER_AUTO #(
        .BITCNT_W (BITCNT_W),
        .ERRCNT_W (ERRCNT_W),
        .AUTO_HARD_PAM4_THRESH (1'b0),
        .ACCEPT_REF_FIFO_DEPTH (256),
        .PIPELINE_RUN_DETECT (1'b1)
    ) u_core (
        .rstb               (rstb),
        .i_clk              (i_clk),
        .rx_valid           (rx_valid),
        .tx_accept_valid    (tx_accept_valid),
        .sel_prbs           (sel_prbs),
        .cfg_thr4_0         (cfg_thr4_0),
        .cfg_thr4_1         (cfg_thr4_1),
        .cfg_thr4_2         (cfg_thr4_2),
        .rx_din_flat        (rx_din_flat),
        .lock               (lock),
        .bit_cnt_seen_total (bit_cnt_seen_total),
        .bit_cnt            (bit_cnt_streak),
        .err_cnt            (err_cnt_streak),
        .bit_cnt_total      (bit_cnt_total),
        .err_cnt_total      (err_cnt_total),
        .err_popcnt         (core_err_popcnt_w),
        .best_slip          (core_best_slip_w),
        .rx_bits128_raw     (core_rx_bits128_raw_w),
        .exp128             (core_exp128_w),
        .rxW_aligned128_dbg (core_rxW_aligned128_dbg_w),
        .expW_raw128_dbg    (core_expW_raw128_dbg_w)
    );

    assign err_popcnt = core_err_popcnt_w[1:0];
    assign best_slip = core_best_slip_w[6:0];
    assign codex_rx_bits128_export_w = core_rx_bits128_raw_w;
    assign exp_bits0_natural = core_exp128_w[63:0];
    assign err_bits0_natural = core_rx_bits128_raw_w[63:0] ^ core_exp128_w[63:0];
    assign rx_prbs_bits = core_rx_bits128_raw_w[CODEX_PRBS_CHECK_BIT_BASE +: 2];
    assign exp_prbs_bits = core_exp128_w[CODEX_PRBS_CHECK_BIT_BASE +: 2];
    assign prbs_pair_match = (rx_prbs_bits == exp_prbs_bits);
end
endgenerate

endmodule
