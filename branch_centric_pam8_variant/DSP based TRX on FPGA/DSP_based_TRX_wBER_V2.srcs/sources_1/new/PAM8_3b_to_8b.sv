`timescale 1ns/1ps
module PAM8_3b_to_8b (
    input  logic [2:0]         din,
    output logic signed [7:0]  dout
);

    always_comb begin
        case (din)
            3'b000: dout = -8'sd126; // -7
            3'b001: dout = -8'sd90;  // -5
            3'b011: dout = -8'sd54;  // -3
            3'b010: dout = -8'sd18;  // -1
            3'b110: dout =  8'sd18;  // +1
            3'b111: dout =  8'sd54;  // +3
            3'b101: dout =  8'sd90;  // +5
            3'b100: dout =  8'sd126; // +7
            default: dout = -8'sd126;
        endcase
    end

endmodule