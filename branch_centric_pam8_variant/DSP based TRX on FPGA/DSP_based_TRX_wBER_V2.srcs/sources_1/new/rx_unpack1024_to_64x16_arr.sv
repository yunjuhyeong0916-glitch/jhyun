`timescale 1ns/1ps
// ============================================================================
// 1024b -> 64x16b unpack (FIFO ordering compensation)
// Inverse of TX pack rule:
//   out_data_16b[(7-g)*128 + i*16 +:16] <= tx16[g*8+i];
// ============================================================================
module rx_unpack1024_to_64x16_arr (
    input  wire [1023:0]        in_data_16b,
    output wire signed [15:0]   rx16 [0:63]
);

    genvar g, i;
    generate
        for (g = 0; g < 8; g = g + 1) begin : G_UNP_G
            for (i = 0; i < 8; i = i + 1) begin : G_UNP_I
                assign rx16[g*8 + i] =
                    $signed(in_data_16b[(7-g)*128 + i*16 +: 16]);
            end
        end
    endgenerate

endmodule