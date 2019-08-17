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
create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ILA \
          -dir ${ip_dir}

set_property -dict [list \
             CONFIG.C_PROBE23_WIDTH {1} CONFIG.C_PROBE22_WIDTH {8} CONFIG.C_PROBE21_WIDTH {1} CONFIG.C_PROBE20_WIDTH {1} \
             CONFIG.C_PROBE19_WIDTH {1} CONFIG.C_PROBE18_WIDTH {8} CONFIG.C_PROBE17_WIDTH {1} CONFIG.C_PROBE16_WIDTH {1} \
             CONFIG.C_PROBE15_WIDTH {4} CONFIG.C_PROBE14_WIDTH {1} CONFIG.C_PROBE13_WIDTH {1} CONFIG.C_PROBE12_WIDTH {1} \
             CONFIG.C_PROBE11_WIDTH {1} CONFIG.C_PROBE10_WIDTH {1} CONFIG.C_PROBE9_WIDTH  {1} CONFIG.C_PROBE8_WIDTH  {1} \
             CONFIG.C_PROBE7_WIDTH  {1} CONFIG.C_PROBE6_WIDTH  {1} CONFIG.C_PROBE5_WIDTH  {1} CONFIG.C_PROBE4_WIDTH  {8} \
             CONFIG.C_PROBE3_WIDTH  {8} CONFIG.C_PROBE2_WIDTH  {1} CONFIG.C_PROBE1_WIDTH  {1} CONFIG.C_PROBE0_WIDTH  {1} \
             CONFIG.C_DATA_DEPTH {65536} CONFIG.C_NUM_OF_PROBES {24}] [get_ips ILA]

#generate_target {instantiation_template} [get_files ${ip_dir}/ILA/ILA.xci]
generate_target all [get_files ${ip_dir}/ILA/ILA.xci]
#catch { config_ip_cache -export [get_ips -all ILA] }
export_ip_user_files -of_objects [get_files ${ip_dir}/ILA/ILA.xci] \
                     -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] ${ip_dir}/ILA/ILA.xci]
#launch_runs -jobs 2 ila_0_synth_1
export_simulation -of_objects [get_files ${ip_dir}/ILA/ILA.xci] \
                  -directory ${WORK_DIR}/${project_name}.ip_user_files/sim_scripts \
                  -ip_user_files_dir ${WORK_DIR}/${project_name}.ip_user_files \
                  -ipstatic_source_dir ${WORK_DIR}/${project_name}.ip_user_files/ipstatic \
                  -lib_map_path [list {modelsim=${WORK_DIR}/${project_name}.cache/compile_simlib/modelsim} \
                  {questa=${WORK_DIR}/${project_name}.cache/compile_simlib/questa} \
                  {riviera=${WORK_DIR}/${project_name}.cache/compile_simlib/riviera} \
                  {activehdl=${WORK_DIR}/${project_name}.cache/compile_simlib/activehdl}] \
                  -use_ip_compiled_libs -force -quiet
