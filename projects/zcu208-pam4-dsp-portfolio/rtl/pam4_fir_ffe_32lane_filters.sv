`timescale 1ns/1ps

// ============================================================================
// FIR_8TAP_TRANSPOSED_64LANE (TIME-UNROLLED, 64 samples/cycle)
// - Immediate coefficient apply (NO coeff register)
// - Transposed-form, time-unrolled (din[i]=x[n+i])
// - DSP-friendly MAC structure
// - Output registered 1 UI
// ============================================================================

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 FFE/FIR Signal Processing
// Module Name: FIR_8TAP_TRANSPOSED_64LANE
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Implements a 64-lane 8-tap transposed FIR for PAM4 TX/RX sample filtering.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module FIR_8TAP_TRANSPOSED_64LANE #(
    parameter int SHIFT = 7
)(
    input  logic               clk,
    input  logic               rst_n,

    input  logic signed [7:0]  din  [0:63],
    input  logic signed [63:0] h_packed,
    output logic signed [7:0]  dout [0:63]
);

    localparam int LANES = 64;
    localparam int NTAPS = 8;

    logic signed [17:0] din_ext [0:LANES-1];
    logic signed [17:0] h_ext   [0:NTAPS-1];
    logic signed [47:0] s_reg   [0:NTAPS-2];
    // Split tap storage into 1D arrays to avoid Vivado 2022.2 3D-RAM inference.
    (* use_dsp = "yes" *) logic signed [47:0] mac0 [0:LANES-1];
    (* use_dsp = "yes" *) logic signed [47:0] mac1 [0:LANES-1];
    (* use_dsp = "yes" *) logic signed [47:0] mac2 [0:LANES-1];
    (* use_dsp = "yes" *) logic signed [47:0] mac3 [0:LANES-1];
    (* use_dsp = "yes" *) logic signed [47:0] mac4 [0:LANES-1];
    (* use_dsp = "yes" *) logic signed [47:0] mac5 [0:LANES-1];
    (* use_dsp = "yes" *) logic signed [47:0] mac6 [0:LANES-1];
    (* use_dsp = "yes" *) logic signed [47:0] mac7 [0:LANES-1];

    function automatic logic signed [7:0] sat8_shift48(
        input logic signed [47:0] x
    );
        logic signed [47:0] y;
        begin
            y = x >>> SHIFT;
            if (y > 48'sd127)       sat8_shift48 = 8'sd127;
            else if (y < -48'sd128) sat8_shift48 = -8'sd128;
            else                    sat8_shift48 = y[7:0];
        end
    endfunction

    always_comb begin
        int i, k;
        for (i = 0; i < LANES; i++)
            din_ext[i] = $signed({{10{din[i][7]}}, din[i]});

        for (k = 0; k < NTAPS; k++)
            h_ext[k] = $signed({{10{h_packed[(k*8)+7]}}, h_packed[(k*8) +: 8]});

        for (i = 0; i < LANES; i++)
            mac7[i] = din_ext[i] * h_ext[7];

        mac6[0] = din_ext[0] * h_ext[6] + s_reg[6];
        for (i = 1; i < LANES; i++)
            mac6[i] = din_ext[i] * h_ext[6] + mac7[i-1];

        mac5[0] = din_ext[0] * h_ext[5] + s_reg[5];
        for (i = 1; i < LANES; i++)
            mac5[i] = din_ext[i] * h_ext[5] + mac6[i-1];

        mac4[0] = din_ext[0] * h_ext[4] + s_reg[4];
        for (i = 1; i < LANES; i++)
            mac4[i] = din_ext[i] * h_ext[4] + mac5[i-1];

        mac3[0] = din_ext[0] * h_ext[3] + s_reg[3];
        for (i = 1; i < LANES; i++)
            mac3[i] = din_ext[i] * h_ext[3] + mac4[i-1];

        mac2[0] = din_ext[0] * h_ext[2] + s_reg[2];
        for (i = 1; i < LANES; i++)
            mac2[i] = din_ext[i] * h_ext[2] + mac3[i-1];

        mac1[0] = din_ext[0] * h_ext[1] + s_reg[1];
        for (i = 1; i < LANES; i++)
            mac1[i] = din_ext[i] * h_ext[1] + mac2[i-1];

        mac0[0] = din_ext[0] * h_ext[0] + s_reg[0];
        for (i = 1; i < LANES; i++)
            mac0[i] = din_ext[i] * h_ext[0] + mac1[i-1];
    end

    always_ff @(posedge clk or negedge rst_n) begin
        int i, k;
        if (!rst_n) begin
            for (k = 0; k < NTAPS-1; k++)
                s_reg[k] <= '0;
            for (i = 0; i < LANES; i++)
                dout[i] <= '0;
        end else begin
            s_reg[0] <= mac1[LANES-1];
            s_reg[1] <= mac2[LANES-1];
            s_reg[2] <= mac3[LANES-1];
            s_reg[3] <= mac4[LANES-1];
            s_reg[4] <= mac5[LANES-1];
            s_reg[5] <= mac6[LANES-1];
            s_reg[6] <= mac7[LANES-1];
            for (i = 0; i < LANES; i++)
                dout[i] <= sat8_shift48(mac0[i]);
        end
    end
endmodule

// ============================================================================
// Direct-form FIR variants used for resource comparison builds.
// - These keep the same packed coefficient conventions as the existing
//   transposed modules.
// - The delay-line history is explicit, so synthesis sees the direct-form
//   multiply-and-adder structure instead of the transposed accumulator chain.
// ============================================================================

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 FFE/FIR Signal Processing
// Module Name: FIR_8TAP_DIRECT_32LANE
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Implements a 32-lane 8-tap direct-form FIR reference filter.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module FIR_8TAP_DIRECT_32LANE #(
    parameter int SHIFT = 7
)(
    input  logic               clk,
    input  logic               rst_n,

    input  logic signed [7:0]  din  [0:31],
    input  logic signed [63:0] h_packed,
    output logic signed [7:0]  dout [0:31]
);
    localparam int LANES = 32;
    localparam int NTAPS = 8;
    localparam int ACC_W = 48;

    logic signed [17:0] din_ext  [0:LANES-1];
    logic signed [17:0] h_ext    [0:NTAPS-1];
    logic signed [17:0] hist_reg [0:NTAPS-2];
    (* use_dsp = "yes" *) logic signed [ACC_W-1:0] acc [0:LANES-1];

    function automatic logic signed [17:0] sample_at(input int idx);
        begin
            if (idx >= 0)
                sample_at = din_ext[idx];
            else
                sample_at = hist_reg[-idx - 1];
        end
    endfunction

    function automatic logic signed [7:0] sat8_shift48(input logic signed [ACC_W-1:0] x);
        logic signed [ACC_W-1:0] y;
        begin
            y = x >>> SHIFT;
            if (y > 48'sd127)       sat8_shift48 = 8'sd127;
            else if (y < -48'sd128) sat8_shift48 = -8'sd128;
            else                    sat8_shift48 = y[7:0];
        end
    endfunction

    always_comb begin
        int i;
        int k;

        for (i = 0; i < LANES; i = i + 1)
            din_ext[i] = $signed({{10{din[i][7]}}, din[i]});
        for (k = 0; k < NTAPS; k = k + 1)
            h_ext[k] = $signed({{10{h_packed[(k*8)+7]}}, h_packed[(k*8) +: 8]});

        for (i = 0; i < LANES; i = i + 1) begin
            acc[i] = '0;
            for (k = 0; k < NTAPS; k = k + 1)
                acc[i] = acc[i] + (sample_at(i - k) * h_ext[k]);
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        int i;
        int k;

        if (!rst_n) begin
            for (k = 0; k < NTAPS-1; k = k + 1)
                hist_reg[k] <= '0;
            for (i = 0; i < LANES; i = i + 1)
                dout[i] <= '0;
        end else begin
            for (k = 0; k < NTAPS-1; k = k + 1)
                hist_reg[k] <= din_ext[LANES - 1 - k];
            for (i = 0; i < LANES; i = i + 1)
                dout[i] <= sat8_shift48(acc[i]);
        end
    end
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 FFE/FIR Signal Processing
// Module Name: FIR_8TAP_DIRECT_64LANE
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Implements a 64-lane 8-tap direct-form FIR reference filter.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module FIR_8TAP_DIRECT_64LANE #(
    parameter int SHIFT = 7
)(
    input  logic               clk,
    input  logic               rst_n,

    input  logic signed [7:0]  din  [0:63],
    input  logic signed [63:0] h_packed,
    output logic signed [7:0]  dout [0:63]
);
    localparam int LANES = 64;
    localparam int NTAPS = 8;
    localparam int ACC_W = 48;

    logic signed [17:0] din_ext  [0:LANES-1];
    logic signed [17:0] h_ext    [0:NTAPS-1];
    logic signed [17:0] hist_reg [0:NTAPS-2];
    (* use_dsp = "yes" *) logic signed [ACC_W-1:0] acc [0:LANES-1];

    function automatic logic signed [17:0] sample_at(input int idx);
        begin
            if (idx >= 0)
                sample_at = din_ext[idx];
            else
                sample_at = hist_reg[-idx - 1];
        end
    endfunction

    function automatic logic signed [7:0] sat8_shift48(input logic signed [ACC_W-1:0] x);
        logic signed [ACC_W-1:0] y;
        begin
            y = x >>> SHIFT;
            if (y > 48'sd127)       sat8_shift48 = 8'sd127;
            else if (y < -48'sd128) sat8_shift48 = -8'sd128;
            else                    sat8_shift48 = y[7:0];
        end
    endfunction

    always_comb begin
        int i;
        int k;

        for (i = 0; i < LANES; i = i + 1)
            din_ext[i] = $signed({{10{din[i][7]}}, din[i]});
        for (k = 0; k < NTAPS; k = k + 1)
            h_ext[k] = $signed({{10{h_packed[(k*8)+7]}}, h_packed[(k*8) +: 8]});

        for (i = 0; i < LANES; i = i + 1) begin
            acc[i] = '0;
            for (k = 0; k < NTAPS; k = k + 1)
                acc[i] = acc[i] + (sample_at(i - k) * h_ext[k]);
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        int i;
        int k;

        if (!rst_n) begin
            for (k = 0; k < NTAPS-1; k = k + 1)
                hist_reg[k] <= '0;
            for (i = 0; i < LANES; i = i + 1)
                dout[i] <= '0;
        end else begin
            for (k = 0; k < NTAPS-1; k = k + 1)
                hist_reg[k] <= din_ext[LANES - 1 - k];
            for (i = 0; i < LANES; i = i + 1)
                dout[i] <= sat8_shift48(acc[i]);
        end
    end
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 FFE/FIR Signal Processing
// Module Name: FIR_Q6_NTAP_DIRECT_32LANE
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Implements a parameterized 32-lane Q6 direct-form FIR filter.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module FIR_Q6_NTAP_DIRECT_32LANE #(
    parameter int LANES = 32,
    parameter int NTAPS = 21,
    parameter int SHIFT = 6
)(
    input  logic               clk,
    input  logic               rst_n,

    input  logic signed [(LANES*8)-1:0] din_flat,
    input  logic signed [(NTAPS*8)-1:0] h_packed,
    output wire signed [(LANES*8)-1:0]  dout_flat
);
    localparam int ACC_W = 48;

    logic signed [7:0] sample_arr [0:LANES-1];
    logic signed [7:0] coeff_arr  [0:NTAPS-1];
    logic signed [7:0] hist_reg   [0:NTAPS-2];
    logic signed [7:0] dout_arr   [0:LANES-1];
    (* use_dsp = "yes" *) logic signed [ACC_W-1:0] acc [0:LANES-1];

    function automatic logic signed [7:0] sample_at(input int idx);
        begin
            if (idx >= 0)
                sample_at = sample_arr[idx];
            else
                sample_at = hist_reg[-idx - 1];
        end
    endfunction

    function automatic logic signed [ACC_W-1:0] mul8_to_acc(
        input logic signed [7:0] a,
        input logic signed [7:0] b
    );
        logic signed [15:0] prod;
        begin
            prod = a * b;
            mul8_to_acc = {{(ACC_W-16){prod[15]}}, prod};
        end
    endfunction

    function automatic logic signed [7:0] sat8_shift48(input logic signed [ACC_W-1:0] x);
        logic signed [ACC_W-1:0] y;
        begin
            y = x >>> SHIFT;
            if (y > 48'sd127)       sat8_shift48 = 8'sd127;
            else if (y < -48'sd128) sat8_shift48 = -8'sd128;
            else                    sat8_shift48 = y[7:0];
        end
    endfunction

    always_comb begin
        int i;
        int k;

        for (i = 0; i < LANES; i = i + 1)
            sample_arr[i] = $signed(din_flat[(i*8) +: 8]);
        for (k = 0; k < NTAPS; k = k + 1)
            coeff_arr[k] = $signed(h_packed[(k*8) +: 8]);

        for (i = 0; i < LANES; i = i + 1) begin
            acc[i] = '0;
            for (k = 0; k < NTAPS; k = k + 1)
                acc[i] = acc[i] + mul8_to_acc(sample_at(i - k), coeff_arr[k]);
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        int i;
        int k;

        if (!rst_n) begin
            for (k = 0; k < NTAPS-1; k = k + 1)
                hist_reg[k] <= '0;
            for (i = 0; i < LANES; i = i + 1)
                dout_arr[i] <= '0;
        end else begin
            for (k = 0; k < NTAPS-1; k = k + 1)
                hist_reg[k] <= sample_arr[LANES - 1 - k];
            for (i = 0; i < LANES; i = i + 1)
                dout_arr[i] <= sat8_shift48(acc[i]);
        end
    end

    genvar lane_i;
    generate
        for (lane_i = 0; lane_i < LANES; lane_i = lane_i + 1) begin : GEN_PACK_DIRECT_Q6
            assign dout_flat[(lane_i*8) +: 8] = dout_arr[lane_i];
        end
    endgenerate
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 FFE/FIR Signal Processing
// Module Name: pam4_fresh_eq29_64lane_direct
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Implements a 64-lane 29-tap direct-form PAM4 equalizer reference path.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module pam4_fresh_eq29_64lane_direct #(
    parameter int LANES = 32,
    parameter int ACTIVE_IN_W = 16,
    parameter int OUT_W = 16,
    parameter int NTAPS = 21
) (
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic signed [(LANES*16)-1:0] din_flat,
    input  logic                    cfg_override_en,
    input  logic signed [(NTAPS*16)-1:0] cfg_coeffs_flat,
    output wire signed [(LANES*OUT_W)-1:0] dout_flat
);
    localparam int IN_W        = 16;
    localparam int COEFF_W     = 16;
    localparam int ACC_W       = 48;
    localparam int SHIFT       = 13;
    localparam int HIST        = NTAPS - 1;
    localparam int DROP_BITS   = (ACTIVE_IN_W >= IN_W) ? 0 : (IN_W - ACTIVE_IN_W);
    localparam int MUL_W       = IN_W + COEFF_W;

    logic signed [IN_W-1:0]    xin      [0:LANES-1];
    logic signed [IN_W-1:0]    xin_eff  [0:LANES-1];
    logic signed [IN_W-1:0]    hist_reg [0:HIST-1];
    logic signed [COEFF_W-1:0] coeff    [0:NTAPS-1];
    (* use_dsp = "yes" *) logic signed [ACC_W-1:0] acc [0:LANES-1];
    logic signed [OUT_W-1:0]   qcur     [0:LANES-1];
    logic signed [OUT_W-1:0]   dout_arr [0:LANES-1];
    logic signed [OUT_W-1:0]   out_reg;

    function automatic logic signed [IN_W-1:0] quantize_input_sample(
        input logic signed [IN_W-1:0] x
    );
        begin
            if (DROP_BITS == 0)
                quantize_input_sample = x;
            else
                quantize_input_sample = (x >>> DROP_BITS) <<< DROP_BITS;
        end
    endfunction

    function automatic logic signed [IN_W-1:0] sample_at(input int idx);
        begin
            if (idx >= 0)
                sample_at = xin_eff[idx];
            else
                sample_at = hist_reg[-idx - 1];
        end
    endfunction

    function automatic logic signed [ACC_W-1:0] mul_to_acc(
        input logic signed [IN_W-1:0] a,
        input logic signed [COEFF_W-1:0] b
    );
        logic signed [MUL_W-1:0] prod;
        begin
            prod = a * b;
            mul_to_acc = {{(ACC_W-MUL_W){prod[MUL_W-1]}}, prod};
        end
    endfunction

    function automatic signed [OUT_W-1:0] quantize_acc_to_out(
        input signed [ACC_W-1:0] x
    );
        logic signed [63:0] xr;
        logic signed [63:0] xs;
        begin
            if (x >= 0)
                xr = $signed({{16{x[ACC_W-1]}}, x}) + (64'sd1 <<< (SHIFT - 1));
            else
                xr = $signed({{16{x[ACC_W-1]}}, x}) - (64'sd1 <<< (SHIFT - 1));
            xs = xr >>> SHIFT;
            if (xs > ((64'sd1 <<< (OUT_W - 1)) - 1))
                quantize_acc_to_out = {1'b0, {(OUT_W-1){1'b1}}};
            else if (xs < -(64'sd1 <<< (OUT_W - 1)))
                quantize_acc_to_out = {1'b1, {(OUT_W-1){1'b0}}};
            else
                quantize_acc_to_out = xs[OUT_W-1:0];
        end
    endfunction

    always_comb begin
        int i;
        int t;

        for (i = 0; i < LANES; i = i + 1) begin
            xin[i] = $signed(din_flat[(i*IN_W) +: IN_W]);
            xin_eff[i] = quantize_input_sample(xin[i]);
        end

        for (t = 0; t < NTAPS; t = t + 1)
            coeff[t] = (cfg_override_en == 1'b1) ? $signed(cfg_coeffs_flat[(t*COEFF_W) +: COEFF_W]) : '0;

        for (i = 0; i < LANES; i = i + 1) begin
            acc[i] = '0;
            for (t = 0; t < NTAPS; t = t + 1)
                acc[i] = acc[i] + mul_to_acc(sample_at(i - t), coeff[t]);
            qcur[i] = quantize_acc_to_out(acc[i]);
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        int i;
        int t;

        if (!rst_n) begin
            for (t = 0; t < HIST; t = t + 1)
                hist_reg[t] <= '0;
            for (i = 0; i < LANES; i = i + 1)
                dout_arr[i] <= '0;
            out_reg <= '0;
        end else begin
            for (t = 0; t < HIST; t = t + 1)
                hist_reg[t] <= xin_eff[LANES - 1 - t];
            dout_arr[0] <= out_reg;
            for (i = 1; i < LANES; i = i + 1)
                dout_arr[i] <= qcur[i - 1];
            out_reg <= qcur[LANES - 1];
        end
    end

    genvar lane_i;
    generate
        for (lane_i = 0; lane_i < LANES; lane_i = lane_i + 1) begin : GEN_PACK_EQ_DIRECT
            assign dout_flat[(lane_i*OUT_W) +: OUT_W] = dout_arr[lane_i];
        end
    endgenerate
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 FFE/FIR Signal Processing
// Module Name: pam4_fresh_tg7_64lane_direct
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Implements a 64-lane 7-tap direct-form PAM4 test-generator shaping path.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module pam4_fresh_tg7_64lane_direct #(
    parameter int LANES = 32,
    parameter int ACTIVE_IN_W = 24,
    parameter int IN_W = 24,
    parameter int OUT_W = IN_W
) (
    input  logic                    clk,
    input  logic                    rst_n,
    input  logic signed [(LANES*IN_W)-1:0] din_flat,
    input  logic                    cfg_override_en,
    input  logic signed [(7*16)-1:0] cfg_coeffs_flat,
    output wire signed [(LANES*OUT_W)-1:0] dout_flat
);
    localparam int NTAPS = 7;
    localparam int HIST  = NTAPS - 1;
    localparam int SHIFT = 13;
    localparam int ACTIVE_W = (ACTIVE_IN_W < 1) ? 1 :
                              ((ACTIVE_IN_W > IN_W) ? IN_W : ACTIVE_IN_W);
    localparam int DROP_BITS = IN_W - ACTIVE_W;
    localparam int ACC_W = (ACTIVE_W >= IN_W) ? 48 : (ACTIVE_W + 16 + 4);
    localparam int EFFECTIVE_SHIFT = (SHIFT > DROP_BITS) ? (SHIFT - DROP_BITS) : 0;
    localparam int ROUND_SHIFT = (EFFECTIVE_SHIFT > 0) ? (EFFECTIVE_SHIFT - 1) : 0;
    localparam int RESTORE_SHIFT = (DROP_BITS > SHIFT) ? (DROP_BITS - SHIFT) : 0;
    localparam int MUL_W = ACTIVE_W + 16;

    localparam logic signed [15:0] DEFAULT_COEFFS [0:NTAPS-1] = '{
        -16'sd292, 16'sd41, -16'sd25, 16'sd11, -16'sd9, 16'sd8180, 16'sd3266
    };

    logic signed [IN_W-1:0]     xin      [0:LANES-1];
    logic signed [ACTIVE_W-1:0] xin_eff  [0:LANES-1];
    logic signed [ACTIVE_W-1:0] hist_reg [0:HIST-1];
    logic signed [15:0]         coeff    [0:NTAPS-1];
    (* use_dsp = "yes" *) logic signed [ACC_W-1:0] acc [0:LANES-1];
    logic signed [OUT_W-1:0]    qcur     [0:LANES-1];
    logic signed [OUT_W-1:0]    dout_arr [0:LANES-1];
    logic signed [OUT_W-1:0]    out_reg;

    function automatic logic signed [ACTIVE_W-1:0] quantize_input_sample(
        input logic signed [IN_W-1:0] x
    );
        logic signed [IN_W-1:0] shifted;
        begin
            shifted = x >>> DROP_BITS;
            quantize_input_sample = shifted[ACTIVE_W-1:0];
        end
    endfunction

    function automatic logic signed [ACTIVE_W-1:0] sample_at(input int idx);
        begin
            if (idx >= 0)
                sample_at = xin_eff[idx];
            else
                sample_at = hist_reg[-idx - 1];
        end
    endfunction

    function automatic logic signed [ACC_W-1:0] mul_to_acc(
        input logic signed [ACTIVE_W-1:0] a,
        input logic signed [15:0] b
    );
        logic signed [MUL_W-1:0] prod;
        begin
            prod = a * b;
            mul_to_acc = {{(ACC_W-MUL_W){prod[MUL_W-1]}}, prod};
        end
    endfunction

    function automatic signed [OUT_W-1:0] quantize_acc_to_out(input signed [ACC_W-1:0] x);
        reg signed [63:0] xr;
        reg signed [63:0] xs;
        begin
            xr = $signed({{(64-ACC_W){x[ACC_W-1]}}, x});
            if (EFFECTIVE_SHIFT > 0) begin
                if (x >= 0)
                    xr = xr + (64'sd1 <<< ROUND_SHIFT);
                else
                    xr = xr - (64'sd1 <<< ROUND_SHIFT);
                xs = xr >>> EFFECTIVE_SHIFT;
            end else begin
                xs = xr;
            end
            if (RESTORE_SHIFT > 0)
                xs = xs <<< RESTORE_SHIFT;
            if (xs > ((64'sd1 <<< (OUT_W - 1)) - 1))
                quantize_acc_to_out = {1'b0, {(OUT_W-1){1'b1}}};
            else if (xs < -(64'sd1 <<< (OUT_W - 1)))
                quantize_acc_to_out = {1'b1, {(OUT_W-1){1'b0}}};
            else
                quantize_acc_to_out = xs[OUT_W-1:0];
        end
    endfunction

    always_comb begin
        int i;
        int t;

        for (i = 0; i < LANES; i = i + 1) begin
            xin[i] = $signed(din_flat[(i*IN_W) +: IN_W]);
            xin_eff[i] = quantize_input_sample(xin[i]);
        end

        for (t = 0; t < NTAPS; t = t + 1)
            coeff[t] = (cfg_override_en == 1'b1) ? $signed(cfg_coeffs_flat[(t*16) +: 16]) : DEFAULT_COEFFS[t];

        for (i = 0; i < LANES; i = i + 1) begin
            acc[i] = '0;
            for (t = 0; t < NTAPS; t = t + 1)
                acc[i] = acc[i] + mul_to_acc(sample_at(i - t), coeff[t]);
            qcur[i] = quantize_acc_to_out(acc[i]);
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        int i;
        int t;

        if (!rst_n) begin
            for (t = 0; t < HIST; t = t + 1)
                hist_reg[t] <= '0;
            for (i = 0; i < LANES; i = i + 1)
                dout_arr[i] <= '0;
            out_reg <= '0;
        end else begin
            for (t = 0; t < HIST; t = t + 1)
                hist_reg[t] <= xin_eff[LANES - 1 - t];
            dout_arr[0] <= out_reg;
            for (i = 1; i < LANES; i = i + 1)
                dout_arr[i] <= qcur[i - 1];
            out_reg <= qcur[LANES - 1];
        end
    end

    genvar lane_i;
    generate
        for (lane_i = 0; lane_i < LANES; lane_i = lane_i + 1) begin : GEN_PACK_TG_DIRECT
            assign dout_flat[(lane_i*OUT_W) +: OUT_W] = dout_arr[lane_i];
        end
    endgenerate
endmodule

// ============================================================================
// FIR_8TAP_TRANSPOSED_32LANE (TIME-UNROLLED, 32 samples/cycle)
// - 32-symbol companion for the 64-lane implementation above.
// - Keeps the same coefficient packing and arithmetic behavior.
// - The 32-lane path is implemented as a vector systolic transposed pipeline:
//   each tap result is registered, while the input vector and coefficient set
//   travel with the block. This preserves output samples with added latency.
// ============================================================================

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 FFE/FIR Signal Processing
// Module Name: FIR_8TAP_TRANSPOSED_32LANE
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Implements a 32-lane 8-tap transposed FIR filter.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module FIR_8TAP_TRANSPOSED_32LANE #(
    parameter int SHIFT = 7
)(
    input  logic               clk,
    input  logic               rst_n,

    input  logic signed [7:0]  din  [0:31],
    input  logic signed [63:0] h_packed,
    output logic signed [7:0]  dout [0:31]
);

    localparam int LANES = 32;
    localparam int NTAPS = 8;

    logic signed [17:0] din_ext [0:LANES-1];
    logic signed [17:0] h_ext_d [0:NTAPS-1];
    logic signed [17:0] h_active_q [0:NTAPS-1];
    logic signed [17:0] x_pipe_q [0:NTAPS-2][0:LANES-1];
    logic signed [17:0] h6_pipe_q;
    logic signed [17:0] h5_pipe_q [0:1];
    logic signed [17:0] h4_pipe_q [0:2];
    logic signed [17:0] h3_pipe_q [0:3];
    logic signed [17:0] h2_pipe_q [0:4];
    logic signed [17:0] h1_pipe_q [0:5];
    logic signed [17:0] h0_pipe_q [0:6];

    (* use_dsp = "yes" *) logic signed [47:0] mac7_q [0:LANES-1];
    (* use_dsp = "yes" *) logic signed [47:0] mac6_q [0:LANES-1];
    (* use_dsp = "yes" *) logic signed [47:0] mac5_q [0:LANES-1];
    (* use_dsp = "yes" *) logic signed [47:0] mac4_q [0:LANES-1];
    (* use_dsp = "yes" *) logic signed [47:0] mac3_q [0:LANES-1];
    (* use_dsp = "yes" *) logic signed [47:0] mac2_q [0:LANES-1];
    (* use_dsp = "yes" *) logic signed [47:0] mac1_q [0:LANES-1];
    (* use_dsp = "yes" *) logic signed [47:0] mac0_q [0:LANES-1];

    logic signed [47:0] s6_feedback_q;
    logic signed [47:0] s5_feedback_q;
    logic signed [47:0] s4_feedback_q;
    logic signed [47:0] s3_feedback_q;
    logic signed [47:0] s2_feedback_q;
    logic signed [47:0] s1_feedback_q;
    logic signed [47:0] s0_feedback_q;

    function automatic logic signed [7:0] sat8_shift48(
        input logic signed [47:0] x
    );
        logic signed [47:0] y;
        begin
            y = x >>> SHIFT;
            if (y > 48'sd127)       sat8_shift48 = 8'sd127;
            else if (y < -48'sd128) sat8_shift48 = -8'sd128;
            else                    sat8_shift48 = y[7:0];
        end
    endfunction

    always_comb begin
        int i, k;
        for (i = 0; i < LANES; i++)
            din_ext[i] = $signed({{10{din[i][7]}}, din[i]});

        for (k = 0; k < NTAPS; k++)
            h_ext_d[k] = $signed({{10{h_packed[(k*8)+7]}}, h_packed[(k*8) +: 8]});
    end

    always_ff @(posedge clk or negedge rst_n) begin
        int i, k, p;
        if (!rst_n) begin
            for (k = 0; k < NTAPS; k++)
                h_active_q[k] <= '0;
            for (p = 0; p < NTAPS-1; p++) begin
                for (i = 0; i < LANES; i++)
                    x_pipe_q[p][i] <= '0;
            end
            h6_pipe_q <= '0;
            for (p = 0; p < 2; p++)
                h5_pipe_q[p] <= '0;
            for (p = 0; p < 3; p++)
                h4_pipe_q[p] <= '0;
            for (p = 0; p < 4; p++)
                h3_pipe_q[p] <= '0;
            for (p = 0; p < 5; p++)
                h2_pipe_q[p] <= '0;
            for (p = 0; p < 6; p++)
                h1_pipe_q[p] <= '0;
            for (p = 0; p < 7; p++)
                h0_pipe_q[p] <= '0;
            s6_feedback_q <= '0;
            s5_feedback_q <= '0;
            s4_feedback_q <= '0;
            s3_feedback_q <= '0;
            s2_feedback_q <= '0;
            s1_feedback_q <= '0;
            s0_feedback_q <= '0;
            for (i = 0; i < LANES; i++) begin
                mac7_q[i] <= '0;
                mac6_q[i] <= '0;
                mac5_q[i] <= '0;
                mac4_q[i] <= '0;
                mac3_q[i] <= '0;
                mac2_q[i] <= '0;
                mac1_q[i] <= '0;
                mac0_q[i] <= '0;
                dout[i] <= '0;
            end
        end else begin
            for (k = 0; k < NTAPS; k++)
                h_active_q[k] <= h_ext_d[k];

            for (i = 0; i < LANES; i++) begin
                mac7_q[i] <= din_ext[i] * h_active_q[7];
                x_pipe_q[0][i] <= din_ext[i];
            end
            h6_pipe_q <= h_active_q[6];
            h5_pipe_q[0] <= h_active_q[5];
            h4_pipe_q[0] <= h_active_q[4];
            h3_pipe_q[0] <= h_active_q[3];
            h2_pipe_q[0] <= h_active_q[2];
            h1_pipe_q[0] <= h_active_q[1];
            h0_pipe_q[0] <= h_active_q[0];

            mac6_q[0] <= x_pipe_q[0][0] * h6_pipe_q + s6_feedback_q;
            for (i = 1; i < LANES; i++)
                mac6_q[i] <= x_pipe_q[0][i] * h6_pipe_q + mac7_q[i-1];
            for (i = 0; i < LANES; i++)
                x_pipe_q[1][i] <= x_pipe_q[0][i];
            h5_pipe_q[1] <= h5_pipe_q[0];
            h4_pipe_q[1] <= h4_pipe_q[0];
            h3_pipe_q[1] <= h3_pipe_q[0];
            h2_pipe_q[1] <= h2_pipe_q[0];
            h1_pipe_q[1] <= h1_pipe_q[0];
            h0_pipe_q[1] <= h0_pipe_q[0];
            s6_feedback_q <= mac7_q[LANES-1];

            mac5_q[0] <= x_pipe_q[1][0] * h5_pipe_q[1] + s5_feedback_q;
            for (i = 1; i < LANES; i++)
                mac5_q[i] <= x_pipe_q[1][i] * h5_pipe_q[1] + mac6_q[i-1];
            for (i = 0; i < LANES; i++)
                x_pipe_q[2][i] <= x_pipe_q[1][i];
            h4_pipe_q[2] <= h4_pipe_q[1];
            h3_pipe_q[2] <= h3_pipe_q[1];
            h2_pipe_q[2] <= h2_pipe_q[1];
            h1_pipe_q[2] <= h1_pipe_q[1];
            h0_pipe_q[2] <= h0_pipe_q[1];
            s5_feedback_q <= mac6_q[LANES-1];

            mac4_q[0] <= x_pipe_q[2][0] * h4_pipe_q[2] + s4_feedback_q;
            for (i = 1; i < LANES; i++)
                mac4_q[i] <= x_pipe_q[2][i] * h4_pipe_q[2] + mac5_q[i-1];
            for (i = 0; i < LANES; i++)
                x_pipe_q[3][i] <= x_pipe_q[2][i];
            h3_pipe_q[3] <= h3_pipe_q[2];
            h2_pipe_q[3] <= h2_pipe_q[2];
            h1_pipe_q[3] <= h1_pipe_q[2];
            h0_pipe_q[3] <= h0_pipe_q[2];
            s4_feedback_q <= mac5_q[LANES-1];

            mac3_q[0] <= x_pipe_q[3][0] * h3_pipe_q[3] + s3_feedback_q;
            for (i = 1; i < LANES; i++)
                mac3_q[i] <= x_pipe_q[3][i] * h3_pipe_q[3] + mac4_q[i-1];
            for (i = 0; i < LANES; i++)
                x_pipe_q[4][i] <= x_pipe_q[3][i];
            h2_pipe_q[4] <= h2_pipe_q[3];
            h1_pipe_q[4] <= h1_pipe_q[3];
            h0_pipe_q[4] <= h0_pipe_q[3];
            s3_feedback_q <= mac4_q[LANES-1];

            mac2_q[0] <= x_pipe_q[4][0] * h2_pipe_q[4] + s2_feedback_q;
            for (i = 1; i < LANES; i++)
                mac2_q[i] <= x_pipe_q[4][i] * h2_pipe_q[4] + mac3_q[i-1];
            for (i = 0; i < LANES; i++)
                x_pipe_q[5][i] <= x_pipe_q[4][i];
            h1_pipe_q[5] <= h1_pipe_q[4];
            h0_pipe_q[5] <= h0_pipe_q[4];
            s2_feedback_q <= mac3_q[LANES-1];

            mac1_q[0] <= x_pipe_q[5][0] * h1_pipe_q[5] + s1_feedback_q;
            for (i = 1; i < LANES; i++)
                mac1_q[i] <= x_pipe_q[5][i] * h1_pipe_q[5] + mac2_q[i-1];
            for (i = 0; i < LANES; i++)
                x_pipe_q[6][i] <= x_pipe_q[5][i];
            h0_pipe_q[6] <= h0_pipe_q[5];
            s1_feedback_q <= mac2_q[LANES-1];

            mac0_q[0] <= x_pipe_q[6][0] * h0_pipe_q[6] + s0_feedback_q;
            for (i = 1; i < LANES; i++)
                mac0_q[i] <= x_pipe_q[6][i] * h0_pipe_q[6] + mac1_q[i-1];
            s0_feedback_q <= mac1_q[LANES-1];

            for (i = 0; i < LANES; i++) begin
                dout[i] <= sat8_shift48(mac0_q[i]);
            end
        end
    end
endmodule

// ============================================================================
// FIR_Q6_NTAP_TRANSPOSED_32LANE
// - RX Q6 FIR wrapper for 8b samples and 8b Q6 coefficients.
// - NTAPS=21, LANES=32 uses three 7-tap transposed partial-sum segments to
//   avoid a long 21-tap single-cycle MAC dependency chain.
// - Short filters use the compact transposed-chain helper.
// ============================================================================

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 FFE/FIR Signal Processing
// Module Name: FIR_Q6_NTAP_TRANSPOSED_32LANE
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Implements a parameterized 32-lane Q6 transposed FIR filter.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module FIR_Q6_NTAP_TRANSPOSED_32LANE #(
    parameter int LANES = 32,
    parameter int NTAPS = 21,
    parameter int SHIFT = 6
)(
    input  logic               clk,
    input  logic               rst_n,
    input  logic               ce,

    input  logic signed [(LANES*8)-1:0]      din_flat,
    input  logic signed [(NTAPS*8)-1:0]      h_packed,
    output wire signed [(LANES*8)-1:0]       dout_flat
);
    generate
        if ((LANES == 32) && (NTAPS == 21)) begin : GEN_RX_EQ21_GROUP_PIPE
            FIR_Q6_21TAP_GROUP_PIPE_32LANE #(
                .SHIFT(SHIFT)
            ) u_group_pipe (
                .clk(clk),
                .rst_n(rst_n),
                .ce(ce),
                .din_flat(din_flat),
                .h_packed(h_packed),
                .dout_flat(dout_flat)
            );
        end else begin : GEN_SHORT_CHAIN
            FIR_Q6_NTAP_CHAIN_32LANE #(
                .LANES(LANES),
                .NTAPS(NTAPS),
                .SHIFT(SHIFT)
            ) u_chain (
                .clk(clk),
                .rst_n(rst_n),
                .ce(ce),
                .din_flat(din_flat),
                .h_packed(h_packed),
                .dout_flat(dout_flat)
            );
        end
    endgenerate
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 FFE/FIR Signal Processing
// Module Name: FIR_Q6_NTAP_CHAIN_32LANE
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Implements a parameterized 32-lane Q6 chained FIR accumulation filter.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module FIR_Q6_NTAP_CHAIN_32LANE #(
    parameter int LANES = 32,
    parameter int NTAPS = 7,
    parameter int SHIFT = 6
)(
    input  logic               clk,
    input  logic               rst_n,
    input  logic               ce,
    input  logic signed [(LANES*8)-1:0]      din_flat,
    input  logic signed [(NTAPS*8)-1:0]      h_packed,
    output wire signed [(LANES*8)-1:0]       dout_flat
);

    localparam int DATA_EXT_W  = 18;
    localparam int COEFF_EXT_W = 18;
    localparam int ACC_W       = 48;

    logic signed [DATA_EXT_W-1:0]  din_ext  [0:LANES-1];
    logic signed [COEFF_EXT_W-1:0] h_ext    [0:NTAPS-1];
    logic signed [ACC_W-1:0]       s_reg    [0:NTAPS-2];
    (* use_dsp = "yes" *) logic signed [ACC_W-1:0] mac_flat [0:(NTAPS*LANES)-1];
    logic signed [7:0]             dout_arr [0:LANES-1];

    function automatic logic signed [7:0] sat8_shift48(
        input logic signed [ACC_W-1:0] x
    );
        logic signed [ACC_W-1:0] y;
        begin
            y = x >>> SHIFT;
            if (y > 48'sd127)       sat8_shift48 = 8'sd127;
            else if (y < -48'sd128) sat8_shift48 = -8'sd128;
            else                    sat8_shift48 = y[7:0];
        end
    endfunction

    function automatic int mac_idx(
        input int tap,
        input int lane
    );
        begin
            mac_idx = (tap * LANES) + lane;
        end
    endfunction

    always_comb begin
        int i;
        int k;
        int kr;

        for (i = 0; i < LANES; i = i + 1)
            din_ext[i] = $signed({{10{din_flat[(i*8)+7]}}, din_flat[(i*8) +: 8]});

        for (k = 0; k < NTAPS; k = k + 1)
            h_ext[k] = $signed({{10{h_packed[(k*8)+7]}}, h_packed[(k*8) +: 8]});

        for (i = 0; i < LANES; i = i + 1)
            mac_flat[mac_idx(NTAPS-1, i)] = din_ext[i] * h_ext[NTAPS-1];

        for (kr = 0; kr < NTAPS-1; kr = kr + 1) begin
            k = NTAPS - 2 - kr;
            mac_flat[mac_idx(k, 0)] = din_ext[0] * h_ext[k] + s_reg[k];
            for (i = 1; i < LANES; i = i + 1)
                mac_flat[mac_idx(k, i)] =
                    din_ext[i] * h_ext[k] + mac_flat[mac_idx(k+1, i-1)];
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        int i;
        int k;
        if (!rst_n) begin
            for (k = 0; k < NTAPS-1; k = k + 1)
                s_reg[k] <= '0;
            for (i = 0; i < LANES; i = i + 1)
                dout_arr[i] <= '0;
        end else if (ce) begin
            for (k = 0; k < NTAPS-1; k = k + 1)
                s_reg[k] <= mac_flat[mac_idx(k+1, LANES-1)];
            for (i = 0; i < LANES; i = i + 1)
                dout_arr[i] <= sat8_shift48(mac_flat[mac_idx(0, i)]);
        end
    end

    genvar lane_i;
    generate
        for (lane_i = 0; lane_i < LANES; lane_i = lane_i + 1) begin : GEN_PACK_CHAIN
            assign dout_flat[(lane_i*8) +: 8] = dout_arr[lane_i];
        end
    endgenerate
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 FFE/FIR Signal Processing
// Module Name: FIR_Q6_7TAP_TRANSPOSED_PARTIAL_32LANE
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Implements a partial 7-tap transposed FIR for 32-lane PAM4 equalization.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module FIR_Q6_7TAP_TRANSPOSED_PARTIAL_32LANE (
    input  logic clk,
    input  logic rst_n,
    input  logic ce,
    input  logic signed [(32*8)-1:0]      din_flat,
    input  logic signed [(7*8)-1:0]       h_packed,
    output wire signed [(32*48)-1:0]      partial_flat
);
    localparam int LANES = 32;
    localparam int NTAPS = 7;
    localparam int ACC_W = 48;
    localparam int EXT_W = 18;

    logic signed [EXT_W-1:0] din_ext  [0:LANES-1];
    logic signed [EXT_W-1:0] h_ext_d  [0:NTAPS-1];
    logic signed [EXT_W-1:0] x_pipe_q [0:NTAPS-2][0:LANES-1];
    logic signed [EXT_W-1:0] h_pipe_q [0:NTAPS-2][0:NTAPS-2];
    (* use_dsp = "yes" *) logic signed [ACC_W-1:0] mac_q [0:NTAPS-1][0:LANES-1];
    logic signed [ACC_W-1:0] feedback_q [0:NTAPS-2];

    always_comb begin
        int lane;
        int tap;

        for (lane = 0; lane < LANES; lane = lane + 1)
            din_ext[lane] = $signed({{10{din_flat[(lane*8)+7]}}, din_flat[(lane*8) +: 8]});

        for (tap = 0; tap < NTAPS; tap = tap + 1)
            h_ext_d[tap] = $signed({{10{h_packed[(tap*8)+7]}}, h_packed[(tap*8) +: 8]});
    end

    always_ff @(posedge clk or negedge rst_n) begin
        int lane;
        int tap;
        int pipe_i;
        if (!rst_n) begin
            for (tap = 0; tap < NTAPS; tap = tap + 1) begin
                for (lane = 0; lane < LANES; lane = lane + 1)
                    mac_q[tap][lane] <= '0;
            end
            for (tap = 0; tap < NTAPS-1; tap = tap + 1) begin
                feedback_q[tap] <= '0;
                for (pipe_i = 0; pipe_i < NTAPS-1; pipe_i = pipe_i + 1)
                    h_pipe_q[tap][pipe_i] <= '0;
                for (lane = 0; lane < LANES; lane = lane + 1)
                    x_pipe_q[tap][lane] <= '0;
            end
        end else if (ce) begin
            for (tap = 0; tap < NTAPS-1; tap = tap + 1) begin
                h_pipe_q[tap][0] <= h_ext_d[tap];
                for (pipe_i = 1; pipe_i < NTAPS-1; pipe_i = pipe_i + 1)
                    h_pipe_q[tap][pipe_i] <= h_pipe_q[tap][pipe_i-1];
            end

            for (lane = 0; lane < LANES; lane = lane + 1) begin
                mac_q[6][lane] <= din_ext[lane] * h_ext_d[6];
                x_pipe_q[0][lane] <= din_ext[lane];
            end

            mac_q[5][0] <= x_pipe_q[0][0] * h_pipe_q[5][0] + feedback_q[5];
            for (lane = 1; lane < LANES; lane = lane + 1)
                mac_q[5][lane] <= x_pipe_q[0][lane] * h_pipe_q[5][0] + mac_q[6][lane-1];
            for (lane = 0; lane < LANES; lane = lane + 1)
                x_pipe_q[1][lane] <= x_pipe_q[0][lane];
            feedback_q[5] <= mac_q[6][LANES-1];

            mac_q[4][0] <= x_pipe_q[1][0] * h_pipe_q[4][1] + feedback_q[4];
            for (lane = 1; lane < LANES; lane = lane + 1)
                mac_q[4][lane] <= x_pipe_q[1][lane] * h_pipe_q[4][1] + mac_q[5][lane-1];
            for (lane = 0; lane < LANES; lane = lane + 1)
                x_pipe_q[2][lane] <= x_pipe_q[1][lane];
            feedback_q[4] <= mac_q[5][LANES-1];

            mac_q[3][0] <= x_pipe_q[2][0] * h_pipe_q[3][2] + feedback_q[3];
            for (lane = 1; lane < LANES; lane = lane + 1)
                mac_q[3][lane] <= x_pipe_q[2][lane] * h_pipe_q[3][2] + mac_q[4][lane-1];
            for (lane = 0; lane < LANES; lane = lane + 1)
                x_pipe_q[3][lane] <= x_pipe_q[2][lane];
            feedback_q[3] <= mac_q[4][LANES-1];

            mac_q[2][0] <= x_pipe_q[3][0] * h_pipe_q[2][3] + feedback_q[2];
            for (lane = 1; lane < LANES; lane = lane + 1)
                mac_q[2][lane] <= x_pipe_q[3][lane] * h_pipe_q[2][3] + mac_q[3][lane-1];
            for (lane = 0; lane < LANES; lane = lane + 1)
                x_pipe_q[4][lane] <= x_pipe_q[3][lane];
            feedback_q[2] <= mac_q[3][LANES-1];

            mac_q[1][0] <= x_pipe_q[4][0] * h_pipe_q[1][4] + feedback_q[1];
            for (lane = 1; lane < LANES; lane = lane + 1)
                mac_q[1][lane] <= x_pipe_q[4][lane] * h_pipe_q[1][4] + mac_q[2][lane-1];
            for (lane = 0; lane < LANES; lane = lane + 1)
                x_pipe_q[5][lane] <= x_pipe_q[4][lane];
            feedback_q[1] <= mac_q[2][LANES-1];

            mac_q[0][0] <= x_pipe_q[5][0] * h_pipe_q[0][5] + feedback_q[0];
            for (lane = 1; lane < LANES; lane = lane + 1)
                mac_q[0][lane] <= x_pipe_q[5][lane] * h_pipe_q[0][5] + mac_q[1][lane-1];
            feedback_q[0] <= mac_q[1][LANES-1];
        end
    end

    genvar partial_lane_i;
    generate
        for (partial_lane_i = 0; partial_lane_i < LANES; partial_lane_i = partial_lane_i + 1) begin : GEN_PARTIAL_PACK
            assign partial_flat[(partial_lane_i*ACC_W) +: ACC_W] = mac_q[0][partial_lane_i];
        end
    endgenerate
endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company: NICS
// Engineer: J.H. YUN
// 
// Create Date: 2026/06/23 23:57:58
// Design Name: PAM4 FFE/FIR Signal Processing
// Module Name: FIR_Q6_21TAP_GROUP_PIPE_32LANE
// Project Name: DAC/ADC_DSP based TRX
// Target Devices: 
// Tool Versions: 
// Description: Implements a grouped and pipelined 21-tap Q6 RX FFE for 32-lane PAM4 equalization.
// 
// Dependencies: 
// 
// Revision:
// 
//////////////////////////////////////////////////////////////////////////////////

module FIR_Q6_21TAP_GROUP_PIPE_32LANE #(
    parameter int SHIFT = 6
)(
    input  logic clk,
    input  logic rst_n,
    input  logic ce,
    input  logic signed [(32*8)-1:0]      din_flat,
    input  logic signed [(21*8)-1:0]      h_packed,
    output wire signed [(32*8)-1:0]       dout_flat
);
    localparam int LANES = 32;
    localparam int NTAPS = 21;
    localparam int SEG_TAPS = 7;
    localparam int HIST = NTAPS - 1;
    localparam int ACC_W = 48;

    logic signed [(HIST*8)-1:0] hist_reg;
    logic signed [(LANES*8)-1:0] seg0_din_flat;
    logic signed [(LANES*8)-1:0] seg1_din_flat;
    logic signed [(LANES*8)-1:0] seg2_din_flat;
    logic signed [(SEG_TAPS*8)-1:0] seg0_h_packed;
    logic signed [(SEG_TAPS*8)-1:0] seg1_h_packed;
    logic signed [(SEG_TAPS*8)-1:0] seg2_h_packed;
    logic signed [(LANES*ACC_W)-1:0] seg0_partial_flat;
    logic signed [(LANES*ACC_W)-1:0] seg1_partial_flat;
    logic signed [(LANES*ACC_W)-1:0] seg2_partial_flat;
    logic signed [ACC_W-1:0] partial_sum_w [0:LANES-1];
    logic signed [7:0] dout_arr [0:LANES-1];

    function automatic logic signed [7:0] sample_at(
        input logic signed [(LANES*8)-1:0] frame_flat,
        input logic signed [(HIST*8)-1:0] hist_flat,
        input int lane,
        input int tap
    );
        begin
            if (lane >= tap)
                sample_at = $signed(frame_flat[((lane - tap)*8) +: 8]);
            else
                sample_at = $signed(hist_flat[((tap - lane - 1)*8) +: 8]);
        end
    endfunction

    function automatic logic signed [7:0] sat8_shift48(
        input logic signed [ACC_W-1:0] x
    );
        logic signed [ACC_W-1:0] y;
        begin
            y = x >>> SHIFT;
            if (y > 48'sd127)       sat8_shift48 = 8'sd127;
            else if (y < -48'sd128) sat8_shift48 = -8'sd128;
            else                    sat8_shift48 = y[7:0];
        end
    endfunction

    always_comb begin
        int lane;
        int tap;

        seg0_din_flat = din_flat;
        seg1_din_flat = '0;
        seg2_din_flat = '0;
        seg0_h_packed = '0;
        seg1_h_packed = '0;
        seg2_h_packed = '0;

        for (lane = 0; lane < LANES; lane = lane + 1) begin
            seg1_din_flat[(lane*8) +: 8] = sample_at(din_flat, hist_reg, lane, 7);
            seg2_din_flat[(lane*8) +: 8] = sample_at(din_flat, hist_reg, lane, 14);
            partial_sum_w[lane] =
                $signed(seg0_partial_flat[(lane*ACC_W) +: ACC_W]) +
                $signed(seg1_partial_flat[(lane*ACC_W) +: ACC_W]) +
                $signed(seg2_partial_flat[(lane*ACC_W) +: ACC_W]);
        end

        for (tap = 0; tap < SEG_TAPS; tap = tap + 1) begin
            seg0_h_packed[(tap*8) +: 8] = h_packed[(tap*8) +: 8];
            seg1_h_packed[(tap*8) +: 8] = h_packed[((tap+7)*8) +: 8];
            seg2_h_packed[(tap*8) +: 8] = h_packed[((tap+14)*8) +: 8];
        end
    end

    FIR_Q6_7TAP_TRANSPOSED_PARTIAL_32LANE u_seg0 (
        .clk(clk),
        .rst_n(rst_n),
        .ce(ce),
        .din_flat(seg0_din_flat),
        .h_packed(seg0_h_packed),
        .partial_flat(seg0_partial_flat)
    );

    FIR_Q6_7TAP_TRANSPOSED_PARTIAL_32LANE u_seg1 (
        .clk(clk),
        .rst_n(rst_n),
        .ce(ce),
        .din_flat(seg1_din_flat),
        .h_packed(seg1_h_packed),
        .partial_flat(seg1_partial_flat)
    );

    FIR_Q6_7TAP_TRANSPOSED_PARTIAL_32LANE u_seg2 (
        .clk(clk),
        .rst_n(rst_n),
        .ce(ce),
        .din_flat(seg2_din_flat),
        .h_packed(seg2_h_packed),
        .partial_flat(seg2_partial_flat)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        int lane;
        int hist_i;
        if (!rst_n) begin
            hist_reg <= '0;
            for (lane = 0; lane < LANES; lane = lane + 1)
                dout_arr[lane] <= '0;
        end else if (ce) begin
            for (lane = 0; lane < LANES; lane = lane + 1)
                dout_arr[lane] <= sat8_shift48(partial_sum_w[lane]);

            for (hist_i = 0; hist_i < HIST; hist_i = hist_i + 1)
                hist_reg[(hist_i*8) +: 8] <= din_flat[((LANES - 1 - hist_i)*8) +: 8];
        end
    end

    genvar out_lane_i;
    generate
        for (out_lane_i = 0; out_lane_i < LANES; out_lane_i = out_lane_i + 1) begin : GEN_PACK_SEGMENTED
            assign dout_flat[(out_lane_i*8) +: 8] = dout_arr[out_lane_i];
        end
    endgenerate
endmodule

