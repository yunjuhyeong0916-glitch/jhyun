`timescale 1ns/1ps
// ============================================================================
// 64x16b -> 64x8b truncation (>>>8)
// Inverse of TX <<<8 full-scale mapping
// ============================================================================
module trunc16_to_8_64lane_arr (
    input  wire signed [15:0]   din16 [0:63],
    output wire signed [7:0]    dout8 [0:63]
);

    genvar k;
    generate
        for (k = 0; k < 64; k = k + 1) begin : G_TRUNC
            assign dout8[k] = din16[k] >>> 8;
        end
    endgenerate

endmodule