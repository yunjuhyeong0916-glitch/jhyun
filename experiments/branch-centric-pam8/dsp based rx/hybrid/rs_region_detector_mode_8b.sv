`timescale 1ns/1ps

module rs_region_detector_mode_8b #(
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
    input  logic [1:0]        mode,         // 00:NRZ, 01:PAM4, 10:PAM8
    input  logic signed [7:0] y8,           // regional-detector input
    output logic [7:0]        active_mask   // active symbol indices (bit i => sym i)
);

    always_comb begin
        active_mask = '0;

        unique case (mode)
            // NRZ: keep both symbols active.
            2'b00: begin
                active_mask[0] = 1'b1;
                active_mask[1] = 1'b1;
            end

            // PAM4: 3-region style mapping -> keep two adjacent symbols.
            2'b01: begin
                if (y8 < PAM4_L1) begin
                    active_mask[0] = 1'b1;
                    active_mask[1] = 1'b1;
                end else if (y8 <= PAM4_L2) begin
                    active_mask[1] = 1'b1;
                    active_mask[2] = 1'b1;
                end else begin
                    active_mask[2] = 1'b1;
                    active_mask[3] = 1'b1;
                end
            end

            // PAM8: mode-aware reduced-state profile (4 active symbols).
            2'b10: begin
                if (y8 < PAM8_L2) begin
                    active_mask[0] = 1'b1;
                    active_mask[1] = 1'b1;
                    active_mask[2] = 1'b1;
                    active_mask[3] = 1'b1;
                end else if (y8 < PAM8_L3) begin
                    active_mask[1] = 1'b1;
                    active_mask[2] = 1'b1;
                    active_mask[3] = 1'b1;
                    active_mask[4] = 1'b1;
                end else if (y8 <= PAM8_L4) begin
                    active_mask[2] = 1'b1;
                    active_mask[3] = 1'b1;
                    active_mask[4] = 1'b1;
                    active_mask[5] = 1'b1;
                end else if (y8 <= PAM8_L5) begin
                    active_mask[3] = 1'b1;
                    active_mask[4] = 1'b1;
                    active_mask[5] = 1'b1;
                    active_mask[6] = 1'b1;
                end else begin
                    active_mask[4] = 1'b1;
                    active_mask[5] = 1'b1;
                    active_mask[6] = 1'b1;
                    active_mask[7] = 1'b1;
                end
            end

            default: begin
                active_mask[0] = 1'b1;
                active_mask[1] = 1'b1;
            end
        endcase
    end

endmodule
