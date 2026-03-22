`timescale 1ns/1ps

module rs_mlsd_core_lane_8b #(
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
    input  logic [3:0]         K_cfg,
    input  logic signed [7:0]  z8,
    output logic               out_valid,
    output logic signed [7:0]  a_hat8
);

    localparam int NS_MAX = 8;
    localparam int M_MAX  = 8;
    localparam logic [MET_W-1:0] INF = '1;

    logic [3:0] M_cfg;
    logic [6:0] NS_cfg;

    always_comb begin
        unique case (mode)
            2'b00: M_cfg = 4'd2;
            2'b01: M_cfg = 4'd4;
            2'b10: M_cfg = 4'd8;
            default: M_cfg = 4'd2;
        endcase
        NS_cfg = M_cfg;
    end

    logic signed [7:0] sym_lut [0:M_MAX-1];

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

    logic [M_MAX-1:0] region_mask_cur;
    logic [M_MAX-1:0] region_mask_prev;
    logic signed [7:0] z_prev;
    logic seen_valid;

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

    logic [MET_W-1:0] bm_rs [0:NS_MAX-1][0:M_MAX-1];
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

    integer mi;
    integer ps, ns, si, sj;
    logic signed [23:0] zhat_full;
    logic signed [15:0] zhat;
    logic signed [16:0] err;
    logic [33:0] err2;
    logic [MET_W-1:0] pm_min;
    logic [2:0] decided_sym;
    logic [TB-1:0] valid_shreg;

    always_comb begin
        pm_finite_mask = '0;
        for (mi = 0; mi < M_MAX; mi = mi + 1) begin
            if ((mi < M_cfg) && (pm[mi] != INF))
                pm_finite_mask[mi] = 1'b1;
        end

        if (seen_valid) ps_active_mask = region_mask_prev & pm_finite_mask;
        else            ps_active_mask = pm_finite_mask;

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
        for (ps = 0; ps < NS_MAX; ps = ps + 1)
            for (ns = 0; ns < M_MAX; ns = ns + 1)
                bm_rs[ps][ns] = INF;

        for (ps = 0; ps < M_cfg; ps = ps + 1) begin
            for (ns = 0; ns < M_cfg; ns = ns + 1) begin
                if (ps_active_mask[ps] && ns_active_mask[ns]) begin
                    zhat_full = $signed(P0) * $signed(sym_lut[ns]) +
                                $signed(P1) * $signed(sym_lut[ps]) +
                                $signed(P2) * $signed(sym_lut[fb_idx[ps]]);
                    zhat = zhat_full >>> PR_SHIFT;
                    err  = $signed(z8) - $signed(zhat);
                    if (err < 0) err2 = (-err) * (-err);
                    else         err2 = ( err) * ( err);

                    if (|err2[33:MET_W]) bm_rs[ps][ns] = INF;
                    else                 bm_rs[ps][ns] = err2[MET_W-1:0];
                end
            end
        end

        pm_in_flat = '0;
        bm_flat = '0;
        for (ps = 0; ps < NS_MAX; ps = ps + 1) begin
            pm_in_flat[ps*MET_W +: MET_W] = pm[ps];
            for (ns = 0; ns < M_MAX; ns = ns + 1)
                bm_flat[((ps*M_MAX)+ns)*MET_W +: MET_W] = bm_rs[ps][ns];
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
        for (si = 0; si < NS_MAX; si = si + 1) begin
            pm_n[si] = pm_out_flat[si*MET_W +: MET_W];
            surv_sym[si] = surv_sym_flat[si*3 +: 3];
            surv_state[si] = surv_state_flat[si*6 +: 6];
        end

        pm_min = INF;
        for (si = 0; si < NS_MAX; si = si + 1) begin
            if (si < M_cfg) begin
                if ((pm_n[si] != INF) && (pm_n[si] < pm_min))
                    pm_min = pm_n[si];
            end
        end
        if (pm_min == INF)
            pm_min = '0;

        state_in_flat = '0;
        sym_in_flat = '0;
        pm_trace_flat = '0;
        for (si = 0; si < NS_MAX; si = si + 1) begin
            if (si < M_cfg) begin
                if (pm_n[si] == INF) pm_norm[si] = INF;
                else                 pm_norm[si] = pm_n[si] - pm_min;

                if (pm_norm[si] != INF)
                    fb_idx_n[si] = surv_state[si][2:0];
                else
                    fb_idx_n[si] = fb_idx[si];
            end else begin
                pm_norm[si] = INF;
                fb_idx_n[si] = 3'd0;
            end

            state_in_flat[si*6 +: 6] = surv_state[si];
            sym_in_flat[si*3 +: 3] = surv_sym[si];
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
        if (!rst_n) begin
            for (sj = 0; sj < NS_MAX; sj = sj + 1) begin
                pm[sj] <= INF;
                fb_idx[sj] <= sj[2:0];
            end
            pm[0] <= '0;
            valid_shreg <= '0;
            z_prev <= '0;
            seen_valid <= 1'b0;
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
                z_prev <= z8;
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
    always_comb k_cfg_unused = K_cfg;

endmodule
