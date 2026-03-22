`timescale 1ns/1ps

// ============================================================================
// tx_pack_64x16_to_8lane_scalar_sync
// - Single-clock packer (no AXI, no valid/ready)
// - Input : 64 lanes x 16b (1024b) frame
// - Output: 8 lanes x 16b scalar ports
// - Each clk: outputs one "segment" (8 lanes) among 8 segments
//   seg 0 -> lanes  0..7
//   seg 1 -> lanes  8..15
//   seg 2 -> lanes 16..23
//   seg 3 -> lanes 24..31
//   seg 4 -> lanes 32..39
//   seg 5 -> lanes 40..47
//   seg 6 -> lanes 48..55
//   seg 7 -> lanes 56..63
//
// ASSUMPTION:
// - New input frame is aligned to seg_idx==0 (every 8 cycles), OR
// - Input is stable for >=8 cycles.
// ============================================================================

module tx_pack_64x16_to_8lane_scalar_sync (
    input  wire          clk,
    input  wire          rstn,

    input  wire [1023:0] in_frame_flat,   // 64*16b

    output reg  signed [15:0] dout16_0,
    output reg  signed [15:0] dout16_1,
    output reg  signed [15:0] dout16_2,
    output reg  signed [15:0] dout16_3,
    output reg  signed [15:0] dout16_4,
    output reg  signed [15:0] dout16_5,
    output reg  signed [15:0] dout16_6,
    output reg  signed [15:0] dout16_7
);

    // 8 segments (64/8)
    reg [2:0]     seg_idx;     // 0..7
    reg [1023:0]  frame_buf;

    integer lane_base;

    always @(posedge clk) begin
        if (!rstn) begin
            seg_idx   <= 3'd0;
            frame_buf <= 1024'b0;

            dout16_0  <= 16'sd0;  dout16_1  <= 16'sd0;  dout16_2  <= 16'sd0;  dout16_3  <= 16'sd0;
            dout16_4  <= 16'sd0;  dout16_5  <= 16'sd0;  dout16_6  <= 16'sd0;  dout16_7  <= 16'sd0;

        end else begin
            // 자동 프레임 래치: seg_idx==0일 때 "새 프레임"이라고 가정하고 잡음
            if (seg_idx == 3'd0) begin
                frame_buf <= in_frame_flat;
            end

            // 현재 segment의 8 lanes 출력
            lane_base = seg_idx * 8;

            dout16_0 <= frame_buf[(lane_base+0)*16 +: 16];
            dout16_1 <= frame_buf[(lane_base+1)*16 +: 16];
            dout16_2 <= frame_buf[(lane_base+2)*16 +: 16];
            dout16_3 <= frame_buf[(lane_base+3)*16 +: 16];
            dout16_4 <= frame_buf[(lane_base+4)*16 +: 16];
            dout16_5 <= frame_buf[(lane_base+5)*16 +: 16];
            dout16_6 <= frame_buf[(lane_base+6)*16 +: 16];
            dout16_7 <= frame_buf[(lane_base+7)*16 +: 16];

            // segment advance (0->1->2->...->7->0...)
            seg_idx <= seg_idx + 3'd1;
        end
    end

endmodule
