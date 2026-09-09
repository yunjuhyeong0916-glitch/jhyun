`timescale 1ns/1ps

module FIR_Q6_21TAP_GROUP_PIPE_32LANE_LEGACY #(
    parameter int SHIFT = 6
)(
    input  logic clk,
    input  logic rst_n,
    input  logic signed [(32*8)-1:0]      din_flat,
    input  logic signed [(21*8)-1:0]      h_packed,
    output wire signed [(32*8)-1:0]       dout_flat
);
    localparam int LANES = 32;
    localparam int NTAPS = 21;
    localparam int HIST = NTAPS - 1;
    localparam int ACC_W = 48;
    localparam int EXT_W = 18;

    logic signed [(HIST*8)-1:0] hist_reg;
    logic signed [EXT_W-1:0] h_ext_q [0:NTAPS-1];
    logic signed [EXT_W-1:0] sample_ext_q [0:NTAPS-1][0:LANES-1];
    (* use_dsp = "yes" *) logic signed [ACC_W-1:0] prod_q [0:NTAPS-1][0:LANES-1];
    logic signed [ACC_W-1:0] sum0_q [0:LANES-1];
    logic signed [ACC_W-1:0] sum1_q [0:LANES-1];
    logic signed [ACC_W-1:0] sum2_q [0:LANES-1];
    logic signed [ACC_W-1:0] sum2_dly_q [0:LANES-1];
    logic signed [ACC_W-1:0] sum01_q [0:LANES-1];
    logic signed [7:0] dout_arr [0:LANES-1];

    function automatic logic signed [7:0] sample_at(
        input logic signed [(LANES*8)-1:0] frame_flat,
        input logic signed [(HIST*8)-1:0] hist_flat,
        input int lane,
        input int tap
    );
        begin
            if (lane >= tap)
                sample_at = $signed(frame_flat[((lane - tap)*8) +: 8]);
            else
                sample_at = $signed(hist_flat[((tap - lane - 1)*8) +: 8]);
        end
    endfunction

    function automatic logic signed [EXT_W-1:0] sample18_at(
        input logic signed [(LANES*8)-1:0] frame_flat,
        input logic signed [(HIST*8)-1:0] hist_flat,
        input int lane,
        input int tap
    );
        logic signed [7:0] sample8;
        begin
            sample8 = sample_at(frame_flat, hist_flat, lane, tap);
            sample18_at = $signed({{10{sample8[7]}}, sample8});
        end
    endfunction

    function automatic logic signed [7:0] sat8_shift48(
        input logic signed [ACC_W-1:0] x
    );
        logic signed [ACC_W-1:0] y;
        begin
            y = x >>> SHIFT;
            if (y > 48'sd127)       sat8_shift48 = 8'sd127;
            else if (y < -48'sd128) sat8_shift48 = -8'sd128;
            else                    sat8_shift48 = y[7:0];
        end
    endfunction

    always_ff @(posedge clk or negedge rst_n) begin
        int lane;
        int tap;
        int hist_i;
        if (!rst_n) begin
            hist_reg <= '0;
            for (tap = 0; tap < NTAPS; tap = tap + 1) begin
                h_ext_q[tap] <= '0;
                for (lane = 0; lane < LANES; lane = lane + 1) begin
                    sample_ext_q[tap][lane] <= '0;
                    prod_q[tap][lane] <= '0;
                end
            end
            for (lane = 0; lane < LANES; lane = lane + 1) begin
                sum0_q[lane] <= '0;
                sum1_q[lane] <= '0;
                sum2_q[lane] <= '0;
                sum2_dly_q[lane] <= '0;
                sum01_q[lane] <= '0;
                dout_arr[lane] <= '0;
            end
        end else begin
            for (tap = 0; tap < NTAPS; tap = tap + 1) begin
                h_ext_q[tap] <= $signed({{10{h_packed[(tap*8)+7]}}, h_packed[(tap*8) +: 8]});
                for (lane = 0; lane < LANES; lane = lane + 1) begin
                    sample_ext_q[tap][lane] <= sample18_at(din_flat, hist_reg, lane, tap);
                    prod_q[tap][lane] <= sample_ext_q[tap][lane] * h_ext_q[tap];
                end
            end

            for (lane = 0; lane < LANES; lane = lane + 1) begin
                sum0_q[lane] <=
                    prod_q[0][lane] + prod_q[1][lane] + prod_q[2][lane] + prod_q[3][lane] +
                    prod_q[4][lane] + prod_q[5][lane] + prod_q[6][lane];
                sum1_q[lane] <=
                    prod_q[7][lane] + prod_q[8][lane] + prod_q[9][lane] + prod_q[10][lane] +
                    prod_q[11][lane] + prod_q[12][lane] + prod_q[13][lane];
                sum2_q[lane] <=
                    prod_q[14][lane] + prod_q[15][lane] + prod_q[16][lane] + prod_q[17][lane] +
                    prod_q[18][lane] + prod_q[19][lane] + prod_q[20][lane];
                sum2_dly_q[lane] <= sum2_q[lane];
                sum01_q[lane] <= sum0_q[lane] + sum1_q[lane];
                dout_arr[lane] <= sat8_shift48(sum01_q[lane] + sum2_dly_q[lane]);
            end

            for (hist_i = 0; hist_i < HIST; hist_i = hist_i + 1)
                hist_reg[(hist_i*8) +: 8] <= din_flat[((LANES - 1 - hist_i)*8) +: 8];
        end
    end

    genvar out_lane_i;
    generate
        for (out_lane_i = 0; out_lane_i < LANES; out_lane_i = out_lane_i + 1) begin : GEN_PACK_GROUP
            assign dout_flat[(out_lane_i*8) +: 8] = dout_arr[out_lane_i];
        end
    endgenerate
endmodule

module tb_rx_eq21_old_vs_segmented_equiv;
    localparam int LANES = 32;
    localparam int NTAPS = 21;
    localparam int LAT_DIFF = 3;
    localparam int MAX_LAT = 12;
    localparam int NUM_CYCLES = 900;

    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic signed [(LANES*8)-1:0] din_flat;
    logic signed [(NTAPS*8)-1:0] h_packed;
    logic signed [(LANES*8)-1:0] old_dout_flat;
    logic signed [(LANES*8)-1:0] new_dout_flat;
    logic signed [7:0] old_delay [0:MAX_LAT][0:LANES-1];
    int errors = 0;

    always #4 clk = ~clk;

    FIR_Q6_21TAP_GROUP_PIPE_32LANE_LEGACY u_old (
        .clk(clk),
        .rst_n(rst_n),
        .din_flat(din_flat),
        .h_packed(h_packed),
        .dout_flat(old_dout_flat)
    );

    FIR_Q6_21TAP_GROUP_PIPE_32LANE u_new (
        .clk(clk),
        .rst_n(rst_n),
        .ce(1'b1),
        .din_flat(din_flat),
        .h_packed(h_packed),
        .dout_flat(new_dout_flat)
    );

    task automatic set_coefficients;
        int tap;
        logic signed [7:0] coeff;
        begin
            for (tap = 0; tap < NTAPS; tap = tap + 1) begin
                coeff = $signed(((tap * 5 + 3) % 23) - 11);
                h_packed[(tap*8) +: 8] = coeff;
            end
        end
    endtask

    task automatic drive_random(input int cyc);
        int lane;
        int signed v;
        begin
            for (lane = 0; lane < LANES; lane = lane + 1) begin
                v = (($urandom(cyc * 211 + lane * 17) % 129) - 64);
                din_flat[(lane*8) +: 8] = v[7:0];
            end
        end
    endtask

    task automatic shift_and_check(input int cyc);
        int d;
        int lane;
        logic signed [7:0] old_lane;
        logic signed [7:0] new_lane;
        begin
            for (d = MAX_LAT; d > 0; d = d - 1)
                for (lane = 0; lane < LANES; lane = lane + 1)
                    old_delay[d][lane] = old_delay[d-1][lane];
            for (lane = 0; lane < LANES; lane = lane + 1)
                old_delay[0][lane] = $signed(old_dout_flat[(lane*8) +: 8]);

            if (cyc > 80) begin
                for (lane = 0; lane < LANES; lane = lane + 1) begin
                    old_lane = old_delay[LAT_DIFF][lane];
                    new_lane = $signed(new_dout_flat[(lane*8) +: 8]);
                    if (new_lane !== old_lane) begin
                        if (errors < 32) begin
                            $display("MISMATCH cyc=%0d lane=%0d new=%0d old_dly=%0d",
                                     cyc, lane, new_lane, old_lane);
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

        din_flat = '0;
        h_packed = '0;
        for (d = 0; d <= MAX_LAT; d = d + 1)
            for (lane = 0; lane < LANES; lane = lane + 1)
                old_delay[d][lane] = '0;

        set_coefficients();

        repeat (8) @(posedge clk);
        rst_n = 1'b1;

        for (cyc = 0; cyc < NUM_CYCLES; cyc = cyc + 1) begin
            @(negedge clk);
            drive_random(cyc);
            @(posedge clk);
            #1;
            shift_and_check(cyc);
        end

        if (errors == 0) begin
            $display("RX_EQ21_OLD_VS_SEGMENTED_EQUIV PASS latency_diff=%0d cycles checked=%0d",
                     LAT_DIFF, NUM_CYCLES);
            $finish;
        end else begin
            $display("RX_EQ21_OLD_VS_SEGMENTED_EQUIV FAIL errors=%0d", errors);
            $fatal(1);
        end
    end
endmodule
