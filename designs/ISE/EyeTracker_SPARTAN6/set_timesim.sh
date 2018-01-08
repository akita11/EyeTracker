#!/bin/bash

# /****************************************************
#
#
#
# ****************************************************/

# Copy netlist and sdf file to simulation directory
cp -p ./netgen/par/TOP_timesim.v ./../../sim/netlist/
cp -p ./netgen/par/TOP_timesim.sdf ./../../sim/sdf/
