`timescale 1ns/1ps

// ============================================================================
// PAM4-only PRBS checker for the 32-lane RX path.
// - Fixed 64 observed bits/valid frame. Public 128b debug ports keep the lower
//   64 active bits and zero-pad the upper half for BD compatibility.
// - NRZ/PAM8 mode muxing and 64/192-bit debug ports are intentionally removed.
// - The multimode source set is backed up separately for future restoration.
// - rx_valid gates the checker state so sparse MLSD output is not mixed with
//   bypass/raw samples or counted multiple times.
// - If rx_din_flat is already hard-sliced MLSD PAM4 {-96,-32,+32,+96}, the
//   demapper uses the matching mid-point thresholds {-64,0,+64}. Otherwise it
//   uses the externally configured EQ thresholds.
// ============================================================================
//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PRBS Generation and BER Checking
// Module Name: RX_PRBSCHK_MULTI_TOP_64LANE_BER_AUTO
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Checks the active 32-lane PAM4 PRBS stream, performs lock detection, and accumulates BER counters.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module RX_PRBSCHK_MULTI_TOP_64LANE_BER_AUTO #(
    parameter int BITCNT_W = 48,
    parameter int ERRCNT_W = 48,

    // Phase lock / unlock knobs
    parameter int ACC_CONFIRM_FRAMES = 2,
    parameter int PASS_ERR_MAX       = 8,
    parameter int UNLOCK_BAD_TH      = 8,
    parameter int UNLOCK_TH          = 2,

    // PRBS run-start states. The active checker path supports PRBS7/PRBS15;
    // PRBS23/PRBS31 parameters are retained only for legacy compatibility.
    parameter logic [30:0] PRBS7_RUNSTART_STATE  = 31'h0000_007F,
    parameter logic [30:0] PRBS15_RUNSTART_STATE = 31'h0000_7FFF,
    parameter logic [30:0] PRBS23_RUNSTART_STATE = 31'h007F_FFFF,
    parameter logic [30:0] PRBS31_RUNSTART_STATE = 31'h7FFF_FFFF,

    // Optional: if RX bit packing order is reversed in time inside each frame
    parameter bit RX_TIME_REVERSED = 1'b0,

    // MLSD detector hard outputs use TX PAM4 levels {-96,-32,+32,+96}; those
    // must be sliced at {-64,0,+64}, not at the EQ-scaled GPIO thresholds.
    parameter bit AUTO_HARD_PAM4_THRESH = 1'b0,

    // In sparse MLSD mode the detector does not consume every TX/RX clock.
    // Advance the reference through invalid gaps only when an input frame was
    // actually accepted by the detector.
    parameter bit ACCEPT_GATED_SPARSE_TIMELINE = 1'b1,
    parameter int ACCEPT_REF_FIFO_DEPTH = 16,

    // Verification hook for the next timing patch. When enabled, the run/hit
    // detector output is registered once more before the checker FSM consumes it.
    parameter bit PIPELINE_RUN_DETECT = 1'b0
)(
    input  logic                 rstb,
    input  logic                 i_clk,
    input  logic                 rx_valid,
    input  logic                 tx_accept_valid,

    input  logic [1:0]           sel_prbs,
    input  logic signed [7:0]    cfg_thr4_0,
    input  logic signed [7:0]    cfg_thr4_1,
    input  logic signed [7:0]    cfg_thr4_2,
    input  logic [255:0]         rx_din_flat,

    output logic                 lock,

    // ALL OBSERVED BITS (includes pre-lock)
    output logic [BITCNT_W-1:0]  bit_cnt_seen_total,

    // STREAK: current continuous lock section only
    output logic [BITCNT_W-1:0]  bit_cnt,
    output logic [ERRCNT_W-1:0]  err_cnt,

    // TOTAL: accumulated across all lock sections since reset / PRBS change
    output logic [BITCNT_W-1:0]  bit_cnt_total,
    output logic [ERRCNT_W-1:0]  err_cnt_total,

    output logic [8:0]           err_popcnt,
    output logic [7:0]           best_slip,

    output logic [127:0]         rx_bits128_raw,
    output logic [127:0]         exp128,

    output logic [127:0]         rxW_aligned128_dbg,
    output logic [127:0]         expW_raw128_dbg
);

    localparam int ACC_CONFIRM_FRAMES_SAFE = (ACC_CONFIRM_FRAMES < 1) ? 1 : ACC_CONFIRM_FRAMES;
    localparam int UNLOCK_TH_SAFE          = (UNLOCK_TH < 1) ? 1 : UNLOCK_TH;
    localparam int PASS_ERR_MAX_SAFE       = (PASS_ERR_MAX < 0) ? 0 : PASS_ERR_MAX;
    localparam int UNLOCK_BAD_TH_SAFE      = (UNLOCK_BAD_TH < 0) ? 0 : UNLOCK_BAD_TH;
    localparam int CONFIRM_CNT_W           = (ACC_CONFIRM_FRAMES_SAFE <= 1) ? 1 : $clog2(ACC_CONFIRM_FRAMES_SAFE + 1);
    localparam int BAD_STREAK_W            = (UNLOCK_TH_SAFE <= 1) ? 1 : $clog2(UNLOCK_TH_SAFE + 1);
    localparam int RUN_CHUNKS              = 2;
    localparam int RUN_CHUNK_W             = 32;
    localparam int ACCEPT_REF_FIFO_DEPTH_SAFE = (ACCEPT_REF_FIFO_DEPTH < 2) ? 2 : ACCEPT_REF_FIFO_DEPTH;
    localparam int ACCEPT_REF_FIFO_PTR_W      = (ACCEPT_REF_FIFO_DEPTH_SAFE <= 2) ? 1 : $clog2(ACCEPT_REF_FIFO_DEPTH_SAFE);
    localparam logic [8:0] PAM4_W9         = 9'd64;
    localparam logic signed [7:0] PAM4_HARD_THR4_0 = -8'sd64;
    localparam logic signed [7:0] PAM4_HARD_THR4_1 =  8'sd0;
    localparam logic signed [7:0] PAM4_HARD_THR4_2 =  8'sd64;

    initial begin
        if (ACC_CONFIRM_FRAMES < 1) $warning("ACC_CONFIRM_FRAMES < 1. Forced to 1 internally.");
        if (UNLOCK_TH < 1)          $warning("UNLOCK_TH < 1. Forced to 1 internally.");
        if (PASS_ERR_MAX < 0)       $warning("PASS_ERR_MAX < 0. Forced to 0 internally.");
        if (UNLOCK_BAD_TH < 0)      $warning("UNLOCK_BAD_TH < 0. Forced to 0 internally.");
    end

    function automatic logic [7:0] rx_lane_byte(input int idx);
        begin
            rx_lane_byte = rx_din_flat[(idx*8) +: 8];
        end
    endfunction

    function automatic logic is_pam4_hard_level(input logic [7:0] x);
        begin
            // -96, -32, +32, +96 are A0, E0, 20, 60; all have low bits 6'h20.
            unique case (x[5:0])
                6'h20:  is_pam4_hard_level = 1'b1;
                default: is_pam4_hard_level = 1'b0;
            endcase
        end
    endfunction

    logic rx_din_is_hard_pam4;
    logic signed [7:0] demap_thr4_0;
    logic signed [7:0] demap_thr4_1;
    logic signed [7:0] demap_thr4_2;
    logic [63:0]       rx_bits64_demap_w;
    logic              rx_valid_demap_q;
    logic              tx_accept_valid_demap_q;

    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic [1:0] sel_prbs_meta;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic [1:0] sel_prbs_sync;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic signed [7:0] cfg_thr4_0_meta;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic signed [7:0] cfg_thr4_1_meta;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic signed [7:0] cfg_thr4_2_meta;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic signed [7:0] cfg_thr4_0_sync;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic signed [7:0] cfg_thr4_1_sync;
    (* ASYNC_REG = "TRUE", SHREG_EXTRACT = "NO" *) logic signed [7:0] cfg_thr4_2_sync;
    logic [1:0] sel_prbs_chk;
    logic       sel_prbs_supported;

    always_comb begin
        rx_din_is_hard_pam4 = AUTO_HARD_PAM4_THRESH;

        for (int lane = 0; lane < 32; lane++) begin
            rx_din_is_hard_pam4 = rx_din_is_hard_pam4 && is_pam4_hard_level(rx_lane_byte(lane));
        end
    end

    assign demap_thr4_0 = rx_din_is_hard_pam4 ? PAM4_HARD_THR4_0 : cfg_thr4_0_sync;
    assign demap_thr4_1 = rx_din_is_hard_pam4 ? PAM4_HARD_THR4_1 : cfg_thr4_1_sync;
    assign demap_thr4_2 = rx_din_is_hard_pam4 ? PAM4_HARD_THR4_2 : cfg_thr4_2_sync;

    RX_GRAY_DEMAP_32LANE_8B_PAM4_CFG u_demap (
        .cfg_thr4_0   (demap_thr4_0),
        .cfg_thr4_1   (demap_thr4_1),
        .cfg_thr4_2   (demap_thr4_2),
        .rx_din_flat  (rx_din_flat),
        .bits64       (rx_bits64_demap_w)
    );

    always_ff @(posedge i_clk or negedge rstb) begin
        if (!rstb) begin
            sel_prbs_meta    <= 2'b00;
            sel_prbs_sync    <= 2'b00;
            cfg_thr4_0_meta  <= PAM4_HARD_THR4_0;
            cfg_thr4_1_meta  <= PAM4_HARD_THR4_1;
            cfg_thr4_2_meta  <= PAM4_HARD_THR4_2;
            cfg_thr4_0_sync  <= PAM4_HARD_THR4_0;
            cfg_thr4_1_sync  <= PAM4_HARD_THR4_1;
            cfg_thr4_2_sync  <= PAM4_HARD_THR4_2;
            rx_bits128_raw   <= '0;
            rx_valid_demap_q <= 1'b0;
            tx_accept_valid_demap_q <= 1'b0;
        end else begin
            sel_prbs_meta    <= sel_prbs;
            sel_prbs_sync    <= sel_prbs_meta;
            cfg_thr4_0_meta  <= cfg_thr4_0;
            cfg_thr4_1_meta  <= cfg_thr4_1;
            cfg_thr4_2_meta  <= cfg_thr4_2;
            cfg_thr4_0_sync  <= cfg_thr4_0_meta;
            cfg_thr4_1_sync  <= cfg_thr4_1_meta;
            cfg_thr4_2_sync  <= cfg_thr4_2_meta;
            rx_valid_demap_q <= rx_valid;
            tx_accept_valid_demap_q <= tx_accept_valid;

            if (rx_valid) begin
                rx_bits128_raw <= {64'd0, rx_bits64_demap_w};
            end
        end
    end

    assign sel_prbs_supported = (sel_prbs_sync == 2'b00) || (sel_prbs_sync == 2'b01);
    assign sel_prbs_chk       = (sel_prbs_sync == 2'b00) ? 2'b00 : 2'b01;

    // Expected PRBS generator chain for 64 PAM4 bits/cycle.
    logic [30:0] state0;
    logic [30:0] state1_w;
    logic [63:0] prbs64_0;

    prbsgen_64b u_prbs64_0 (
        .rstb        (rstb),
        .i_clk       (i_clk),
        .sel_prbs    (sel_prbs_chk),
        .ext_ptrn_en (1'b0),
        .ext_ptrn    (64'h0),
        .state_in_en (1'b1),
        .state_in    (state0),
        .state_out   (state1_w),
        .dout        (prbs64_0)
    );

    assign exp128 = {64'd0, prbs64_0};

    logic [63:0] rxW_time;
    logic [63:0] expW_raw;
    logic [63:0] accept_ref_fifo_mem [0:ACCEPT_REF_FIFO_DEPTH_SAFE-1];
    logic [ACCEPT_REF_FIFO_PTR_W-1:0] accept_ref_fifo_wr_ptr;
    logic [ACCEPT_REF_FIFO_PTR_W-1:0] accept_ref_fifo_rd_ptr;
    logic [ACCEPT_REF_FIFO_PTR_W:0]   accept_ref_fifo_count;
    logic [63:0] accept_ref_fifo_head;
    logic         accept_ref_fifo_has_ref;
    logic         accept_ref_fifo_push;
    logic         accept_ref_fifo_push_do;
    logic         accept_ref_fifo_pop;

    assign accept_ref_fifo_head = accept_ref_fifo_mem[accept_ref_fifo_rd_ptr];
    assign accept_ref_fifo_has_ref = ACCEPT_GATED_SPARSE_TIMELINE && lock && (accept_ref_fifo_count != '0);
    assign expW_raw = accept_ref_fifo_has_ref ? accept_ref_fifo_head : prbs64_0;

    always_comb begin
        for (int i = 0; i < 64; i++) begin
            rxW_time[i] = RX_TIME_REVERSED ? rx_bits128_raw[63-i] : rx_bits128_raw[i];
        end
    end

    function automatic logic [3:0] popcount8(input logic [7:0] x);
        logic [3:0] c;
        begin
            c = 4'd0;
            for (int i = 0; i < 8; i++) c = c + {3'd0, x[i]};
            popcount8 = c;
        end
    endfunction

    function automatic logic [8:0] popcount64(input logic [63:0] x);
        logic [3:0] c00, c01, c02, c03, c04, c05, c06, c07;
        logic [4:0] s00, s01, s02, s03;
        logic [5:0] t00, t01;
        logic [6:0] u00;
        begin
            c00 = popcount8(x[  0 +: 8]);
            c01 = popcount8(x[  8 +: 8]);
            c02 = popcount8(x[ 16 +: 8]);
            c03 = popcount8(x[ 24 +: 8]);
            c04 = popcount8(x[ 32 +: 8]);
            c05 = popcount8(x[ 40 +: 8]);
            c06 = popcount8(x[ 48 +: 8]);
            c07 = popcount8(x[ 56 +: 8]);

            s00 = {1'b0, c00} + {1'b0, c01};
            s01 = {1'b0, c02} + {1'b0, c03};
            s02 = {1'b0, c04} + {1'b0, c05};
            s03 = {1'b0, c06} + {1'b0, c07};

            t00 = {1'b0, s00} + {1'b0, s01};
            t01 = {1'b0, s02} + {1'b0, s03};

            u00 = {1'b0, t00} + {1'b0, t01};

            popcount64 = {2'b00, u00};
        end
    endfunction

    function automatic logic [30:0] runstart_state(input logic [1:0] s);
        begin
            unique case (s)
                2'b00:   runstart_state = PRBS7_RUNSTART_STATE;
                2'b01:   runstart_state = PRBS15_RUNSTART_STATE;
                default: runstart_state = PRBS15_RUNSTART_STATE;
            endcase
        end
    endfunction

    function automatic logic chk_fb_left(
        input logic [30:0] st,
        input logic [1:0]  mode
    );
        begin
            unique case (mode)
                2'b00:   chk_fb_left = st[6]  ^ st[5];
                default: chk_fb_left = st[14] ^ st[13];
            endcase
        end
    endfunction

    function automatic logic [30:0] chk_step_left(
        input logic [30:0] st,
        input logic [1:0]  mode
    );
        logic fb;
        begin
            fb = chk_fb_left(st, mode);
            unique case (mode)
                2'b00:   chk_step_left = {24'b0, st[5:0],  fb};
                default: chk_step_left = {16'b0, st[13:0], fb};
            endcase
        end
    endfunction

    function automatic logic [30:0] advance_state_bits(
        input logic [30:0] st,
        input logic [1:0]  mode,
        input logic [8:0]  nbits
    );
        logic [30:0] s;
        begin
            s = st;
            for (int i = 0; i < 64; i++) begin
                if (i < int'(nbits)) begin
                    s = chk_step_left(s, mode);
                end
            end
            advance_state_bits = s;
        end
    endfunction

    function automatic logic [ACCEPT_REF_FIFO_PTR_W-1:0] accept_ref_fifo_ptr_inc(
        input logic [ACCEPT_REF_FIFO_PTR_W-1:0] ptr
    );
        begin
            if (int'(ptr) >= (ACCEPT_REF_FIFO_DEPTH_SAFE - 1)) begin
                accept_ref_fifo_ptr_inc = '0;
            end else begin
                accept_ref_fifo_ptr_inc = ptr + 1'b1;
            end
        end
    endfunction

    // RUN detect over the fixed 64-bit PAM4 window.
    logic [7:0] req_ones;
    logic [7:0] run1_len, run1_len_next;
    logic       hit_now;
    logic [8:0] hit_abs_now;
    logic       hit_in_current_frame;
    logic [6:0] hit_offset_now;
    logic [8:0] bits_to_next_frame_now;
    logic [30:0] state_after_hit_frame_w;
    logic       run_scan_valid_q;
    logic       run_accept_valid_q;
    logic [1:0] sel_q;
    logic       selprbs_changed;
    logic [63:0] rxW_time_scan_q;
    logic [7:0] run1_len_scan_q;
    logic [7:0] req_ones_scan_q;

    logic [RUN_CHUNKS-1:0] chunk_all_w;
    logic [RUN_CHUNKS-1:0] chunk_all_q;
    logic [RUN_CHUNKS-1:0] chunk_hit_w;
    logic [RUN_CHUNKS-1:0] chunk_hit_q;
    logic [7:0] chunk_prefix_w [0:RUN_CHUNKS-1];
    logic [7:0] chunk_prefix_q [0:RUN_CHUNKS-1];
    logic [7:0] chunk_suffix_w [0:RUN_CHUNKS-1];
    logic [7:0] chunk_suffix_q [0:RUN_CHUNKS-1];
    logic [7:0] chunk_hit_start_w [0:RUN_CHUNKS-1];
    logic [7:0] chunk_hit_start_q [0:RUN_CHUNKS-1];

    logic       run_proc_valid_q;
    logic       run_accept_proc_q;
    logic [63:0]  rxW_time_proc_q;
    logic [7:0]   run1_len_next_proc_q;
    logic         hit_proc_q;
    logic [8:0]   hit_abs_proc_q;
    logic         hit_in_current_frame_proc_q;
    logic [30:0]  state_after_hit_frame_proc_q;

    always_comb begin
        unique case (sel_prbs_chk)
            2'b00: req_ones = 8'd7;
            2'b01: req_ones = 8'd15;
            default: req_ones = 8'd15;
        endcase
    end

    always_comb begin
        for (int c = 0; c < RUN_CHUNKS; c++) begin
            logic [RUN_CHUNK_W-1:0] chunk;
            logic prefix_done;
            logic suffix_done;
            logic [7:0] r_local;

            chunk = rxW_time[(c*RUN_CHUNK_W) +: RUN_CHUNK_W];

            chunk_all_w[c]       = &chunk;
            chunk_hit_w[c]       = 1'b0;
            chunk_prefix_w[c]    = 8'd0;
            chunk_suffix_w[c]    = 8'd0;
            chunk_hit_start_w[c] = 8'd0;

            prefix_done = 1'b0;
            for (int j = 0; j < RUN_CHUNK_W; j++) begin
                if (!prefix_done && chunk[j]) begin
                    chunk_prefix_w[c] = chunk_prefix_w[c] + 8'd1;
                end else begin
                    prefix_done = 1'b1;
                end
            end

            suffix_done = 1'b0;
            for (int jj = 0; jj < RUN_CHUNK_W; jj++) begin
                int j;
                j = RUN_CHUNK_W - 1 - jj;
                if (!suffix_done && chunk[j]) begin
                    chunk_suffix_w[c] = chunk_suffix_w[c] + 8'd1;
                end else begin
                    suffix_done = 1'b1;
                end
            end

            r_local = 8'd0;
            for (int j = 0; j < RUN_CHUNK_W; j++) begin
                if (chunk[j]) begin
                    r_local = r_local + 8'd1;
                end else begin
                    r_local = 8'd0;
                end

                if (!chunk_hit_w[c] && (r_local == req_ones)) begin
                    chunk_hit_w[c]       = 1'b1;
                    chunk_hit_start_w[c] = j - int'(req_ones) + 1;
                end
            end
        end
    end

    always_ff @(posedge i_clk or negedge rstb) begin
        if (!rstb) begin
            run_scan_valid_q <= 1'b0;
            run_accept_valid_q <= 1'b0;
            rxW_time_scan_q  <= '0;
            run1_len_scan_q  <= 8'd0;
                req_ones_scan_q  <= 8'd7;

            for (int c = 0; c < RUN_CHUNKS; c++) begin
                chunk_all_q[c]       <= 1'b0;
                chunk_hit_q[c]       <= 1'b0;
                chunk_prefix_q[c]    <= 8'd0;
                chunk_suffix_q[c]    <= 8'd0;
                chunk_hit_start_q[c] <= 8'd0;
            end
        end else begin
            run_scan_valid_q <= rx_valid_demap_q && sel_prbs_supported;
            run_accept_valid_q <= tx_accept_valid_demap_q && sel_prbs_supported;

            if (rx_valid_demap_q && sel_prbs_supported) begin
                rxW_time_scan_q <= rxW_time;
                run1_len_scan_q <= run1_len;
                req_ones_scan_q <= req_ones;

                for (int c = 0; c < RUN_CHUNKS; c++) begin
                    chunk_all_q[c]       <= chunk_all_w[c];
                    chunk_hit_q[c]       <= chunk_hit_w[c];
                    chunk_prefix_q[c]    <= chunk_prefix_w[c];
                    chunk_suffix_q[c]    <= chunk_suffix_w[c];
                    chunk_hit_start_q[c] <= chunk_hit_start_w[c];
                end
            end
        end
    end

    assign accept_ref_fifo_push = ACCEPT_GATED_SPARSE_TIMELINE && lock && run_accept_proc_q;
    assign accept_ref_fifo_push_do = accept_ref_fifo_push &&
                                     (int'(accept_ref_fifo_count) < ACCEPT_REF_FIFO_DEPTH_SAFE);
    assign accept_ref_fifo_pop = ACCEPT_GATED_SPARSE_TIMELINE && lock && run_proc_valid_q &&
                                 (accept_ref_fifo_count != '0);

    always_ff @(posedge i_clk or negedge rstb) begin
        if (!rstb) begin
            accept_ref_fifo_wr_ptr <= '0;
            accept_ref_fifo_rd_ptr <= '0;
            accept_ref_fifo_count  <= '0;
        end else if (selprbs_changed || !lock) begin
            accept_ref_fifo_wr_ptr <= '0;
            accept_ref_fifo_rd_ptr <= '0;
            accept_ref_fifo_count  <= '0;
        end else begin
            if (accept_ref_fifo_push_do) begin
                accept_ref_fifo_mem[accept_ref_fifo_wr_ptr] <= prbs64_0;
                accept_ref_fifo_wr_ptr <= accept_ref_fifo_ptr_inc(accept_ref_fifo_wr_ptr);
            end

            if (accept_ref_fifo_pop) begin
                accept_ref_fifo_rd_ptr <= accept_ref_fifo_ptr_inc(accept_ref_fifo_rd_ptr);
            end

            unique case ({accept_ref_fifo_push_do, accept_ref_fifo_pop})
                2'b10: accept_ref_fifo_count <= accept_ref_fifo_count + 1'b1;
                2'b01: accept_ref_fifo_count <= accept_ref_fifo_count - 1'b1;
                default: accept_ref_fifo_count <= accept_ref_fifo_count;
            endcase
        end
    end

    always_comb begin
        logic [7:0] r;
        logic [8:0] chunk_base;

        r             = run1_len_scan_q;
        hit_now       = 1'b0;
        hit_abs_now   = 9'd0;
        run1_len_next = run1_len_scan_q;

        for (int c = 0; c < RUN_CHUNKS; c++) begin
            chunk_base = 9'd128 + (c * RUN_CHUNK_W);

            if (!hit_now &&
                (r < req_ones_scan_q) &&
                (({1'b0, r} + {1'b0, chunk_prefix_q[c]}) >= {1'b0, req_ones_scan_q})) begin
                // rxW_aligned indexes {rx_hist2, rx_hist1, current_frame}; the
                // current frame starts at absolute offset 128. A run can begin
                // in rx_hist1 when it crosses a frame boundary.
                hit_now     = 1'b1;
                hit_abs_now = chunk_base - {1'b0, r};
            end else if (!hit_now && chunk_hit_q[c]) begin
                hit_now     = 1'b1;
                hit_abs_now = chunk_base + {1'b0, chunk_hit_start_q[c]};
            end

            if (chunk_all_q[c]) begin
                if (r > 8'd223) r = 8'hFF;
                else            r = r + 8'd32;
            end else begin
                r = chunk_suffix_q[c];
            end
        end

        run1_len_next = r;
    end

    always_comb begin
        hit_in_current_frame    = hit_now && (hit_abs_now >= 9'd128);
        hit_offset_now          = hit_abs_now[6:0];
        bits_to_next_frame_now  = 9'd64 - {2'b00, hit_offset_now};
        state_after_hit_frame_w = advance_state_bits(
            runstart_state(sel_prbs_chk),
            sel_prbs_chk,
            bits_to_next_frame_now
        );
    end

    generate
        if (PIPELINE_RUN_DETECT) begin : GEN_RUN_DETECT_PIPE
            always_ff @(posedge i_clk or negedge rstb) begin
                if (!rstb) begin
                    run_proc_valid_q              <= 1'b0;
                    run_accept_proc_q             <= 1'b0;
                    rxW_time_proc_q               <= '0;
                    run1_len_next_proc_q          <= 8'd0;
                    hit_proc_q                    <= 1'b0;
                    hit_abs_proc_q                <= 9'd0;
                    hit_in_current_frame_proc_q   <= 1'b0;
                    state_after_hit_frame_proc_q  <= PRBS7_RUNSTART_STATE;
                end else if (selprbs_changed) begin
                    run_proc_valid_q              <= 1'b0;
                    run_accept_proc_q             <= 1'b0;
                    rxW_time_proc_q               <= '0;
                    run1_len_next_proc_q          <= 8'd0;
                    hit_proc_q                    <= 1'b0;
                    hit_abs_proc_q                <= 9'd0;
                    hit_in_current_frame_proc_q   <= 1'b0;
                    state_after_hit_frame_proc_q  <= PRBS7_RUNSTART_STATE;
                end else begin
                    run_proc_valid_q  <= run_scan_valid_q;
                    run_accept_proc_q <= run_accept_valid_q;

                    if (run_scan_valid_q) begin
                        rxW_time_proc_q              <= rxW_time_scan_q;
                        run1_len_next_proc_q         <= run1_len_next;
                        hit_proc_q                   <= hit_now;
                        hit_abs_proc_q               <= hit_abs_now;
                        hit_in_current_frame_proc_q  <= hit_in_current_frame;
                        state_after_hit_frame_proc_q <= state_after_hit_frame_w;
                    end else begin
                        hit_proc_q           <= 1'b0;
                        run1_len_next_proc_q <= run1_len_scan_q;
                    end
                end
            end
        end else begin : GEN_RUN_DETECT_DIRECT
            assign run_proc_valid_q             = run_scan_valid_q;
            assign run_accept_proc_q            = run_accept_valid_q;
            assign rxW_time_proc_q              = rxW_time_scan_q;
            assign run1_len_next_proc_q         = run1_len_next;
            assign hit_proc_q                   = hit_now;
            assign hit_abs_proc_q               = hit_abs_now;
            assign hit_in_current_frame_proc_q  = hit_in_current_frame;
            assign state_after_hit_frame_proc_q = state_after_hit_frame_w;
        end
    endgenerate

    // 3-frame history + reframing.
    logic [63:0]  rx_hist1, rx_hist2;
    logic [8:0]   align_abs;
    logic [7:0]   align_phase;
    logic [63:0]  rxW_aligned;

    always_comb begin
        int idx;

        rxW_aligned = '0;
        for (int j = 0; j < 64; j++) begin
            idx = int'(align_abs) + j;
            if (idx < 64)           rxW_aligned[j] = rx_hist2[idx];
            else if (idx < 128)     rxW_aligned[j] = rx_hist1[idx - 64];
            else if (idx < 192)     rxW_aligned[j] = rxW_time_proc_q[idx - 128];
            else                    rxW_aligned[j] = 1'b0;
        end
    end

    always_comb begin
        align_phase = {2'b00, align_abs[5:0]};
        best_slip   = align_phase;
    end

    logic [63:0]  err_vec;
    logic [8:0]   err_now;

    always_comb begin
        err_vec = rxW_aligned ^ expW_raw;
        err_now = popcount64(err_vec);
    end

    typedef enum logic [1:0] {
        ST_WAIT_RUN = 2'd0,
        ST_FIRST    = 2'd1,
        ST_CONFIRM  = 2'd2,
        ST_LOCK     = 2'd3
    } st_t;

    st_t st;

    logic [CONFIRM_CNT_W-1:0] confirm_cnt;
    logic [BAD_STREAK_W-1:0]  bad_streak;
    logic [BAD_STREAK_W-1:0]  bad_streak_next;

    assign selprbs_changed = (sel_q != sel_prbs_sync);

    always_comb begin
        if (int'(err_now) > UNLOCK_BAD_TH_SAFE) begin
            if (int'(bad_streak) < UNLOCK_TH_SAFE) bad_streak_next = bad_streak + 1'b1;
            else                                    bad_streak_next = bad_streak;
        end else begin
            bad_streak_next = '0;
        end
    end

    always_ff @(posedge i_clk or negedge rstb) begin
        if (!rstb) sel_q <= 2'b11;
        else       sel_q <= sel_prbs_sync;
    end

    always_ff @(posedge i_clk or negedge rstb) begin
        if (!rstb) begin
            st <= ST_WAIT_RUN;
            lock <= 1'b0;

            bit_cnt_seen_total <= '0;

            bit_cnt       <= '0;
            err_cnt       <= '0;
            bit_cnt_total <= '0;
            err_cnt_total <= '0;

            err_popcnt <= 9'd0;

            run1_len   <= 8'd0;
            rx_hist1   <= '0;
            rx_hist2   <= '0;
            align_abs  <= 9'd0;

            confirm_cnt<= '0;
            bad_streak <= '0;

            state0     <= PRBS7_RUNSTART_STATE;

        end else if (selprbs_changed) begin
            st <= ST_WAIT_RUN;
            lock <= 1'b0;

            bit_cnt_seen_total <= '0;

            bit_cnt       <= '0;
            err_cnt       <= '0;
            bit_cnt_total <= '0;
            err_cnt_total <= '0;

            err_popcnt <= 9'd0;

            run1_len   <= 8'd0;
            rx_hist1   <= '0;
            rx_hist2   <= '0;
            align_abs  <= 9'd0;

            confirm_cnt<= '0;
            bad_streak <= '0;

            state0     <= PRBS7_RUNSTART_STATE;

        end else if (!run_proc_valid_q) begin
            // Sparse MLSD output can deassert rx_valid while the TX PRBS keeps
            // advancing. Do not consume a PRBS frame for every raw clock; only
            // advance when the detector accepted a frame that can later produce
            // a valid recovered 64b word.
            if ((st != ST_WAIT_RUN) &&
                (!ACCEPT_GATED_SPARSE_TIMELINE || run_accept_proc_q)) begin
                state0 <= state1_w;
            end
        end else begin
            bit_cnt_seen_total <= bit_cnt_seen_total + {{(BITCNT_W-9){1'b0}}, PAM4_W9};

            rx_hist2 <= rx_hist1;
            rx_hist1 <= rxW_time_proc_q;

            run1_len <= run1_len_next_proc_q;

            unique case (st)
                ST_WAIT_RUN: begin
                    lock       <= 1'b0;
                    err_popcnt <= 9'd0;

                    bit_cnt    <= '0;
                    err_cnt    <= '0;

                    confirm_cnt<= '0;
                    bad_streak <= '0;

                    state0 <= PRBS7_RUNSTART_STATE;

                    if (hit_proc_q) begin
                        if (hit_in_current_frame_proc_q) begin
                            // Sparse-valid MLSD frames are not adjacent in time,
                            // so do not build the first compare window across
                            // two valid frames. Use the next valid frame as a
                            // whole 64-bit block and pre-advance the PRBS state
                            // from the detected run to that frame boundary.
                            align_abs <= 9'd128;
                            state0    <= state_after_hit_frame_proc_q;
                        end else begin
                            // Full-rate fallback for runs crossing a valid-frame
                            // boundary.
                            align_abs <= hit_abs_proc_q - 9'd64;
                            state0    <= runstart_state(sel_prbs_chk);
                        end
                        st <= ST_FIRST;
                    end
                end

                ST_FIRST: begin
                    lock       <= 1'b0;
                    err_popcnt <= err_now;

                    if (int'(err_now) <= PASS_ERR_MAX_SAFE) begin
                        state0 <= state1_w;

                        if (ACC_CONFIRM_FRAMES_SAFE <= 1) begin
                            st   <= ST_LOCK;
                            lock <= 1'b1;

                            bit_cnt <= '0;
                            err_cnt <= '0;

                            confirm_cnt <= '0;
                            bad_streak  <= '0;
                        end else begin
                            st          <= ST_CONFIRM;
                            confirm_cnt <= 'd1;
                            bad_streak  <= '0;
                        end
                    end else begin
                        st          <= ST_WAIT_RUN;
                        lock        <= 1'b0;
                        run1_len    <= 8'd0;
                        confirm_cnt <= '0;
                        bad_streak  <= '0;
                        state0      <= PRBS7_RUNSTART_STATE;
                    end
                end

                ST_CONFIRM: begin
                    lock       <= 1'b0;
                    err_popcnt <= err_now;

                    if (int'(err_now) <= PASS_ERR_MAX_SAFE) begin
                        state0 <= state1_w;

                        if ((int'(confirm_cnt) + 1) >= ACC_CONFIRM_FRAMES_SAFE) begin
                            st   <= ST_LOCK;
                            lock <= 1'b1;

                            bit_cnt <= '0;
                            err_cnt <= '0;

                            confirm_cnt <= '0;
                            bad_streak  <= '0;
                        end else begin
                            confirm_cnt <= confirm_cnt + 1'b1;
                        end
                    end else begin
                        st          <= ST_WAIT_RUN;
                        lock        <= 1'b0;
                        run1_len    <= 8'd0;
                        confirm_cnt <= '0;
                        bad_streak  <= '0;
                        state0      <= PRBS7_RUNSTART_STATE;
                    end
                end

                ST_LOCK: begin
                    lock       <= 1'b1;
                    err_popcnt <= err_now;

                    if (!ACCEPT_GATED_SPARSE_TIMELINE ||
                        !accept_ref_fifo_has_ref ||
                        run_accept_proc_q) begin
                        state0 <= state1_w;
                    end

                    bit_cnt <= bit_cnt + {{(BITCNT_W-9){1'b0}}, PAM4_W9};
                    err_cnt <= err_cnt + {{(ERRCNT_W-9){1'b0}}, err_now};

                    bit_cnt_total <= bit_cnt_total + {{(BITCNT_W-9){1'b0}}, PAM4_W9};
                    err_cnt_total <= err_cnt_total + {{(ERRCNT_W-9){1'b0}}, err_now};

                    bad_streak <= bad_streak_next;

                    if (int'(bad_streak_next) >= UNLOCK_TH_SAFE) begin
                        st          <= ST_WAIT_RUN;
                        lock        <= 1'b0;
                        run1_len    <= 8'd0;
                        confirm_cnt <= '0;
                        bad_streak  <= '0;
                        state0      <= PRBS7_RUNSTART_STATE;
                    end
                end

                default: begin
                    st <= ST_WAIT_RUN;
                    lock <= 1'b0;

                    bit_cnt <= '0;
                    err_cnt <= '0;

                    err_popcnt <= 9'd0;
                    run1_len   <= 8'd0;
                    confirm_cnt<= '0;
                    bad_streak <= '0;
                    state0     <= PRBS7_RUNSTART_STATE;
                end
            endcase
        end
    end

    always_comb begin
        rxW_aligned128_dbg = {64'd0, rxW_aligned};
        expW_raw128_dbg    = {64'd0, expW_raw};
    end

endmodule
