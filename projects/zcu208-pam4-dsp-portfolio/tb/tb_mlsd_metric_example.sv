`timescale 1ns/1ps

// Standalone published eight-lane metric tile. Python checks the exported
// matrices and reconstructs the sequence; this does not exercise RTL traceback.
module tb_mlsd_metric_example;
    localparam int WORDS = 64, MET_W = 12;
    logic clk = 0;
    always #4 clk = ~clk;
    logic rst_n = 0, in_valid = 0;
    logic [63:0] din8_flat = 0;
    logic signed [127:0] g0_prod_flat, g1_prod_flat;
    wire out_valid;
    wire [191:0] block_xform_flat;
    wire [1535:0] lane_xform_flat;
    logic [63:0] samples [0:WORDS-1];
    integer cycle = 0, accepted = 0, received = 0, latency = -1;
    integer accepted_cycle [0:WORDS-1];
    integer g0, g1, w, lane_file, block_file;
    integer levels [0:3] = '{-96, -32, 32, 96};
    string case_name, sample_name, lane_name, block_name;

    codex_pam4_rs4_prefix8_nearest2_metric_productflat_trace_ooc #(
        .MET_W(MET_W), .Q_SHIFT(8), .SEGMENT_BRANCH_SURVIVORS(2),
        .USE_L1_BRANCH_METRIC(1), .ENABLE_PAIR_NORMALIZE(1),
        .ENABLE_PM_STATE_UPDATE(0)
    ) dut (
        .clk(clk), .rst_n(rst_n), .in_valid(in_valid), .din8_flat(din8_flat),
        .fb_idx_lane_flat({8{8'he4}}),
        .g0_prod_flat(g0_prod_flat), .g1_prod_flat(g1_prod_flat), .g2_prod_flat(128'd0),
        .out_valid(out_valid), .pm_out_flat(),
        .block_xform_flat(block_xform_flat), .lane_xform_flat(lane_xform_flat)
    );

    always @(posedge clk) begin
        if (rst_n) begin
            cycle = cycle + 1;
            if (in_valid) begin
                if (accepted >= WORDS) $fatal(1, "Too many accepted words");
                accepted_cycle[accepted] = cycle;
                accepted = accepted + 1;
            end
            #1;
            if (out_valid) begin
                if (received >= accepted) $fatal(1, "Unexpected tile output");
                if (latency < 0) latency = cycle - accepted_cycle[received];
                if (cycle - accepted_cycle[received] != latency)
                    $fatal(1, "Tile latency changed");
                if ((^lane_xform_flat === 1'bx) || (^block_xform_flat === 1'bx))
                    $fatal(1, "Unknown metric output");
                for (int k = 0; k < 8; k = k + 1)
                    for (int r = 0; r < 4; r = r + 1)
                        for (int c = 0; c < 4; c = c + 1)
                            $fdisplay(lane_file, "%0d,%0d,%0d,%0d,%0d,%0d,%0d",
                                received, k, r, c,
                                lane_xform_flat[(k*16+r*4+c)*MET_W +: MET_W],
                                accepted_cycle[received], cycle);
                for (int r = 0; r < 4; r = r + 1)
                    for (int c = 0; c < 4; c = c + 1)
                        $fdisplay(block_file, "%0d,%0d,%0d,%0d",
                            received, r, c, block_xform_flat[(r*4+c)*MET_W +: MET_W]);
                received = received + 1;
            end
        end
    end
    initial begin
        if (!$value$plusargs("CASE_%s", case_name)) case_name = "memoryless";
        if (!$value$plusargs("G0_%d", g0)) g0 = 256;
        if (!$value$plusargs("G1_%d", g1)) g1 = 0;
        for (int s = 0; s < 4; s = s + 1) begin
            g0_prod_flat[s*32 +: 32] = g0*levels[s];
            g1_prod_flat[s*32 +: 32] = g1*levels[s];
        end
        sample_name = $sformatf("%s_tile_samples.hex", case_name);
        lane_name = $sformatf("%s_lane_metrics.csv", case_name);
        block_name = $sformatf("%s_block_metrics.csv", case_name);
        $readmemh(sample_name, samples);
        lane_file = $fopen(lane_name, "w");
        block_file = $fopen(block_name, "w");
        if (!lane_file || !block_file) $fatal(1, "Cannot open trace CSV");
        $fdisplay(lane_file, "word,lane,destination,previous,metric,input_cycle,output_cycle");
        $fdisplay(block_file, "word,destination,previous,metric");
        repeat (6) @(negedge clk);
        rst_n = 1;
        repeat (3) @(negedge clk);
        for (w = 0; w < WORDS; w = w + 1) begin
            in_valid = 1;
            din8_flat = samples[w];
            @(negedge clk);
            if (w == 7 || w == 31) begin
                in_valid = 0;
                repeat (3) @(negedge clk);
            end
        end
        in_valid = 0;
        repeat (80) @(negedge clk);
        if (accepted != WORDS || received != WORDS)
            $fatal(1, "Tile word count mismatch");
        $fclose(lane_file);
        $fclose(block_file);
        $display("MLSD_TILE PASS case=%s words=%0d symbols=%0d latency_cycles=%0d",
                 case_name, received, received*8, latency);
        $finish;
    end
    initial begin
        #20000;
        $fatal(1, "Simulation timeout");
    end
endmodule
