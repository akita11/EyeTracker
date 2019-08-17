#!/bin/tcl
#// -----------------------------------------------------------------------------
#//  Title         : Generate a bitstream file by cli
#//  Project       : common
#// -----------------------------------------------------------------------------
#//  File          : run_generate_bitstream.tcl
#//  Author        : K.Ishiwatari
#//  Created       : 2017/ 6/24
#//  Last modified : 
#// -----------------------------------------------------------------------------
#//  Description   : tcl 
#// -----------------------------------------------------------------------------
#//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
#// -----------------------------------------------------------------------------

# /* ---- Define parameter
source ./tcl/extend_tcl_library.tcl

# /* ----------------------------------------------------------------------------- */
#        Main
# /* ----------------------------------------------------------------------------- */

set project_name    EyeTracker
set device_name     xc7k160tfbg484-1
set top_module      TOP

# /* ---- Define parameter ---- */
set outputDir ./project/$project_name
file mkdir ${outputDir}

# /* ---- Prepare environment ---- */
#create_project -in_memory -part $device_name

# /* ---- Read RTL File ---- */
ReadFromFileList "./filelist.f"

# /* ---- Read IP File ---- */
ReadFromFileList "./filelist_ip_gen.f"

# /* ---- Synthesis ---- */
ReadFile ../syn/constraints/TOP_syn.xdc
synth_design -top $top_module -part $device_name
write_checkpoint -force ${outputDir}/post_synth
report_timing_summary -file ${outputDir}/post_synth_timing_summary.rpt
report_power -file ${outputDir}/post_synth_power.rpt

# /* ---- Placement ---- */
ReadFile ../syn/tcl/TOP_impliment.tcl
opt_design
place_design
phys_opt_design
write_checkpoint -force ${outputDir}/post_place
report_timing_summary -file ${outputDir}/post_place_timing_summary.rpt

# /* ---- Routing ---- */
route_design
write_checkpoint -force ${outputDir}/post_route
report_timing_summary -file ${outputDir}/post_route_timing_summary.rpt
report_timing -sort_by group -max_paths 100 -path_type summary -file ${outputDir}/post_route_timing.rpt
report_clock_utilization -file ${outputDir}/clock_util.rpt
report_utilization -file ${outputDir}/post_route_util.rpt
report_power -file ${outputDir}/post_route_power.rpt
report_drc -file ${outputDir}/post_impl_drc.rpt
write_verilog -force ${outputDir}/${project_name}_netlist.v
write_xdc -no_fixed_only -force ${outputDir}/${project_name}_impl.xdc

# /* ---- Generate a bitstream ---- */
ReadFile  ../syn/tcl/TOP_bitstream.tcl
write_bitstream -force ${outputDir}/${project_name}.bit

# /* ---- Generate MCS file ---- */
write_cfgmem -format MCS -interface SPIx1 -size 128 -loadbit "up 0 ${outputDir}/${project_name}.bit" -file ${outputDir}/${project_name}.mcs
