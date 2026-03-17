`timescale 1ns/1ps

module PRBS_CHK_RX_TEST (
    input  wire        clk,
    input  wire        rstb,       // active low
    input  wire [1:0]  prbs_sel,   // 00=prbs7, 01=prbs15, 10=prbs31
    input  wire [1:0]  mode,       // 00=NRZ, 01=PAM4, 10=PAM8
    input  wire [511:0] rx_din_flat, // 64lane * 8b signed samples

    // demap outputs (ILA/debug용)
    output wire [63:0]  bits64,
    output wire [127:0] bits128,
    output wire [191:0] bits192,

    // PRBS error outputs
    output wire [63:0]  err64,
    output wire [127:0] err128,
    output wire [191:0] err192,
    output wire [191:0] err_sel     // mode에 맞는 err만 살아있고 나머지는 0
);

    // ------------------------------------------------------------
    // 1) Gray demap (NRZ/PAM4/PAM8 모두 생성)
    // ------------------------------------------------------------
    RX_GRAY_DEMAP_64LANE_8B_CFG u_demap (
        .mode        (mode),
        .rx_din_flat (rx_din_flat),
        .bits64      (bits64),
        .bits128     (bits128),
        .bits192     (bits192)
    );

    // ------------------------------------------------------------
    // 2) mode에 따른 "체크할 비트스트림" 구성 (최대 192로 고정)
    // ------------------------------------------------------------
    wire [191:0] prbs_in;
    wire [191:0] err_all;

    genvar k;
    generate
        for (k = 0; k < 192; k = k + 1) begin : GEN_PRBSIN
            if (k < 64) begin : G0_63
                assign prbs_in[k] = (mode == 2'b00) ? bits64[k]   : 1'b0; // NRZ
            end
            else if (k < 128) begin : G64_127
                assign prbs_in[k] = (mode == 2'b01) ? bits128[k]  : 1'b0; // PAM4
            end
            else begin : G128_191
                assign prbs_in[k] = (mode == 2'b10) ? bits192[k]  : 1'b0; // PAM8
            end

            // ----------------------------------------------------
            // 3) bit별 PRBS_CHECKER 적용
            // ----------------------------------------------------
            PRBS_CHECKER u_chk (
                .clk      (clk),
                .rstb     (rstb),
                .prbs_sel (prbs_sel),
                .prbs     (prbs_in[k]),
                .err      (err_all[k])
            );
        end
    endgenerate

    // ------------------------------------------------------------
    // 4) mode별 출력 정리
    //    - 선택된 mode 폭만 유효, 나머지는 0
    // ------------------------------------------------------------
    assign err_sel = err_all;

    assign err64  = (mode == 2'b00) ? err_all[63:0]   : 64'b0;
    assign err128 = (mode == 2'b01) ? err_all[127:0]  : 128'b0;
    assign err192 = (mode == 2'b10) ? err_all[191:0]  : 192'b0;

endmodule