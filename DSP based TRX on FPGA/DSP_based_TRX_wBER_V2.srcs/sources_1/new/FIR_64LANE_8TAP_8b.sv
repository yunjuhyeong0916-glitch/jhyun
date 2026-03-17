`timescale 1ns/1ps
// ============================================================================
// FIR_64LANE_8TAP_8b
// - 64 lanes in parallel (each lane has independent state)
// - din  : signed 8-bit [0:63]
// - h    : shared signed 8-bit taps [0:7]
// - dout : signed 8-bit [0:63]
// ============================================================================

module FIR_64LANE_8TAP_8b #(
    parameter int SHIFT = 7
)(
    input  logic              clk,
    input  logic              rst_n,

    input  logic signed [7:0] din  [0:63],
    input  logic signed [7:0] h    [0:7],

    output logic signed [7:0] dout [0:63]
);

    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : GEN_FIR_LANE
            FIR_1LANE_8TAP_8b #(
                .SHIFT(SHIFT)
            ) u_fir (
                .clk   (clk),
                .rst_n (rst_n),
                .din   (din[i]),
                .h     (h),
                .dout  (dout[i])
            );
        end
    endgenerate

endmodule