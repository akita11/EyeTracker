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
# //     for Implement (Layout setting)
# // -----------------------------------------------------------------------------

# /* ----- Pull-up/Pull-down setting ----- */
set_property PULLUP   TRUE [get_ports RST_N]

set_property PULLDOWN TRUE [get_ports [list DATA_L[*] DATA_R[*] FVAL DVAL LVAL CCLK]]
set_property PULLUP   TRUE [get_ports [list JP[*]]]
set_property PULLUP   TRUE [get_ports [list UART_RXD]]

set_property PULLDOWN TRUE [get_ports [list DUMMY0 DUMMY1]]

# /* ----- I/O constraints ----- */
set_property IOSTANDARD LVCMOS33 [get_ports [list DATA_L[*] DATA_R[*] FVAL DVAL LVAL CCLK]]
set_property IOSTANDARD LVCMOS33 [get_ports [list VGA_R[*] VGA_G[*] VGA_B[*] VGA_HSYNC VGA_VSYNC VGA_CLK]]
set_property IOSTANDARD LVCMOS33 [get_ports [list CLK RST_N]]
set_property IOSTANDARD LVCMOS33 [get_ports [list JP[*] UART_RXD UART_TXD]]

set_property IOSTANDARD LVCMOS18 [get_ports [list DUMMY0 DUMMY1]]

set_property SLEW SLOW [get_ports [list VGA_R[*] VGA_G[*] VGA_B[*] VGA_HSYNC VGA_VSYNC VGA_CLK]]
set_property SLEW SLOW [get_ports [list UART_TXD]]

set_property DRIVE  8 [get_ports [list VGA_R[*] VGA_G[*] VGA_B[*] VGA_HSYNC VGA_VSYNC VGA_CLK]]
set_property DRIVE  8 [get_ports [list UART_TXD]]

# /* ----- Placement Constraints ----- */

# /* ----- DATA_L & DATA_R from Camara Link ----- */
set_property PACKAGE_PIN B22  [get_ports [list DATA_L[0]]]
set_property PACKAGE_PIN B21  [get_ports [list DATA_L[1]]]
set_property PACKAGE_PIN B20  [get_ports [list DATA_L[2]]]
set_property PACKAGE_PIN D22  [get_ports [list DATA_L[3]]]
set_property PACKAGE_PIN D21  [get_ports [list DATA_L[4]]]
set_property PACKAGE_PIN D19  [get_ports [list DATA_L[5]]]
set_property PACKAGE_PIN G12  [get_ports [list DATA_L[6]]]
set_property PACKAGE_PIN D20  [get_ports [list DATA_L[7]]]
#
set_property PACKAGE_PIN B11  [get_ports [list DATA_R[0]]]
set_property PACKAGE_PIN B10  [get_ports [list DATA_R[1]]]
set_property PACKAGE_PIN F11  [get_ports [list DATA_R[2]]]
set_property PACKAGE_PIN F9   [get_ports [list DATA_R[3]]]
set_property PACKAGE_PIN G8   [get_ports [list DATA_R[4]]]
set_property PACKAGE_PIN F8   [get_ports [list DATA_R[5]]]
set_property PACKAGE_PIN F10  [get_ports [list DATA_R[6]]]
set_property PACKAGE_PIN E9   [get_ports [list DATA_R[7]]]
#
set_property PACKAGE_PIN H13  [get_ports LVAL]
set_property PACKAGE_PIN F13  [get_ports FVAL]
set_property PACKAGE_PIN G13  [get_ports DVAL]
#
set_property PACKAGE_PIN E16  [get_ports CCLK]

set_property PACKAGE_PIN W15  [get_ports [list VGA_R[0]]]
set_property PACKAGE_PIN V15  [get_ports [list VGA_R[1]]]
set_property PACKAGE_PIN U15  [get_ports [list VGA_R[2]]]
set_property PACKAGE_PIN T15  [get_ports [list VGA_R[3]]]
set_property PACKAGE_PIN T16  [get_ports [list VGA_R[4]]]
set_property PACKAGE_PIN R16  [get_ports [list VGA_R[5]]]
set_property PACKAGE_PIN Y18  [get_ports [list VGA_R[6]]]
set_property PACKAGE_PIN Y19  [get_ports [list VGA_R[7]]]
#
set_property PACKAGE_PIN F21  [get_ports [list VGA_G[0]]]
set_property PACKAGE_PIN E21  [get_ports [list VGA_G[1]]]
set_property PACKAGE_PIN E22  [get_ports [list VGA_G[2]]]
set_property PACKAGE_PIN G21  [get_ports [list VGA_G[3]]]
set_property PACKAGE_PIN V22  [get_ports [list VGA_G[4]]]
set_property PACKAGE_PIN U22  [get_ports [list VGA_G[5]]]
set_property PACKAGE_PIN T21  [get_ports [list VGA_G[6]]]
set_property PACKAGE_PIN U21  [get_ports [list VGA_G[7]]]
#
set_property PACKAGE_PIN AA20 [get_ports [list VGA_B[0]]]
set_property PACKAGE_PIN AB21 [get_ports [list VGA_B[1]]]
set_property PACKAGE_PIN AA21 [get_ports [list VGA_B[2]]]
set_property PACKAGE_PIN AB22 [get_ports [list VGA_B[3]]]
set_property PACKAGE_PIN Y21  [get_ports [list VGA_B[4]]]
set_property PACKAGE_PIN Y22  [get_ports [list VGA_B[5]]]
set_property PACKAGE_PIN W22  [get_ports [list VGA_B[6]]]
set_property PACKAGE_PIN W21  [get_ports [list VGA_B[7]]]
#
set_property PACKAGE_PIN AB18 [get_ports VGA_HSYNC]
set_property PACKAGE_PIN AA19 [get_ports VGA_VSYNC]
#
set_property PACKAGE_PIN AB20 [get_ports VGA_CLK]
#

# System Clock
set_property PACKAGE_PIN E17  [get_ports CLK]

# System Reset (SW2)
set_property PACKAGE_PIN K17  [get_ports RST_N]

#
set_property PACKAGE_PIN U17  [get_ports UART_RXD]
set_property PACKAGE_PIN W16  [get_ports UART_TXD]

#
set_property PACKAGE_PIN AA18 [get_ports [list JP[0]]]
set_property PACKAGE_PIN W17  [get_ports [list JP[1]]]
set_property PACKAGE_PIN Y17  [get_ports [list JP[2]]]
set_property PACKAGE_PIN V18  [get_ports [list JP[3]]]
set_property PACKAGE_PIN Y16  [get_ports [list JP[4]]]
set_property PACKAGE_PIN AB17 [get_ports [list JP[5]]]
set_property PACKAGE_PIN AA16 [get_ports [list JP[6]]]
set_property PACKAGE_PIN AB16 [get_ports [list JP[7]]]

#
set_property PACKAGE_PIN Y11 [get_ports [list DUMMY0]]
set_property PACKAGE_PIN Y12 [get_ports [list DUMMY1]]

# /* ----- Misc. ----- */
set_property CFGBVS VCCO [current_design]
