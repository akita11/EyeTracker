#!/bin/bash

# /***************************************************************************************
#
#    ISEにてPlace & Route -> Generate Post-Place & Route Simulation Modelを実行0
#    
#    作業ディレクトリ(./designs/ISE/EyeTracker_SPARTAN6)の下の「./netgen/par/」の下の
#    TOP_timesim.sdfとTOP_timesim.vを本スクリプトでコピー
#
# ****************************************************************************************/

# Copy netlist and sdf file to simulation directory
cp -p ./netgen/par/TOP_timesim.v ./../../sim/netlist/
cp -p ./netgen/par/TOP_timesim.sdf ./../../sim/sdf/
