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

# /* ---- Main Routine ---- */
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.3 -module_name MEM

set_property -dict [list CONFIG.Memory_Type {True_Dual_Port_RAM} \
             CONFIG.Algorithm {Low_Power} \
             CONFIG.Write_Width_A {640} CONFIG.Write_Depth_A {512} CONFIG.Read_Width_A {640} CONFIG.Operating_Mode_A {NO_CHANGE} \
             CONFIG.Write_Width_B {640} CONFIG.Read_Width_B {640} CONFIG.Operating_Mode_B {NO_CHANGE} CONFIG.Enable_B {Use_ENB_Pin} \
             CONFIG.Register_PortA_Output_of_Memory_Primitives {true} CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
             CONFIG.Port_B_Clock {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Port_B_Enable_Rate {100}] [get_ips MEM]

generate_target all [get_ips MEM] -force
synth_ip [get_ips MEM]
