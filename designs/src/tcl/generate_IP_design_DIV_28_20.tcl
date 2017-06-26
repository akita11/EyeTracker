# // -----------------------------------------------------------------------------
# //  Title         : Generate IP design for DIV_28_20
# //  Project       : EyeTracker
# // -----------------------------------------------------------------------------
# //  File          : generate_IP_design_DIV_28_20.tcl
# //  Author        : K.Ishiwatari
# //  Created       : 2017/ 6/14
# //  Last modified : 
# // -----------------------------------------------------------------------------
# //  Description   : Xilinx Design Constraint file 
# // -----------------------------------------------------------------------------
# //  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
# // -----------------------------------------------------------------------------

create_ip -name div_gen -vendor xilinx.com -library ip -version 5.1 -module_name DIV_28_20 \
          -dir c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip
set_property -dict [list CONFIG.dividend_and_quotient_width {28} CONFIG.divisor_width {20} \
             CONFIG.operand_sign {Unsigned} CONFIG.divide_by_zero_detect {true} CONFIG.ACLKEN {true} CONFIG.ARESETN {true} \
             CONFIG.remainder_type {Fractional} CONFIG.fractional_width {20} CONFIG.latency {50}] [get_ips DIV_28_20]
#generate_target {instantiation_template} [get_files c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip/DIV_28_20/DIV_28_20.xci]
generate_target all [get_files  c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip/DIV_28_20/DIV_28_20.xci]
catch { config_ip_cache -export [get_ips -all DIV_28_20] }
export_ip_user_files -of_objects [get_files c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip/DIV_28_20/DIV_28_20.xci] \
                     -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip/DIV_28_20/DIV_28_20.xci]
launch_runs -jobs 2 DIV_28_20_synth_1
export_simulation -of_objects [get_files c:/work/EyeTracker/designs/FPGA/project_1/project_1.srcs/sources_1/ip/DIV_28_20/DIV_28_20.xci] \
                  -directory C:/work/EyeTracker/designs/FPGA/project_1/project_1.ip_user_files/sim_scripts \
                  -ip_user_files_dir C:/work/EyeTracker/designs/FPGA/project_1/project_1.ip_user_files \
                  -ipstatic_source_dir C:/work/EyeTracker/designs/FPGA/project_1/project_1.ip_user_files/ipstatic \
                  -lib_map_path [list {modelsim=C:/work/EyeTracker/designs/FPGA/project_1/project_1.cache/compile_simlib/modelsim} {questa=C:/work/EyeTracker/designs/FPGA/project_1/project_1.cache/compile_simlib/questa} {riviera=C:/work/EyeTracker/designs/FPGA/project_1/project_1.cache/compile_simlib/riviera} {activehdl=C:/work/EyeTracker/designs/FPGA/project_1/project_1.cache/compile_simlib/activehdl}] \
                  -use_ip_compiled_libs -force -quiet
