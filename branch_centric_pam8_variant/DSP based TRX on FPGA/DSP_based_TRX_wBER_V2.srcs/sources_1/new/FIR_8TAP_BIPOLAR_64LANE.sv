`timescale 1ns/1ps

module FIR_8TAP_BIPOLAR_64LANE #(
    parameter int SHIFT = 8,
    parameter int PRE   = 1          // 권장: 0..6 (PRE=7이면 POST=0이라 구조상 별도 처리 필요)
)(
    input  logic               clk,
    input  logic               rst_n,

    input  logic signed [7:0]  din      [0:63],
    input  logic signed [63:0] h_packed,
    output logic signed [7:0]  dout     [0:63]
);

    localparam int LANES = 64;
    localparam int NTAPS = 8;
    localparam int POST  = (NTAPS-1) - PRE;   // 7-PRE

    // ----------------------------
    // unpack coeff
    // ----------------------------
    logic signed [7:0] h_rel_idx [0:NTAPS-1];
    integer rr;
    always_comb begin
        for (rr = 0; rr < NTAPS; rr = rr + 1)
            h_rel_idx[rr] = h_packed[8*rr +: 8];
    end

    // ----------------------------
    // storage blocks
    // ----------------------------
    logic signed [7:0] prev_block [0:LANES-1];
    logic signed [7:0] curr_block [0:LANES-1];

    // POST>0일 때만 의미 있음 (PRE=7이면 POST=0이라 이 배열 자체가 만들 수 없음)
    // => 안전하게 PRE 범위를 0..6로 쓰는 걸 추천
    logic signed [7:0] tail_post  [0:POST-1];

    logic have_2blocks;

    // ----------------------------
    // extmul
    // ----------------------------
    function automatic logic signed [23:0] extmul8(
        input logic signed [7:0] a,
        input logic signed [7:0] b
    );
        logic signed [15:0] p;
        begin
            p = a * b;
            extmul8 = {{8{p[15]}}, p};
        end
    endfunction

    // ----------------------------
    // sat + shift
    // ----------------------------
    function automatic logic signed [7:0] sat8_shift(
        input logic signed [23:0] x
    );
        logic signed [23:0] y;
        begin
            y = x >>> SHIFT;
            if ($signed(y) >  127) sat8_shift =  8'sd127;
            else if ($signed(y) < -128) sat8_shift = -8'sd128;
            else sat8_shift = y[7:0];
        end
    endfunction

    // ----------------------------
    // sample fetch (툴호환 위해 블록내 선언 제거)
    // ----------------------------
    function automatic logic signed [7:0] get_sample_for_prev(
        input int i,
        input int k_rel
    );
        int idx;
        int a;
        int b;
        begin
            idx = i - k_rel;

            if ((idx >= 0) && (idx < LANES)) begin
                get_sample_for_prev = prev_block[idx];
            end
            else if (idx < 0) begin
                a = -idx - 1;
                if ((POST > 0) && (a >= 0) && (a < POST))
                    get_sample_for_prev = tail_post[a];
                else
                    get_sample_for_prev = '0;
            end
            else begin
                b = idx - LANES;
                if ((PRE > 0) && (b >= 0) && (b < PRE))
                    get_sample_for_prev = curr_block[b];
                else
                    get_sample_for_prev = '0;
            end
        end
    endfunction

    // ----------------------------
    // comb accumulate
    // ----------------------------
    logic signed [23:0] acc [0:LANES-1];

    integer i, r;
    int k_rel;
    logic signed [23:0] sum;
    logic signed [7:0]  x_samp;

    always_comb begin
        for (i = 0; i < LANES; i = i + 1) begin
            sum = '0;
            for (r = 0; r < NTAPS; r = r + 1) begin
                k_rel  = r - PRE;
                x_samp = get_sample_for_prev(i, k_rel);
                sum    = sum + extmul8(x_samp, h_rel_idx[r]);
            end
            acc[i] = sum;
        end
    end

    // ----------------------------
    // sequential: capture/shift (reset은 for-loop로)
    // ----------------------------
    integer k;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            have_2blocks <= 1'b0;

            for (i = 0; i < LANES; i = i + 1) begin
                prev_block[i] <= '0;
                curr_block[i] <= '0;
            end

            if (POST > 0) begin
                for (k = 0; k < POST; k = k + 1)
                    tail_post[k] <= '0;
            end
        end else begin
            // shift blocks
            prev_block <= curr_block;
            curr_block <= din;

            have_2blocks <= 1'b1;

            // update tail_post for next cycle (POST>0일 때만)
            if (POST > 0) begin
                for (k = 0; k < POST; k = k + 1)
                    tail_post[k] <= curr_block[LANES-1-k];
            end
        end
    end

    // ----------------------------
    // output reg
    // ----------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < LANES; i = i + 1)
                dout[i] <= '0;
        end else begin
            if (!have_2blocks) begin
                for (i = 0; i < LANES; i = i + 1)
                    dout[i] <= '0;
            end else begin
                for (i = 0; i < LANES; i = i + 1)
                    dout[i] <= sat8_shift(acc[i]);
            end
        end
    end

endmodule