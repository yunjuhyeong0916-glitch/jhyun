`timescale 1ns/1ps

module cmp_unified_mlsd_core_lane_8b #(
    parameter int TB       = 40,
    parameter int MET_W    = 16,
    parameter int PR_SHIFT = 2,

    parameter logic [3:0] K_CFG = 4'd2,

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

    logic                      use_full_state;
    logic [3:0]                M_cfg;
    logic [6:0]                NS_cfg;
    logic [2:0]                ps_keep_base;
    logic [2:0]                ns_keep_base;
    logic [2:0]                ps_keep_max;
    logic [2:0]                ns_keep_max;
    logic [2:0]                ps_keep_dyn;
    logic [2:0]                ns_keep_dyn;
    logic [MET_W-1:0] ambig_gap_ps_th;
    logic [MET_W-1:0] ambig_gap_ns_th;
    logic signed [7:0]         sym_lut [0:M_MAX-1];
    logic [MET_W-1:0]          pm      [0:NS_MAX-1];
    logic [MET_W-1:0]          pm_n    [0:NS_MAX-1];
    logic [MET_W-1:0]          pm_norm [0:NS_MAX-1];
    logic [2:0]                surv_sym   [0:NS_MAX-1];
    logic [5:0]                surv_state [0:NS_MAX-1];
    logic [2:0]                fb_idx     [0:NS_MAX-1];
    logic [2:0]                fb_idx_n   [0:NS_MAX-1];

    logic [NS_MAX*6-1:0]       state_in_flat;
    logic [NS_MAX*3-1:0]       sym_in_flat;
    logic [TB*NS_MAX*6-1:0]    state_mem_flat;
    logic [TB*NS_MAX*3-1:0]    sym_mem_flat;
    logic [NS_MAX*MET_W-1:0]   pm_flat;

    logic [M_MAX-1:0]          pm_finite_mask;
    logic [M_MAX-1:0]          ps_active_mask;
    logic [M_MAX-1:0]          ns_active_mask;
    logic [3:0]                ps_active_count;
    logic [3:0]                ns_active_count;
    logic [M_MAX-1:0]          branch_active_mask [0:NS_MAX-1];
    logic [7:0]                branch_active_count;
    logic                      branch_expand_hit_int;

    logic [MET_W-1:0]          pre_bm   [0:NS_MAX-1][0:M_MAX-1];
    logic [MET_W-1:0]          ps_score [0:M_MAX-1];
    logic [MET_W-1:0]          ns_score [0:M_MAX-1];

    logic [2:0]                decided_sym;
    logic [TB-1:0]             valid_shreg;

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
        int keep_tmp;
        unique case (mode)
            2'b00: begin
                use_full_state = 1'b1;
                M_cfg = 4'd2;
                NS_cfg = 7'd4;
                ps_keep_base = 3'd2;
                ns_keep_base = 3'd2;
                ps_keep_max = 3'd2;
                ns_keep_max = 3'd2;
                ambig_gap_ps_th = '0;
                ambig_gap_ns_th = '0;
            end
            2'b01: begin
                use_full_state = 1'b0;
                M_cfg = 4'd4;
                NS_cfg = 7'd4;
                ps_keep_base = 3'd2;
                ns_keep_base = 3'd2;
                keep_tmp = 2 + K_CFG;
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
            2'b10: begin
                use_full_state = 1'b0;
                M_cfg = 4'd8;
                NS_cfg = 7'd8;
                ps_keep_base = 3'd5;
                ns_keep_base = 3'd5;
                keep_tmp = 5 + K_CFG;
                if (keep_tmp > M_cfg)
                    keep_tmp = M_cfg;
                ps_keep_max = keep_tmp[2:0];
                ns_keep_max = keep_tmp[2:0];
                unique case (ch_case_sel)
                    2'd0: begin ambig_gap_ps_th = 16'd256; ambig_gap_ns_th = 16'd32; end
                    2'd1: begin ambig_gap_ps_th = 16'd128; ambig_gap_ns_th = 16'd16; end
                    default: begin ambig_gap_ps_th = 16'd64; ambig_gap_ns_th = 16'd8; end
                endcase
            end
            default: begin
                use_full_state = 1'b1;
                M_cfg = 4'd2;
                NS_cfg = 7'd4;
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
                .PAM4_L0(PAM4_L0), .PAM4_L1(PAM4_L1), .PAM4_L2(PAM4_L2), .PAM4_L3(PAM4_L3),
                .PAM8_L0(PAM8_L0), .PAM8_L1(PAM8_L1), .PAM8_L2(PAM8_L2), .PAM8_L3(PAM8_L3),
                .PAM8_L4(PAM8_L4), .PAM8_L5(PAM8_L5), .PAM8_L6(PAM8_L6), .PAM8_L7(PAM8_L7)
            ) u_lut (
                .mode    (mode),
                .sym_idx (gi[2:0]),
                .sym_amp (sym_lut[gi])
            );
        end
    endgenerate

    always_comb begin
        int mi, ps, ns, sel;
        int branch_keep_base;
        int branch_keep_max;
        int branch_keep_dyn;
        logic signed [23:0] zhat_full_loc;
        logic signed [15:0] zhat_loc;
        logic signed [16:0] err_loc;
        logic [33:0]        err2_loc;
        logic [MET_W-1:0]   cand_loc;
        logic [MET_W-1:0]   best_val;
        logic [2:0]         best_ps_idx;
        logic [2:0]         best_ns_idx;
        logic [M_MAX-1:0]   branch_mask_loc [0:NS_MAX-1];
        logic [MET_W-1:0]   branch_boundary_val;
        logic [MET_W-1:0]   branch_extra_val;
        logic [MET_W-1:0]   branch_gap_val;
        logic [MET_W-1:0]   branch_ambig_th;
        logic               branch_need_expand;

        pm_finite_mask = '0;
        ps_active_mask = '0;
        ns_active_mask = '0;
        branch_active_count = '0;
        branch_expand_hit_int = 1'b0;
        branch_keep_base = 0;
        branch_keep_max = 0;
        branch_keep_dyn = 0;
        branch_boundary_val = INF;
        branch_extra_val = INF;
        branch_gap_val = INF;
        branch_ambig_th = INF;
        branch_need_expand = 1'b0;

        for (ps = 0; ps < NS_MAX; ps = ps + 1) begin
            branch_active_mask[ps] = '0;
            branch_mask_loc[ps] = '0;
            for (ns = 0; ns < M_MAX; ns = ns + 1)
                pre_bm[ps][ns] = INF;
        end

        for (mi = 0; mi < M_MAX; mi = mi + 1) begin
            ps_score[mi] = INF;
            ns_score[mi] = INF;
        end

        for (mi = 0; mi < NS_cfg; mi = mi + 1) begin
            if (pm[mi] != INF)
                pm_finite_mask[mi] = 1'b1;
        end

        if (use_full_state) begin
            for (mi = 0; mi < M_cfg; mi = mi + 1) begin
                ps_active_mask[mi] = 1'b1;
                ns_active_mask[mi] = 1'b1;
            end
        end else begin
            for (ps = 0; ps < NS_cfg; ps = ps + 1) begin
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

            branch_keep_base = ps_keep_base * ns_keep_base;
            branch_keep_max = ps_keep_max * ns_keep_max;
            branch_keep_dyn = branch_keep_base;
            if (ambig_gap_ps_th < ambig_gap_ns_th)
                branch_ambig_th = ambig_gap_ps_th;
            else
                branch_ambig_th = ambig_gap_ns_th;

            for (sel = 0; sel < branch_keep_base; sel = sel + 1) begin
                best_val = INF;
                best_ps_idx = 3'd0;
                best_ns_idx = 3'd0;
                for (ps = 0; ps < NS_cfg; ps = ps + 1) begin
                    if (pm[ps] != INF) begin
                        for (ns = 0; ns < M_cfg; ns = ns + 1) begin
                            cand_loc = sat_add(pm[ps], pre_bm[ps][ns]);
                            if (!branch_mask_loc[ps][ns] && (cand_loc < best_val)) begin
                                best_val = cand_loc;
                                best_ps_idx = ps[2:0];
                                best_ns_idx = ns[2:0];
                            end
                        end
                    end
                end
                if (best_val != INF) begin
                    branch_mask_loc[best_ps_idx][best_ns_idx] = 1'b1;
                    branch_boundary_val = best_val;
                end
            end

            for (ps = 0; ps < NS_cfg; ps = ps + 1) begin
                if (pm[ps] != INF) begin
                    for (ns = 0; ns < M_cfg; ns = ns + 1) begin
                        cand_loc = sat_add(pm[ps], pre_bm[ps][ns]);
                        if (!branch_mask_loc[ps][ns] && (cand_loc < branch_extra_val))
                            branch_extra_val = cand_loc;
                    end
                end
            end

            if ((K_CFG != 0) &&
                (branch_boundary_val != INF) && (branch_extra_val != INF)) begin
                branch_gap_val = branch_extra_val - branch_boundary_val;
                if (branch_gap_val <= branch_ambig_th)
                    branch_need_expand = 1'b1;
            end

            if (branch_need_expand) begin
                branch_keep_dyn = branch_keep_base + M_cfg;
                if (branch_keep_dyn > branch_keep_max)
                    branch_keep_dyn = branch_keep_max;
            end

            for (sel = branch_keep_base; sel < branch_keep_dyn; sel = sel + 1) begin
                best_val = INF;
                best_ps_idx = 3'd0;
                best_ns_idx = 3'd0;
                for (ps = 0; ps < NS_cfg; ps = ps + 1) begin
                    if (pm[ps] != INF) begin
                        for (ns = 0; ns < M_cfg; ns = ns + 1) begin
                            cand_loc = sat_add(pm[ps], pre_bm[ps][ns]);
                            if (!branch_mask_loc[ps][ns] && (cand_loc < best_val)) begin
                                best_val = cand_loc;
                                best_ps_idx = ps[2:0];
                                best_ns_idx = ns[2:0];
                            end
                        end
                    end
                end
                if (best_val != INF)
                    branch_mask_loc[best_ps_idx][best_ns_idx] = 1'b1;
            end

            for (ps = 0; ps < NS_cfg; ps = ps + 1) begin
                for (ns = 0; ns < M_cfg; ns = ns + 1) begin
                    if (branch_mask_loc[ps][ns]) begin
                        branch_active_mask[ps][ns] = 1'b1;
                        ps_active_mask[ps] = 1'b1;
                        ns_active_mask[ns] = 1'b1;
                        branch_active_count = branch_active_count + 8'd1;
                    end
                end
            end

            if (branch_active_count == 0) begin
                branch_active_count = '0;
                ns_active_mask = '0;
                for (ps = 0; ps < NS_cfg; ps = ps + 1) begin
                    if (pm_finite_mask[ps]) begin
                        ps_active_mask[ps] = 1'b1;
                        for (ns = 0; ns < M_cfg; ns = ns + 1) begin
                            branch_active_mask[ps][ns] = 1'b1;
                            ns_active_mask[ns] = 1'b1;
                            branch_active_count = branch_active_count + 8'd1;
                        end
                    end
                end
            end

            branch_expand_hit_int = (branch_keep_dyn > branch_keep_base);
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

        if (!in_valid)
            cand_count = 8'd0;
        else if (use_full_state)
            cand_count = M_cfg * M_cfg * M_cfg;
        else
            cand_count = branch_active_count;
    end

    always_comb begin
        ps_expand_hit = in_valid && !use_full_state && branch_expand_hit_int;
        ns_expand_hit = in_valid && !use_full_state && branch_expand_hit_int;
    end
    always_comb begin
        int ps, m, si, s1, s2, next_state;
        logic signed [23:0] zhat_full_loc;
        logic signed [15:0] zhat_loc;
        logic signed [16:0] err_loc;
        logic [33:0]        err2_loc;
        logic [MET_W-1:0]   cand_loc;
        logic [MET_W-1:0]   pm_min_loc;

        for (si = 0; si < NS_MAX; si = si + 1) begin
            pm_n[si]       = INF;
            surv_sym[si]   = 3'd0;
            surv_state[si] = 6'd0;
        end

        if (use_full_state) begin
            for (ps = 0; ps < NS_cfg; ps = ps + 1) begin
                s1 = ps / 2;
                s2 = ps % 2;

                for (m = 0; m < 2; m = m + 1) begin
                    zhat_full_loc = $signed(P0) * $signed(sym_lut[m]) +
                                    $signed(P1) * $signed(sym_lut[s1]) +
                                    $signed(P2) * $signed(sym_lut[s2]);
                    zhat_loc = zhat_full_loc >>> PR_SHIFT;
                    err_loc  = $signed(z8) - $signed(zhat_loc);

                    if (err_loc < 0)
                        err2_loc = (-err_loc) * (-err_loc);
                    else
                        err2_loc = err_loc * err_loc;

                    if (|err2_loc[33:MET_W])
                        cand_loc = INF;
                    else
                        cand_loc = sat_add(pm[ps], err2_loc[MET_W-1:0]);

                    next_state = (m * 2) + s1;
                    if (cand_loc < pm_n[next_state]) begin
                        pm_n[next_state]       = cand_loc;
                        surv_state[next_state] = ps[5:0];
                        surv_sym[next_state]   = m[2:0];
                    end
                end
            end
        end else begin
            for (ps = 0; ps < NS_cfg; ps = ps + 1) begin
                for (m = 0; m < M_cfg; m = m + 1) begin
                    if (branch_active_mask[ps][m]) begin
                        cand_loc = sat_add(pm[ps], pre_bm[ps][m]);
                        next_state = m;
                        if (cand_loc < pm_n[next_state]) begin
                            pm_n[next_state]       = cand_loc;
                            surv_state[next_state] = ps[5:0];
                            surv_sym[next_state]   = m[2:0];
                        end
                    end
                end
            end
        end

        pm_min_loc = INF;
        for (si = 0; si < NS_MAX; si = si + 1) begin
            if ((si < NS_cfg) && (pm_n[si] != INF) && (pm_n[si] < pm_min_loc))
                pm_min_loc = pm_n[si];
        end
        if (pm_min_loc == INF)
            pm_min_loc = '0;

        state_in_flat = '0;
        sym_in_flat   = '0;
        pm_flat       = '0;
        for (si = 0; si < NS_MAX; si = si + 1) begin
            if (si < NS_cfg) begin
                if (pm_n[si] == INF)
                    pm_norm[si] = INF;
                else
                    pm_norm[si] = pm_n[si] - pm_min_loc;
            end else begin
                pm_norm[si] = INF;
            end

            if (!use_full_state && (si < NS_cfg)) begin
                if (pm_norm[si] != INF)
                    fb_idx_n[si] = surv_state[si][2:0];
                else
                    fb_idx_n[si] = fb_idx[si];
            end else begin
                fb_idx_n[si] = 3'd0;
            end

            state_in_flat[si*6 +: 6]   = surv_state[si];
            sym_in_flat[si*3 +: 3]     = surv_sym[si];
            pm_flat[si*MET_W +: MET_W] = pm[si];
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
        .pm_flat       (pm_flat),
        .state_mem_flat(state_mem_flat),
        .sym_mem_flat  (sym_mem_flat),
        .decided_sym   (decided_sym)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        int si;
        if (!rst_n) begin
            for (si = 0; si < NS_MAX; si = si + 1) begin
                pm[si]     <= INF;
                fb_idx[si] <= si[2:0];
            end
            pm[0] <= '0;
            valid_shreg <= '0;
        end else begin
            if (TB > 1)
                valid_shreg <= {valid_shreg[TB-2:0], in_valid};
            else
                valid_shreg <= in_valid;

            if (in_valid) begin
                for (si = 0; si < NS_MAX; si = si + 1) begin
                    pm[si] <= pm_norm[si];
                    if (!use_full_state && (si < NS_cfg))
                        fb_idx[si] <= fb_idx_n[si];
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

