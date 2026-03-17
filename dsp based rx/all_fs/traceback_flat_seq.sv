`timescale 1ns/1ps

module traceback_flat_seq #(
    parameter int TB     = 40,
    parameter int MET_W  = 16,
    parameter int NS_MAX = 64
)(
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic                    start,
    input  logic [6:0]              NS_cfg,
    input  logic [NS_MAX*MET_W-1:0] pm_flat,
    input  logic [TB*NS_MAX*6-1:0]  state_mem_flat,
    input  logic [TB*NS_MAX*3-1:0]  sym_mem_flat,
    output logic                    busy,
    output logic                    done,
    output logic [2:0]              decided_sym
);

    localparam int STEP_W = (TB <= 2) ? 1 : $clog2(TB);

    logic [TB*NS_MAX*6-1:0]  state_mem_snap;
    logic [TB*NS_MAX*3-1:0]  sym_mem_snap;
    logic [5:0] best_state_next;
    logic [5:0] tb_state;
    logic [STEP_W-1:0] step_idx;

    integer i;
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
        best_state_next = 6'd0;
        pm_best = pm_flat[0 +: MET_W];
        for (i = 1; i < NS_cfg; i = i + 1) begin
            pm_i = pm_flat[i*MET_W +: MET_W];
            if (pm_i < pm_best) begin
                pm_best = pm_i;
                best_state_next = i[5:0];
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_mem_snap <= '0;
            sym_mem_snap   <= '0;
            busy           <= 1'b0;
            done           <= 1'b0;
            tb_state       <= '0;
            step_idx       <= '0;
            decided_sym    <= '0;
        end else begin
            done <= 1'b0;

            if (start && !busy) begin
                state_mem_snap <= state_mem_flat;
                sym_mem_snap   <= sym_mem_flat;
                tb_state       <= best_state_next;
                step_idx       <= '0;
                busy           <= 1'b1;

                if (TB <= 1) begin
                    decided_sym <= get_sym(sym_mem_flat, 0, best_state_next);
                    busy        <= 1'b0;
                    done        <= 1'b1;
                end
            end else if (busy) begin
                if (step_idx < TB-2) begin
                    tb_state <= get_state(state_mem_snap, step_idx, tb_state);
                    step_idx <= step_idx + 1'b1;
                end else begin
                    decided_sym <= get_sym(sym_mem_snap, TB-1, get_state(state_mem_snap, TB-2, tb_state));
                    busy        <= 1'b0;
                    done        <= 1'b1;
                end
            end
        end
    end

endmodule
