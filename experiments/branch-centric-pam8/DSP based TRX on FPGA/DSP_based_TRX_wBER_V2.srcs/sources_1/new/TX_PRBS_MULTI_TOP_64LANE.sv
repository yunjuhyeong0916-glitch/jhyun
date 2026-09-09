`timescale 1ns/1ps
// ============================================================================
// TX_PRBS_MULTI_TOP_64LANE  (MODE-DEPENDENT ADVANCE, WIDTH-SPLIT VERSION)
// - 3x PRBS64 chained -> provides contiguous window up to 192b
// - Explicit split views:
//     prbs64  = prbs64_0                  ( 64b)
//     prbs128 = {prbs64_1, prbs64_0}      (128b)
//     prbs192 = {prbs64_2, prbs64_1, prbs64_0} (192b)
// - Mode-selectable modulation:
//     00 : NRZ   (1 bit / symbol)  -> consume  64 bits
//     01 : PAM4  (2 bits / symbol) -> consume 128 bits
//     10 : PAM8  (3 bits / symbol) -> consume 192 bits
// - Always outputs 64 lanes of signed [7:0]
// ============================================================================

module TX_PRBS_MULTI_TOP_64LANE (
    input  wire        rstb,
    input  wire        i_clk,

    // PRBS control
    input  wire [1:0]  sel_prbs,

    // mode select
    // 00 = NRZ, 01 = PAM4, 10 = PAM8
    input  wire [1:0]  mode,

    // 64-lane output
    output logic signed [7:0] dout [0:63]
);

    // ------------------------------------------------------------
    // PRBS64 x3 (state chained)
    // ------------------------------------------------------------
    logic [30:0] state0, state1, state2, state3;
    wire  [63:0] prbs64_0, prbs64_1, prbs64_2;

    // steps 0~63
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

    // steps 64~127
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

    // steps 128~191
    prbsgen_64b u_prbs64_2 (
        .rstb        (rstb),
        .i_clk       (i_clk),
        .sel_prbs    (sel_prbs),
        .ext_ptrn_en (1'b0),
        .ext_ptrn    ('0),
        .state_in_en (1'b1),
        .state_in    (state2),
        .state_out   (state3),
        .dout        (prbs64_2)
    );

    // ------------------------------------------------------------
    // Mode-dependent PRBS advance (consume bits per UI-frame)
    // ------------------------------------------------------------
    always_ff @(posedge i_clk or negedge rstb) begin
        if (!rstb) begin
            state0 <= 31'h7FFF_FFFF;   // PRBS31 default seed
        end else begin
            unique case (mode)
                2'b00: state0 <= state1; // NRZ  :  64-step advance
                2'b01: state0 <= state2; // PAM4 : 128-step advance
                2'b10: state0 <= state3; // PAM8 : 192-step advance
                default: state0 <= state1;
            endcase
        end
    end

    // ------------------------------------------------------------
    // Explicit width-split PRBS windows
    // ------------------------------------------------------------
    wire [63:0]  prbs64;
    wire [127:0] prbs128;
    wire [191:0] prbs192;

    assign prbs64  = prbs64_0;
    assign prbs128 = { prbs64_1, prbs64_0 };
    assign prbs192 = { prbs64_2, prbs64_1, prbs64_0 };

    // ------------------------------------------------------------
    // Symbol slicing + mapper instances
    // - IMPORTANT: slice only from the corresponding width
    // ------------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : GEN_LANE

            // ---------- NRZ (1b) ----------
            wire nrz_bit = prbs64[i];
            wire signed [7:0] nrz_8b;
            NRZ_to_8b u_nrz (
                .din  (nrz_bit),
                .dout (nrz_8b)
            );

            // ---------- PAM4 (2b) ----------
            wire [1:0] pam4_sym = { prbs128[2*i+1], prbs128[2*i] };
            wire signed [7:0] pam4_8b;
            PAM4_2b_to_8b u_pam4 (
                .din  (pam4_sym),
                .dout (pam4_8b)
            );

            // ---------- PAM8 (3b) ----------
            wire [2:0] pam8_sym = {
                prbs192[3*i+2],
                prbs192[3*i+1],
                prbs192[3*i]
            };
            wire signed [7:0] pam8_8b;
            PAM8_3b_to_8b u_pam8 (
                .din  (pam8_sym),
                .dout (pam8_8b)
            );

            // ---------- mode select ----------
            always_comb begin
                unique case (mode)
                    2'b00: dout[i] = nrz_8b;
                    2'b01: dout[i] = pam4_8b;
                    2'b10: dout[i] = pam8_8b;
                    default: dout[i] = nrz_8b;
                endcase
            end

        end
    endgenerate

endmodule