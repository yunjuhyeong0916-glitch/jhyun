`timescale 1ns/1ps

module traceback_flat #(
    parameter int TB     = 40,
    parameter int MET_W  = 16,
    parameter int NS_MAX = 64
)(
    input  logic [6:0]              NS_cfg,
    input  logic [NS_MAX*MET_W-1:0] pm_flat,
    input  logic [TB*NS_MAX*6-1:0]  state_mem_flat,
    input  logic [TB*NS_MAX*3-1:0]  sym_mem_flat,
    output logic [2:0]              decided_sym
);

    integer i, t;
    logic [5:0] best_state;
    logic [5:0] tb_state;
    logic [MET_W-1:0] pm_i;
    logic [MET_W-1:0] pm_best;

    function automatic logic [5:0] get_state(
        input logic [TB*NS_MAX*6-1:0] bus,
        input int depth,
        input int state_idx
    );
        get_state = bus[((depth*NS_MAX)+state_idx)*6 +: 6];
    endfunction

    function automatic logic [2:0] get_sym(
        input logic [TB*NS_MAX*3-1:0] bus,
        input int depth,
        input int state_idx
    );
        get_sym = bus[((depth*NS_MAX)+state_idx)*3 +: 3];
    endfunction

    always_comb begin
        best_state = 6'd0;
        pm_best = pm_flat[0 +: MET_W];

        for (i = 1; i < NS_cfg; i = i + 1) begin
            pm_i = pm_flat[i*MET_W +: MET_W];
            if (pm_i < pm_best) begin
                pm_best = pm_i;
                best_state = i[5:0];
            end
        end

        tb_state = best_state;
        for (t = 0; t < TB-1; t = t + 1)
            tb_state = get_state(state_mem_flat, t, tb_state);

        decided_sym = get_sym(sym_mem_flat, TB-1, tb_state);
    end

endmodule
