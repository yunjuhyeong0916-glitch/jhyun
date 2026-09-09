`timescale 1ns/1ps

// ============================================================================
// pam4_rx_coeff_bram_loader
// - RX-only coefficient loader for use with AXI BRAM Controller + true dual
//   port BRAM.
// - Software writes the shadow image through AXI BRAM Controller on BRAM Port A.
// - This module reads BRAM Port B, snapshots the image into an internal shadow
//   bank, then atomically swaps to the active bank on a commit sequence change.
//
// BRAM word map (32-bit words on Port B, byte addresses on AXI = word*4):
//   word  0 / 0x000 : ID low         = 0x52584252 ("RXBR")
//   word  1 / 0x004 : ID high        = 0x00010000
//   word  2 / 0x008 : CTRL
//                     bit1 = RX EQ override enable
//                     bit2 = reserved
//                     bit3 = RX PR override enable
//                     bit4 = RX level override enable
//                     bit5 = RX threshold override enable
//                     bit6 = RX MLSD debug 8-lane group override enable
//                     bit7 = RX main route override enable
//                     bits[10:8] = RX MLSD debug 8-lane group select
//                     bits[13:11] = RX main route select
//                       0=RAW8, 1=EQ8, 2=SHAPE8, 3=NP8, 4=MLSD
//   word  3 / 0x00C : COMMIT_SEQ
//                     Software increments this after finishing all writes.
//   word  4 / 0x010 : RX_CAPTURE_TOKEN
//                     Software changes bits[7:0] and commits to arm one capture.
//   word  5 / 0x014 : RX_CAPTURE_DEPTH_FRAMES
//                     Number of debug MLSD output frames to capture.
//   word 16 / 0x040 : RX EQ taps [0:20], s8 in bits[7:0], Q6
//   word 48 / 0x0C0 : reserved, retained for register-map compatibility
//   word 64 / 0x100 : RX PR taps [0:2],  s12 Q8 in bits[11:0]
//   word 72 / 0x120 : RX levels  [0:3],  s8  in bits[7:0]
//   word 80 / 0x140 : RX thr4    [0:2],  s8  in bits[7:0]
//
// Notes:
// - BRAM Port B is read-only here. Hardware never writes back status into BRAM.
// - cfg_apply_ready gates only the active-bank swap. Shadow prefetch can happen
//   earlier, but outputs update atomically only when cfg_apply_ready is high.
// ============================================================================

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: Control and Coefficient Interface
// Module Name: pam4_rx_coeff_bram_loader
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Loads and distributes RX EQ coefficient words from a BRAM-style configuration interface.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module pam4_rx_coeff_bram_loader #(
    parameter integer BRAM_ADDR_WIDTH = 8
) (
    input  logic                       clk,
    input  logic                       rst_n,
    input  logic                       cfg_apply_ready,
    input  logic                       bram_hold,

    output logic                       cfg_commit_pulse,
    output logic                       cfg_commit_pending,
    output logic                       cfg_load_busy,
    output logic [31:0]                cfg_active_commit_seq,

    output logic                       bram_en,
    output logic [3:0]                 bram_we,
    output logic [BRAM_ADDR_WIDTH-1:0] bram_addr,
    output logic [31:0]                bram_wrdata,
    input  logic [31:0]                bram_rddata,

    output logic [(21*8)-1:0]          rx_eq_coeffs_flat_active,
    output logic                       rx_eq_override_en_active,
    output logic [(3*12)-1:0]          rx_pr_taps_flat_active,
    output logic                       rx_pr_override_en_active,
    output logic [31:0]                rx_pam4_levels_flat_active,
    output logic                       rx_level_override_en_active,
    output logic [23:0]                rx_thr4_flat_active,
    output logic                       rx_thr_override_en_active,
    output logic [2:0]                 rx_mlsd_dbg_group_sel_active,
    output logic                       rx_mlsd_dbg_group_override_en_active,
    output logic [2:0]                 rx_main_route_sel_active,
    output logic                       rx_main_route_override_en_active,
    output logic [7:0]                 rx_mlsd_capture_token_active,
    output logic [7:0]                 rx_mlsd_capture_depth_frames_active
);
    localparam logic [31:0] ID_LO = 32'h5258_4252;
    localparam logic [31:0] ID_HI = 32'h0001_0000;

    localparam int WORD_CTRL        = 2;
    localparam int WORD_COMMIT_SEQ  = 3;
    localparam int WORD_MLSD_CAP_TOKEN = 4;
    localparam int WORD_MLSD_CAP_DEPTH = 5;
    localparam int REG_IDX_RX_EQ    = 16;
    localparam int REG_IDX_RESERVED = 48;
    localparam int REG_IDX_RX_PR    = 64;
    localparam int REG_IDX_RX_LV    = 72;
    localparam int REG_IDX_RX_THR   = 80;
    localparam int REG_WORDS        = 88;
    localparam int RX_EQ_TAPS       = 21;
    localparam int LOAD_ITEMS       = 41;

    typedef enum logic [2:0] {
        ST_POLL_REQ   = 3'd0,
        ST_POLL_WAIT  = 3'd1,
        ST_LOAD_REQ   = 3'd2,
        ST_LOAD_WAIT  = 3'd3,
        ST_APPLY_WAIT = 3'd4
    } state_t;

    state_t state_q;

    logic [31:0] active_regs [0:REG_WORDS-1];
    logic [31:0] shadow_regs [0:REG_WORDS-1];
    logic [31:0] pending_commit_seq_q;
    logic [5:0]  load_idx_q;

    integer i;

    function automatic logic [31:0] default_word(input int idx);
        begin
            default_word = 32'd0;
            case (idx)
                0:                  default_word = ID_LO;
                1:                  default_word = ID_HI;
                REG_IDX_RX_EQ + 0:  default_word = 32'h0000_0040;
                REG_IDX_RX_PR + 0:  default_word = 32'h0000_0100;
                REG_IDX_RX_PR + 1:  default_word = 32'h0000_0000;
                REG_IDX_RX_PR + 2:  default_word = 32'h0000_0000;

                REG_IDX_RX_LV + 0:  default_word = 32'hFFFF_FFA0;
                REG_IDX_RX_LV + 1:  default_word = 32'hFFFF_FFE0;
                REG_IDX_RX_LV + 2:  default_word = 32'h0000_0020;
                REG_IDX_RX_LV + 3:  default_word = 32'h0000_0060;

                REG_IDX_RX_THR + 0: default_word = 32'hFFFF_FFC0;
                REG_IDX_RX_THR + 1: default_word = 32'h0000_0000;
                REG_IDX_RX_THR + 2: default_word = 32'h0000_0040;
                default:            default_word = 32'd0;
            endcase
        end
    endfunction

    function automatic logic [BRAM_ADDR_WIDTH-1:0] load_word_addr(input logic [5:0] load_idx);
        int addr_tmp;
        begin
            if (load_idx == 0)
                addr_tmp = WORD_CTRL;
            else if (load_idx == 1)
                addr_tmp = WORD_MLSD_CAP_TOKEN;
            else if (load_idx == 2)
                addr_tmp = WORD_MLSD_CAP_DEPTH;
            else if (load_idx <= 23)
                addr_tmp = REG_IDX_RX_EQ + load_idx - 3;
            else if (load_idx <= 30)
                addr_tmp = REG_IDX_RESERVED + load_idx - 24;
            else if (load_idx <= 33)
                addr_tmp = REG_IDX_RX_PR + load_idx - 31;
            else if (load_idx <= 37)
                addr_tmp = REG_IDX_RX_LV + load_idx - 34;
            else
                addr_tmp = REG_IDX_RX_THR + load_idx - 38;
            load_word_addr = addr_tmp;
        end
    endfunction

    function automatic int load_dest_idx(input logic [5:0] load_idx);
        begin
            if (load_idx == 0)
                load_dest_idx = WORD_CTRL;
            else if (load_idx == 1)
                load_dest_idx = WORD_MLSD_CAP_TOKEN;
            else if (load_idx == 2)
                load_dest_idx = WORD_MLSD_CAP_DEPTH;
            else if (load_idx <= 23)
                load_dest_idx = REG_IDX_RX_EQ + load_idx - 3;
            else if (load_idx <= 30)
                load_dest_idx = REG_IDX_RESERVED + load_idx - 24;
            else if (load_idx <= 33)
                load_dest_idx = REG_IDX_RX_PR + load_idx - 31;
            else if (load_idx <= 37)
                load_dest_idx = REG_IDX_RX_LV + load_idx - 34;
            else
                load_dest_idx = REG_IDX_RX_THR + load_idx - 38;
        end
    endfunction

    task automatic load_reset_defaults;
        begin
            for (int ridx = 0; ridx < REG_WORDS; ridx = ridx + 1) begin
                active_regs[ridx] <= default_word(ridx);
                shadow_regs[ridx] <= default_word(ridx);
            end
        end
    endtask

    always_comb begin
        bram_en     = 1'b0;
        bram_we     = 4'b0000;
        bram_addr   = '0;
        bram_wrdata = 32'd0;

        case (state_q)
            ST_POLL_REQ:  begin bram_en = 1'b1; bram_addr = WORD_COMMIT_SEQ[BRAM_ADDR_WIDTH-1:0]; end
            ST_LOAD_REQ:  begin bram_en = 1'b1; bram_addr = load_word_addr(load_idx_q);           end
            default:      begin end
        endcase

        rx_eq_coeffs_flat_active = '0;
        for (int eqi = 0; eqi < RX_EQ_TAPS; eqi = eqi + 1)
            rx_eq_coeffs_flat_active[(eqi*8) +: 8] = active_regs[REG_IDX_RX_EQ + eqi][7:0];

        rx_pr_taps_flat_active = '0;
        for (int pri = 0; pri < 3; pri = pri + 1)
            rx_pr_taps_flat_active[(pri*12) +: 12] = active_regs[REG_IDX_RX_PR + pri][11:0];

        rx_pam4_levels_flat_active = '0;
        for (int lvi = 0; lvi < 4; lvi = lvi + 1)
            rx_pam4_levels_flat_active[(lvi*8) +: 8] = active_regs[REG_IDX_RX_LV + lvi][7:0];

        rx_thr4_flat_active = '0;
        for (int thri = 0; thri < 3; thri = thri + 1)
            rx_thr4_flat_active[(thri*8) +: 8] = active_regs[REG_IDX_RX_THR + thri][7:0];

        rx_eq_override_en_active    = active_regs[WORD_CTRL][1];
        rx_pr_override_en_active    = active_regs[WORD_CTRL][3];
        rx_level_override_en_active = active_regs[WORD_CTRL][4];
        rx_thr_override_en_active   = active_regs[WORD_CTRL][5];
        rx_mlsd_dbg_group_override_en_active = active_regs[WORD_CTRL][6];
        rx_main_route_override_en_active = active_regs[WORD_CTRL][7];
        rx_mlsd_dbg_group_sel_active = active_regs[WORD_CTRL][10:8];
        rx_main_route_sel_active = active_regs[WORD_CTRL][13:11];
        rx_mlsd_capture_token_active = active_regs[WORD_MLSD_CAP_TOKEN][7:0];
        rx_mlsd_capture_depth_frames_active = active_regs[WORD_MLSD_CAP_DEPTH][7:0];
    end

    initial begin
        state_q               = ST_POLL_REQ;
        pending_commit_seq_q  = 32'd0;
        load_idx_q            = '0;
        cfg_commit_pulse      = 1'b0;
        cfg_commit_pending    = 1'b0;
        cfg_load_busy         = 1'b0;
        cfg_active_commit_seq = 32'd0;
        for (i = 0; i < REG_WORDS; i = i + 1) begin
            active_regs[i] = default_word(i);
            shadow_regs[i] = default_word(i);
        end
    end

    always @(posedge clk or negedge rst_n) begin
        int dest_idx;
        if (!rst_n) begin
            state_q               <= ST_POLL_REQ;
            pending_commit_seq_q  <= 32'd0;
            load_idx_q            <= '0;
            cfg_commit_pulse      <= 1'b0;
            cfg_commit_pending    <= 1'b0;
            cfg_load_busy         <= 1'b0;
            cfg_active_commit_seq <= 32'd0;
            for (i = 0; i < REG_WORDS; i = i + 1) begin
                active_regs[i] <= 32'd0;
                shadow_regs[i] <= 32'd0;
            end
            load_reset_defaults();
        end else begin
            cfg_commit_pulse <= 1'b0;
            if (bram_hold) begin
                cfg_load_busy <= cfg_load_busy;
            end else case (state_q)
                ST_POLL_REQ: begin
                    state_q <= ST_POLL_WAIT;
                end

                ST_POLL_WAIT: begin
                    if (bram_rddata != cfg_active_commit_seq) begin
                        pending_commit_seq_q <= bram_rddata;
                        cfg_commit_pending   <= 1'b1;
                        if (cfg_apply_ready) begin
                            cfg_load_busy <= 1'b1;
                            load_idx_q    <= '0;
                            state_q       <= ST_LOAD_REQ;
                        end else begin
                            state_q <= ST_POLL_REQ;
                        end
                    end else begin
                        state_q <= ST_POLL_REQ;
                    end
                end

                ST_LOAD_REQ: begin
                    state_q <= ST_LOAD_WAIT;
                end

                ST_LOAD_WAIT: begin
                    dest_idx = load_dest_idx(load_idx_q);
                    shadow_regs[dest_idx] <= bram_rddata;
                    if (load_idx_q == LOAD_ITEMS-1) begin
                        state_q <= ST_APPLY_WAIT;
                    end else begin
                        load_idx_q <= load_idx_q + 1'b1;
                        state_q    <= ST_LOAD_REQ;
                    end
                end

                ST_APPLY_WAIT: begin
                    if (cfg_apply_ready) begin
                        for (i = 0; i < REG_WORDS; i = i + 1)
                            active_regs[i] <= shadow_regs[i];
                        cfg_active_commit_seq <= pending_commit_seq_q;
                        cfg_commit_pulse      <= 1'b1;
                        cfg_commit_pending    <= 1'b0;
                        cfg_load_busy         <= 1'b0;
                        state_q               <= ST_POLL_REQ;
                    end
                end

                default: begin
                    state_q <= ST_POLL_REQ;
                end
            endcase
        end
    end
endmodule
