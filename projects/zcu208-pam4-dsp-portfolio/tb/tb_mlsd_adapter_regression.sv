`timescale 1ns/1ps

// Exercise the published adapter and detector without RFDC or the EQ frontend.
// The two fixtures use memory-0 / memory-1 channels; g2 is zero in both.
module tb_mlsd_adapter_regression;
    localparam int WORDS = 16;
    localparam int WARMUP_WORDS = 2;
    localparam int LANES = 32;
    localparam int MET_W = 12;
    logic clk = 0;
    always #4 clk = ~clk;
    logic rst_n = 0, in_valid = 0;
    logic signed [511:0] in_data_16b = '0;
    logic signed [35:0] cfg_pr_taps_flat;
    wire signed [255:0] dout_flat;
    wire out_valid;
    wire [31:0] decision_ready;
    logic [511:0] samples [0:WORDS-1];
    logic [255:0] expected [0:WORDS-1];
    integer accepted_cycle [0:WORDS+WARMUP_WORDS-1];
    integer cycle = 0, accepted = 0, received = 0;
    integer latency = -1, log_file;
    integer g0, g1, w, bit_base, check_word;
    logic [511:0] warmup_data;
    string case_name, trace_name, sample_name, expected_name;

    codex_pam4_rs4_trace32_board_adapter_normprefix_contract #(
        .TB(40), .MET_W(MET_W), .Q_SHIFT(8),
        .SEGMENT_BRANCH_SURVIVORS(2), .USE_L1_BRANCH_METRIC(1),
        .ENABLE_PAIR_NORMALIZE(1)
    ) dut (
        .clk(clk), .rst_n(rst_n), .in_valid(in_valid), .ch_case_sel(2'd0),
        .in_data_16b(in_data_16b),
        .cfg_eq_override_en(1'b0), .cfg_eq_coeffs_flat(168'd0),
        .cfg_pr_override_en(1'b1), .cfg_pr_taps_flat(cfg_pr_taps_flat),
        .cfg_level_override_en(1'b0), .cfg_pam4_levels_flat(32'd0),
        .dout_flat(dout_flat), .out_valid(out_valid),
        .trace_decision_ready_debug_lane(decision_ready)
    );

    always @(posedge clk) begin
        if (rst_n) begin
            cycle = cycle + 1;
            if (in_valid) begin
                if (accepted >= WORDS+WARMUP_WORDS) $fatal(1, "Too many accepted words");
                accepted_cycle[accepted] = cycle;
                accepted = accepted + 1;
            end
            #1; // Observe registered outputs after NBA updates.
            if (out_valid) begin
                if (received >= accepted) $fatal(1, "Unexpected output word");
                if (latency < 0) latency = cycle - accepted_cycle[received];
                if (cycle - accepted_cycle[received] != latency)
                    $fatal(1, "Output latency changed at word %0d", received);
                check_word = received - WARMUP_WORDS;
                if (check_word >= 0) begin
                  if (decision_ready !== 32'hffffffff)
                    $fatal(1, "Decision-ready mask contains missing or unknown lanes");
                  for (int k = 0; k < LANES; k = k + 1) begin
                    if (dout_flat[k*8 +: 8] !== expected[check_word][k*8 +: 8]) begin
                        $display("expected_word=%h actual_word=%h", expected[check_word], dout_flat);
                        $fatal(1, "MLSD_MISMATCH word=%0d lane=%0d expected=%0d actual=%0d",
                               check_word, k, $signed(expected[check_word][k*8 +: 8]),
                               $signed(dout_flat[k*8 +: 8]));
                    end
                    bit_base = ((3 - k/8)*128) + ((k%8)*16);
                    $fdisplay(log_file, "%0d,%0d,%0d,%0d,%0d,%0d,%0d",
                              check_word, k, accepted_cycle[received], cycle,
                              $signed(samples[check_word][bit_base +: 16])/128,
                              $signed(expected[check_word][k*8 +: 8]),
                              $signed(dout_flat[k*8 +: 8]));
                  end
                end
                received = received + 1;
            end
        end
    end

    initial begin
        if (!$value$plusargs("CASE_%s", case_name)) case_name = "memoryless";
        if (!$value$plusargs("G0_%d", g0)) g0 = 256;
        if (!$value$plusargs("G1_%d", g1)) g1 = 0;
        cfg_pr_taps_flat = {12'd0, 12'(g1), 12'(g0)};
        sample_name = $sformatf("%s_samples.hex", case_name);
        expected_name = $sformatf("%s_expected.hex", case_name);
        $readmemh(sample_name, samples);
        $readmemh(expected_name, expected);
        if ($test$plusargs("CORRUPT_EXPECTED")) expected[0][7:0] = 8'd0;
        if (!$value$plusargs("TRACE_%s", trace_name)) trace_name = $sformatf("%s_rtl_trace.csv", case_name);
        log_file = $fopen(trace_name, "w");
        if (!log_file) $fatal(1, "Cannot create trace CSV");
        $fdisplay(log_file, "word,lane,input_cycle,output_cycle,sample,expected,actual");
        repeat (6) @(negedge clk);
        rst_n = 1;
        repeat (6) @(negedge clk); // Let configured product registers settle.
        for (int k = 0; k < LANES; k = k + 1) begin
            bit_base = ((3 - k/8)*128) + ((k%8)*16);
            warmup_data[bit_base +: 16] = 16'((((g0+g1)*(-96)) >>> 8)*128);
        end
        in_valid = 1;
        in_data_16b = warmup_data;
        repeat (WARMUP_WORDS) @(negedge clk);
        in_valid = 0;
        repeat (80) @(negedge clk);
        for (w = 0; w < WORDS; w = w + 1) begin
            in_valid = 1;
            in_data_16b = samples[w];
            @(negedge clk);
            if ((w == 3) || (w == 9)) begin
                in_valid = 0;
                repeat (3) @(negedge clk);
            end
        end
        in_valid = 0;
        repeat (200) @(negedge clk);
        if (accepted != WORDS+WARMUP_WORDS || received != WORDS+WARMUP_WORDS)
            $fatal(1, "Word count mismatch accepted=%0d received=%0d", accepted, received);
        $fclose(log_file);
        $display("MLSD_MINIMAL PASS case=%s words=%0d symbols=%0d latency_cycles=%0d",
                 case_name, received-WARMUP_WORDS, (received-WARMUP_WORDS)*LANES, latency);
        $finish;
    end
    initial begin
        #20000;
        $fatal(1, "Simulation timeout");
    end
endmodule
