`timescale 1ns/1ps

module traceback #(
    parameter int TB     = 40,
    parameter int MET_W  = 16,
    parameter int NS_MAX = 64
)(
    input  logic [6:0]       NS_cfg,
    input  logic [MET_W-1:0] pm [NS_MAX],
    input  logic [5:0]       state_mem [TB-1:0][NS_MAX],
    input  logic [2:0]       sym_mem   [TB-1:0][NS_MAX],

    output logic [2:0] decided_sym
);

    integer i, t;
    logic [5:0] best_state;
    logic [5:0] tb_state;

    always_comb begin
        best_state = 6'd0;

        for (i = 1; i < NS_cfg; i = i + 1) begin
            if (pm[i] < pm[best_state])
                best_state = i[5:0];
        end

        tb_state = best_state;
        for (t = 0; t < TB-1; t = t + 1)
            tb_state = state_mem[t][tb_state];

        decided_sym = sym_mem[TB-1][tb_state];
    end

endmodule
