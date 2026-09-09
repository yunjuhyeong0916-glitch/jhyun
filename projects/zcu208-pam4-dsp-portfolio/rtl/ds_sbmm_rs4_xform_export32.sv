`timescale 1ns/1ps

// 32-lane metric/xform export for the active 512b RX path.
// It instantiates four 8-lane metric tiles and exports the 32 lane transforms
// in the trace shell's local-lane-major order, plus four tile-start PM vectors.
//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: Dual-Survivor Segmented Branch-Metric Matrix MLSD
// Module Name: codex_pam4_rs4_prefix32_xform_export_ooc
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Builds and exports 32-lane segmented branch-metric transforms for the trace-shell MLSD path.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module codex_pam4_rs4_prefix32_xform_export_ooc #(
    parameter int TB = 40,
    parameter int MET_W = 10,
    parameter int Q_SHIFT = 8,
    parameter int SEGMENT_BRANCH_SURVIVORS = 2,
    parameter bit USE_L1_BRANCH_METRIC = 1'b1,
    parameter int BRANCH_METRIC_SHIFT = 0,
    parameter bit ENABLE_PAIR_NORMALIZE = 1'b1,
    parameter bit ENABLE_PAIR_OFFSET_COMPENSATION = 1'b0,
    parameter bit ENABLE_TILE_INPUT_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_LANE_XFORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_LANE_SELECT_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_LANE_SELECT_SECOND_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_PAIR_XFORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_QUAD_XFORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_BLOCK_XFORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_START_PM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_END_PM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_PM_STATE_UPDATE = 1'b0
) (
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         in_valid,
    input  logic [255:0]                 din32_flat,
    input  logic signed [(4*32)-1:0]     g0_prod_flat,
    input  logic signed [(4*32)-1:0]     g1_prod_flat,
    input  logic signed [(4*32)-1:0]     g2_prod_flat,
    input  logic                         state_update_valid,
    input  logic [(4*MET_W)-1:0]         pm_update_flat,
    input  logic [7:0]                   fb_idx_update_flat,
    output logic                         xform_valid,
    output logic [(4*MET_W)-1:0]         pm_start_flat,
    // lane_xform_flat ordering: local_lane first, then tile within that lane.
    output logic [(32*16*MET_W)-1:0]     lane_xform_flat,
    output logic [(4*4*MET_W)-1:0]       pm_tile_start_flat,
    output logic [(4*MET_W)-1:0]         pm_end_export_flat,
    output logic [((TB <= 1) ? 1 : $clog2(TB + 1))-1:0] samples_processed_out,
    output logic [7:0]                   fb_idx_state_out
);
    localparam int TILES = 4;
    localparam int TILE_LANES = 8;
    localparam int LANES = 32;
    localparam int STATES = 4;
    localparam int MAT_W = STATES * STATES * MET_W;
    localparam int PM_W = STATES * MET_W;
    localparam int SAMPLE_COUNT_W = (TB <= 1) ? 1 : $clog2(TB + 1);
    localparam logic [MET_W-1:0] INF = {MET_W{1'b1}};
    localparam bit PM_CHAIN_PIPELINE_ACTIVE =
        ENABLE_TILE_START_PM_PIPELINE_SPLIT || ENABLE_TILE_END_PM_PIPELINE_SPLIT;

    logic [TILES-1:0] tile_valid;
    logic [TILES-1:0] tile_valid_q;
    logic [PM_W-1:0] tile_pm_unused [0:TILES-1];
    logic [MAT_W-1:0] tile_block_xform [0:TILES-1];
    logic [(TILE_LANES*MAT_W)-1:0] tile_lane_xform [0:TILES-1];

    logic [PM_W-1:0] pm_state_flat;
    logic [PM_W-1:0] pm_start_capture_q;
    logic [7:0] fb_idx_state_flat;
    logic [SAMPLE_COUNT_W-1:0] samples_processed_state;
    logic [SAMPLE_COUNT_W-1:0] samples_processed_capture_q;

    logic [PM_W-1:0] pm_tile_start_c [0:TILES-1];
    logic [(TILES*PM_W)-1:0] pm_tile_start_flat_c;
    logic [(LANES*MAT_W)-1:0] lane_xform_flat_c;
    logic [PM_W-1:0] pm_end_c;
    logic xform_valid_q;

    logic [3:0] pm_pipe_valid_q;
    logic [PM_W-1:0] pm_pipe_start_s0_q;
    logic [PM_W-1:0] pm_pipe_start0_s1_q;
    logic [PM_W-1:0] pm_pipe_start1_s1_q;
    logic [PM_W-1:0] pm_pipe_start0_s2_q;
    logic [PM_W-1:0] pm_pipe_start1_s2_q;
    logic [PM_W-1:0] pm_pipe_start2_s2_q;
    logic [PM_W-1:0] pm_pipe_start0_s3_q;
    logic [PM_W-1:0] pm_pipe_start1_s3_q;
    logic [PM_W-1:0] pm_pipe_start2_s3_q;
    logic [PM_W-1:0] pm_pipe_start3_s3_q;
    logic [SAMPLE_COUNT_W-1:0] samples_processed_s0_q;
    logic [SAMPLE_COUNT_W-1:0] samples_processed_s1_q;
    logic [SAMPLE_COUNT_W-1:0] samples_processed_s2_q;
    logic [SAMPLE_COUNT_W-1:0] samples_processed_s3_q;
    logic [MAT_W-1:0] tile_block_s0_q [0:TILES-1];
    logic [MAT_W-1:0] tile_block_s1_q [0:TILES-1];
    logic [MAT_W-1:0] tile_block_s2_q [0:TILES-1];
    logic [MAT_W-1:0] tile_block_s3_q [0:TILES-1];
    logic [(LANES*MAT_W)-1:0] lane_xform_s0_q;
    logic [(LANES*MAT_W)-1:0] lane_xform_s1_q;
    logic [(LANES*MAT_W)-1:0] lane_xform_s2_q;
    logic [(LANES*MAT_W)-1:0] lane_xform_s3_q;
    logic [PM_W-1:0] pm_pipe_start1_c;
    logic [PM_W-1:0] pm_pipe_start2_c;
    logic [PM_W-1:0] pm_pipe_start3_c;
    logic [PM_W-1:0] pm_pipe_end_c;
    logic [(TILES*PM_W)-1:0] pm_tile_start_pipe_flat_c;
    logic [MAT_W-1:0] pair_pipe_xform_c [0:1];
    logic [MAT_W-1:0] pair_state_xform_c [0:1];
    logic [MAT_W-1:0] word_pipe_xform_c;
    logic [MAT_W-1:0] pair_scan_xform_c [0:1];
    logic [MAT_W-1:0] word_scan_xform_c;
    logic [MAT_W-1:0] pair_xform_s1_q [0:1];
    logic [MAT_W-1:0] word_xform_s2_q;
    logic [MAT_W-1:0] word_xform_s3_q;
    logic [PM_W-1:0] pm_pipe_state_start1_c;
    logic [PM_W-1:0] pm_pipe_state_start2_c;
    logic [PM_W-1:0] pm_pipe_state_start3_c;
    logic [PM_W-1:0] pm_pipe_state_end_c;
    logic pm_state_out_s4_valid_q;
    logic pm_state_out_s5_valid_q;
    logic pm_state_out_s6_valid_q;
    logic [PM_W-1:0] pm_pipe_state_start0_s4_q;
    logic [PM_W-1:0] pm_pipe_state_start1_s4_q;
    logic [MAT_W-1:0] pm_pipe_state_pair01_s4_q;
    logic [MAT_W-1:0] pm_pipe_state_tile2_s4_q;
    logic [PM_W-1:0] pm_pipe_state_end_s4_q;
    logic [(LANES*MAT_W)-1:0] lane_xform_s4_q;
    logic [SAMPLE_COUNT_W-1:0] samples_processed_s4_q;
    logic [PM_W-1:0] pm_pipe_state_start0_s5_q;
    logic [PM_W-1:0] pm_pipe_state_start1_s5_q;
    logic [PM_W-1:0] pm_pipe_state_start2_s5_q;
    logic [MAT_W-1:0] pm_pipe_state_tile2_s5_q;
    logic [PM_W-1:0] pm_pipe_state_end_s5_q;
    logic [(LANES*MAT_W)-1:0] lane_xform_s5_q;
    logic [SAMPLE_COUNT_W-1:0] samples_processed_s5_q;
    logic [PM_W-1:0] pm_pipe_state_start0_s6_q;
    logic [PM_W-1:0] pm_pipe_state_start1_s6_q;
    logic [PM_W-1:0] pm_pipe_state_start2_s6_q;
    logic [PM_W-1:0] pm_pipe_state_start3_s6_q;
    logic [PM_W-1:0] pm_pipe_state_end_s6_q;
    logic [(LANES*MAT_W)-1:0] lane_xform_s6_q;
    logic [SAMPLE_COUNT_W-1:0] samples_processed_s6_q;

    assign xform_valid = xform_valid_q;
    assign pm_start_flat = pm_start_capture_q;
    assign samples_processed_out = samples_processed_capture_q;
    assign fb_idx_state_out = fb_idx_state_flat;

    genvar tile;
    generate
        for (tile = 0; tile < TILES; tile = tile + 1) begin : g_tile
            (* keep = "yes", dont_touch = "yes" *) logic tile_in_valid_q;
            (* keep = "yes", dont_touch = "yes" *) logic [63:0] din8_tile_q;
            (* keep = "yes", dont_touch = "yes" *) logic signed [(4*32)-1:0] g0_prod_tile_q;
            (* keep = "yes", dont_touch = "yes" *) logic signed [(4*32)-1:0] g1_prod_tile_q;
            (* keep = "yes", dont_touch = "yes" *) logic signed [(4*32)-1:0] g2_prod_tile_q;
            logic [(8*8)-1:0] fb_idx_lane_tile_q;

            always_ff @(posedge clk) begin
                if (!rst_n) begin
                    tile_in_valid_q <= 1'b0;
                    din8_tile_q <= '0;
                    g0_prod_tile_q <= '0;
                    g1_prod_tile_q <= '0;
                    g2_prod_tile_q <= '0;
                    fb_idx_lane_tile_q <= {8{{2'd3, 2'd2, 2'd1, 2'd0}}};
                end else begin
                    tile_in_valid_q <= in_valid;
                    din8_tile_q <= din32_flat[(tile*64) +: 64];
                    g0_prod_tile_q <= g0_prod_flat;
                    g1_prod_tile_q <= g1_prod_flat;
                    g2_prod_tile_q <= g2_prod_flat;
                    if (state_update_valid)
                        fb_idx_lane_tile_q <= {8{fb_idx_update_flat}};
                end
            end

            (* keep_hierarchy = "yes" *)
            codex_pam4_rs4_prefix8_nearest2_metric_productflat_trace_ooc #(
                .MET_W(MET_W),
                .Q_SHIFT(Q_SHIFT),
                .SEGMENT_BRANCH_SURVIVORS(SEGMENT_BRANCH_SURVIVORS),
                .USE_L1_BRANCH_METRIC(USE_L1_BRANCH_METRIC),
                .BRANCH_METRIC_SHIFT(BRANCH_METRIC_SHIFT),
                .ENABLE_PAIR_NORMALIZE(ENABLE_PAIR_NORMALIZE),
                .ENABLE_PAIR_OFFSET_COMPENSATION(ENABLE_PAIR_OFFSET_COMPENSATION),
                .ENABLE_INPUT_PIPELINE_SPLIT(ENABLE_TILE_INPUT_PIPELINE_SPLIT),
                .ENABLE_LANE_XFORM_PIPELINE_SPLIT(ENABLE_LANE_XFORM_PIPELINE_SPLIT),
                .ENABLE_LANE_SELECT_PIPELINE_SPLIT(ENABLE_LANE_SELECT_PIPELINE_SPLIT),
                .ENABLE_LANE_SELECT_SECOND_PIPELINE_SPLIT(ENABLE_TILE_LANE_SELECT_SECOND_PIPELINE_SPLIT),
                .ENABLE_PAIR_XFORM_PIPELINE_SPLIT(ENABLE_TILE_PAIR_XFORM_PIPELINE_SPLIT),
                .ENABLE_QUAD_XFORM_PIPELINE_SPLIT(ENABLE_TILE_QUAD_XFORM_PIPELINE_SPLIT),
                .ENABLE_BLOCK_XFORM_PIPELINE_SPLIT(ENABLE_TILE_BLOCK_XFORM_PIPELINE_SPLIT),
                .ENABLE_PM_STATE_UPDATE(ENABLE_TILE_PM_STATE_UPDATE)
            ) u_tile (
                .clk(clk),
                .rst_n(rst_n),
                .in_valid(tile_in_valid_q),
                .din8_flat(din8_tile_q),
                .fb_idx_lane_flat(fb_idx_lane_tile_q),
                .g0_prod_flat(g0_prod_tile_q),
                .g1_prod_flat(g1_prod_tile_q),
                .g2_prod_flat(g2_prod_tile_q),
                .out_valid(tile_valid[tile]),
                .pm_out_flat(tile_pm_unused[tile]),
                .block_xform_flat(tile_block_xform[tile]),
                .lane_xform_flat(tile_lane_xform[tile])
            );
        end
    endgenerate

    function automatic logic [SAMPLE_COUNT_W-1:0] sample_count_after_word(
        input logic [SAMPLE_COUNT_W-1:0] sample_count_in
    );
        int lane;
        logic [SAMPLE_COUNT_W-1:0] sample_count_work;
        begin
            sample_count_work = sample_count_in;
            for (lane = 0; lane < LANES; lane = lane + 1) begin
                if (sample_count_work < TB)
                    sample_count_work = sample_count_work + 1'b1;
            end
            sample_count_after_word = sample_count_work;
        end
    endfunction

    function automatic logic [MET_W-1:0] sat_add(
        input logic [MET_W-1:0] a,
        input logic [MET_W-1:0] b
    );
        logic [MET_W:0] sum_ext;
        begin
            if ((a == INF) || (b == INF)) begin
                sat_add = INF;
            end else begin
                sum_ext = {1'b0, a} + {1'b0, b};
                sat_add = sum_ext[MET_W] ? INF : sum_ext[MET_W-1:0];
            end
        end
    endfunction

    function automatic logic [MET_W-1:0] mat_get(
        input logic [MAT_W-1:0] mat,
        input int row,
        input int col
    );
        begin
            mat_get = mat[((row*STATES + col)*MET_W) +: MET_W];
        end
    endfunction

    function automatic logic [MET_W-1:0] pm_get(
        input logic [PM_W-1:0] pm,
        input int idx
    );
        begin
            pm_get = pm[(idx*MET_W) +: MET_W];
        end
    endfunction

    function automatic logic [PM_W-1:0] apply_xform(
        input logic [MAT_W-1:0] mat,
        input logic [PM_W-1:0] pm_in
    );
        int row;
        int col;
        logic [PM_W-1:0] pm_r;
        logic [MET_W-1:0] raw_pm [0:STATES-1];
        logic [MET_W-1:0] best;
        logic [MET_W-1:0] cand_metric;
        logic [MET_W-1:0] pm_min;
        begin
            pm_min = INF;
            for (row = 0; row < STATES; row = row + 1) begin
                best = INF;
                for (col = 0; col < STATES; col = col + 1) begin
                    cand_metric = sat_add(pm_get(pm_in, col), mat_get(mat, row, col));
                    if (cand_metric < best)
                        best = cand_metric;
                end
                raw_pm[row] = best;
                if ((best != INF) && ((pm_min == INF) || (best < pm_min)))
                    pm_min = best;
            end

            if (pm_min == INF)
                pm_min = '0;

            pm_r = '0;
            for (row = 0; row < STATES; row = row + 1) begin
                if (raw_pm[row] == INF)
                    pm_r[(row*MET_W) +: MET_W] = INF;
                else
                    pm_r[(row*MET_W) +: MET_W] = raw_pm[row] - pm_min;
            end
            apply_xform = pm_r;
        end
    endfunction

    function automatic logic [MAT_W-1:0] compose_xform(
        input logic [MAT_W-1:0] later_xform,
        input logic [MAT_W-1:0] earlier_xform
    );
        int row;
        int col;
        int mid;
        logic [MAT_W-1:0] mat_r;
        logic [MET_W-1:0] best;
        logic [MET_W-1:0] cand_metric;
        begin
            mat_r = {MAT_W{1'b1}};
            for (row = 0; row < STATES; row = row + 1) begin
                for (col = 0; col < STATES; col = col + 1) begin
                    best = INF;
                    for (mid = 0; mid < STATES; mid = mid + 1) begin
                        cand_metric = sat_add(
                            mat_get(earlier_xform, mid, col),
                            mat_get(later_xform, row, mid)
                        );
                        if (cand_metric < best)
                            best = cand_metric;
                    end
                    mat_r[((row*STATES + col)*MET_W) +: MET_W] = best;
                end
            end
            compose_xform = mat_r;
        end
    endfunction

    always_comb begin
        pm_pipe_start1_c = apply_xform(tile_block_s0_q[0], pm_pipe_start_s0_q);
        pair_pipe_xform_c[0] = compose_xform(tile_block_s0_q[1], tile_block_s0_q[0]);
        pair_pipe_xform_c[1] = compose_xform(tile_block_s0_q[3], tile_block_s0_q[2]);
        word_pipe_xform_c = compose_xform(pair_xform_s1_q[1], pair_xform_s1_q[0]);
        pm_pipe_start2_c = apply_xform(pair_xform_s1_q[0], pm_pipe_start0_s1_q);
        pm_pipe_start3_c = apply_xform(tile_block_s2_q[2], pm_pipe_start2_s2_q);
        pm_pipe_end_c = apply_xform(word_xform_s3_q, pm_pipe_start0_s3_q);

        pm_tile_start_pipe_flat_c = '0;
        pm_tile_start_pipe_flat_c[(0*PM_W) +: PM_W] = pm_pipe_start0_s3_q;
        pm_tile_start_pipe_flat_c[(1*PM_W) +: PM_W] = pm_pipe_start1_s3_q;
        pm_tile_start_pipe_flat_c[(2*PM_W) +: PM_W] = pm_pipe_start2_s3_q;
        pm_tile_start_pipe_flat_c[(3*PM_W) +: PM_W] = pm_pipe_start3_s3_q;

        pair_state_xform_c[0] = compose_xform(tile_block_s3_q[1], tile_block_s3_q[0]);
        pair_state_xform_c[1] = '0;
        pm_pipe_state_start1_c = apply_xform(tile_block_s3_q[0], pm_state_flat);
        pm_pipe_state_start2_c = apply_xform(pm_pipe_state_pair01_s4_q, pm_pipe_state_start0_s4_q);
        pm_pipe_state_start3_c = apply_xform(pm_pipe_state_tile2_s5_q, pm_pipe_state_start2_s5_q);
        pm_pipe_state_end_c = apply_xform(word_xform_s3_q, pm_state_flat);
    end

    always_comb begin
        int tile_i;
        int local_lane;
        int lane_group_idx;

        pair_scan_xform_c[0] = compose_xform(tile_block_xform[1], tile_block_xform[0]);
        pair_scan_xform_c[1] = compose_xform(tile_block_xform[3], tile_block_xform[2]);
        word_scan_xform_c = compose_xform(pair_scan_xform_c[1], pair_scan_xform_c[0]);

        for (tile_i = 0; tile_i < TILES; tile_i = tile_i + 1)
            pm_tile_start_c[tile_i] = '0;
        pm_tile_start_flat_c = '0;
        lane_xform_flat_c = '0;

        pm_tile_start_c[0] = pm_state_flat;
        pm_tile_start_c[1] = apply_xform(tile_block_xform[0], pm_state_flat);
        pm_tile_start_c[2] = apply_xform(pair_scan_xform_c[0], pm_state_flat);
        pm_tile_start_c[3] = apply_xform(tile_block_xform[2], pm_tile_start_c[2]);
        pm_end_c = apply_xform(word_scan_xform_c, pm_state_flat);

        for (tile_i = 0; tile_i < TILES; tile_i = tile_i + 1) begin
            pm_tile_start_flat_c[(tile_i*PM_W) +: PM_W] = pm_tile_start_c[tile_i];
            for (local_lane = 0; local_lane < TILE_LANES; local_lane = local_lane + 1) begin
                lane_group_idx = (local_lane*TILES) + tile_i;
                lane_xform_flat_c[(lane_group_idx*MAT_W) +: MAT_W] =
                    tile_lane_xform[tile_i][(local_lane*MAT_W) +: MAT_W];
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        int st;
        int tile_i;

        if (!rst_n) begin
            pm_state_flat <= {PM_W{1'b1}};
            pm_state_flat[0 +: MET_W] <= '0;
            pm_start_capture_q <= {PM_W{1'b1}};
            pm_start_capture_q[0 +: MET_W] <= '0;
            fb_idx_state_flat <= '0;
            for (st = 0; st < STATES; st = st + 1)
                fb_idx_state_flat[(st*2) +: 2] <= st[1:0];
            samples_processed_state <= '0;
            samples_processed_capture_q <= '0;
            tile_valid_q <= '0;
            xform_valid_q <= 1'b0;
            pm_tile_start_flat <= '0;
            lane_xform_flat <= '0;
            pm_end_export_flat <= {PM_W{1'b1}};
            pm_end_export_flat[0 +: MET_W] <= '0;
            pm_pipe_valid_q <= '0;
            pm_pipe_start_s0_q <= '0;
            pm_pipe_start0_s1_q <= '0;
            pm_pipe_start1_s1_q <= '0;
            pm_pipe_start0_s2_q <= '0;
            pm_pipe_start1_s2_q <= '0;
            pm_pipe_start2_s2_q <= '0;
            pm_pipe_start0_s3_q <= '0;
            pm_pipe_start1_s3_q <= '0;
            pm_pipe_start2_s3_q <= '0;
            pm_pipe_start3_s3_q <= '0;
            samples_processed_s0_q <= '0;
            samples_processed_s1_q <= '0;
            samples_processed_s2_q <= '0;
            samples_processed_s3_q <= '0;
            lane_xform_s0_q <= '0;
            lane_xform_s1_q <= '0;
            lane_xform_s2_q <= '0;
            lane_xform_s3_q <= '0;
            for (tile_i = 0; tile_i < TILES; tile_i = tile_i + 1) begin
                tile_block_s0_q[tile_i] <= '0;
                tile_block_s1_q[tile_i] <= '0;
                tile_block_s2_q[tile_i] <= '0;
                tile_block_s3_q[tile_i] <= '0;
            end
            pair_xform_s1_q[0] <= '0;
            pair_xform_s1_q[1] <= '0;
            word_xform_s2_q <= '0;
            word_xform_s3_q <= '0;
            pm_state_out_s4_valid_q <= 1'b0;
            pm_state_out_s5_valid_q <= 1'b0;
            pm_state_out_s6_valid_q <= 1'b0;
            pm_pipe_state_start0_s4_q <= '0;
            pm_pipe_state_start1_s4_q <= '0;
            pm_pipe_state_pair01_s4_q <= '0;
            pm_pipe_state_tile2_s4_q <= '0;
            pm_pipe_state_end_s4_q <= '0;
            lane_xform_s4_q <= '0;
            samples_processed_s4_q <= '0;
            pm_pipe_state_start0_s5_q <= '0;
            pm_pipe_state_start1_s5_q <= '0;
            pm_pipe_state_start2_s5_q <= '0;
            pm_pipe_state_tile2_s5_q <= '0;
            pm_pipe_state_end_s5_q <= '0;
            lane_xform_s5_q <= '0;
            samples_processed_s5_q <= '0;
            pm_pipe_state_start0_s6_q <= '0;
            pm_pipe_state_start1_s6_q <= '0;
            pm_pipe_state_start2_s6_q <= '0;
            pm_pipe_state_start3_s6_q <= '0;
            pm_pipe_state_end_s6_q <= '0;
            lane_xform_s6_q <= '0;
            samples_processed_s6_q <= '0;
        end else begin
            tile_valid_q <= tile_valid;

            if (PM_CHAIN_PIPELINE_ACTIVE) begin
                pm_pipe_valid_q <= {pm_pipe_valid_q[2:0], (&tile_valid_q)};
                pm_state_out_s4_valid_q <= pm_pipe_valid_q[3];
                pm_state_out_s5_valid_q <= pm_state_out_s4_valid_q;
                pm_state_out_s6_valid_q <= pm_state_out_s5_valid_q;
                xform_valid_q <= pm_state_out_s6_valid_q;

                if (&tile_valid_q) begin
                    pm_pipe_start_s0_q <= pm_state_flat;
                    samples_processed_s0_q <= samples_processed_state;
                    lane_xform_s0_q <= lane_xform_flat_c;
                    for (tile_i = 0; tile_i < TILES; tile_i = tile_i + 1)
                        tile_block_s0_q[tile_i] <= tile_block_xform[tile_i];
                end

                if (pm_pipe_valid_q[0]) begin
                    pm_pipe_start0_s1_q <= pm_pipe_start_s0_q;
                    pm_pipe_start1_s1_q <= pm_pipe_start1_c;
                    samples_processed_s1_q <= samples_processed_s0_q;
                    lane_xform_s1_q <= lane_xform_s0_q;
                    for (tile_i = 0; tile_i < TILES; tile_i = tile_i + 1)
                        tile_block_s1_q[tile_i] <= tile_block_s0_q[tile_i];
                    pair_xform_s1_q[0] <= pair_pipe_xform_c[0];
                    pair_xform_s1_q[1] <= pair_pipe_xform_c[1];
                end

                if (pm_pipe_valid_q[1]) begin
                    pm_pipe_start0_s2_q <= pm_pipe_start0_s1_q;
                    pm_pipe_start1_s2_q <= pm_pipe_start1_s1_q;
                    pm_pipe_start2_s2_q <= pm_pipe_start2_c;
                    samples_processed_s2_q <= samples_processed_s1_q;
                    lane_xform_s2_q <= lane_xform_s1_q;
                    for (tile_i = 0; tile_i < TILES; tile_i = tile_i + 1)
                        tile_block_s2_q[tile_i] <= tile_block_s1_q[tile_i];
                    word_xform_s2_q <= word_pipe_xform_c;
                end

                if (pm_pipe_valid_q[2]) begin
                    pm_pipe_start0_s3_q <= pm_pipe_start0_s2_q;
                    pm_pipe_start1_s3_q <= pm_pipe_start1_s2_q;
                    pm_pipe_start2_s3_q <= pm_pipe_start2_s2_q;
                    pm_pipe_start3_s3_q <= pm_pipe_start3_c;
                    samples_processed_s3_q <= samples_processed_s2_q;
                    lane_xform_s3_q <= lane_xform_s2_q;
                    for (tile_i = 0; tile_i < TILES; tile_i = tile_i + 1)
                        tile_block_s3_q[tile_i] <= tile_block_s2_q[tile_i];
                    word_xform_s3_q <= word_xform_s2_q;
                end

                if (pm_pipe_valid_q[3]) begin
                    pm_pipe_state_start0_s4_q <= pm_state_flat;
                    pm_pipe_state_start1_s4_q <= pm_pipe_state_start1_c;
                    pm_pipe_state_pair01_s4_q <= pair_state_xform_c[0];
                    pm_pipe_state_tile2_s4_q <= tile_block_s3_q[2];
                    pm_pipe_state_end_s4_q <= pm_pipe_state_end_c;
                    lane_xform_s4_q <= lane_xform_s3_q;
                    samples_processed_s4_q <= samples_processed_state;
                end

                if (pm_state_out_s4_valid_q) begin
                    pm_pipe_state_start0_s5_q <= pm_pipe_state_start0_s4_q;
                    pm_pipe_state_start1_s5_q <= pm_pipe_state_start1_s4_q;
                    pm_pipe_state_start2_s5_q <= pm_pipe_state_start2_c;
                    pm_pipe_state_tile2_s5_q <= pm_pipe_state_tile2_s4_q;
                    pm_pipe_state_end_s5_q <= pm_pipe_state_end_s4_q;
                    lane_xform_s5_q <= lane_xform_s4_q;
                    samples_processed_s5_q <= samples_processed_s4_q;
                end

                if (pm_state_out_s5_valid_q) begin
                    pm_pipe_state_start0_s6_q <= pm_pipe_state_start0_s5_q;
                    pm_pipe_state_start1_s6_q <= pm_pipe_state_start1_s5_q;
                    pm_pipe_state_start2_s6_q <= pm_pipe_state_start2_s5_q;
                    pm_pipe_state_start3_s6_q <= pm_pipe_state_start3_c;
                    pm_pipe_state_end_s6_q <= pm_pipe_state_end_s5_q;
                    lane_xform_s6_q <= lane_xform_s5_q;
                    samples_processed_s6_q <= samples_processed_s5_q;
                end

                if (pm_state_out_s6_valid_q) begin
                    pm_start_capture_q <= pm_pipe_state_start0_s6_q;
                    samples_processed_capture_q <= samples_processed_s6_q;
                    pm_tile_start_flat[(0*PM_W) +: PM_W] <= pm_pipe_state_start0_s6_q;
                    pm_tile_start_flat[(1*PM_W) +: PM_W] <= pm_pipe_state_start1_s6_q;
                    pm_tile_start_flat[(2*PM_W) +: PM_W] <= pm_pipe_state_start2_s6_q;
                    pm_tile_start_flat[(3*PM_W) +: PM_W] <= pm_pipe_state_start3_s6_q;
                    lane_xform_flat <= lane_xform_s6_q;
                    pm_end_export_flat <= pm_pipe_state_end_s6_q;
                end
            end else begin
                xform_valid_q <= &tile_valid_q;

                if (&tile_valid_q) begin
                    pm_start_capture_q <= pm_state_flat;
                    samples_processed_capture_q <= samples_processed_state;
                    pm_tile_start_flat <= pm_tile_start_flat_c;
                    lane_xform_flat <= lane_xform_flat_c;
                    pm_end_export_flat <= pm_end_c;
                end
            end

            if (PM_CHAIN_PIPELINE_ACTIVE) begin
                if (pm_pipe_valid_q[3]) begin
                    pm_state_flat <= pm_pipe_state_end_c;
                    samples_processed_state <= sample_count_after_word(samples_processed_state);
                end
            end else if (&tile_valid_q) begin
                pm_state_flat <= pm_end_c;
                samples_processed_state <= sample_count_after_word(samples_processed_state);
            end

            if (state_update_valid) begin
                fb_idx_state_flat <= fb_idx_update_flat;
            end
        end
    end
endmodule
