`timescale 1ns/1ps

// ============================================================================
// FIR_8TAP_TRANSPOSED_64LANE (TIME-UNROLLED, 64 samples/cycle)
// - Immediate coefficient apply (NO coeff register)
// - Transposed-form, time-unrolled (din[i]=x[n+i])
// - Output registered 1 UI
// ============================================================================

module FIR_8TAP_TRANSPOSED_64LANE #(
    parameter int SHIFT = 7
)(
    input  logic               clk,
    input  logic               rst_n,

    input  logic signed [7:0]   din      [0:63],
    input  logic signed [63:0]  h_packed,        // IMMEDIATE apply (h0=LSB)
    output logic signed [7:0]   dout     [0:63]
);

    localparam int LANES = 64;
    localparam int NTAPS = 8;

    // ------------------------------------------------------------
    // 1) UNPACK COEFFICIENTS (IMMEDIATE)
    //    h[0]=h_packed[7:0], ..., h[7]=h_packed[63:56]
    // ------------------------------------------------------------
    logic signed [7:0] h [0:NTAPS-1];
    always_comb begin
        for (int k = 0; k < NTAPS; k++)
            h[k] = h_packed[8*k +: 8];
    end

    // ------------------------------------------------------------
    // 2) TRANSPOSED FIR STATE (per-tap, across cycles)
    // ------------------------------------------------------------
    logic signed [23:0] s_reg     [0:NTAPS-2];
    logic signed [23:0] stage_sum [0:NTAPS-1][0:LANES-1];

    // ------------------------------------------------------------
    // 3) MULTIPLY + EXTEND
    // ------------------------------------------------------------
    function automatic logic signed [23:0] extmul8(
        input logic signed [7:0] a,
        input logic signed [7:0] b
    );
        logic signed [15:0] p;
        begin
            p = a * b;
            return {{8{p[15]}}, p};
        end
    endfunction

    // ------------------------------------------------------------
    // 4) SATURATION + SHIFT
    // ------------------------------------------------------------
    function automatic logic signed [7:0] sat8_shift(
        input logic signed [23:0] x
    );
        logic signed [23:0] y;
        begin
            y = x >>> SHIFT;
            if ($signed(y) >  127) return  8'sd127;
            if ($signed(y) < -128) return -8'sd128;
            return y[7:0];
        end
    endfunction

    // ------------------------------------------------------------
    // 5) COMBINATIONAL FIR (time-unrolled)
    // ------------------------------------------------------------
    always_comb begin
        // last tap
        for (int i = 0; i < LANES; i++)
            stage_sum[NTAPS-1][i] = extmul8(din[i], h[NTAPS-1]);

        // middle taps
        for (int k = NTAPS-2; k >= 1; k--) begin
            stage_sum[k][0] = extmul8(din[0], h[k]) + s_reg[k];
            for (int i = 1; i < LANES; i++)
                stage_sum[k][i] = extmul8(din[i], h[k]) + stage_sum[k+1][i-1];
        end

        // tap 0
        stage_sum[0][0] = extmul8(din[0], h[0]) + s_reg[0];
        for (int i = 1; i < LANES; i++)
            stage_sum[0][i] = extmul8(din[i], h[0]) + stage_sum[1][i-1];
    end

    // ------------------------------------------------------------
    // 6) STATE UPDATE (across cycles)
    // ------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int k = 0; k < NTAPS-1; k++)
                s_reg[k] <= '0;
        end else begin
            for (int k = 0; k < NTAPS-1; k++)
                s_reg[k] <= stage_sum[k+1][LANES-1];
        end
    end

    // ------------------------------------------------------------
    // 7) OUTPUT REGISTER (1 UI)
    // ------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            dout <= '{default:'0};
        else
            for (int i = 0; i < LANES; i++)
                dout[i] <= sat8_shift(stage_sum[0][i]);
    end

endmodule
