`timescale 1ns/1ps
module NRZ_to_8b (
    input  logic              din,
    output logic signed [7:0]  dout
);

    always_comb begin
        if (din)
            dout =  8'sd127;
        else
            dout = -8'sd127;
    end

endmodule