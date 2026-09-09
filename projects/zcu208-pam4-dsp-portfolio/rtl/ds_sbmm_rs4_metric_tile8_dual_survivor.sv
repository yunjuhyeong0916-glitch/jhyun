`timescale 1ns/1ps

// Trace-capable 8-lane nearest-2 transform tile.
// The lane transform payload is delayed to align with block_xform_flat/out_valid.
//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: Dual-Survivor Segmented Branch-Metric Matrix MLSD
// Module Name: codex_pam4_rs4_prefix8_nearest2_metric_productflat_trace_ooc
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Computes an 8-lane dual-survivor segmented branch-metric matrix tile for PAM4 RS4 MLSD.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module codex_pam4_rs4_prefix8_nearest2_metric_productflat_trace_ooc #(
    parameter int MET_W = 12,
    parameter int Q_SHIFT = 8,
    // Number of branch candidates retained per previous state in the segmented
    // branch-metric matrix. The active DS-SBMM configuration uses 2 survivors.
    parameter int SEGMENT_BRANCH_SURVIVORS = 2,
    parameter bit USE_L1_BRANCH_METRIC = 1'b1,
    parameter int BRANCH_METRIC_SHIFT = 0,
    parameter bit USE_DEST_RESCUE = 1'b1,
    parameter bit ENABLE_PAIR_NORMALIZE = 1'b1,
    parameter bit ENABLE_PAIR_OFFSET_COMPENSATION = 1'b0,
    parameter bit ENABLE_INPUT_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_LANE_XFORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_LANE_SELECT_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_LANE_SELECT_SECOND_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_PAIR_XFORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_QUAD_XFORM_PIPELINE_SPLIT = 1'b0,
    parameter bit ENABLE_BLOCK_XFORM_PIPELINE_SPLIT = 1'b0,
    // Standalone prefix8 may export a running path metric. The trace-shell
    // xform-export path does not consume pm_out_flat, so it can disable this
    // feedback to remove the local pm_state -> pm_state critical path.
    parameter bit ENABLE_PM_STATE_UPDATE = 1'b1
) (
    input  logic                      clk,
    input  logic                      rst_n,
    input  logic                      in_valid,
    input  logic [63:0]               din8_flat,
    input  logic [(8*8)-1:0]          fb_idx_lane_flat,
    input  logic signed [(4*32)-1:0]  g0_prod_flat,
    input  logic signed [(4*32)-1:0]  g1_prod_flat,
    input  logic signed [(4*32)-1:0]  g2_prod_flat,
    output logic                      out_valid,
    output logic [(4*MET_W)-1:0]      pm_out_flat,
    output logic [(16*MET_W)-1:0]     block_xform_flat,
    output logic [(8*16*MET_W)-1:0]   lane_xform_flat
);
    localparam int LANES = 8;
    localparam int STATES = 4;
    localparam int ALPHABET = 4;
    localparam int ACTIVE_BRANCH_SURVIVORS =
        (SEGMENT_BRANCH_SURVIVORS < 1) ? 1 :
        ((SEGMENT_BRANCH_SURVIVORS > 4) ? 4 : SEGMENT_BRANCH_SURVIVORS);
    localparam int MAT_W = STATES * STATES * MET_W;
    localparam int PM_W = STATES * MET_W;
    localparam int PRE_ENTRY_W = MET_W + 17;
    localparam int PRE_W = STATES * ALPHABET * PRE_ENTRY_W;
    localparam int SELECT_W = STATES * ALPHABET;
    localparam int SECOND_SELECT_PART_ENTRY_W = 20;
    localparam int SECOND_SELECT_PART_W = STATES * SECOND_SELECT_PART_ENTRY_W;
    localparam bit LANE_SELECT_SECOND_PIPELINE_ACTIVE =
        ENABLE_LANE_XFORM_PIPELINE_SPLIT &&
        ENABLE_LANE_SELECT_PIPELINE_SPLIT &&
        ENABLE_LANE_SELECT_SECOND_PIPELINE_SPLIT &&
        (ACTIVE_BRANCH_SURVIVORS == 2);
    localparam bit QUAD_XFORM_PIPELINE_ACTIVE =
        ENABLE_QUAD_XFORM_PIPELINE_SPLIT &&
        !(!ENABLE_PAIR_NORMALIZE && ENABLE_PAIR_OFFSET_COMPENSATION);
    localparam bit PAIR_XFORM_PIPELINE_ACTIVE = ENABLE_PAIR_XFORM_PIPELINE_SPLIT;
    localparam bit BLOCK_XFORM_PIPELINE_ACTIVE =
        ENABLE_BLOCK_XFORM_PIPELINE_SPLIT &&
        !(!ENABLE_PAIR_NORMALIZE && ENABLE_PAIR_OFFSET_COMPENSATION);
    localparam bit INPUT_PIPELINE_ACTIVE = ENABLE_INPUT_PIPELINE_SPLIT;
    localparam logic [MET_W-1:0] INF = {MET_W{1'b1}};

    (* keep = "true", shreg_extract = "no" *) logic input_stage_valid_q;
    (* keep = "true", shreg_extract = "no" *) logic [63:0] din8_flat_q;
    (* keep = "true", shreg_extract = "no" *) logic [(8*8)-1:0] fb_idx_lane_flat_q;
    (* keep = "true", shreg_extract = "no" *) logic signed [(4*32)-1:0] g0_prod_flat_q;
    (* keep = "true", shreg_extract = "no" *) logic signed [(4*32)-1:0] g1_prod_flat_q;
    (* keep = "true", shreg_extract = "no" *) logic signed [(4*32)-1:0] g2_prod_flat_q;
    wire [63:0] din8_metric_flat = INPUT_PIPELINE_ACTIVE ? din8_flat_q : din8_flat;
    wire [(8*8)-1:0] fb_idx_metric_flat = INPUT_PIPELINE_ACTIVE ? fb_idx_lane_flat_q : fb_idx_lane_flat;
    wire signed [(4*32)-1:0] g0_metric_flat = INPUT_PIPELINE_ACTIVE ? g0_prod_flat_q : g0_prod_flat;
    wire signed [(4*32)-1:0] g1_metric_flat = INPUT_PIPELINE_ACTIVE ? g1_prod_flat_q : g1_prod_flat;
    wire signed [(4*32)-1:0] g2_metric_flat = INPUT_PIPELINE_ACTIVE ? g2_prod_flat_q : g2_prod_flat;

    logic [PRE_W-1:0] lane_metric_pre_c [0:LANES-1];
    logic [PRE_W-1:0] lane_metric_pre_q [0:LANES-1];
    logic [PRE_W-1:0] lane_metric_pre_select_first_q [0:LANES-1];
    logic [PRE_W-1:0] lane_metric_pre_select_second_q [0:LANES-1];
    logic [PRE_W-1:0] lane_metric_pre_select_q [0:LANES-1];
    logic [SELECT_W-1:0] lane_xform_select_first_c [0:LANES-1];
    logic [SELECT_W-1:0] lane_xform_select_first_q [0:LANES-1];
    logic [SELECT_W-1:0] lane_xform_select_first_second_q [0:LANES-1];
    logic [SECOND_SELECT_PART_W-1:0] lane_xform_select_part01_c [0:LANES-1];
    logic [SECOND_SELECT_PART_W-1:0] lane_xform_select_part23_c [0:LANES-1];
    logic [SECOND_SELECT_PART_W-1:0] lane_xform_select_part01_q [0:LANES-1];
    logic [SECOND_SELECT_PART_W-1:0] lane_xform_select_part23_q [0:LANES-1];
    logic [SELECT_W-1:0] lane_xform_select_c [0:LANES-1];
    logic [SELECT_W-1:0] lane_xform_select_q [0:LANES-1];
    logic [MAT_W-1:0] lane_xform_c [0:LANES-1];
    logic [MAT_W-1:0] lane_xform_q [0:LANES-1];
    logic [MAT_W-1:0] lane_xform_d0 [0:LANES-1];
    logic [MAT_W-1:0] lane_xform_d1 [0:LANES-1];
    logic [MAT_W-1:0] lane_xform_d2 [0:LANES-1];
    logic [MAT_W-1:0] lane_xform_d3 [0:LANES-1];
    logic [MAT_W-1:0] lane_xform_d4 [0:LANES-1];
    logic [MAT_W-1:0] lane_xform_d5 [0:LANES-1];
    logic [MAT_W-1:0] lane_xform_d6 [0:LANES-1];
    logic [MAT_W-1:0] lane_xform_d7 [0:LANES-1];
    logic [MAT_W-1:0] pair_xform_mid01_c [0:3];
    logic [MAT_W-1:0] pair_xform_mid23_c [0:3];
    logic [MAT_W-1:0] pair_xform_mid01_q [0:3];
    logic [MAT_W-1:0] pair_xform_mid23_q [0:3];
    logic [MAT_W-1:0] pair_xform_raw_c [0:3];
    logic [MAT_W-1:0] pair_xform_raw_q [0:3];
    logic [MET_W-1:0] pair_xform_offset_c [0:3];
    logic [MET_W-1:0] pair_xform_offset_q [0:3];
    logic [MAT_W-1:0] pair_xform_c [0:3];
    logic [MAT_W-1:0] pair_xform_q [0:3];
    logic [MAT_W-1:0] quad_xform_mid01_c [0:1];
    logic [MAT_W-1:0] quad_xform_mid23_c [0:1];
    logic [MAT_W-1:0] quad_xform_mid01_q [0:1];
    logic [MAT_W-1:0] quad_xform_mid23_q [0:1];
    logic [MAT_W-1:0] quad_xform_c [0:1];
    logic [MAT_W-1:0] quad_xform_q [0:1];
    logic [MAT_W-1:0] block_xform_mid01_c;
    logic [MAT_W-1:0] block_xform_mid23_c;
    logic [MAT_W-1:0] block_xform_mid01_q;
    logic [MAT_W-1:0] block_xform_mid23_q;
    logic [MAT_W-1:0] block_xform_c;
    logic [MAT_W-1:0] block_xform_q;
    logic [PM_W-1:0]  pm_init_flat;
    logic [PM_W-1:0]  pm_state_flat;
    logic [PM_W-1:0]  pm_next_c;
    (* max_fanout = 64 *) logic             valid_pre;
    (* max_fanout = 64 *) logic             valid_s0;
    (* max_fanout = 64 *) logic             valid_lane_select_s1;
    (* max_fanout = 64 *) logic             valid_lane_select_s2;
    (* max_fanout = 64 *) logic             valid_lane_xform;
    (* max_fanout = 64 *) logic             valid_pair_mid;
    (* max_fanout = 64 *) logic             valid_pair_raw;
    (* max_fanout = 64 *) logic             valid_s1;
    (* max_fanout = 64 *) logic             valid_s2;
    (* max_fanout = 64 *) logic             valid_s3;
    (* max_fanout = 64 *) logic             valid_s4;
    (* max_fanout = 64 *) logic             valid_block_mid;
    wire block_input_valid = QUAD_XFORM_PIPELINE_ACTIVE ? valid_s4 : valid_s3;
    wire output_stage_valid = BLOCK_XFORM_PIPELINE_ACTIVE ? valid_block_mid : block_input_valid;

    assign pm_init_flat = {{(PM_W-MET_W){1'b1}}, {MET_W{1'b0}}};

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

    function automatic logic [MAT_W-1:0] make_lane_xform(
        input logic signed [7:0] sample_z8,
        input logic [7:0] fb_idx,
        input logic signed [(4*32)-1:0] g0_flat,
        input logic signed [(4*32)-1:0] g1_flat,
        input logic signed [(4*32)-1:0] g2_flat
    );
        int ps;
        int cand;
        int pick;
        int best_idx;
        logic found;
        logic [ALPHABET-1:0] selected;
        logic [MAT_W-1:0] mat_r;
        logic signed [31:0] g0_prod [0:ALPHABET-1];
        logic signed [31:0] g1_prod [0:ALPHABET-1];
        logic signed [31:0] g2_prod [0:ALPHABET-1];
        logic signed [16:0] err_by_cand [0:ALPHABET-1];
        logic [16:0] err_abs_by_cand [0:ALPHABET-1];
        logic [16:0] best_abs;
        logic [MET_W-1:0] selected_metric;
        logic selected_by_src [0:STATES-1][0:ALPHABET-1];
        logic [MET_W-1:0] metric_by_src [0:STATES-1][0:ALPHABET-1];
        logic dest_has_incoming;
        logic rescue_found;
        int rescue_src;
        logic [MET_W-1:0] rescue_metric;
        logic signed [31:0] base_term_q8;
        logic signed [31:0] zhat_q8;
        logic signed [15:0] zhat;
        logic signed [16:0] err;
        logic signed [16:0] err_neg;
        (* use_dsp = "yes" *) logic signed [33:0] err2;
        logic [16:0] metric_l1_scaled;
        logic [33:0] metric_sq_scaled;
        begin
            mat_r = {MAT_W{1'b1}};
            for (ps = 0; ps < STATES; ps = ps + 1) begin
                for (cand = 0; cand < ALPHABET; cand = cand + 1) begin
                    selected_by_src[ps][cand] = 1'b0;
                    metric_by_src[ps][cand] = INF;
                end
            end

            for (cand = 0; cand < ALPHABET; cand = cand + 1) begin
                g0_prod[cand] = $signed(g0_flat[(cand*32) +: 32]);
                g1_prod[cand] = $signed(g1_flat[(cand*32) +: 32]);
                g2_prod[cand] = $signed(g2_flat[(cand*32) +: 32]);
            end

            for (ps = 0; ps < STATES; ps = ps + 1) begin
                base_term_q8 = g1_prod[ps] + g2_prod[fb_idx[(ps*2) +: 2]];

                for (cand = 0; cand < ALPHABET; cand = cand + 1) begin
                    zhat_q8 = g0_prod[cand] + base_term_q8;
                    zhat = zhat_q8 >>> Q_SHIFT;
                    err = $signed(sample_z8) - $signed(zhat);
                    err_neg = -err;
                    err_by_cand[cand] = err;
                    err_abs_by_cand[cand] = err[16] ? err_neg[16:0] : err[16:0];
                    if (USE_L1_BRANCH_METRIC) begin
                        metric_l1_scaled = (BRANCH_METRIC_SHIFT <= 0)
                            ? err_abs_by_cand[cand]
                            : (err_abs_by_cand[cand] >> BRANCH_METRIC_SHIFT);
                        if (|metric_l1_scaled[16:MET_W])
                            metric_by_src[ps][cand] = INF;
                        else
                            metric_by_src[ps][cand] = metric_l1_scaled[MET_W-1:0];
                    end else begin
                        err2 = err_by_cand[cand] * err_by_cand[cand];
                        metric_sq_scaled = (BRANCH_METRIC_SHIFT <= 0)
                            ? err2
                            : (err2 >> BRANCH_METRIC_SHIFT);
                        if (|metric_sq_scaled[33:MET_W])
                            metric_by_src[ps][cand] = INF;
                        else
                            metric_by_src[ps][cand] = metric_sq_scaled[MET_W-1:0];
                    end
                end

                selected = '0;
                for (pick = 0; pick < ACTIVE_BRANCH_SURVIVORS; pick = pick + 1) begin
                    best_abs = {17{1'b1}};
                    best_idx = 0;
                    found = 1'b0;
                    for (cand = 0; cand < ALPHABET; cand = cand + 1) begin
                        if (!selected[cand] && (err_abs_by_cand[cand] < best_abs)) begin
                            best_abs = err_abs_by_cand[cand];
                            best_idx = cand;
                            found = 1'b1;
                        end
                    end
                    if (found) begin
                        selected[best_idx] = 1'b1;
                        selected_metric = metric_by_src[ps][best_idx];
                        selected_by_src[ps][best_idx] = 1'b1;
                        mat_r[((best_idx*STATES + ps)*MET_W) +: MET_W] = selected_metric;
                    end
                end
            end

            if (USE_DEST_RESCUE) begin
                for (cand = 0; cand < ALPHABET; cand = cand + 1) begin
                    dest_has_incoming = 1'b0;
                    for (ps = 0; ps < STATES; ps = ps + 1) begin
                        if (selected_by_src[ps][cand] && (metric_by_src[ps][cand] != INF))
                            dest_has_incoming = 1'b1;
                    end

                    if (!dest_has_incoming) begin
                        rescue_found = 1'b0;
                        rescue_src = 0;
                        rescue_metric = INF;
                        for (ps = 0; ps < STATES; ps = ps + 1) begin
                            if (metric_by_src[ps][cand] < rescue_metric) begin
                                rescue_found = 1'b1;
                                rescue_src = ps;
                                rescue_metric = metric_by_src[ps][cand];
                            end
                        end
                        if (rescue_found)
                            mat_r[((cand*STATES + rescue_src)*MET_W) +: MET_W] = rescue_metric;
                    end
                end
            end

            make_lane_xform = mat_r;
        end
    endfunction

    function automatic logic [MET_W-1:0] pre_get_metric(
        input logic [PRE_W-1:0] pre,
        input int ps,
        input int cand
    );
        begin
            pre_get_metric = pre[(((ps*ALPHABET + cand)*PRE_ENTRY_W)) +: MET_W];
        end
    endfunction

    function automatic logic [16:0] pre_get_abs(
        input logic [PRE_W-1:0] pre,
        input int ps,
        input int cand
    );
        begin
            pre_get_abs = pre[(((ps*ALPHABET + cand)*PRE_ENTRY_W) + MET_W) +: 17];
        end
    endfunction

    function automatic logic [PRE_W-1:0] make_lane_metric_precompute(
        input logic signed [7:0] sample_z8,
        input logic [7:0] fb_idx,
        input logic signed [(4*32)-1:0] g0_flat,
        input logic signed [(4*32)-1:0] g1_flat,
        input logic signed [(4*32)-1:0] g2_flat
    );
        int ps;
        int cand;
        logic [PRE_W-1:0] pre_r;
        logic signed [31:0] g0_prod [0:ALPHABET-1];
        logic signed [31:0] g1_prod [0:ALPHABET-1];
        logic signed [31:0] g2_prod [0:ALPHABET-1];
        logic signed [31:0] base_term_q8;
        logic signed [31:0] zhat_q8;
        logic signed [15:0] zhat;
        logic signed [16:0] err;
        logic signed [16:0] err_neg;
        (* use_dsp = "yes" *) logic signed [33:0] err2;
        logic [16:0] err_abs;
        logic [16:0] metric_l1_scaled;
        logic [33:0] metric_sq_scaled;
        logic [MET_W-1:0] metric_sat;
        begin
            pre_r = '0;

            for (cand = 0; cand < ALPHABET; cand = cand + 1) begin
                g0_prod[cand] = $signed(g0_flat[(cand*32) +: 32]);
                g1_prod[cand] = $signed(g1_flat[(cand*32) +: 32]);
                g2_prod[cand] = $signed(g2_flat[(cand*32) +: 32]);
            end

            for (ps = 0; ps < STATES; ps = ps + 1) begin
                base_term_q8 = g1_prod[ps] + g2_prod[fb_idx[(ps*2) +: 2]];

                for (cand = 0; cand < ALPHABET; cand = cand + 1) begin
                    zhat_q8 = g0_prod[cand] + base_term_q8;
                    zhat = zhat_q8 >>> Q_SHIFT;
                    err = $signed(sample_z8) - $signed(zhat);
                    err_neg = -err;
                    err_abs = err[16] ? err_neg[16:0] : err[16:0];

                    if (USE_L1_BRANCH_METRIC) begin
                        metric_l1_scaled = (BRANCH_METRIC_SHIFT <= 0)
                            ? err_abs
                            : (err_abs >> BRANCH_METRIC_SHIFT);
                        metric_sat = |metric_l1_scaled[16:MET_W]
                            ? INF
                            : metric_l1_scaled[MET_W-1:0];
                    end else begin
                        err2 = err * err;
                        metric_sq_scaled = (BRANCH_METRIC_SHIFT <= 0)
                            ? err2
                            : (err2 >> BRANCH_METRIC_SHIFT);
                        metric_sat = |metric_sq_scaled[33:MET_W]
                            ? INF
                            : metric_sq_scaled[MET_W-1:0];
                    end

                    pre_r[(((ps*ALPHABET + cand)*PRE_ENTRY_W)) +: MET_W] = metric_sat;
                    pre_r[(((ps*ALPHABET + cand)*PRE_ENTRY_W) + MET_W) +: 17] = err_abs;
                end
            end

            make_lane_metric_precompute = pre_r;
        end
    endfunction

    function automatic logic [SELECT_W-1:0] make_lane_xform_select_from_precompute(
        input logic [PRE_W-1:0] pre
    );
        int ps;
        int cand;
        int pick;
        int best_idx;
        logic found;
        logic [ALPHABET-1:0] selected;
        logic [SELECT_W-1:0] select_r;
        logic [16:0] best_abs;
        logic [16:0] cand_abs;
        begin
            select_r = '0;
            for (ps = 0; ps < STATES; ps = ps + 1) begin
                selected = '0;
                for (pick = 0; pick < ACTIVE_BRANCH_SURVIVORS; pick = pick + 1) begin
                    best_abs = {17{1'b1}};
                    best_idx = 0;
                    found = 1'b0;
                    for (cand = 0; cand < ALPHABET; cand = cand + 1) begin
                        cand_abs = pre_get_abs(pre, ps, cand);
                        if (!selected[cand] && (cand_abs < best_abs)) begin
                            best_abs = cand_abs;
                            best_idx = cand;
                            found = 1'b1;
                        end
                    end
                    if (found) begin
                        selected[best_idx] = 1'b1;
                        select_r[(ps*ALPHABET) + best_idx] = 1'b1;
                    end
                end
            end

            make_lane_xform_select_from_precompute = select_r;
        end
    endfunction

    function automatic logic [SELECT_W-1:0] make_lane_xform_first_select_from_precompute(
        input logic [PRE_W-1:0] pre
    );
        int ps;
        int cand;
        int best_idx;
        logic found;
        logic [SELECT_W-1:0] select_r;
        logic [16:0] best_abs;
        logic [16:0] cand_abs;
        begin
            select_r = '0;
            for (ps = 0; ps < STATES; ps = ps + 1) begin
                best_abs = {17{1'b1}};
                best_idx = 0;
                found = 1'b0;
                for (cand = 0; cand < ALPHABET; cand = cand + 1) begin
                    cand_abs = pre_get_abs(pre, ps, cand);
                    if (cand_abs < best_abs) begin
                        best_abs = cand_abs;
                        best_idx = cand;
                        found = 1'b1;
                    end
                end
                if (found)
                    select_r[(ps*ALPHABET) + best_idx] = 1'b1;
            end

            make_lane_xform_first_select_from_precompute = select_r;
        end
    endfunction

    function automatic logic [SELECT_W-1:0] make_lane_xform_remaining_select_from_precompute(
        input logic [PRE_W-1:0] pre,
        input logic [SELECT_W-1:0] first_selected_flat
    );
        int ps;
        int cand;
        int pick;
        int best_idx;
        logic found;
        logic [ALPHABET-1:0] selected;
        logic [SELECT_W-1:0] select_r;
        logic [16:0] best_abs;
        logic [16:0] cand_abs;
        begin
            select_r = first_selected_flat;
            for (ps = 0; ps < STATES; ps = ps + 1) begin
                selected = first_selected_flat[(ps*ALPHABET) +: ALPHABET];
                for (pick = 1; pick < ACTIVE_BRANCH_SURVIVORS; pick = pick + 1) begin
                    best_abs = {17{1'b1}};
                    best_idx = 0;
                    found = 1'b0;
                    for (cand = 0; cand < ALPHABET; cand = cand + 1) begin
                        cand_abs = pre_get_abs(pre, ps, cand);
                        if (!selected[cand] && (cand_abs < best_abs)) begin
                            best_abs = cand_abs;
                            best_idx = cand;
                            found = 1'b1;
                        end
                    end
                    if (found) begin
                        selected[best_idx] = 1'b1;
                        select_r[(ps*ALPHABET) + best_idx] = 1'b1;
                    end
                end
            end

            make_lane_xform_remaining_select_from_precompute = select_r;
        end
    endfunction

    function automatic logic [SECOND_SELECT_PART_W-1:0] make_lane_xform_second_select_part01_from_precompute(
        input logic [PRE_W-1:0] pre,
        input logic [SELECT_W-1:0] first_selected_flat
    );
        int ps;
        int cand;
        int best_idx;
        logic found;
        logic [ALPHABET-1:0] selected;
        logic [SECOND_SELECT_PART_W-1:0] part_r;
        logic [16:0] best_abs;
        logic [16:0] cand_abs;
        begin
            part_r = '0;
            for (ps = 0; ps < STATES; ps = ps + 1) begin
                selected = first_selected_flat[(ps*ALPHABET) +: ALPHABET];
                best_abs = {17{1'b1}};
                best_idx = 0;
                found = 1'b0;
                for (cand = 0; cand < 2; cand = cand + 1) begin
                    cand_abs = pre_get_abs(pre, ps, cand);
                    if (!selected[cand] && (cand_abs < best_abs)) begin
                        best_abs = cand_abs;
                        best_idx = cand;
                        found = 1'b1;
                    end
                end
                part_r[(ps*SECOND_SELECT_PART_ENTRY_W) +: 17] = best_abs;
                part_r[(ps*SECOND_SELECT_PART_ENTRY_W + 17) +: 2] = best_idx[1:0];
                part_r[(ps*SECOND_SELECT_PART_ENTRY_W + 19)] = found;
            end

            make_lane_xform_second_select_part01_from_precompute = part_r;
        end
    endfunction

    function automatic logic [SECOND_SELECT_PART_W-1:0] make_lane_xform_second_select_part23_from_precompute(
        input logic [PRE_W-1:0] pre,
        input logic [SELECT_W-1:0] first_selected_flat
    );
        int ps;
        int cand;
        int best_idx;
        logic found;
        logic [ALPHABET-1:0] selected;
        logic [SECOND_SELECT_PART_W-1:0] part_r;
        logic [16:0] best_abs;
        logic [16:0] cand_abs;
        begin
            part_r = '0;
            for (ps = 0; ps < STATES; ps = ps + 1) begin
                selected = first_selected_flat[(ps*ALPHABET) +: ALPHABET];
                best_abs = {17{1'b1}};
                best_idx = 0;
                found = 1'b0;
                for (cand = 2; cand < ALPHABET; cand = cand + 1) begin
                    cand_abs = pre_get_abs(pre, ps, cand);
                    if (!selected[cand] && (cand_abs < best_abs)) begin
                        best_abs = cand_abs;
                        best_idx = cand;
                        found = 1'b1;
                    end
                end
                part_r[(ps*SECOND_SELECT_PART_ENTRY_W) +: 17] = best_abs;
                part_r[(ps*SECOND_SELECT_PART_ENTRY_W + 17) +: 2] = best_idx[1:0];
                part_r[(ps*SECOND_SELECT_PART_ENTRY_W + 19)] = found;
            end

            make_lane_xform_second_select_part23_from_precompute = part_r;
        end
    endfunction

    function automatic logic [SELECT_W-1:0] make_lane_xform_second_select_merge_from_parts(
        input logic [SELECT_W-1:0] first_selected_flat,
        input logic [SECOND_SELECT_PART_W-1:0] part01,
        input logic [SECOND_SELECT_PART_W-1:0] part23
    );
        int ps;
        int best_idx;
        logic [SELECT_W-1:0] select_r;
        logic [16:0] best01_abs;
        logic [16:0] best23_abs;
        logic [1:0] best01_idx;
        logic [1:0] best23_idx;
        logic found01;
        logic found23;
        begin
            select_r = first_selected_flat;
            for (ps = 0; ps < STATES; ps = ps + 1) begin
                best01_abs = part01[(ps*SECOND_SELECT_PART_ENTRY_W) +: 17];
                best23_abs = part23[(ps*SECOND_SELECT_PART_ENTRY_W) +: 17];
                best01_idx = part01[(ps*SECOND_SELECT_PART_ENTRY_W + 17) +: 2];
                best23_idx = part23[(ps*SECOND_SELECT_PART_ENTRY_W + 17) +: 2];
                found01 = part01[(ps*SECOND_SELECT_PART_ENTRY_W + 19)];
                found23 = part23[(ps*SECOND_SELECT_PART_ENTRY_W + 19)];

                if (found01 && (!found23 || (best01_abs <= best23_abs))) begin
                    best_idx = best01_idx;
                    select_r[(ps*ALPHABET) + best_idx] = 1'b1;
                end else if (found23) begin
                    best_idx = best23_idx;
                    select_r[(ps*ALPHABET) + best_idx] = 1'b1;
                end
            end

            make_lane_xform_second_select_merge_from_parts = select_r;
        end
    endfunction

    function automatic logic [MAT_W-1:0] make_lane_xform_from_selected_precompute(
        input logic [PRE_W-1:0] pre,
        input logic [SELECT_W-1:0] selected_by_src_flat
    );
        int ps;
        int cand;
        logic [MAT_W-1:0] mat_r;
        logic [MET_W-1:0] cand_metric;
        logic dest_has_incoming;
        logic rescue_found;
        int rescue_src;
        logic [MET_W-1:0] rescue_metric;
        begin
            mat_r = {MAT_W{1'b1}};
            for (ps = 0; ps < STATES; ps = ps + 1) begin
                for (cand = 0; cand < ALPHABET; cand = cand + 1) begin
                    if (selected_by_src_flat[(ps*ALPHABET) + cand])
                        mat_r[((cand*STATES + ps)*MET_W) +: MET_W] = pre_get_metric(pre, ps, cand);
                end
            end

            if (USE_DEST_RESCUE) begin
                for (cand = 0; cand < ALPHABET; cand = cand + 1) begin
                    dest_has_incoming = 1'b0;
                    for (ps = 0; ps < STATES; ps = ps + 1) begin
                        if (selected_by_src_flat[(ps*ALPHABET) + cand] &&
                            (pre_get_metric(pre, ps, cand) != INF)) begin
                            dest_has_incoming = 1'b1;
                        end
                    end

                    if (!dest_has_incoming) begin
                        rescue_found = 1'b0;
                        rescue_src = 0;
                        rescue_metric = INF;
                        for (ps = 0; ps < STATES; ps = ps + 1) begin
                            cand_metric = pre_get_metric(pre, ps, cand);
                            if (cand_metric < rescue_metric) begin
                                rescue_found = 1'b1;
                                rescue_src = ps;
                                rescue_metric = cand_metric;
                            end
                        end
                        if (rescue_found)
                            mat_r[((cand*STATES + rescue_src)*MET_W) +: MET_W] = rescue_metric;
                    end
                end
            end

            make_lane_xform_from_selected_precompute = mat_r;
        end
    endfunction

    function automatic logic [MAT_W-1:0] make_lane_xform_from_precompute(
        input logic [PRE_W-1:0] pre
    );
        begin
            make_lane_xform_from_precompute =
                make_lane_xform_from_selected_precompute(
                    pre,
                    make_lane_xform_select_from_precompute(pre)
                );
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
        logic [MET_W-1:0] early_metric;
        logic [MET_W-1:0] late_metric;
        begin
            mat_r = {MAT_W{1'b1}};
            for (row = 0; row < STATES; row = row + 1) begin
                for (col = 0; col < STATES; col = col + 1) begin
                    best = INF;
                    for (mid = 0; mid < STATES; mid = mid + 1) begin
                        early_metric = mat_get(earlier_xform, mid, col);
                        late_metric = mat_get(later_xform, row, mid);
                        if ((early_metric != INF) && (late_metric != INF)) begin
                            cand_metric = sat_add(early_metric, late_metric);
                            if (cand_metric < best)
                                best = cand_metric;
                        end
                    end
                    mat_r[((row*STATES + col)*MET_W) +: MET_W] = best;
                end
            end
            compose_xform = mat_r;
        end
    endfunction

    function automatic logic [MAT_W-1:0] compose_xform_mid01(
        input logic [MAT_W-1:0] later_xform,
        input logic [MAT_W-1:0] earlier_xform
    );
        int row;
        int col;
        int mid;
        logic [MAT_W-1:0] mat_r;
        logic [MET_W-1:0] best;
        logic [MET_W-1:0] cand_metric;
        logic [MET_W-1:0] early_metric;
        logic [MET_W-1:0] late_metric;
        begin
            mat_r = {MAT_W{1'b1}};
            for (row = 0; row < STATES; row = row + 1) begin
                for (col = 0; col < STATES; col = col + 1) begin
                    best = INF;
                    for (mid = 0; mid < 2; mid = mid + 1) begin
                        early_metric = mat_get(earlier_xform, mid, col);
                        late_metric = mat_get(later_xform, row, mid);
                        if ((early_metric != INF) && (late_metric != INF)) begin
                            cand_metric = sat_add(early_metric, late_metric);
                            if (cand_metric < best)
                                best = cand_metric;
                        end
                    end
                    mat_r[((row*STATES + col)*MET_W) +: MET_W] = best;
                end
            end
            compose_xform_mid01 = mat_r;
        end
    endfunction

    function automatic logic [MAT_W-1:0] compose_xform_mid23(
        input logic [MAT_W-1:0] later_xform,
        input logic [MAT_W-1:0] earlier_xform
    );
        int row;
        int col;
        int mid;
        logic [MAT_W-1:0] mat_r;
        logic [MET_W-1:0] best;
        logic [MET_W-1:0] cand_metric;
        logic [MET_W-1:0] early_metric;
        logic [MET_W-1:0] late_metric;
        begin
            mat_r = {MAT_W{1'b1}};
            for (row = 0; row < STATES; row = row + 1) begin
                for (col = 0; col < STATES; col = col + 1) begin
                    best = INF;
                    for (mid = 2; mid < STATES; mid = mid + 1) begin
                        early_metric = mat_get(earlier_xform, mid, col);
                        late_metric = mat_get(later_xform, row, mid);
                        if ((early_metric != INF) && (late_metric != INF)) begin
                            cand_metric = sat_add(early_metric, late_metric);
                            if (cand_metric < best)
                                best = cand_metric;
                        end
                    end
                    mat_r[((row*STATES + col)*MET_W) +: MET_W] = best;
                end
            end
            compose_xform_mid23 = mat_r;
        end
    endfunction

    function automatic logic [MAT_W-1:0] compose_xform_merge_partials(
        input logic [MAT_W-1:0] part_a,
        input logic [MAT_W-1:0] part_b
    );
        int row;
        int col;
        logic [MAT_W-1:0] mat_r;
        logic [MET_W-1:0] a_metric;
        logic [MET_W-1:0] b_metric;
        begin
            mat_r = {MAT_W{1'b1}};
            for (row = 0; row < STATES; row = row + 1) begin
                for (col = 0; col < STATES; col = col + 1) begin
                    a_metric = mat_get(part_a, row, col);
                    b_metric = mat_get(part_b, row, col);
                    mat_r[((row*STATES + col)*MET_W) +: MET_W] =
                        (a_metric < b_metric) ? a_metric : b_metric;
                end
            end
            compose_xform_merge_partials = mat_r;
        end
    endfunction

    function automatic logic [MAT_W-1:0] normalize_xform(
        input logic [MAT_W-1:0] mat
    );
        int row;
        int col;
        logic [MAT_W-1:0] mat_r;
        logic [MET_W-1:0] mat_min;
        logic [MET_W-1:0] entry_metric;
        begin
            mat_r = mat;
            mat_min = INF;
            for (row = 0; row < STATES; row = row + 1) begin
                for (col = 0; col < STATES; col = col + 1) begin
                    entry_metric = mat_get(mat, row, col);
                    if ((entry_metric != INF) && ((mat_min == INF) || (entry_metric < mat_min)))
                        mat_min = entry_metric;
                end
            end

            if (mat_min == INF)
                mat_min = '0;
            for (row = 0; row < STATES; row = row + 1) begin
                for (col = 0; col < STATES; col = col + 1) begin
                    entry_metric = mat_get(mat_r, row, col);
                    if (entry_metric != INF)
                        mat_r[((row*STATES + col)*MET_W) +: MET_W] = entry_metric - mat_min;
                end
            end
            normalize_xform = mat_r;
        end
    endfunction

    function automatic logic [MET_W-1:0] xform_min(
        input logic [MAT_W-1:0] mat
    );
        int row;
        int col;
        logic [MET_W-1:0] mat_min;
        logic [MET_W-1:0] entry_metric;
        begin
            mat_min = INF;
            for (row = 0; row < STATES; row = row + 1) begin
                for (col = 0; col < STATES; col = col + 1) begin
                    entry_metric = mat_get(mat, row, col);
                    if ((entry_metric != INF) && ((mat_min == INF) || (entry_metric < mat_min)))
                        mat_min = entry_metric;
                end
            end
            if (mat_min == INF)
                mat_min = '0;
            xform_min = mat_min;
        end
    endfunction

    function automatic logic [MAT_W-1:0] compose_xform_with_offsets(
        input logic [MAT_W-1:0] later_xform,
        input logic [MAT_W-1:0] earlier_xform,
        input logic [MET_W-1:0] later_offset,
        input logic [MET_W-1:0] earlier_offset
    );
        int row;
        int col;
        int mid;
        logic [MAT_W-1:0] mat_r;
        logic [MET_W:0] best_ext;
        logic [MET_W:0] cand_ext;
        logic [MET_W:0] offset_sum_ext;
        logic [MET_W:0] adj_ext;
        logic [MET_W-1:0] early_metric;
        logic [MET_W-1:0] late_metric;
        begin
            mat_r = {MAT_W{1'b1}};
            offset_sum_ext = {1'b0, later_offset} + {1'b0, earlier_offset};
            for (row = 0; row < STATES; row = row + 1) begin
                for (col = 0; col < STATES; col = col + 1) begin
                    best_ext = {1'b1, {MET_W{1'b1}}};
                    for (mid = 0; mid < STATES; mid = mid + 1) begin
                        early_metric = mat_get(earlier_xform, mid, col);
                        late_metric = mat_get(later_xform, row, mid);
                        if ((early_metric != INF) && (late_metric != INF)) begin
                            cand_ext = {1'b0, early_metric} + {1'b0, late_metric};
                            if (cand_ext < best_ext)
                                best_ext = cand_ext;
                        end
                    end
                    if (best_ext != {1'b1, {MET_W{1'b1}}}) begin
                        adj_ext = (best_ext > offset_sum_ext) ? (best_ext - offset_sum_ext) : '0;
                        mat_r[((row*STATES + col)*MET_W) +: MET_W] =
                            adj_ext[MET_W] ? INF : adj_ext[MET_W-1:0];
                    end
                end
            end
            compose_xform_with_offsets = mat_r;
        end
    endfunction

    function automatic logic [PM_W-1:0] apply_xform(
        input logic [MAT_W-1:0] mat,
        input logic [PM_W-1:0] pm_in
    );
        int row;
        int col;
        logic [PM_W-1:0] pm_r;
        logic [MET_W-1:0] best;
        logic [MET_W-1:0] cand_metric;
        logic [MET_W-1:0] pm_metric;
        logic [MET_W-1:0] edge_metric;
        logic [MET_W-1:0] pm_min;
        begin
            pm_r = {PM_W{1'b1}};
            pm_min = INF;
            for (row = 0; row < STATES; row = row + 1) begin
                best = INF;
                for (col = 0; col < STATES; col = col + 1) begin
                    pm_metric = pm_get(pm_in, col);
                    edge_metric = mat_get(mat, row, col);
                    if ((pm_metric != INF) && (edge_metric != INF)) begin
                        cand_metric = sat_add(pm_metric, edge_metric);
                        if (cand_metric < best)
                            best = cand_metric;
                    end
                end
                pm_r[(row*MET_W) +: MET_W] = best;
                if ((best != INF) && (best < pm_min))
                    pm_min = best;
            end
            if (pm_min == INF)
                pm_min = '0;
            for (row = 0; row < STATES; row = row + 1) begin
                if (pm_r[(row*MET_W) +: MET_W] != INF)
                    pm_r[(row*MET_W) +: MET_W] = pm_r[(row*MET_W) +: MET_W] - pm_min;
            end
            apply_xform = pm_r;
        end
    endfunction

    always_comb begin
        int lane;
        for (lane = 0; lane < LANES; lane = lane + 1) begin
            lane_metric_pre_c[lane] = make_lane_metric_precompute(
                $signed(din8_metric_flat[(lane*8) +: 8]),
                fb_idx_metric_flat[(lane*8) +: 8],
                g0_metric_flat,
                g1_metric_flat,
                g2_metric_flat
            );
            lane_xform_select_first_c[lane] =
                make_lane_xform_first_select_from_precompute(lane_metric_pre_q[lane]);
            lane_xform_select_part01_c[lane] = '0;
            lane_xform_select_part23_c[lane] = '0;
            if (ENABLE_LANE_XFORM_PIPELINE_SPLIT && ENABLE_LANE_SELECT_PIPELINE_SPLIT) begin
                if (LANE_SELECT_SECOND_PIPELINE_ACTIVE) begin
                    lane_xform_select_part01_c[lane] =
                        make_lane_xform_second_select_part01_from_precompute(
                            lane_metric_pre_select_first_q[lane],
                            lane_xform_select_first_q[lane]
                        );
                    lane_xform_select_part23_c[lane] =
                        make_lane_xform_second_select_part23_from_precompute(
                            lane_metric_pre_select_first_q[lane],
                            lane_xform_select_first_q[lane]
                        );
                    lane_xform_select_c[lane] =
                        make_lane_xform_second_select_merge_from_parts(
                            lane_xform_select_first_second_q[lane],
                            lane_xform_select_part01_q[lane],
                            lane_xform_select_part23_q[lane]
                        );
                end else begin
                    lane_xform_select_c[lane] = make_lane_xform_remaining_select_from_precompute(
                        lane_metric_pre_select_first_q[lane],
                        lane_xform_select_first_q[lane]
                    );
                end
            end else begin
                lane_xform_select_c[lane] =
                    make_lane_xform_select_from_precompute(lane_metric_pre_q[lane]);
            end
            if (ENABLE_LANE_XFORM_PIPELINE_SPLIT) begin
                lane_xform_c[lane] = make_lane_xform_from_selected_precompute(
                    lane_metric_pre_select_q[lane],
                    lane_xform_select_q[lane]
                );
            end else begin
                lane_xform_c[lane] = make_lane_xform_from_precompute(lane_metric_pre_q[lane]);
            end
        end

        for (lane = 0; lane < 4; lane = lane + 1) begin
            pair_xform_mid01_c[lane] = '0;
            pair_xform_mid23_c[lane] = '0;
        end
        if (PAIR_XFORM_PIPELINE_ACTIVE) begin
            pair_xform_mid01_c[0] = compose_xform_mid01(lane_xform_q[1], lane_xform_q[0]);
            pair_xform_mid23_c[0] = compose_xform_mid23(lane_xform_q[1], lane_xform_q[0]);
            pair_xform_mid01_c[1] = compose_xform_mid01(lane_xform_q[3], lane_xform_q[2]);
            pair_xform_mid23_c[1] = compose_xform_mid23(lane_xform_q[3], lane_xform_q[2]);
            pair_xform_mid01_c[2] = compose_xform_mid01(lane_xform_q[5], lane_xform_q[4]);
            pair_xform_mid23_c[2] = compose_xform_mid23(lane_xform_q[5], lane_xform_q[4]);
            pair_xform_mid01_c[3] = compose_xform_mid01(lane_xform_q[7], lane_xform_q[6]);
            pair_xform_mid23_c[3] = compose_xform_mid23(lane_xform_q[7], lane_xform_q[6]);
            pair_xform_raw_c[0] = compose_xform_merge_partials(pair_xform_mid01_q[0], pair_xform_mid23_q[0]);
            pair_xform_raw_c[1] = compose_xform_merge_partials(pair_xform_mid01_q[1], pair_xform_mid23_q[1]);
            pair_xform_raw_c[2] = compose_xform_merge_partials(pair_xform_mid01_q[2], pair_xform_mid23_q[2]);
            pair_xform_raw_c[3] = compose_xform_merge_partials(pair_xform_mid01_q[3], pair_xform_mid23_q[3]);
        end else begin
            pair_xform_raw_c[0] = compose_xform(lane_xform_q[1], lane_xform_q[0]);
            pair_xform_raw_c[1] = compose_xform(lane_xform_q[3], lane_xform_q[2]);
            pair_xform_raw_c[2] = compose_xform(lane_xform_q[5], lane_xform_q[4]);
            pair_xform_raw_c[3] = compose_xform(lane_xform_q[7], lane_xform_q[6]);
        end
        if (ENABLE_PAIR_NORMALIZE) begin
            pair_xform_c[0] = normalize_xform(pair_xform_raw_q[0]);
            pair_xform_c[1] = normalize_xform(pair_xform_raw_q[1]);
            pair_xform_c[2] = normalize_xform(pair_xform_raw_q[2]);
            pair_xform_c[3] = normalize_xform(pair_xform_raw_q[3]);
            pair_xform_offset_c[0] = '0;
            pair_xform_offset_c[1] = '0;
            pair_xform_offset_c[2] = '0;
            pair_xform_offset_c[3] = '0;
        end else begin
            pair_xform_c[0] = pair_xform_raw_q[0];
            pair_xform_c[1] = pair_xform_raw_q[1];
            pair_xform_c[2] = pair_xform_raw_q[2];
            pair_xform_c[3] = pair_xform_raw_q[3];
            if (ENABLE_PAIR_OFFSET_COMPENSATION) begin
                pair_xform_offset_c[0] = xform_min(pair_xform_raw_q[0]);
                pair_xform_offset_c[1] = xform_min(pair_xform_raw_q[1]);
                pair_xform_offset_c[2] = xform_min(pair_xform_raw_q[2]);
                pair_xform_offset_c[3] = xform_min(pair_xform_raw_q[3]);
            end else begin
                pair_xform_offset_c[0] = '0;
                pair_xform_offset_c[1] = '0;
                pair_xform_offset_c[2] = '0;
                pair_xform_offset_c[3] = '0;
            end
        end
        for (lane = 0; lane < 2; lane = lane + 1) begin
            quad_xform_mid01_c[lane] = '0;
            quad_xform_mid23_c[lane] = '0;
        end
        if (!ENABLE_PAIR_NORMALIZE && ENABLE_PAIR_OFFSET_COMPENSATION) begin
            quad_xform_c[0] = compose_xform_with_offsets(
                pair_xform_q[1], pair_xform_q[0],
                pair_xform_offset_q[1], pair_xform_offset_q[0]
            );
            quad_xform_c[1] = compose_xform_with_offsets(
                pair_xform_q[3], pair_xform_q[2],
                pair_xform_offset_q[3], pair_xform_offset_q[2]
            );
        end else if (QUAD_XFORM_PIPELINE_ACTIVE) begin
            quad_xform_mid01_c[0] = compose_xform_mid01(pair_xform_q[1], pair_xform_q[0]);
            quad_xform_mid23_c[0] = compose_xform_mid23(pair_xform_q[1], pair_xform_q[0]);
            quad_xform_mid01_c[1] = compose_xform_mid01(pair_xform_q[3], pair_xform_q[2]);
            quad_xform_mid23_c[1] = compose_xform_mid23(pair_xform_q[3], pair_xform_q[2]);
            quad_xform_c[0] = compose_xform_merge_partials(quad_xform_mid01_q[0], quad_xform_mid23_q[0]);
            quad_xform_c[1] = compose_xform_merge_partials(quad_xform_mid01_q[1], quad_xform_mid23_q[1]);
        end else begin
            quad_xform_c[0] = compose_xform(pair_xform_q[1], pair_xform_q[0]);
            quad_xform_c[1] = compose_xform(pair_xform_q[3], pair_xform_q[2]);
        end
        block_xform_mid01_c = '0;
        block_xform_mid23_c = '0;
        if (BLOCK_XFORM_PIPELINE_ACTIVE) begin
            block_xform_mid01_c = compose_xform_mid01(quad_xform_q[1], quad_xform_q[0]);
            block_xform_mid23_c = compose_xform_mid23(quad_xform_q[1], quad_xform_q[0]);
            block_xform_c = compose_xform_merge_partials(block_xform_mid01_q, block_xform_mid23_q);
        end else begin
            block_xform_c = compose_xform(quad_xform_q[1], quad_xform_q[0]);
        end
        if (ENABLE_PM_STATE_UPDATE)
            pm_next_c = apply_xform(block_xform_q, pm_state_flat);
        else
            pm_next_c = pm_init_flat;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        int i;
        if (!rst_n) begin
            input_stage_valid_q <= 1'b0;
            din8_flat_q <= '0;
            fb_idx_lane_flat_q <= {8{{2'd3, 2'd2, 2'd1, 2'd0}}};
            g0_prod_flat_q <= '0;
            g1_prod_flat_q <= '0;
            g2_prod_flat_q <= '0;
            valid_pre <= 1'b0;
            valid_s0 <= 1'b0;
            valid_lane_select_s1 <= 1'b0;
            valid_lane_select_s2 <= 1'b0;
            valid_lane_xform <= 1'b0;
            valid_pair_mid <= 1'b0;
            valid_pair_raw <= 1'b0;
            valid_s1 <= 1'b0;
            valid_s2 <= 1'b0;
            valid_s3 <= 1'b0;
            valid_s4 <= 1'b0;
            valid_block_mid <= 1'b0;
            out_valid <= 1'b0;
            block_xform_mid01_q <= '0;
            block_xform_mid23_q <= '0;
            block_xform_q <= '0;
            block_xform_flat <= '0;
            lane_xform_flat <= '0;
            pm_state_flat <= pm_init_flat;
            pm_out_flat <= pm_init_flat;
            for (i = 0; i < LANES; i = i + 1) begin
                lane_metric_pre_q[i] <= '0;
                lane_metric_pre_select_first_q[i] <= '0;
                lane_metric_pre_select_second_q[i] <= '0;
                lane_metric_pre_select_q[i] <= '0;
                lane_xform_select_first_q[i] <= '0;
                lane_xform_select_first_second_q[i] <= '0;
                lane_xform_select_part01_q[i] <= '0;
                lane_xform_select_part23_q[i] <= '0;
                lane_xform_select_q[i] <= '0;
                lane_xform_q[i] <= '0;
                lane_xform_d0[i] <= '0;
                lane_xform_d1[i] <= '0;
                lane_xform_d2[i] <= '0;
                lane_xform_d3[i] <= '0;
                lane_xform_d4[i] <= '0;
                lane_xform_d5[i] <= '0;
                lane_xform_d6[i] <= '0;
                lane_xform_d7[i] <= '0;
            end
            for (i = 0; i < 4; i = i + 1) begin
                pair_xform_mid01_q[i] <= '0;
                pair_xform_mid23_q[i] <= '0;
                pair_xform_raw_q[i] <= '0;
                pair_xform_offset_q[i] <= '0;
                pair_xform_q[i] <= '0;
            end
            for (i = 0; i < 2; i = i + 1)
                quad_xform_q[i] <= '0;
            for (i = 0; i < 2; i = i + 1) begin
                quad_xform_mid01_q[i] <= '0;
                quad_xform_mid23_q[i] <= '0;
            end
        end else begin
            input_stage_valid_q <= in_valid;
            din8_flat_q <= din8_flat;
            fb_idx_lane_flat_q <= fb_idx_lane_flat;
            g0_prod_flat_q <= g0_prod_flat;
            g1_prod_flat_q <= g1_prod_flat;
            g2_prod_flat_q <= g2_prod_flat;
            valid_pre <= INPUT_PIPELINE_ACTIVE ? input_stage_valid_q : in_valid;
            valid_s0 <= valid_pre;
            valid_lane_select_s1 <= valid_s0;
            valid_lane_select_s2 <= valid_lane_select_s1;
            valid_lane_xform <= LANE_SELECT_SECOND_PIPELINE_ACTIVE ?
                                valid_lane_select_s2 :
                                ((ENABLE_LANE_XFORM_PIPELINE_SPLIT && ENABLE_LANE_SELECT_PIPELINE_SPLIT) ?
                                 valid_lane_select_s1 :
                                 (ENABLE_LANE_XFORM_PIPELINE_SPLIT ? valid_s0 : valid_pre));
            valid_pair_mid <= valid_lane_xform;
            valid_pair_raw <= PAIR_XFORM_PIPELINE_ACTIVE ? valid_pair_mid : valid_lane_xform;
            valid_s1 <= valid_pair_raw;
            valid_s2 <= valid_s1;
            valid_s3 <= valid_s2;
            valid_s4 <= valid_s3;
            valid_block_mid <= block_input_valid;
            out_valid <= output_stage_valid;

            for (i = 0; i < LANES; i = i + 1) begin
                lane_metric_pre_q[i] <= lane_metric_pre_c[i];
                if (ENABLE_LANE_XFORM_PIPELINE_SPLIT) begin
                    if (ENABLE_LANE_SELECT_PIPELINE_SPLIT) begin
                        lane_metric_pre_select_first_q[i] <= lane_metric_pre_q[i];
                        lane_xform_select_first_q[i] <= lane_xform_select_first_c[i];
                        if (LANE_SELECT_SECOND_PIPELINE_ACTIVE) begin
                            lane_metric_pre_select_second_q[i] <= lane_metric_pre_select_first_q[i];
                            lane_xform_select_first_second_q[i] <= lane_xform_select_first_q[i];
                            lane_xform_select_part01_q[i] <= lane_xform_select_part01_c[i];
                            lane_xform_select_part23_q[i] <= lane_xform_select_part23_c[i];
                            lane_metric_pre_select_q[i] <= lane_metric_pre_select_second_q[i];
                        end else begin
                            lane_metric_pre_select_second_q[i] <= '0;
                            lane_xform_select_first_second_q[i] <= '0;
                            lane_xform_select_part01_q[i] <= '0;
                            lane_xform_select_part23_q[i] <= '0;
                            lane_metric_pre_select_q[i] <= lane_metric_pre_select_first_q[i];
                        end
                        lane_xform_select_q[i] <= lane_xform_select_c[i];
                    end else begin
                        lane_metric_pre_select_first_q[i] <= '0;
                        lane_metric_pre_select_second_q[i] <= '0;
                        lane_xform_select_first_q[i] <= '0;
                        lane_xform_select_first_second_q[i] <= '0;
                        lane_xform_select_part01_q[i] <= '0;
                        lane_xform_select_part23_q[i] <= '0;
                        lane_metric_pre_select_q[i] <= lane_metric_pre_q[i];
                        lane_xform_select_q[i] <= lane_xform_select_c[i];
                    end
                end else begin
                    lane_metric_pre_select_first_q[i] <= '0;
                    lane_metric_pre_select_second_q[i] <= '0;
                    lane_metric_pre_select_q[i] <= '0;
                    lane_xform_select_first_q[i] <= '0;
                    lane_xform_select_first_second_q[i] <= '0;
                    lane_xform_select_part01_q[i] <= '0;
                    lane_xform_select_part23_q[i] <= '0;
                    lane_xform_select_q[i] <= '0;
                end
                lane_xform_q[i] <= lane_xform_c[i];
                lane_xform_d0[i] <= lane_xform_c[i];
            end

            for (i = 0; i < 4; i = i + 1) begin
                pair_xform_mid01_q[i] <= pair_xform_mid01_c[i];
                pair_xform_mid23_q[i] <= pair_xform_mid23_c[i];
                pair_xform_raw_q[i] <= pair_xform_raw_c[i];
            end
            for (i = 0; i < 4; i = i + 1) begin
                pair_xform_offset_q[i] <= pair_xform_offset_c[i];
                pair_xform_q[i] <= pair_xform_c[i];
            end
            for (i = 0; i < LANES; i = i + 1)
                lane_xform_d1[i] <= lane_xform_d0[i];

            for (i = 0; i < 2; i = i + 1)
                quad_xform_mid01_q[i] <= quad_xform_mid01_c[i];
            for (i = 0; i < 2; i = i + 1)
                quad_xform_mid23_q[i] <= quad_xform_mid23_c[i];
            for (i = 0; i < 2; i = i + 1)
                quad_xform_q[i] <= quad_xform_c[i];
            for (i = 0; i < LANES; i = i + 1)
                lane_xform_d2[i] <= lane_xform_d1[i];

            block_xform_mid01_q <= block_xform_mid01_c;
            block_xform_mid23_q <= block_xform_mid23_c;
            block_xform_q <= block_xform_c;
            for (i = 0; i < LANES; i = i + 1)
                lane_xform_d3[i] <= lane_xform_d2[i];
            for (i = 0; i < LANES; i = i + 1)
                lane_xform_d4[i] <= lane_xform_d3[i];
            for (i = 0; i < LANES; i = i + 1)
                lane_xform_d5[i] <= lane_xform_d4[i];
            for (i = 0; i < LANES; i = i + 1)
                lane_xform_d6[i] <= lane_xform_d5[i];
            for (i = 0; i < LANES; i = i + 1)
                lane_xform_d7[i] <= lane_xform_d6[i];

            if (output_stage_valid) begin
                block_xform_flat <= block_xform_q;
                if (ENABLE_PM_STATE_UPDATE) begin
                    pm_state_flat <= pm_next_c;
                    pm_out_flat <= pm_next_c;
                end else begin
                    pm_out_flat <= pm_init_flat;
                end
            end
            for (i = 0; i < LANES; i = i + 1) begin
                if (PAIR_XFORM_PIPELINE_ACTIVE) begin
                    if (QUAD_XFORM_PIPELINE_ACTIVE)
                        lane_xform_flat[(i*MAT_W) +: MAT_W] <= BLOCK_XFORM_PIPELINE_ACTIVE ? lane_xform_d7[i] : lane_xform_d6[i];
                    else
                        lane_xform_flat[(i*MAT_W) +: MAT_W] <= BLOCK_XFORM_PIPELINE_ACTIVE ? lane_xform_d6[i] : lane_xform_d5[i];
                end else begin
                    if (QUAD_XFORM_PIPELINE_ACTIVE)
                        lane_xform_flat[(i*MAT_W) +: MAT_W] <= BLOCK_XFORM_PIPELINE_ACTIVE ? lane_xform_d6[i] : lane_xform_d5[i];
                    else
                        lane_xform_flat[(i*MAT_W) +: MAT_W] <= BLOCK_XFORM_PIPELINE_ACTIVE ? lane_xform_d5[i] : lane_xform_d4[i];
                end
            end
        end
    end
endmodule
