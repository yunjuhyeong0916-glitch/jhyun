`timescale 1ns/1ps
// ============================================================================
// rx_bd_shim_raw1024_to_bitplanes_mmrs_mlsd_fitfirst
// - in_data_16b(512) -> 32-lane PAM4 bypass/frontend/MLSD -> RX8P export
// - The active board path consumes 32 16-bit RX samples directly.
// - Legacy 64-lane detector branches remain source-compatible but disabled.
// - PRBSCHK owns bitplane generation; this shim exports RX8P samples/valid.
// - This variant does NOT modify the original shim or placeholder RX DSP.
// ============================================================================

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: DAC/ADC DSP-Based PAM4 Transceiver
// Module Name: rx_bd_shim_raw1024_to_bitplanes_mmrs_mlsd_fitfirst
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Bridges the 1024-bit RX BD stream to bit-plane outputs with EQ and DS-SBMM MLSD detection.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module rx_bd_shim_raw1024_to_bitplanes_mmrs_mlsd_fitfirst (
    input  wire          aclk,
    input  wire          aresetn,

    input  wire [1:0]    mode,        // 00=NRZ, 01=PAM4, 10=PAM8
    input  wire          rx_ffe_en,
    input  wire [63:0]   rx_h_flat,
    input  wire          cfg_use_mlsd,
    input  wire [1:0]    ch_case_sel,
    input  wire [511:0]  in_data_16b,
    input  wire          in_data_valid,
    input  wire          cfg_rx_eq_override_en,
    input  wire signed [(21*8)-1:0] cfg_rx_eq_coeffs_flat,
    input  wire          cfg_rx_pr_override_en,
    input  wire signed [(3*12)-1:0] cfg_rx_pr_taps_flat,
    input  wire          cfg_rx_level_override_en,
    input  wire signed [31:0] cfg_rx_pam4_levels_flat,
    input  wire          cfg_rx_thr_override_en,
    input  wire signed [23:0] cfg_rx_thr4_flat,
    input  wire [2:0]    cfg_rx_mlsd_dbg_group_sel,
    input  wire [2:0]    cfg_rx_main_route_sel,
    input  wire          cfg_rx_main_route_override_en,

    // Selected 32-lane output sent to the checker/decode path.
    output wire signed [255:0] out_rx8p_packed,
    output wire          out_rx8p_valid,

    // Debug/bring-up visibility.
    output wire signed [255:0] out_rx8p_bypass_packed,
    output wire signed [255:0] out_rx8p_mlsd_packed,
    output wire          out_path_is_mlsd,
    output wire          mlsd_out_valid,
    output wire          mlsd_accept_valid,
    output wire [15:0]   mlsd_cand_count_sum,
    output wire [7:0]    mlsd_ps_expand_sum,
    output wire [7:0]    mlsd_ns_expand_sum,
    output wire signed [63:0]  dbg_raw8_lanes8,
    output wire signed [63:0]  dbg_eq8_lanes8,
    output wire signed [255:0] dbg_eq8_packed_full,
    output wire signed [63:0]  dbg_shape8_lanes8,
    output wire signed [63:0]  dbg_np8_lanes8,
    output wire signed [63:0]  dbg_det_np8_lanes8,
    output wire signed [63:0]  dbg_mlsd8_lanes8,
    output wire [63:0]   dbg_mlsd_hist_packed,
    output wire [63:0]   dbg_predec_hist_packed,
    output wire [63:0]   dbg_mlsd_ctrl_packed,
    output wire [63:0]   dbg_mlsd_pm_packed,
    output wire signed [7:0]   dbg_raw0,
    output wire signed [15:0]  dbg_ch0
);

    // Only legacy inactive detector branches still require the historical
    // 1024-bit/64-lane shape.  The active path below uses in_data_16b directly.
    wire [1023:0] in_data_16b_64lane_padded = {in_data_16b, 512'd0};

    generate if (1'b0) begin : GEN_LEGACY_BYPASS64_UNUSED
    // ------------------------------------------------------------------------
    // Legacy 64-lane bypass unpack/truncate path, intentionally disabled.
    // ------------------------------------------------------------------------
    wire signed [15:0] rx16_0;
    wire signed [15:0] rx16_1;
    wire signed [15:0] rx16_2;
    wire signed [15:0] rx16_3;
    wire signed [15:0] rx16_4;
    wire signed [15:0] rx16_5;
    wire signed [15:0] rx16_6;
    wire signed [15:0] rx16_7;
    wire signed [15:0] rx16_8;
    wire signed [15:0] rx16_9;
    wire signed [15:0] rx16_10;
    wire signed [15:0] rx16_11;
    wire signed [15:0] rx16_12;
    wire signed [15:0] rx16_13;
    wire signed [15:0] rx16_14;
    wire signed [15:0] rx16_15;
    wire signed [15:0] rx16_16;
    wire signed [15:0] rx16_17;
    wire signed [15:0] rx16_18;
    wire signed [15:0] rx16_19;
    wire signed [15:0] rx16_20;
    wire signed [15:0] rx16_21;
    wire signed [15:0] rx16_22;
    wire signed [15:0] rx16_23;
    wire signed [15:0] rx16_24;
    wire signed [15:0] rx16_25;
    wire signed [15:0] rx16_26;
    wire signed [15:0] rx16_27;
    wire signed [15:0] rx16_28;
    wire signed [15:0] rx16_29;
    wire signed [15:0] rx16_30;
    wire signed [15:0] rx16_31;
    wire signed [15:0] rx16_32;
    wire signed [15:0] rx16_33;
    wire signed [15:0] rx16_34;
    wire signed [15:0] rx16_35;
    wire signed [15:0] rx16_36;
    wire signed [15:0] rx16_37;
    wire signed [15:0] rx16_38;
    wire signed [15:0] rx16_39;
    wire signed [15:0] rx16_40;
    wire signed [15:0] rx16_41;
    wire signed [15:0] rx16_42;
    wire signed [15:0] rx16_43;
    wire signed [15:0] rx16_44;
    wire signed [15:0] rx16_45;
    wire signed [15:0] rx16_46;
    wire signed [15:0] rx16_47;
    wire signed [15:0] rx16_48;
    wire signed [15:0] rx16_49;
    wire signed [15:0] rx16_50;
    wire signed [15:0] rx16_51;
    wire signed [15:0] rx16_52;
    wire signed [15:0] rx16_53;
    wire signed [15:0] rx16_54;
    wire signed [15:0] rx16_55;
    wire signed [15:0] rx16_56;
    wire signed [15:0] rx16_57;
    wire signed [15:0] rx16_58;
    wire signed [15:0] rx16_59;
    wire signed [15:0] rx16_60;
    wire signed [15:0] rx16_61;
    wire signed [15:0] rx16_62;
    wire signed [15:0] rx16_63;

    rx_unpack1024_to_64x16 u_unp (
        .in_data_16b(in_data_16b_64lane_padded),
        .rx16_0(rx16_0),
        .rx16_1(rx16_1),
        .rx16_2(rx16_2),
        .rx16_3(rx16_3),
        .rx16_4(rx16_4),
        .rx16_5(rx16_5),
        .rx16_6(rx16_6),
        .rx16_7(rx16_7),
        .rx16_8(rx16_8),
        .rx16_9(rx16_9),
        .rx16_10(rx16_10),
        .rx16_11(rx16_11),
        .rx16_12(rx16_12),
        .rx16_13(rx16_13),
        .rx16_14(rx16_14),
        .rx16_15(rx16_15),
        .rx16_16(rx16_16),
        .rx16_17(rx16_17),
        .rx16_18(rx16_18),
        .rx16_19(rx16_19),
        .rx16_20(rx16_20),
        .rx16_21(rx16_21),
        .rx16_22(rx16_22),
        .rx16_23(rx16_23),
        .rx16_24(rx16_24),
        .rx16_25(rx16_25),
        .rx16_26(rx16_26),
        .rx16_27(rx16_27),
        .rx16_28(rx16_28),
        .rx16_29(rx16_29),
        .rx16_30(rx16_30),
        .rx16_31(rx16_31),
        .rx16_32(rx16_32),
        .rx16_33(rx16_33),
        .rx16_34(rx16_34),
        .rx16_35(rx16_35),
        .rx16_36(rx16_36),
        .rx16_37(rx16_37),
        .rx16_38(rx16_38),
        .rx16_39(rx16_39),
        .rx16_40(rx16_40),
        .rx16_41(rx16_41),
        .rx16_42(rx16_42),
        .rx16_43(rx16_43),
        .rx16_44(rx16_44),
        .rx16_45(rx16_45),
        .rx16_46(rx16_46),
        .rx16_47(rx16_47),
        .rx16_48(rx16_48),
        .rx16_49(rx16_49),
        .rx16_50(rx16_50),
        .rx16_51(rx16_51),
        .rx16_52(rx16_52),
        .rx16_53(rx16_53),
        .rx16_54(rx16_54),
        .rx16_55(rx16_55),
        .rx16_56(rx16_56),
        .rx16_57(rx16_57),
        .rx16_58(rx16_58),
        .rx16_59(rx16_59),
        .rx16_60(rx16_60),
        .rx16_61(rx16_61),
        .rx16_62(rx16_62),
        .rx16_63(rx16_63)
    );

    // ------------------------------------------------------------------------
    // trunc -> rx8_pre
    // ------------------------------------------------------------------------
    wire signed [7:0] rx8p_0;
    wire signed [7:0] rx8p_1;
    wire signed [7:0] rx8p_2;
    wire signed [7:0] rx8p_3;
    wire signed [7:0] rx8p_4;
    wire signed [7:0] rx8p_5;
    wire signed [7:0] rx8p_6;
    wire signed [7:0] rx8p_7;
    wire signed [7:0] rx8p_8;
    wire signed [7:0] rx8p_9;
    wire signed [7:0] rx8p_10;
    wire signed [7:0] rx8p_11;
    wire signed [7:0] rx8p_12;
    wire signed [7:0] rx8p_13;
    wire signed [7:0] rx8p_14;
    wire signed [7:0] rx8p_15;
    wire signed [7:0] rx8p_16;
    wire signed [7:0] rx8p_17;
    wire signed [7:0] rx8p_18;
    wire signed [7:0] rx8p_19;
    wire signed [7:0] rx8p_20;
    wire signed [7:0] rx8p_21;
    wire signed [7:0] rx8p_22;
    wire signed [7:0] rx8p_23;
    wire signed [7:0] rx8p_24;
    wire signed [7:0] rx8p_25;
    wire signed [7:0] rx8p_26;
    wire signed [7:0] rx8p_27;
    wire signed [7:0] rx8p_28;
    wire signed [7:0] rx8p_29;
    wire signed [7:0] rx8p_30;
    wire signed [7:0] rx8p_31;
    wire signed [7:0] rx8p_32;
    wire signed [7:0] rx8p_33;
    wire signed [7:0] rx8p_34;
    wire signed [7:0] rx8p_35;
    wire signed [7:0] rx8p_36;
    wire signed [7:0] rx8p_37;
    wire signed [7:0] rx8p_38;
    wire signed [7:0] rx8p_39;
    wire signed [7:0] rx8p_40;
    wire signed [7:0] rx8p_41;
    wire signed [7:0] rx8p_42;
    wire signed [7:0] rx8p_43;
    wire signed [7:0] rx8p_44;
    wire signed [7:0] rx8p_45;
    wire signed [7:0] rx8p_46;
    wire signed [7:0] rx8p_47;
    wire signed [7:0] rx8p_48;
    wire signed [7:0] rx8p_49;
    wire signed [7:0] rx8p_50;
    wire signed [7:0] rx8p_51;
    wire signed [7:0] rx8p_52;
    wire signed [7:0] rx8p_53;
    wire signed [7:0] rx8p_54;
    wire signed [7:0] rx8p_55;
    wire signed [7:0] rx8p_56;
    wire signed [7:0] rx8p_57;
    wire signed [7:0] rx8p_58;
    wire signed [7:0] rx8p_59;
    wire signed [7:0] rx8p_60;
    wire signed [7:0] rx8p_61;
    wire signed [7:0] rx8p_62;
    wire signed [7:0] rx8p_63;

    trunc16_to_8_64lane u_trunc (
        .din16_0(rx16_0),
        .din16_1(rx16_1),
        .din16_2(rx16_2),
        .din16_3(rx16_3),
        .din16_4(rx16_4),
        .din16_5(rx16_5),
        .din16_6(rx16_6),
        .din16_7(rx16_7),
        .din16_8(rx16_8),
        .din16_9(rx16_9),
        .din16_10(rx16_10),
        .din16_11(rx16_11),
        .din16_12(rx16_12),
        .din16_13(rx16_13),
        .din16_14(rx16_14),
        .din16_15(rx16_15),
        .din16_16(rx16_16),
        .din16_17(rx16_17),
        .din16_18(rx16_18),
        .din16_19(rx16_19),
        .din16_20(rx16_20),
        .din16_21(rx16_21),
        .din16_22(rx16_22),
        .din16_23(rx16_23),
        .din16_24(rx16_24),
        .din16_25(rx16_25),
        .din16_26(rx16_26),
        .din16_27(rx16_27),
        .din16_28(rx16_28),
        .din16_29(rx16_29),
        .din16_30(rx16_30),
        .din16_31(rx16_31),
        .din16_32(rx16_32),
        .din16_33(rx16_33),
        .din16_34(rx16_34),
        .din16_35(rx16_35),
        .din16_36(rx16_36),
        .din16_37(rx16_37),
        .din16_38(rx16_38),
        .din16_39(rx16_39),
        .din16_40(rx16_40),
        .din16_41(rx16_41),
        .din16_42(rx16_42),
        .din16_43(rx16_43),
        .din16_44(rx16_44),
        .din16_45(rx16_45),
        .din16_46(rx16_46),
        .din16_47(rx16_47),
        .din16_48(rx16_48),
        .din16_49(rx16_49),
        .din16_50(rx16_50),
        .din16_51(rx16_51),
        .din16_52(rx16_52),
        .din16_53(rx16_53),
        .din16_54(rx16_54),
        .din16_55(rx16_55),
        .din16_56(rx16_56),
        .din16_57(rx16_57),
        .din16_58(rx16_58),
        .din16_59(rx16_59),
        .din16_60(rx16_60),
        .din16_61(rx16_61),
        .din16_62(rx16_62),
        .din16_63(rx16_63),

        .dout8_0(rx8p_0),
        .dout8_1(rx8p_1),
        .dout8_2(rx8p_2),
        .dout8_3(rx8p_3),
        .dout8_4(rx8p_4),
        .dout8_5(rx8p_5),
        .dout8_6(rx8p_6),
        .dout8_7(rx8p_7),
        .dout8_8(rx8p_8),
        .dout8_9(rx8p_9),
        .dout8_10(rx8p_10),
        .dout8_11(rx8p_11),
        .dout8_12(rx8p_12),
        .dout8_13(rx8p_13),
        .dout8_14(rx8p_14),
        .dout8_15(rx8p_15),
        .dout8_16(rx8p_16),
        .dout8_17(rx8p_17),
        .dout8_18(rx8p_18),
        .dout8_19(rx8p_19),
        .dout8_20(rx8p_20),
        .dout8_21(rx8p_21),
        .dout8_22(rx8p_22),
        .dout8_23(rx8p_23),
        .dout8_24(rx8p_24),
        .dout8_25(rx8p_25),
        .dout8_26(rx8p_26),
        .dout8_27(rx8p_27),
        .dout8_28(rx8p_28),
        .dout8_29(rx8p_29),
        .dout8_30(rx8p_30),
        .dout8_31(rx8p_31),
        .dout8_32(rx8p_32),
        .dout8_33(rx8p_33),
        .dout8_34(rx8p_34),
        .dout8_35(rx8p_35),
        .dout8_36(rx8p_36),
        .dout8_37(rx8p_37),
        .dout8_38(rx8p_38),
        .dout8_39(rx8p_39),
        .dout8_40(rx8p_40),
        .dout8_41(rx8p_41),
        .dout8_42(rx8p_42),
        .dout8_43(rx8p_43),
        .dout8_44(rx8p_44),
        .dout8_45(rx8p_45),
        .dout8_46(rx8p_46),
        .dout8_47(rx8p_47),
        .dout8_48(rx8p_48),
        .dout8_49(rx8p_49),
        .dout8_50(rx8p_50),
        .dout8_51(rx8p_51),
        .dout8_52(rx8p_52),
        .dout8_53(rx8p_53),
        .dout8_54(rx8p_54),
        .dout8_55(rx8p_55),
        .dout8_56(rx8p_56),
        .dout8_57(rx8p_57),
        .dout8_58(rx8p_58),
        .dout8_59(rx8p_59),
        .dout8_60(rx8p_60),
        .dout8_61(rx8p_61),
        .dout8_62(rx8p_62),
        .dout8_63(rx8p_63)
    );

    // ------------------------------------------------------------------------
    // pack bypass path
    // ------------------------------------------------------------------------
    assign out_rx8p_bypass_packed[0 +: 8] = rx8p_0;
    assign out_rx8p_bypass_packed[8 +: 8] = rx8p_1;
    assign out_rx8p_bypass_packed[16 +: 8] = rx8p_2;
    assign out_rx8p_bypass_packed[24 +: 8] = rx8p_3;
    assign out_rx8p_bypass_packed[32 +: 8] = rx8p_4;
    assign out_rx8p_bypass_packed[40 +: 8] = rx8p_5;
    assign out_rx8p_bypass_packed[48 +: 8] = rx8p_6;
    assign out_rx8p_bypass_packed[56 +: 8] = rx8p_7;
    assign out_rx8p_bypass_packed[64 +: 8] = rx8p_8;
    assign out_rx8p_bypass_packed[72 +: 8] = rx8p_9;
    assign out_rx8p_bypass_packed[80 +: 8] = rx8p_10;
    assign out_rx8p_bypass_packed[88 +: 8] = rx8p_11;
    assign out_rx8p_bypass_packed[96 +: 8] = rx8p_12;
    assign out_rx8p_bypass_packed[104 +: 8] = rx8p_13;
    assign out_rx8p_bypass_packed[112 +: 8] = rx8p_14;
    assign out_rx8p_bypass_packed[120 +: 8] = rx8p_15;
    assign out_rx8p_bypass_packed[128 +: 8] = rx8p_16;
    assign out_rx8p_bypass_packed[136 +: 8] = rx8p_17;
    assign out_rx8p_bypass_packed[144 +: 8] = rx8p_18;
    assign out_rx8p_bypass_packed[152 +: 8] = rx8p_19;
    assign out_rx8p_bypass_packed[160 +: 8] = rx8p_20;
    assign out_rx8p_bypass_packed[168 +: 8] = rx8p_21;
    assign out_rx8p_bypass_packed[176 +: 8] = rx8p_22;
    assign out_rx8p_bypass_packed[184 +: 8] = rx8p_23;
    assign out_rx8p_bypass_packed[192 +: 8] = rx8p_24;
    assign out_rx8p_bypass_packed[200 +: 8] = rx8p_25;
    assign out_rx8p_bypass_packed[208 +: 8] = rx8p_26;
    assign out_rx8p_bypass_packed[216 +: 8] = rx8p_27;
    assign out_rx8p_bypass_packed[224 +: 8] = rx8p_28;
    assign out_rx8p_bypass_packed[232 +: 8] = rx8p_29;
    assign out_rx8p_bypass_packed[240 +: 8] = rx8p_30;
    assign out_rx8p_bypass_packed[248 +: 8] = rx8p_31;
    end endgenerate

    function signed [15:0] lane16_from_fifo32;
        input [511:0] flat;
        input integer lane;
        integer group;
        integer local_lane;
        integer bit_base;
        begin
            group = lane / 8;
            local_lane = lane % 8;
            bit_base = ((3 - group) * 128) + (local_lane * 16);
            lane16_from_fifo32 = $signed(flat[bit_base +: 16]);
        end
    endfunction

    function signed [7:0] sat8_shift7;
        input signed [15:0] din;
        reg signed [15:0] shifted;
        begin
            shifted = din >>> 7;
            if (shifted > 16'sd127) begin
                sat8_shift7 = 8'sd127;
            end else if (shifted < -16'sd128) begin
                sat8_shift7 = -8'sd128;
            end else begin
                sat8_shift7 = shifted[7:0];
            end
        end
    endfunction

    genvar bypass_lane;
    generate
        for (bypass_lane = 0; bypass_lane < 32; bypass_lane = bypass_lane + 1) begin : GEN_BYPASS_PACK32
            assign out_rx8p_bypass_packed[(bypass_lane * 8) +: 8] =
                sat8_shift7(lane16_from_fifo32(in_data_16b, bypass_lane));
        end
    endgenerate
    // ------------------------------------------------------------------------
    // PAM4-only RX EQ + PR-metric MLSD detector path.
    // - Levels remain [-96, -32, 32, 96].
    // - Board default flow:
    //   ADC/FIFO 16b -> EQ21 -> sat8 -> detector_input/NP alias
    //   -> 32-symbol RS4 nearest-2 segment/min-plus prefix MLSD.
    // - PR taps are detector branch-metric coefficients. They are not the
    //   detector_input8/legacy-NP sample path.
    // - Legacy shape/NP debug names are kept only as route/ILA aliases.
    // - NRZ/PAM8 still bypass this path.
    // ------------------------------------------------------------------------
    wire                pam4_mlsd_in_valid;
    wire signed [255:0] pam4_raw8_dbg_packed;
    wire signed [255:0] pam4_eq8_dbg_packed;
    wire signed [255:0] pam4_shape8_dbg_packed;
    wire signed [255:0] pam4_np8_dbg_packed;
    wire signed [63:0]  pam4_det_np8_dbg_lanes8;
    wire [63:0]         pam4_eq8_negrail_bitmap;
    wire signed [255:0] pam4_mlsd_dout_flat;
    wire                pam4_mlsd_out_valid;
    wire                pam4_mlsd_accept_valid;
    wire [15:0]         pam4_mlsd_cand_count_sum;
    wire [63:0]         pam4_mlsd_dbg_ctrl_packed;
    wire [63:0]         pam4_mlsd_dbg_pm_packed;
    wire                pam4_trace_payload_valid_unused;
    wire [(4*10)-1:0]   pam4_trace_pm_end_debug_flat_unused;
    wire [(64*4*2)-1:0] pam4_trace_pred_cols_debug_flat_unused;
    wire [(64*2)-1:0]   pam4_trace_best_state_lane_debug_flat_unused;
    wire [63:0]         pam4_trace_decision_ready_debug_lane_unused;
    wire [7:0]          pam4_trace_fb_idx_next_debug_flat_unused;
    wire signed [7:0]   pam4_mlsd_dbg_raw0;
    wire signed [15:0]  pam4_mlsd_dbg_ch0;
    wire signed [7:0]   cfg_thr4_0_eff;
    wire signed [7:0]   cfg_thr4_1_eff;
    wire signed [7:0]   cfg_thr4_2_eff;
    reg [6:0]           mlsd_hist_m96;
    reg [6:0]           mlsd_hist_m32;
    reg [6:0]           mlsd_hist_p32;
    reg [6:0]           mlsd_hist_p96;
    reg [6:0]           mlsd_hist_other;
    reg [14:0]          mlsd_hist_acc_m96;
    reg [14:0]          mlsd_hist_acc_m32;
    reg [14:0]          mlsd_hist_acc_p32;
    reg [14:0]          mlsd_hist_acc_p96;
    reg [14:0]          mlsd_hist_acc_other;
    reg [14:0]          mlsd_hist_acc_total;
    reg [14:0]          mlsd_hist_snap_m96;
    reg [14:0]          mlsd_hist_snap_m32;
    reg [14:0]          mlsd_hist_snap_p32;
    reg [14:0]          mlsd_hist_snap_p96;
    reg                 mlsd_hist_acc_done;
    reg [63:0]          dbg_mlsd_hist_packed_r;
    reg [7:0]           predec_hist_bin0;
    reg [7:0]           predec_hist_bin1;
    reg [7:0]           predec_hist_bin2;
    reg [7:0]           predec_hist_bin3;
    reg signed [7:0]    predec_hist_sample;
    reg [63:0]          dbg_predec_hist_packed_r;
    integer             mlsd_hist_i;
    integer             predec_hist_i;

    localparam integer  PAM4_MLSD_ACTIVE_LANES = 32;
    localparam signed [7:0] PAM4_DEFAULT_THR4_0 = -8'sd64;
    localparam signed [7:0] PAM4_DEFAULT_THR4_1 =  8'sd0;
    localparam signed [7:0] PAM4_DEFAULT_THR4_2 =  8'sd64;
    localparam [14:0]   MLSD_HIST_FRAME_LANES = 15'd32;
    localparam [6:0]    MLSD_HIST_FRAME_LANES7 = 7'd32;
    localparam [14:0]   MLSD_HIST_FREEZE_TOTAL = 15'd16384;
    localparam [14:0]   MLSD_HIST_FREEZE_LAST_FRAME = MLSD_HIST_FREEZE_TOTAL - MLSD_HIST_FRAME_LANES;
    // Keep each ILA debug view at 64 bits by exposing one runtime-selected
    // 8-lane window. 0: lanes 0..7, ... 3: lanes 24..31.

    function [14:0] sat15_add7;
        input [14:0] a;
        input [6:0] b;
        reg [15:0] sum_ext;
        begin
            sum_ext = {1'b0, a} + {9'd0, b};
            sat15_add7 = sum_ext[15] ? 15'h7FFF : sum_ext[14:0];
        end
    endfunction

    function [63:0] pick_lane8_window;
        input [255:0] flat;
        input [2:0] group_sel;
        begin
            case (group_sel)
                3'd0: pick_lane8_window = flat[  0 +: 64];
                3'd1: pick_lane8_window = flat[ 64 +: 64];
                3'd2: pick_lane8_window = flat[128 +: 64];
                default: pick_lane8_window = flat[192 +: 64];
            endcase
        end
    endfunction

    wire pam4_mode_en;
    wire pam4_cfg_mlsd_path_en;
    wire pam4_core_path_en;
    wire pam4_main_route_is_mlsd;
    wire pam4_main_route_is_frontend;
    wire pam4_main_route_is_raw;
    wire pam4_frontend_valid;
    wire predec_hist_valid;
    wire [2:0] pam4_main_route_sel_eff;
    wire [2:0] pam4_default_main_route_sel;
    wire signed [255:0] pam4_fullrate_main_packed;
    wire signed [255:0] pam4_route_frontend_packed;
    wire signed [255:0] predec_hist_packed;
    reg [6:0] pam4_frontend_valid_pipe;
    reg signed [255:0] out_rx8p_mlsd_hold;
    wire signed [255:0] selected_rx8p_packed_pre;
    wire                selected_rx8p_valid_pre;
    wire                selected_path_is_mlsd_pre;
    wire [14:0]         mlsd_hist_acc_known;
    wire [6:0]          mlsd_hist_known;
    wire                mlsd_hist_acc_stale_all_other;
    reg signed [255:0] out_rx8p_mlsd_packed_q;
    reg signed [255:0] out_rx8p_packed_q;
    reg                 out_rx8p_valid_q;
    reg                 out_path_is_mlsd_q;
    reg                 mlsd_out_valid_q;
    reg [15:0]          mlsd_cand_count_sum_q;
    reg signed [63:0]  dbg_mlsd8_lanes8_q;
    reg                 pam4_diag_cfg_pm_sel_q;

    // Board RX detector: contribution-aligned 32-symbol RS4 nearest-2
    // segment/min-plus prefix MLSD through the trace32 adapter.
    localparam integer PAM4_RX_EQ_MAX_TAPS = 21;
    localparam integer PAM4_MLSD_NORMPREFIX_TRACE64_MET_W = 9;
    localparam integer PAM4_MLSD_BRANCH_METRIC_SHIFT = 1;
    // TRX candidate 32-lane trace timing profile. This mirrors the best OOC
    // post-place configuration from 2026-06-04 and intentionally leaves the
    // lane-select-second split disabled because it worsened post-place timing.
    localparam PAM4_MLSD_TRACE64_ENABLE_PAIR_NORMALIZE = 1'b0;
    localparam PAM4_MLSD_TRACE64_ENABLE_PAIR_OFFSET_COMPENSATION = 1'b0;
    localparam PAM4_MLSD_TRACE64_ENABLE_END_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_TILE_INPUT_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_LANE_XFORM_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_LANE_SELECT_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_TILE_LANE_SELECT_SECOND_PIPELINE_SPLIT = 1'b0;
    localparam PAM4_MLSD_TRACE64_ENABLE_TILE_PAIR_XFORM_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_TILE_QUAD_XFORM_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_TILE_BLOCK_XFORM_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_EXPORT_PAIR_QUAD_XFORM_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_TILE_START_PM_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_TILE_START_NORM_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_TILE_EVEN_PM_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_TILE_EVEN_NORM_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_TILE_ODD_PM_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_TILE_ODD_NORM_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_TILE_END_PM_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_TILE_END_NORM_PIPELINE_SPLIT = 1'b1;
    localparam PAM4_MLSD_TRACE64_ENABLE_TILE_END_EXPORT_PIPELINE_SPLIT = 1'b0;
    localparam PAM4_MLSD_TRACE64_ENABLE_TILE_PM_STATE_UPDATE = 1'b0;
    localparam PAM4_MLSD_TRACE64_ENABLE_TRACE_PM_HANDOFF_REG = 1'b0;
    localparam PAM4_MLSD_TRACE64_ENABLE_TRACE_ROW_OUTPUT_PIPELINE_SPLIT = 1'b1;
    // Diagnostic BER-tuned nearest-2 test build from analysis_rtl sweeps.
    // Keep disabled until matched-channel sanity BER is near zero; otherwise
    // the fitted coefficients can hide detector/TB ordering or metric issues.
    localparam PAM4_MLSD_USE_BER_TUNED_TEST_BUILD = 1'b0;
    // Active DS-SBMM setting: retain two branch survivors per previous state
    // in each segmented branch-metric tile. The 4-survivor value is kept only
    // for diagnostic/stress comparisons, not for the active board image.
    localparam integer PAM4_MLSD_DS_SBMM_SURVIVORS = 2;
    localparam integer PAM4_MLSD_STRESS_BRANCH_SURVIVORS = 4;
    localparam integer PAM4_MLSD_SEGMENT_BRANCH_SURVIVORS =
        PAM4_MLSD_USE_BER_TUNED_TEST_BUILD
            ? PAM4_MLSD_STRESS_BRANCH_SURVIVORS
            : PAM4_MLSD_DS_SBMM_SURVIVORS;
    localparam PAM4_MLSD_USE_TB_TUNED_COEFFS =
        PAM4_MLSD_USE_BER_TUNED_TEST_BUILD;
    // PR taps are detector metric coefficients in Q_SHIFT=8 scale. Use
    // g0=256,g1=0,g2=0 for a memoryless identity sanity run; g0=64 is a
    // quarter-scale metric tap, not identity.
    localparam signed [11:0] PAM4_MLSD_G0_Q8 =
        PAM4_MLSD_USE_TB_TUNED_COEFFS ? 12'sd64 : 12'sd256;
    localparam signed [11:0] PAM4_MLSD_G1_Q8 =
        PAM4_MLSD_USE_TB_TUNED_COEFFS ? 12'sd70 : 12'sd0;
    localparam signed [11:0] PAM4_MLSD_G2_Q8 =
        PAM4_MLSD_USE_TB_TUNED_COEFFS ? 12'sd0 : 12'sd0;
    localparam signed [(21*8)-1:0] PAM4_MLSD_TB_TUNED_EQ_COEFFS = {
        {(20*8){1'b0}},
        8'sd64
    };

    wire pam4_eq_override_eff = PAM4_MLSD_USE_TB_TUNED_COEFFS ? 1'b1 : cfg_rx_eq_override_en;
    wire signed [(21*8)-1:0] pam4_eq_coeffs_eff =
        PAM4_MLSD_USE_TB_TUNED_COEFFS ? PAM4_MLSD_TB_TUNED_EQ_COEFFS : cfg_rx_eq_coeffs_flat;

    // Board RX default: select the MLSD route. The active contribution-aligned
    // 32-symbol prefix path accepts a continuous stream and produces II=1
    // detector frames after the prefix/trace pipeline fill latency.
    localparam PAM4_MAIN_USE_FULLRATE_MLSD = 1'b1;
    localparam [1:0] PAM4_FULLRATE_STAGE_RAW8  = 2'd0;
    localparam [1:0] PAM4_FULLRATE_STAGE_EQ8   = 2'd1;
    // SHAPE is retained only as a legacy debug/route alias; in the active
    // normprefix path, SHAPE and NP both mean the detector_input8 bus.
    localparam [1:0] PAM4_FULLRATE_STAGE_SHAPE = 2'd2;
    // Legacy NP route name: detector_input8 sample bus, not PR taps.
    localparam [1:0] PAM4_FULLRATE_STAGE_NP    = 2'd3;
    localparam [1:0] PAM4_MAIN_FULLRATE_STAGE  = PAM4_FULLRATE_STAGE_EQ8;
    localparam [2:0] PAM4_MAIN_ROUTE_RAW8      = 3'd0;
    localparam [2:0] PAM4_MAIN_ROUTE_EQ8       = 3'd1;
    localparam [2:0] PAM4_MAIN_ROUTE_SHAPE     = 3'd2;
    localparam [2:0] PAM4_MAIN_ROUTE_NP        = 3'd3;
    localparam [2:0] PAM4_MAIN_ROUTE_MLSD      = 3'd4;
    localparam         PAM4_EQ_USE_TRANSPOSED = 1'b1;
    localparam integer PAM4_EQ_ACTIVE_IN_W = 16;
    // ILA7 probe4 debug mux without changing RX/MLSD function:
    // 0 = live detector-input8[63:0], 1 = EQ8[127:64],
    // 2 = per-lane EQ8 == 8'h80 (-128) bitmap,
    // 3 = legacy shape8[63:0] alias of detector_input8,
    // 4 = detector_input8[63:0] (legacy NP8 name, not PR taps),
    // 5 = detector runtime config summary:
    //     byte0..3 = effective PAM4 levels L0..L3,
    //     byte4..6 = PR taps g0..g2 truncated to signed 8b,
    //     byte7 = {mode[1:0], thr_ovr, pr2_ovf, pr1_ovf, pr0_ovf, level_ovr, pr_ovr}.
    // 6 = pre-detector histogram summary:
    //     byte0..3 = bin counts under cfg_thr4_0/1/2, byte4..6 = active thresholds,
    //     byte7 = {route_ovr, route_sel[2:0], 3'd0, predec_hist_valid}.
    // 7 = MLSD control summary:
    //     trace adapter: byte7=accept_count, byte6=drop_count,
    //     byte5:4=best_state lanes0..7 packed 2b/lane, byte3=decision_ready[7:0],
    //     byte2=fb_idx_next, byte1={fullrate_pipe_reserved[7:0]},
    //     byte0={fifo_overflow_sticky,adapter_busy,trace_out_valid,
    //     trace_launch_fire,real_xform_valid,frontend_launch,input_accept,decision_ready0}.
    //     chunked mode: word[63:48]=fifo_fill_count, [47:32]=cand_count_sum,
    //     byte3=segment_count, byte2=capture_count, byte1=replay_skip_count,
    //     byte0={fifo_overflow,fifo_valid,in_ready,stage_load,capture_active,replay_active,in_valid,out_valid}.
    // 8 = MLSD path metric summary: word[63:48]=pm3, [47:32]=pm2, [31:16]=pm1, [15:0]=pm0.
    // 9 = alternating detector config summary and MLSD path metric summary.
    // Board bring-up debug: export compact MLSD/front-end observability to ILA.
    // Disable these after root-cause isolation if implementation margin is tight.
    localparam         PAM4_DEBUG_OUTPUTS_EN = 1'b1;
    localparam [3:0]   PAM4_ILA7_PROBE4_SEL = 4'd0;
    localparam         PAM4_DEBUG_ILA7_PROBE1_SHOW_MLSD8 = 1'b0;
    localparam         PAM4_DEBUG_EXPORT_MLSD_INTERNALS = 1'b1;
    localparam         PAM4_DEBUG_ENABLE_HISTOGRAMS = 1'b0;

    wire signed [11:0] pam4_pr0_dbg = cfg_rx_pr_taps_flat[11:0];
    wire signed [11:0] pam4_pr1_dbg = cfg_rx_pr_taps_flat[23:12];
    wire signed [11:0] pam4_pr2_dbg = cfg_rx_pr_taps_flat[35:24];
    wire               pam4_pr0_s8_ovf_dbg = (pam4_pr0_dbg > 12'sd127) || (pam4_pr0_dbg < -12'sd128);
    wire               pam4_pr1_s8_ovf_dbg = (pam4_pr1_dbg > 12'sd127) || (pam4_pr1_dbg < -12'sd128);
    wire               pam4_pr2_s8_ovf_dbg = (pam4_pr2_dbg > 12'sd127) || (pam4_pr2_dbg < -12'sd128);
    wire signed [7:0]  pam4_l0_eff_dbg = cfg_rx_level_override_en ? $signed(cfg_rx_pam4_levels_flat[7:0])   : -8'sd96;
    wire signed [7:0]  pam4_l1_eff_dbg = cfg_rx_level_override_en ? $signed(cfg_rx_pam4_levels_flat[15:8])  : -8'sd32;
    wire signed [7:0]  pam4_l2_eff_dbg = cfg_rx_level_override_en ? $signed(cfg_rx_pam4_levels_flat[23:16]) :  8'sd32;
    wire signed [7:0]  pam4_l3_eff_dbg = cfg_rx_level_override_en ? $signed(cfg_rx_pam4_levels_flat[31:24]) :  8'sd96;
    wire [7:0]         pam4_detector_cfg_flags_dbg = {mode[1:0],
                                                      cfg_rx_thr_override_en,
                                                      pam4_pr2_s8_ovf_dbg,
                                                      pam4_pr1_s8_ovf_dbg,
                                                      pam4_pr0_s8_ovf_dbg,
                                                      cfg_rx_level_override_en,
                                                      cfg_rx_pr_override_en};
    wire [63:0]        pam4_detector_cfg_dbg_packed = {pam4_detector_cfg_flags_dbg,
                                                       pam4_pr2_dbg[7:0],
                                                       pam4_pr1_dbg[7:0],
                                                       pam4_pr0_dbg[7:0],
                                                       pam4_l3_eff_dbg,
                                                       pam4_l2_eff_dbg,
                                                       pam4_l1_eff_dbg,
                                                       pam4_l0_eff_dbg};
    wire [63:0]        pam4_mlsd_dbg_ctrl_export = PAM4_DEBUG_EXPORT_MLSD_INTERNALS
                                                       ? pam4_mlsd_dbg_ctrl_packed
                                                       : 64'd0;
    wire [63:0]        pam4_mlsd_dbg_pm_export = PAM4_DEBUG_EXPORT_MLSD_INTERNALS
                                                       ? pam4_mlsd_dbg_pm_packed
                                                       : 64'd0;
    wire [63:0]        pam4_detector_cfg_pm_dbg_packed = pam4_diag_cfg_pm_sel_q
                                                       ? pam4_mlsd_dbg_pm_export
                                                       : pam4_detector_cfg_dbg_packed;

    assign pam4_mode_en        = (mode == 2'b01);
    assign pam4_cfg_mlsd_path_en = cfg_use_mlsd && pam4_mode_en;
    assign pam4_default_main_route_sel = !pam4_cfg_mlsd_path_en             ? PAM4_MAIN_ROUTE_RAW8 :
                                         PAM4_MAIN_USE_FULLRATE_MLSD        ? PAM4_MAIN_ROUTE_MLSD :
                                         {1'b0, PAM4_MAIN_FULLRATE_STAGE};
    assign pam4_main_route_sel_eff = cfg_rx_main_route_override_en ? cfg_rx_main_route_sel
                                                                  : pam4_default_main_route_sel;
    assign pam4_main_route_is_raw = (pam4_main_route_sel_eff == PAM4_MAIN_ROUTE_RAW8);
    assign pam4_main_route_is_mlsd = (pam4_main_route_sel_eff == PAM4_MAIN_ROUTE_MLSD);
    assign pam4_main_route_is_frontend = pam4_mode_en && !pam4_main_route_is_raw && !pam4_main_route_is_mlsd;
    assign pam4_core_path_en = pam4_mode_en &&
                               (cfg_use_mlsd || rx_ffe_en ||
                                (cfg_rx_main_route_override_en && !pam4_main_route_is_raw));
    assign pam4_mlsd_in_valid  = aresetn && in_data_valid && pam4_core_path_en;
    assign out_rx8p_mlsd_packed = out_rx8p_mlsd_packed_q;
    assign out_path_is_mlsd    = out_path_is_mlsd_q;
    assign mlsd_out_valid      = mlsd_out_valid_q;
    assign mlsd_accept_valid   = pam4_mlsd_accept_valid;
    assign mlsd_cand_count_sum = PAM4_DEBUG_OUTPUTS_EN ? mlsd_cand_count_sum_q : 16'd0;
    assign mlsd_ps_expand_sum  = 8'd0;
    assign mlsd_ns_expand_sum  = 8'd0;
    assign dbg_raw8_lanes8     = pick_lane8_window(pam4_raw8_dbg_packed, cfg_rx_mlsd_dbg_group_sel);
    assign dbg_eq8_lanes8      = pick_lane8_window(pam4_eq8_dbg_packed, cfg_rx_mlsd_dbg_group_sel);
    assign dbg_eq8_packed_full = pam4_eq8_dbg_packed;
    assign dbg_shape8_lanes8   = pick_lane8_window(pam4_shape8_dbg_packed, cfg_rx_mlsd_dbg_group_sel);
    assign dbg_np8_lanes8      = pick_lane8_window(pam4_np8_dbg_packed, cfg_rx_mlsd_dbg_group_sel);
    assign dbg_det_np8_lanes8  = pick_lane8_window(pam4_np8_dbg_packed, cfg_rx_mlsd_dbg_group_sel);
    assign dbg_mlsd8_lanes8    = dbg_mlsd8_lanes8_q;
    assign dbg_mlsd_hist_packed = dbg_mlsd_hist_packed_r;
    assign dbg_predec_hist_packed = dbg_predec_hist_packed_r;
    assign dbg_mlsd_ctrl_packed = pam4_mlsd_dbg_ctrl_export;
    assign dbg_mlsd_pm_packed   = pam4_mlsd_dbg_pm_export;
    assign dbg_raw0            = pam4_mlsd_dbg_raw0;
    assign dbg_ch0             = pam4_mlsd_dbg_ch0;
    assign pam4_frontend_valid = (in_data_valid && pam4_core_path_en) &&
                                 (PAM4_EQ_USE_TRANSPOSED ? pam4_frontend_valid_pipe[6]
                                                         : pam4_frontend_valid_pipe[1]);
    assign pam4_fullrate_main_packed =
                                (PAM4_MAIN_FULLRATE_STAGE == PAM4_FULLRATE_STAGE_RAW8)  ? pam4_raw8_dbg_packed   :
                                (PAM4_MAIN_FULLRATE_STAGE == PAM4_FULLRATE_STAGE_SHAPE) ? pam4_shape8_dbg_packed :
                                (PAM4_MAIN_FULLRATE_STAGE == PAM4_FULLRATE_STAGE_NP)    ? pam4_np8_dbg_packed    :
                                                                                          pam4_eq8_dbg_packed;
    assign pam4_route_frontend_packed =
                                (pam4_main_route_sel_eff == PAM4_MAIN_ROUTE_SHAPE) ? pam4_shape8_dbg_packed :
                                (pam4_main_route_sel_eff == PAM4_MAIN_ROUTE_NP)    ? pam4_np8_dbg_packed    :
                                                                                      pam4_eq8_dbg_packed;
    assign predec_hist_valid    = pam4_main_route_is_frontend ? pam4_frontend_valid
                                                              : (out_rx8p_valid && pam4_mode_en);
    assign predec_hist_packed   = pam4_main_route_is_frontend ? pam4_route_frontend_packed
                                                              : out_rx8p_packed;
    assign selected_rx8p_valid_pre = pam4_main_route_is_mlsd     ? pam4_mlsd_out_valid
                                     : pam4_main_route_is_frontend ? pam4_frontend_valid
                                                                  : (aresetn && in_data_valid);
    assign selected_rx8p_packed_pre = pam4_main_route_is_mlsd
                                     ? (pam4_mlsd_out_valid ? pam4_mlsd_dout_flat : out_rx8p_mlsd_hold)
                                     : (pam4_main_route_is_frontend ? pam4_route_frontend_packed : out_rx8p_bypass_packed);
    assign selected_path_is_mlsd_pre = pam4_main_route_is_mlsd && pam4_mlsd_out_valid;
    assign out_rx8p_valid      = out_rx8p_valid_q;
    assign out_rx8p_packed     = out_rx8p_packed_q;
    assign cfg_thr4_0_eff      = (cfg_rx_thr_override_en === 1'b1) ? $signed(cfg_rx_thr4_flat[7:0])   : PAM4_DEFAULT_THR4_0;
    assign cfg_thr4_1_eff      = (cfg_rx_thr_override_en === 1'b1) ? $signed(cfg_rx_thr4_flat[15:8])  : PAM4_DEFAULT_THR4_1;
    assign cfg_thr4_2_eff      = (cfg_rx_thr_override_en === 1'b1) ? $signed(cfg_rx_thr4_flat[23:16]) : PAM4_DEFAULT_THR4_2;
    assign mlsd_hist_acc_known = (PAM4_DEBUG_ENABLE_HISTOGRAMS &&
                                  (mlsd_hist_acc_total >= mlsd_hist_acc_other))
                               ? (mlsd_hist_acc_total - mlsd_hist_acc_other)
                               : 15'd0;
    assign mlsd_hist_known     = PAM4_DEBUG_ENABLE_HISTOGRAMS
                               ? (mlsd_hist_m96 + mlsd_hist_m32 + mlsd_hist_p32 + mlsd_hist_p96)
                               : 7'd0;
    assign mlsd_hist_acc_stale_all_other =
        PAM4_DEBUG_ENABLE_HISTOGRAMS &&
        mlsd_hist_acc_done &&
        (mlsd_hist_acc_total == MLSD_HIST_FREEZE_TOTAL) &&
        (mlsd_hist_acc_other == MLSD_HIST_FREEZE_TOTAL) &&
        (mlsd_hist_acc_known == 15'd0) &&
        (mlsd_hist_known == MLSD_HIST_FRAME_LANES7);

    genvar eq8_dbg_lane;
    assign pam4_eq8_negrail_bitmap[63:32] = 32'd0;
    generate
        for (eq8_dbg_lane = 0; eq8_dbg_lane < 32; eq8_dbg_lane = eq8_dbg_lane + 1) begin : GEN_EQ8_NEGRAIL_BITMAP
            assign pam4_eq8_negrail_bitmap[eq8_dbg_lane] =
                ($signed(pam4_eq8_dbg_packed[(eq8_dbg_lane*8) +: 8]) == 8'sh80);
        end
    endgenerate

    always @* begin
        mlsd_hist_m96   = 7'd0;
        mlsd_hist_m32   = 7'd0;
        mlsd_hist_p32   = 7'd0;
        mlsd_hist_p96   = 7'd0;
        mlsd_hist_other = 7'd0;

        // Count the exact MLSD frame emitted by the detector. The registered
        // dbg_mlsd8_lanes8 signal exposes the selected 8-lane window from this
        // same frame without routing all 512 bits into the ILA.
        if (PAM4_DEBUG_ENABLE_HISTOGRAMS && pam4_mlsd_out_valid) begin
            for (mlsd_hist_i = 0; mlsd_hist_i < PAM4_MLSD_ACTIVE_LANES; mlsd_hist_i = mlsd_hist_i + 1) begin
                case (pam4_mlsd_dout_flat[(mlsd_hist_i*8) +: 8])
                    8'hA0: mlsd_hist_m96   = mlsd_hist_m96 + 7'd1; // -96
                    8'hE0: mlsd_hist_m32   = mlsd_hist_m32 + 7'd1; // -32
                    8'h20: mlsd_hist_p32   = mlsd_hist_p32 + 7'd1; // +32
                    8'h60: mlsd_hist_p96   = mlsd_hist_p96 + 7'd1; // +96
                    default: mlsd_hist_other = mlsd_hist_other + 7'd1;
                endcase
            end
        end
    end

    always @* begin
        predec_hist_bin0 = 8'd0;
        predec_hist_bin1 = 8'd0;
        predec_hist_bin2 = 8'd0;
        predec_hist_bin3 = 8'd0;
        predec_hist_sample = 8'sd0;

        if (PAM4_DEBUG_ENABLE_HISTOGRAMS && predec_hist_valid && (mode == 2'b01)) begin
            for (predec_hist_i = 0; predec_hist_i < PAM4_MLSD_ACTIVE_LANES; predec_hist_i = predec_hist_i + 1) begin
                predec_hist_sample = predec_hist_packed[(predec_hist_i*8) +: 8];
                if (predec_hist_sample < cfg_thr4_0_eff) begin
                    predec_hist_bin0 = predec_hist_bin0 + 8'd1;
                end else if (predec_hist_sample < cfg_thr4_1_eff) begin
                    predec_hist_bin1 = predec_hist_bin1 + 8'd1;
                end else if (predec_hist_sample < cfg_thr4_2_eff) begin
                    predec_hist_bin2 = predec_hist_bin2 + 8'd1;
                end else begin
                    predec_hist_bin3 = predec_hist_bin3 + 8'd1;
                end
            end
        end
    end

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            out_rx8p_mlsd_hold <= 256'sd0;
            out_rx8p_mlsd_packed_q <= 256'sd0;
            out_rx8p_packed_q <= 256'sd0;
            out_rx8p_valid_q <= 1'b0;
            out_path_is_mlsd_q <= 1'b0;
            mlsd_out_valid_q <= 1'b0;
            mlsd_cand_count_sum_q <= 16'd0;
            dbg_mlsd8_lanes8_q <= 64'sd0;
            pam4_diag_cfg_pm_sel_q <= 1'b0;
            pam4_frontend_valid_pipe <= 7'b0000000;
            mlsd_hist_acc_m96 <= 15'd0;
            mlsd_hist_acc_m32 <= 15'd0;
            mlsd_hist_acc_p32 <= 15'd0;
            mlsd_hist_acc_p96 <= 15'd0;
            mlsd_hist_acc_other <= 15'd0;
            mlsd_hist_acc_total <= 15'd0;
            mlsd_hist_snap_m96 <= 15'd0;
            mlsd_hist_snap_m32 <= 15'd0;
            mlsd_hist_snap_p32 <= 15'd0;
            mlsd_hist_snap_p96 <= 15'd0;
            mlsd_hist_acc_done <= 1'b0;
            dbg_mlsd_hist_packed_r <= 64'd0;
            dbg_predec_hist_packed_r <= 64'd0;
        end else begin
            pam4_diag_cfg_pm_sel_q <= (PAM4_DEBUG_OUTPUTS_EN && pam4_main_route_is_mlsd)
                                     ? ~pam4_diag_cfg_pm_sel_q
                                     : 1'b0;

            if (!PAM4_DEBUG_ENABLE_HISTOGRAMS) begin
                mlsd_hist_acc_m96 <= 15'd0;
                mlsd_hist_acc_m32 <= 15'd0;
                mlsd_hist_acc_p32 <= 15'd0;
                mlsd_hist_acc_p96 <= 15'd0;
                mlsd_hist_acc_other <= 15'd0;
                mlsd_hist_acc_total <= 15'd0;
                mlsd_hist_snap_m96 <= 15'd0;
                mlsd_hist_snap_m32 <= 15'd0;
                mlsd_hist_snap_p32 <= 15'd0;
                mlsd_hist_snap_p96 <= 15'd0;
                mlsd_hist_acc_done <= 1'b0;
                dbg_mlsd_hist_packed_r <= 64'd0;
                dbg_predec_hist_packed_r <= 64'd0;
            end else if (!pam4_main_route_is_mlsd || mlsd_hist_acc_stale_all_other) begin
                mlsd_hist_acc_m96 <= 15'd0;
                mlsd_hist_acc_m32 <= 15'd0;
                mlsd_hist_acc_p32 <= 15'd0;
                mlsd_hist_acc_p96 <= 15'd0;
                mlsd_hist_acc_other <= 15'd0;
                mlsd_hist_acc_total <= 15'd0;
                mlsd_hist_snap_m96 <= 15'd0;
                mlsd_hist_snap_m32 <= 15'd0;
                mlsd_hist_snap_p32 <= 15'd0;
                mlsd_hist_snap_p96 <= 15'd0;
                mlsd_hist_acc_done <= 1'b0;
            end else if (pam4_mlsd_out_valid) begin
                if (mlsd_hist_acc_total >= MLSD_HIST_FREEZE_LAST_FRAME) begin
                    mlsd_hist_snap_m96 <= sat15_add7(mlsd_hist_acc_m96, mlsd_hist_m96);
                    mlsd_hist_snap_m32 <= sat15_add7(mlsd_hist_acc_m32, mlsd_hist_m32);
                    mlsd_hist_snap_p32 <= sat15_add7(mlsd_hist_acc_p32, mlsd_hist_p32);
                    mlsd_hist_snap_p96 <= sat15_add7(mlsd_hist_acc_p96, mlsd_hist_p96);
                    mlsd_hist_acc_m96 <= 15'd0;
                    mlsd_hist_acc_m32 <= 15'd0;
                    mlsd_hist_acc_p32 <= 15'd0;
                    mlsd_hist_acc_p96 <= 15'd0;
                    mlsd_hist_acc_other <= 15'd0;
                    mlsd_hist_acc_total <= 15'd0;
                    mlsd_hist_acc_done <= 1'b1;
                end else begin
                    mlsd_hist_acc_m96 <= sat15_add7(mlsd_hist_acc_m96, mlsd_hist_m96);
                    mlsd_hist_acc_m32 <= sat15_add7(mlsd_hist_acc_m32, mlsd_hist_m32);
                    mlsd_hist_acc_p32 <= sat15_add7(mlsd_hist_acc_p32, mlsd_hist_p32);
                    mlsd_hist_acc_p96 <= sat15_add7(mlsd_hist_acc_p96, mlsd_hist_p96);
                    mlsd_hist_acc_other <= sat15_add7(mlsd_hist_acc_other, mlsd_hist_other);
                    mlsd_hist_acc_total <= mlsd_hist_acc_total + MLSD_HIST_FRAME_LANES;
                end
            end
            out_rx8p_valid_q <= selected_rx8p_valid_pre;
            out_path_is_mlsd_q <= selected_path_is_mlsd_pre;
            mlsd_out_valid_q <= pam4_main_route_is_mlsd && pam4_mlsd_out_valid;
            if (selected_rx8p_valid_pre) begin
                out_rx8p_packed_q <= selected_rx8p_packed_pre;
            end
            if (PAM4_DEBUG_ENABLE_HISTOGRAMS) begin
                dbg_mlsd_hist_packed_r <= {
                                    3'b111,
                                    mlsd_hist_acc_done,
                                    mlsd_hist_snap_p96,
                                    mlsd_hist_snap_p32,
                                    mlsd_hist_snap_m32,
                                    mlsd_hist_snap_m96
                                };
                dbg_predec_hist_packed_r <= {
                                    cfg_rx_main_route_override_en,
                                    pam4_main_route_sel_eff,
                                    3'd0,
                                    predec_hist_valid && (mode == 2'b01),
                                    cfg_thr4_2_eff,
                                    cfg_thr4_1_eff,
                                    cfg_thr4_0_eff,
                                    predec_hist_bin3,
                                    predec_hist_bin2,
                                    predec_hist_bin1,
                                    predec_hist_bin0
                                };
            end
            if (pam4_mlsd_out_valid) begin
                out_rx8p_mlsd_hold <= pam4_mlsd_dout_flat;
                out_rx8p_mlsd_packed_q <= pam4_mlsd_dout_flat;
                mlsd_cand_count_sum_q <= pam4_mlsd_cand_count_sum;
                if (PAM4_DEBUG_OUTPUTS_EN) begin
                    dbg_mlsd8_lanes8_q <= pick_lane8_window(pam4_mlsd_dout_flat,
                                                             cfg_rx_mlsd_dbg_group_sel);
                end else begin
                    dbg_mlsd8_lanes8_q <= 64'sd0;
                end
            end else if (!pam4_main_route_is_mlsd) begin
                mlsd_cand_count_sum_q <= 16'd0;
            end
            if (in_data_valid && pam4_core_path_en) begin
                pam4_frontend_valid_pipe <= {pam4_frontend_valid_pipe[5:0], 1'b1};
            end
        end
    end

    // Detector path. Capture-replay is not used for the performance path.
    wire [(4*PAM4_MLSD_NORMPREFIX_TRACE64_MET_W)-1:0]
                         pam4_trace_pm_end_debug_flat32_unused;
    wire [(32*4*2)-1:0] pam4_trace_pred_cols_debug_flat32_unused;
    wire [(32*2)-1:0]   pam4_trace_best_state_lane_debug_flat32_unused;
    wire [31:0]         pam4_trace_decision_ready_debug_lane32_unused;

            assign pam4_trace_pm_end_debug_flat_unused =
                {{(4*(10-PAM4_MLSD_NORMPREFIX_TRACE64_MET_W)){1'b0}},
                 pam4_trace_pm_end_debug_flat32_unused};
            assign pam4_trace_pred_cols_debug_flat_unused =
                {{(32*4*2){1'b0}}, pam4_trace_pred_cols_debug_flat32_unused};
            assign pam4_trace_best_state_lane_debug_flat_unused =
                {{(32*2){1'b0}}, pam4_trace_best_state_lane_debug_flat32_unused};
            assign pam4_trace_decision_ready_debug_lane_unused =
                {32'd0, pam4_trace_decision_ready_debug_lane32_unused};
            assign pam4_shape8_dbg_packed = pam4_np8_dbg_packed;

            codex_pam4_rs4_trace32_board_adapter_normprefix_contract #(
                .TB(32),
                .MET_W(PAM4_MLSD_NORMPREFIX_TRACE64_MET_W),
                .Q_SHIFT(8),
                .SEGMENT_BRANCH_SURVIVORS(PAM4_MLSD_SEGMENT_BRANCH_SURVIVORS),
                .USE_L1_BRANCH_METRIC(1'b1),
                .BRANCH_METRIC_SHIFT(PAM4_MLSD_BRANCH_METRIC_SHIFT),
                .ENABLE_PAIR_NORMALIZE(PAM4_MLSD_TRACE64_ENABLE_PAIR_NORMALIZE),
                .ENABLE_PAIR_OFFSET_COMPENSATION(PAM4_MLSD_TRACE64_ENABLE_PAIR_OFFSET_COMPENSATION),
                .ENABLE_END_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_END_PIPELINE_SPLIT),
                .ENABLE_TILE_INPUT_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_TILE_INPUT_PIPELINE_SPLIT),
                .ENABLE_LANE_XFORM_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_LANE_XFORM_PIPELINE_SPLIT),
                .ENABLE_LANE_SELECT_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_LANE_SELECT_PIPELINE_SPLIT),
                .ENABLE_TILE_LANE_SELECT_SECOND_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_TILE_LANE_SELECT_SECOND_PIPELINE_SPLIT),
                .ENABLE_TILE_PAIR_XFORM_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_TILE_PAIR_XFORM_PIPELINE_SPLIT),
                .ENABLE_TILE_QUAD_XFORM_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_TILE_QUAD_XFORM_PIPELINE_SPLIT),
                .ENABLE_TILE_BLOCK_XFORM_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_TILE_BLOCK_XFORM_PIPELINE_SPLIT),
                .ENABLE_EXPORT_PAIR_QUAD_XFORM_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_EXPORT_PAIR_QUAD_XFORM_PIPELINE_SPLIT),
                .ENABLE_TILE_START_PM_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_TILE_START_PM_PIPELINE_SPLIT),
                .ENABLE_TILE_START_NORM_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_TILE_START_NORM_PIPELINE_SPLIT),
                .ENABLE_TILE_EVEN_PM_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_TILE_EVEN_PM_PIPELINE_SPLIT),
                .ENABLE_TILE_EVEN_NORM_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_TILE_EVEN_NORM_PIPELINE_SPLIT),
                .ENABLE_TILE_ODD_PM_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_TILE_ODD_PM_PIPELINE_SPLIT),
                .ENABLE_TILE_ODD_NORM_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_TILE_ODD_NORM_PIPELINE_SPLIT),
                .ENABLE_TILE_END_PM_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_TILE_END_PM_PIPELINE_SPLIT),
                .ENABLE_TILE_END_NORM_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_TILE_END_NORM_PIPELINE_SPLIT),
                .ENABLE_TILE_END_EXPORT_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_TILE_END_EXPORT_PIPELINE_SPLIT),
                .ENABLE_TILE_PM_STATE_UPDATE(PAM4_MLSD_TRACE64_ENABLE_TILE_PM_STATE_UPDATE),
                .ENABLE_TRACE_PM_HANDOFF_REG(PAM4_MLSD_TRACE64_ENABLE_TRACE_PM_HANDOFF_REG),
                .ENABLE_TRACE_ROW_OUTPUT_PIPELINE_SPLIT(PAM4_MLSD_TRACE64_ENABLE_TRACE_ROW_OUTPUT_PIPELINE_SPLIT),
                .ENABLE_DEBUG_OUTPUTS(PAM4_DEBUG_OUTPUTS_EN),
                .G0_Q8(PAM4_MLSD_G0_Q8),
                .G1_Q8(PAM4_MLSD_G1_Q8),
                .G2_Q8(PAM4_MLSD_G2_Q8)
            ) u_pam4_normprefix_core (
                .clk(aclk),
                .rst_n(aresetn),
                .in_valid(pam4_mlsd_in_valid),
                .ch_case_sel(ch_case_sel),
                .in_data_16b(in_data_16b),
                .cfg_eq_override_en(pam4_eq_override_eff),
                .cfg_eq_coeffs_flat(pam4_eq_coeffs_eff),
                .cfg_pr_override_en(cfg_rx_pr_override_en),
                .cfg_pr_taps_flat(cfg_rx_pr_taps_flat),
                .cfg_level_override_en(cfg_rx_level_override_en),
                .cfg_pam4_levels_flat(cfg_rx_pam4_levels_flat),
                .raw8_packed(pam4_raw8_dbg_packed),
                .eq8_packed(pam4_eq8_dbg_packed),
                .detector_input8_packed(pam4_np8_dbg_packed),
                .dbg_detector_input8_lanes8(pam4_det_np8_dbg_lanes8),
                .dout_flat(pam4_mlsd_dout_flat),
                .out_valid(pam4_mlsd_out_valid),
                .cand_count_sum(pam4_mlsd_cand_count_sum),
                .dbg_raw0(pam4_mlsd_dbg_raw0),
                .dbg_ch0(pam4_mlsd_dbg_ch0),
                .dbg_mlsd_ctrl_packed(pam4_mlsd_dbg_ctrl_packed),
                .dbg_mlsd_pm_packed(pam4_mlsd_dbg_pm_packed),
                .trace_payload_valid(pam4_trace_payload_valid_unused),
                .trace_pm_end_debug_flat(pam4_trace_pm_end_debug_flat32_unused),
                .trace_pred_cols_debug_flat(pam4_trace_pred_cols_debug_flat32_unused),
                .trace_best_state_lane_debug_flat(pam4_trace_best_state_lane_debug_flat32_unused),
                .trace_decision_ready_debug_lane(pam4_trace_decision_ready_debug_lane32_unused),
                .trace_fb_idx_next_debug_flat(pam4_trace_fb_idx_next_debug_flat_unused),
                .detector_accept_valid(pam4_mlsd_accept_valid)
            );

endmodule
