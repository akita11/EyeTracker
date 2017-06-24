# // -----------------------------------------------------------------------------
# //  Title         : Generate IP design for MEM
# //  Project       : EyeTracker
# // -----------------------------------------------------------------------------
# //  File          : generate_IP_design_MEM.tcl
# //  Author        : K.Ishiwatari
# //  Created       : 2017/ 1/ 1
# //  Last modified : 
# // -----------------------------------------------------------------------------
# //  Description   : Xilinx Design Constraint file 
# // -----------------------------------------------------------------------------
# //  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
# // -----------------------------------------------------------------------------

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ILA \
          -dir c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip
set_property -dict [list \
             CONFIG.C_PROBE23_WIDTH {1} CONFIG.C_PROBE22_WIDTH {8} CONFIG.C_PROBE21_WIDTH {1} CONFIG.C_PROBE20_WIDTH {1} \
             CONFIG.C_PROBE19_WIDTH {1} CONFIG.C_PROBE18_WIDTH {8} CONFIG.C_PROBE17_WIDTH {1} CONFIG.C_PROBE16_WIDTH {1} \
             CONFIG.C_PROBE15_WIDTH {4} CONFIG.C_PROBE14_WIDTH {1} CONFIG.C_PROBE13_WIDTH {1} CONFIG.C_PROBE12_WIDTH {1} \
             CONFIG.C_PROBE11_WIDTH {1} CONFIG.C_PROBE10_WIDTH {1} CONFIG.C_PROBE9_WIDTH  {1} CONFIG.C_PROBE8_WIDTH  {1} \
             CONFIG.C_PROBE7_WIDTH  {1} CONFIG.C_PROBE6_WIDTH  {1} CONFIG.C_PROBE5_WIDTH  {1} CONFIG.C_PROBE4_WIDTH  {8} \
             CONFIG.C_PROBE3_WIDTH  {8} CONFIG.C_PROBE2_WIDTH  {1} CONFIG.C_PROBE1_WIDTH  {1} CONFIG.C_PROBE0_WIDTH  {1} \
             CONFIG.C_DATA_DEPTH {65536} CONFIG.C_NUM_OF_PROBES {24}] [get_ips ILA]
generate_target all [get_ips ILA] -force
synth_ip [get_ips ILA]
