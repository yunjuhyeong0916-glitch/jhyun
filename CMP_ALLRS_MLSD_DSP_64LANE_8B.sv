`timescale 1ns/1ps

module CMP_ALLRS_MLSD_DSP_64LANE_8B #(
    parameter int TB    = 40,
    parameter int MET_W = 16,

    parameter logic [3:0] K_CFG = 4'd2,

    parameter logic signed [7:0] P0 = 8'sd1,
    parameter logic signed [7:0] P1 = 8'sd2,
    parameter logic signed [7:0] P2 = 8'sd1,

    parameter logic signed [7:0] NRZ_NEG = -8'sd127,
    parameter logic signed [7:0] NRZ_POS =  8'sd127,

    parameter logic signed [7:0] PAM4_L0 = -8'sd96,
    parameter logic signed [7:0] PAM4_L1 = -8'sd32,
    parameter logic signed [7:0] PAM4_L2 =  8'sd32,
    parameter logic signed [7:0] PAM4_L3 =  8'sd96,

    parameter logic signed [7:0] PAM8_L0 = -8'sd112,
    parameter logic signed [7:0] PAM8_L1 = -8'sd80,
    parameter logic signed [7:0] PAM8_L2 = -8'sd48,
    parameter logic signed [7:0] PAM8_L3 = -8'sd16,
    parameter logic signed [7:0] PAM8_L4 =  8'sd16,
    parameter logic signed [7:0] PAM8_L5 =  8'sd48,
    parameter logic signed [7:0] PAM8_L6 =  8'sd80,
    parameter logic signed [7:0] PAM8_L7 =  8'sd112
)(
    input  logic         clk,
    input  logic         rst_n,
    input  logic         in_valid,
    input  logic [1:0]   mode,
    input  logic [1:0]   ch_case_sel,

    // 64 lanes x 8b = 512b
    input  logic [511:0] din_flat,
    input  logic [511:0] raw_flat,

    output logic [511:0] dout_flat,
    output logic         out_valid,
    output logic [15:0]  cand_count_sum,
    output logic [7:0]   ps_expand_sum,
    output logic [7:0]   ns_expand_sum,

    // debug (lane0)
    output logic signed [7:0]  dbg_raw0,
    output logic signed [15:0] dbg_ch0
);

    logic [63:0] out_valid_l;
    logic [7:0] cand_count_l [0:63];
    logic       ps_expand_l [0:63];
    logic       ns_expand_l [0:63];
    logic signed [15:0] ch_mid_lane [0:63];

    genvar gi;
    generate
        for (gi = 0; gi < 64; gi++) begin : GEN_LANE
            logic signed [7:0] z8;
            logic signed [7:0] a8;

            assign z8 = $signed(din_flat[8*gi +: 8]);
            assign dout_flat[8*gi +: 8] = a8;

            assign ch_mid_lane[gi] = {{8{z8[7]}}, z8};

            cmp_allrs_rs_mlsd_core_lane_8b #(
                .TB(TB),
                .MET_W(MET_W),

                .P0(P0), .P1(P1), .P2(P2),

                .NRZ_NEG(NRZ_NEG), .NRZ_POS(NRZ_POS),
                .PAM4_L0(PAM4_L0), .PAM4_L1(PAM4_L1), .PAM4_L2(PAM4_L2), .PAM4_L3(PAM4_L3),
                .PAM8_L0(PAM8_L0), .PAM8_L1(PAM8_L1), .PAM8_L2(PAM8_L2), .PAM8_L3(PAM8_L3),
                .PAM8_L4(PAM8_L4), .PAM8_L5(PAM8_L5), .PAM8_L6(PAM8_L6), .PAM8_L7(PAM8_L7)
            ) u_lane (
                .clk      (clk),
                .rst_n    (rst_n),
                .in_valid (in_valid),
                .mode     (mode),
                .ch_case_sel(ch_case_sel),
                .K_cfg    (K_CFG),
                .z8       (z8),
                .out_valid(out_valid_l[gi]),
                .a_hat8      (a8),
                .cand_count   (cand_count_l[gi]),
                .ps_expand_hit(ps_expand_l[gi]),
                .ns_expand_hit(ns_expand_l[gi])
            );

        end
    endgenerate

    assign out_valid = out_valid_l[0];

    always_comb begin
        int gi_i;
        cand_count_sum = 16'd0;
        ps_expand_sum = 8'd0;
        ns_expand_sum = 8'd0;
        for (gi_i = 0; gi_i < 64; gi_i = gi_i + 1) begin
            cand_count_sum = cand_count_sum + cand_count_l[gi_i];
            ps_expand_sum = ps_expand_sum + ps_expand_l[gi_i];
            ns_expand_sum = ns_expand_sum + ns_expand_l[gi_i];
        end
    end

    always_comb begin
        dbg_raw0 = $signed(raw_flat[7:0]);
        dbg_ch0  = ch_mid_lane[0];
    end

endmodule







