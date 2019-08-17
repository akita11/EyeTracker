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
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.3 -module_name MEM \
          -dir ${ip_dir}

set_property -dict [list CONFIG.Memory_Type {True_Dual_Port_RAM} \
             CONFIG.Algorithm {Low_Power} \
             CONFIG.Write_Width_A {640} CONFIG.Write_Depth_A {512} CONFIG.Read_Width_A {640} CONFIG.Operating_Mode_A {NO_CHANGE} \
             CONFIG.Write_Width_B {640} CONFIG.Read_Width_B {640} CONFIG.Operating_Mode_B {NO_CHANGE} CONFIG.Enable_B {Use_ENB_Pin} \
             CONFIG.Register_PortA_Output_of_Memory_Primitives {true} CONFIG.Register_PortB_Output_of_Memory_Primitives {true} \
             CONFIG.Port_B_Clock {100} CONFIG.Port_B_Write_Rate {50} CONFIG.Port_B_Enable_Rate {100}] [get_ips MEM]

#generate_target {instantiation_template} [get_files ${ip_dir}/MEM/MEM.xci]
generate_target all [get_files  ${ip_dir}/MEM/MEM.xci]
#catch { config_ip_cache -export [get_ips -all MEM] }
export_ip_user_files -of_objects [get_files ${ip_dir}/MEM/MEM.xci] \
                     -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] ${ip_dir}/MEM/MEM.xci]
#launch_runs -jobs 2 MEM_synth_1
export_simulation -of_objects [get_files ${ip_dir}/MEM/MEM.xci] \
                  -directory ${WORK_DIR}/${project_name}.ip_user_files/sim_scripts \
                  -ip_user_files_dir ${WORK_DIR}/${project_name}.ip_user_files \
                  -ipstatic_source_dir ${WORK_DIR}/${project_name}.ip_user_files/ipstatic \
                  -lib_map_path [list {modelsim=${WORK_DIR}/${project_name}.cache/compile_simlib/modelsim} \
                  {questa=${WORK_DIR}/${project_name}.cache/compile_simlib/questa} \
                  {riviera=${WORK_DIR}/${project_name}.cache/compile_simlib/riviera} \
                  {activehdl=${WORK_DIR}/${project_name}.cache/compile_simlib/activehdl}] \
                  -use_ip_compiled_libs -force -quiet
