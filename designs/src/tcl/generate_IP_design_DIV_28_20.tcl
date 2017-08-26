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

# /* ---- Check project name ---- */
if {[info exist "::project_name"] != 1} {
  set project_name "project_1"
} else {
  set project_name $::project_name
}

# /* ---- Get execute environment ---- */
set OS       [lindex $::platform(os)       0]
set ARCH     [lindex $::platform(machine)  0]
set PLATFORM [lindex $::platform(platform) 0]

if { $OS == "Windows NT" } {
  set WORK_DIR "c:/work/EyeTracker/designs/FPGA/${project_name}"
} elseif { $OS == "Linux" } {
  set WORK_DIR "./project_mode/${project_name}"
}

# /* ---- Create directory ---- */
set ip_dir "${WORK_DIR}/${project_name}.srcs/sources_1/ip"
file mkdir ${ip_dir}

# /* ---- Main Routine ---- */
create_ip -name div_gen -vendor xilinx.com -library ip -version 5.1 -module_name DIV_28_20 \
          -dir ${ip_dir}

set_property -dict [list CONFIG.dividend_and_quotient_width {28} CONFIG.divisor_width {20} \
             CONFIG.operand_sign {Unsigned} CONFIG.divide_by_zero_detect {true} CONFIG.ACLKEN {true} CONFIG.ARESETN {true} \
             CONFIG.remainder_type {Fractional} CONFIG.fractional_width {20} CONFIG.latency {50}] [get_ips DIV_28_20]

#generate_target {instantiation_template} [get_files ${ip_dir}/DIV_28_20/DIV_28_20.xci]
generate_target all [get_files ${ip_dir}/DIV_28_20/DIV_28_20.xci]
catch { config_ip_cache -export [get_ips -all DIV_28_20] }
export_ip_user_files -of_objects [get_files ${ip_dir}/DIV_28_20/DIV_28_20.xci] \
                     -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] ${ip_dir}/DIV_28_20/DIV_28_20.xci]
launch_runs -jobs 2 DIV_28_20_synth_1
export_simulation -of_objects [get_files ${ip_dir}/DIV_28_20/DIV_28_20.xci] \
                  -directory ${WORK_DIR}/${project_name}.ip_user_files/sim_scripts \
                  -ip_user_files_dir ${WORK_DIR}/${project_name}.ip_user_files \
                  -ipstatic_source_dir v.ip_user_files/ipstatic \
                  -lib_map_path [list {modelsim=${WORK_DIR}/${project_name}.cache/compile_simlib/modelsim} \
                  {questa=${WORK_DIR}/${project_name}.cache/compile_simlib/questa} \
                  {riviera=${WORK_DIR}/${project_name}.cache/compile_simlib/riviera} \
                  {activehdl=${WORK_DIR}/${project_name}.cache/compile_simlib/activehdl}] \
                  -use_ip_compiled_libs -force -quiet
