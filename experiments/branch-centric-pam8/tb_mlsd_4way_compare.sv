`timescale 1ns/1ps

module tb_mlsd_4way_compare;

  localparam int LANES           = 64;
  localparam int TB              = 40;
  localparam int MET_W           = 16;
  localparam int PR_SHIFT        = 2;
  localparam int SYMS_PER_CASE   = 1024;
  localparam int DRAIN_CYCLES    = TB + 8;
  localparam int NUM_NOISE_CASES = 4;
  localparam int NUM_CH_CASES    = 4;
  localparam int LAG_SWEEP       = 4;
  localparam int EXP_DEPTH       = TB + LAG_SWEEP + 8;
  localparam int LAG_CENTER      = TB - 1;
  localparam int LAG_MIN         = LAG_CENTER - LAG_SWEEP;
  localparam int LAG_MAX         = LAG_CENTER + LAG_SWEEP;
  localparam int NUM_LAGS        = (2 * LAG_SWEEP) + 1;

  localparam logic [3:0] K_CFG = 4'd2;

  localparam logic signed [7:0] P0 = 8'sd1;
  localparam logic signed [7:0] P1 = 8'sd2;
  localparam logic signed [7:0] P2 = 8'sd1;

  localparam logic signed [7:0] NRZ_NEG = -8'sd127;
  localparam logic signed [7:0] NRZ_POS =  8'sd127;

  localparam logic signed [7:0] PAM4_L0 = -8'sd96;
  localparam logic signed [7:0] PAM4_L1 = -8'sd32;
  localparam logic signed [7:0] PAM4_L2 =  8'sd32;
  localparam logic signed [7:0] PAM4_L3 =  8'sd96;

  localparam logic signed [7:0] PAM8_L0 = -8'sd112;
  localparam logic signed [7:0] PAM8_L1 = -8'sd80;
  localparam logic signed [7:0] PAM8_L2 = -8'sd48;
  localparam logic signed [7:0] PAM8_L3 = -8'sd16;
  localparam logic signed [7:0] PAM8_L4 =  8'sd16;
  localparam logic signed [7:0] PAM8_L5 =  8'sd48;
  localparam logic signed [7:0] PAM8_L6 =  8'sd80;
  localparam logic signed [7:0] PAM8_L7 =  8'sd112;

  logic         clk;
  logic         rst_n;
  logic         in_valid;
  logic [1:0]   mode;
  logic [511:0] din_flat;
  logic [511:0] raw_flat;

  logic [511:0] dout_allfs;
  logic [511:0] dout_hybrid;
  logic [511:0] dout_allrs;
  logic [511:0] dout_unified;

  logic out_valid_allfs;
  logic out_valid_hybrid;
  logic out_valid_allrs;
  logic out_valid_unified;

  logic [15:0] cand_sum_allfs;
  logic [15:0] cand_sum_hybrid;
  logic [15:0] cand_sum_allrs;
  logic [15:0] cand_sum_unified;
  logic [7:0]  ps_expand_sum_allfs;
  logic [7:0]  ns_expand_sum_allfs;
  logic [7:0]  ps_expand_sum_hybrid;
  logic [7:0]  ns_expand_sum_hybrid;
  logic [7:0]  ps_expand_sum_allrs;
  logic [7:0]  ns_expand_sum_allrs;
  logic [7:0]  ps_expand_sum_unified;
  logic [7:0]  ns_expand_sum_unified;

  logic signed [7:0]  dbg_raw0_allfs;
  logic signed [15:0] dbg_ch0_allfs;
  logic signed [7:0]  dbg_raw0_hybrid;
  logic signed [15:0] dbg_ch0_hybrid;
  logic signed [7:0]  dbg_raw0_allrs;
  logic signed [15:0] dbg_ch0_allrs;
  logic signed [7:0]  dbg_raw0_unified;
  logic signed [15:0] dbg_ch0_unified;

  logic [6:0] prbs_state  [0:LANES-1];
  logic [6:0] noise_state [0:LANES-1];
  logic signed [7:0] hist1 [0:LANES-1];
  logic signed [7:0] hist2 [0:LANES-1];
  logic signed [7:0] exp_shift [0:LANES-1][0:EXP_DEPTH-1];
  logic [EXP_DEPTH-1:0] tx_valid_shreg;

  integer total_sym_phase;
  integer total_in_sym_phase;
  longint unsigned cand_acc_allfs_phase;
  longint unsigned cand_acc_hybrid_phase;
  longint unsigned cand_acc_allrs_phase;
  longint unsigned cand_acc_unified_phase;
  longint unsigned ps_expand_acc_allfs_phase;
  longint unsigned ns_expand_acc_allfs_phase;
  longint unsigned ps_expand_acc_hybrid_phase;
  longint unsigned ns_expand_acc_hybrid_phase;
  longint unsigned ps_expand_acc_allrs_phase;
  longint unsigned ns_expand_acc_allrs_phase;
  longint unsigned ps_expand_acc_unified_phase;
  longint unsigned ns_expand_acc_unified_phase;
  integer err_allfs_lag    [0:NUM_LAGS-1];
  integer err_hybrid_lag   [0:NUM_LAGS-1];
  integer err_allrs_lag    [0:NUM_LAGS-1];
  integer err_unified_lag  [0:NUM_LAGS-1];
  integer mis_hybrid_vs_fs_phase;
  integer mis_allrs_vs_fs_phase;
  integer mis_unified_vs_fs_phase;
  integer valid_mismatch_hyb_phase;
  integer valid_mismatch_rs_phase;
  integer valid_mismatch_uni_phase;

  integer current_mode_idx;
  integer current_noise_mag;
  integer current_ch_case;

  function automatic logic signed [7:0] lane_get(
    input logic [511:0] bus,
    input int idx
  );
    logic signed [7:0] tmp;
    begin
      tmp = $signed(bus[8*idx +: 8]);
      lane_get = tmp;
    end
  endfunction

  task automatic lane_set(
    ref logic [511:0] bus,
    input int idx,
    input logic signed [7:0] val
  );
    begin
      bus[8*idx +: 8] = val;
    end
  endtask

  function automatic logic signed [7:0] sat8_from_int(input integer x);
    begin
      if      (x > 127)   sat8_from_int =  8'sd127;
      else if (x < -128)  sat8_from_int = -8'sd128;
      else                sat8_from_int = x[7:0];
    end
  endfunction

  function automatic logic signed [7:0] sym_amp_from_idx(
    input logic [1:0] mode_f,
    input int idx
  );
    begin
      case (mode_f)
        2'b00: sym_amp_from_idx = idx[0] ? NRZ_POS : NRZ_NEG;
        2'b01: begin
          case (idx[1:0])
            2'd0: sym_amp_from_idx = PAM4_L0;
            2'd1: sym_amp_from_idx = PAM4_L1;
            2'd2: sym_amp_from_idx = PAM4_L2;
            default: sym_amp_from_idx = PAM4_L3;
          endcase
        end
        2'b10: begin
          case (idx[2:0])
            3'd0: sym_amp_from_idx = PAM8_L0;
            3'd1: sym_amp_from_idx = PAM8_L1;
            3'd2: sym_amp_from_idx = PAM8_L2;
            3'd3: sym_amp_from_idx = PAM8_L3;
            3'd4: sym_amp_from_idx = PAM8_L4;
            3'd5: sym_amp_from_idx = PAM8_L5;
            3'd6: sym_amp_from_idx = PAM8_L6;
            default: sym_amp_from_idx = PAM8_L7;
          endcase
        end
        default: sym_amp_from_idx = NRZ_NEG;
      endcase
    end
  endfunction

  function automatic logic [6:0] prbs7_step(input logic [6:0] s);
    logic fb;
    begin
      fb = s[6] ^ s[5];
      prbs7_step = {s[5:0], fb};
    end
  endfunction

  function automatic logic [6:0] prbs7_seed(
    input int ln,
    input logic [1:0] mode_f,
    input bit noise_domain
  );
    int seed_i;
    begin
      seed_i = (((ln + 1) * 17) + (noise_domain ? 73 : 11) + mode_f) % 127;
      prbs7_seed = seed_i[6:0] + 7'd1;
    end
  endfunction

  function automatic int prbs_bits_per_symbol(input logic [1:0] mode_f);
    begin
      case (mode_f)
        2'b00: prbs_bits_per_symbol = 1;
        2'b01: prbs_bits_per_symbol = 2;
        2'b10: prbs_bits_per_symbol = 3;
        default: prbs_bits_per_symbol = 1;
      endcase
    end
  endfunction

  task automatic prbs7_take_bits(
    input int nbits,
    inout logic [6:0] s,
    output int bits_val
  );
    int bi;
    logic [6:0] s_loc;
    begin
      bits_val = 0;
      s_loc = s;
      for (bi = 0; bi < nbits; bi = bi + 1) begin
        bits_val = bits_val | ((s_loc[6] ? 1 : 0) << bi);
        s_loc = prbs7_step(s_loc);
      end
      s = s_loc;
    end
  endtask

  task automatic prbs7_next_symbol_idx(
    input logic [1:0] mode_f,
    inout logic [6:0] s,
    output int idx
  );
    begin
      prbs7_take_bits(prbs_bits_per_symbol(mode_f), s, idx);
    end
  endtask

  function automatic integer noise_mag_value(input int noise_case_idx);
    begin
      case (noise_case_idx)
        0: noise_mag_value = 0;
        1: noise_mag_value = 2;
        2: noise_mag_value = 4;
        default: noise_mag_value = 8;
      endcase
    end
  endfunction

  function automatic integer ch_case_p0(input int ch_case_idx);
    begin
      case (ch_case_idx)
        0: ch_case_p0 = 1;
        1: ch_case_p0 = 1;
        2: ch_case_p0 = 1;
        default: ch_case_p0 = 0;
      endcase
    end
  endfunction

  function automatic integer ch_case_p1(input int ch_case_idx);
    begin
      case (ch_case_idx)
        0: ch_case_p1 = 2;
        1: ch_case_p1 = 2;
        2: ch_case_p1 = 1;
        default: ch_case_p1 = 2;
      endcase
    end
  endfunction

  function automatic integer ch_case_p2(input int ch_case_idx);
    begin
      case (ch_case_idx)
        0: ch_case_p2 = 1;
        1: ch_case_p2 = 0;
        2: ch_case_p2 = 1;
        default: ch_case_p2 = 1;
      endcase
    end
  endfunction

  function automatic integer noise_from_prbs7(
    input int prbs_u8,
    input int noise_mag_i
  );
    integer span;
    begin
      if (noise_mag_i <= 0) begin
        noise_from_prbs7 = 0;
      end else begin
        span = (2 * noise_mag_i) + 1;
        noise_from_prbs7 = (prbs_u8 % span) - noise_mag_i;
      end
    end
  endfunction

  function automatic integer pr2_sample_int(
    input logic signed [7:0] a0,
    input logic signed [7:0] a1,
    input logic signed [7:0] a2,
    input integer c0,
    input integer c1,
    input integer c2,
    input integer noise_i
  );
    integer full;
    begin
      full = c0 * $signed(a0) +
             c1 * $signed(a1) +
             c2 * $signed(a2);
      pr2_sample_int = (full >>> PR_SHIFT) + noise_i;
    end
  endfunction

  function automatic [31:0] mode_label(input int mode_idx);
    begin
      case (mode_idx)
        0: mode_label = "NRZ ";
        1: mode_label = "PAM4";
        2: mode_label = "PAM8";
        default: mode_label = "UNKN";
      endcase
    end
  endfunction

  task automatic shift_expected_lane(
    input int ln,
    input logic signed [7:0] amp
  );
    int t;
    begin
      for (t = EXP_DEPTH-1; t > 0; t = t - 1)
        exp_shift[ln][t] = exp_shift[ln][t-1];
      exp_shift[ln][0] = amp;
    end
  endtask

  task automatic init_mode_context(input logic [1:0] mode_sel);
    int ln, t;
    logic signed [7:0] init_amp;
    begin
      init_amp = sym_amp_from_idx(mode_sel, 0);
      for (ln = 0; ln < LANES; ln = ln + 1) begin
        prbs_state[ln]  = prbs7_seed(ln, mode_sel, 1'b0);
        noise_state[ln] = prbs7_seed(ln, mode_sel, 1'b1);
        hist1[ln] = init_amp;
        hist2[ln] = init_amp;
        for (t = 0; t < EXP_DEPTH; t = t + 1)
          exp_shift[ln][t] = 8'sd0;
      end
    end
  endtask

  function automatic int theo_final_candidates_per_lane(
    input int mode_idx_f,
    input int arch_idx
  );
    begin
      case (mode_idx_f)
        0: begin
          case (arch_idx)
            0, 1, 3: theo_final_candidates_per_lane = 8;
            default: theo_final_candidates_per_lane = 4;
          endcase
        end
        1: begin
          case (arch_idx)
            0: theo_final_candidates_per_lane = 64;
            default: theo_final_candidates_per_lane = 4;
          endcase
        end
        2: begin
          case (arch_idx)
            0: theo_final_candidates_per_lane = 512;
            default: theo_final_candidates_per_lane = 16;
          endcase
        end
        default: theo_final_candidates_per_lane = 0;
      endcase
    end
  endfunction

  function automatic int theo_final_candidates_per_lane_max(
    input int mode_idx_f,
    input int arch_idx
  );
    int keep_dim;
    begin
      case (mode_idx_f)
        0: begin
          case (arch_idx)
            0, 1, 3: theo_final_candidates_per_lane_max = 8;
            default: theo_final_candidates_per_lane_max = 4;
          endcase
        end
        1: begin
          case (arch_idx)
            0: theo_final_candidates_per_lane_max = 64;
            default: begin
              keep_dim = 2 + K_CFG;
              if (keep_dim > 4)
                keep_dim = 4;
              theo_final_candidates_per_lane_max = keep_dim * keep_dim;
            end
          endcase
        end
        2: begin
          case (arch_idx)
            0: theo_final_candidates_per_lane_max = 512;
            default: begin
              keep_dim = 4 + K_CFG;
              if (keep_dim > 8)
                keep_dim = 8;
              theo_final_candidates_per_lane_max = keep_dim * keep_dim;
            end
          endcase
        end
        default: theo_final_candidates_per_lane_max = 0;
      endcase
    end
  endfunction

  function automatic int metric_prebm_per_lane(
    input int mode_idx_f,
    input int arch_idx
  );
    begin
      case (mode_idx_f)
        0: begin
          case (arch_idx)
            2: metric_prebm_per_lane = 4;
            default: metric_prebm_per_lane = 0;
          endcase
        end
        1: begin
          case (arch_idx)
            0: metric_prebm_per_lane = 0;
            default: metric_prebm_per_lane = 16;
          endcase
        end
        2: begin
          case (arch_idx)
            0: metric_prebm_per_lane = 0;
            default: metric_prebm_per_lane = 64;
          endcase
        end
        default: metric_prebm_per_lane = 0;
      endcase
    end
  endfunction

  function automatic int metric_ksel_per_lane(
    input int mode_idx_f,
    input int arch_idx
  );
    int keep_dim;
    begin
      case (mode_idx_f)
        0: begin
          case (arch_idx)
            2: metric_ksel_per_lane = 8;
            default: metric_ksel_per_lane = 0;
          endcase
        end
        1: begin
          case (arch_idx)
            0: metric_ksel_per_lane = 0;
            default: begin
              keep_dim = 2 + K_CFG;
              if (keep_dim > 4)
                keep_dim = 4;
              metric_ksel_per_lane = 2 * keep_dim * 4;
            end
          endcase
        end
        2: begin
          case (arch_idx)
            0: metric_ksel_per_lane = 0;
            default: begin
              keep_dim = 4 + K_CFG;
              if (keep_dim > 8)
                keep_dim = 8;
              metric_ksel_per_lane = 2 * keep_dim * 8;
            end
          endcase
        end
        default: metric_ksel_per_lane = 0;
      endcase
    end
  endfunction

  function automatic int memw_per_lane(
    input int mode_idx_f,
    input int arch_idx
  );
    begin
      case (mode_idx_f)
        0: begin
          case (arch_idx)
            0, 1, 3: memw_per_lane = 4;
            default: memw_per_lane = 2;
          endcase
        end
        1: begin
          case (arch_idx)
            0: memw_per_lane = 16;
            default: memw_per_lane = 4;
          endcase
        end
        2: begin
          case (arch_idx)
            0: memw_per_lane = 64;
            default: memw_per_lane = 8;
          endcase
        end
        default: memw_per_lane = 0;
      endcase
    end
  endfunction
  task automatic clear_phase_counters();
    int li;
    begin
      total_sym_phase = 0;
      total_in_sym_phase = 0;
      cand_acc_allfs_phase   = 0;
      cand_acc_hybrid_phase  = 0;
      cand_acc_allrs_phase   = 0;
      cand_acc_unified_phase = 0;
      ps_expand_acc_allfs_phase   = 0;
      ns_expand_acc_allfs_phase   = 0;
      ps_expand_acc_hybrid_phase  = 0;
      ns_expand_acc_hybrid_phase  = 0;
      ps_expand_acc_allrs_phase   = 0;
      ns_expand_acc_allrs_phase   = 0;
      ps_expand_acc_unified_phase = 0;
      ns_expand_acc_unified_phase = 0;
      for (li = 0; li < NUM_LAGS; li = li + 1) begin
        err_allfs_lag[li]   = 0;
        err_hybrid_lag[li]  = 0;
        err_allrs_lag[li]   = 0;
        err_unified_lag[li] = 0;
      end
      mis_hybrid_vs_fs_phase   = 0;
      mis_allrs_vs_fs_phase    = 0;
      mis_unified_vs_fs_phase  = 0;
      valid_mismatch_hyb_phase = 0;
      valid_mismatch_rs_phase  = 0;
      valid_mismatch_uni_phase = 0;
    end
  endtask

  task automatic drive_one_symbol(
    input logic [1:0] mode_sel,
    input int ch_case_idx,
    input int noise_mag_i
  );
    int ln;
    int idx;
    int noise_bits;
    int noise_i;
    logic signed [7:0] a0;
    logic signed [7:0] din0;
    begin
      raw_flat = '0;
      din_flat = '0;

      for (ln = 0; ln < LANES; ln = ln + 1) begin
        prbs7_next_symbol_idx(mode_sel, prbs_state[ln], idx);
        prbs7_take_bits(8, noise_state[ln], noise_bits);
        a0      = sym_amp_from_idx(mode_sel, idx);
        noise_i = noise_from_prbs7(noise_bits, noise_mag_i);
        din0    = sat8_from_int(pr2_sample_int(
                    a0,
                    hist1[ln],
                    hist2[ln],
                    ch_case_p0(ch_case_idx),
                    ch_case_p1(ch_case_idx),
                    ch_case_p2(ch_case_idx),
                    noise_i
                  ));

        lane_set(raw_flat, ln, a0);
        lane_set(din_flat, ln, din0);
        shift_expected_lane(ln, a0);

        hist2[ln] = hist1[ln];
        hist1[ln] = a0;
      end
    end
  endtask

  task automatic print_phase_summary(
    input int mode_idx,
    input int ch_case_idx,
    input int noise_mag_i
  );
    int li;
    int best_li_allfs;
    int best_li_hybrid;
    int best_li_allrs;
    int best_li_unified;
    integer best_err_allfs;
    integer best_err_hybrid;
    integer best_err_allrs;
    integer best_err_unified;
    integer nom_li;
    integer nom_abs;
    real ser_nom_allfs;
    real ser_nom_hybrid;
    real ser_nom_allrs;
    real ser_nom_unified;
    real ser_best_allfs;
    real ser_best_hybrid;
    real ser_best_allrs;
    real ser_best_unified;
    real mis_h;
    real mis_r;
    real mis_u;
    real cand_avg_allfs;
    real cand_avg_hybrid;
    real cand_avg_allrs;
    real cand_avg_unified;
    real ps_expand_rate_allfs;
    real ns_expand_rate_allfs;
    real ps_expand_rate_hybrid;
    real ns_expand_rate_hybrid;
    real ps_expand_rate_allrs;
    real ns_expand_rate_allrs;
    real ps_expand_rate_unified;
    real ns_expand_rate_unified;
    integer per_lane_input_syms;
    integer theo_cand_allfs;
    integer theo_cand_hybrid;
    integer theo_cand_allrs;
    integer theo_cand_unified;
    integer prebm_per_lane_allfs;
    integer prebm_per_lane_hybrid;
    integer prebm_per_lane_allrs;
    integer prebm_per_lane_unified;
    integer ksel_per_lane_allfs;
    integer ksel_per_lane_hybrid;
    integer ksel_per_lane_allrs;
    integer ksel_per_lane_unified;
    integer memw_per_lane_allfs;
    integer memw_per_lane_hybrid;
    integer memw_per_lane_allrs;
    integer memw_per_lane_unified;
    longint unsigned prebm_total_allfs;
    longint unsigned prebm_total_hybrid;
    longint unsigned prebm_total_allrs;
    longint unsigned prebm_total_unified;
    longint unsigned bm_total_allfs;
    longint unsigned bm_total_hybrid;
    longint unsigned bm_total_allrs;
    longint unsigned bm_total_unified;
    longint unsigned ksel_total_allfs;
    longint unsigned ksel_total_hybrid;
    longint unsigned ksel_total_allrs;
    longint unsigned ksel_total_unified;
    longint unsigned memw_total_allfs;
    longint unsigned memw_total_hybrid;
    longint unsigned memw_total_allrs;
    longint unsigned memw_total_unified;
    begin
      nom_li  = LAG_SWEEP;
      nom_abs = LAG_CENTER;

      best_li_allfs   = 0;
      best_li_hybrid  = 0;
      best_li_allrs   = 0;
      best_li_unified = 0;
      best_err_allfs   = err_allfs_lag[0];
      best_err_hybrid  = err_hybrid_lag[0];
      best_err_allrs   = err_allrs_lag[0];
      best_err_unified = err_unified_lag[0];

      for (li = 1; li < NUM_LAGS; li = li + 1) begin
        if (err_allfs_lag[li]   < best_err_allfs)   begin best_err_allfs   = err_allfs_lag[li];   best_li_allfs   = li; end
        if (err_hybrid_lag[li]  < best_err_hybrid)  begin best_err_hybrid  = err_hybrid_lag[li];  best_li_hybrid  = li; end
        if (err_allrs_lag[li]   < best_err_allrs)   begin best_err_allrs   = err_allrs_lag[li];   best_li_allrs   = li; end
        if (err_unified_lag[li] < best_err_unified) begin best_err_unified = err_unified_lag[li]; best_li_unified = li; end
      end

      ser_nom_allfs   = (total_sym_phase == 0) ? 0.0 : (err_allfs_lag[nom_li]   * 1.0 / total_sym_phase);
      ser_nom_hybrid  = (total_sym_phase == 0) ? 0.0 : (err_hybrid_lag[nom_li]  * 1.0 / total_sym_phase);
      ser_nom_allrs   = (total_sym_phase == 0) ? 0.0 : (err_allrs_lag[nom_li]   * 1.0 / total_sym_phase);
      ser_nom_unified = (total_sym_phase == 0) ? 0.0 : (err_unified_lag[nom_li] * 1.0 / total_sym_phase);

      ser_best_allfs   = (total_sym_phase == 0) ? 0.0 : (best_err_allfs   * 1.0 / total_sym_phase);
      ser_best_hybrid  = (total_sym_phase == 0) ? 0.0 : (best_err_hybrid  * 1.0 / total_sym_phase);
      ser_best_allrs   = (total_sym_phase == 0) ? 0.0 : (best_err_allrs   * 1.0 / total_sym_phase);
      ser_best_unified = (total_sym_phase == 0) ? 0.0 : (best_err_unified * 1.0 / total_sym_phase);

      mis_h = (total_sym_phase == 0) ? 0.0 : (mis_hybrid_vs_fs_phase  * 1.0 / total_sym_phase);
      mis_r = (total_sym_phase == 0) ? 0.0 : (mis_allrs_vs_fs_phase   * 1.0 / total_sym_phase);
      mis_u = (total_sym_phase == 0) ? 0.0 : (mis_unified_vs_fs_phase * 1.0 / total_sym_phase);
      cand_avg_allfs   = (total_in_sym_phase == 0) ? 0.0 : (cand_acc_allfs_phase   * 1.0 / total_in_sym_phase);
      cand_avg_hybrid  = (total_in_sym_phase == 0) ? 0.0 : (cand_acc_hybrid_phase  * 1.0 / total_in_sym_phase);
      cand_avg_allrs   = (total_in_sym_phase == 0) ? 0.0 : (cand_acc_allrs_phase   * 1.0 / total_in_sym_phase);
      cand_avg_unified = (total_in_sym_phase == 0) ? 0.0 : (cand_acc_unified_phase * 1.0 / total_in_sym_phase);
      ps_expand_rate_allfs   = (total_in_sym_phase == 0) ? 0.0 : (ps_expand_acc_allfs_phase   * 1.0 / total_in_sym_phase);
      ns_expand_rate_allfs   = (total_in_sym_phase == 0) ? 0.0 : (ns_expand_acc_allfs_phase   * 1.0 / total_in_sym_phase);
      ps_expand_rate_hybrid  = (total_in_sym_phase == 0) ? 0.0 : (ps_expand_acc_hybrid_phase  * 1.0 / total_in_sym_phase);
      ns_expand_rate_hybrid  = (total_in_sym_phase == 0) ? 0.0 : (ns_expand_acc_hybrid_phase  * 1.0 / total_in_sym_phase);
      ps_expand_rate_allrs   = (total_in_sym_phase == 0) ? 0.0 : (ps_expand_acc_allrs_phase   * 1.0 / total_in_sym_phase);
      ns_expand_rate_allrs   = (total_in_sym_phase == 0) ? 0.0 : (ns_expand_acc_allrs_phase   * 1.0 / total_in_sym_phase);
      ps_expand_rate_unified = (total_in_sym_phase == 0) ? 0.0 : (ps_expand_acc_unified_phase * 1.0 / total_in_sym_phase);
      ns_expand_rate_unified = (total_in_sym_phase == 0) ? 0.0 : (ns_expand_acc_unified_phase * 1.0 / total_in_sym_phase);

      per_lane_input_syms = (LANES == 0) ? 0 : (total_in_sym_phase / LANES);
      theo_cand_allfs   = theo_final_candidates_per_lane(mode_idx, 0);
      theo_cand_hybrid  = theo_final_candidates_per_lane(mode_idx, 1);
      theo_cand_allrs   = theo_final_candidates_per_lane(mode_idx, 2);
      theo_cand_unified = theo_final_candidates_per_lane(mode_idx, 3);

      prebm_per_lane_allfs   = metric_prebm_per_lane(mode_idx, 0);
      prebm_per_lane_hybrid  = metric_prebm_per_lane(mode_idx, 1);
      prebm_per_lane_allrs   = metric_prebm_per_lane(mode_idx, 2);
      prebm_per_lane_unified = metric_prebm_per_lane(mode_idx, 3);

      ksel_per_lane_allfs   = metric_ksel_per_lane(mode_idx, 0);
      ksel_per_lane_hybrid  = metric_ksel_per_lane(mode_idx, 1);
      ksel_per_lane_allrs   = metric_ksel_per_lane(mode_idx, 2);
      ksel_per_lane_unified = metric_ksel_per_lane(mode_idx, 3);

      memw_per_lane_allfs   = memw_per_lane(mode_idx, 0);
      memw_per_lane_hybrid  = memw_per_lane(mode_idx, 1);
      memw_per_lane_allrs   = memw_per_lane(mode_idx, 2);
      memw_per_lane_unified = memw_per_lane(mode_idx, 3);

      prebm_total_allfs   = longint'(prebm_per_lane_allfs)   * longint'(total_in_sym_phase);
      prebm_total_hybrid  = longint'(prebm_per_lane_hybrid)  * longint'(total_in_sym_phase);
      prebm_total_allrs   = longint'(prebm_per_lane_allrs)   * longint'(total_in_sym_phase);
      prebm_total_unified = longint'(prebm_per_lane_unified) * longint'(total_in_sym_phase);

      bm_total_allfs   = cand_acc_allfs_phase   + prebm_total_allfs;
      bm_total_hybrid  = cand_acc_hybrid_phase  + prebm_total_hybrid;
      bm_total_allrs   = cand_acc_allrs_phase   + prebm_total_allrs;
      bm_total_unified = cand_acc_unified_phase + prebm_total_unified;

      ksel_total_allfs   = longint'(ksel_per_lane_allfs)   * longint'(total_in_sym_phase);
      ksel_total_hybrid  = longint'(ksel_per_lane_hybrid)  * longint'(total_in_sym_phase);
      ksel_total_allrs   = longint'(ksel_per_lane_allrs)   * longint'(total_in_sym_phase);
      ksel_total_unified = longint'(ksel_per_lane_unified) * longint'(total_in_sym_phase);

      memw_total_allfs   = longint'(memw_per_lane_allfs)   * longint'(total_in_sym_phase);
      memw_total_hybrid  = longint'(memw_per_lane_hybrid)  * longint'(total_in_sym_phase);
      memw_total_allrs   = longint'(memw_per_lane_allrs)   * longint'(total_in_sym_phase);
      memw_total_unified = longint'(memw_per_lane_unified) * longint'(total_in_sym_phase);

      $display("----------------------------------------");
      $display("Stimulus=PRBS7 symbol stream");
      $display("MODE=%s  CH_CASE=%0d  CH_TAPS=[%0d %0d %0d]  NOISE_MAG=%0d  symbols=%0d",
               mode_label(mode_idx),
               ch_case_idx,
               ch_case_p0(ch_case_idx),
               ch_case_p1(ch_case_idx),
               ch_case_p2(ch_case_idx),
               noise_mag_i,
               total_sym_phase);
      $display("Nominal lag abs=%0d offset=%0d (polarity-aware)", nom_abs, 0);
      $display("SER@nom  all-FS   = %e (%0d / %0d)", ser_nom_allfs,   err_allfs_lag[nom_li],   total_sym_phase);
      $display("SER@nom  hybrid   = %e (%0d / %0d)", ser_nom_hybrid,  err_hybrid_lag[nom_li],  total_sym_phase);
      $display("SER@nom  all-RS   = %e (%0d / %0d)", ser_nom_allrs,   err_allrs_lag[nom_li],   total_sym_phase);
      $display("SER@nom  unified  = %e (%0d / %0d)", ser_nom_unified, err_unified_lag[nom_li], total_sym_phase);
      $display("BEST all-FS   lag abs=%0d offset=%0d  SER=%e (%0d / %0d)",
               LAG_MIN + best_li_allfs,   (LAG_MIN + best_li_allfs)   - LAG_CENTER, ser_best_allfs,   best_err_allfs,   total_sym_phase);
      $display("BEST hybrid   lag abs=%0d offset=%0d  SER=%e (%0d / %0d)",
               LAG_MIN + best_li_hybrid,  (LAG_MIN + best_li_hybrid)  - LAG_CENTER, ser_best_hybrid,  best_err_hybrid,  total_sym_phase);
      $display("BEST all-RS   lag abs=%0d offset=%0d  SER=%e (%0d / %0d)",
               LAG_MIN + best_li_allrs,   (LAG_MIN + best_li_allrs)   - LAG_CENTER, ser_best_allrs,   best_err_allrs,   total_sym_phase);
      $display("BEST unified  lag abs=%0d offset=%0d  SER=%e (%0d / %0d)",
               LAG_MIN + best_li_unified, (LAG_MIN + best_li_unified) - LAG_CENTER, ser_best_unified, best_err_unified, total_sym_phase);
      $display("MIS  hybrid vs all-FS = %e (%0d / %0d)", mis_h, mis_hybrid_vs_fs_phase, total_sym_phase);
      $display("MIS  all-RS vs all-FS = %e (%0d / %0d)", mis_r, mis_allrs_vs_fs_phase, total_sym_phase);
      $display("MIS  unified vs all-FS = %e (%0d / %0d)", mis_u, mis_unified_vs_fs_phase, total_sym_phase);
      $display("VALID mismatch counts: hybrid=%0d  all-RS=%0d  unified=%0d",
               valid_mismatch_hyb_phase, valid_mismatch_rs_phase, valid_mismatch_uni_phase);
      $display("Actual avg candidates/lane/input_symbol  all-FS=%0.3f  hybrid=%0.3f  all-RS=%0.3f  unified=%0.3f",
               cand_avg_allfs, cand_avg_hybrid, cand_avg_allrs, cand_avg_unified);
      $display("Candidates/lane/symbol(base) all-FS=%0d  hybrid=%0d  all-RS=%0d  unified=%0d",
               theo_cand_allfs, theo_cand_hybrid, theo_cand_allrs, theo_cand_unified);
      $display("Candidates/lane/symbol(max)  all-FS=%0d  hybrid=%0d  all-RS=%0d  unified=%0d",
               theo_final_candidates_per_lane_max(mode_idx, 0),
               theo_final_candidates_per_lane_max(mode_idx, 1),
               theo_final_candidates_per_lane_max(mode_idx, 2),
               theo_final_candidates_per_lane_max(mode_idx, 3));
      $display("Expand hits(ps/ns)      all-FS=%0d/%0d  hybrid=%0d/%0d  all-RS=%0d/%0d  unified=%0d/%0d",
               ps_expand_acc_allfs_phase, ns_expand_acc_allfs_phase,
               ps_expand_acc_hybrid_phase, ns_expand_acc_hybrid_phase,
               ps_expand_acc_allrs_phase, ns_expand_acc_allrs_phase,
               ps_expand_acc_unified_phase, ns_expand_acc_unified_phase);
      $display("Expand rate(ps/ns)      all-FS=%0.3f/%0.3f  hybrid=%0.3f/%0.3f  all-RS=%0.3f/%0.3f  unified=%0.3f/%0.3f",
               ps_expand_rate_allfs, ns_expand_rate_allfs,
               ps_expand_rate_hybrid, ns_expand_rate_hybrid,
               ps_expand_rate_allrs, ns_expand_rate_allrs,
               ps_expand_rate_unified, ns_expand_rate_unified);
      $display("preBM/lane/symbol       all-FS=%0d  hybrid=%0d  all-RS=%0d  unified=%0d",
               prebm_per_lane_allfs, prebm_per_lane_hybrid, prebm_per_lane_allrs, prebm_per_lane_unified);
      $display("[Per-lane cumulative complexity over %0d input symbols]", per_lane_input_syms);
      $display("  FINAL BM/ACS   all-FS=%0d  hybrid=%0d  all-RS=%0d  unified=%0d",
               cand_acc_allfs_phase / LANES, cand_acc_hybrid_phase / LANES, cand_acc_allrs_phase / LANES, cand_acc_unified_phase / LANES);
      $display("  pre-BM         all-FS=%0d  hybrid=%0d  all-RS=%0d  unified=%0d",
               prebm_total_allfs / LANES, prebm_total_hybrid / LANES, prebm_total_allrs / LANES, prebm_total_unified / LANES);
      $display("  BM-like total  all-FS=%0d  hybrid=%0d  all-RS=%0d  unified=%0d",
               bm_total_allfs / LANES, bm_total_hybrid / LANES, bm_total_allrs / LANES, bm_total_unified / LANES);
      $display("  KSEL(max est.) all-FS=%0d  hybrid=%0d  all-RS=%0d  unified=%0d",
               ksel_total_allfs / LANES, ksel_total_hybrid / LANES, ksel_total_allrs / LANES, ksel_total_unified / LANES);
      $display("  MEMW           all-FS=%0d  hybrid=%0d  all-RS=%0d  unified=%0d",
               memw_total_allfs / LANES, memw_total_hybrid / LANES, memw_total_allrs / LANES, memw_total_unified / LANES);
      $display("[All-lanes cumulative complexity]");
      $display("  FINAL BM/ACS   all-FS=%0d  hybrid=%0d  all-RS=%0d  unified=%0d",
               cand_acc_allfs_phase, cand_acc_hybrid_phase, cand_acc_allrs_phase, cand_acc_unified_phase);
      $display("  pre-BM         all-FS=%0d  hybrid=%0d  all-RS=%0d  unified=%0d",
               prebm_total_allfs, prebm_total_hybrid, prebm_total_allrs, prebm_total_unified);
      $display("  BM-like total  all-FS=%0d  hybrid=%0d  all-RS=%0d  unified=%0d",
               bm_total_allfs, bm_total_hybrid, bm_total_allrs, bm_total_unified);
      $display("  KSEL(max est.) all-FS=%0d  hybrid=%0d  all-RS=%0d  unified=%0d",
               ksel_total_allfs, ksel_total_hybrid, ksel_total_allrs, ksel_total_unified);
      $display("  MEMW           all-FS=%0d  hybrid=%0d  all-RS=%0d  unified=%0d",
               memw_total_allfs, memw_total_hybrid, memw_total_allrs, memw_total_unified);
    end
  endtask

  task automatic run_sweep_case(
    input logic [1:0] mode_sel,
    input int mode_idx,
    input int ch_case_idx,
    input int noise_mag_i,
    input int n_syms
  );
    int n;
    begin
      current_mode_idx  = mode_idx;
      current_noise_mag = noise_mag_i;
      current_ch_case   = ch_case_idx;
      clear_phase_counters();

      mode     = mode_sel;
      rst_n    = 1'b0;
      in_valid = 1'b0;
      raw_flat = '0;
      din_flat = '0;
      init_mode_context(mode_sel);

      repeat (4) @(negedge clk);
      rst_n = 1'b1;
      @(negedge clk);

      in_valid = 1'b1;
      for (n = 0; n < n_syms; n = n + 1) begin
        drive_one_symbol(mode_sel, ch_case_idx, noise_mag_i);
        @(negedge clk);
      end

      in_valid = 1'b0;
      raw_flat = '0;
      din_flat = '0;
      repeat (DRAIN_CYCLES) @(posedge clk);

      print_phase_summary(mode_idx, ch_case_idx, noise_mag_i);
    end
  endtask

  CMP_ALLFS_MLSD_DSP_64LANE_8B #(
    .TB(TB),
    .MET_W(MET_W),
    .P0(P0), .P1(P1), .P2(P2),
    .NRZ_NEG(NRZ_NEG), .NRZ_POS(NRZ_POS),
    .PAM4_L0(PAM4_L0), .PAM4_L1(PAM4_L1), .PAM4_L2(PAM4_L2), .PAM4_L3(PAM4_L3),
    .PAM8_L0(PAM8_L0), .PAM8_L1(PAM8_L1), .PAM8_L2(PAM8_L2), .PAM8_L3(PAM8_L3),
    .PAM8_L4(PAM8_L4), .PAM8_L5(PAM8_L5), .PAM8_L6(PAM8_L6), .PAM8_L7(PAM8_L7)
  ) u_allfs (
    .clk(clk), .rst_n(rst_n), .in_valid(in_valid), .mode(mode),
    .din_flat(din_flat), .raw_flat(raw_flat),
    .dout_flat(dout_allfs), .out_valid(out_valid_allfs), .cand_count_sum(cand_sum_allfs),
    .dbg_raw0(dbg_raw0_allfs), .dbg_ch0(dbg_ch0_allfs)
  );

  CMP_HYBRID_MLSD_DSP_64LANE_8B #(
    .TB(TB),
    .MET_W(MET_W),
    .K_CFG(K_CFG),
    .P0(P0), .P1(P1), .P2(P2),
    .NRZ_NEG(NRZ_NEG), .NRZ_POS(NRZ_POS),
    .PAM4_L0(PAM4_L0), .PAM4_L1(PAM4_L1), .PAM4_L2(PAM4_L2), .PAM4_L3(PAM4_L3),
    .PAM8_L0(PAM8_L0), .PAM8_L1(PAM8_L1), .PAM8_L2(PAM8_L2), .PAM8_L3(PAM8_L3),
    .PAM8_L4(PAM8_L4), .PAM8_L5(PAM8_L5), .PAM8_L6(PAM8_L6), .PAM8_L7(PAM8_L7)
  ) u_hybrid (
    .clk(clk), .rst_n(rst_n), .in_valid(in_valid), .mode(mode), .ch_case_sel(2'd0),
    .din_flat(din_flat), .raw_flat(raw_flat),
    .dout_flat(dout_hybrid), .out_valid(out_valid_hybrid), .cand_count_sum(cand_sum_hybrid),
    .ps_expand_sum(ps_expand_sum_hybrid), .ns_expand_sum(ns_expand_sum_hybrid),
    .dbg_raw0(dbg_raw0_hybrid), .dbg_ch0(dbg_ch0_hybrid)
  );

  CMP_ALLRS_MLSD_DSP_64LANE_8B #(
    .TB(TB),
    .MET_W(MET_W),
    .K_CFG(K_CFG),
    .P0(P0), .P1(P1), .P2(P2),
    .NRZ_NEG(NRZ_NEG), .NRZ_POS(NRZ_POS),
    .PAM4_L0(PAM4_L0), .PAM4_L1(PAM4_L1), .PAM4_L2(PAM4_L2), .PAM4_L3(PAM4_L3),
    .PAM8_L0(PAM8_L0), .PAM8_L1(PAM8_L1), .PAM8_L2(PAM8_L2), .PAM8_L3(PAM8_L3),
    .PAM8_L4(PAM8_L4), .PAM8_L5(PAM8_L5), .PAM8_L6(PAM8_L6), .PAM8_L7(PAM8_L7)
  ) u_allrs (
    .clk(clk), .rst_n(rst_n), .in_valid(in_valid), .mode(mode), .ch_case_sel(2'd0),
    .din_flat(din_flat), .raw_flat(raw_flat),
    .dout_flat(dout_allrs), .out_valid(out_valid_allrs), .cand_count_sum(cand_sum_allrs),
    .ps_expand_sum(ps_expand_sum_allrs), .ns_expand_sum(ns_expand_sum_allrs),
    .dbg_raw0(dbg_raw0_allrs), .dbg_ch0(dbg_ch0_allrs)
  );

  CMP_UNIFIED_MLSD_DSP_64LANE_8B #(
    .TB(TB),
    .MET_W(MET_W),
    .K_CFG(K_CFG),
    .P0(P0), .P1(P1), .P2(P2),
    .NRZ_NEG(NRZ_NEG), .NRZ_POS(NRZ_POS),
    .PAM4_L0(PAM4_L0), .PAM4_L1(PAM4_L1), .PAM4_L2(PAM4_L2), .PAM4_L3(PAM4_L3),
    .PAM8_L0(PAM8_L0), .PAM8_L1(PAM8_L1), .PAM8_L2(PAM8_L2), .PAM8_L3(PAM8_L3),
    .PAM8_L4(PAM8_L4), .PAM8_L5(PAM8_L5), .PAM8_L6(PAM8_L6), .PAM8_L7(PAM8_L7)
  ) u_unified (
    .clk(clk), .rst_n(rst_n), .in_valid(in_valid), .mode(mode), .ch_case_sel(2'd0),
    .din_flat(din_flat), .raw_flat(raw_flat),
    .dout_flat(dout_unified), .out_valid(out_valid_unified), .cand_count_sum(cand_sum_unified),
    .ps_expand_sum(ps_expand_sum_unified), .ns_expand_sum(ns_expand_sum_unified),
    .dbg_raw0(dbg_raw0_unified), .dbg_ch0(dbg_ch0_unified)
  );

  initial clk = 1'b0;
  always #1 clk = ~clk;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      tx_valid_shreg <= '0;
    else
      tx_valid_shreg <= {tx_valid_shreg[EXP_DEPTH-2:0], in_valid};
  end

  always @(posedge clk) begin
    if (rst_n && in_valid) begin
      total_in_sym_phase    = total_in_sym_phase + LANES;
      cand_acc_allfs_phase   = cand_acc_allfs_phase + cand_sum_allfs;
      cand_acc_hybrid_phase  = cand_acc_hybrid_phase + cand_sum_hybrid;
      cand_acc_allrs_phase   = cand_acc_allrs_phase + cand_sum_allrs;
      cand_acc_unified_phase = cand_acc_unified_phase + cand_sum_unified;
      ps_expand_acc_allfs_phase   = ps_expand_acc_allfs_phase + ps_expand_sum_allfs;
      ns_expand_acc_allfs_phase   = ns_expand_acc_allfs_phase + ns_expand_sum_allfs;
      ps_expand_acc_hybrid_phase  = ps_expand_acc_hybrid_phase + ps_expand_sum_hybrid;
      ns_expand_acc_hybrid_phase  = ns_expand_acc_hybrid_phase + ns_expand_sum_hybrid;
      ps_expand_acc_allrs_phase   = ps_expand_acc_allrs_phase + ps_expand_sum_allrs;
      ns_expand_acc_allrs_phase   = ns_expand_acc_allrs_phase + ns_expand_sum_allrs;
      ps_expand_acc_unified_phase = ps_expand_acc_unified_phase + ps_expand_sum_unified;
      ns_expand_acc_unified_phase = ns_expand_acc_unified_phase + ns_expand_sum_unified;
    end
  end

  always @(posedge clk) begin
    int ln;
    int li;
    int lag_abs;
    int beat_mis_h;
    int beat_mis_r;
    int beat_mis_u;
    int beat_err_allfs;
    int beat_err_hybrid;
    int beat_err_allrs;
    int beat_err_unified;
    logic signed [7:0] expv;
    logic signed [7:0] y_allfs;
    logic signed [7:0] y_hybrid;
    logic signed [7:0] y_allrs;
    logic signed [7:0] y_unified;

    if (rst_n && tx_valid_shreg[LAG_MAX]) begin
      if (out_valid_allfs !== out_valid_hybrid)
        valid_mismatch_hyb_phase = valid_mismatch_hyb_phase + 1;
      if (out_valid_allfs !== out_valid_allrs)
        valid_mismatch_rs_phase = valid_mismatch_rs_phase + 1;
      if (out_valid_allfs !== out_valid_unified)
        valid_mismatch_uni_phase = valid_mismatch_uni_phase + 1;

      if (out_valid_allfs && out_valid_hybrid && out_valid_allrs && out_valid_unified) begin
        total_sym_phase = total_sym_phase + LANES;

        beat_mis_h = 0;
        beat_mis_r = 0;
        beat_mis_u = 0;
        for (ln = 0; ln < LANES; ln = ln + 1) begin
          y_allfs   = lane_get(dout_allfs, ln);
          y_hybrid  = lane_get(dout_hybrid, ln);
          y_allrs   = lane_get(dout_allrs, ln);
          y_unified = lane_get(dout_unified, ln);
          if (y_hybrid  !== y_allfs) beat_mis_h = beat_mis_h + 1;
          if (y_allrs   !== y_allfs) beat_mis_r = beat_mis_r + 1;
          if (y_unified !== y_allfs) beat_mis_u = beat_mis_u + 1;
        end
        mis_hybrid_vs_fs_phase  = mis_hybrid_vs_fs_phase + beat_mis_h;
        mis_allrs_vs_fs_phase   = mis_allrs_vs_fs_phase + beat_mis_r;
        mis_unified_vs_fs_phase = mis_unified_vs_fs_phase + beat_mis_u;

        for (li = 0; li < NUM_LAGS; li = li + 1) begin
          lag_abs = LAG_MIN + li;
          beat_err_allfs   = 0;
          beat_err_hybrid  = 0;
          beat_err_allrs   = 0;
          beat_err_unified = 0;

          for (ln = 0; ln < LANES; ln = ln + 1) begin
            expv      = exp_shift[ln][lag_abs];
            y_allfs   = lane_get(dout_allfs, ln);
            y_hybrid  = lane_get(dout_hybrid, ln);
            y_allrs   = lane_get(dout_allrs, ln);
            y_unified = lane_get(dout_unified, ln);

            if ((y_allfs   !== expv) && (y_allfs   !== -expv)) beat_err_allfs   = beat_err_allfs + 1;
            if ((y_hybrid  !== expv) && (y_hybrid  !== -expv)) beat_err_hybrid  = beat_err_hybrid + 1;
            if ((y_allrs   !== expv) && (y_allrs   !== -expv)) beat_err_allrs   = beat_err_allrs + 1;
            if ((y_unified !== expv) && (y_unified !== -expv)) beat_err_unified = beat_err_unified + 1;
          end

          err_allfs_lag[li]   = err_allfs_lag[li]   + beat_err_allfs;
          err_hybrid_lag[li]  = err_hybrid_lag[li]  + beat_err_hybrid;
          err_allrs_lag[li]   = err_allrs_lag[li]   + beat_err_allrs;
          err_unified_lag[li] = err_unified_lag[li] + beat_err_unified;
        end
      end
    end
  end

  initial begin : STIM
    int mode_idx;
    int ch_case_idx;
    int noise_case_idx;

    current_mode_idx  = 0;
    current_noise_mag = 0;
    current_ch_case   = 0;
    rst_n    = 1'b0;
    in_valid = 1'b0;
    mode     = 2'b00;
    raw_flat = '0;
    din_flat = '0;
    clear_phase_counters();

    repeat (4) @(negedge clk);

    for (ch_case_idx = 0; ch_case_idx < NUM_CH_CASES; ch_case_idx = ch_case_idx + 1) begin
      for (noise_case_idx = 0; noise_case_idx < NUM_NOISE_CASES; noise_case_idx = noise_case_idx + 1) begin
        for (mode_idx = 0; mode_idx < 3; mode_idx = mode_idx + 1) begin
          case (mode_idx)
            0: run_sweep_case(2'b00, 0, ch_case_idx, noise_mag_value(noise_case_idx), SYMS_PER_CASE);
            1: run_sweep_case(2'b01, 1, ch_case_idx, noise_mag_value(noise_case_idx), SYMS_PER_CASE);
            2: run_sweep_case(2'b10, 2, ch_case_idx, noise_mag_value(noise_case_idx), SYMS_PER_CASE);
          endcase
        end
      end
    end

    $display("========================================");
    $display("4-way MLSD sweep completed");
    $display("LANES=%0d  TB=%0d  SYMS_PER_CASE=%0d", LANES, TB, SYMS_PER_CASE);
    $display("Sweeps: mode(3) x channel_case(%0d) x noise_case(%0d) x lag(%0d..%0d)",
             NUM_CH_CASES, NUM_NOISE_CASES, LAG_MIN, LAG_MAX);
    $display("Architectures: all-FS / hybrid / all-RS / unified");
    $display("========================================");
    $finish;
  end

endmodule


