`timescale 1ns/1ps

module cmp_hybrid_rs_mlsd_core_lane_8b #(
    parameter int TB       = 40,
    parameter int MET_W    = 16,
    parameter int PR_SHIFT = 2,

    parameter logic signed [7:0] P0 = 8'sd1,
    parameter logic signed [7:0] P1 = 8'sd2,
    parameter logic signed [7:0] P2 = 8'sd1,

    parameter logic signed [7:0] NRZ_NEG = -8'sd127,
    parameter logic signed [7:0] NRZ_POS =  8'sd127,

    parameter logic signed [7:0] PAM4_L0 = -8'sd96,
    parameter logic signed [7:0] PAM4_L1 = -8'sd32,
    parameter logic signed [7:0] PAM4_L2 =  8'sd32,
    parameter logic signed [7:0] PAM4_L3 =  8'sd96,

    parameter logic signed [7:0] PAM8_L0 = -8'sd112,
    parameter logic signed [7:0] PAM8_L1 = -8'sd80,
    parameter logic signed [7:0] PAM8_L2 = -8'sd48,
    parameter logic signed [7:0] PAM8_L3 = -8'sd16,
    parameter logic signed [7:0] PAM8_L4 =  8'sd16,
    parameter logic signed [7:0] PAM8_L5 =  8'sd48,
    parameter logic signed [7:0] PAM8_L6 =  8'sd80,
    parameter logic signed [7:0] PAM8_L7 =  8'sd112
)(
    input  logic               clk,
    input  logic               rst_n,
    input  logic               in_valid,
    input  logic [1:0]         mode,
    input  logic [1:0]         ch_case_sel,
    input  logic [3:0]         K_cfg,
    input  logic signed [7:0]  z8,
    output logic               out_valid,
    output logic signed [7:0]  a_hat8,
    output logic [7:0]         cand_count,
    output logic               ps_expand_hit,
    output logic               ns_expand_hit
);

    localparam int NS_MAX = 8;
    localparam int M_MAX  = 8;
    localparam logic [MET_W-1:0] INF = '1;

    logic [3:0] M_cfg;
    logic [6:0] NS_cfg;
    logic [2:0] ps_keep_base;
    logic [2:0] ns_keep_base;
    logic [2:0] ps_keep_max;
    logic [2:0] ns_keep_max;
    logic [2:0] ps_keep_dyn;
    logic [2:0] ns_keep_dyn;
    logic [MET_W-1:0] ambig_gap_ps_th;
    logic [MET_W-1:0] ambig_gap_ns_th;

    logic signed [7:0] sym_lut [0:M_MAX-1];

    logic [MET_W-1:0] pm      [0:NS_MAX-1];
    logic [MET_W-1:0] pm_n    [0:NS_MAX-1];
    logic [MET_W-1:0] pm_norm [0:NS_MAX-1];
    logic [2:0]       surv_sym   [0:NS_MAX-1];
    logic [5:0]       surv_state [0:NS_MAX-1];
    logic [2:0]       fb_idx     [0:NS_MAX-1];
    logic [2:0]       fb_idx_n   [0:NS_MAX-1];

    logic [M_MAX-1:0] pm_finite_mask;
    logic [M_MAX-1:0] ps_active_mask;
    logic [M_MAX-1:0] ns_active_mask;
    logic [3:0]       ps_active_count;
    logic [3:0]       ns_active_count;

    logic [MET_W-1:0] pre_bm   [0:NS_MAX-1][0:M_MAX-1];
    logic [MET_W-1:0] ps_score [0:M_MAX-1];
    logic [MET_W-1:0] ns_score [0:M_MAX-1];
    logic [MET_W-1:0] bm_rs    [0:NS_MAX-1][0:M_MAX-1];

    logic [NS_MAX*MET_W-1:0]       pm_in_flat;
    logic [NS_MAX*M_MAX*MET_W-1:0] bm_flat;
    logic [NS_MAX*MET_W-1:0]       pm_out_flat;
    logic [NS_MAX*3-1:0]           surv_sym_flat;
    logic [NS_MAX*6-1:0]           surv_state_flat;
    logic [NS_MAX*6-1:0]           state_in_flat;
    logic [NS_MAX*3-1:0]           sym_in_flat;
    logic [TB*NS_MAX*6-1:0]        state_mem_flat;
    logic [TB*NS_MAX*3-1:0]        sym_mem_flat;
    logic [NS_MAX*MET_W-1:0]       pm_trace_flat;

    logic [2:0]     decided_sym;
    logic [TB-1:0]  valid_shreg;

    function automatic logic [MET_W-1:0] sat_add(
        input logic [MET_W-1:0] a,
        input logic [MET_W-1:0] b
    );
        logic [MET_W:0] sum_ext;
        begin
            if (a == INF || b == INF)
                sat_add = INF;
            else begin
                sum_ext = {1'b0, a} + {1'b0, b};
                sat_add = sum_ext[MET_W] ? INF : sum_ext[MET_W-1:0];
            end
        end
    endfunction

    always_comb begin
        unique case (mode)
            2'b00: M_cfg = 4'd2;
            2'b01: M_cfg = 4'd4;
            2'b10: M_cfg = 4'd8;
            default: M_cfg = 4'd2;
        endcase
        NS_cfg = M_cfg;
    end

    always_comb begin
        int keep_tmp;
        unique case (mode)
            2'b10: begin
                ps_keep_base = 3'd4;
                ns_keep_base = 3'd4;
                keep_tmp = 4 + K_cfg;
                if (keep_tmp > M_cfg)
                    keep_tmp = M_cfg;
                ps_keep_max = keep_tmp[2:0];
                ns_keep_max = keep_tmp[2:0];
                unique case (ch_case_sel)
                    2'd0: begin ambig_gap_ps_th = 16'd128; ambig_gap_ns_th = 16'd16; end
                    2'd1: begin ambig_gap_ps_th = 16'd64;  ambig_gap_ns_th = 16'd8;  end
                    default: begin ambig_gap_ps_th = 16'd32;  ambig_gap_ns_th = 16'd4;  end
                endcase
            end
            2'b01: begin
                ps_keep_base = 3'd2;
                ns_keep_base = 3'd2;
                keep_tmp = 2 + K_cfg;
                if (keep_tmp > M_cfg)
                    keep_tmp = M_cfg;
                ps_keep_max = keep_tmp[2:0];
                ns_keep_max = keep_tmp[2:0];
                unique case (ch_case_sel)
                    2'd0: begin ambig_gap_ps_th = 16'd512; ambig_gap_ns_th = 16'd64;  end
                    2'd1: begin ambig_gap_ps_th = 16'd256; ambig_gap_ns_th = 16'd32;  end
                    default: begin ambig_gap_ps_th = 16'd128; ambig_gap_ns_th = 16'd16;  end
                endcase
            end
            default: begin
                ps_keep_base = 3'd2;
                ns_keep_base = 3'd2;
                ps_keep_max = 3'd2;
                ns_keep_max = 3'd2;
                ambig_gap_ps_th = '0;
                ambig_gap_ns_th = '0;
            end
        endcase
    end

    genvar gi;
    generate
        for (gi = 0; gi < M_MAX; gi = gi + 1) begin : GEN_LUT
            symbol_lut_mode_8b #(
                .NRZ_NEG(NRZ_NEG), .NRZ_POS(NRZ_POS),
                .PAM4_L0(PAM4_L0), .PAM4_L1(PAM4_L1),
                .PAM4_L2(PAM4_L2), .PAM4_L3(PAM4_L3),
                .PAM8_L0(PAM8_L0), .PAM8_L1(PAM8_L1),
                .PAM8_L2(PAM8_L2), .PAM8_L3(PAM8_L3),
                .PAM8_L4(PAM8_L4), .PAM8_L5(PAM8_L5),
                .PAM8_L6(PAM8_L6), .PAM8_L7(PAM8_L7)
            ) u_lut (
                .mode    (mode),
                .sym_idx (gi[2:0]),
                .sym_amp (sym_lut[gi])
            );
        end
    endgenerate

    always_comb begin
        int mi, ps, ns, sel;
        logic signed [23:0] zhat_full_loc;
        logic signed [15:0] zhat_loc;
        logic signed [16:0] err_loc;
        logic [33:0]        err2_loc;
        logic [MET_W-1:0]   cand_loc;
        logic [MET_W-1:0]   best_val;
        logic [2:0]         best_idx;
        logic [M_MAX-1:0]   ps_mask_loc;
        logic [M_MAX-1:0]   ns_mask_loc;
        logic [MET_W-1:0]   ps_boundary_val;
        logic [MET_W-1:0]   ns_boundary_val;
        logic [MET_W-1:0]   ps_extra_val;
        logic [MET_W-1:0]   ns_extra_val;
        logic [MET_W-1:0]   ps_gap_val;
        logic [MET_W-1:0]   ns_gap_val;
        logic               ps_need_expand;
        logic               ns_need_expand;

        pm_finite_mask = '0;
        ps_active_mask = '0;
        ns_active_mask = '0;
        ps_keep_dyn = ps_keep_base;
        ns_keep_dyn = ns_keep_base;
        ps_mask_loc = '0;
        ns_mask_loc = '0;
        ps_boundary_val = INF;
        ns_boundary_val = INF;
        ps_extra_val = INF;
        ns_extra_val = INF;
        ps_gap_val = INF;
        ns_gap_val = INF;
        ps_need_expand = 1'b0;
        ns_need_expand = 1'b0;

        for (ps = 0; ps < NS_MAX; ps = ps + 1) begin
            for (ns = 0; ns < M_MAX; ns = ns + 1)
                pre_bm[ps][ns] = INF;
        end

        for (mi = 0; mi < M_MAX; mi = mi + 1) begin
            ps_score[mi] = INF;
            ns_score[mi] = INF;
        end

        for (mi = 0; mi < M_cfg; mi = mi + 1) begin
            if (pm[mi] != INF)
                pm_finite_mask[mi] = 1'b1;
        end

        for (ps = 0; ps < M_cfg; ps = ps + 1) begin
            if (pm[ps] != INF) begin
                for (ns = 0; ns < M_cfg; ns = ns + 1) begin
                    zhat_full_loc = $signed(P0) * $signed(sym_lut[ns]) +
                                    $signed(P1) * $signed(sym_lut[ps]) +
                                    $signed(P2) * $signed(sym_lut[fb_idx[ps]]);
                    zhat_loc = zhat_full_loc >>> PR_SHIFT;
                    err_loc  = $signed(z8) - $signed(zhat_loc);

                    if (err_loc < 0)
                        err2_loc = (-err_loc) * (-err_loc);
                    else
                        err2_loc = err_loc * err_loc;

                    if (|err2_loc[33:MET_W])
                        pre_bm[ps][ns] = INF;
                    else
                        pre_bm[ps][ns] = err2_loc[MET_W-1:0];

                    cand_loc = sat_add(pm[ps], pre_bm[ps][ns]);
                    if (cand_loc < ps_score[ps])
                        ps_score[ps] = cand_loc;
                    if (cand_loc < ns_score[ns])
                        ns_score[ns] = cand_loc;
                end
            end
        end

        for (sel = 0; sel < ps_keep_base; sel = sel + 1) begin
            best_val = INF;
            best_idx = 3'd0;
            for (mi = 0; mi < M_cfg; mi = mi + 1) begin
                if (!ps_mask_loc[mi] && (ps_score[mi] < best_val)) begin
                    best_val = ps_score[mi];
                    best_idx = mi[2:0];
                end
            end
            if (best_val != INF) begin
                ps_mask_loc[best_idx] = 1'b1;
                ps_boundary_val = best_val;
            end
        end

        for (mi = 0; mi < M_cfg; mi = mi + 1) begin
            if (!ps_mask_loc[mi] && (ps_score[mi] < ps_extra_val))
                ps_extra_val = ps_score[mi];
        end

        for (sel = 0; sel < ns_keep_base; sel = sel + 1) begin
            best_val = INF;
            best_idx = 3'd0;
            for (mi = 0; mi < M_cfg; mi = mi + 1) begin
                if (!ns_mask_loc[mi] && (ns_score[mi] < best_val)) begin
                    best_val = ns_score[mi];
                    best_idx = mi[2:0];
                end
            end
            if (best_val != INF) begin
                ns_mask_loc[best_idx] = 1'b1;
                ns_boundary_val = best_val;
            end
        end

        for (mi = 0; mi < M_cfg; mi = mi + 1) begin
            if (!ns_mask_loc[mi] && (ns_score[mi] < ns_extra_val))
                ns_extra_val = ns_score[mi];
        end

        if ((mode != 2'b00) && (K_cfg != 0) &&
            (ps_boundary_val != INF) && (ps_extra_val != INF)) begin
            ps_gap_val = ps_extra_val - ps_boundary_val;
            if (ps_gap_val <= ambig_gap_ps_th)
                ps_need_expand = 1'b1;
        end
        if ((mode != 2'b00) && (K_cfg != 0) &&
            (ns_boundary_val != INF) && (ns_extra_val != INF)) begin
            ns_gap_val = ns_extra_val - ns_boundary_val;
            if (ns_gap_val <= ambig_gap_ns_th)
                ns_need_expand = 1'b1;
        end

        if (ps_need_expand && ns_need_expand) begin
            if (ps_gap_val <= ns_gap_val)
                ps_keep_dyn = ps_keep_max;
            else
                ns_keep_dyn = ns_keep_max;
        end else begin
            if (ps_need_expand)
                ps_keep_dyn = ps_keep_max;
            if (ns_need_expand)
                ns_keep_dyn = ns_keep_max;
        end

        for (sel = ps_keep_base; sel < ps_keep_dyn; sel = sel + 1) begin
            best_val = INF;
            best_idx = 3'd0;
            for (mi = 0; mi < M_cfg; mi = mi + 1) begin
                if (!ps_mask_loc[mi] && (ps_score[mi] < best_val)) begin
                    best_val = ps_score[mi];
                    best_idx = mi[2:0];
                end
            end
            if (best_val != INF)
                ps_mask_loc[best_idx] = 1'b1;
        end

        for (sel = ns_keep_base; sel < ns_keep_dyn; sel = sel + 1) begin
            best_val = INF;
            best_idx = 3'd0;
            for (mi = 0; mi < M_cfg; mi = mi + 1) begin
                if (!ns_mask_loc[mi] && (ns_score[mi] < best_val)) begin
                    best_val = ns_score[mi];
                    best_idx = mi[2:0];
                end
            end
            if (best_val != INF)
                ns_mask_loc[best_idx] = 1'b1;
        end

        ps_active_mask = ps_mask_loc;
        ns_active_mask = ns_mask_loc;

        if (ps_active_mask == '0)
            ps_active_mask = pm_finite_mask;

        if (ns_active_mask == '0) begin
            for (mi = 0; mi < M_cfg; mi = mi + 1)
                ns_active_mask[mi] = 1'b1;
        end
    end

    always_comb begin
        int mi;
        ps_active_count = '0;
        ns_active_count = '0;
        for (mi = 0; mi < M_MAX; mi = mi + 1) begin
            ps_active_count = ps_active_count + ps_active_mask[mi];
            ns_active_count = ns_active_count + ns_active_mask[mi];
        end

        if (in_valid)
            cand_count = ps_active_count * ns_active_count;
        else
            cand_count = 8'd0;
    end

    always_comb begin
        ps_expand_hit = in_valid && (ps_keep_dyn > ps_keep_base);
        ns_expand_hit = in_valid && (ns_keep_dyn > ns_keep_base);
    end

    always_comb begin
        int ps, ns;
        pm_in_flat = '0;
        bm_flat    = '0;

        for (ps = 0; ps < NS_MAX; ps = ps + 1) begin
            for (ns = 0; ns < M_MAX; ns = ns + 1)
                bm_rs[ps][ns] = INF;
        end

        for (ps = 0; ps < NS_MAX; ps = ps + 1)
            pm_in_flat[ps*MET_W +: MET_W] = pm[ps];

        for (ps = 0; ps < M_cfg; ps = ps + 1) begin
            for (ns = 0; ns < M_cfg; ns = ns + 1) begin
                if (ps_active_mask[ps] && ns_active_mask[ns])
                    bm_rs[ps][ns] = pre_bm[ps][ns];
                bm_flat[((ps*M_MAX)+ns)*MET_W +: MET_W] = bm_rs[ps][ns];
            end
        end
    end

    acs_rsmlsd_flat #(.MET_W(MET_W), .NS_MAX(NS_MAX), .M_MAX(M_MAX)) u_acs (
        .en             (in_valid),
        .M_cfg          (M_cfg),
        .NS_cfg         (NS_cfg),
        .ps_active_mask (ps_active_mask),
        .ns_active_mask (ns_active_mask),
        .pm_in_flat     (pm_in_flat),
        .bm_in_flat     (bm_flat),
        .pm_out_flat    (pm_out_flat),
        .surv_sym_flat  (surv_sym_flat),
        .surv_state_flat(surv_state_flat)
    );

    always_comb begin
        int si;
        logic [MET_W-1:0] pm_min_loc;

        for (si = 0; si < NS_MAX; si = si + 1) begin
            pm_n[si]       = pm_out_flat[si*MET_W +: MET_W];
            surv_sym[si]   = surv_sym_flat[si*3 +: 3];
            surv_state[si] = surv_state_flat[si*6 +: 6];
        end

        pm_min_loc = INF;
        for (si = 0; si < NS_MAX; si = si + 1) begin
            if ((si < M_cfg) && (pm_n[si] != INF) && (pm_n[si] < pm_min_loc))
                pm_min_loc = pm_n[si];
        end
        if (pm_min_loc == INF)
            pm_min_loc = '0;

        state_in_flat = '0;
        sym_in_flat   = '0;
        pm_trace_flat = '0;
        for (si = 0; si < NS_MAX; si = si + 1) begin
            if (si < M_cfg) begin
                if (pm_n[si] == INF)
                    pm_norm[si] = INF;
                else
                    pm_norm[si] = pm_n[si] - pm_min_loc;

                if (pm_norm[si] != INF)
                    fb_idx_n[si] = surv_state[si][2:0];
                else
                    fb_idx_n[si] = fb_idx[si];
            end else begin
                pm_norm[si] = INF;
                fb_idx_n[si] = 3'd0;
            end

            state_in_flat[si*6 +: 6]   = surv_state[si];
            sym_in_flat[si*3 +: 3]     = surv_sym[si];
            pm_trace_flat[si*MET_W +: MET_W] = pm[si];
        end
    end

    survivor_mem_flat #(.TB(TB), .NS_MAX(NS_MAX)) u_mem (
        .clk           (clk),
        .rst_n         (rst_n),
        .we            (in_valid),
        .state_in_flat (state_in_flat),
        .sym_in_flat   (sym_in_flat),
        .state_mem_flat(state_mem_flat),
        .sym_mem_flat  (sym_mem_flat)
    );

    traceback_flat #(.TB(TB), .MET_W(MET_W), .NS_MAX(NS_MAX)) u_tb (
        .NS_cfg        (NS_cfg),
        .pm_flat       (pm_trace_flat),
        .state_mem_flat(state_mem_flat),
        .sym_mem_flat  (sym_mem_flat),
        .decided_sym   (decided_sym)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        int sj;
        if (!rst_n) begin
            for (sj = 0; sj < NS_MAX; sj = sj + 1) begin
                pm[sj] <= INF;
                fb_idx[sj] <= sj[2:0];
            end
            pm[0] <= '0;
            valid_shreg <= '0;
        end else begin
            if (TB > 1)
                valid_shreg <= {valid_shreg[TB-2:0], in_valid};
            else
                valid_shreg <= in_valid;

            if (in_valid) begin
                for (sj = 0; sj < NS_MAX; sj = sj + 1) begin
                    pm[sj] <= pm_norm[sj];
                    fb_idx[sj] <= fb_idx_n[sj];
                end
            end
        end
    end

    assign out_valid = valid_shreg[TB-1];

    always_comb begin
        if (out_valid)
            a_hat8 = sym_lut[decided_sym];
        else
            a_hat8 = 8'sd0;
    end


endmodule
