module prbs7chk (
        clk,
        rstb,
        prbs,
        err
        );

        input wire clk, rstb;
        input wire prbs;
        output wire err;

        reg prbs_in;
        reg [6:0] prbs_state;
        wire i;

        always @(posedge clk or negedge rstb) begin
            if (!rstb) begin
                prbs_state <= 7'b0000000;
                prbs_in <= 1'b0;
            end
            else begin
                prbs_in <= prbs;
                prbs_state <= {prbs_state[5:0], prbs_in};
            end
        end

        assign i = prbs_state[6] ^ prbs_state[5];
        assign err = i^prbs_in;

endmodule
