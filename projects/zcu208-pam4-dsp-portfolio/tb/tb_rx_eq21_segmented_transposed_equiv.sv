`timescale 1ns/1ps

module tb_rx_eq21_segmented_transposed_equiv;
    localparam int LANES = 32;
    localparam int NTAPS = 21;
    localparam int SHIFT = 6;
    localparam int LATENCY = 7;
    localparam int MAX_LAT = 16;
    localparam int NUM_CYCLES = 900;

    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic signed [(LANES*8)-1:0] din_flat;
    logic signed [(NTAPS*8)-1:0] h_packed;
    logic signed [(LANES*8)-1:0] dout_flat;

    logic signed [7:0] hist_ref [0:NTAPS-2];
    logic signed [7:0] gold_now [0:LANES-1];
    logic signed [7:0] gold_delay [0:MAX_LAT][0:LANES-1];
    int errors = 0;

    always #4 clk = ~clk;

    FIR_Q6_21TAP_GROUP_PIPE_32LANE #(
        .SHIFT(SHIFT)
    ) u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .ce(1'b1),
        .din_flat(din_flat),
        .h_packed(h_packed),
        .dout_flat(dout_flat)
    );

    function automatic logic signed [7:0] get_din(input int lane);
        begin
            get_din = $signed(din_flat[(lane*8) +: 8]);
        end
    endfunction

    function automatic logic signed [7:0] get_coeff(input int tap);
        begin
            get_coeff = $signed(h_packed[(tap*8) +: 8]);
        end
    endfunction

    function automatic logic signed [7:0] sample_at(input int lane, input int tap);
        begin
            if (lane >= tap)
                sample_at = get_din(lane - tap);
            else
                sample_at = hist_ref[tap - lane - 1];
        end
    endfunction

    function automatic logic signed [7:0] sat8_shift48(input logic signed [47:0] x);
        logic signed [47:0] y;
        begin
            y = x >>> SHIFT;
            if (y > 48'sd127)       sat8_shift48 = 8'sd127;
            else if (y < -48'sd128) sat8_shift48 = -8'sd128;
            else                    sat8_shift48 = y[7:0];
        end
    endfunction

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

    task automatic compute_gold;
        int lane;
        int tap;
        logic signed [47:0] acc;
        logic signed [7:0] sample8;
        logic signed [7:0] coeff8;
        logic signed [17:0] sample18;
        logic signed [17:0] coeff18;
        begin
            for (lane = 0; lane < LANES; lane = lane + 1) begin
                acc = '0;
                for (tap = 0; tap < NTAPS; tap = tap + 1) begin
                    sample8 = sample_at(lane, tap);
                    coeff8 = get_coeff(tap);
                    sample18 = $signed({{10{sample8[7]}}, sample8});
                    coeff18 = $signed({{10{coeff8[7]}}, coeff8});
                    acc = acc + (sample18 * coeff18);
                end
                gold_now[lane] = sat8_shift48(acc);
            end
        end
    endtask

    task automatic update_ref_history;
        int hist_i;
        begin
            for (hist_i = 0; hist_i < NTAPS-1; hist_i = hist_i + 1)
                hist_ref[hist_i] = get_din(LANES - 1 - hist_i);
        end
    endtask

    task automatic shift_and_check(input int cyc);
        int d;
        int lane;
        logic signed [7:0] dut_lane;
        begin
            for (d = MAX_LAT; d > 0; d = d - 1)
                for (lane = 0; lane < LANES; lane = lane + 1)
                    gold_delay[d][lane] = gold_delay[d-1][lane];
            for (lane = 0; lane < LANES; lane = lane + 1)
                gold_delay[0][lane] = gold_now[lane];

            if (cyc > 80) begin
                for (lane = 0; lane < LANES; lane = lane + 1) begin
                    dut_lane = $signed(dout_flat[(lane*8) +: 8]);
                    if (dut_lane !== gold_delay[LATENCY][lane]) begin
                        if (errors < 32) begin
                            $display("MISMATCH cyc=%0d lane=%0d dut=%0d gold_dly=%0d",
                                     cyc, lane, dut_lane, gold_delay[LATENCY][lane]);
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
        for (lane = 0; lane < NTAPS-1; lane = lane + 1)
            hist_ref[lane] = '0;
        for (d = 0; d <= MAX_LAT; d = d + 1)
            for (lane = 0; lane < LANES; lane = lane + 1)
                gold_delay[d][lane] = '0;

        set_coefficients();

        repeat (8) @(posedge clk);
        rst_n = 1'b1;

        for (cyc = 0; cyc < NUM_CYCLES; cyc = cyc + 1) begin
            @(negedge clk);
            drive_random(cyc);
            @(posedge clk);
            #1;
            compute_gold();
            shift_and_check(cyc);
            update_ref_history();
        end

        if (errors == 0) begin
            $display("RX_EQ21_SEGMENTED_TRANSPOSED_EQUIV PASS latency=%0d cycles checked=%0d",
                     LATENCY, NUM_CYCLES);
            $finish;
        end else begin
            $display("RX_EQ21_SEGMENTED_TRANSPOSED_EQUIV FAIL errors=%0d", errors);
            $fatal(1);
        end
    end
endmodule
