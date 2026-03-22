`timescale 1ns/1ps

// ============================================================================
// TX_PRBS_PAM4_TOP_64LANE (PRBS128 VERSION)
// - 1x PRBS128 -> 128 bits per cycle (time-contiguous)
// - PAM4 mapping: 2 bits -> 1 symbol
// - 64 symbols per cycle (64 lanes)
// ============================================================================

module TX_PRBS_PAM4_TOP_128B_64LANE (
    input  wire        rstb,
    input  wire        i_clk,

    // PRBS control (single generator)
    input  wire [1:0]  sel_prbs,
    input  wire        ext_ptrn_en,
    input  wire [127:0] ext_ptrn,

    // ------------------------------------------------------------
    // 64-lane PAM4 output (array)
    // ------------------------------------------------------------
    output logic signed [7:0] dout [0:63]
);

    // ------------------------------------------------------------
    // PRBS128 generator (time-sequential)
    // ------------------------------------------------------------
    wire [127:0] prbs128_q;

    prbsgen_128b u_prbs128 (
        .rstb        (rstb),
        .i_clk       (i_clk),
        .sel_prbs    (sel_prbs),
        .ext_ptrn_en (ext_ptrn_en),
        .ext_ptrn    (ext_ptrn),
        .dout        (prbs128_q)
    );

    // ------------------------------------------------------------
    // PAM4 mapping
    //   lane i uses {prbs128[2*i+1], prbs128[2*i]}
    // ------------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : GEN_PAM4
            wire [1:0] sym2b;
            assign sym2b = { prbs128_q[2*i+1], prbs128_q[2*i] };

            PAM4_2b_to_8b u_pam4 (
                .din  (sym2b),
                .dout (dout[i])
            );
        end
    endgenerate

endmodule