`timescale 1ns/1ps

module survivor_mem #(
    parameter int TB     = 40,
    parameter int NS_MAX = 64
)(
    input  logic clk,
    input  logic rst_n,
    input  logic we,

    input  logic [5:0] state_in [NS_MAX],
    input  logic [2:0] sym_in   [NS_MAX],

    output logic [5:0] state_mem [TB-1:0][NS_MAX],
    output logic [2:0] sym_mem   [TB-1:0][NS_MAX]
);

    integer t, s;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (t = 0; t < TB; t = t + 1) begin
                for (s = 0; s < NS_MAX; s = s + 1) begin
                    state_mem[t][s] <= 6'd0;
                    sym_mem[t][s]   <= 3'd0;
                end
            end
        end else if (we) begin
            for (t = TB-1; t > 0; t = t - 1) begin
                for (s = 0; s < NS_MAX; s = s + 1) begin
                    state_mem[t][s] <= state_mem[t-1][s];
                    sym_mem[t][s]   <= sym_mem[t-1][s];
                end
            end

            for (s = 0; s < NS_MAX; s = s + 1) begin
                state_mem[0][s] <= state_in[s];
                sym_mem[0][s]   <= sym_in[s];
            end
        end
    end

endmodule
