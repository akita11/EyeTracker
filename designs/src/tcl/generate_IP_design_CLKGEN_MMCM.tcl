# // -----------------------------------------------------------------------------
# //  Title         : Generate IP design for CLKGEN_MMCM
# //  Project       : EyeTracker
# // -----------------------------------------------------------------------------
# //  File          : generate_IP_design_CLKGEN_MMCM.tcl
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
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 5.3 -module_name CLKGEN_MMCM \
          -dir ${ip_dir}

set_property -dict [list CONFIG.USE_MIN_POWER {true} CONFIG.RESET_TYPE {ACTIVE_LOW} CONFIG.RESET_PORT {resetn} \
             CONFIG.PRIM_IN_FREQ {50} CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25} CONFIG.USE_SAFE_CLOCK_STARTUP {true} \
             CONFIG.JITTER_SEL {No_Jitter} CONFIG.CLKIN1_JITTER_PS {200.0} CONFIG.CLKOUT1_DRIVES {BUFGCE} \
             CONFIG.CLKOUT2_DRIVES {BUFGCE} CONFIG.CLKOUT3_DRIVES {BUFGCE} CONFIG.CLKOUT4_DRIVES {BUFGCE} \
             CONFIG.CLKOUT5_DRIVES {BUFGCE} CONFIG.CLKOUT6_DRIVES {BUFGCE} CONFIG.CLKOUT7_DRIVES {BUFGCE} \
             CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
             CONFIG.MMCM_DIVCLK_DIVIDE {2} CONFIG.MMCM_CLKFBOUT_MULT_F {24.125} CONFIG.MMCM_CLKIN1_PERIOD {20.0} \
             CONFIG.MMCM_CLKOUT0_DIVIDE_F {24.125} CONFIG.MMCM_CLKOUT0_DUTY_CYCLE {0.5} \
             CONFIG.CLKOUT1_JITTER {437.668} CONFIG.CLKOUT1_PHASE_ERROR {333.440}] [get_ips CLKGEN_MMCM]

#generate_target {instantiation_template} [get_files ${ip_dir}/CLKGEN_MMCM/CLKGEN_MMCM.xci]
generate_target all [get_files ${ip_dir}/CLKGEN_MMCM/CLKGEN_MMCM.xci]
export_ip_user_files -of_objects [get_files ${ip_dir}/CLKGEN_MMCM/CLKGEN_MMCM.xci] \
                     -no_script -sync -force -quiet
create_ip_run [get_files -of_objects [get_fileset sources_1] ${ip_dir}/CLKGEN_MMCM/CLKGEN_MMCM.xci]
#launch_runs -jobs 2 CLKGEN_MMCM_synth_1
export_simulation -of_objects [get_files ${ip_dir}/CLKGEN_MMCM/CLKGEN_MMCM.xci] \
                  -directory ${WORK_DIR}/${project_name}.ip_user_files/sim_scripts \
                  -ip_user_files_dir ${WORK_DIR}/${project_name}.ip_user_files \
                  -ipstatic_source_dir ${WORK_DIR}/${project_name}.ip_user_files/ipstatic \
                  -lib_map_path [list {modelsim=${WORK_DIR}/${project_name}.cache/compile_simlib/modelsim} \
                  {questa=${WORK_DIR}/${project_name}.cache/compile_simlib/questa} \
                  {riviera=${WORK_DIR}/${project_name}.cache/compile_simlib/riviera} \
                  {activehdl=${WORK_DIR}/${project_name}.cache/compile_simlib/activehdl}] \
                  -use_ip_compiled_libs -force -quiet
