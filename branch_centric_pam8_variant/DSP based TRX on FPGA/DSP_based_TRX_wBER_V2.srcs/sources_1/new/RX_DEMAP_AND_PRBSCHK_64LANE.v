`timescale 1ns/1ps

module RX_DEMAP_AND_PRBSCHK_64LANE #(
    // =========================
    // Embedded thresholds
    // =========================
    parameter signed [7:0] THR_NRZ = 8'sd0,

    parameter signed [7:0] THR4_0  = -8'sd85,
    parameter signed [7:0] THR4_1  =  8'sd0,
    parameter signed [7:0] THR4_2  =  8'sd85,

    parameter signed [7:0] THR8_0  = -8'sd108,
    parameter signed [7:0] THR8_1  = -8'sd72,
    parameter signed [7:0] THR8_2  = -8'sd36,
    parameter signed [7:0] THR8_3  =  8'sd0,
    parameter signed [7:0] THR8_4  =  8'sd36,
    parameter signed [7:0] THR8_5  =  8'sd72,
    parameter signed [7:0] THR8_6  =  8'sd108
)(
    input              clk,
    input              rstb,
    input      [1:0]   prbs_sel,
    input      [1:0]   mode,
    input      [511:0] rx_din_flat,

    output     [63:0]  bits64,
    output     [127:0] bits128,
    output     [191:0] bits192,

    output     [63:0]  err64,
    output     [127:0] err128,
    output     [191:0] err192,

    output reg [191:0] err_sel
);

    // ------------------------------------------------------------
    // 1) Demapper
    // ------------------------------------------------------------
    RX_GRAY_DEMAP_64LANE_8B_CFG #(
        .THR_NRZ(THR_NRZ),
        .THR4_0 (THR4_0),
        .THR4_1 (THR4_1),
        .THR4_2 (THR4_2),
        .THR8_0 (THR8_0),
        .THR8_1 (THR8_1),
        .THR8_2 (THR8_2),
        .THR8_3 (THR8_3),
        .THR8_4 (THR8_4),
        .THR8_5 (THR8_5),
        .THR8_6 (THR8_6)
    ) u_demap (
        .mode        (mode),
        .rx_din_flat (rx_din_flat),
        .bits64      (bits64),
        .bits128     (bits128),
        .bits192     (bits192)
    );

    // ------------------------------------------------------------
    // 2) PRBS checkers
    // ------------------------------------------------------------
    genvar k;

    // NRZ
    generate
        for (k = 0; k < 64; k = k + 1) begin : GEN_CHK64
            PRBS_CHECKER u_chk (
                .clk      (clk),
                .rstb     (rstb),
                .prbs_sel (prbs_sel),
                .prbs     (bits64[k]),
                .err      (err64[k])
            );
        end
    endgenerate

    // PAM4
    generate
        for (k = 0; k < 128; k = k + 1) begin : GEN_CHK128
            PRBS_CHECKER u_chk (
                .clk      (clk),
                .rstb     (rstb),
                .prbs_sel (prbs_sel),
                .prbs     (bits128[k]),
                .err      (err128[k])
            );
        end
    endgenerate

    // PAM8
    generate
        for (k = 0; k < 192; k = k + 1) begin : GEN_CHK192
            PRBS_CHECKER u_chk (
                .clk      (clk),
                .rstb     (rstb),
                .prbs_sel (prbs_sel),
                .prbs     (bits192[k]),
                .err      (err192[k])
            );
        end
    endgenerate


    // ------------------------------------------------------------
    // 3) mode select
    // ------------------------------------------------------------
    always @(*) begin
        err_sel = 192'b0;

        case (mode)
            2'b00: err_sel[63:0]   = err64;
            2'b01: err_sel[127:0]  = err128;
            2'b10: err_sel[191:0]  = err192;
            default: err_sel       = 192'b0;
        endcase
    end

endmodule