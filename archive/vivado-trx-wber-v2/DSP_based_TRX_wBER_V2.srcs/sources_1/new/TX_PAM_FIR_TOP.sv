`timescale 1ns/1ps

// ============================================================================
// TX_PAM_FIR_TOP
// - PRBS64 x3 기반 NRZ / PAM4 / PAM8
// - FIR_8TAP_TRANSPOSED_64LANE 적용
// - FFE bypass 지원
// ============================================================================

module TX_PAM_FIR_TOP (
    input  wire        rstb,
    input  wire        i_clk,
    input  wire        ffe_en,

    // PRBS control
    input  wire [1:0]  sel_prbs,

    // modulation mode
    // 00 = NRZ, 01 = PAM4, 10 = PAM8
    input  wire [1:0]  mode,

    // FIR coefficients (Q7)
    input  wire signed [7:0] h0,
    input  wire signed [7:0] h1,
    input  wire signed [7:0] h2,
    input  wire signed [7:0] h3,
    input  wire signed [7:0] h4,
    input  wire signed [7:0] h5,
    input  wire signed [7:0] h6,
    input  wire signed [7:0] h7,

    // 64-lane TX output (time-ordered)
    output logic signed [7:0] dout [0:63]
);

    // ------------------------------------------------------------------------
    // Internal lane arrays
    // ------------------------------------------------------------------------
    logic signed [7:0] tx_raw [0:63];
    logic signed [7:0] tx_fir [0:63];

    // ------------------------------------------------------------------------
    // PRBS + Modulation (NRZ / PAM4 / PAM8)
    // ------------------------------------------------------------------------
    TX_PRBS_MULTI_TOP_64LANE u_prbs_mod (
        .rstb     (rstb),
        .i_clk    (i_clk),
        .sel_prbs (sel_prbs),
        .mode     (mode),
        .dout     (tx_raw)
    );

    // ------------------------------------------------------------------------
    // FIR coefficient packing (h0 = LSB)
    // ------------------------------------------------------------------------
    logic signed [63:0] h_packed;

    always_comb begin
        h_packed = {
            h7, h6, h5, h4, h3, h2, h1, h0
        };
    end

    // ------------------------------------------------------------------------
    // FIR : Transposed, time-unrolled, 64-lane
    // ------------------------------------------------------------------------
    FIR_8TAP_TRANSPOSED_64LANE #(
        .SHIFT(7)
    ) u_fir (
        .clk      (i_clk),
        .rst_n    (rstb),
        .din      (tx_raw),
        .h_packed (h_packed),
        .dout     (tx_fir)
    );

    // ------------------------------------------------------------------------
    // FFE enable mux
    // ------------------------------------------------------------------------
    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : GEN_OUT_MUX
            assign dout[i] = ffe_en ? tx_fir[i] : tx_raw[i];
        end
    endgenerate

endmodule