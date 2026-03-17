`timescale 1ns/1ps

// ============================================================================
// TX_PAM4_FIR_TOP (PRBS128 VERSION)
// - 1x PRBS128 (time-contiguous)
// - PAM4 mapping -> 64 lanes (time-sequential meaning)
// - FIR operates on time-ordered samples
// ============================================================================

module TX_PAM4_FIR_TOP_128B (
    input  wire        rstb,
    input  wire        i_clk,
    input  wire        ffe_en,

    // PRBS control (single generator)
    input  wire [1:0]  sel_prbs,
    input  wire        ext_ptrn_en,
    input  wire [127:0] ext_ptrn,

    // FIR coefficients
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
    // PRBS128 + PAM4 encoder (time-sequential lanes)
    // ------------------------------------------------------------------------
    TX_PRBS_PAM4_TOP_128B_64LANE u_prbs_pam4 (
        .rstb        (rstb),
        .i_clk       (i_clk),

        .sel_prbs    (sel_prbs),
        .ext_ptrn_en (ext_ptrn_en),
        .ext_ptrn    (ext_ptrn),

        .dout        (tx_raw)
    );

    // ------------------------------------------------------------------------
    // FIR coefficient array
    // ------------------------------------------------------------------------
    logic signed [7:0] h [0:7];
    assign h[0] = h0;
    assign h[1] = h1;
    assign h[2] = h2;
    assign h[3] = h3;
    assign h[4] = h4;
    assign h[5] = h5;
    assign h[6] = h6;
    assign h[7] = h7;

    // ------------------------------------------------------------------------
    // FIR
    // ※ 네가 말한 대로 "직렬 FIR"이면 여기서 구조 변경됨
    // ------------------------------------------------------------------------
    FIR_64LANE_8TAP_8b u_fir (
        .clk   (i_clk),
        .rst_n (rstb),
        .din   (tx_raw),
        .h     (h),
        .dout  (tx_fir)
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