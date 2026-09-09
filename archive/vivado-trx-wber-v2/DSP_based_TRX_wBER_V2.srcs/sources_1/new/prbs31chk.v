module prbs31chk (
        clk,
        rstb,
        prbs,
        err
        );

        input wire clk, rstb;
        input wire prbs;
        output wire err;

        reg prbs_in;
        reg [30:0] prbs_state;
        wire i;

        always @(posedge clk or negedge rstb) begin
                if (!rstb) begin
                        prbs_state <= 31'b0;
                        prbs_in <= 1'b0;
                end
                else begin
                        prbs_in <= prbs;
                        prbs_state <= {prbs_state[29:0], prbs_in};
                end
        end

        assign i = prbs_state[30] ^ prbs_state[27];
        assign err = i^prbs_in;

endmodule
