`timescale 1ns/1ps
// ============================================================================
// rx_bd_shim_raw1024_to_bitplanes_rxdsp8b
// - In-place patched wrapper for RS4 top-k-prune detector integration
// - Keeps the original module name for BD/module reference stability
// - Adds cfg_use_mlsd and reuses the existing channel-select path as ch_case_sel
// - Uses the fit-first shim implementation while keeping PRBS bitplane export
//   in the separate checker module_ref.
// - Integrates RX BRAM-backed coefficient loading directly in this existing BD
//   cell so the design can keep the same module_ref.
// - PRBSCHK owns the RX bitplane/threshold path; the shim keeps only RX8P data.
// - rx_data_valid is the FIFO read handshake in the RX clock domain. It is
//   delayed by the FIFO read latency before it gates MLSD/checker progress.
// - The board FIFO provides 512b = 32x16b and this wrapper passes that word
//   directly into the active 32-lane RX/MLSD implementation.
// ============================================================================

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: DAC/ADC DSP-Based PAM4 Transceiver
// Module Name: rx_bd_shim_raw1024_to_bitplanes_rxdsp8b
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Bridges the 1024-bit RX BD stream to 8-bit RX DSP processing and debug capture paths.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module rx_bd_shim_raw1024_to_bitplanes_rxdsp8b (
    input  wire          aclk,
    input  wire          aresetn,

    input  wire [1:0]    mode,
    input  wire          rx_ffe_en,
    input  wire [63:0]   rx_h_flat,
    input  wire          cfg_use_mlsd,
    input  wire [1:0]    ch_case_sel,
    input  wire [511:0]  in_data_16b,
    input  wire          rx_data_valid,
    output wire [31:0]   cfg_rx_coeff_active_commit_seq,
    output wire [31:0]   rxcfg_bram_addr,
    output wire          rxcfg_bram_en,
    output wire [3:0]    rxcfg_bram_we,
    output wire [31:0]   rxcfg_bram_wrdata,
    input  wire [31:0]   rxcfg_bram_rddata,
    output wire          decision_valid,
    output wire          mlsd_accept_valid,
    output wire [23:0]   rx_thr4_flat_eff,
    output wire signed [7:0] rx_thr4_0_eff,
    output wire signed [7:0] rx_thr4_1_eff,
    output wire signed [7:0] rx_thr4_2_eff,

    output wire signed [255:0] out_rx8p_packed,
    output wire signed [63:0] dbg_eq8_lanes8,
    output wire signed [63:0] dbg_det_np8_lanes8,
    output wire signed [63:0] dbg_mlsd8_lanes8,
    output wire [63:0]   dbg_mlsd_ctrl_packed,
    output wire [63:0]   dbg_mlsd_pm_packed,
    output wire          dbg_mlsd_valid,
    output wire [15:0]   dbg_mlsd_cand_count_sum,
    output wire [63:0]   dbg_rx_stream_state
);

    localparam RX_RUNTIME_EQ_OVERRIDE_EN      = 1'b1;
    localparam RX_RUNTIME_PR_OVERRIDE_EN      = 1'b1;
    localparam RX_RUNTIME_LEVEL_OVERRIDE_EN   = 1'b1;
    localparam RX_RUNTIME_THR_OVERRIDE_EN     = 1'b1;
    localparam RX_RUNTIME_MLSD_DBG_GROUP_OVERRIDE_EN = 1'b1;
    // Capture a compact MLSD debug frame for offline UART/CSV diagnosis.
    // This reuses the existing RX config BRAM path and does not require the
    // hardware PRBS checker to be enabled.
    localparam RX_MLSD_CAPTURE_EN = 1'b1;
    localparam [2:0] RX_DEFAULT_MLSD_DBG_GROUP_SEL = 3'd7;
    localparam [7:0] RX_MLSD_SOFT_RESET_CYCLES = 8'd32;
    localparam [7:0] RX_MLSD_SOFT_WARMUP_VALID_FRAMES = 8'd64;
    // Keep RX mode/core selection under Vitis GPIO ownership.
    localparam RX_BRINGUP_FORCE_PAM4_MLSD = 1'b0;
    localparam [1:0] RX_BRINGUP_MODE = 2'b01;
    localparam RX_BRINGUP_CFG_USE_MLSD = 1'b1;

    wire [(21*8)-1:0]  rx_eq_coeffs_flat_active;
    wire [(3*12)-1:0]  rx_pr_taps_flat_active;
    wire [31:0]        rx_pam4_levels_flat_active;
    wire               rx_eq_override_en_loader;
    wire               rx_pr_override_en_loader;
    wire               rx_level_override_en_loader;
    wire [23:0]        rx_thr4_flat_active;
    wire               rx_thr_override_en_loader;
    wire [2:0]         rx_mlsd_dbg_group_sel_loader;
    wire               rx_mlsd_dbg_group_override_en_loader;
    wire [2:0]         rx_mlsd_dbg_group_sel_active;
    wire [2:0]         rx_main_route_sel_loader;
    wire               rx_main_route_override_en_loader;
    wire [7:0]         rx_mlsd_capture_token_loader;
    wire [7:0]         rx_mlsd_capture_depth_frames_loader;
    wire               rx_eq_override_en_active;
    wire               rx_pr_override_en_active;
    wire               rx_level_override_en_active;
    wire               rx_thr_override_en_active;
    wire [23:0]        rx_thr4_flat_eff_w;
    (* keep = "true" *) wire signed [255:0] out_rx8p_packed_w;
    (* keep = "true" *) wire signed [959:0] mlsd_debug_capture_frame_w;
    (* keep = "true" *) wire signed [255:0] dbg_eq8_packed_full_int;
    wire [255:0]       rx_eq_coeffs_dbg_flat;
    wire signed [63:0]   dbg_raw8_lanes8_int;
    wire                out_rx8p_valid_int;
    wire                out_path_is_mlsd_unused;
    wire                mlsd_out_valid_int;
    wire                mlsd_accept_valid_int;
    wire [15:0]         dbg_mlsd_cand_count_sum_int;
    wire [7:0]          mlsd_ps_expand_sum_unused;
    wire [7:0]          mlsd_ns_expand_sum_unused;
    wire                cfg_rx_coeff_commit_pulse;
    wire                cfg_rx_coeff_commit_pending_unused;
    wire                cfg_rx_coeff_load_busy_unused;
    wire                rxcfg_cfg_bram_en;
    wire [3:0]          rxcfg_cfg_bram_we;
    wire [7:0]          rxcfg_cfg_bram_addr_word;
    wire [31:0]         rxcfg_cfg_bram_wrdata;
    wire                mlsd_cap_bram_req;
    wire [3:0]          mlsd_cap_bram_we;
    wire [31:0]         mlsd_cap_bram_addr;
    wire [31:0]         mlsd_cap_bram_wrdata;
    wire signed [255:0] out_rx8p_mlsd_packed_int;
    reg  [1:0]          rx_data_valid_pipe;
    reg  [31:0]         dbg_rx_frame_count;
    reg  [7:0]          mlsd_soft_reset_count_q;
    reg  [7:0]          mlsd_soft_warmup_count_q;
    reg                 mlsd_soft_warmup_active_q;
    wire                mlsd_soft_reset_active;
    wire                mlsd_soft_warmup_active;
    wire                mlsd_impl_aresetn;
    wire                out_rx8p_valid_safe;
    wire                mlsd_out_valid_safe;
    wire                mlsd_accept_valid_safe;

    assign rx_eq_override_en_active    = RX_RUNTIME_EQ_OVERRIDE_EN      ? rx_eq_override_en_loader    : 1'b0;
    assign rx_pr_override_en_active    = RX_RUNTIME_PR_OVERRIDE_EN      ? rx_pr_override_en_loader    : 1'b0;
    assign rx_level_override_en_active = RX_RUNTIME_LEVEL_OVERRIDE_EN   ? rx_level_override_en_loader : 1'b0;
    assign rx_thr_override_en_active   = RX_RUNTIME_THR_OVERRIDE_EN     ? rx_thr_override_en_loader   : 1'b0;
    assign rx_mlsd_dbg_group_sel_active =
        (RX_RUNTIME_MLSD_DBG_GROUP_OVERRIDE_EN && rx_mlsd_dbg_group_override_en_loader)
            ? rx_mlsd_dbg_group_sel_loader
            : RX_DEFAULT_MLSD_DBG_GROUP_SEL;
    wire                rx_data_valid_aligned;
    wire [5:0]          rx_ctrl_cfg_async;
    wire [5:0]          rx_ctrl_cfg_aclk;
    wire                rx_ctrl_cfg_update_unused;
    wire [1:0]          ch_case_sel_aclk;
    wire                cfg_use_mlsd_aclk;
    wire                rx_ffe_en_aclk;
    wire [1:0]          mode_aclk;

    // fifo_generator_1 has C_PRELOAD_LATENCY=2, so rd_en/!empty is delayed
    // two RX clocks to align with the 512b FIFO word.
    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            rx_data_valid_pipe <= 2'b00;
            dbg_rx_frame_count <= 32'd0;
        end else begin
            rx_data_valid_pipe <= {rx_data_valid_pipe[0], rx_data_valid};
            if (rx_data_valid_aligned) begin
                dbg_rx_frame_count <= dbg_rx_frame_count + 32'd1;
            end
        end
    end

    assign rx_data_valid_aligned = rx_data_valid_pipe[1];

    always @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            mlsd_soft_reset_count_q <= 8'd0;
            mlsd_soft_warmup_count_q <= 8'd0;
            mlsd_soft_warmup_active_q <= 1'b0;
        end else if (cfg_rx_coeff_commit_pulse) begin
            mlsd_soft_reset_count_q <= RX_MLSD_SOFT_RESET_CYCLES;
            mlsd_soft_warmup_count_q <= RX_MLSD_SOFT_WARMUP_VALID_FRAMES;
            mlsd_soft_warmup_active_q <= 1'b1;
        end else if (mlsd_soft_reset_count_q != 8'd0) begin
            mlsd_soft_reset_count_q <= mlsd_soft_reset_count_q - 8'd1;
        end else if (mlsd_soft_warmup_active_q && out_rx8p_valid_int) begin
            if (mlsd_soft_warmup_count_q <= 8'd1) begin
                mlsd_soft_warmup_count_q <= 8'd0;
                mlsd_soft_warmup_active_q <= 1'b0;
            end else begin
                mlsd_soft_warmup_count_q <= mlsd_soft_warmup_count_q - 8'd1;
            end
        end
    end

    assign mlsd_soft_reset_active = (mlsd_soft_reset_count_q != 8'd0);
    assign mlsd_soft_warmup_active = mlsd_soft_reset_active || mlsd_soft_warmup_active_q;
    assign mlsd_impl_aresetn = aresetn && !mlsd_soft_reset_active;
    assign out_rx8p_valid_safe = out_rx8p_valid_int && !mlsd_soft_warmup_active;
    assign mlsd_out_valid_safe = mlsd_out_valid_int && !mlsd_soft_warmup_active;
    assign mlsd_accept_valid_safe = mlsd_accept_valid_int && !mlsd_soft_warmup_active;

    wire [1:0] mode_bringup_eff =
        RX_BRINGUP_FORCE_PAM4_MLSD ? RX_BRINGUP_MODE : mode;
    wire cfg_use_mlsd_bringup_eff =
        RX_BRINGUP_FORCE_PAM4_MLSD ? RX_BRINGUP_CFG_USE_MLSD : cfg_use_mlsd;

    assign rx_ctrl_cfg_async = {mode_bringup_eff, rx_ffe_en, cfg_use_mlsd_bringup_eff, ch_case_sel};
    rx_cfg_stable_cdc #(
        .WIDTH(6),
        .STABLE_CYCLES(4),
        .RESET_VALUE(6'b00_0_0_00)
    ) u_rx_ctrl_cfg_cdc (
        .dst_clk(aclk),
        .dst_rstn(aresetn),
        .async_cfg(rx_ctrl_cfg_async),
        .dst_cfg(rx_ctrl_cfg_aclk),
        .dst_update_pulse(rx_ctrl_cfg_update_unused)
    );

    assign mode_aclk         = rx_ctrl_cfg_aclk[5:4];
    assign rx_ffe_en_aclk    = rx_ctrl_cfg_aclk[3];
    assign cfg_use_mlsd_aclk = rx_ctrl_cfg_aclk[2];
    assign ch_case_sel_aclk  = rx_ctrl_cfg_aclk[1:0];

    assign dbg_rx_stream_state = {
        dbg_rx_frame_count,
        in_data_16b[511:496],
        rx_data_valid_pipe,
        rx_data_valid,
        rx_data_valid_aligned,
        out_rx8p_valid_safe,
        mlsd_accept_valid_safe,
        mlsd_soft_reset_active,
        mlsd_soft_warmup_active,
        cfg_use_mlsd_aclk,
        rx_ffe_en_aclk,
        mode_aclk,
        4'b0000
    };

    pam4_rx_coeff_bram_loader u_rx_cfg (
        .clk(aclk),
        .rst_n(aresetn),
        .cfg_apply_ready(1'b1),
        .bram_hold(RX_MLSD_CAPTURE_EN ? mlsd_cap_bram_req : 1'b0),
        .cfg_commit_pulse(cfg_rx_coeff_commit_pulse),
        .cfg_commit_pending(cfg_rx_coeff_commit_pending_unused),
        .cfg_load_busy(cfg_rx_coeff_load_busy_unused),
        .cfg_active_commit_seq(cfg_rx_coeff_active_commit_seq),
        .bram_en(rxcfg_cfg_bram_en),
        .bram_we(rxcfg_cfg_bram_we),
        .bram_addr(rxcfg_cfg_bram_addr_word),
        .bram_wrdata(rxcfg_cfg_bram_wrdata),
        .bram_rddata(rxcfg_bram_rddata),
        .rx_eq_coeffs_flat_active(rx_eq_coeffs_flat_active),
        .rx_eq_override_en_active(rx_eq_override_en_loader),
        .rx_pr_taps_flat_active(rx_pr_taps_flat_active),
        .rx_pr_override_en_active(rx_pr_override_en_loader),
        .rx_pam4_levels_flat_active(rx_pam4_levels_flat_active),
        .rx_level_override_en_active(rx_level_override_en_loader),
        .rx_thr4_flat_active(rx_thr4_flat_active),
        .rx_thr_override_en_active(rx_thr_override_en_loader),
        .rx_mlsd_dbg_group_sel_active(rx_mlsd_dbg_group_sel_loader),
        .rx_mlsd_dbg_group_override_en_active(rx_mlsd_dbg_group_override_en_loader),
        .rx_main_route_sel_active(rx_main_route_sel_loader),
        .rx_main_route_override_en_active(rx_main_route_override_en_loader),
        .rx_mlsd_capture_token_active(rx_mlsd_capture_token_loader),
        .rx_mlsd_capture_depth_frames_active(rx_mlsd_capture_depth_frames_loader)
    );

    rx_bd_shim_raw1024_to_bitplanes_mmrs_mlsd_fitfirst u_impl (
        .aclk(aclk),
        .aresetn(mlsd_impl_aresetn),
        .mode(mode_aclk),
        .rx_ffe_en(rx_ffe_en_aclk),
        .rx_h_flat(rx_h_flat),
        .cfg_use_mlsd(cfg_use_mlsd_aclk),
        .ch_case_sel(ch_case_sel_aclk),
        .in_data_16b(in_data_16b),
        .in_data_valid(rx_data_valid_aligned),
        .cfg_rx_eq_override_en(rx_eq_override_en_active),
        .cfg_rx_eq_coeffs_flat(rx_eq_coeffs_flat_active),
        .cfg_rx_pr_override_en(rx_pr_override_en_active),
        .cfg_rx_pr_taps_flat(rx_pr_taps_flat_active),
        .cfg_rx_level_override_en(rx_level_override_en_active),
        .cfg_rx_pam4_levels_flat(rx_pam4_levels_flat_active),
        .cfg_rx_thr_override_en(rx_thr_override_en_active),
        .cfg_rx_thr4_flat(rx_thr4_flat_active),
        .cfg_rx_mlsd_dbg_group_sel(rx_mlsd_dbg_group_sel_active),
        .cfg_rx_main_route_sel(rx_main_route_sel_loader),
        .cfg_rx_main_route_override_en(rx_main_route_override_en_loader),
        .out_rx8p_packed(out_rx8p_packed_w),
        .out_rx8p_valid(out_rx8p_valid_int),
        .out_rx8p_bypass_packed(),
        .out_rx8p_mlsd_packed(out_rx8p_mlsd_packed_int),
        .out_path_is_mlsd(out_path_is_mlsd_unused),
        .mlsd_out_valid(mlsd_out_valid_int),
        .mlsd_accept_valid(mlsd_accept_valid_int),
        .mlsd_cand_count_sum(dbg_mlsd_cand_count_sum_int),
        .mlsd_ps_expand_sum(mlsd_ps_expand_sum_unused),
        .mlsd_ns_expand_sum(mlsd_ns_expand_sum_unused),
        .dbg_raw8_lanes8(dbg_raw8_lanes8_int),
        .dbg_eq8_lanes8(dbg_eq8_lanes8),
        .dbg_eq8_packed_full(dbg_eq8_packed_full_int),
        .dbg_shape8_lanes8(),
        .dbg_np8_lanes8(),
        .dbg_det_np8_lanes8(dbg_det_np8_lanes8),
        .dbg_mlsd8_lanes8(dbg_mlsd8_lanes8),
        .dbg_mlsd_hist_packed(),
        .dbg_predec_hist_packed(),
        .dbg_mlsd_ctrl_packed(dbg_mlsd_ctrl_packed),
        .dbg_mlsd_pm_packed(dbg_mlsd_pm_packed),
        .dbg_raw0(),
        .dbg_ch0()
    );

    generate
        if (RX_MLSD_CAPTURE_EN) begin : gen_mlsd256_capture
            // Debug-only capture frame map, 32-bit words:
            //  0..1  selected RX8P lanes 0..7
            //  2..3  pre-MLSD detector input lanes 0..7
            //  4..5  MLSD debug-group output lanes
            //  6..7  MLSD control/traceback metadata
            //  8..9  raw8 lanes 0..7
            // 10..11 eq8 lanes 0..7
            // 12     active EQ taps {tap3..tap0}, signed 8b Q6 each
            // 13     status/route/valid flags
            // 14..20 active EQ taps {tap7..tap4} .. {tap20}, zero padded
            // 21..28 full EQ8 lanes 0..31, four signed 8b lanes per word
            // 29     marker 0x45513850 ("EQ8P")
            mlsd_debug_bram_capture #(
                .FRAME_BITS(960),
                .CAPTURE_MAX_FRAMES(64),
                .CAPTURE_BASE_WORD(256),
                .STATUS_BASE_WORD(8)
            ) u_mlsd256_capture (
                .clk(aclk),
                .rst_n(aresetn),
                .arm_token(rx_mlsd_capture_token_loader),
                .depth_frames(rx_mlsd_capture_depth_frames_loader),
                .frame_valid(out_rx8p_valid_safe),
                .frame_data(mlsd_debug_capture_frame_w),
                .bram_req(mlsd_cap_bram_req),
                .bram_we(mlsd_cap_bram_we),
                .bram_addr(mlsd_cap_bram_addr),
                .bram_wrdata(mlsd_cap_bram_wrdata)
            );
        end else begin : gen_no_mlsd256_capture
            assign mlsd_cap_bram_req    = 1'b0;
            assign mlsd_cap_bram_we     = 4'b0000;
            assign mlsd_cap_bram_addr   = 32'd0;
            assign mlsd_cap_bram_wrdata = 32'd0;
        end
    endgenerate

    assign rxcfg_bram_en = 1'b1;
    assign rxcfg_bram_we = mlsd_cap_bram_req ? mlsd_cap_bram_we : 4'b0000;
    assign rxcfg_bram_wrdata = mlsd_cap_bram_req ? mlsd_cap_bram_wrdata : rxcfg_cfg_bram_wrdata;
    assign rxcfg_bram_addr = mlsd_cap_bram_req ? mlsd_cap_bram_addr
                                                : {22'd0, rxcfg_cfg_bram_addr_word, 2'b00};

    assign rx_eq_coeffs_dbg_flat = {{(256-(21*8)){1'b0}}, rx_eq_coeffs_flat_active};

    assign mlsd_debug_capture_frame_w = {
        32'h4551_3850,
        dbg_eq8_packed_full_int[255:224],
        dbg_eq8_packed_full_int[223:192],
        dbg_eq8_packed_full_int[191:160],
        dbg_eq8_packed_full_int[159:128],
        dbg_eq8_packed_full_int[127:96],
        dbg_eq8_packed_full_int[95:64],
        dbg_eq8_packed_full_int[63:32],
        dbg_eq8_packed_full_int[31:0],
        rx_eq_coeffs_dbg_flat[255:224],
        rx_eq_coeffs_dbg_flat[223:192],
        rx_eq_coeffs_dbg_flat[191:160],
        rx_eq_coeffs_dbg_flat[159:128],
        rx_eq_coeffs_dbg_flat[127:96],
        rx_eq_coeffs_dbg_flat[95:64],
        rx_eq_coeffs_dbg_flat[63:32],
        {
            dbg_mlsd_cand_count_sum,
            rx_mlsd_dbg_group_sel_active,
            rx_main_route_sel_loader,
            out_path_is_mlsd_unused,
            mlsd_out_valid_safe,
            mlsd_accept_valid_safe,
            out_rx8p_valid_safe,
            cfg_use_mlsd_aclk,
            rx_main_route_override_en_loader,
            rx_mlsd_dbg_group_override_en_loader,
            rx_pr_override_en_active,
            rx_level_override_en_active,
            rx_thr_override_en_active
        },
        rx_eq_coeffs_dbg_flat[31:0],
        dbg_eq8_lanes8[63:32],
        dbg_eq8_lanes8[31:0],
        dbg_raw8_lanes8_int[63:32],
        dbg_raw8_lanes8_int[31:0],
        dbg_mlsd_ctrl_packed[63:32],
        dbg_mlsd_ctrl_packed[31:0],
        dbg_mlsd8_lanes8[63:32],
        dbg_mlsd8_lanes8[31:0],
        dbg_det_np8_lanes8[63:32],
        dbg_det_np8_lanes8[31:0],
        out_rx8p_packed_w[63:32],
        out_rx8p_packed_w[31:0]
    };

    assign dbg_mlsd_valid = mlsd_out_valid_safe;
    assign dbg_mlsd_cand_count_sum = mlsd_soft_warmup_active ? 16'd0 : dbg_mlsd_cand_count_sum_int;
    assign rx_thr4_flat_eff_w = rx_thr_override_en_active ? rx_thr4_flat_active
                                                          : {8'h40, 8'h00, 8'hC0};
    assign rx_thr4_flat_eff = rx_thr4_flat_eff_w;
    assign rx_thr4_0_eff = rx_thr4_flat_eff_w[7:0];
    assign rx_thr4_1_eff = rx_thr4_flat_eff_w[15:8];
    assign rx_thr4_2_eff = rx_thr4_flat_eff_w[23:16];
    assign out_rx8p_packed = out_rx8p_packed_w;
    assign decision_valid = out_rx8p_valid_safe;
    assign mlsd_accept_valid = mlsd_accept_valid_safe;

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: Dual-Survivor Segmented Branch-Metric Matrix MLSD
// Module Name: mlsd_debug_bram_capture
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Captures MLSD debug frames into a BRAM-readable memory window.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module mlsd_debug_bram_capture #(
    parameter integer FRAME_BITS = 512,
    parameter integer CAPTURE_MAX_FRAMES = 64,
    parameter integer CAPTURE_BASE_WORD  = 256,
    parameter integer STATUS_BASE_WORD   = 8
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire [7:0]           arm_token,
    input  wire [7:0]           depth_frames,
    input  wire                 frame_valid,
    input  wire signed [FRAME_BITS-1:0] frame_data,
    output reg                  bram_req,
    output reg  [3:0]           bram_we,
    output reg  [31:0]          bram_addr,
    output reg  [31:0]          bram_wrdata
);
    localparam [31:0] STATUS_MAGIC = 32'h4D4C_5344; // "MLSD"
    localparam integer WORDS_PER_FRAME = FRAME_BITS / 32;
    localparam [7:0] CAPTURE_MAX_FRAMES_U8 = CAPTURE_MAX_FRAMES;
    localparam integer FRAME_CNT_W = (CAPTURE_MAX_FRAMES <= 2)   ? 1 :
                                     (CAPTURE_MAX_FRAMES <= 4)   ? 2 :
                                     (CAPTURE_MAX_FRAMES <= 8)   ? 3 :
                                     (CAPTURE_MAX_FRAMES <= 16)  ? 4 :
                                     (CAPTURE_MAX_FRAMES <= 32)  ? 5 :
                                     (CAPTURE_MAX_FRAMES <= 64)  ? 6 :
                                     (CAPTURE_MAX_FRAMES <= 128) ? 7 : 8;

    localparam [2:0] ST_IDLE              = 3'd0;
    localparam [2:0] ST_CAPTURE           = 3'd1;
    localparam [2:0] ST_DUMP_DATA         = 3'd2;
    localparam [2:0] ST_DUMP_STATUS      = 3'd3;
    localparam [2:0] ST_WRITE_ARM_STATUS = 3'd4;

    (* ram_style = "block" *) reg [FRAME_BITS-1:0] frame_mem [0:CAPTURE_MAX_FRAMES-1];

    reg [2:0] state_q;
    reg [7:0] arm_token_seen_q;
    reg [7:0] target_frames_q;
    reg [7:0] captured_frames_q;
    reg [7:0] dump_frame_q;
    reg [7:0] dump_word_q;
    reg [1:0] status_word_q;
    reg       overflow_q;
    reg       capture_done_q;

    wire [7:0] depth_limited =
        (depth_frames == 8'd0) ? CAPTURE_MAX_FRAMES_U8 :
        (depth_frames > CAPTURE_MAX_FRAMES_U8) ? CAPTURE_MAX_FRAMES_U8 :
        depth_frames;

    wire arm_event = (arm_token != arm_token_seen_q);
    wire capture_full_next = (captured_frames_q + 8'd1) >= target_frames_q;
    wire dump_last_word = (dump_word_q == (WORDS_PER_FRAME - 1));
    wire dump_last_frame = (dump_frame_q + 8'd1) >= captured_frames_q;

    function automatic [31:0] status_word_value(input [1:0] idx);
        begin
            case (idx)
                2'd0: status_word_value = STATUS_MAGIC;
                2'd1: status_word_value = {
                                            8'd0,
                                            target_frames_q,
                                            captured_frames_q,
                                            4'd0,
                                            overflow_q,
                                            capture_done_q,
                                            (state_q == ST_DUMP_DATA) || (state_q == ST_DUMP_STATUS),
                                            (state_q == ST_CAPTURE) ||
                                            (state_q == ST_WRITE_ARM_STATUS)
                                           };
                2'd2: status_word_value = {24'd0, target_frames_q};
                default: status_word_value = {24'd0, captured_frames_q};
            endcase
        end
    endfunction

    always @* begin
        bram_req    = (state_q == ST_DUMP_DATA) ||
                      (state_q == ST_DUMP_STATUS) ||
                      (state_q == ST_WRITE_ARM_STATUS);
        bram_we     = bram_req ? 4'hF : 4'h0;
        bram_addr   = 32'd0;
        bram_wrdata = 32'd0;

        if (state_q == ST_DUMP_DATA) begin
            bram_addr = ((CAPTURE_BASE_WORD + (dump_frame_q * WORDS_PER_FRAME) + dump_word_q) << 2);
            bram_wrdata = frame_mem[dump_frame_q][(dump_word_q * 32) +: 32];
        end else if ((state_q == ST_DUMP_STATUS) ||
                     (state_q == ST_WRITE_ARM_STATUS)) begin
            bram_addr = ((STATUS_BASE_WORD + status_word_q) << 2);
            bram_wrdata = status_word_value(status_word_q);
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_q <= ST_IDLE;
            arm_token_seen_q <= 8'd0;
                        target_frames_q <= CAPTURE_MAX_FRAMES_U8;
            captured_frames_q <= 8'd0;
            dump_frame_q <= 8'd0;
            dump_word_q <= 8'd0;
            status_word_q <= 2'd0;
            overflow_q <= 1'b0;
            capture_done_q <= 1'b0;
        end else begin
            case (state_q)
                ST_IDLE: begin
                    if (arm_event) begin
                        arm_token_seen_q <= arm_token;
                        target_frames_q <= depth_limited;
                        captured_frames_q <= 8'd0;
                        dump_frame_q <= 8'd0;
                        dump_word_q <= 8'd0;
                        status_word_q <= 2'd0;
                        overflow_q <= (depth_frames > CAPTURE_MAX_FRAMES_U8);
                        capture_done_q <= 1'b0;
                        state_q <= ST_WRITE_ARM_STATUS;
                    end
                end

                ST_CAPTURE: begin
                    if (arm_event) begin
                        arm_token_seen_q <= arm_token;
                        target_frames_q <= depth_limited;
                        captured_frames_q <= 8'd0;
                        dump_frame_q <= 8'd0;
                        dump_word_q <= 8'd0;
                        status_word_q <= 2'd0;
                        overflow_q <= (depth_frames > CAPTURE_MAX_FRAMES_U8);
                        capture_done_q <= 1'b0;
                        state_q <= ST_WRITE_ARM_STATUS;
                    end else if (frame_valid) begin
                        frame_mem[captured_frames_q[FRAME_CNT_W-1:0]] <= frame_data;
                        captured_frames_q <= captured_frames_q + 8'd1;
                        if (capture_full_next) begin
                            dump_frame_q <= 8'd0;
                            dump_word_q <= 8'd0;
                            state_q <= ST_DUMP_DATA;
                        end
                    end
                end

                ST_DUMP_DATA: begin
                    if (dump_last_word) begin
                        dump_word_q <= 8'd0;
                        if (dump_last_frame) begin
                            status_word_q <= 2'd0;
                            capture_done_q <= 1'b1;
                            state_q <= ST_DUMP_STATUS;
                        end else begin
                            dump_frame_q <= dump_frame_q + 8'd1;
                        end
                    end else begin
                        dump_word_q <= dump_word_q + 8'd1;
                    end
                end

                ST_DUMP_STATUS: begin
                    if (status_word_q == 2'd3) begin
                        state_q <= ST_IDLE;
                    end else begin
                        status_word_q <= status_word_q + 2'd1;
                    end
                end

                ST_WRITE_ARM_STATUS: begin
                    if (status_word_q == 2'd3) begin
                        status_word_q <= 2'd0;
                        state_q <= ST_CAPTURE;
                    end else begin
                        status_word_q <= status_word_q + 2'd1;
                    end
                end

                default: begin
                    state_q <= ST_IDLE;
                end
            endcase
        end
    end
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: Control and Coefficient Interface
// Module Name: rx_cfg_stable_cdc
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Synchronizes RX configuration fields into the RX processing clock domain with stable update timing.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module rx_cfg_stable_cdc #(
    parameter integer WIDTH = 1,
    parameter integer STABLE_CYCLES = 4,
    parameter [WIDTH-1:0] RESET_VALUE = {WIDTH{1'b0}}
) (
    input  wire             dst_clk,
    input  wire             dst_rstn,
    input  wire [WIDTH-1:0] async_cfg,
    output reg  [WIDTH-1:0] dst_cfg,
    output reg              dst_update_pulse
);

    (* ASYNC_REG = "TRUE" *) reg [WIDTH-1:0] async_meta;
    (* ASYNC_REG = "TRUE" *) reg [WIDTH-1:0] async_sync;
    reg [WIDTH-1:0] pending_cfg;
    reg [3:0]       stable_count;

    always @(posedge dst_clk or negedge dst_rstn) begin
        if (!dst_rstn) begin
            async_meta       <= RESET_VALUE;
            async_sync       <= RESET_VALUE;
            pending_cfg      <= RESET_VALUE;
            dst_cfg          <= RESET_VALUE;
            dst_update_pulse <= 1'b0;
            stable_count     <= 4'd0;
        end else begin
            dst_update_pulse <= 1'b0;
            async_meta       <= async_cfg;
            async_sync       <= async_meta;

            if (async_sync != pending_cfg) begin
                pending_cfg  <= async_sync;
                stable_count <= 4'd0;
            end else if (dst_cfg != pending_cfg) begin
                if (stable_count >= (STABLE_CYCLES - 1)) begin
                    dst_cfg          <= pending_cfg;
                    dst_update_pulse <= 1'b1;
                end else begin
                    stable_count <= stable_count + 1'b1;
                end
            end else begin
                stable_count <= 4'd0;
            end
        end
    end

endmodule

