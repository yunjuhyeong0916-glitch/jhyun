`timescale 1ns/1ps

module PAM4_2b_to_8b (
    input  logic [1:0]          din,
    output logic signed [7:0]   dout
);

    always_comb begin
        case (din)
            2'b00: dout = -8'sd127;  // Level -3
            2'b01: dout = -8'sd42;   // Level -1
            2'b11: dout =  8'sd42;   // Level +1
            2'b10: dout =  8'sd127;  // Level +3
            default: dout = -8'sd127;
        endcase
    end

endmodule

