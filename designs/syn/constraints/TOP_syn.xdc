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
create_clock -name CLK -period 20.000 -waveform "0 10.000" [get_ports CLK]
set_clock_uncertainty -setup 0.300 [get_clocks CLK]
set_clock_uncertainty -hold  0.100 [get_clocks CLK]

# /* ----- CCLK (50MHz/40MHz) ----- */
create_clock -name CCLK -period 20.000 -waveform "0 10.000" [get_ports CCLK]
#create_clock -name CCLK -period 25.000 -waveform "0 12.500" [get_ports CCLK]
set_clock_uncertainty -setup 0.300 [get_clocks CCLK]
set_clock_uncertainty -hold  0.100 [get_clocks CCLK]

# /* ----- VCLK ----- */
create_generated_clock -name VGA_CLK -source [get_pins m_CLK25M/m_CLKGEN_MMCM/inst/mmcm_adv_inst/CLKOUT0] \
    -divide_by 1 -add \
    -master_clock [get_clocks clk_out1_CLKGEN_MMCM] [get_ports VGA_CLK]

# /* ----- Clock Group Setting ----- */
set_clock_groups -asynchronous \
    -group [get_clocks [list CLK]] \
    -group [get_clocks [list CCLK]] \
    -group [get_clocks [list VGA_CLK]]

# /* ----- set false path ----- */
set_false_path -from [get_ports [list [JP[*]]]
set_false_path -from [get_ports RST_N]

# /* ----- Input Constraint ----- */
#    Setup : 5[ns]
#    Hold  : 3[ns]
set_input_delay -add -clock [get_clocks CCLK] -max 20 [get_ports [list DATA_R[*] DATA_L[*] FVAL DVAL LVAL]]
set_input_delay -add -clock [get_clocks CCLK] -min  3 [get_ports [list DATA_R[*] DATA_L[*] FVAL DVAL LVAL]]

#set_input_delay -add -clock [get_clocks CLK] -max  0 [get_ports [list JP[*] RST_N]]
#set_input_delay -add -clock [get_clocks CLK] -min  0 [get_ports [list JP[*] RST_N]]

# /* ----- Output Constraint ----- */
#    Output delay
#      Max : 5[ns]
#      Min : 2[ns]
set_output_delay -add -clock [get_clocks VGA_CLK] -max 5 [get_ports [list VGA_R[*] VGA_G[*] VGA_B[*] VGA_HSYNC VGA_VSYNC]]
set_output_delay -add -clock [get_clocks VGA_CLK] -min 2 [get_ports [list VGA_R[*] VGA_G[*] VGA_B[*] VGA_HSYNC VGA_VSYNC]]
