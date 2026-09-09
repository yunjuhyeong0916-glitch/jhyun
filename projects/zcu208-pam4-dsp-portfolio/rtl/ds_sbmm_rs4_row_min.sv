`timescale 1ns/1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: Dual-Survivor Segmented Branch-Metric Matrix MLSD
// Module Name: codex_pam4_rs4_row_min_ooc
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Reduces a 4-entry metric row to the minimum path metric and winning state index.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module codex_pam4_rs4_row_min_ooc #(
    parameter int MET_W = 10
) (
    input  logic [MET_W-1:0] pm0,
    input  logic [MET_W-1:0] pm1,
    input  logic [MET_W-1:0] pm2,
    input  logic [MET_W-1:0] pm3,
    input  logic [MET_W-1:0] m0,
    input  logic [MET_W-1:0] m1,
    input  logic [MET_W-1:0] m2,
    input  logic [MET_W-1:0] m3,
    output logic [MET_W-1:0] row_best,
    output logic [1:0]       row_pred
);
    localparam logic [MET_W-1:0] INF = {MET_W{1'b1}};

    logic [MET_W-1:0] c0;
    logic [MET_W-1:0] c1;
    logic [MET_W-1:0] c2;
    logic [MET_W-1:0] c3;
    logic [MET_W-1:0] b01;
    logic [MET_W-1:0] b23;
    logic [1:0]       p01;
    logic [1:0]       p23;
    logic             v0;
    logic             v1;
    logic             v2;
    logic             v3;

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

    always_comb begin
        v0 = (pm0 != INF) && (m0 != INF);
        v1 = (pm1 != INF) && (m1 != INF);
        v2 = (pm2 != INF) && (m2 != INF);
        v3 = (pm3 != INF) && (m3 != INF);

        c0 = sat_add(pm0, m0);
        c1 = sat_add(pm1, m1);
        c2 = sat_add(pm2, m2);
        c3 = sat_add(pm3, m3);

        b01 = INF;
        p01 = 2'd0;
        if (v0) begin
            b01 = c0;
            p01 = 2'd0;
        end
        if (v1 && (c1 < b01)) begin
            b01 = c1;
            p01 = 2'd1;
        end

        b23 = INF;
        p23 = 2'd2;
        if (v2) begin
            b23 = c2;
            p23 = 2'd2;
        end
        if (v3 && (c3 < b23)) begin
            b23 = c3;
            p23 = 2'd3;
        end

        if (b01 <= b23) begin
            row_best = b01;
            row_pred = p01;
        end else begin
            row_best = b23;
            row_pred = p23;
        end
    end
endmodule
