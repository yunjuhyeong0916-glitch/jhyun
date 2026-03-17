`timescale 1ns/1ps

module fs_mlsd_core_lane_8b #(
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
    input  logic signed [7:0]  z8,
    output logic               out_valid,
    output logic signed [7:0]  a_hat8
);

    localparam int NS_MAX = 64;
    localparam int M_MAX  = 8;
    localparam logic [MET_W-1:0] INF = '1;

    logic [3:0] M_cfg;
    logic [6:0] NS_cfg;

    logic signed [7:0] sym_lut [0:M_MAX-1];
    logic [MET_W-1:0]  pm      [0:NS_MAX-1];
    logic [MET_W-1:0]  pm_n    [0:NS_MAX-1];
    logic [MET_W-1:0]  pm_norm [0:NS_MAX-1];
    logic [2:0]        surv_sym   [0:NS_MAX-1];
    logic [5:0]        surv_state [0:NS_MAX-1];

    logic [NS_MAX*6-1:0]      state_in_flat;
    logic [NS_MAX*3-1:0]      sym_in_flat;
    logic [TB*NS_MAX*6-1:0]   state_mem_flat;
    logic [TB*NS_MAX*3-1:0]   sym_mem_flat;
    logic [NS_MAX*MET_W-1:0]  pm_flat;

    logic [2:0]       decided_sym;
    logic [TB-1:0]    valid_shreg;

    integer ps, m, si;
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
            2'b00: M_cfg = 4'd2;
            2'b01: M_cfg = 4'd4;
            2'b10: M_cfg = 4'd8;
            default: M_cfg = 4'd2;
        endcase
        NS_cfg = M_cfg * M_cfg;
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
        for (si = 0; si < NS_MAX; si = si + 1) begin
            pm_n[si]       = INF;
            surv_sym[si]   = 3'd0;
            surv_state[si] = 6'd0;
        end

        for (ps = 0; ps < NS_cfg; ps = ps + 1) begin
            s1 = ps / M_cfg;
            s2 = ps % M_cfg;

            for (m = 0; m < M_cfg; m = m + 1) begin
                zhat_full = $signed(P0) * $signed(sym_lut[m]) +
                            $signed(P1) * $signed(sym_lut[s1]) +
                            $signed(P2) * $signed(sym_lut[s2]);

                zhat = zhat_full >>> PR_SHIFT;
                err  = $signed(z8) - $signed(zhat);

                if (err < 0) err2 = (-err) * (-err);
                else         err2 = ( err) * ( err);

                if (|err2[33:MET_W]) cand = INF;
                else                 cand = sat_add(pm[ps], err2[MET_W-1:0]);

                next_state = (m * M_cfg) + s1;
                if (cand < pm_n[next_state]) begin
                    pm_n[next_state]       = cand;
                    surv_state[next_state] = ps[5:0];
                    surv_sym[next_state]   = m[2:0];
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

            state_in_flat[si*6 +: 6] = surv_state[si];
            sym_in_flat[si*3 +: 3]   = surv_sym[si];
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
            for (si = 0; si < NS_MAX; si = si + 1)
                pm[si] <= INF;
            pm[0] <= '0;
            valid_shreg <= '0;
        end else begin
            if (TB > 1)
                valid_shreg <= {valid_shreg[TB-2:0], in_valid};
            else
                valid_shreg <= in_valid;

            if (in_valid) begin
                for (si = 0; si < NS_MAX; si = si + 1)
                    pm[si] <= pm_norm[si];
            end
        end
    end

    assign out_valid = valid_shreg[TB-1];

    always_comb begin
        if (out_valid) a_hat8 = sym_lut[decided_sym];
        else           a_hat8 = 8'sd0;
    end

endmodule
