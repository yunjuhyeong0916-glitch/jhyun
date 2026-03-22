`timescale 1ns/1ps
// ============================================================================
// RX_PRBSCHK_LOCK_BER_TXMATCH_SUM_V2   (Vivado v2022.2 synth-friendly)
// - TX prbsgen_64b 정의와 1:1 매칭 (fb_left/step_left/out_msb/seed_of 동일)
// - 0 + 1^N + 0 패턴으로 lock (N=7/15/23/31)
// - lock 이후 전체 bit stream 합산 BER
// - Debug: prbs_aligned / prbs_valid_mask / prbs_valid_bits
// - Safety: mode/sel_prbs 변경 시 unlock + 카운터/상태 리셋
//
// IMPORTANT (Vivado OOC synth):
// - 모든 for-loop bound는 상수(8/16/24/32/64/128/192)만 사용
// - (expr)[8:0] 같은 문법 사용 금지 (Vivado가 싫어함) -> size cast 사용
// ============================================================================

module RX_PRBSCHK_LOCK_BER_TXMATCH_SUM_V2 #(
    parameter int TOTCNT_W = 48,
    parameter int ERRCNT_W = 48
)(
    input  logic        clk,
    input  logic        rstn,

    input  logic [1:0]  mode,
    input  logic [1:0]  sel_prbs,

    input  logic [63:0]   rx_bits64,
    input  logic [127:0]  rx_bits128,
    input  logic [191:0]  rx_bits192,

    output logic        locked,
    output logic        lock_pulse,

    output logic [TOTCNT_W-1:0] total_bits,
    output logic [ERRCNT_W-1:0] error_bits,

    output logic [191:0] prbs_aligned,
    output logic [191:0] prbs_valid_mask,
    output logic [8:0]   prbs_valid_bits
);

    // ============================================================
    // PRBS order N (run-detect)
    // ============================================================
    int N;
    always_comb begin
        unique case (sel_prbs)
            2'b00: N = 7;
            2'b01: N = 15;
            2'b10: N = 23;
            default: N = 31;
        endcase
    end

    // ============================================================
    // TX-matched PRBS primitives
    // ============================================================
    function automatic logic fb_left(input logic [30:0] st, input logic [1:0] m);
        case (m)
            2'b00: fb_left = st[6]  ^ st[5];
            2'b01: fb_left = st[14] ^ st[13];
            2'b10: fb_left = st[22] ^ st[17];
            default: fb_left = st[30] ^ st[27];
        endcase
    endfunction

    function automatic logic [30:0] step_left(input logic [30:0] st, input logic [1:0] m);
        logic fb;
        begin
            fb = fb_left(st, m);
            case (m)
                2'b00: step_left = {24'b0, st[5:0],  fb};
                2'b01: step_left = {16'b0, st[13:0], fb};
                2'b10: step_left = {8'b0,  st[21:0], fb};
                default: step_left = {st[29:0], fb};
            endcase
        end
    endfunction

    function automatic logic out_msb(input logic [30:0] st, input logic [1:0] m);
        case (m)
            2'b00: out_msb = st[6];
            2'b01: out_msb = st[14];
            2'b10: out_msb = st[22];
            default: out_msb = st[30];
        endcase
    endfunction

    function automatic logic [30:0] seed_of(input logic [1:0] m);
        case (m)
            2'b00: seed_of = 31'h0000_007F;
            2'b01: seed_of = 31'h0000_7FFF;
            2'b10: seed_of = 31'h007F_FFFF;
            default: seed_of = 31'h7FFF_FFFF;
        endcase
    endfunction

    // ============================================================
    // Constant-step advance helpers (NO runtime steps)
    // ============================================================
    function automatic logic [30:0] adv8 (input logic [30:0] st0, input logic [1:0] m);
        logic [30:0] st; int k;
        begin st = st0; for (k=0; k<8;  k++) st = step_left(st, m); adv8  = st; end
    endfunction

    function automatic logic [30:0] adv16(input logic [30:0] st0, input logic [1:0] m);
        logic [30:0] st; int k;
        begin st = st0; for (k=0; k<16; k++) st = step_left(st, m); adv16 = st; end
    endfunction

    function automatic logic [30:0] adv24(input logic [30:0] st0, input logic [1:0] m);
        logic [30:0] st; int k;
        begin st = st0; for (k=0; k<24; k++) st = step_left(st, m); adv24 = st; end
    endfunction

    function automatic logic [30:0] adv32(input logic [30:0] st0, input logic [1:0] m);
        logic [30:0] st; int k;
        begin st = st0; for (k=0; k<32; k++) st = step_left(st, m); adv32 = st; end
    endfunction

    // seed advanced by (N+1) => 8/16/24/32
    function automatic logic [30:0] seed_adv_Np1(input logic [1:0] m);
        logic [30:0] sd;
        begin
            sd = seed_of(m);
            case (m)
                2'b00: seed_adv_Np1 = adv8 (sd, m);   // 7+1
                2'b01: seed_adv_Np1 = adv16(sd, m);   // 15+1
                2'b10: seed_adv_Np1 = adv24(sd, m);   // 23+1
                default: seed_adv_Np1 = adv32(sd, m); // 31+1
            endcase
        end
    endfunction

    // ============================================================
    // popcount (constant bounds)
    // ============================================================
    function automatic int popcount_64(input logic [63:0] v);
        int s, i;
        begin s = 0; for (i=0; i<64;  i++) s += v[i]; popcount_64  = s; end
    endfunction

    function automatic int popcount_128(input logic [127:0] v);
        int s, i;
        begin s = 0; for (i=0; i<128; i++) s += v[i]; popcount_128 = s; end
    endfunction

    function automatic int popcount_192(input logic [191:0] v);
        int s, i;
        begin s = 0; for (i=0; i<192; i++) s += v[i]; popcount_192 = s; end
    endfunction

    // ============================================================
    // regs
    // ============================================================
    logic [30:0] prbs_state_q, prbs_state_d;
    int          run_len_q,    run_len_d;

    logic        locked_q,     locked_d;
    logic        lock_pulse_d;

    logic [TOTCNT_W-1:0] total_d;
    logic [ERRCNT_W-1:0] err_d;

    logic [191:0] prbs_aligned_d;
    logic [191:0] prbs_valid_mask_d;
    logic [8:0]   prbs_valid_bits_d;

    // cfg change detect
    logic [1:0] mode_q, sel_q;
    logic       cfg_changed;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            mode_q <= 2'b00;
            sel_q  <= 2'b11;
        end else begin
            mode_q <= mode;
            sel_q  <= sel_prbs;
        end
    end
    assign cfg_changed = (mode_q != mode) || (sel_q != sel_prbs);

    // ============================================================
    // main comb
    // ============================================================
    int  i;
    int  run_local;
    bit  found;
    int  found_j;
    int  start_idx;

    logic [30:0] st;
    logic [191:0] mism;

    always_comb begin
        // defaults
        prbs_state_d = prbs_state_q;
        run_len_d    = run_len_q;

        locked_d     = locked_q;
        lock_pulse_d = 1'b0;

        total_d      = total_bits;
        err_d        = error_bits;

        prbs_aligned_d    = '0;
        prbs_valid_mask_d = '0;
        prbs_valid_bits_d = 9'd0;

        mism = '0;

        // --------------------------------------------------------
        // cfg changed -> reset
        // --------------------------------------------------------
        if (cfg_changed) begin
            prbs_state_d = seed_of(sel_prbs);
            run_len_d    = 0;
            locked_d     = 1'b0;
            lock_pulse_d = 1'b0;
            total_d      = '0;
            err_d        = '0;
        end
        // --------------------------------------------------------
        // LOCKED: full-width compare
        // --------------------------------------------------------
        else if (locked_q) begin
            unique case (mode)
                2'b00: begin
                    st = prbs_state_q;
                    for (i=0; i<64; i++) begin
                        prbs_aligned_d[i]    = out_msb(st, sel_prbs);
                        prbs_valid_mask_d[i] = 1'b1;
                        mism[i]              = rx_bits64[i] ^ prbs_aligned_d[i];
                        st = step_left(st, sel_prbs);
                    end
                    prbs_state_d      = st;
                    total_d           = total_bits + 64;
                    err_d             = error_bits + popcount_64(mism[63:0]);
                    prbs_valid_bits_d = 9'd64;
                end

                2'b01: begin
                    st = prbs_state_q;
                    for (i=0; i<128; i++) begin
                        prbs_aligned_d[i]    = out_msb(st, sel_prbs);
                        prbs_valid_mask_d[i] = 1'b1;
                        mism[i]              = rx_bits128[i] ^ prbs_aligned_d[i];
                        st = step_left(st, sel_prbs);
                    end
                    prbs_state_d      = st;
                    total_d           = total_bits + 128;
                    err_d             = error_bits + popcount_128(mism[127:0]);
                    prbs_valid_bits_d = 9'd128;
                end

                default: begin
                    st = prbs_state_q;
                    for (i=0; i<192; i++) begin
                        prbs_aligned_d[i]    = out_msb(st, sel_prbs);
                        prbs_valid_mask_d[i] = 1'b1;
                        mism[i]              = rx_bits192[i] ^ prbs_aligned_d[i];
                        st = step_left(st, sel_prbs);
                    end
                    prbs_state_d      = st;
                    total_d           = total_bits + 192;
                    err_d             = error_bits + popcount_192(mism[191:0]);
                    prbs_valid_bits_d = 9'd192;
                end
            endcase
        end
        // --------------------------------------------------------
        // UNLOCKED: scan for 0 + 1^N + 0, then align+compare from found_j+1
        // --------------------------------------------------------
        else begin
            found     = 1'b0;
            found_j   = -1;
            run_local = run_len_q;

            unique case (mode)

                // =======================
                // NRZ: 64
                // =======================
                2'b00: begin
                    for (i=0; i<64; i++) begin
                        if (!found) begin
                            if (rx_bits64[i]) run_local++;
                            else begin
                                if (run_local == N) begin
                                    found   = 1'b1;
                                    found_j = i;
                                    run_local = 0;
                                end else begin
                                    run_local = 0;
                                end
                            end
                        end
                    end
                    run_len_d = run_local;

                    if (found) begin
                        start_idx    = found_j + 1;
                        prbs_state_d = seed_adv_Np1(sel_prbs);
                        st           = prbs_state_d;

                        for (i=0; i<64; i++) begin
                            if (i >= start_idx) begin
                                prbs_aligned_d[i]    = out_msb(st, sel_prbs);
                                prbs_valid_mask_d[i] = 1'b1;
                                mism[i]              = rx_bits64[i] ^ prbs_aligned_d[i];
                                st = step_left(st, sel_prbs);
                            end
                        end

                        prbs_state_d      = st;
                        total_d           = total_bits + (64 - start_idx);
                        err_d             = error_bits + popcount_64(mism[63:0]);
                        prbs_valid_bits_d = 9'($unsigned(64 - start_idx));

                        locked_d     = 1'b1;
                        lock_pulse_d = 1'b1;
                        run_len_d    = 0;
                    end
                end

                // =======================
                // PAM4: 128
                // =======================
                2'b01: begin
                    for (i=0; i<128; i++) begin
                        if (!found) begin
                            if (rx_bits128[i]) run_local++;
                            else begin
                                if (run_local == N) begin
                                    found   = 1'b1;
                                    found_j = i;
                                    run_local = 0;
                                end else begin
                                    run_local = 0;
                                end
                            end
                        end
                    end
                    run_len_d = run_local;

                    if (found) begin
                        start_idx    = found_j + 1;
                        prbs_state_d = seed_adv_Np1(sel_prbs);
                        st           = prbs_state_d;

                        for (i=0; i<128; i++) begin
                            if (i >= start_idx) begin
                                prbs_aligned_d[i]    = out_msb(st, sel_prbs);
                                prbs_valid_mask_d[i] = 1'b1;
                                mism[i]              = rx_bits128[i] ^ prbs_aligned_d[i];
                                st = step_left(st, sel_prbs);
                            end
                        end

                        prbs_state_d      = st;
                        total_d           = total_bits + (128 - start_idx);
                        err_d             = error_bits + popcount_128(mism[127:0]);
                        prbs_valid_bits_d = 9'($unsigned(128 - start_idx));

                        locked_d     = 1'b1;
                        lock_pulse_d = 1'b1;
                        run_len_d    = 0;
                    end
                end

                // =======================
                // PAM8: 192
                // =======================
                default: begin
                    for (i=0; i<192; i++) begin
                        if (!found) begin
                            if (rx_bits192[i]) run_local++;
                            else begin
                                if (run_local == N) begin
                                    found   = 1'b1;
                                    found_j = i;
                                    run_local = 0;
                                end else begin
                                    run_local = 0;
                                end
                            end
                        end
                    end
                    run_len_d = run_local;

                    if (found) begin
                        start_idx    = found_j + 1;
                        prbs_state_d = seed_adv_Np1(sel_prbs);
                        st           = prbs_state_d;

                        for (i=0; i<192; i++) begin
                            if (i >= start_idx) begin
                                prbs_aligned_d[i]    = out_msb(st, sel_prbs);
                                prbs_valid_mask_d[i] = 1'b1;
                                mism[i]              = rx_bits192[i] ^ prbs_aligned_d[i];
                                st = step_left(st, sel_prbs);
                            end
                        end

                        prbs_state_d      = st;
                        total_d           = total_bits + (192 - start_idx);
                        err_d             = error_bits + popcount_192(mism[191:0]);
                        prbs_valid_bits_d = 9'($unsigned(192 - start_idx));

                        locked_d     = 1'b1;
                        lock_pulse_d = 1'b1;
                        run_len_d    = 0;
                    end
                end
            endcase
        end
    end

    // ============================================================
    // sequential
    // ============================================================
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            prbs_state_q    <= 31'h7FFF_FFFF;
            run_len_q       <= 0;

            locked_q        <= 1'b0;
            lock_pulse      <= 1'b0;

            total_bits      <= '0;
            error_bits      <= '0;

            prbs_aligned    <= '0;
            prbs_valid_mask <= '0;
            prbs_valid_bits <= 9'd0;
        end else begin
            prbs_state_q    <= prbs_state_d;
            run_len_q       <= run_len_d;

            locked_q        <= locked_d;
            lock_pulse      <= lock_pulse_d;

            total_bits      <= total_d;
            error_bits      <= err_d;

            prbs_aligned    <= prbs_aligned_d;
            prbs_valid_mask <= prbs_valid_mask_d;
            prbs_valid_bits <= prbs_valid_bits_d;
        end
    end

    assign locked = locked_q;

endmodule