`timescale 1ns/1ps

module fir8tap_transposed_32lane_ref #(
    parameter int SHIFT = 7
)(
    input  logic               clk,
    input  logic               rst_n,
    input  logic signed [7:0]  din  [0:31],
    input  logic signed [63:0] h_packed,
    output logic signed [7:0]  dout [0:31]
);
    localparam int LANES = 32;
    localparam int NTAPS = 8;
    localparam int COEFF_GROUPS = 4;
    localparam int LANES_PER_COEFF_GROUP = LANES / COEFF_GROUPS;

    logic signed [17:0] din_ext [0:LANES-1];
    logic signed [17:0] h_ext_q [0:COEFF_GROUPS-1][0:NTAPS-1];
    logic signed [47:0] s_reg   [0:NTAPS-2];
    logic signed [47:0] mac0_q  [0:LANES-1];
    logic signed [47:0] mac0 [0:LANES-1];
    logic signed [47:0] mac1 [0:LANES-1];
    logic signed [47:0] mac2 [0:LANES-1];
    logic signed [47:0] mac3 [0:LANES-1];
    logic signed [47:0] mac4 [0:LANES-1];
    logic signed [47:0] mac5 [0:LANES-1];
    logic signed [47:0] mac6 [0:LANES-1];
    logic signed [47:0] mac7 [0:LANES-1];

    function automatic logic signed [7:0] sat8_shift48(input logic signed [47:0] x);
        logic signed [47:0] y;
        begin
            y = x >>> SHIFT;
            if (y > 48'sd127)       sat8_shift48 = 8'sd127;
            else if (y < -48'sd128) sat8_shift48 = -8'sd128;
            else                    sat8_shift48 = y[7:0];
        end
    endfunction

    always_ff @(posedge clk or negedge rst_n) begin
        int g, k;
        if (!rst_n) begin
            for (g = 0; g < COEFF_GROUPS; g++)
                for (k = 0; k < NTAPS; k++)
                    h_ext_q[g][k] <= '0;
        end else begin
            for (g = 0; g < COEFF_GROUPS; g++)
                for (k = 0; k < NTAPS; k++)
                    h_ext_q[g][k] <= $signed({{10{h_packed[(k*8)+7]}}, h_packed[(k*8) +: 8]});
        end
    end

    always_comb begin
        int i;
        for (i = 0; i < LANES; i++)
            din_ext[i] = $signed({{10{din[i][7]}}, din[i]});

        for (i = 0; i < LANES; i++)
            mac7[i] = din_ext[i] * h_ext_q[i / LANES_PER_COEFF_GROUP][7];

        mac6[0] = din_ext[0] * h_ext_q[0][6] + s_reg[6];
        for (i = 1; i < LANES; i++)
            mac6[i] = din_ext[i] * h_ext_q[i / LANES_PER_COEFF_GROUP][6] + mac7[i-1];

        mac5[0] = din_ext[0] * h_ext_q[0][5] + s_reg[5];
        for (i = 1; i < LANES; i++)
            mac5[i] = din_ext[i] * h_ext_q[i / LANES_PER_COEFF_GROUP][5] + mac6[i-1];

        mac4[0] = din_ext[0] * h_ext_q[0][4] + s_reg[4];
        for (i = 1; i < LANES; i++)
            mac4[i] = din_ext[i] * h_ext_q[i / LANES_PER_COEFF_GROUP][4] + mac5[i-1];

        mac3[0] = din_ext[0] * h_ext_q[0][3] + s_reg[3];
        for (i = 1; i < LANES; i++)
            mac3[i] = din_ext[i] * h_ext_q[i / LANES_PER_COEFF_GROUP][3] + mac4[i-1];

        mac2[0] = din_ext[0] * h_ext_q[0][2] + s_reg[2];
        for (i = 1; i < LANES; i++)
            mac2[i] = din_ext[i] * h_ext_q[i / LANES_PER_COEFF_GROUP][2] + mac3[i-1];

        mac1[0] = din_ext[0] * h_ext_q[0][1] + s_reg[1];
        for (i = 1; i < LANES; i++)
            mac1[i] = din_ext[i] * h_ext_q[i / LANES_PER_COEFF_GROUP][1] + mac2[i-1];

        mac0[0] = din_ext[0] * h_ext_q[0][0] + s_reg[0];
        for (i = 1; i < LANES; i++)
            mac0[i] = din_ext[i] * h_ext_q[i / LANES_PER_COEFF_GROUP][0] + mac1[i-1];
    end

    always_ff @(posedge clk or negedge rst_n) begin
        int i, k;
        if (!rst_n) begin
            for (k = 0; k < NTAPS-1; k++)
                s_reg[k] <= '0;
            for (i = 0; i < LANES; i++) begin
                mac0_q[i] <= '0;
                dout[i] <= '0;
            end
        end else begin
            s_reg[0] <= mac1[LANES-1];
            s_reg[1] <= mac2[LANES-1];
            s_reg[2] <= mac3[LANES-1];
            s_reg[3] <= mac4[LANES-1];
            s_reg[4] <= mac5[LANES-1];
            s_reg[5] <= mac6[LANES-1];
            s_reg[6] <= mac7[LANES-1];
            for (i = 0; i < LANES; i++) begin
                mac0_q[i] <= mac0[i];
                dout[i] <= sat8_shift48(mac0_q[i]);
            end
        end
    end
endmodule

module tb_tx_fir32_systolic_equiv;
    localparam int LANES = 32;
    localparam int MAX_LAT = 16;
    localparam int DUT_EXTRA_LAT = 7;
    localparam int NUM_CYCLES = 800;

    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic signed [7:0] din [0:LANES-1];
    logic signed [63:0] h_packed;
    logic signed [7:0] dout_ref [0:LANES-1];
    logic signed [7:0] dout_dut [0:LANES-1];
    logic signed [7:0] ref_delay [0:MAX_LAT][0:LANES-1];
    int errors = 0;

    always #4 clk = ~clk;

    fir8tap_transposed_32lane_ref u_ref (
        .clk(clk),
        .rst_n(rst_n),
        .din(din),
        .h_packed(h_packed),
        .dout(dout_ref)
    );

    FIR_8TAP_TRANSPOSED_32LANE u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .din(din),
        .h_packed(h_packed),
        .dout(dout_dut)
    );

    function automatic logic signed [7:0] rand_s8(input int salt);
        int unsigned r;
        begin
            r = $urandom(salt);
            rand_s8 = $signed(r[7:0]);
        end
    endfunction

    task automatic drive_random(input int cyc);
        int lane;
        int tap;
        logic signed [7:0] coeff;
        begin
            for (lane = 0; lane < LANES; lane++)
                din[lane] = rand_s8((cyc * 131) + lane);

            if ((cyc % 5) == 0) begin
                for (tap = 0; tap < 8; tap++) begin
                    coeff = rand_s8((cyc * 17) + tap);
                    h_packed[(tap*8) +: 8] = coeff;
                end
            end
        end
    endtask

    task automatic shift_and_check(input int cyc);
        int d;
        int lane;
        begin
            for (d = MAX_LAT; d > 0; d--)
                for (lane = 0; lane < LANES; lane++)
                    ref_delay[d][lane] = ref_delay[d-1][lane];
            for (lane = 0; lane < LANES; lane++)
                ref_delay[0][lane] = dout_ref[lane];

            if (cyc > 80) begin
                for (lane = 0; lane < LANES; lane++) begin
                    if (dout_dut[lane] !== ref_delay[DUT_EXTRA_LAT][lane]) begin
                        if (errors < 20) begin
                            $display("MISMATCH cyc=%0d lane=%0d dut=%0d ref_dly=%0d",
                                     cyc, lane, dout_dut[lane], ref_delay[DUT_EXTRA_LAT][lane]);
                        end
                        errors++;
                    end
                end
            end
        end
    endtask

    initial begin
        int cyc;
        int lane;
        int d;
        h_packed = '0;
        for (lane = 0; lane < LANES; lane++)
            din[lane] = '0;
        for (d = 0; d <= MAX_LAT; d++)
            for (lane = 0; lane < LANES; lane++)
                ref_delay[d][lane] = '0;

        repeat (8) @(posedge clk);
        rst_n = 1'b1;

        for (cyc = 0; cyc < NUM_CYCLES; cyc++) begin
            @(negedge clk);
            drive_random(cyc);
            @(posedge clk);
            #1;
            shift_and_check(cyc);
        end

        if (errors == 0) begin
            $display("TX_FIR32_SYSTOLIC_EQUIV PASS extra_latency=%0d cycles checked=%0d",
                     DUT_EXTRA_LAT, NUM_CYCLES);
            $finish;
        end else begin
            $display("TX_FIR32_SYSTOLIC_EQUIV FAIL errors=%0d", errors);
            $fatal(1);
        end
    end
endmodule
