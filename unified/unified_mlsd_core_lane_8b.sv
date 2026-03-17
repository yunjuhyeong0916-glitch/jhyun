`timescale 1ns/1ps

module unified_mlsd_core_lane_8b #(
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
    input  logic signed [7:0]  z8,
    output logic               out_valid,
    output logic signed [7:0]  a_hat8
);

    localparam int NS_MAX = 8;
    localparam int M_MAX  = 8;
    localparam logic [MET_W-1:0] INF = '1;

    logic                      use_full_state;
    logic [3:0]                M_cfg;
    logic [6:0]                NS_cfg;
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

    logic [M_MAX-1:0]          region_mask_cur;
    logic [M_MAX-1:0]          region_mask_prev;
    logic [M_MAX-1:0]          pm_finite_mask;
    logic [M_MAX-1:0]          ps_active_mask;
    logic [M_MAX-1:0]          ns_active_mask;
    logic signed [7:0]         z_prev;
    logic                      seen_valid;

    logic [2:0]                decided_sym;
    logic [TB-1:0]             valid_shreg;

    integer ps, m, si, mi;
    integer s1, s2;
    integer next_state;
    logic signed [23:0] zhat_full;
    logic signed [15:0] zhat;
    logic signed [16:0] err;
    logic [33:0]        err2;
    logic [MET_W-1:0]   cand;
    logic [MET_W-1:0]   pm_min;

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
            2'b00: begin
                use_full_state = 1'b1;
                M_cfg = 4'd2;
                NS_cfg = 7'd4;
            end
            2'b01: begin
                use_full_state = 1'b0;
                M_cfg = 4'd4;
                NS_cfg = 7'd4;
            end
            2'b10: begin
                use_full_state = 1'b0;
                M_cfg = 4'd8;
                NS_cfg = 7'd8;
            end
            default: begin
                use_full_state = 1'b1;
                M_cfg = 4'd2;
                NS_cfg = 7'd4;
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

    rs_region_detector_mode_8b #(
        .PAM4_L0(PAM4_L0), .PAM4_L1(PAM4_L1), .PAM4_L2(PAM4_L2), .PAM4_L3(PAM4_L3),
        .PAM8_L0(PAM8_L0), .PAM8_L1(PAM8_L1), .PAM8_L2(PAM8_L2), .PAM8_L3(PAM8_L3),
        .PAM8_L4(PAM8_L4), .PAM8_L5(PAM8_L5), .PAM8_L6(PAM8_L6), .PAM8_L7(PAM8_L7)
    ) u_reg_cur (
        .mode        (mode),
        .y8          (z8),
        .active_mask (region_mask_cur)
    );

    rs_region_detector_mode_8b #(
        .PAM4_L0(PAM4_L0), .PAM4_L1(PAM4_L1), .PAM4_L2(PAM4_L2), .PAM4_L3(PAM4_L3),
        .PAM8_L0(PAM8_L0), .PAM8_L1(PAM8_L1), .PAM8_L2(PAM8_L2), .PAM8_L3(PAM8_L3),
        .PAM8_L4(PAM8_L4), .PAM8_L5(PAM8_L5), .PAM8_L6(PAM8_L6), .PAM8_L7(PAM8_L7)
    ) u_reg_prev (
        .mode        (mode),
        .y8          (z_prev),
        .active_mask (region_mask_prev)
    );

    always_comb begin
        pm_finite_mask = '0;
        for (mi = 0; mi < M_MAX; mi = mi + 1) begin
            if ((mi < NS_cfg) && (pm[mi] != INF))
                pm_finite_mask[mi] = 1'b1;
        end

        if (seen_valid)
            ps_active_mask = region_mask_prev & pm_finite_mask;
        else
            ps_active_mask = pm_finite_mask;

        ns_active_mask = region_mask_cur;

        for (mi = M_cfg; mi < M_MAX; mi = mi + 1) begin
            ps_active_mask[mi] = 1'b0;
            ns_active_mask[mi] = 1'b0;
        end

        if (ps_active_mask == '0)
            ps_active_mask = pm_finite_mask;

        if (ns_active_mask == '0) begin
            ns_active_mask = '0;
            for (mi = 0; mi < M_cfg; mi = mi + 1)
                ns_active_mask[mi] = 1'b1;
        end
    end

    always_comb begin
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
                    zhat_full = $signed(P0) * $signed(sym_lut[m]) +
                                $signed(P1) * $signed(sym_lut[s1]) +
                                $signed(P2) * $signed(sym_lut[s2]);

                    zhat = zhat_full >>> PR_SHIFT;
                    err  = $signed(z8) - $signed(zhat);

                    if (err < 0) err2 = (-err) * (-err);
                    else         err2 = ( err) * ( err);

                    if (|err2[33:MET_W]) cand = INF;
                    else                 cand = sat_add(pm[ps], err2[MET_W-1:0]);

                    next_state = (m * 2) + s1;
                    if (cand < pm_n[next_state]) begin
                        pm_n[next_state]       = cand;
                        surv_state[next_state] = ps[5:0];
                        surv_sym[next_state]   = m[2:0];
                    end
                end
            end
        end else begin
            for (ps = 0; ps < NS_cfg; ps = ps + 1) begin
                if (ps_active_mask[ps]) begin
                    for (m = 0; m < M_cfg; m = m + 1) begin
                        if (ns_active_mask[m]) begin
                            zhat_full = $signed(P0) * $signed(sym_lut[m]) +
                                        $signed(P1) * $signed(sym_lut[ps]) +
                                        $signed(P2) * $signed(sym_lut[fb_idx[ps]]);

                            zhat = zhat_full >>> PR_SHIFT;
                            err  = $signed(z8) - $signed(zhat);

                            if (err < 0) err2 = (-err) * (-err);
                            else         err2 = ( err) * ( err);

                            if (|err2[33:MET_W]) cand = INF;
                            else                 cand = sat_add(pm[ps], err2[MET_W-1:0]);

                            next_state = m;
                            if (cand < pm_n[next_state]) begin
                                pm_n[next_state]       = cand;
                                surv_state[next_state] = ps[5:0];
                                surv_sym[next_state]   = m[2:0];
                            end
                        end
                    end
                end
            end
        end

        pm_min = INF;
        for (si = 0; si < NS_MAX; si = si + 1) begin
            if ((si < NS_cfg) && (pm_n[si] != INF) && (pm_n[si] < pm_min))
                pm_min = pm_n[si];
        end
        if (pm_min == INF)
            pm_min = '0;

        state_in_flat = '0;
        sym_in_flat   = '0;
        pm_flat       = '0;
        for (si = 0; si < NS_MAX; si = si + 1) begin
            if (si < NS_cfg) begin
                if (pm_n[si] == INF) pm_norm[si] = INF;
                else                 pm_norm[si] = pm_n[si] - pm_min;
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
        if (!rst_n) begin
            for (si = 0; si < NS_MAX; si = si + 1) begin
                pm[si]     <= INF;
                fb_idx[si] <= si[2:0];
            end
            pm[0] <= '0;
            valid_shreg <= '0;
            z_prev      <= '0;
            seen_valid  <= 1'b0;
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
                z_prev     <= z8;
                seen_valid <= 1'b1;
            end
        end
    end

    assign out_valid = valid_shreg[TB-1];

    always_comb begin
        if (out_valid) a_hat8 = sym_lut[decided_sym];
        else           a_hat8 = 8'sd0;
    end

    logic [3:0] k_cfg_unused;
    always_comb k_cfg_unused = K_CFG;

endmodule
