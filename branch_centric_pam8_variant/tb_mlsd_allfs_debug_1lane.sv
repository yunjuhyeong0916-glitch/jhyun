`timescale 1ns/1ps

module tb_mlsd_allfs_debug_1lane;

  localparam int TB              = 40;
  localparam int MET_W           = 16;
  localparam int PR_SHIFT        = 2;
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
  localparam int LAG_SWEEP       = 4;
  localparam int EXP_DEPTH       = TB + FE_LAT + LAG_SWEEP + 8;
  localparam int LAG_CENTER      = TB + FE_LAT - 1;
  localparam int LAG_MIN         = LAG_CENTER - LAG_SWEEP;
  localparam int LAG_MAX         = LAG_CENTER + LAG_SWEEP;
  localparam int NUM_LAGS        = (2 * LAG_SWEEP) + 1;
  localparam int DRAIN_CYCLES    = TB + FE_LAT + 16;

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

  logic clk;
  logic rst_n;
  logic in_valid;
  logic [1:0] mode;

  logic signed [7:0] raw_samp;
  logic signed [7:0] noise_in;
  logic signed [7:0] noise_d1;
  logic signed [7:0] noise_d2;
  logic signed [7:0] noise_d3;
  logic signed [CH_OW-1:0] ch_mid;
  logic signed [EQ_OW-1:0] eq_mid;
  logic signed [7:0] din_samp;
  logic ch_out_valid;
  logic eq_out_valid;
  logic out_valid;
  logic signed [7:0] a_hat8;

  logic [6:0] prbs_state;
  logic [6:0] noise_state;
  logic signed [7:0] exp_shift [0:EXP_DEPTH-1];
  logic [EXP_DEPTH-1:0] tx_valid_shreg;
  logic signed [CH_CW-1:0] ch_coeffs [0:CH_NTAPS-1];
  logic signed [EQ_CW-1:0] eq_coeffs [0:EQ_NTAPS-1];

  integer dbg_mode_idx;
  integer dbg_ch_case_idx;
  integer dbg_noise_mag;
  integer dbg_n_syms;
  integer dbg_compare_lag;
  integer dbg_print_limit;
  integer total_out;
  integer total_err_cmp;
  integer err_lag [0:NUM_LAGS-1];
  integer out_idx;
  integer mis_printed;

  integer eq_shifted_i;
  integer din_comb_i;
  integer pr2_now_i;
  logic signed [7:0] pr2_now_sat;

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
    input int lane_id,
    input logic [1:0] mode_f,
    input bit noise_domain
  );
    int seed_i;
    begin
      seed_i = (((lane_id + 1) * 17) + (noise_domain ? 73 : 11) + mode_f) % 127;
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
          ch_coeffs[0] = 16'sd4915;
          ch_coeffs[1] = 16'sd1638;
          ch_coeffs[2] = 16'sd819;
          ch_coeffs[3] = 16'sd410;
          ch_coeffs[4] = 16'sd205;
          ch_coeffs[5] = 16'sd102;
          ch_coeffs[6] = 16'sd51;
        end
        1: begin
          ch_coeffs[0] = 16'sd6554;
          ch_coeffs[1] = 16'sd1229;
          ch_coeffs[2] = 16'sd410;
          ch_coeffs[3] = 16'sd205;
          ch_coeffs[4] = 16'sd82;
          ch_coeffs[5] = 16'sd41;
          ch_coeffs[6] = 16'sd20;
        end
        2: begin
          ch_coeffs[0] = 16'sd7373;
          ch_coeffs[1] = 16'sd819;
          ch_coeffs[2] = 16'sd205;
          ch_coeffs[3] = 16'sd82;
          ch_coeffs[4] = 16'sd41;
          ch_coeffs[5] = 16'sd20;
          ch_coeffs[6] = 16'sd10;
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
          eq_coeffs[1] = 16'sd0;
          eq_coeffs[2] = 16'sd0;
          eq_coeffs[3] = 16'sd0;
          eq_coeffs[4] = 16'sd0;
          eq_coeffs[5] = 16'sd0;
          eq_coeffs[6] = 16'sd0;
        end
      endcase
    end
  endtask

  task automatic shift_expected(input logic signed [7:0] amp);
    int t;
    begin
      for (t = EXP_DEPTH - 1; t > 0; t = t - 1)
        exp_shift[t] = exp_shift[t-1];
      exp_shift[0] = amp;
    end
  endtask

  task automatic init_mode_context(input logic [1:0] mode_sel);
    int t;
    begin
      prbs_state = prbs7_seed(0, mode_sel, 1'b0);
      noise_state = prbs7_seed(0, mode_sel, 1'b1);
      noise_in = '0;
      for (t = 0; t < EXP_DEPTH; t = t + 1)
        exp_shift[t] = 8'sd0;
      out_idx = 0;
      mis_printed = 0;
      total_out = 0;
      total_err_cmp = 0;
      for (t = 0; t < NUM_LAGS; t = t + 1)
        err_lag[t] = 0;
    end
  endtask

  task automatic drive_one_symbol(
    input logic [1:0] mode_sel,
    input int noise_mag_i
  );
    int idx;
    int noise_bits;
    int noise_i;
    logic signed [7:0] a0;
    begin
      prbs7_next_symbol_idx(mode_sel, prbs_state, idx);
      prbs7_take_bits(8, noise_state, noise_bits);
      a0      = sym_amp_from_idx(mode_sel, idx);
      noise_i = noise_from_prbs7(noise_bits, noise_mag_i);
      raw_samp = a0;
      noise_in = sat8_from_int(noise_i);
      shift_expected(a0);
    end
  endtask

  always #1 clk = ~clk;

  fir_siso_wide #(
    .IW(8), .OW(CH_OW), .CW(CH_CW), .COEFF_FRAC(CH_FRAC), .NTAPS(CH_NTAPS),
    .SAT_EN(CH_SAT_EN), .ROUND_EN(CH_ROUND_EN), .ADVANCE_ON_INVALID(CH_ADV_ON_INV)
  ) u_ch (
    .clk(clk), .rst_n(rst_n), .in_valid(in_valid), .cfg_bypass(1'b0),
    .in_samp(raw_samp), .coeffs(ch_coeffs), .out_valid(ch_out_valid), .out_samp(ch_mid)
  );

  fir_siso_wide #(
    .IW(CH_OW), .OW(EQ_OW), .CW(EQ_CW), .COEFF_FRAC(EQ_FRAC), .NTAPS(EQ_NTAPS),
    .SAT_EN(EQ_SAT_EN), .ROUND_EN(EQ_ROUND_EN), .ADVANCE_ON_INVALID(EQ_ADV_ON_INV)
  ) u_eq (
    .clk(clk), .rst_n(rst_n), .in_valid(ch_out_valid), .cfg_bypass(1'b0),
    .in_samp(ch_mid), .coeffs(eq_coeffs), .out_valid(eq_out_valid), .out_samp(eq_mid)
  );

  always_comb begin
    eq_shifted_i = $signed(eq_mid) >>> PR_SHIFT;
    din_comb_i = eq_shifted_i + $signed(noise_d3);
    din_samp = sat8_from_int(din_comb_i);

    pr2_now_i = (($signed(P0) * $signed(exp_shift[0])) +
                 ($signed(P1) * $signed(exp_shift[1])) +
                 ($signed(P2) * $signed(exp_shift[2]))) >>> PR_SHIFT;
    pr2_now_sat = sat8_from_int(pr2_now_i);
  end

  cmp_allfs_mlsd_core_lane_8b #(
    .TB(TB), .MET_W(MET_W), .PR_SHIFT(PR_SHIFT),
    .P0(P0), .P1(P1), .P2(P2),
    .NRZ_NEG(NRZ_NEG), .NRZ_POS(NRZ_POS),
    .PAM4_L0(PAM4_L0), .PAM4_L1(PAM4_L1), .PAM4_L2(PAM4_L2), .PAM4_L3(PAM4_L3),
    .PAM8_L0(PAM8_L0), .PAM8_L1(PAM8_L1), .PAM8_L2(PAM8_L2), .PAM8_L3(PAM8_L3),
    .PAM8_L4(PAM8_L4), .PAM8_L5(PAM8_L5), .PAM8_L6(PAM8_L6), .PAM8_L7(PAM8_L7)
  ) u_dut (
    .clk(clk), .rst_n(rst_n), .in_valid(eq_out_valid), .mode(mode), .z8(din_samp),
    .out_valid(out_valid), .a_hat8(a_hat8)
  );

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      tx_valid_shreg <= '0;
      noise_d1 <= '0;
      noise_d2 <= '0;
      noise_d3 <= '0;
    end else begin
      tx_valid_shreg <= {tx_valid_shreg[EXP_DEPTH-2:0], in_valid};
      noise_d1 <= in_valid ? noise_in : '0;
      noise_d2 <= noise_d1;
      noise_d3 <= noise_d2;
    end
  end

  always @(posedge clk) begin
    int li;
    int lag_abs;
    int eval_limit;
    logic signed [7:0] expv;
    logic signed [7:0] exp_prev;
    logic signed [7:0] exp_next;
    logic mis_cmp;
    bit count_en;

    if (rst_n && tx_valid_shreg[LAG_MAX] && out_valid) begin
      eval_limit = (dbg_n_syms > (dbg_compare_lag + LAG_SWEEP)) ? (dbg_n_syms - dbg_compare_lag - LAG_SWEEP) : 0;
      count_en = (out_idx < eval_limit);
      expv = exp_shift[dbg_compare_lag];
      exp_prev = exp_shift[dbg_compare_lag - 1];
      exp_next = exp_shift[dbg_compare_lag + 1];
      mis_cmp = ((a_hat8 !== expv) && (a_hat8 !== -expv));
      if (count_en)
        total_out = total_out + 1;
      if (count_en && mis_cmp)
        total_err_cmp = total_err_cmp + 1;

      if ((out_idx < dbg_print_limit) || (mis_cmp && (mis_printed < dbg_print_limit))) begin
        $display("[DBG][SYM] out=%0d mode=%0d ch=%0d noise=%0d raw_now=%0d noise_d3=%0d ch_mid=%0d eq_mid=%0d eq_s=%0d din=%0d pr2_now=%0d y=%0d expL=%0d expL-1=%0d expL+1=%0d mis=%0d dec=%0d best=%0d tb=%0d pm_best=%0d pm0=%0d pm1=%0d pm2=%0d pm3=%0d",
                 out_idx, dbg_mode_idx, dbg_ch_case_idx, dbg_noise_mag,
                 raw_samp, noise_d3, ch_mid, eq_mid, eq_shifted_i, din_samp, pr2_now_sat,
                 a_hat8, expv, exp_prev, exp_next, mis_cmp,
                 u_dut.u_tb.decided_sym, u_dut.u_tb.best_state, u_dut.u_tb.tb_state, u_dut.u_tb.pm_best,
                 u_dut.pm[0], u_dut.pm[1], u_dut.pm[2], u_dut.pm[3]);
      end
      if (mis_cmp)
        mis_printed = mis_printed + 1;

      for (li = 0; li < NUM_LAGS; li = li + 1) begin
        lag_abs = LAG_MIN + li;
        expv = exp_shift[lag_abs];
        if (count_en && (a_hat8 !== expv) && (a_hat8 !== -expv))
          err_lag[li] = err_lag[li] + 1;
      end

      out_idx = out_idx + 1;
    end
  end

  task automatic print_summary;
    int li;
    int lag_abs;
    int best_li;
    integer best_err;
    real ser_cmp;
    real ser_best;
    begin
      $display("----------------------------------------");
      $display("ALLFS 1-lane debug summary");
      $display("MODE=%s CH_CASE=%0d(%s) NOISE_MAG=%0d N_SYMS=%0d COMPARE_LAG=%0d",
               mode_label(dbg_mode_idx), dbg_ch_case_idx, ch_case_label(dbg_ch_case_idx),
               dbg_noise_mag, dbg_n_syms, dbg_compare_lag);
      $display("SER window excludes last COMPARE_LAG+LAG_SWEEP=%0d outputs", (dbg_compare_lag + LAG_SWEEP));
      $display("CH_COEFFS(real) = [%0.4f %0.4f %0.4f %0.4f %0.4f %0.4f %0.4f]",
               coeff_to_real(ch_coeffs[0]), coeff_to_real(ch_coeffs[1]), coeff_to_real(ch_coeffs[2]),
               coeff_to_real(ch_coeffs[3]), coeff_to_real(ch_coeffs[4]), coeff_to_real(ch_coeffs[5]), coeff_to_real(ch_coeffs[6]));
      $display("EQ_COEFFS(real) = [%0.4f %0.4f %0.4f %0.4f %0.4f %0.4f %0.4f]",
               coeff_to_real(eq_coeffs[0]), coeff_to_real(eq_coeffs[1]), coeff_to_real(eq_coeffs[2]),
               coeff_to_real(eq_coeffs[3]), coeff_to_real(eq_coeffs[4]), coeff_to_real(eq_coeffs[5]), coeff_to_real(eq_coeffs[6]));
      if (total_out > 0) begin
        ser_cmp = $itor(total_err_cmp) / $itor(total_out);
        $display("COMPARE_LAG SER = %0.6e (%0d / %0d)", ser_cmp, total_err_cmp, total_out);
      end else begin
        $display("COMPARE_LAG SER = N/A (no outputs captured)");
      end

      best_li = 0;
      best_err = err_lag[0];
      for (li = 0; li < NUM_LAGS; li = li + 1) begin
        lag_abs = LAG_MIN + li;
        if (err_lag[li] < best_err) begin
          best_err = err_lag[li];
          best_li = li;
        end
        if (total_out > 0)
          $display("LAG=%0d SER=%0.6e (%0d / %0d)", lag_abs, $itor(err_lag[li]) / $itor(total_out), err_lag[li], total_out);
      end
      if (total_out > 0) begin
        ser_best = $itor(best_err) / $itor(total_out);
        $display("BEST LAG=%0d SER=%0.6e (%0d / %0d)", LAG_MIN + best_li, ser_best, best_err, total_out);
      end
      $display("----------------------------------------");
    end
  endtask

  initial begin : STIM
    int n;

    dbg_mode_idx = 1;
    dbg_ch_case_idx = 3;
    dbg_noise_mag = 0;
    dbg_n_syms = 128;
    dbg_compare_lag = 42;
    dbg_print_limit = 64;

    void'($value$plusargs("MODE_IDX=%d", dbg_mode_idx));
    void'($value$plusargs("CH_CASE=%d", dbg_ch_case_idx));
    void'($value$plusargs("NOISE_MAG=%d", dbg_noise_mag));
    void'($value$plusargs("N_SYMS=%d", dbg_n_syms));
    void'($value$plusargs("COMPARE_LAG=%d", dbg_compare_lag));
    void'($value$plusargs("PRINT_LIMIT=%d", dbg_print_limit));

    if (dbg_mode_idx < 0 || dbg_mode_idx > 2) dbg_mode_idx = 1;
    if (dbg_ch_case_idx < 0 || dbg_ch_case_idx > 3) dbg_ch_case_idx = 3;
    if (dbg_compare_lag < LAG_MIN + 1 || dbg_compare_lag > LAG_MAX - 1) dbg_compare_lag = 42;
    if (dbg_print_limit < 1) dbg_print_limit = 16;
    if (dbg_n_syms < 1) dbg_n_syms = 64;

    case (dbg_mode_idx)
      0: mode = 2'b00;
      1: mode = 2'b01;
      default: mode = 2'b10;
    endcase

    clk = 1'b0;
    rst_n = 1'b0;
    in_valid = 1'b0;
    raw_samp = '0;
    noise_in = '0;

    load_ch_coeffs(dbg_ch_case_idx);
    load_eq_coeffs(dbg_ch_case_idx);
    init_mode_context(mode);

    $display("========================================");
    $display("ALLFS 1-lane debug TB start");
    $display("MODE=%s CH_CASE=%0d(%s) NOISE_MAG=%0d N_SYMS=%0d COMPARE_LAG=%0d PRINT_LIMIT=%0d",
             mode_label(dbg_mode_idx), dbg_ch_case_idx, ch_case_label(dbg_ch_case_idx),
             dbg_noise_mag, dbg_n_syms, dbg_compare_lag, dbg_print_limit);
    $display("Use +MODE_IDX=0/1/2 +CH_CASE=0..3 +NOISE_MAG=int +N_SYMS=int +COMPARE_LAG=int +PRINT_LIMIT=int");
    $display("========================================");

    repeat (4) @(negedge clk);
    rst_n = 1'b1;
    @(negedge clk);

    in_valid = 1'b1;
    for (n = 0; n < dbg_n_syms; n = n + 1) begin
      drive_one_symbol(mode, dbg_noise_mag);
      @(negedge clk);
    end

    in_valid = 1'b0;
    raw_samp = '0;
    repeat (DRAIN_CYCLES) @(posedge clk);
    print_summary();
    $finish;
  end

endmodule
