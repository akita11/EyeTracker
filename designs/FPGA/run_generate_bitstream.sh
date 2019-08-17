#!/bin/sh

##### Get work directory
work_dir=`dirname $0`

##### Change current directory
cd ${work_dir}

##### Vivado version
vivado_ver=2016.4

##### Set Vivado environment
source /apps/Xilinx/Vivado${vivado_ver}/Vivado/${vivado_ver}/settings64.sh

##### 
vivado -mode batch -source ./run_generate_bitstream.tcl
