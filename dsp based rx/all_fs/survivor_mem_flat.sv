`timescale 1ns/1ps

module survivor_mem_flat #(
    parameter int TB     = 40,
    parameter int NS_MAX = 64
)(
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic                   we,
    input  logic [NS_MAX*6-1:0]    state_in_flat,
    input  logic [NS_MAX*3-1:0]    sym_in_flat,
    output logic [TB*NS_MAX*6-1:0] state_mem_flat,
    output logic [TB*NS_MAX*3-1:0] sym_mem_flat
);

    integer t, s;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_mem_flat <= '0;
            sym_mem_flat   <= '0;
        end else if (we) begin
            for (t = TB-1; t > 0; t = t - 1) begin
                for (s = 0; s < NS_MAX; s = s + 1) begin
                    state_mem_flat[((t*NS_MAX)+s)*6 +: 6] <= state_mem_flat[(((t-1)*NS_MAX)+s)*6 +: 6];
                    sym_mem_flat[((t*NS_MAX)+s)*3 +: 3]   <= sym_mem_flat[(((t-1)*NS_MAX)+s)*3 +: 3];
                end
            end

            for (s = 0; s < NS_MAX; s = s + 1) begin
                state_mem_flat[s*6 +: 6] <= state_in_flat[s*6 +: 6];
                sym_mem_flat[s*3 +: 3]   <= sym_in_flat[s*3 +: 3];
            end
        end
    end

endmodule
