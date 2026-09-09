`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: Dual-Survivor Segmented Branch-Metric Matrix MLSD
// Module Name: codex_pam4_rs4_apply_xform_rowpipe_ooc
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Applies a 4x4 branch-metric transform row pipeline to path metrics for RS4 MLSD.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module codex_pam4_rs4_apply_xform_rowpipe_ooc #(
    parameter int MET_W = 10,
    parameter bit ENABLE_OUTPUT_PIPELINE_SPLIT = 1'b0
) (
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  in_valid,
    input  logic [(16*MET_W)-1:0] lane_mat,
    input  logic [(4*MET_W)-1:0]  pm_in,
    output logic                  out_valid,
    output logic [(4*MET_W)-1:0]  pm_next,
    output logic [(4*2)-1:0]      pred_cols,
    output logic [1:0]            best_idx
);
    localparam int STATES = 4;
    localparam int MAT_W = STATES * STATES * MET_W;
    localparam int PM_W = STATES * MET_W;
    localparam logic [MET_W-1:0] INF = {MET_W{1'b1}};

    logic [MET_W-1:0] row_best_w [0:STATES-1];
    logic [MET_W-1:0] row_best_s1_q [0:STATES-1];
    logic [MET_W-1:0] row_best_out [0:STATES-1];
    logic [1:0] row_pred_w [0:STATES-1];
    logic [1:0] row_pred_s1_q [0:STATES-1];
    logic [1:0] row_pred_out [0:STATES-1];
    logic valid_s1_q;
    logic valid_s2_q;

    logic [PM_W-1:0] pm_next_c;
    logic [(STATES*2)-1:0] pred_cols_c;
    logic [1:0] best_idx_c;

    function automatic logic [MET_W-1:0] pm_get(
        input logic [PM_W-1:0] pm,
        input int idx
    );
        begin
            pm_get = pm[(idx*MET_W) +: MET_W];
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

    genvar row_g;
    generate
        for (row_g = 0; row_g < STATES; row_g = row_g + 1) begin : g_row
            (* keep_hierarchy = "yes" *)
            codex_pam4_rs4_row_min_ooc #(
                .MET_W(MET_W)
            ) u_row_min (
                .pm0(pm_get(pm_in, 0)),
                .pm1(pm_get(pm_in, 1)),
                .pm2(pm_get(pm_in, 2)),
                .pm3(pm_get(pm_in, 3)),
                .m0(mat_get(lane_mat, row_g, 0)),
                .m1(mat_get(lane_mat, row_g, 1)),
                .m2(mat_get(lane_mat, row_g, 2)),
                .m3(mat_get(lane_mat, row_g, 3)),
                .row_best(row_best_w[row_g]),
                .row_pred(row_pred_w[row_g])
            );
        end
    endgenerate

    always_comb begin
        int st;
        logic [MET_W-1:0] pm_min;

        for (st = 0; st < STATES; st = st + 1) begin
            if (ENABLE_OUTPUT_PIPELINE_SPLIT) begin
                row_best_out[st] = row_best_s1_q[st];
                row_pred_out[st] = row_pred_s1_q[st];
            end else begin
                row_best_out[st] = row_best_w[st];
                row_pred_out[st] = row_pred_w[st];
            end
        end

        pm_min = row_best_out[0];
        best_idx_c = 2'd0;
        for (st = 1; st < STATES; st = st + 1) begin
            if (row_best_out[st] < pm_min) begin
                pm_min = row_best_out[st];
                best_idx_c = st[1:0];
            end
        end

        pm_next_c = {PM_W{1'b1}};
        for (st = 0; st < STATES; st = st + 1) begin
            if ((pm_min != INF) && (row_best_out[st] != INF))
                pm_next_c[(st*MET_W) +: MET_W] = row_best_out[st] - pm_min;
        end

        pred_cols_c = '0;
        for (st = 0; st < STATES; st = st + 1)
            pred_cols_c[(st*2) +: 2] = row_pred_out[st];
    end

    always_ff @(posedge clk or negedge rst_n) begin
        int st;
        if (!rst_n) begin
            valid_s1_q <= 1'b0;
            valid_s2_q <= 1'b0;
            out_valid <= 1'b0;
            for (st = 0; st < STATES; st = st + 1) begin
                row_best_s1_q[st] <= '0;
                row_pred_s1_q[st] <= '0;
            end
            pm_next <= '0;
            pred_cols <= '0;
            best_idx <= '0;
        end else begin
            valid_s1_q <= in_valid;
            valid_s2_q <= valid_s1_q;
            out_valid <= valid_s2_q;
            if (in_valid) begin
                for (st = 0; st < STATES; st = st + 1) begin
                    row_best_s1_q[st] <= row_best_w[st];
                    row_pred_s1_q[st] <= row_pred_w[st];
                end
            end
            if (ENABLE_OUTPUT_PIPELINE_SPLIT ? valid_s1_q : in_valid) begin
                pm_next <= pm_next_c;
                pred_cols <= pred_cols_c;
                best_idx <= best_idx_c;
            end
        end
    end
endmodule
