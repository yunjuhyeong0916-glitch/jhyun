`timescale 1ns/1ps

module tb_mlsd_4way_channel_compare;

  localparam int LANES           = 64;
  localparam int TB              = 40;
  localparam int MET_W           = 16;
  localparam int PR_SHIFT        = 2;
  localparam int SYMS_PER_CASE   = 16384;
  localparam int NUM_NOISE_CASES = 4;
  localparam int NUM_CH_CASES    = 4;
  localparam int LAG_SWEEP       = 4;

  localparam int CH_NTAPS        = 7;
  localparam int CH_CW           = 16;
  localparam int CH_FRAC         = 13;
  localparam int CH_OW           = 16;
  localparam int CH_LAT          = 1;
  localparam bit CH_SAT_EN       = 1'b0;
  localparam bit CH_ROUND_EN     = 1'b1;
  localparam bit CH_ADV_ON_INV   = 1'b1;

  localparam int EQ_NTAPS        = 7;
  localparam int EQ_CW           = 16;
  localparam int EQ_FRAC         = 13;
  localparam int EQ_OW           = 24;
  localparam int EQ_LAT          = 1;
  localparam bit EQ_SAT_EN       = 1'b0;
  localparam bit EQ_ROUND_EN     = 1'b1;
  localparam bit EQ_ADV_ON_INV   = 1'b1;

  localparam int FE_LAT          = CH_LAT + EQ_LAT;
  localparam int DRAIN_CYCLES    = TB + FE_LAT + 16;

  localparam int EXP_DEPTH       = TB + FE_LAT + LAG_SWEEP + 8;
  localparam int LAG_CENTER      = TB + FE_LAT - 1;
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
  logic [1:0]   ch_case_sel;
  logic [511:0] raw_flat;
  logic [511:0] din_flat;

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
  logic signed [7:0]  exp_shift [0:LANES-1][0:EXP_DEPTH-1];
  logic [EXP_DEPTH-1:0] tx_valid_shreg;

  logic                    ch_out_valid;
  logic                    ch_out_valid_l [0:LANES-1];
  logic                    eq_out_valid;
  logic                    eq_out_valid_l [0:LANES-1];
  logic signed [7:0]       raw_lane      [0:LANES-1];
  logic signed [7:0]       noise_in_lane [0:LANES-1];
  logic signed [7:0]       noise_d1_lane [0:LANES-1];
  logic signed [7:0]       noise_d2_lane [0:LANES-1];
  logic signed [7:0]       noise_d3_lane [0:LANES-1];
  logic signed [CH_OW-1:0] ch_mid_lane   [0:LANES-1];
  logic signed [EQ_OW-1:0] eq_mid_lane   [0:LANES-1];
  logic signed [CH_CW-1:0] ch_coeffs [0:CH_NTAPS-1];
  logic signed [EQ_CW-1:0] eq_coeffs [0:EQ_NTAPS-1];
  logic signed [CH_CW-1:0] ch_coeffs_case0 [0:CH_NTAPS-1];
  logic signed [CH_CW-1:0] ch_coeffs_case1 [0:CH_NTAPS-1];
  logic signed [CH_CW-1:0] ch_coeffs_case2 [0:CH_NTAPS-1];

  logic                    ch_probe_valid_case0;
  logic                    ch_probe_valid_case1;
  logic                    ch_probe_valid_case2;
  logic signed [CH_OW-1:0] ch_probe_mid_case0;
  logic signed [CH_OW-1:0] ch_probe_mid_case1;
  logic signed [CH_OW-1:0] ch_probe_mid_case2;

  // lane0 real probes for channel input/output observation
  real raw0_r;
  real ch0_r;
  real ch0_postshift_r;
  real noise0_r;
  real din0_r;
  real raw0_n;
  real ch0_n;
  real din0_n;
  integer active_noise_mag;
  localparam bit DBG_SANITY_ALLFS = 1'b1;
  localparam int DBG_SANITY_MAX_PRINT = 24;
  integer dbg_sanity_out_count;
  integer dbg_sanity_mis_count;
  real noise0_added_r;
  real noise0_added_n;
  real noise0_added_mag0_r;
  real noise0_added_mag2_r;
  real noise0_added_mag4_r;
  real noise0_added_mag8_r;
  real noise0_added_mag0_n;
  real noise0_added_mag2_n;
  real noise0_added_mag4_n;
  real noise0_added_mag8_n;

  // per-channel lane0 probes
  real raw0_case0_r;
  real ch0_case0_r;
  real ch0_case0_postshift_r;
  real din0_case0_r;
  real raw0_case1_r;
  real ch0_case1_r;
  real ch0_case1_postshift_r;
  real din0_case1_r;
  real raw0_case2_r;
  real ch0_case2_r;
  real ch0_case2_postshift_r;
  real din0_case2_r;
  real raw0_case0_n;
  real ch0_case0_n;
  real din0_case0_n;
  real raw0_case1_n;
  real ch0_case1_n;
  real din0_case1_n;
  real raw0_case2_n;
  real ch0_case2_n;
  real din0_case2_n;

  integer total_sym_phase;
  integer total_out_beat_phase;
  integer total_out_beat_limit_phase;
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

  function automatic real coeff_to_real(input logic signed [CH_CW-1:0] c);
    begin
      coeff_to_real = $itor(c) / (1 << CH_FRAC);
    end
  endfunction

  function automatic [39:0] mode_label(input int mode_idx);
    begin
      case (mode_idx)
        0: mode_label = "NRZ  ";
        1: mode_label = "PAM4 ";
        2: mode_label = "PAM8 ";
        default: mode_label = "UNKWN";
      endcase
    end
  endfunction

  function automatic [111:0] ch_case_label(input int ch_case_idx);
    begin
      case (ch_case_idx)
        0: ch_case_label = "single_tail";
        1: ch_case_label = "weak_tail";
        2: ch_case_label = "very_weak_tail";
        default: ch_case_label = "sanity_pr2";
      endcase
    end
  endfunction

  task automatic load_ch_coeffs(input int ch_case_idx);
    int k;
    begin
      for (k = 0; k < CH_NTAPS; k = k + 1)
        ch_coeffs[k] = 16'sd0;

      case (ch_case_idx)
        0: begin
          ch_coeffs[0] = 16'sd4915; // 0.6000
          ch_coeffs[1] = 16'sd1638; // 0.2000
          ch_coeffs[2] = 16'sd819;  // 0.1000
          ch_coeffs[3] = 16'sd410;  // 0.0500
          ch_coeffs[4] = 16'sd205;  // 0.0250
          ch_coeffs[5] = 16'sd102;  // 0.0125
          ch_coeffs[6] = 16'sd51;   // 0.0062
        end
        1: begin
          ch_coeffs[0] = 16'sd6554; // 0.8000
          ch_coeffs[1] = 16'sd1229; // 0.1500
          ch_coeffs[2] = 16'sd410;  // 0.0500
          ch_coeffs[3] = 16'sd205;  // 0.0250
          ch_coeffs[4] = 16'sd82;   // 0.0100
          ch_coeffs[5] = 16'sd41;   // 0.0050
          ch_coeffs[6] = 16'sd20;   // 0.0024
        end
        2: begin
          ch_coeffs[0] = 16'sd7373; // 0.9000
          ch_coeffs[1] = 16'sd819;  // 0.1000
          ch_coeffs[2] = 16'sd205;  // 0.0250
          ch_coeffs[3] = 16'sd82;   // 0.0100
          ch_coeffs[4] = 16'sd41;   // 0.0050
          ch_coeffs[5] = 16'sd20;   // 0.0024
          ch_coeffs[6] = 16'sd10;   // 0.0012
        end
        default: begin
          ch_coeffs[0] = 16'sd8192;
          ch_coeffs[1] = 16'sd16384;
          ch_coeffs[2] = 16'sd8192;
          ch_coeffs[3] = 16'sd0;
          ch_coeffs[4] = 16'sd0;
          ch_coeffs[5] = 16'sd0;
          ch_coeffs[6] = 16'sd0;
        end
      endcase
    end
  endtask

  task automatic load_eq_coeffs(input int ch_case_idx);
    int k;
    begin
      for (k = 0; k < EQ_NTAPS; k = k + 1)
        eq_coeffs[k] = 16'sd0;

      case (ch_case_idx)
        0: begin
          eq_coeffs[0] = 16'sd13651;
          eq_coeffs[1] = 16'sd22749;
          eq_coeffs[2] = 16'sd3793;
          eq_coeffs[3] = -16'sd6192;
          eq_coeffs[4] = -16'sd1031;
          eq_coeffs[5] = -16'sd164;
          eq_coeffs[6] = 16'sd19;
        end
        1: begin
          eq_coeffs[0] = 16'sd10239;
          eq_coeffs[1] = 16'sd18557;
          eq_coeffs[2] = 16'sd6119;
          eq_coeffs[3] = -16'sd2627;
          eq_coeffs[4] = -16'sd598;
          eq_coeffs[5] = -16'sd211;
          eq_coeffs[6] = -16'sd66;
        end
        2: begin
          eq_coeffs[0] = 16'sd9101;
          eq_coeffs[1] = 16'sd17191;
          eq_coeffs[2] = 16'sd6938;
          eq_coeffs[3] = -16'sd1349;
          eq_coeffs[4] = -16'sd284;
          eq_coeffs[5] = -16'sd128;
          eq_coeffs[6] = -16'sd62;
        end
        default: begin
          eq_coeffs[0] = 16'sd8192;
        end
      endcase
    end
  endtask

  initial begin : INIT_DEBUG_CH_COEFFS
    int k;
    for (k = 0; k < CH_NTAPS; k = k + 1) begin
      ch_coeffs_case0[k] = '0;
      ch_coeffs_case1[k] = '0;
      ch_coeffs_case2[k] = '0;
    end

    ch_coeffs_case0[0] = 16'sd4915;
    ch_coeffs_case0[1] = 16'sd1638;
    ch_coeffs_case0[2] = 16'sd819;
    ch_coeffs_case0[3] = 16'sd410;
    ch_coeffs_case0[4] = 16'sd205;
    ch_coeffs_case0[5] = 16'sd102;
    ch_coeffs_case0[6] = 16'sd51;

    ch_coeffs_case1[0] = 16'sd6554;
    ch_coeffs_case1[1] = 16'sd1229;
    ch_coeffs_case1[2] = 16'sd410;
    ch_coeffs_case1[3] = 16'sd205;
    ch_coeffs_case1[4] = 16'sd82;
    ch_coeffs_case1[5] = 16'sd41;
    ch_coeffs_case1[6] = 16'sd20;

    ch_coeffs_case2[0] = 16'sd7373;
    ch_coeffs_case2[1] = 16'sd819;
    ch_coeffs_case2[2] = 16'sd205;
    ch_coeffs_case2[3] = 16'sd82;
    ch_coeffs_case2[4] = 16'sd41;
    ch_coeffs_case2[5] = 16'sd20;
    ch_coeffs_case2[6] = 16'sd10;
  end

  task automatic shift_expected_lane(
    input int ln,
    input logic signed [7:0] amp
  );
    int t;
    begin
      for (t = EXP_DEPTH - 1; t > 0; t = t - 1)
        exp_shift[ln][t] = exp_shift[ln][t-1];
      exp_shift[ln][0] = amp;
    end
  endtask

  task automatic init_mode_context(input logic [1:0] mode_sel);
    int ln;
    int t;
    begin
      for (ln = 0; ln < LANES; ln = ln + 1) begin
        prbs_state[ln]  = prbs7_seed(ln, mode_sel, 1'b0);
        noise_state[ln] = prbs7_seed(ln, mode_sel, 1'b1);
        noise_in_lane[ln] = '0;
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
      total_out_beat_phase = 0;
      total_out_beat_limit_phase = 0;
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
    input int noise_mag_i
  );
    int ln;
    int idx;
    int noise_bits;
    int noise_i;
    logic signed [7:0] a0;
    begin
      raw_flat = '0;
      for (ln = 0; ln < LANES; ln = ln + 1) begin
        prbs7_next_symbol_idx(mode_sel, prbs_state[ln], idx);
        prbs7_take_bits(8, noise_state[ln], noise_bits);
        a0      = sym_amp_from_idx(mode_sel, idx);
        noise_i = noise_from_prbs7(noise_bits, noise_mag_i);

        lane_set(raw_flat, ln, a0);
        noise_in_lane[ln] = sat8_from_int(noise_i);
        shift_expected_lane(ln, a0);
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
      $display("MODE=%s  CH_CASE=%0d(%s)  NOISE_MAG=%0d  symbols=%0d",
               mode_label(mode_idx), ch_case_idx, ch_case_label(ch_case_idx), noise_mag_i, total_sym_phase);
      $display("SER window excludes last LAG_MAX+LAG_SWEEP=%0d outputs per lane", (LAG_MAX + LAG_SWEEP));
      $display("Stimulus=PRBS7 symbol stream");
      $display("CH_COEFFS(real) = [%0.4f %0.4f %0.4f %0.4f %0.4f %0.4f %0.4f]",
               coeff_to_real(ch_coeffs[0]), coeff_to_real(ch_coeffs[1]), coeff_to_real(ch_coeffs[2]),
               coeff_to_real(ch_coeffs[3]), coeff_to_real(ch_coeffs[4]), coeff_to_real(ch_coeffs[5]),
               coeff_to_real(ch_coeffs[6]));
      $display("CH_COEFFS(q13)  = [%0d %0d %0d %0d %0d %0d %0d]",
               ch_coeffs[0], ch_coeffs[1], ch_coeffs[2], ch_coeffs[3], ch_coeffs[4], ch_coeffs[5], ch_coeffs[6]);
      $display("EQ_COEFFS(real) = [%0.4f %0.4f %0.4f %0.4f %0.4f %0.4f %0.4f]",
               coeff_to_real(eq_coeffs[0]), coeff_to_real(eq_coeffs[1]), coeff_to_real(eq_coeffs[2]),
               coeff_to_real(eq_coeffs[3]), coeff_to_real(eq_coeffs[4]), coeff_to_real(eq_coeffs[5]),
               coeff_to_real(eq_coeffs[6]));
      $display("EQ_COEFFS(q13)  = [%0d %0d %0d %0d %0d %0d %0d]",
               eq_coeffs[0], eq_coeffs[1], eq_coeffs[2], eq_coeffs[3], eq_coeffs[4], eq_coeffs[5], eq_coeffs[6]);
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

  genvar cgi;
  generate
    for (cgi = 0; cgi < LANES; cgi = cgi + 1) begin : GEN_CH
      assign raw_lane[cgi] = $signed(raw_flat[8*cgi +: 8]);
      fir_siso_wide #(
        .IW(8),
        .OW(CH_OW),
        .CW(CH_CW),
        .COEFF_FRAC(CH_FRAC),
        .NTAPS(CH_NTAPS),
        .SAT_EN(CH_SAT_EN),
        .ROUND_EN(CH_ROUND_EN),
        .ADVANCE_ON_INVALID(CH_ADV_ON_INV)
      ) u_ch (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .cfg_bypass(1'b0),
        .in_samp(raw_lane[cgi]),
        .coeffs(ch_coeffs),
        .out_valid(ch_out_valid_l[cgi]),
        .out_samp(ch_mid_lane[cgi])
      );
    end
  endgenerate

  assign ch_out_valid = ch_out_valid_l[0];

  genvar egi;
  generate
    for (egi = 0; egi < LANES; egi = egi + 1) begin : GEN_EQ
      fir_siso_wide #(
        .IW(CH_OW),
        .OW(EQ_OW),
        .CW(EQ_CW),
        .COEFF_FRAC(EQ_FRAC),
        .NTAPS(EQ_NTAPS),
        .SAT_EN(EQ_SAT_EN),
        .ROUND_EN(EQ_ROUND_EN),
        .ADVANCE_ON_INVALID(EQ_ADV_ON_INV)
      ) u_eq (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(ch_out_valid_l[egi]),
        .cfg_bypass(1'b0),
        .in_samp(ch_mid_lane[egi]),
        .coeffs(eq_coeffs),
        .out_valid(eq_out_valid_l[egi]),
        .out_samp(eq_mid_lane[egi])
      );
    end
  endgenerate

  assign eq_out_valid = eq_out_valid_l[0];
  fir_siso_wide #(
    .IW(8),
    .OW(CH_OW),
    .CW(CH_CW),
    .COEFF_FRAC(CH_FRAC),
    .NTAPS(CH_NTAPS),
    .SAT_EN(CH_SAT_EN),
    .ROUND_EN(CH_ROUND_EN),
    .ADVANCE_ON_INVALID(CH_ADV_ON_INV)
  ) u_ch_case0_probe (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .cfg_bypass(1'b0),
    .in_samp(raw_lane[0]),
    .coeffs(ch_coeffs_case0),
    .out_valid(ch_probe_valid_case0),
    .out_samp(ch_probe_mid_case0)
  );

  fir_siso_wide #(
    .IW(8),
    .OW(CH_OW),
    .CW(CH_CW),
    .COEFF_FRAC(CH_FRAC),
    .NTAPS(CH_NTAPS),
    .SAT_EN(CH_SAT_EN),
    .ROUND_EN(CH_ROUND_EN),
    .ADVANCE_ON_INVALID(CH_ADV_ON_INV)
  ) u_ch_case1_probe (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .cfg_bypass(1'b0),
    .in_samp(raw_lane[0]),
    .coeffs(ch_coeffs_case1),
    .out_valid(ch_probe_valid_case1),
    .out_samp(ch_probe_mid_case1)
  );

  fir_siso_wide #(
    .IW(8),
    .OW(CH_OW),
    .CW(CH_CW),
    .COEFF_FRAC(CH_FRAC),
    .NTAPS(CH_NTAPS),
    .SAT_EN(CH_SAT_EN),
    .ROUND_EN(CH_ROUND_EN),
    .ADVANCE_ON_INVALID(CH_ADV_ON_INV)
  ) u_ch_case2_probe (
    .clk(clk),
    .rst_n(rst_n),
    .in_valid(in_valid),
    .cfg_bypass(1'b0),
    .in_samp(raw_lane[0]),
    .coeffs(ch_coeffs_case2),
    .out_valid(ch_probe_valid_case2),
    .out_samp(ch_probe_mid_case2)
  );

  always_comb begin
    int ln;
    integer x;
    for (ln = 0; ln < LANES; ln = ln + 1) begin
      x = ($signed(eq_mid_lane[ln]) >>> PR_SHIFT) + $signed(noise_d3_lane[ln]);
      din_flat[8*ln +: 8] = sat8_from_int(x);
    end
  end

  always_comb begin
    integer x_case0;
    integer x_case1;
    integer x_case2;

    raw0_r          = $itor(raw_lane[0]);
    ch0_r           = $itor(ch_mid_lane[0]);
    ch0_postshift_r = $itor($signed(ch_mid_lane[0]) >>> PR_SHIFT);
    noise0_r        = $itor(noise_d1_lane[0]);
    noise0_added_r  = $itor(noise_d3_lane[0]);
    din0_r          = $itor($signed(din_flat[7:0]));

    raw0_n          = raw0_r / 127.0;
    ch0_n           = ch0_r / 127.0;
    din0_n          = din0_r / 127.0;
    noise0_added_n  = noise0_added_r / 127.0;

    noise0_added_mag0_r = 0.0;
    noise0_added_mag2_r = 0.0;
    noise0_added_mag4_r = 0.0;
    noise0_added_mag8_r = 0.0;
    case (active_noise_mag)
      0: noise0_added_mag0_r = noise0_added_r;
      2: noise0_added_mag2_r = noise0_added_r;
      4: noise0_added_mag4_r = noise0_added_r;
      8: noise0_added_mag8_r = noise0_added_r;
      default: ;
    endcase
    noise0_added_mag0_n = noise0_added_mag0_r / 127.0;
    noise0_added_mag2_n = noise0_added_mag2_r / 127.0;
    noise0_added_mag4_n = noise0_added_mag4_r / 127.0;
    noise0_added_mag8_n = noise0_added_mag8_r / 127.0;

    x_case0 = ($signed(ch_probe_mid_case0) >>> PR_SHIFT) + $signed(noise_d1_lane[0]);
    x_case1 = ($signed(ch_probe_mid_case1) >>> PR_SHIFT) + $signed(noise_d1_lane[0]);
    x_case2 = ($signed(ch_probe_mid_case2) >>> PR_SHIFT) + $signed(noise_d1_lane[0]);

    raw0_case0_r          = raw0_r;
    ch0_case0_r           = $itor(ch_probe_mid_case0);
    ch0_case0_postshift_r = $itor($signed(ch_probe_mid_case0) >>> PR_SHIFT);
    din0_case0_r          = $itor(sat8_from_int(x_case0));

    raw0_case1_r          = raw0_r;
    ch0_case1_r           = $itor(ch_probe_mid_case1);
    ch0_case1_postshift_r = $itor($signed(ch_probe_mid_case1) >>> PR_SHIFT);
    din0_case1_r          = $itor(sat8_from_int(x_case1));

    raw0_case2_r          = raw0_r;
    ch0_case2_r           = $itor(ch_probe_mid_case2);
    ch0_case2_postshift_r = $itor($signed(ch_probe_mid_case2) >>> PR_SHIFT);
    din0_case2_r          = $itor(sat8_from_int(x_case2));

    raw0_case0_n = raw0_case0_r / 127.0;
    ch0_case0_n  = ch0_case0_r / 127.0;
    din0_case0_n = din0_case0_r / 127.0;

    raw0_case1_n = raw0_case1_r / 127.0;
    ch0_case1_n  = ch0_case1_r / 127.0;
    din0_case1_n = din0_case1_r / 127.0;

    raw0_case2_n = raw0_case2_r / 127.0;
    ch0_case2_n  = ch0_case2_r / 127.0;
    din0_case2_n = din0_case2_r / 127.0;
  end

  CMP_ALLFS_MLSD_DSP_64LANE_8B #(
    .TB(TB), .MET_W(MET_W),
    .P0(P0), .P1(P1), .P2(P2),
    .NRZ_NEG(NRZ_NEG), .NRZ_POS(NRZ_POS),
    .PAM4_L0(PAM4_L0), .PAM4_L1(PAM4_L1), .PAM4_L2(PAM4_L2), .PAM4_L3(PAM4_L3),
    .PAM8_L0(PAM8_L0), .PAM8_L1(PAM8_L1), .PAM8_L2(PAM8_L2), .PAM8_L3(PAM8_L3),
    .PAM8_L4(PAM8_L4), .PAM8_L5(PAM8_L5), .PAM8_L6(PAM8_L6), .PAM8_L7(PAM8_L7)
  ) u_allfs (
    .clk(clk), .rst_n(rst_n), .in_valid(eq_out_valid), .mode(mode),
    .din_flat(din_flat), .raw_flat(raw_flat),
    .dout_flat(dout_allfs), .out_valid(out_valid_allfs), .cand_count_sum(cand_sum_allfs),
    .dbg_raw0(dbg_raw0_allfs), .dbg_ch0(dbg_ch0_allfs)
  );

  CMP_HYBRID_MLSD_DSP_64LANE_8B #(
    .TB(TB), .MET_W(MET_W), .K_CFG(K_CFG),
    .P0(P0), .P1(P1), .P2(P2),
    .NRZ_NEG(NRZ_NEG), .NRZ_POS(NRZ_POS),
    .PAM4_L0(PAM4_L0), .PAM4_L1(PAM4_L1), .PAM4_L2(PAM4_L2), .PAM4_L3(PAM4_L3),
    .PAM8_L0(PAM8_L0), .PAM8_L1(PAM8_L1), .PAM8_L2(PAM8_L2), .PAM8_L3(PAM8_L3),
    .PAM8_L4(PAM8_L4), .PAM8_L5(PAM8_L5), .PAM8_L6(PAM8_L6), .PAM8_L7(PAM8_L7)
  ) u_hybrid (
    .clk(clk), .rst_n(rst_n), .in_valid(eq_out_valid), .mode(mode), .ch_case_sel(ch_case_sel),
    .din_flat(din_flat), .raw_flat(raw_flat),
    .dout_flat(dout_hybrid), .out_valid(out_valid_hybrid), .cand_count_sum(cand_sum_hybrid),
    .ps_expand_sum(ps_expand_sum_hybrid), .ns_expand_sum(ns_expand_sum_hybrid),
    .dbg_raw0(dbg_raw0_hybrid), .dbg_ch0(dbg_ch0_hybrid)
  );

  CMP_ALLRS_MLSD_DSP_64LANE_8B #(
    .TB(TB), .MET_W(MET_W), .K_CFG(K_CFG),
    .P0(P0), .P1(P1), .P2(P2),
    .NRZ_NEG(NRZ_NEG), .NRZ_POS(NRZ_POS),
    .PAM4_L0(PAM4_L0), .PAM4_L1(PAM4_L1), .PAM4_L2(PAM4_L2), .PAM4_L3(PAM4_L3),
    .PAM8_L0(PAM8_L0), .PAM8_L1(PAM8_L1), .PAM8_L2(PAM8_L2), .PAM8_L3(PAM8_L3),
    .PAM8_L4(PAM8_L4), .PAM8_L5(PAM8_L5), .PAM8_L6(PAM8_L6), .PAM8_L7(PAM8_L7)
  ) u_allrs (
    .clk(clk), .rst_n(rst_n), .in_valid(eq_out_valid), .mode(mode), .ch_case_sel(ch_case_sel),
    .din_flat(din_flat), .raw_flat(raw_flat),
    .dout_flat(dout_allrs), .out_valid(out_valid_allrs), .cand_count_sum(cand_sum_allrs),
    .ps_expand_sum(ps_expand_sum_allrs), .ns_expand_sum(ns_expand_sum_allrs),
    .dbg_raw0(dbg_raw0_allrs), .dbg_ch0(dbg_ch0_allrs)
  );

  CMP_UNIFIED_MLSD_DSP_64LANE_8B #(
    .TB(TB), .MET_W(MET_W), .K_CFG(K_CFG),
    .P0(P0), .P1(P1), .P2(P2),
    .NRZ_NEG(NRZ_NEG), .NRZ_POS(NRZ_POS),
    .PAM4_L0(PAM4_L0), .PAM4_L1(PAM4_L1), .PAM4_L2(PAM4_L2), .PAM4_L3(PAM4_L3),
    .PAM8_L0(PAM8_L0), .PAM8_L1(PAM8_L1), .PAM8_L2(PAM8_L2), .PAM8_L3(PAM8_L3),
    .PAM8_L4(PAM8_L4), .PAM8_L5(PAM8_L5), .PAM8_L6(PAM8_L6), .PAM8_L7(PAM8_L7)
  ) u_unified (
    .clk(clk), .rst_n(rst_n), .in_valid(eq_out_valid), .mode(mode), .ch_case_sel(ch_case_sel),
    .din_flat(din_flat), .raw_flat(raw_flat),
    .dout_flat(dout_unified), .out_valid(out_valid_unified), .cand_count_sum(cand_sum_unified),
    .ps_expand_sum(ps_expand_sum_unified), .ns_expand_sum(ns_expand_sum_unified),
    .dbg_raw0(dbg_raw0_unified), .dbg_ch0(dbg_ch0_unified)
  );

  initial clk = 1'b0;
  always #1 clk = ~clk;

  always_ff @(posedge clk or negedge rst_n) begin
    int ln;
    if (!rst_n) begin
      tx_valid_shreg <= '0;
      for (ln = 0; ln < LANES; ln = ln + 1) begin
        noise_d1_lane[ln] <= '0;
        noise_d2_lane[ln] <= '0;
        noise_d3_lane[ln] <= '0;
      end
    end else begin
      tx_valid_shreg <= {tx_valid_shreg[EXP_DEPTH-2:0], in_valid};
      for (ln = 0; ln < LANES; ln = ln + 1) begin
        noise_d1_lane[ln] <= in_valid ? noise_in_lane[ln] : '0;
        noise_d2_lane[ln] <= noise_d1_lane[ln];
        noise_d3_lane[ln] <= noise_d2_lane[ln];
      end
    end
  end

  always_ff @(posedge clk) begin
    int ln;
    if (rst_n) begin
      for (ln = 1; ln < LANES; ln = ln + 1) begin
        if (ch_out_valid_l[ln] !== ch_out_valid_l[0])
          $error("Channel out_valid mismatch at lane %0d", ln);
        if (eq_out_valid_l[ln] !== eq_out_valid_l[0])
          $error("EQ out_valid mismatch at lane %0d", ln);
      end
    end
  end

  always @(posedge clk) begin
    if (rst_n && eq_out_valid) begin
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
    bit count_en;
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
        count_en = (total_out_beat_phase < total_out_beat_limit_phase);

        if (count_en) begin
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

        total_out_beat_phase = total_out_beat_phase + 1;
      end
    end
  end

  always @(posedge clk) begin
    logic signed [7:0] dbg_raw_cur;
    logic signed [7:0] dbg_din_cur;
    logic signed [7:0] dbg_y_allfs;
    logic signed [7:0] dbg_exp41;
    logic signed [7:0] dbg_exp42;
    logic signed [7:0] dbg_exp43;
    logic dbg_mis42;

    if (DBG_SANITY_ALLFS &&
        rst_n &&
        (ch_case_sel == 2'd3) &&
        (active_noise_mag == 0) &&
        (mode != 2'b00) &&
        out_valid_allfs) begin
      dbg_raw_cur = lane_get(raw_flat, 0);
      dbg_din_cur = lane_get(din_flat, 0);
      dbg_y_allfs = lane_get(dout_allfs, 0);
      dbg_exp41   = exp_shift[0][41];
      dbg_exp42   = exp_shift[0][42];
      dbg_exp43   = exp_shift[0][43];
      dbg_mis42   = ((dbg_y_allfs !== dbg_exp42) && (dbg_y_allfs !== -dbg_exp42));

      if (dbg_sanity_out_count < DBG_SANITY_MAX_PRINT) begin
        $display("[DBG][ALLFS][SANITY] mode=%0d noise=%0d out_idx=%0d raw_cur=%0d din_cur=%0d exp41=%0d exp42=%0d exp43=%0d y=%0d dec_sym=%0d best_state=%0d tb_state=%0d pm_best=%0d mis42=%0d",
                 mode, active_noise_mag, dbg_sanity_out_count,
                 dbg_raw_cur, dbg_din_cur, dbg_exp41, dbg_exp42, dbg_exp43, dbg_y_allfs,
                 u_allfs.GEN_LANE[0].u_lane.u_tb.decided_sym,
                 u_allfs.GEN_LANE[0].u_lane.u_tb.best_state,
                 u_allfs.GEN_LANE[0].u_lane.u_tb.tb_state,
                 u_allfs.GEN_LANE[0].u_lane.u_tb.pm_best,
                 dbg_mis42);
      end

      if (dbg_mis42 && (dbg_sanity_mis_count < DBG_SANITY_MAX_PRINT)) begin
        $display("[DBG][ALLFS][MIS42] mode=%0d mis_idx=%0d exp42=%0d y=%0d exp41=%0d exp43=%0d dec_sym=%0d best_state=%0d tb_state=%0d pm_best=%0d",
                 mode, dbg_sanity_mis_count,
                 dbg_exp42, dbg_y_allfs, dbg_exp41, dbg_exp43,
                 u_allfs.GEN_LANE[0].u_lane.u_tb.decided_sym,
                 u_allfs.GEN_LANE[0].u_lane.u_tb.best_state,
                 u_allfs.GEN_LANE[0].u_lane.u_tb.tb_state,
                 u_allfs.GEN_LANE[0].u_lane.u_tb.pm_best);
        dbg_sanity_mis_count = dbg_sanity_mis_count + 1;
      end

      dbg_sanity_out_count = dbg_sanity_out_count + 1;
    end
  end

  task automatic run_sweep_case(
    input logic [1:0] mode_sel,
    input int mode_idx,
    input int ch_case_idx,
    input int noise_mag_i,
    input int n_syms
  );
    int n;
    begin
      clear_phase_counters();
      total_out_beat_limit_phase = (n_syms > (LAG_MAX + LAG_SWEEP)) ? (n_syms - LAG_MAX - LAG_SWEEP) : 0;
      active_noise_mag = noise_mag_i;
      dbg_sanity_out_count = 0;
      dbg_sanity_mis_count = 0;
      mode       = mode_sel;
      ch_case_sel = ch_case_idx[1:0];
      rst_n      = 1'b0;
      in_valid   = 1'b0;
      raw_flat   = '0;
      load_ch_coeffs(ch_case_idx);
      load_eq_coeffs(ch_case_idx);
      init_mode_context(mode_sel);

      repeat (4) @(negedge clk);
      rst_n = 1'b1;
      @(negedge clk);

      in_valid = 1'b1;
      for (n = 0; n < n_syms; n = n + 1) begin
        drive_one_symbol(mode_sel, noise_mag_i);
        @(negedge clk);
      end

      in_valid = 1'b0;
      raw_flat = '0;
      repeat (DRAIN_CYCLES) @(posedge clk);
      print_phase_summary(mode_idx, ch_case_idx, noise_mag_i);
      active_noise_mag = -1;
    end
  endtask

  initial begin : STIM
    int mode_idx;
    int ch_case_idx;
    int noise_case_idx;
    int run_n_syms;
    int mode_sel;
    int ch_sel;
    int noise_sel;

    rst_n       = 1'b0;
    in_valid    = 1'b0;
    mode        = 2'b00;
    ch_case_sel = 2'b00;
    raw_flat    = '0;
    active_noise_mag = -1;
    clear_phase_counters();
    repeat (4) @(negedge clk);

    run_n_syms = SYMS_PER_CASE;
    mode_sel   = -1;
    ch_sel     = -1;
    noise_sel  = -1;
    void'($value$plusargs("N_SYMS=%d", run_n_syms));
    void'($value$plusargs("MODE_SEL=%d", mode_sel));
    void'($value$plusargs("CH_SEL=%d", ch_sel));
    void'($value$plusargs("NOISE_SEL=%d", noise_sel));

    for (ch_case_idx = 0; ch_case_idx < NUM_CH_CASES; ch_case_idx = ch_case_idx + 1) begin
      if ((ch_sel >= 0) && (ch_case_idx != ch_sel))
        continue;
      for (noise_case_idx = 0; noise_case_idx < NUM_NOISE_CASES; noise_case_idx = noise_case_idx + 1) begin
        if ((noise_sel >= 0) && (noise_case_idx != noise_sel))
          continue;
        for (mode_idx = 0; mode_idx < 3; mode_idx = mode_idx + 1) begin
          if ((mode_sel >= 0) && (mode_idx != mode_sel))
            continue;
          case (mode_idx)
            0: run_sweep_case(2'b00, 0, ch_case_idx, noise_mag_value(noise_case_idx), run_n_syms);
            1: run_sweep_case(2'b01, 1, ch_case_idx, noise_mag_value(noise_case_idx), run_n_syms);
            2: run_sweep_case(2'b10, 2, ch_case_idx, noise_mag_value(noise_case_idx), run_n_syms);
          endcase
        end
      end
    end

    $display("========================================");
    $display("4-way MLSD channel sweep completed");
    $display("LANES=%0d  TB=%0d  CH_NTAPS=%0d  SYMS_PER_CASE=%0d  RUN_N_SYMS=%0d", LANES, TB, CH_NTAPS, SYMS_PER_CASE, run_n_syms);
    $display("Sweeps: mode(3) x channel_case(%0d) x noise_case(%0d) x lag(%0d..%0d)",
             NUM_CH_CASES, NUM_NOISE_CASES, LAG_MIN, LAG_MAX);
    $display("Architectures: all-FS / hybrid / all-RS / unified");
    $display("========================================");
    $finish;
  end

endmodule
