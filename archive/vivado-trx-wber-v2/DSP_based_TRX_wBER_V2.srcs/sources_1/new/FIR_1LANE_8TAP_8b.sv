`timescale 1ns/1ps
// ============================================================================
// FIR_1LANE_8TAP_8b
// - 1-lane, time-sequential FIR
// - din  : signed 8-bit
// - h    : signed 8-bit (8 taps)
// - dout : signed 8-bit (>>>SHIFT + saturation [-128, +127])
// - Transposed form (DSP48 friendly)
// ============================================================================

module FIR_1LANE_8TAP_8b #(
    parameter int SHIFT = 7
)(
    input  logic               clk,
    input  logic               rst_n,

    input  logic signed [7:0]  din,
    input  logic signed [7:0]  h   [0:7],

    output logic signed [7:0]  dout
);

    // ------------------------------------------------------------------------
    // Internal accumulator
    // 8b x 8b = 16b, + headroom ¡æ 24b
    // ------------------------------------------------------------------------
    logic signed [23:0] acc [0:6];   // 7 regs for 8 taps

    // ------------------------------------------------------------------------
    // 8b ¡¿ 8b ¡æ 24b sign-extended
    // ------------------------------------------------------------------------
    function automatic logic signed [23:0] mul8x8_ext24(
        input logic signed [7:0] a,
        input logic signed [7:0] b
    );
        logic signed [15:0] p;
        begin
            p = a * b;
            return {{(24-16){p[15]}}, p};
        end
    endfunction

    // ------------------------------------------------------------------------
    // Scale + saturation to signed 8b
    // ------------------------------------------------------------------------
    function automatic logic signed [7:0] sat8_shiftN(
        input logic signed [23:0] x
    );
        logic signed [23:0] y;
        begin
            y = x >>> SHIFT;
            if ($signed(y) > 127)   return 8'sd127;
            if ($signed(y) < -128)  return -8'sd128;
            return y[7:0];
        end
    endfunction

    // ------------------------------------------------------------------------
    // Transposed-form FIR
    // y[n] = x*h0 + z1
    // z1  = x*h1 + z2
    // ...
    // z6  = x*h6 + x*h7
    // ------------------------------------------------------------------------
    logic signed [23:0] y_full;
    logic signed [23:0] xh [0:7];

    always_comb begin
        for (int k = 0; k < 8; k++) begin
            xh[k] = mul8x8_ext24(din, h[k]);
        end
        y_full = xh[0] + acc[0];
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int i = 0; i < 7; i++)
                acc[i] <= '0;
            dout <= '0;
        end else begin
            // pipeline regs (high tap ¡æ low tap)
            acc[0] <= xh[1] + acc[1];
            acc[1] <= xh[2] + acc[2];
            acc[2] <= xh[3] + acc[3];
            acc[3] <= xh[4] + acc[4];
            acc[4] <= xh[5] + acc[5];
            acc[5] <= xh[6] + acc[6];
            acc[6] <= xh[7];

            // output register
            dout <= sat8_shiftN(y_full);
        end
    end

endmodule