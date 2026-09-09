`timescale 1ns/1ps

// Detector-first 32-lane board-adapter contract for the 512b RX input path.
// Board default frontend: raw16 -> truncate to raw8 -> EQ21(8b)
// -> detector_input8 -> prefix32 xform/trace shell.
// PR taps are detector metric coefficients, not a frontend NP filter. They use
// the detector Q_SHIFT scale: with Q_SHIFT=8, a memoryless identity metric is
// g0=256,g1=0,g2=0.
//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: Dual-Survivor Segmented Branch-Metric Matrix MLSD
// Module Name: codex_pam4_rs4_trace32_board_adapter_normprefix_contract
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Adapts raw 32-lane RX samples to the EQ, branch-metric, and trace-shell MLSD contract.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module codex_pam4_rs4_trace32_board_adapter_normprefix_contract #(
    parameter int TB = 40,
    parameter int MET_W = 10,
    parameter int Q_SHIFT = 8,
    parameter int SEGMENT_BRANCH_SURVIVORS = 2,
    parameter int CORE32_LAT = 100,
    parameter bit SYNTHETIC_XFORM_MODE = 1'b0,
    parameter bit USE_L1_BRANCH_METRIC = 1'b1,
    parameter int BRANCH_METRIC_SHIFT = 0,
    parameter bit ENABLE_PAIR_NORMALIZE = 1'b1,
    parameter bit ENABLE_PAIR_OFFSET_COMPENSATION = 1'b0,
    parameter bit ENABLE_END_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_INPUT_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_LANE_XFORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_LANE_SELECT_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_LANE_SELECT_SECOND_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_PAIR_XFORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_QUAD_XFORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_BLOCK_XFORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_EXPORT_PAIR_QUAD_XFORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_START_PM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_START_NORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_EVEN_PM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_EVEN_NORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_ODD_PM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_ODD_NORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_END_PM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_END_NORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_END_EXPORT_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_TILE_PM_STATE_UPDATE = 1'b0,
    parameter bit ENABLE_TRACE_PM_HANDOFF_REG = 1'b0,
    parameter bit ENABLE_TRACE_ROW_OUTPUT_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_DEBUG_OUTPUTS = 1'b1,
    parameter logic signed [11:0] G0_Q8 = 12'sd256,
    parameter logic signed [11:0] G1_Q8 = 12'sd0,
    parameter logic signed [11:0] G2_Q8 = 12'sd0,
    parameter logic signed [11:0] G0_CH0_Q8 = G0_Q8,
    parameter logic signed [11:0] G1_CH0_Q8 = G1_Q8,
    parameter logic signed [11:0] G2_CH0_Q8 = G2_Q8,
    parameter logic signed [11:0] G0_CH1_Q8 = G0_Q8,
    parameter logic signed [11:0] G1_CH1_Q8 = G1_Q8,
    parameter logic signed [11:0] G2_CH1_Q8 = G2_Q8,
    parameter logic signed [11:0] G0_CH2_Q8 = G0_Q8,
    parameter logic signed [11:0] G1_CH2_Q8 = G1_Q8,
    parameter logic signed [11:0] G2_CH2_Q8 = G2_Q8,
    parameter logic signed [11:0] G0_CH3_Q8 = G0_Q8,
    parameter logic signed [11:0] G1_CH3_Q8 = G1_Q8,
    parameter logic signed [11:0] G2_CH3_Q8 = G2_Q8
) (
    input  logic                 clk,
    input  logic                 rst_n,
    input  logic                 in_valid,
    input  logic [1:0]           ch_case_sel,
    input  logic signed [511:0]  in_data_16b,
    input  logic                 cfg_eq_override_en,
    input  logic signed [(21*8)-1:0] cfg_eq_coeffs_flat,
    input  logic                 cfg_pr_override_en,
    input  logic signed [(3*12)-1:0] cfg_pr_taps_flat,
    input  logic                 cfg_level_override_en,
    input  logic signed [31:0]   cfg_pam4_levels_flat,
    output logic signed [255:0]  raw8_packed,
    output logic signed [255:0]  eq8_packed,
    output logic signed [255:0]  detector_input8_packed,
    output logic signed [63:0]   dbg_detector_input8_lanes8,
    output logic signed [255:0]  dout_flat,
    output logic                 out_valid,
    output logic [15:0]          cand_count_sum,
    output logic signed [7:0]    dbg_raw0,
    output logic signed [15:0]   dbg_ch0,
    output logic [63:0]          dbg_mlsd_ctrl_packed,
    output logic [63:0]          dbg_mlsd_pm_packed,
    output logic                 trace_payload_valid,
    output logic [(4*MET_W)-1:0] trace_pm_end_debug_flat,
    output logic [(32*4*2)-1:0]  trace_pred_cols_debug_flat,
    output logic [(32*2)-1:0]    trace_best_state_lane_debug_flat,
    output logic [31:0]          trace_decision_ready_debug_lane,
    output logic [7:0]           trace_fb_idx_next_debug_flat,
    output logic                 detector_accept_valid
);
    localparam int STATES = 4;
    localparam int LANES = 32;
    localparam int TILES = 4;
    localparam int TILE_LANES = 8;
    localparam int PM_W = STATES * MET_W;
    localparam int MAT_W = STATES * STATES * MET_W;
    localparam int EQ_W = 8;
    localparam int RAW8_SHIFT = 7;
    localparam int PAM4_RX_EQ21_LATENCY = 4;
    localparam int SAMPLE_COUNT_W = (TB <= 1) ? 1 : $clog2(TB + 1);
    localparam logic signed [7:0] PAM4_STATIC_L0 = -8'sd96;
    localparam logic signed [7:0] PAM4_STATIC_L1 = -8'sd32;
    localparam logic signed [7:0] PAM4_STATIC_L2 =  8'sd32;
    localparam logic signed [7:0] PAM4_STATIC_L3 =  8'sd96;

    function automatic logic [15:0] pack_pm16(input logic [MET_W-1:0] pm);
        pack_pm16 = {{(16-MET_W){1'b0}}, pm};
    endfunction

    logic real_xform_valid;
    logic [PM_W-1:0] real_pm_start_flat;
    logic [(LANES*MAT_W)-1:0] real_lane_xform_flat;
    logic [(TILES*PM_W)-1:0] real_pm_tile_start_flat;
    logic [PM_W-1:0] real_pm_end_export_flat;
    logic [SAMPLE_COUNT_W-1:0] real_samples_processed;
    logic [7:0] real_fb_idx_state;

    logic signed [7:0] pam4_l0_eff;
    logic signed [7:0] pam4_l1_eff;
    logic signed [7:0] pam4_l2_eff;
    logic signed [7:0] pam4_l3_eff;
    logic signed [(4*32)-1:0] g0_prod_flat_w;
    logic signed [(4*32)-1:0] g1_prod_flat_w;
    logic signed [(4*32)-1:0] g2_prod_flat_w;
    logic signed [11:0] g0_q8_sel_w;
    logic signed [11:0] g1_q8_sel_w;
    logic signed [11:0] g2_q8_sel_w;
    logic signed [11:0] g0_q8_s0_q;
    logic signed [11:0] g1_q8_s0_q;
    logic signed [11:0] g2_q8_s0_q;
    logic signed [7:0] pam4_l0_s0_q;
    logic signed [7:0] pam4_l1_s0_q;
    logic signed [7:0] pam4_l2_s0_q;
    logic signed [7:0] pam4_l3_s0_q;
    (* use_dsp = "yes" *) logic signed [19:0] g0_l0_prod_q;
    (* use_dsp = "yes" *) logic signed [19:0] g0_l1_prod_q;
    (* use_dsp = "yes" *) logic signed [19:0] g0_l2_prod_q;
    (* use_dsp = "yes" *) logic signed [19:0] g0_l3_prod_q;
    (* use_dsp = "yes" *) logic signed [19:0] g1_l0_prod_q;
    (* use_dsp = "yes" *) logic signed [19:0] g1_l1_prod_q;
    (* use_dsp = "yes" *) logic signed [19:0] g1_l2_prod_q;
    (* use_dsp = "yes" *) logic signed [19:0] g1_l3_prod_q;
    (* use_dsp = "yes" *) logic signed [19:0] g2_l0_prod_q;
    (* use_dsp = "yes" *) logic signed [19:0] g2_l1_prod_q;
    (* use_dsp = "yes" *) logic signed [19:0] g2_l2_prod_q;
    (* use_dsp = "yes" *) logic signed [19:0] g2_l3_prod_q;
    (* use_dsp = "yes" *) logic signed [19:0] g0_l0_prod_m_q;
    (* use_dsp = "yes" *) logic signed [19:0] g0_l1_prod_m_q;
    (* use_dsp = "yes" *) logic signed [19:0] g0_l2_prod_m_q;
    (* use_dsp = "yes" *) logic signed [19:0] g0_l3_prod_m_q;
    (* use_dsp = "yes" *) logic signed [19:0] g1_l0_prod_m_q;
    (* use_dsp = "yes" *) logic signed [19:0] g1_l1_prod_m_q;
    (* use_dsp = "yes" *) logic signed [19:0] g1_l2_prod_m_q;
    (* use_dsp = "yes" *) logic signed [19:0] g1_l3_prod_m_q;
    (* use_dsp = "yes" *) logic signed [19:0] g2_l0_prod_m_q;
    (* use_dsp = "yes" *) logic signed [19:0] g2_l1_prod_m_q;
    (* use_dsp = "yes" *) logic signed [19:0] g2_l2_prod_m_q;
    (* use_dsp = "yes" *) logic signed [19:0] g2_l3_prod_m_q;
    logic xform_s0_valid_q;
    logic xform_s1_valid_q;
    logic xform_stage_valid_q;
    logic [255:0] xform_s0_din_q;
    logic [255:0] xform_s1_din_q;
    logic [255:0] xform_stage_din_q;

    logic trace_out_valid;
    logic [PM_W-1:0] trace_pm_end_flat;
    logic [(LANES*STATES*2)-1:0] trace_pred_cols_flat;
    logic [(LANES*2)-1:0] trace_best_state_lane_flat;
    logic [(LANES*2)-1:0] trace_survivor_state_lane_flat;
    logic [LANES-1:0] trace_decision_ready_lane;
    logic [7:0] trace_fb_idx_next_flat;
    logic [PM_W-1:0] trace_pm_end_struct_flat;

    logic drop_sticky_q;
    logic [15:0] accept_count_q;
    logic [15:0] drop_count_q;
    logic [PAM4_RX_EQ21_LATENCY:0] frontend_valid_pipe_q;
    logic [1:0] ch_case_sel_pipe_q [0:PAM4_RX_EQ21_LATENCY];
    logic signed [255:0]          raw8_live_packed;
    logic signed [255:0]          raw8_det_packed;
    logic signed [255:0]          detector_input8_det_packed;
    logic signed [(LANES*EQ_W)-1:0] eq_input8_live_packed;
    logic signed [(LANES*EQ_W)-1:0] eq8_live_packed;
    logic signed [511:0] active_in_data_q;

    wire adapter_busy = 1'b0;
    wire fullrate_pipe_reserved_full = 1'b0;
    wire input_accept_fire = in_valid;
    wire input_overflow_fire = 1'b0;
    wire use_eq_frontend = (cfg_eq_override_en === 1'b1);
    wire frontend_eq_only_valid = in_valid && frontend_valid_pipe_q[PAM4_RX_EQ21_LATENCY];
    wire frontend_xform_fire = use_eq_frontend ? frontend_eq_only_valid : in_valid;
    wire launch_fire = frontend_xform_fire;
    wire trace_launch_fire = real_xform_valid;
    wire real_state_update_fire = trace_out_valid;
    wire [1:0] metric_ch_case_sel = use_eq_frontend ? ch_case_sel_pipe_q[PAM4_RX_EQ21_LATENCY] : ch_case_sel;

    assign detector_accept_valid = input_accept_fire;
    assign out_valid = trace_out_valid;
    assign cand_count_sum = ENABLE_DEBUG_OUTPUTS ? (out_valid ? 16'd256 : 16'd0) : 16'd0;
    assign trace_payload_valid = ENABLE_DEBUG_OUTPUTS ? trace_out_valid : 1'b0;
    assign trace_pm_end_debug_flat = ENABLE_DEBUG_OUTPUTS ? trace_pm_end_flat : '0;
    assign trace_pred_cols_debug_flat = ENABLE_DEBUG_OUTPUTS ? trace_pred_cols_flat : '0;
    assign trace_best_state_lane_debug_flat = ENABLE_DEBUG_OUTPUTS ? trace_best_state_lane_flat : '0;
    assign trace_decision_ready_debug_lane = ENABLE_DEBUG_OUTPUTS ? trace_decision_ready_lane : '0;
    assign trace_fb_idx_next_debug_flat = ENABLE_DEBUG_OUTPUTS ? trace_fb_idx_next_flat : '0;

    always_ff @(posedge clk) begin
        active_in_data_q <= in_data_16b;
    end

    codex_pam4_rs4_prefix32_xform_export_ooc #(
        .TB(TB),
        .MET_W(MET_W),
        .Q_SHIFT(Q_SHIFT),
        .SEGMENT_BRANCH_SURVIVORS(SEGMENT_BRANCH_SURVIVORS),
        .USE_L1_BRANCH_METRIC(USE_L1_BRANCH_METRIC),
        .BRANCH_METRIC_SHIFT(BRANCH_METRIC_SHIFT),
        .ENABLE_PAIR_NORMALIZE(ENABLE_PAIR_NORMALIZE),
        .ENABLE_PAIR_OFFSET_COMPENSATION(ENABLE_PAIR_OFFSET_COMPENSATION),
        .ENABLE_TILE_INPUT_PIPELINE_SPLIT(ENABLE_TILE_INPUT_PIPELINE_SPLIT),
        .ENABLE_LANE_XFORM_PIPELINE_SPLIT(ENABLE_LANE_XFORM_PIPELINE_SPLIT),
        .ENABLE_LANE_SELECT_PIPELINE_SPLIT(ENABLE_LANE_SELECT_PIPELINE_SPLIT),
        .ENABLE_TILE_LANE_SELECT_SECOND_PIPELINE_SPLIT(ENABLE_TILE_LANE_SELECT_SECOND_PIPELINE_SPLIT),
        .ENABLE_TILE_PAIR_XFORM_PIPELINE_SPLIT(ENABLE_TILE_PAIR_XFORM_PIPELINE_SPLIT),
        .ENABLE_TILE_QUAD_XFORM_PIPELINE_SPLIT(ENABLE_TILE_QUAD_XFORM_PIPELINE_SPLIT),
        .ENABLE_TILE_BLOCK_XFORM_PIPELINE_SPLIT(ENABLE_TILE_BLOCK_XFORM_PIPELINE_SPLIT),
        .ENABLE_TILE_START_PM_PIPELINE_SPLIT(ENABLE_TILE_START_PM_PIPELINE_SPLIT),
        .ENABLE_TILE_END_PM_PIPELINE_SPLIT(ENABLE_TILE_END_PM_PIPELINE_SPLIT),
        .ENABLE_TILE_PM_STATE_UPDATE(ENABLE_TILE_PM_STATE_UPDATE)
    ) u_xform_export (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(xform_stage_valid_q),
        .din32_flat(xform_stage_din_q),
        .g0_prod_flat(g0_prod_flat_w),
        .g1_prod_flat(g1_prod_flat_w),
        .g2_prod_flat(g2_prod_flat_w),
        .state_update_valid(real_state_update_fire),
        .pm_update_flat(trace_pm_end_flat),
        .fb_idx_update_flat(trace_fb_idx_next_flat),
        .xform_valid(real_xform_valid),
        .pm_start_flat(real_pm_start_flat),
        .lane_xform_flat(real_lane_xform_flat),
        .pm_tile_start_flat(real_pm_tile_start_flat),
        .pm_end_export_flat(real_pm_end_export_flat),
        .samples_processed_out(real_samples_processed),
        .fb_idx_state_out(real_fb_idx_state)
    );

    assign trace_pm_end_struct_flat = real_pm_end_export_flat;

    codex_pam4_rs4_prefix32_trace_shell_rowpipe #(
        .TB(TB),
        .MET_W(MET_W),
        .GROUP_BASE_LANE(0),
        .ENABLE_PM_HANDOFF_REG(ENABLE_TRACE_PM_HANDOFF_REG),
        .ENABLE_ROW_OUTPUT_PIPELINE_SPLIT(ENABLE_TRACE_ROW_OUTPUT_PIPELINE_SPLIT)
    ) u_trace_shell (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(trace_launch_fire),
        .pm_tile_start_flat(real_pm_tile_start_flat),
        .lane_xform_flat(real_lane_xform_flat),
        .samples_processed_in(real_samples_processed),
        .out_valid(trace_out_valid),
        .pred_cols_flat(trace_pred_cols_flat),
        .best_state_lane_flat(trace_best_state_lane_flat),
        .decision_ready_lane(trace_decision_ready_lane),
        .fb_idx_out_flat(trace_fb_idx_next_flat),
        .pm_end_flat()
    );

    function automatic logic signed [7:0] trunc16_to_s8(input logic signed [15:0] x);
        logic signed [16:0] shifted;
        begin
            shifted = $signed({x[15], x}) >>> RAW8_SHIFT;
            if (shifted > 17'sd127) begin
                trunc16_to_s8 = 8'sd127;
            end else if (shifted < -17'sd128) begin
                trunc16_to_s8 = -8'sd128;
            end else begin
                trunc16_to_s8 = shifted[7:0];
            end
        end
    endfunction

    function automatic logic signed [15:0] lane16_from_fifo32(
        input logic signed [511:0] flat,
        input int lane
    );
        int group;
        int local_lane;
        int bit_base;
        begin
            group = lane / TILE_LANES;
            local_lane = lane % TILE_LANES;
            bit_base = ((TILES - 1 - group) * 128) + (local_lane * 16);
            lane16_from_fifo32 = flat[bit_base +: 16];
        end
    endfunction

    function automatic logic signed [11:0] select_g_q8(
        input logic [1:0] tap_sel,
        input logic [1:0] ch_sel,
        input logic cfg_override,
        input logic signed [(3*12)-1:0] cfg_flat
    );
        begin
            if (cfg_override == 1'b1) begin
                unique case (tap_sel)
                    2'd0: select_g_q8 = $signed(cfg_flat[11:0]);
                    2'd1: select_g_q8 = $signed(cfg_flat[23:12]);
                    default: select_g_q8 = $signed(cfg_flat[35:24]);
                endcase
            end else begin
                unique case ({ch_sel, tap_sel})
                    4'd0:  select_g_q8 = G0_CH0_Q8;
                    4'd1:  select_g_q8 = G1_CH0_Q8;
                    4'd2:  select_g_q8 = G2_CH0_Q8;
                    4'd4:  select_g_q8 = G0_CH1_Q8;
                    4'd5:  select_g_q8 = G1_CH1_Q8;
                    4'd6:  select_g_q8 = G2_CH1_Q8;
                    4'd8:  select_g_q8 = G0_CH2_Q8;
                    4'd9:  select_g_q8 = G1_CH2_Q8;
                    4'd10: select_g_q8 = G2_CH2_Q8;
                    4'd12: select_g_q8 = G0_CH3_Q8;
                    4'd13: select_g_q8 = G1_CH3_Q8;
                    default: select_g_q8 = G2_CH3_Q8;
                endcase
            end
        end
    endfunction

    function automatic logic signed [31:0] sx20_to_s32(
        input logic signed [19:0] x
    );
        begin
            sx20_to_s32 = {{12{x[19]}}, x};
        end
    endfunction

    function automatic logic signed [(4*32)-1:0] pack_prod_flat(
        input logic signed [19:0] p0,
        input logic signed [19:0] p1,
        input logic signed [19:0] p2,
        input logic signed [19:0] p3
    );
        begin
            pack_prod_flat = {sx20_to_s32(p3), sx20_to_s32(p2),
                              sx20_to_s32(p1), sx20_to_s32(p0)};
        end
    endfunction

    function automatic logic signed [7:0] pam4_level_from_state(
        input logic [1:0] state,
        input logic signed [7:0] l0,
        input logic signed [7:0] l1,
        input logic signed [7:0] l2,
        input logic signed [7:0] l3
    );
        begin
            unique case (state)
                2'd0: pam4_level_from_state = l0;
                2'd1: pam4_level_from_state = l1;
                2'd2: pam4_level_from_state = l2;
                default: pam4_level_from_state = l3;
            endcase
        end
    endfunction

    always_comb begin
        int lane;
        int pred_idx;
        logic [1:0] cur_state;

        trace_survivor_state_lane_flat = '0;
        cur_state = trace_best_state_lane_flat[((LANES-1)*2) +: 2];
        for (lane = LANES-1; lane >= 0; lane = lane - 1) begin
            trace_survivor_state_lane_flat[(lane*2) +: 2] = cur_state;
            pred_idx = (lane*STATES) + cur_state;
            cur_state = trace_pred_cols_flat[(pred_idx*2) +: 2];
        end
    end

    assign pam4_l0_eff = (cfg_level_override_en === 1'b1) ? $signed(cfg_pam4_levels_flat[7:0])   : PAM4_STATIC_L0;
    assign pam4_l1_eff = (cfg_level_override_en === 1'b1) ? $signed(cfg_pam4_levels_flat[15:8])  : PAM4_STATIC_L1;
    assign pam4_l2_eff = (cfg_level_override_en === 1'b1) ? $signed(cfg_pam4_levels_flat[23:16]) : PAM4_STATIC_L2;
    assign pam4_l3_eff = (cfg_level_override_en === 1'b1) ? $signed(cfg_pam4_levels_flat[31:24]) : PAM4_STATIC_L3;
    assign g0_q8_sel_w = select_g_q8(2'd0, metric_ch_case_sel, cfg_pr_override_en, cfg_pr_taps_flat);
    assign g1_q8_sel_w = select_g_q8(2'd1, metric_ch_case_sel, cfg_pr_override_en, cfg_pr_taps_flat);
    assign g2_q8_sel_w = select_g_q8(2'd2, metric_ch_case_sel, cfg_pr_override_en, cfg_pr_taps_flat);
    assign g0_prod_flat_w = pack_prod_flat(g0_l0_prod_q, g0_l1_prod_q, g0_l2_prod_q, g0_l3_prod_q);
    assign g1_prod_flat_w = pack_prod_flat(g1_l0_prod_q, g1_l1_prod_q, g1_l2_prod_q, g1_l3_prod_q);
    assign g2_prod_flat_w = pack_prod_flat(g2_l0_prod_q, g2_l1_prod_q, g2_l2_prod_q, g2_l3_prod_q);

    // Live RX EQ uses a 32-lane transposed FIR with 8b samples and 8b Q6
    // runtime coefficients. Its output is the detector_input8 bus when enabled.
    FIR_Q6_NTAP_TRANSPOSED_32LANE #(
        .LANES(32),
        .NTAPS(21),
        .SHIFT(6)
    ) u_rx_eq21_live (
        .clk(clk),
        .rst_n(rst_n),
        .ce(in_valid),
        .din_flat(eq_input8_live_packed),
        .h_packed(cfg_eq_coeffs_flat),
        .dout_flat(eq8_live_packed)
    );

    always_comb begin
        int lane;
        logic signed [15:0] raw16;
        logic signed [7:0] raw8;
        logic signed [7:0] eq8;

        raw8_live_packed = '0;
        eq_input8_live_packed = '0;
        raw8_packed = '0;
        eq8_packed = '0;
        detector_input8_packed = '0;
        raw8_det_packed = '0;
        detector_input8_det_packed = '0;

        for (lane = 0; lane < LANES; lane = lane + 1) begin
            raw16 = lane16_from_fifo32(in_data_16b, lane);
            raw8 = trunc16_to_s8(raw16);
            eq8 = eq8_live_packed[(lane*EQ_W) +: EQ_W];
            raw8_live_packed[(lane*8) +: 8] = raw8;
            eq_input8_live_packed[(lane*EQ_W) +: EQ_W] = raw8;
            raw8_packed[(lane*8) +: 8] = raw8;
            eq8_packed[(lane*8) +: 8] = use_eq_frontend ? eq8 : raw8;
            detector_input8_packed[(lane*8) +: 8] = eq8_packed[(lane*8) +: 8];
            raw8_det_packed[(lane*8) +: 8] = raw8;
            detector_input8_det_packed[(lane*8) +: 8] =
                detector_input8_packed[(lane*8) +: 8];
        end
    end

    always_comb begin
        int lane;
        logic [1:0] best_state;

        dout_flat = '0;
        for (lane = 0; lane < LANES; lane = lane + 1) begin
            best_state = trace_survivor_state_lane_flat[(lane*2) +: 2];
            if (trace_decision_ready_lane[lane]) begin
                dout_flat[(lane*8) +: 8] = pam4_level_from_state(best_state,
                                                                 pam4_l0_eff,
                                                                 pam4_l1_eff,
                                                                 pam4_l2_eff,
                                                                 pam4_l3_eff);
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        int pipe_i;
        if (!rst_n) begin
            trace_pm_end_flat <= '0;
            frontend_valid_pipe_q <= '0;
            g0_q8_s0_q <= '0;
            g1_q8_s0_q <= '0;
            g2_q8_s0_q <= '0;
            pam4_l0_s0_q <= '0;
            pam4_l1_s0_q <= '0;
            pam4_l2_s0_q <= '0;
            pam4_l3_s0_q <= '0;
            xform_s0_valid_q <= 1'b0;
            xform_s1_valid_q <= 1'b0;
            xform_stage_valid_q <= 1'b0;
            xform_s0_din_q <= '0;
            xform_s1_din_q <= '0;
            xform_stage_din_q <= '0;
            for (pipe_i = 0; pipe_i <= PAM4_RX_EQ21_LATENCY; pipe_i = pipe_i + 1)
                ch_case_sel_pipe_q[pipe_i] <= '0;
        end else begin
            if (in_valid) begin
                frontend_valid_pipe_q <= {frontend_valid_pipe_q[PAM4_RX_EQ21_LATENCY-1:0], 1'b1};
                ch_case_sel_pipe_q[0] <= ch_case_sel;
                for (pipe_i = 1; pipe_i <= PAM4_RX_EQ21_LATENCY; pipe_i = pipe_i + 1)
                    ch_case_sel_pipe_q[pipe_i] <= ch_case_sel_pipe_q[pipe_i-1];
            end

            g0_q8_s0_q <= g0_q8_sel_w;
            g1_q8_s0_q <= g1_q8_sel_w;
            g2_q8_s0_q <= g2_q8_sel_w;
            pam4_l0_s0_q <= pam4_l0_eff;
            pam4_l1_s0_q <= pam4_l1_eff;
            pam4_l2_s0_q <= pam4_l2_eff;
            pam4_l3_s0_q <= pam4_l3_eff;
            xform_s0_valid_q <= frontend_xform_fire;
            if (frontend_xform_fire) begin
                xform_s0_din_q <= detector_input8_packed;
            end

            xform_s1_valid_q <= xform_s0_valid_q;
            if (xform_s0_valid_q) begin
                xform_s1_din_q <= xform_s0_din_q;
            end
            xform_stage_valid_q <= xform_s1_valid_q;
            if (xform_s1_valid_q) begin
                xform_stage_din_q <= xform_s1_din_q;
            end

            if (real_xform_valid) begin
                trace_pm_end_flat <= real_pm_end_export_flat;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            g0_l0_prod_q <= '0;
            g0_l1_prod_q <= '0;
            g0_l2_prod_q <= '0;
            g0_l3_prod_q <= '0;
            g0_l0_prod_m_q <= '0;
            g0_l1_prod_m_q <= '0;
            g0_l2_prod_m_q <= '0;
            g0_l3_prod_m_q <= '0;
            g1_l0_prod_q <= '0;
            g1_l1_prod_q <= '0;
            g1_l2_prod_q <= '0;
            g1_l3_prod_q <= '0;
            g1_l0_prod_m_q <= '0;
            g1_l1_prod_m_q <= '0;
            g1_l2_prod_m_q <= '0;
            g1_l3_prod_m_q <= '0;
            g2_l0_prod_q <= '0;
            g2_l1_prod_q <= '0;
            g2_l2_prod_q <= '0;
            g2_l3_prod_q <= '0;
            g2_l0_prod_m_q <= '0;
            g2_l1_prod_m_q <= '0;
            g2_l2_prod_m_q <= '0;
            g2_l3_prod_m_q <= '0;
        end else begin
            g0_l0_prod_m_q <= $signed(g0_q8_s0_q) * $signed(pam4_l0_s0_q);
            g0_l1_prod_m_q <= $signed(g0_q8_s0_q) * $signed(pam4_l1_s0_q);
            g0_l2_prod_m_q <= $signed(g0_q8_s0_q) * $signed(pam4_l2_s0_q);
            g0_l3_prod_m_q <= $signed(g0_q8_s0_q) * $signed(pam4_l3_s0_q);
            g1_l0_prod_m_q <= $signed(g1_q8_s0_q) * $signed(pam4_l0_s0_q);
            g1_l1_prod_m_q <= $signed(g1_q8_s0_q) * $signed(pam4_l1_s0_q);
            g1_l2_prod_m_q <= $signed(g1_q8_s0_q) * $signed(pam4_l2_s0_q);
            g1_l3_prod_m_q <= $signed(g1_q8_s0_q) * $signed(pam4_l3_s0_q);
            g2_l0_prod_m_q <= $signed(g2_q8_s0_q) * $signed(pam4_l0_s0_q);
            g2_l1_prod_m_q <= $signed(g2_q8_s0_q) * $signed(pam4_l1_s0_q);
            g2_l2_prod_m_q <= $signed(g2_q8_s0_q) * $signed(pam4_l2_s0_q);
            g2_l3_prod_m_q <= $signed(g2_q8_s0_q) * $signed(pam4_l3_s0_q);

            g0_l0_prod_q <= g0_l0_prod_m_q;
            g0_l1_prod_q <= g0_l1_prod_m_q;
            g0_l2_prod_q <= g0_l2_prod_m_q;
            g0_l3_prod_q <= g0_l3_prod_m_q;
            g1_l0_prod_q <= g1_l0_prod_m_q;
            g1_l1_prod_q <= g1_l1_prod_m_q;
            g1_l2_prod_q <= g1_l2_prod_m_q;
            g1_l3_prod_q <= g1_l3_prod_m_q;
            g2_l0_prod_q <= g2_l0_prod_m_q;
            g2_l1_prod_q <= g2_l1_prod_m_q;
            g2_l2_prod_q <= g2_l2_prod_m_q;
            g2_l3_prod_q <= g2_l3_prod_m_q;
        end
    end

    generate
        if (ENABLE_DEBUG_OUTPUTS) begin : GEN_DEBUG_OUTPUTS
            always_ff @(posedge clk or negedge rst_n) begin
                if (!rst_n) begin
                    dbg_detector_input8_lanes8 <= '0;
                    dbg_raw0 <= '0;
                    dbg_ch0 <= '0;
                    dbg_mlsd_ctrl_packed <= '0;
                    dbg_mlsd_pm_packed <= '0;
                    drop_sticky_q <= 1'b0;
                    accept_count_q <= 16'd0;
                    drop_count_q <= 16'd0;
                end else begin
                    if (input_accept_fire) begin
                        accept_count_q <= accept_count_q + 1'b1;
                    end
                    if (input_overflow_fire) begin
                        drop_sticky_q <= 1'b1;
                        if (drop_count_q != 16'hFFFF) begin
                            drop_count_q <= drop_count_q + 1'b1;
                        end
                    end
                    if (launch_fire) begin
                        if (!use_eq_frontend) begin
                            dbg_detector_input8_lanes8 <= detector_input8_det_packed[63:0];
                        end
                        dbg_raw0 <= raw8_det_packed[7:0];
                        dbg_ch0 <= lane16_from_fifo32(active_in_data_q, 0);
                    end
                    if (frontend_xform_fire) begin
                        dbg_detector_input8_lanes8 <= detector_input8_det_packed[63:0];
                    end

                    dbg_mlsd_ctrl_packed <= {
                        accept_count_q[7:0],
                        drop_count_q[7:0],
                        trace_best_state_lane_flat[15:0],
                        trace_decision_ready_lane[7:0],
                        trace_fb_idx_next_flat,
                        {fullrate_pipe_reserved_full, 7'd0},
                        drop_sticky_q,
                        adapter_busy,
                        trace_out_valid,
                        trace_launch_fire,
                        real_xform_valid,
                        launch_fire,
                        input_accept_fire,
                        trace_decision_ready_lane[0]
                    };
                    dbg_mlsd_pm_packed <= {
                        pack_pm16(trace_pm_end_flat[(3*MET_W) +: MET_W]),
                        pack_pm16(trace_pm_end_flat[(2*MET_W) +: MET_W]),
                        pack_pm16(trace_pm_end_flat[(1*MET_W) +: MET_W]),
                        pack_pm16(trace_pm_end_flat[(0*MET_W) +: MET_W])
                    };
                end
            end
        end else begin : GEN_NO_DEBUG_OUTPUTS
            assign dbg_detector_input8_lanes8 = '0;
            assign dbg_raw0 = '0;
            assign dbg_ch0 = '0;
            assign dbg_mlsd_ctrl_packed = '0;
            assign dbg_mlsd_pm_packed = '0;
        end
    endgenerate

    wire unused_cfg = cfg_eq_override_en ^ cfg_pr_override_en ^
                      cfg_level_override_en ^ SYNTHETIC_XFORM_MODE ^ CORE32_LAT[0] ^
                      ENABLE_END_PIPELINE_SPLIT ^
                      ENABLE_EXPORT_PAIR_QUAD_XFORM_PIPELINE_SPLIT ^
                      ENABLE_TILE_START_PM_PIPELINE_SPLIT ^
                      ENABLE_TILE_START_NORM_PIPELINE_SPLIT ^
                      ENABLE_TILE_EVEN_PM_PIPELINE_SPLIT ^
                      ENABLE_TILE_EVEN_NORM_PIPELINE_SPLIT ^
                      ENABLE_TILE_ODD_PM_PIPELINE_SPLIT ^
                      ENABLE_TILE_ODD_NORM_PIPELINE_SPLIT ^
                      ENABLE_TILE_END_PM_PIPELINE_SPLIT ^
                      ENABLE_TILE_END_NORM_PIPELINE_SPLIT ^
                      ENABLE_TILE_END_EXPORT_PIPELINE_SPLIT ^
                      ^cfg_eq_coeffs_flat ^
                      ^cfg_pr_taps_flat ^ ^cfg_pam4_levels_flat ^ ^ch_case_sel ^
                      ^real_pm_start_flat ^ ^real_fb_idx_state ^
                      ^trace_pm_end_struct_flat;
    wire unused_cfg_sink = unused_cfg;

endmodule
