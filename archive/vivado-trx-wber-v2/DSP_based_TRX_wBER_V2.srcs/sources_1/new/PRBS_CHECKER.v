module PRBS_CHECKER (
        input wire clk,
        input wire rstb,
        input [1:0] prbs_sel, // 2'b00 = prbs7, 2'b01 = prbs15, 2'b10 = prbs31
        input wire prbs,
        output reg err
        );

        wire err7, err15, err31;
        prbs7chk prbs7chk (.clk(clk), .rstb(rstb), .prbs(prbs), .err(err7));
        prbs15chk prbs15chk (.clk(clk), .rstb(rstb), .prbs(prbs), .err(err15));
        prbs31chk prbs31chk (.clk(clk), .rstb(rstb), .prbs(prbs), .err(err31));

        always @(*) begin
        case (prbs_sel)
        2'b00: err = err7;
        2'b01: err = err15;
        2'b10: err = err31;
        default: err = 1'b0;
        endcase
        end

endmodule
