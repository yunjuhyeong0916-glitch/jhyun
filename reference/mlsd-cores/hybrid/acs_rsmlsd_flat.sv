`timescale 1ns/1ps

module acs_rsmlsd_flat #(
    parameter int MET_W  = 16,
    parameter int NS_MAX = 8,
    parameter int M_MAX  = 8
)(
    input  logic                          en,
    input  logic [3:0]                    M_cfg,
    input  logic [6:0]                    NS_cfg,
    input  logic [M_MAX-1:0]              ps_active_mask,
    input  logic [M_MAX-1:0]              ns_active_mask,
    input  logic [NS_MAX*MET_W-1:0]       pm_in_flat,
    input  logic [NS_MAX*M_MAX*MET_W-1:0] bm_in_flat,
    output logic [NS_MAX*MET_W-1:0]       pm_out_flat,
    output logic [NS_MAX*3-1:0]           surv_sym_flat,
    output logic [NS_MAX*6-1:0]           surv_state_flat
);

    localparam logic [MET_W-1:0] INF = '1;

    logic [MET_W-1:0] pm_in      [0:NS_MAX-1];
    logic [MET_W-1:0] bm_in      [0:NS_MAX-1][0:M_MAX-1];
    logic [MET_W-1:0] pm_out     [0:NS_MAX-1];
    logic [2:0]       surv_sym   [0:NS_MAX-1];
    logic [5:0]       surv_state [0:NS_MAX-1];

    integer i, j;
    integer ns, ps;
    logic [MET_W-1:0] best_pm, cand;
    logic [5:0] best_ps;

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
        for (i = 0; i < NS_MAX; i = i + 1) begin
            pm_in[i] = pm_in_flat[i*MET_W +: MET_W];
            for (j = 0; j < M_MAX; j = j + 1)
                bm_in[i][j] = bm_in_flat[((i*M_MAX)+j)*MET_W +: MET_W];
        end

        for (ns = 0; ns < NS_MAX; ns = ns + 1) begin
            pm_out[ns]     = INF;
            surv_sym[ns]   = '0;
            surv_state[ns] = '0;
        end

        if (en) begin
            for (ns = 0; ns < M_cfg; ns = ns + 1) begin
                if (ns_active_mask[ns]) begin
                    best_pm = INF;
                    best_ps = '0;
                    for (ps = 0; ps < M_cfg; ps = ps + 1) begin
                        if (ps_active_mask[ps]) begin
                            cand = sat_add(pm_in[ps], bm_in[ps][ns]);
                            if (cand < best_pm) begin
                                best_pm = cand;
                                best_ps = ps[5:0];
                            end
                        end
                    end
                    pm_out[ns]     = best_pm;
                    surv_state[ns] = best_ps;
                    surv_sym[ns]   = ns[2:0];
                end
            end
        end

        pm_out_flat = '0;
        surv_sym_flat = '0;
        surv_state_flat = '0;
        for (i = 0; i < NS_MAX; i = i + 1) begin
            pm_out_flat[i*MET_W +: MET_W] = pm_out[i];
            surv_sym_flat[i*3 +: 3] = surv_sym[i];
            surv_state_flat[i*6 +: 6] = surv_state[i];
        end
    end

    logic [6:0] ns_cfg_unused;
    always_comb ns_cfg_unused = NS_cfg;

endmodule
