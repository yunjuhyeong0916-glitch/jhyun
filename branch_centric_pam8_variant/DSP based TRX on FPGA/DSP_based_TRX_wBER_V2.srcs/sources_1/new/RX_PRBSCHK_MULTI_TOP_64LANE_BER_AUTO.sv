`timescale 1ns/1ps

module RX_PRBSCHK_MULTI_TOP_64LANE_BER_AUTO #(
    parameter int BITCNT_W = 48,
    parameter int ERRCNT_W = 48,

    // Phase lock / unlock knobs
    parameter int ACC_CONFIRM_FRAMES = 2,
    parameter int PASS_ERR_MAX       = 0,
    parameter int UNLOCK_BAD_TH      = 8,
    parameter int UNLOCK_TH          = 2,

    // PRBS run-start states
    parameter logic [30:0] PRBS7_RUNSTART_STATE  = 31'h0000_007F,
    parameter logic [30:0] PRBS15_RUNSTART_STATE = 31'h0000_7FFF,
    parameter logic [30:0] PRBS23_RUNSTART_STATE = 31'h007F_FFFF,
    parameter logic [30:0] PRBS31_RUNSTART_STATE = 31'h7FFF_FFFF,

    // Optional: if RX bit packing order is reversed in time inside each frame
    parameter bit RX_TIME_REVERSED = 1'b0,

    // Embedded thresholds
    parameter logic signed [7:0] THR_NRZ = 8'sd0,

    parameter logic signed [7:0] THR4_0  = -8'sd85,
    parameter logic signed [7:0] THR4_1  =  8'sd0,
    parameter logic signed [7:0] THR4_2  =  8'sd85,

    parameter logic signed [7:0] THR8_0  = -8'sd108,
    parameter logic signed [7:0] THR8_1  = -8'sd72,
    parameter logic signed [7:0] THR8_2  = -8'sd36,
    parameter logic signed [7:0] THR8_3  =  8'sd0,
    parameter logic signed [7:0] THR8_4  =  8'sd36,
    parameter logic signed [7:0] THR8_5  =  8'sd72,
    parameter logic signed [7:0] THR8_6  =  8'sd108
)(
    input  logic                 rstb,
    input  logic                 i_clk,

    input  logic [1:0]           sel_prbs,
    input  logic [1:0]           mode,
    input  logic signed [7:0]    cfg_thr_nrz,
    input  logic signed [7:0]    cfg_thr4_0,
    input  logic signed [7:0]    cfg_thr4_1,
    input  logic signed [7:0]    cfg_thr4_2,
    input  logic signed [7:0]    cfg_thr8_0,
    input  logic signed [7:0]    cfg_thr8_1,
    input  logic signed [7:0]    cfg_thr8_2,
    input  logic signed [7:0]    cfg_thr8_3,
    input  logic signed [7:0]    cfg_thr8_4,
    input  logic signed [7:0]    cfg_thr8_5,
    input  logic signed [7:0]    cfg_thr8_6,
    input  logic                 cfg_thr_en,

    input  logic [511:0]         rx_din_flat,

    output logic                 lock,

    // ALL OBSERVED BITS (includes pre-lock)
    output logic [BITCNT_W-1:0]  bit_cnt_seen_total,

    // STREAK: current continuous lock section only
    output logic [BITCNT_W-1:0]  bit_cnt,
    output logic [ERRCNT_W-1:0]  err_cnt,

    // TOTAL: accumulated across all lock sections since reset / mode change / prbs change
    output logic [BITCNT_W-1:0]  bit_cnt_total,
    output logic [ERRCNT_W-1:0]  err_cnt_total,

    output logic [8:0]           err_popcnt,
    output logic [7:0]           best_slip,

    // RAW demap outputs
    output logic [63:0]          rx_bits64_raw,
    output logic [127:0]         rx_bits128_raw,
    output logic [191:0]         rx_bits192_raw,

    // Expected PRBS raw outputs
    output logic [63:0]          exp64,
    output logic [127:0]         exp128,
    output logic [191:0]         exp192,

    // DEBUG (ILA): final compare signals split by mode
    output logic [63:0]          rxW_aligned64_dbg,
    output logic [127:0]         rxW_aligned128_dbg,
    output logic [191:0]         rxW_aligned192_dbg,

    output logic [63:0]          expW_raw64_dbg,
    output logic [127:0]         expW_raw128_dbg,
    output logic [191:0]         expW_raw192_dbg
);

    localparam int ACC_CONFIRM_FRAMES_SAFE = (ACC_CONFIRM_FRAMES < 1) ? 1 : ACC_CONFIRM_FRAMES;
    localparam int UNLOCK_TH_SAFE          = (UNLOCK_TH < 1) ? 1 : UNLOCK_TH;
    localparam int PASS_ERR_MAX_SAFE       = (PASS_ERR_MAX < 0) ? 0 : PASS_ERR_MAX;
    localparam int UNLOCK_BAD_TH_SAFE      = (UNLOCK_BAD_TH < 0) ? 0 : UNLOCK_BAD_TH;
    localparam int CONFIRM_CNT_W           = (ACC_CONFIRM_FRAMES_SAFE <= 1) ? 1 : $clog2(ACC_CONFIRM_FRAMES_SAFE + 1);
    localparam int BAD_STREAK_W            = (UNLOCK_TH_SAFE <= 1) ? 1 : $clog2(UNLOCK_TH_SAFE + 1);

    initial begin
        if (ACC_CONFIRM_FRAMES < 1) $warning("ACC_CONFIRM_FRAMES < 1. Forced to 1 internally.");
        if (UNLOCK_TH < 1)          $warning("UNLOCK_TH < 1. Forced to 1 internally.");
        if (PASS_ERR_MAX < 0)       $warning("PASS_ERR_MAX < 0. Forced to 0 internally.");
        if (UNLOCK_BAD_TH < 0)      $warning("UNLOCK_BAD_TH < 0. Forced to 0 internally.");
    end

    // 1) RX Gray demap
    RX_GRAY_DEMAP_64LANE_8B_CFG #(
        .THR_NRZ (THR_NRZ),
        .THR4_0  (THR4_0),
        .THR4_1  (THR4_1),
        .THR4_2  (THR4_2),
        .THR8_0  (THR8_0),
        .THR8_1  (THR8_1),
        .THR8_2  (THR8_2),
        .THR8_3  (THR8_3),
        .THR8_4  (THR8_4),
        .THR8_5  (THR8_5),
        .THR8_6  (THR8_6)
    ) u_demap (
        .cfg_thr_nrz  (cfg_thr_nrz),
        .cfg_thr4_0   (cfg_thr4_0),
        .cfg_thr4_1   (cfg_thr4_1),
        .cfg_thr4_2   (cfg_thr4_2),
        .cfg_thr8_0   (cfg_thr8_0),
        .cfg_thr8_1   (cfg_thr8_1),
        .cfg_thr8_2   (cfg_thr8_2),
        .cfg_thr8_3   (cfg_thr8_3),
        .cfg_thr8_4   (cfg_thr8_4),
        .cfg_thr8_5   (cfg_thr8_5),
        .cfg_thr8_6   (cfg_thr8_6),
        .cfg_thr_en   (cfg_thr_en),
        .mode         (mode),
        .rx_din_flat  (rx_din_flat),
        .bits64       (rx_bits64_raw),
        .bits128      (rx_bits128_raw),
        .bits192      (rx_bits192_raw)
    );

    // 2) Expected PRBS generator chain
    logic [30:0] state0;
    logic [30:0] state1_w, state2_w, state3_w;

    logic [63:0] prbs64_0, prbs64_1, prbs64_2;

    prbsgen_64b u_prbs64_0 (
        .rstb        (rstb),
        .i_clk       (i_clk),
        .sel_prbs    (sel_prbs),
        .ext_ptrn_en (1'b0),
        .ext_ptrn    (64'h0),
        .state_in_en (1'b1),
        .state_in    (state0),
        .state_out   (state1_w),
        .dout        (prbs64_0)
    );

    prbsgen_64b u_prbs64_1 (
        .rstb        (rstb),
        .i_clk       (i_clk),
        .sel_prbs    (sel_prbs),
        .ext_ptrn_en (1'b0),
        .ext_ptrn    (64'h0),
        .state_in_en (1'b1),
        .state_in    (state1_w),
        .state_out   (state2_w),
        .dout        (prbs64_1)
    );

    prbsgen_64b u_prbs64_2 (
        .rstb        (rstb),
        .i_clk       (i_clk),
        .sel_prbs    (sel_prbs),
        .ext_ptrn_en (1'b0),
        .ext_ptrn    (64'h0),
        .state_in_en (1'b1),
        .state_in    (state2_w),
        .state_out   (state3_w),
        .dout        (prbs64_2)
    );

    assign exp64  = prbs64_0;
    assign exp128 = {prbs64_1, prbs64_0};
    assign exp192 = {prbs64_2, prbs64_1, prbs64_0};

    // 3) Select W + raw windows
    logic [8:0]   W9;
    logic [191:0] rxW_raw, rxW_time, expW_raw;

    always_comb begin
        W9       = 9'd64;
        rxW_raw  = '0;
        expW_raw = '0;

        unique case (mode)
            2'b00: begin
                W9 = 9'd64;
                rxW_raw[63:0]   = rx_bits64_raw;
                expW_raw[63:0]  = exp64;
            end
            2'b01: begin
                W9 = 9'd128;
                rxW_raw[127:0]  = rx_bits128_raw;
                expW_raw[127:0] = exp128;
            end
            2'b10: begin
                W9 = 9'd192;
                rxW_raw[191:0]  = rx_bits192_raw;
                expW_raw[191:0] = exp192;
            end
            default: begin
                W9 = 9'd64;
                rxW_raw[63:0]   = rx_bits64_raw;
                expW_raw[63:0]  = exp64;
            end
        endcase
    end

    always_comb begin
        rxW_time = '0;
        unique case (mode)
            2'b00: begin
                for (int i = 0; i < 64; i++) begin
                    rxW_time[i] = RX_TIME_REVERSED ? rxW_raw[63-i] : rxW_raw[i];
                end
            end
            2'b01: begin
                for (int i = 0; i < 128; i++) begin
                    rxW_time[i] = RX_TIME_REVERSED ? rxW_raw[127-i] : rxW_raw[i];
                end
            end
            2'b10: begin
                for (int i = 0; i < 192; i++) begin
                    rxW_time[i] = RX_TIME_REVERSED ? rxW_raw[191-i] : rxW_raw[i];
                end
            end
            default: begin
                for (int i = 0; i < 64; i++) begin
                    rxW_time[i] = RX_TIME_REVERSED ? rxW_raw[63-i] : rxW_raw[i];
                end
            end
        endcase
    end

    // Helpers
    function automatic logic [8:0] popcount64(input logic [63:0] x);
        logic [8:0] c;
        begin
            c = 9'd0;
            for (int i = 0; i < 64; i++) c = c + {{8{1'b0}}, x[i]};
            popcount64 = c;
        end
    endfunction

    function automatic logic [8:0] popcount128(input logic [127:0] x);
        logic [8:0] c;
        begin
            c = 9'd0;
            for (int i = 0; i < 128; i++) c = c + {{8{1'b0}}, x[i]};
            popcount128 = c;
        end
    endfunction

    function automatic logic [8:0] popcount192(input logic [191:0] x);
        logic [8:0] c;
        begin
            c = 9'd0;
            for (int i = 0; i < 192; i++) c = c + {{8{1'b0}}, x[i]};
            popcount192 = c;
        end
    endfunction

    function automatic logic [30:0] runstart_state(input logic [1:0] s);
        begin
            unique case (s)
                2'b00:   runstart_state = PRBS7_RUNSTART_STATE;
                2'b01:   runstart_state = PRBS15_RUNSTART_STATE;
                2'b10:   runstart_state = PRBS23_RUNSTART_STATE;
                default: runstart_state = PRBS31_RUNSTART_STATE;
            endcase
        end
    endfunction

    function automatic logic [30:0] advance_state0_by_mode(
        input logic [1:0]  m,
        input logic [30:0] s1,
        input logic [30:0] s2,
        input logic [30:0] s3
    );
        begin
            unique case (m)
                2'b00:   advance_state0_by_mode = s1;
                2'b01:   advance_state0_by_mode = s2;
                2'b10:   advance_state0_by_mode = s3;
                default: advance_state0_by_mode = s1;
            endcase
        end
    endfunction

    // 4) RUN detect
    logic [7:0] req_ones;
    logic [7:0] run1_len, run1_len_next;
    logic       hit_now;
    logic [8:0] hit_abs_now;

    always_comb begin
        unique case (sel_prbs)
            2'b00:   req_ones = 8'd7;
            2'b01:   req_ones = 8'd15;
            2'b10:   req_ones = 8'd23;
            default: req_ones = 8'd31;
        endcase
    end

    always_comb begin
        logic [7:0] r;
        int abs_start;

        r           = run1_len;
        hit_now     = 1'b0;
        hit_abs_now = 9'd0;
        abs_start   = 0;

        unique case (mode)
            2'b00: begin
                for (int i = 0; i < 64; i++) begin
                    if (rxW_time[i]) begin
                        if (r != 8'hFF) r = r + 8'd1;
                    end else begin
                        r = 8'd0;
                    end

                    if (!hit_now && (r == req_ones)) begin
                        hit_now     = 1'b1;
                        abs_start   = 64 + i - int'(req_ones) + 1;
                        hit_abs_now = abs_start[8:0];
                    end
                end
            end
            2'b01: begin
                for (int i = 0; i < 128; i++) begin
                    if (rxW_time[i]) begin
                        if (r != 8'hFF) r = r + 8'd1;
                    end else begin
                        r = 8'd0;
                    end

                    if (!hit_now && (r == req_ones)) begin
                        hit_now     = 1'b1;
                        abs_start   = 128 + i - int'(req_ones) + 1;
                        hit_abs_now = abs_start[8:0];
                    end
                end
            end
            2'b10: begin
                for (int i = 0; i < 192; i++) begin
                    if (rxW_time[i]) begin
                        if (r != 8'hFF) r = r + 8'd1;
                    end else begin
                        r = 8'd0;
                    end

                    if (!hit_now && (r == req_ones)) begin
                        hit_now     = 1'b1;
                        abs_start   = 192 + i - int'(req_ones) + 1;
                        hit_abs_now = abs_start[8:0];
                    end
                end
            end
            default: begin
                for (int i = 0; i < 64; i++) begin
                    if (rxW_time[i]) begin
                        if (r != 8'hFF) r = r + 8'd1;
                    end else begin
                        r = 8'd0;
                    end

                    if (!hit_now && (r == req_ones)) begin
                        hit_now     = 1'b1;
                        abs_start   = 64 + i - int'(req_ones) + 1;
                        hit_abs_now = abs_start[8:0];
                    end
                end
            end
        endcase

        run1_len_next = r;
    end

    // 5) 3-frame history + reframing
    logic [191:0] rx_hist1, rx_hist2;
    logic [8:0]   align_abs;
    logic [8:0]   align_phase9;
    logic [191:0] rxW_aligned;

    always_comb begin
        int idx;
        rxW_aligned = '0;

        unique case (mode)
            2'b00: begin
                for (int j = 0; j < 64; j++) begin
                    idx = int'(align_abs) + j;
                    if (idx < 64)           rxW_aligned[j] = rx_hist2[idx];
                    else if (idx < 128)     rxW_aligned[j] = rx_hist1[idx - 64];
                    else if (idx < 192)     rxW_aligned[j] = rxW_time[idx - 128];
                    else                    rxW_aligned[j] = 1'b0;
                end
            end
            2'b01: begin
                for (int j = 0; j < 128; j++) begin
                    idx = int'(align_abs) + j;
                    if (idx < 128)          rxW_aligned[j] = rx_hist2[idx];
                    else if (idx < 256)     rxW_aligned[j] = rx_hist1[idx - 128];
                    else if (idx < 384)     rxW_aligned[j] = rxW_time[idx - 256];
                    else                    rxW_aligned[j] = 1'b0;
                end
            end
            2'b10: begin
                for (int j = 0; j < 192; j++) begin
                    idx = int'(align_abs) + j;
                    if (idx < 192)          rxW_aligned[j] = rx_hist2[idx];
                    else if (idx < 384)     rxW_aligned[j] = rx_hist1[idx - 192];
                    else if (idx < 576)     rxW_aligned[j] = rxW_time[idx - 384];
                    else                    rxW_aligned[j] = 1'b0;
                end
            end
            default: begin
                for (int j = 0; j < 64; j++) begin
                    idx = int'(align_abs) + j;
                    if (idx < 64)           rxW_aligned[j] = rx_hist2[idx];
                    else if (idx < 128)     rxW_aligned[j] = rx_hist1[idx - 64];
                    else if (idx < 192)     rxW_aligned[j] = rxW_time[idx - 128];
                    else                    rxW_aligned[j] = 1'b0;
                end
            end
        endcase
    end

    always_comb begin
        unique case (mode)
            2'b00:   align_phase9 = (align_abs >= 9'd64)  ? (align_abs - 9'd64)  : align_abs;
            2'b01:   align_phase9 = (align_abs >= 9'd128) ? (align_abs - 9'd128) : align_abs;
            2'b10:   align_phase9 = (align_abs >= 9'd192) ? (align_abs - 9'd192) : align_abs;
            default: align_phase9 = (align_abs >= 9'd64)  ? (align_abs - 9'd64)  : align_abs;
        endcase
        best_slip = align_phase9[7:0];
    end

    // 6) Compare
    logic [191:0] err_vec;
    logic [8:0]   err_now;

    always_comb begin
        err_vec = (rxW_aligned ^ expW_raw);

        unique case (mode)
            2'b00:   err_now = popcount64(err_vec[63:0]);
            2'b01:   err_now = popcount128(err_vec[127:0]);
            2'b10:   err_now = popcount192(err_vec[191:0]);
            default: err_now = popcount64(err_vec[63:0]);
        endcase
    end

    // 7) FSM
    typedef enum logic [1:0] {
        ST_WAIT_RUN = 2'd0,
        ST_FIRST    = 2'd1,
        ST_CONFIRM  = 2'd2,
        ST_LOCK     = 2'd3
    } st_t;

    st_t st;

    logic [1:0] mode_q, sel_q;
    logic       mode_changed, selprbs_changed;

    logic [CONFIRM_CNT_W-1:0] confirm_cnt;
    logic [BAD_STREAK_W-1:0]  bad_streak;
    logic [BAD_STREAK_W-1:0]  bad_streak_next;

    assign mode_changed    = (mode_q != mode);
    assign selprbs_changed = (sel_q  != sel_prbs);

    always_comb begin
        if (int'(err_now) > UNLOCK_BAD_TH_SAFE) begin
            if (int'(bad_streak) < UNLOCK_TH_SAFE) bad_streak_next = bad_streak + 1'b1;
            else                                    bad_streak_next = bad_streak;
        end else begin
            bad_streak_next = '0;
        end
    end

    always_ff @(posedge i_clk or negedge rstb) begin
        if (!rstb) begin
            mode_q <= 2'b00;
            sel_q  <= 2'b00;
        end else begin
            mode_q <= mode;
            sel_q  <= sel_prbs;
        end
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

            state0     <= 31'h7FFF_FFFF;

        end else if (mode_changed || selprbs_changed) begin
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

            state0     <= 31'h7FFF_FFFF;

        end else begin
            // Count every observed bit, including pre-lock time.
            bit_cnt_seen_total <= bit_cnt_seen_total + {{(BITCNT_W-9){1'b0}}, W9};

            rx_hist2 <= rx_hist1;
            rx_hist1 <= rxW_time;

            run1_len <= run1_len_next;

            unique case (st)

                ST_WAIT_RUN: begin
                    lock       <= 1'b0;
                    err_popcnt <= 9'd0;

                    bit_cnt    <= '0;
                    err_cnt    <= '0;

                    confirm_cnt<= '0;
                    bad_streak <= '0;

                    state0 <= 31'h7FFF_FFFF;

                    if (hit_now) begin
                        align_abs <= hit_abs_now;
                        state0    <= runstart_state(sel_prbs);
                        st        <= ST_FIRST;
                    end
                end

                ST_FIRST: begin
                    lock       <= 1'b0;
                    err_popcnt <= err_now;

                    if (int'(err_now) <= PASS_ERR_MAX_SAFE) begin
                        state0 <= advance_state0_by_mode(mode, state1_w, state2_w, state3_w);

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
                        state0      <= 31'h7FFF_FFFF;
                    end
                end

                ST_CONFIRM: begin
                    lock       <= 1'b0;
                    err_popcnt <= err_now;

                    if (int'(err_now) <= PASS_ERR_MAX_SAFE) begin
                        state0 <= advance_state0_by_mode(mode, state1_w, state2_w, state3_w);

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
                        state0      <= 31'h7FFF_FFFF;
                    end
                end

                ST_LOCK: begin
                    lock       <= 1'b1;
                    err_popcnt <= err_now;

                    state0 <= advance_state0_by_mode(mode, state1_w, state2_w, state3_w);

                    bit_cnt <= bit_cnt + {{(BITCNT_W-9){1'b0}}, W9};
                    err_cnt <= err_cnt + {{(ERRCNT_W-9){1'b0}}, err_now};

                    bit_cnt_total <= bit_cnt_total + {{(BITCNT_W-9){1'b0}}, W9};
                    err_cnt_total <= err_cnt_total + {{(ERRCNT_W-9){1'b0}}, err_now};

                    bad_streak <= bad_streak_next;

                    if (int'(bad_streak_next) >= UNLOCK_TH_SAFE) begin
                        st          <= ST_WAIT_RUN;
                        lock        <= 1'b0;
                        run1_len    <= 8'd0;
                        confirm_cnt <= '0;
                        bad_streak  <= '0;
                        state0      <= 31'h7FFF_FFFF;
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
                    state0     <= 31'h7FFF_FFFF;
                end
            endcase
        end
    end

    // DEBUG hookup: split outputs by mode
    always_comb begin
        rxW_aligned64_dbg   = '0;
        rxW_aligned128_dbg  = '0;
        rxW_aligned192_dbg  = '0;

        expW_raw64_dbg      = '0;
        expW_raw128_dbg     = '0;
        expW_raw192_dbg     = '0;

        unique case (mode)
            2'b00: begin
                rxW_aligned64_dbg  = rxW_aligned[63:0];
                expW_raw64_dbg     = expW_raw[63:0];
            end
            2'b01: begin
                rxW_aligned128_dbg = rxW_aligned[127:0];
                expW_raw128_dbg    = expW_raw[127:0];
            end
            2'b10: begin
                rxW_aligned192_dbg = rxW_aligned[191:0];
                expW_raw192_dbg    = expW_raw[191:0];
            end
            default: begin
                rxW_aligned64_dbg  = rxW_aligned[63:0];
                expW_raw64_dbg     = expW_raw[63:0];
            end
        endcase
    end

endmodule
