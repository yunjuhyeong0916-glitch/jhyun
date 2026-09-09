`timescale 1ns/1ps

// ============================================================================
// TX_PRBS_MULTI_TOP_32LANE
// - One PRBS64 generator per cycle.
// - PAM4 consumes all 64 PRBS bits as 32 symbols on lanes 0..31.
// - ext_ptrn ports override the PRBS generator when ext_ptrn_en is high.
// - The PRBS state is held while the external pattern is selected.
// - The selected 64-bit word is registered once before symbol mapping.
// - The mapped 8-bit symbols are registered once before the TX FIR.
// - NRZ long-gap impulse mode:
//   ext_ptrn_en=1, mode=00, ext_ptrn[63:56]=8'hA5.
//   ext_ptrn[55:48] is period_words_minus_1; ext_ptrn[31:0] is the pulse mask.
// ============================================================================

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PRBS Generation and BER Checking
// Module Name: TX_PRBS_MULTI_TOP_32LANE
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Generates 32-lane PRBS/constant TX bit streams with configurable mode control.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module TX_PRBS_MULTI_TOP_32LANE (
    input  wire        rstb,
    input  wire        i_clk,
    input  wire [1:0]  sel_prbs,
    input  wire        ext_ptrn_en,
    input  wire [63:0] ext_ptrn,

    // 00 = NRZ, 01 = PAM4, 10 = PAM4 fallback in this PRBS64 mode
    input  wire [1:0]  mode,

    output logic signed [7:0] dout [0:31]
);

    logic [30:0] state0, state1;
    wire  [63:0] prbs64;
    logic [63:0] prbs64_q;
    localparam logic [7:0] IMPULSE_SIG = 8'hA5;

    wire        impulse_mode = ext_ptrn_en && (mode == 2'b00) && (ext_ptrn[63:56] == IMPULSE_SIG);
    wire [7:0] impulse_period_m1 = ext_ptrn[55:48];
    logic [7:0] impulse_phase_q;
    wire [63:0] impulse_ext_ptrn = (impulse_phase_q == 8'd0) ? {32'b0, ext_ptrn[31:0]} : 64'b0;
    wire [63:0] prbs_ext_ptrn = impulse_mode ? impulse_ext_ptrn : ext_ptrn;

    prbsgen_64b u_prbs64_0 (
        .rstb        (rstb),
        .i_clk       (i_clk),
        .sel_prbs    (sel_prbs),
        .ext_ptrn_en (ext_ptrn_en),
        .ext_ptrn    (prbs_ext_ptrn),
        .state_in_en (1'b1),
        .state_in    (state0),
        .state_out   (state1),
        .dout        (prbs64)
    );

    always_ff @(posedge i_clk or negedge rstb) begin
        if (!rstb) begin
            state0 <= 31'h0000_7FFF;
        end else begin
            state0 <= state1;
        end
    end

    always_ff @(posedge i_clk or negedge rstb) begin
        if (!rstb) begin
            impulse_phase_q <= 8'd0;
        end else if (!impulse_mode) begin
            impulse_phase_q <= 8'd0;
        end else if (impulse_phase_q >= impulse_period_m1) begin
            impulse_phase_q <= 8'd0;
        end else begin
            impulse_phase_q <= impulse_phase_q + 8'd1;
        end
    end

    always_ff @(posedge i_clk or negedge rstb) begin
        if (!rstb) begin
            prbs64_q <= 64'b0;
        end else begin
            prbs64_q <= prbs64;
        end
    end

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : GEN_LANE
            wire nrz_bit = prbs64_q[i];
            wire signed [7:0] nrz_8b;
            NRZ_to_8b u_nrz (
                .din  (nrz_bit),
                .dout (nrz_8b)
            );

            wire [1:0] pam4_sym = {prbs64_q[2*i+1], prbs64_q[2*i]};
            wire signed [7:0] pam4_8b;
            PAM4_2b_to_8b u_pam4 (
                .din  (pam4_sym),
                .dout (pam4_8b)
            );

            logic signed [7:0] dout_sel;
            always_comb begin
                unique case (mode)
                    2'b00: dout_sel = nrz_8b;
                    2'b01: dout_sel = pam4_8b;
                    2'b10: dout_sel = pam4_8b;
                    default: dout_sel = nrz_8b;
                endcase
            end

            always_ff @(posedge i_clk or negedge rstb) begin
                if (!rstb) begin
                    dout[i] <= 8'sd0;
                end else begin
                    dout[i] <= dout_sel;
                end
            end
        end
    endgenerate

endmodule

// ============================================================================
// TX_PRBS_MULTI_TOP_64LANE
// - Legacy compatibility wrapper.
// - Lanes 0..31 are valid; lanes 32..63 are tied to zero.
// ============================================================================

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PRBS Generation and BER Checking
// Module Name: TX_PRBS_MULTI_TOP_64LANE
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Provides a legacy 64-lane compatibility wrapper around the active 32-lane TX PRBS generator.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module TX_PRBS_MULTI_TOP_64LANE (
    input  wire        rstb,
    input  wire        i_clk,
    input  wire [1:0]  sel_prbs,
    input  wire        ext_ptrn_en,
    input  wire [63:0] ext_ptrn,
    input  wire [1:0]  mode,
    output logic signed [7:0] dout [0:63]
);

    logic signed [7:0] dout32 [0:31];

    TX_PRBS_MULTI_TOP_32LANE u_core32 (
        .rstb     (rstb),
        .i_clk    (i_clk),
        .sel_prbs (sel_prbs),
        .ext_ptrn_en (ext_ptrn_en),
        .ext_ptrn (ext_ptrn),
        .mode     (mode),
        .dout     (dout32)
    );

    genvar lane_i;
    generate
        for (lane_i = 0; lane_i < 32; lane_i = lane_i + 1) begin : GEN_VALID
            assign dout[lane_i] = dout32[lane_i];
        end
        for (lane_i = 32; lane_i < 64; lane_i = lane_i + 1) begin : GEN_UNUSED
            assign dout[lane_i] = 8'sd0;
        end
    endgenerate

endmodule
