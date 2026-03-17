`timescale 1ns/1ps

module acs_rsmlsd #(
    parameter int MET_W  = 16,
    parameter int NS_MAX = 8,
    parameter int M_MAX  = 8
)(
    input  logic                   en,
    input  logic [3:0]             M_cfg,
    input  logic [6:0]             NS_cfg,          // kept for interface compatibility
    input  logic [M_MAX-1:0]       ps_active_mask,  // active previous states
    input  logic [M_MAX-1:0]       ns_active_mask,  // active next states
    input  logic [MET_W-1:0]       pm_in  [NS_MAX],
    input  logic [MET_W-1:0]       bm_in  [NS_MAX][M_MAX], // bm_in[ps][ns]
    output logic [MET_W-1:0]       pm_out [NS_MAX],
    output logic [2:0]             surv_sym   [NS_MAX],
    output logic [5:0]             surv_state [NS_MAX]
);

    localparam logic [MET_W-1:0] INF = '1;

    function automatic logic [MET_W-1:0] sat_add(
        input logic [MET_W-1:0] a,
        input logic [MET_W-1:0] b
    );
        logic [MET_W:0] sum_ext;
        begin
            if (a == INF || b == INF)
                sat_add = INF;
            else begin
                sum_ext = {1'b0,a} + {1'b0,b};
                sat_add = sum_ext[MET_W] ? INF : sum_ext[MET_W-1:0];
            end
        end
    endfunction

    integer ns, ps;
    logic [MET_W-1:0] best_pm, cand;
    logic [5:0] best_ps;

    always_comb begin
        for (ns = 0; ns < NS_MAX; ns++) begin
            pm_out[ns]     = INF;
            surv_sym[ns]   = '0;
            surv_state[ns] = '0;
        end

        if (en) begin
            for (ns = 0; ns < M_cfg; ns++) begin
                if (ns_active_mask[ns]) begin
                    best_pm = INF;
                    best_ps = '0;

                    for (ps = 0; ps < M_cfg; ps++) begin
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
    end

endmodule
