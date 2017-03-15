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

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.3 -module_name MEM \
          -dir c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip
set_property -dict [list CONFIG.Memory_Type {True_Dual_Port_RAM} \
             CONFIG.Algorithm {Low_Power} \
             CONFIG.Write_Width_A {640} CONFIG.Write_Depth_A {512} CONFIG.Read_Width_A {640} CONFIG.Operating_Mode_A {NO_CHANGE} \
             CONFIG.Write_Width_B {640} CONFIG.Read_Width_B {640} CONFIG.Operating_Mode_B {NO_CHANGE} CONFIG.Enable_B {Use_ENB_Pin} \
             CONFIG.Register_PortA_Output_of_Memory_Primitives {true} CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
             CONFIG.Port_B_Clock {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Port_B_Enable_Rate {100}] [get_ips MEM]
#generate_target {instantiation_template} [get_files c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip/MEM/MEM.xci]
generate_target all [get_files  c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip/MEM/MEM.xci]
#catch { config_ip_cache -export [get_ips -all MEM] }
export_ip_user_files -of_objects [get_files c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip/MEM/MEM.xci] \
                     -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip/MEM/MEM.xci]
#launch_runs -jobs 2 MEM_synth_1
export_simulation -of_objects [get_files c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip/MEM/MEM.xci] \
                  -directory C:/work/EyeTracker/designs/FPGA/project_1/project_1.ip_user_files/sim_scripts \
                  -ip_user_files_dir C:/work/EyeTracker/designs/FPGA/project_1/project_1.ip_user_files \
                  -ipstatic_source_dir C:/work/EyeTracker/designs/FPGA/project_1/project_1.ip_user_files/ipstatic \
                  -lib_map_path [list {modelsim=C:/work/EyeTracker/designs/FPGA/project_1/project_1.cache/compile_simlib/modelsim} {questa=C:/work/EyeTracker/designs/FPGA/project_1/project_1.cache/compile_simlib/questa} {riviera=C:/work/EyeTracker/designs/FPGA/project_1/project_1.cache/compile_simlib/riviera} {activehdl=C:/work/EyeTracker/designs/FPGA/project_1/project_1.cache/compile_simlib/activehdl}] \
                  -use_ip_compiled_libs -force -quiet
