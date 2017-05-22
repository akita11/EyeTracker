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

#generate_target {instantiation_template} [get_files c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip/ILA/ILA.xci]
generate_target all [get_files c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip/ILA/ILA.xci]
#catch { config_ip_cache -export [get_ips -all ILA] }
export_ip_user_files -of_objects [get_files c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip/ILA/ILA.xci] \
                     -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip/ILA/ILA.xci]
#launch_runs -jobs 2 ila_0_synth_1
export_simulation -of_objects [get_files c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip/ILA/ILA.xci] \
                  -directory C:/work/EyeTracker/designs/FPGA/project_1/project_1.ip_user_files/sim_scripts \
                  -ip_user_files_dir C:/work/EyeTracker/designs/FPGA/project_1/project_1.ip_user_files \
                  -ipstatic_source_dir C:/work/EyeTracker/designs/FPGA/project_1/project_1.ip_user_files/ipstatic \
                  -lib_map_path [list {modelsim=C:/work/EyeTracker/designs/FPGA/project_1/project_1.cache/compile_simlib/modelsim} \
                  {questa=C:/work/EyeTracker/designs/FPGA/project_1/project_1.cache/compile_simlib/questa} \
                  {riviera=C:/work/EyeTracker/designs/FPGA/project_1/project_1.cache/compile_simlib/riviera} \
                  {activehdl=C:/work/EyeTracker/designs/FPGA/project_1/project_1.cache/compile_simlib/activehdl}] \
                  -use_ip_compiled_libs -force -quiet
