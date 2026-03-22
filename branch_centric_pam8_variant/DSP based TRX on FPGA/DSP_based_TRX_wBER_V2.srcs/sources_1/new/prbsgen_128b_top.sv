module prbsgen_128b_top (
    input  logic         rstb,
    input  logic         i_clk,
    input  logic [1:0]   sel_prbs,
    output logic [127:0] dout
);

    logic [30:0] state0, state1, state2;
    logic [63:0] prbs64_0, prbs64_1;

    // ---- PRBS64 #0 : first 64 bits ----
    prbsgen_64b u_prbs64_0 (
        .rstb        (rstb),
        .i_clk       (i_clk),
        .sel_prbs    (sel_prbs),
        .ext_ptrn_en (1'b0),
        .ext_ptrn    ('0),
        .state_in_en (1'b1),
        .state_in    (state0),
        .state_out   (state1),
        .dout        (prbs64_0)
    );

    // ---- PRBS64 #1 : next 64 bits ----
    prbsgen_64b u_prbs64_1 (
        .rstb        (rstb),
        .i_clk       (i_clk),
        .sel_prbs    (sel_prbs),
        .ext_ptrn_en (1'b0),
        .ext_ptrn    ('0),
        .state_in_en (1'b1),
        .state_in    (state1),
        .state_out   (state2),
        .dout        (prbs64_1)
    );

    // ---- state management ----
    always_ff @(posedge i_clk or negedge rstb) begin
        if (!rstb) begin
            // same seed policy
            state0 <= 31'h7FFF_FFFF;
        end else begin
            state0 <= state2;   // advance by 128 steps per cycle
        end
    end

    assign dout = {prbs64_1, prbs64_0};

endmodule