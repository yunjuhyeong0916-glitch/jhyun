`timescale 1ns/1ps

module txrx_pack_to_axis64 (
    input               aclk,
    input               aresetn,

    input  wire [31:0]  tx32,
    input  wire         tx_valid,   // 1이면 tx32 유효

    input  wire [31:0]  rx32,
    input  wire         rx_valid,   // 1이면 rx32 유효 (보통 RX가 기준)

    // AXI4-Stream out (to DMA S2MM)
    output reg  [63:0]  m_axis_tdata,
    output reg          m_axis_tvalid,
    input  wire         m_axis_tready
);

    always @(posedge aclk) begin
        if (!aresetn) begin
            m_axis_tdata  <= 64'd0;
            m_axis_tvalid <= 1'b0;
        end else begin
            // 소비되면 다음 전송 준비
            if (m_axis_tvalid && m_axis_tready) begin
                m_axis_tvalid <= 1'b0;
            end

            // "새 레코드" 생성 조건:
            // - 현재 비어있거나(!tvalid) 또는 이번 사이클에 소비될 예정(tready)이고
            // - rx_valid가 들어오면 1개의 64b 레코드 생성
            if ((m_axis_tready || !m_axis_tvalid) && rx_valid) begin
                // [31:0]  = TX32
                // [63:32] = RX32
                // (TX가 같은 타이밍이 아닐 수도 있으면 tx_valid로 외부에서 align 권장)
                m_axis_tdata  <= {rx32, tx32};
                m_axis_tvalid <= 1'b1;
            end
        end
    end

endmodule