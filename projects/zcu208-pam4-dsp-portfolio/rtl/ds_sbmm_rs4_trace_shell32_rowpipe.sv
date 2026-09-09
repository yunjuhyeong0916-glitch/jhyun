`timescale 1ns/1ps

// Full-rate 32-lane trace/update shell for one 32-symbol structural segment.
// The shell accepts one 32-symbol xform payload per clock and pipelines the
// eight local-lane traceback recurrences so output valid is II=1 after fill.
//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: Dual-Survivor Segmented Branch-Metric Matrix MLSD
// Module Name: codex_pam4_rs4_prefix32_trace_shell_rowpipe
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Performs 32-lane prefix-trace MLSD row-pipe decision recovery for the PAM4 detector.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module codex_pam4_rs4_prefix32_trace_shell_rowpipe #(
    parameter int TB = 40,
    parameter int MET_W = 10,
    parameter int GROUP_BASE_LANE = 0,
    parameter bit ENABLE_PM_HANDOFF_REG = 1'b0,
    parameter bit ENABLE_ROW_OUTPUT_PIPELINE_SPLIT = 1'b0
) (
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         in_valid,
    input  logic [(4*4*MET_W)-1:0]       pm_tile_start_flat,
    // local-lane-major order: all four tile matrices for lane0, then lane1...
    input  logic [(32*16*MET_W)-1:0]     lane_xform_flat,
    input  logic [((TB <= 1) ? 1 : $clog2(TB + 1))-1:0] samples_processed_in,
    output logic                         out_valid,
    output logic [(32*4*2)-1:0]          pred_cols_flat,
    output logic [(32*2)-1:0]            best_state_lane_flat,
    output logic [31:0]                  decision_ready_lane,
    output logic [7:0]                   fb_idx_out_flat,
    output logic [(4*MET_W)-1:0]         pm_end_flat
);
    localparam int SEG_TILES = 4;
    localparam int TILE_LANES = 8;
    localparam int LANES = SEG_TILES * TILE_LANES;
    localparam int STATES = 4;
    localparam int MAT_W = STATES * STATES * MET_W;
    localparam int PM_W = STATES * MET_W;
    localparam int TRACE_PRED_W = STATES * 2;
    localparam int SAMPLE_COUNT_W = (TB <= 1) ? 1 : $clog2(TB + 1);

    logic [(SEG_TILES*MAT_W)-1:0] lane_group [0:TILE_LANES-1];
    logic [(SEG_TILES*MAT_W)-1:0] lane_group_capture_q [0:TILE_LANES-1];
    logic [(SEG_TILES*MAT_W)-1:0] lane_group_trace0_pipe [0:0];
    logic [(SEG_TILES*MAT_W)-1:0] lane_group_trace1_pipe [0:4];
    logic [(SEG_TILES*MAT_W)-1:0] lane_group_trace2_pipe [0:8];
    logic [(SEG_TILES*MAT_W)-1:0] lane_group_trace3_pipe [0:12];
    logic [(SEG_TILES*MAT_W)-1:0] lane_group_trace4_pipe [0:16];
    logic [(SEG_TILES*MAT_W)-1:0] lane_group_trace5_pipe [0:20];
    logic [(SEG_TILES*MAT_W)-1:0] lane_group_trace6_pipe [0:24];
    logic [(SEG_TILES*MAT_W)-1:0] lane_group_trace7_pipe [0:28];

    logic [PM_W-1:0] step_pm_in [0:TILE_LANES-1][0:SEG_TILES-1];
    logic [PM_W-1:0] step_pm_next [0:TILE_LANES-1][0:SEG_TILES-1];
    logic [PM_W-1:0] pm_tile_start_q [0:SEG_TILES-1];
    logic [PM_W-1:0] pm_lane_q [0:TILE_LANES-1][0:SEG_TILES-1];
    logic [PM_W-1:0] pm_end_stage_q;
    logic [MAT_W-1:0] step_lane_mat [0:TILE_LANES-1][0:SEG_TILES-1];
    logic [TRACE_PRED_W-1:0] step_pred_cols [0:TILE_LANES-1][0:SEG_TILES-1];
    logic [1:0] step_best_idx [0:TILE_LANES-1][0:SEG_TILES-1];
    logic step_in_valid [0:TILE_LANES-1];
    logic step_out_valid [0:TILE_LANES-1][0:SEG_TILES-1];

    logic [(LANES*TRACE_PRED_W)-1:0] pred_acc_in [0:TILE_LANES-1];
    logic [(LANES*TRACE_PRED_W)-1:0] pred_acc_s0_q [0:TILE_LANES-1];
    logic [(LANES*TRACE_PRED_W)-1:0] pred_acc_s1_q [0:TILE_LANES-1];
    logic [(LANES*TRACE_PRED_W)-1:0] pred_acc_q [0:TILE_LANES-1];
    logic [(LANES*TRACE_PRED_W)-1:0] pred_acc_next_w [0:TILE_LANES-1];

    logic [(LANES*2)-1:0] best_acc_in [0:TILE_LANES-1];
    logic [(LANES*2)-1:0] best_acc_s0_q [0:TILE_LANES-1];
    logic [(LANES*2)-1:0] best_acc_s1_q [0:TILE_LANES-1];
    logic [(LANES*2)-1:0] best_acc_q [0:TILE_LANES-1];
    logic [(LANES*2)-1:0] best_acc_next_w [0:TILE_LANES-1];

    logic [LANES-1:0] ready_acc_in [0:TILE_LANES-1];
    logic [LANES-1:0] ready_acc_s0_q [0:TILE_LANES-1];
    logic [LANES-1:0] ready_acc_s1_q [0:TILE_LANES-1];
    logic [LANES-1:0] ready_acc_q [0:TILE_LANES-1];
    logic [LANES-1:0] ready_acc_next_w [0:TILE_LANES-1];

    logic [SAMPLE_COUNT_W-1:0] sample_in [0:TILE_LANES-1];
    logic [SAMPLE_COUNT_W-1:0] sample_s0_q [0:TILE_LANES-1];
    logic [SAMPLE_COUNT_W-1:0] sample_s1_q [0:TILE_LANES-1];
    logic [SAMPLE_COUNT_W-1:0] sample_q [0:TILE_LANES-1];
    logic [SAMPLE_COUNT_W-1:0] samples_processed_q;
    logic trace_valid_q;
    logic final_valid_q;
    logic [TILE_LANES-1:0] step_start_q;
    logic [7:0] fb_idx_next_w;

    genvar unpack_lane_g;
    generate
        for (unpack_lane_g = 0; unpack_lane_g < TILE_LANES; unpack_lane_g = unpack_lane_g + 1) begin : g_unpack_lane
            assign lane_group[unpack_lane_g] =
                lane_xform_flat[(unpack_lane_g*SEG_TILES*MAT_W) +: (SEG_TILES*MAT_W)];
        end
    endgenerate

    function automatic logic [MAT_W-1:0] tile_lane_group_mat_get(
        input logic [(SEG_TILES*MAT_W)-1:0] group_flat,
        input int tile_idx
    );
        begin
            tile_lane_group_mat_get = group_flat[(tile_idx*MAT_W) +: MAT_W];
        end
    endfunction

    function automatic logic decision_ready_after_lane(
        input logic [SAMPLE_COUNT_W-1:0] count_before,
        input int lane_advance
    );
        logic [SAMPLE_COUNT_W:0] count_after_lane;
        logic [SAMPLE_COUNT_W:0] tb_ext;
        begin
            count_after_lane = {1'b0, count_before} + GROUP_BASE_LANE + lane_advance;
            tb_ext = TB[SAMPLE_COUNT_W:0];
            decision_ready_after_lane = (count_after_lane >= tb_ext);
        end
    endfunction

    always_comb begin
        int local_lane;
        int tile_idx;
        int lane_idx;
        int st;

        for (local_lane = 0; local_lane < TILE_LANES; local_lane = local_lane + 1) begin
            pred_acc_next_w[local_lane] = pred_acc_s1_q[local_lane];
            best_acc_next_w[local_lane] = best_acc_s1_q[local_lane];
            ready_acc_next_w[local_lane] = ready_acc_s1_q[local_lane];
            for (tile_idx = 0; tile_idx < SEG_TILES; tile_idx = tile_idx + 1) begin
                lane_idx = (tile_idx*TILE_LANES) + local_lane;
                pred_acc_next_w[local_lane][(lane_idx*TRACE_PRED_W) +: TRACE_PRED_W] =
                    step_pred_cols[local_lane][tile_idx];
                best_acc_next_w[local_lane][(lane_idx*2) +: 2] =
                    step_best_idx[local_lane][tile_idx];
                ready_acc_next_w[local_lane][lane_idx] =
                    decision_ready_after_lane(sample_s1_q[local_lane], lane_idx + 1);
            end
        end

        fb_idx_next_w = fb_idx_out_flat;
        for (st = 0; st < STATES; st = st + 1) begin
            fb_idx_next_w[(st*2) +: 2] =
                pred_acc_next_w[TILE_LANES-1][(((LANES-1)*STATES + st)*2) +: 2];
        end
    end

    genvar lane_g;
    genvar tile_g;
    generate
        for (lane_g = 0; lane_g < TILE_LANES; lane_g = lane_g + 1) begin : g_step_lane
            assign step_in_valid[lane_g] = step_start_q[lane_g];
            if (lane_g == 0) begin : g_lane0_inputs
                assign pred_acc_in[lane_g] = '0;
                assign best_acc_in[lane_g] = '0;
                assign ready_acc_in[lane_g] = '0;
                assign sample_in[lane_g] = samples_processed_q;
            end else begin : g_laneN_inputs
                assign pred_acc_in[lane_g] =
                    step_out_valid[lane_g-1][0] ? pred_acc_next_w[lane_g-1] : pred_acc_q[lane_g-1];
                assign best_acc_in[lane_g] =
                    step_out_valid[lane_g-1][0] ? best_acc_next_w[lane_g-1] : best_acc_q[lane_g-1];
                assign ready_acc_in[lane_g] =
                    step_out_valid[lane_g-1][0] ? ready_acc_next_w[lane_g-1] : ready_acc_q[lane_g-1];
                assign sample_in[lane_g] =
                    step_out_valid[lane_g-1][0] ? sample_s1_q[lane_g-1] : sample_q[lane_g-1];
            end

            for (tile_g = 0; tile_g < SEG_TILES; tile_g = tile_g + 1) begin : g_step_tile
                if (lane_g == 0) begin : g_pm_lane0
                    assign step_pm_in[lane_g][tile_g] = pm_tile_start_q[tile_g];
                end else begin : g_pm_laneN
                    assign step_pm_in[lane_g][tile_g] =
                        (ENABLE_PM_HANDOFF_REG || !step_out_valid[lane_g-1][tile_g])
                            ? pm_lane_q[lane_g-1][tile_g]
                            : step_pm_next[lane_g-1][tile_g];
                end

                if (lane_g == 0) begin : g_lane_mat0
                    assign step_lane_mat[lane_g][tile_g] =
                        tile_lane_group_mat_get(lane_group_trace0_pipe[0], tile_g);
                end else if (lane_g == 1) begin : g_lane_mat1
                    assign step_lane_mat[lane_g][tile_g] =
                        tile_lane_group_mat_get(lane_group_trace1_pipe[4], tile_g);
                end else if (lane_g == 2) begin : g_lane_mat2
                    assign step_lane_mat[lane_g][tile_g] =
                        tile_lane_group_mat_get(lane_group_trace2_pipe[8], tile_g);
                end else if (lane_g == 3) begin : g_lane_mat3
                    assign step_lane_mat[lane_g][tile_g] =
                        tile_lane_group_mat_get(lane_group_trace3_pipe[12], tile_g);
                end else if (lane_g == 4) begin : g_lane_mat4
                    assign step_lane_mat[lane_g][tile_g] =
                        tile_lane_group_mat_get(lane_group_trace4_pipe[16], tile_g);
                end else if (lane_g == 5) begin : g_lane_mat5
                    assign step_lane_mat[lane_g][tile_g] =
                        tile_lane_group_mat_get(lane_group_trace5_pipe[20], tile_g);
                end else if (lane_g == 6) begin : g_lane_mat6
                    assign step_lane_mat[lane_g][tile_g] =
                        tile_lane_group_mat_get(lane_group_trace6_pipe[24], tile_g);
                end else begin : g_lane_mat7
                    assign step_lane_mat[lane_g][tile_g] =
                        tile_lane_group_mat_get(lane_group_trace7_pipe[28], tile_g);
                end

                (* keep_hierarchy = "yes" *)
                codex_pam4_rs4_apply_xform_rowpipe_ooc #(
                    .MET_W(MET_W),
                    .ENABLE_OUTPUT_PIPELINE_SPLIT(ENABLE_ROW_OUTPUT_PIPELINE_SPLIT)
                ) u_rowpipe (
                    .clk(clk),
                    .rst_n(rst_n),
                    .in_valid(step_in_valid[lane_g]),
                    .lane_mat(step_lane_mat[lane_g][tile_g]),
                    .pm_in(step_pm_in[lane_g][tile_g]),
                    .out_valid(step_out_valid[lane_g][tile_g]),
                    .pm_next(step_pm_next[lane_g][tile_g]),
                    .pred_cols(step_pred_cols[lane_g][tile_g]),
                    .best_idx(step_best_idx[lane_g][tile_g])
                );
            end
        end
    endgenerate

    always_ff @(posedge clk or negedge rst_n) begin
        int local_lane;
        int tile_idx;
        int dd;

        if (!rst_n) begin
            trace_valid_q <= 1'b0;
            final_valid_q <= 1'b0;
            step_start_q <= '0;
            out_valid <= 1'b0;
            samples_processed_q <= '0;
            pred_cols_flat <= '0;
            best_state_lane_flat <= '0;
            decision_ready_lane <= '0;
            fb_idx_out_flat <= '0;
            for (local_lane = 0; local_lane < STATES; local_lane = local_lane + 1)
                fb_idx_out_flat[(local_lane*2) +: 2] <= local_lane[1:0];
            pm_end_flat <= '0;
            pm_end_stage_q <= '0;

            lane_group_trace0_pipe[0] <= '0;
            for (local_lane = 0; local_lane < TILE_LANES; local_lane = local_lane + 1)
                lane_group_capture_q[local_lane] <= '0;
            for (dd = 0; dd < 5; dd = dd + 1) lane_group_trace1_pipe[dd] <= '0;
            for (dd = 0; dd < 9; dd = dd + 1) lane_group_trace2_pipe[dd] <= '0;
            for (dd = 0; dd < 13; dd = dd + 1) lane_group_trace3_pipe[dd] <= '0;
            for (dd = 0; dd < 17; dd = dd + 1) lane_group_trace4_pipe[dd] <= '0;
            for (dd = 0; dd < 21; dd = dd + 1) lane_group_trace5_pipe[dd] <= '0;
            for (dd = 0; dd < 25; dd = dd + 1) lane_group_trace6_pipe[dd] <= '0;
            for (dd = 0; dd < 29; dd = dd + 1) lane_group_trace7_pipe[dd] <= '0;

            for (local_lane = 0; local_lane < TILE_LANES; local_lane = local_lane + 1) begin
                pred_acc_s0_q[local_lane] <= '0;
                pred_acc_s1_q[local_lane] <= '0;
                pred_acc_q[local_lane] <= '0;
                best_acc_s0_q[local_lane] <= '0;
                best_acc_s1_q[local_lane] <= '0;
                best_acc_q[local_lane] <= '0;
                ready_acc_s0_q[local_lane] <= '0;
                ready_acc_s1_q[local_lane] <= '0;
                ready_acc_q[local_lane] <= '0;
                sample_s0_q[local_lane] <= '0;
                sample_s1_q[local_lane] <= '0;
                sample_q[local_lane] <= '0;
                for (tile_idx = 0; tile_idx < SEG_TILES; tile_idx = tile_idx + 1)
                    pm_lane_q[local_lane][tile_idx] <= '0;
            end
            for (tile_idx = 0; tile_idx < SEG_TILES; tile_idx = tile_idx + 1)
                pm_tile_start_q[tile_idx] <= '0;
        end else begin
            trace_valid_q <= in_valid;
            step_start_q[0] <= in_valid;
            for (local_lane = 1; local_lane < TILE_LANES; local_lane = local_lane + 1)
                step_start_q[local_lane] <= step_out_valid[local_lane-1][0];

            if (in_valid) begin
                samples_processed_q <= samples_processed_in;
                for (tile_idx = 0; tile_idx < SEG_TILES; tile_idx = tile_idx + 1)
                    pm_tile_start_q[tile_idx] <= pm_tile_start_flat[(tile_idx*PM_W) +: PM_W];
                for (local_lane = 0; local_lane < TILE_LANES; local_lane = local_lane + 1)
                    lane_group_capture_q[local_lane] <= lane_group[local_lane];
            end

            lane_group_trace0_pipe[0] <= in_valid ? lane_group[0] : lane_group_capture_q[0];
            lane_group_trace1_pipe[0] <= in_valid ? lane_group[1] : lane_group_capture_q[1];
            for (dd = 1; dd < 5; dd = dd + 1) lane_group_trace1_pipe[dd] <= lane_group_trace1_pipe[dd-1];
            lane_group_trace2_pipe[0] <= in_valid ? lane_group[2] : lane_group_capture_q[2];
            for (dd = 1; dd < 9; dd = dd + 1) lane_group_trace2_pipe[dd] <= lane_group_trace2_pipe[dd-1];
            lane_group_trace3_pipe[0] <= in_valid ? lane_group[3] : lane_group_capture_q[3];
            for (dd = 1; dd < 13; dd = dd + 1) lane_group_trace3_pipe[dd] <= lane_group_trace3_pipe[dd-1];
            lane_group_trace4_pipe[0] <= in_valid ? lane_group[4] : lane_group_capture_q[4];
            for (dd = 1; dd < 17; dd = dd + 1) lane_group_trace4_pipe[dd] <= lane_group_trace4_pipe[dd-1];
            lane_group_trace5_pipe[0] <= in_valid ? lane_group[5] : lane_group_capture_q[5];
            for (dd = 1; dd < 21; dd = dd + 1) lane_group_trace5_pipe[dd] <= lane_group_trace5_pipe[dd-1];
            lane_group_trace6_pipe[0] <= in_valid ? lane_group[6] : lane_group_capture_q[6];
            for (dd = 1; dd < 25; dd = dd + 1) lane_group_trace6_pipe[dd] <= lane_group_trace6_pipe[dd-1];
            lane_group_trace7_pipe[0] <= in_valid ? lane_group[7] : lane_group_capture_q[7];
            for (dd = 1; dd < 29; dd = dd + 1) lane_group_trace7_pipe[dd] <= lane_group_trace7_pipe[dd-1];

            for (local_lane = 0; local_lane < TILE_LANES; local_lane = local_lane + 1) begin
                if (step_in_valid[local_lane]) begin
                    pred_acc_s0_q[local_lane] <= pred_acc_in[local_lane];
                    best_acc_s0_q[local_lane] <= best_acc_in[local_lane];
                    ready_acc_s0_q[local_lane] <= ready_acc_in[local_lane];
                    sample_s0_q[local_lane] <= sample_in[local_lane];
                end
                pred_acc_s1_q[local_lane] <= pred_acc_s0_q[local_lane];
                best_acc_s1_q[local_lane] <= best_acc_s0_q[local_lane];
                ready_acc_s1_q[local_lane] <= ready_acc_s0_q[local_lane];
                sample_s1_q[local_lane] <= sample_s0_q[local_lane];

                if (step_out_valid[local_lane][0]) begin
                    pred_acc_q[local_lane] <= pred_acc_next_w[local_lane];
                    best_acc_q[local_lane] <= best_acc_next_w[local_lane];
                    ready_acc_q[local_lane] <= ready_acc_next_w[local_lane];
                    sample_q[local_lane] <= sample_s1_q[local_lane];
                    for (tile_idx = 0; tile_idx < SEG_TILES; tile_idx = tile_idx + 1)
                        pm_lane_q[local_lane][tile_idx] <= step_pm_next[local_lane][tile_idx];
                end
            end

            if (step_out_valid[TILE_LANES-1][0])
                pm_end_stage_q <= step_pm_next[TILE_LANES-1][SEG_TILES-1];

            final_valid_q <= step_out_valid[TILE_LANES-1][0];
            out_valid <= final_valid_q;
            if (final_valid_q) begin
                pred_cols_flat <= pred_acc_q[TILE_LANES-1];
                best_state_lane_flat <= best_acc_q[TILE_LANES-1];
                decision_ready_lane <= ready_acc_q[TILE_LANES-1];
                pm_end_flat <= pm_end_stage_q;
                for (local_lane = 0; local_lane < STATES; local_lane = local_lane + 1)
                    fb_idx_out_flat[(local_lane*2) +: 2] <=
                        pred_acc_q[TILE_LANES-1][(((LANES-1)*STATES + local_lane)*2) +: 2];
            end
        end
    end
endmodule
