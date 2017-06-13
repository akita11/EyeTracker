# // -----------------------------------------------------------------------------
# //  Title         : Design Constraint file for EyeTracker
# //  Project       : EyeTracker
# // -----------------------------------------------------------------------------
# //  File          : TOP_syn.xdc
# //  Author        : K.Ishiwatari
# //  Created       : 2017/ 1/ 1
# //  Last modified :
# // -----------------------------------------------------------------------------
# //  Description   : Xilinx Design Constraint file
# // -----------------------------------------------------------------------------
# //  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
# // -----------------------------------------------------------------------------

# // -----------------------------------------------------------------------------
# //     for Synthesis
# // -----------------------------------------------------------------------------

# /* ----- Clock Setting ----- */

# /* ----- CLK (50MHz)----- */
create_clock -period 20.000 -name CLK -waveform {0.000 10.000} [get_ports CLK]
set_clock_uncertainty -setup 0.300 [get_clocks CLK]
set_clock_uncertainty -hold 0.100 [get_clocks CLK]

# /* ----- CCLK (50MHz/40MHz) ----- */
create_clock -period 20.000 -name CCLK -waveform {0.000 10.000} [get_ports CCLK]
#create_clock -name CCLK -period 25.000 -waveform "0 12.500" [get_ports CCLK]
set_clock_uncertainty -setup 0.300 [get_clocks CCLK]
set_clock_uncertainty -hold 0.100 [get_clocks CCLK]

# /* ----- VCLK ----- */
#create_clock -name VGA_CLK -period 40.000 -waveform "0 20.000" [get_pins m_CLK25M/m_CLKGEN_MMCM/inst/mmcm_adv_inst/CLKOUT0]
#set_clock_uncertainty -setup 0.300 [get_clocks VGA_CLK]
#set_clock_uncertainty -hold  0.100 [get_clocks VGA_CLK]
#
create_generated_clock -name OUT_VGA_CLK -source [get_pins m_CLK25M/m_CLKGEN_MMCM/inst/mmcm_adv_inst/CLKOUT0] -divide_by 1 -add -master_clock clk_out1_CLKGEN_MMCM [get_ports VGA_CLK]

# /* ----- Clock Group Setting ----- */
set_clock_groups -asynchronous -group [get_clocks CLK] -group [get_clocks CCLK] -group [get_clocks OUT_VGA_CLK]

# /* ----- set false path ----- */
#
set_property PULLUP true [get_ports RST_N]
set_property PULLDOWN true [get_ports {DATA_L[7]}]
set_property PULLDOWN true [get_ports {DATA_L[6]}]
set_property PULLDOWN true [get_ports {DATA_L[5]}]
set_property PULLDOWN true [get_ports {DATA_L[4]}]
set_property PULLDOWN true [get_ports {DATA_L[3]}]
set_property PULLDOWN true [get_ports {DATA_L[2]}]
set_property PULLDOWN true [get_ports {DATA_L[1]}]
set_property PULLDOWN true [get_ports {DATA_L[0]}]
set_property PULLDOWN true [get_ports {DATA_R[7]}]
set_property PULLDOWN true [get_ports {DATA_R[6]}]
set_property PULLDOWN true [get_ports {DATA_R[5]}]
set_property PULLDOWN true [get_ports {DATA_R[4]}]
set_property PULLDOWN true [get_ports {DATA_R[3]}]
set_property PULLDOWN true [get_ports {DATA_R[2]}]
set_property PULLDOWN true [get_ports {DATA_R[1]}]
set_property PULLDOWN true [get_ports {DATA_R[0]}]
set_property PULLDOWN true [get_ports FVAL]
set_property PULLDOWN true [get_ports DVAL]
set_property PULLDOWN true [get_ports LVAL]
set_property PULLDOWN true [get_ports CCLK]
set_property PULLUP true [get_ports UART_RXD]
set_property PULLDOWN true [get_ports DUMMY0]
set_property PULLDOWN true [get_ports DUMMY1]
set_property IOSTANDARD LVCMOS33 [get_ports {{DATA_L[*]} {DATA_R[*]} FVAL DVAL LVAL CCLK}]
set_property IOSTANDARD LVCMOS33 [get_ports {{VGA_R[*]} {VGA_G[*]} {VGA_B[*]} VGA_HSYNC VGA_VSYNC VGA_CLK}]
set_property IOSTANDARD LVCMOS33 [get_ports CLK]
set_property IOSTANDARD LVCMOS33 [get_ports RST_N]
set_property IOSTANDARD LVCMOS33 [get_ports {{JP[*]} UART_RXD UART_TXD}]
#set_property IOSTANDARD LVCMOS33 [get_ports VGAOUT_MODE]
set_property IOSTANDARD LVCMOS18 [get_ports DUMMY0]
set_property IOSTANDARD LVCMOS18 [get_ports DUMMY1]
set_property SLEW SLOW [get_ports {{VGA_R[*]} {VGA_G[*]} {VGA_B[*]} VGA_HSYNC VGA_VSYNC VGA_CLK}]
set_property SLEW SLOW [get_ports UART_TXD]
set_property DRIVE 8 [get_ports {{VGA_R[*]} {VGA_G[*]} {VGA_B[*]} VGA_HSYNC VGA_VSYNC VGA_CLK}]
set_property DRIVE 8 [get_ports UART_TXD]
set_property CFGBVS VCCO [current_design]
set_property PULLDOWN true [get_ports {JP[7]}]
set_property PULLDOWN true [get_ports {JP[6]}]
set_property PULLDOWN true [get_ports {JP[5]}]
set_property PULLDOWN true [get_ports {JP[4]}]
set_property PULLDOWN true [get_ports {JP[3]}]
set_property PULLDOWN true [get_ports {JP[2]}]
set_property PULLDOWN true [get_ports {JP[1]}]
set_property PULLDOWN true [get_ports {JP[0]}]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets VGA_CLK_OBUF]
