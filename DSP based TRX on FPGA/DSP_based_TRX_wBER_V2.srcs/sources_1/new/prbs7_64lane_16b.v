`timescale 1ns/1ps
// ============================================================================
// prbs7_axis_master_16p1b
// - PRBS7 (x^7 + x^6 + 1)
// - AXI4-Stream Master
// - 16-parallel ¡¿ 1bit (m_axis_tdata[15:0])
// - backpressure safe
// ============================================================================

module prbs7_axis_master_16p1b (
    input  wire        aclk,
    input  wire        aresetn,

    output reg  [15:0] m_axis_tdata,
    output reg         m_axis_tvalid,
    input  wire        m_axis_tready
);

    integer i;

    // ------------------------------------------------------------------------
    // PRBS7 state
    // ------------------------------------------------------------------------
    reg [6:0] state_q;
    reg [6:0] state_d;
    reg [6:0] s;

    reg [15:0] prbs16;

    // ------------------------------------------------------------------------
    // PRBS7 16-step unroll (combinational)
    // ------------------------------------------------------------------------
    always @(*) begin
        s = state_q;
        for (i = 0; i < 16; i = i + 1) begin
            prbs16[i] = s[0];              // output bit
            s = {s[6] ^ s[5], s[6:1]};     // feedback
        end
        state_d = s;
    end

    // ------------------------------------------------------------------------
    // AXI4-Stream handshake + state control
    // ------------------------------------------------------------------------
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            state_q       <= 7'h1;   // non-zero seed
            m_axis_tdata  <= 16'd0;
            m_axis_tvalid <= 1'b0;
        end else begin
            if (!m_axis_tvalid) begin
                // prepare first word
                m_axis_tdata  <= prbs16;
                m_axis_tvalid <= 1'b1;
            end else if (m_axis_tvalid && m_axis_tready) begin
                // successful transfer ¡æ advance PRBS
                m_axis_tdata  <= prbs16;
                state_q       <= state_d;
                m_axis_tvalid <= 1'b1;   // continuous stream
            end
            // else: tvalid=1 & tready=0 ¡æ HOLD
        end
    end

endmodule
