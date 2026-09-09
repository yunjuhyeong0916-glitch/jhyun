`timescale 1ns/1ps

// ============================================================================
// TX_PRBS_PAM4_TOP_64LANE (ARRAY OUTPUT VERSION)
// - 2x PRBS64 -> 128 bits per cycle
// - PAM4 mapping: 2 bits -> 1 symbol
// - 64 symbols per cycle (64 lanes)
// - Lane array output (no scalar breakout)
// ============================================================================

module TX_PRBS_PAM4_TOP_64LANE (
    input  wire        rstb,
    input  wire        i_clk,

    input  wire [1:0]  sel_prbs64_a,
    input  wire        ext_ptrn_en64_a,
    input  wire [63:0] ext_ptrn64_a,

    input  wire [1:0]  sel_prbs64_b,
    input  wire        ext_ptrn_en64_b,
    input  wire [63:0] ext_ptrn64_b,

    // ------------------------------------------------------------
    // 64-lane PAM4 output (array)
    // ------------------------------------------------------------
    output logic signed [7:0] dout [0:63]
);

    // ------------------------------------------------------------
    // Two PRBS64 generators => 128 bits total per cycle
    // ------------------------------------------------------------
    wire [63:0] prbs64_a_q;
    wire [63:0] prbs64_b_q;

    prbsgen_64b u_prbs64_a (
        .rstb        (rstb),
        .i_clk       (i_clk),
        .sel_prbs    (sel_prbs64_a),
        .ext_ptrn_en (ext_ptrn_en64_a),
        .ext_ptrn    (ext_ptrn64_a),
        .dout        (prbs64_a_q)
    );

    prbsgen_64b u_prbs64_b (
        .rstb        (rstb),
        .i_clk       (i_clk),
        .sel_prbs    (sel_prbs64_b),
        .ext_ptrn_en (ext_ptrn_en64_b),
        .ext_ptrn    (ext_ptrn64_b),
        .dout        (prbs64_b_q)
    );

    // ------------------------------------------------------------
    // Concatenate for lane mapping
    //   bits128[ 63:0]  = prbs64_a
    //   bits128[127:64] = prbs64_b
    // ------------------------------------------------------------
    wire [127:0] bits128;
    assign bits128 = {prbs64_b_q, prbs64_a_q};

    // ------------------------------------------------------------
    // PAM4 mapping
    //   lane i uses {bits128[2*i+1], bits128[2*i]}
    // ------------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : GEN_PAM4
            wire [1:0] sym2b;
            assign sym2b = { bits128[2*i+1], bits128[2*i] };

            PAM4_2b_to_8b u_pam4 (
                .din  (sym2b),
                .dout (dout[i])
            );
        end
    endgenerate

endmodule
