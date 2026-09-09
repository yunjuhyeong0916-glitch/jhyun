



set_property PACKAGE_PIN C11 [get_ports {clk104_clk_spi_mux_sel_tri_o[0]}]
set_property PACKAGE_PIN B12 [get_ports {clk104_clk_spi_mux_sel_tri_o[1]}]


####################################################################################
# Constraints from file : 'design_1_ddr4_0_0_board.xdc'
####################################################################################



####################################################################################
# Constraints from file : 'design_1_ddr4_0_0_board.xdc'
####################################################################################

#set_property IOSTANDARD LVCMOS12 [get_ports sys_rst_1]
#set_property PACKAGE_PIN A17 [get_ports sys_rst_1]


####################################################################################
# Constraints from file : 'design_1_ddr4_0_0_board.xdc'
####################################################################################



####################################################################################
# Constraints from file : 'design_1_ddr4_0_0_board.xdc'
####################################################################################


set_property IOSTANDARD LVCMOS12 [get_ports {clk104_clk_spi_mux_sel_tri_o[1]}]
set_property IOSTANDARD LVCMOS12 [get_ports {clk104_clk_spi_mux_sel_tri_o[0]}]

####################################################################################
# Constraints from file : 'design_1_ddr4_0_0_board.xdc'
####################################################################################

set_false_path -from [get_clocks RFADC2_CLK] -to [get_clocks -of_objects [get_pins {design_1_i/util_ds_buf_1/U0/USE_BUFGCE_DIV2.GEN_BUFGCE_DIV2[0].BUFGCE_DIV2_I/O}]]
set_false_path -from [get_clocks RFDAC0_CLK] -to [get_clocks -of_objects [get_pins {design_1_i/util_ds_buf_1/U0/USE_BUFGCE_DIV2.GEN_BUFGCE_DIV2[0].BUFGCE_DIV2_I/O}]]
set_false_path -from [get_clocks clk_pl_0] -to [get_clocks -of_objects [get_pins {design_1_i/util_ds_buf_1/U0/USE_BUFGCE_DIV2.GEN_BUFGCE_DIV2[0].BUFGCE_DIV2_I/O}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
