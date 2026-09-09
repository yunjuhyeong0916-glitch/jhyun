//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
//Date        : Wed Jan 14 15:06:10 2026
//Host        : YUN running 64-bit major release  (build 9200)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (CLK_IN_D_0_clk_n,
    CLK_IN_D_0_clk_p,
    adc2_clk_0_clk_n,
    adc2_clk_0_clk_p,
    clk104_clk_spi_mux_sel_tri_o,
    dac0_clk_0_clk_n,
    dac0_clk_0_clk_p,
    vin2_01_0_v_n,
    vin2_01_0_v_p,
    vout00_0_v_n,
    vout00_0_v_p);
  input CLK_IN_D_0_clk_n;
  input CLK_IN_D_0_clk_p;
  input adc2_clk_0_clk_n;
  input adc2_clk_0_clk_p;
  output [1:0]clk104_clk_spi_mux_sel_tri_o;
  input dac0_clk_0_clk_n;
  input dac0_clk_0_clk_p;
  input vin2_01_0_v_n;
  input vin2_01_0_v_p;
  output vout00_0_v_n;
  output vout00_0_v_p;

  wire CLK_IN_D_0_clk_n;
  wire CLK_IN_D_0_clk_p;
  wire adc2_clk_0_clk_n;
  wire adc2_clk_0_clk_p;
  wire [1:0]clk104_clk_spi_mux_sel_tri_o;
  wire dac0_clk_0_clk_n;
  wire dac0_clk_0_clk_p;
  wire vin2_01_0_v_n;
  wire vin2_01_0_v_p;
  wire vout00_0_v_n;
  wire vout00_0_v_p;

  design_1 design_1_i
       (.CLK_IN_D_0_clk_n(CLK_IN_D_0_clk_n),
        .CLK_IN_D_0_clk_p(CLK_IN_D_0_clk_p),
        .adc2_clk_0_clk_n(adc2_clk_0_clk_n),
        .adc2_clk_0_clk_p(adc2_clk_0_clk_p),
        .clk104_clk_spi_mux_sel_tri_o(clk104_clk_spi_mux_sel_tri_o),
        .dac0_clk_0_clk_n(dac0_clk_0_clk_n),
        .dac0_clk_0_clk_p(dac0_clk_0_clk_p),
        .vin2_01_0_v_n(vin2_01_0_v_n),
        .vin2_01_0_v_p(vin2_01_0_v_p),
        .vout00_0_v_n(vout00_0_v_n),
        .vout00_0_v_p(vout00_0_v_p));
endmodule
