// 
+access+rw
-64bit

// for PLI
//-loadvpi 

// for Test bench

./test_bench/SIM_TOP.v
./test_bench/FSDB_DUMP.v
./test_bench/SDF.v

// read netlist file
./netlist/TOP_timesim.v

//
-y $XILINX_ISE/ISE_DS/ISE/verilog/src/XilinxCoreLib/ +libext+.v
-y $XILINX_ISE/ISE_DS/ISE/verilog/src/unisims/ +libext+.v
-y $XILINX_ISE/ISE_DS/ISE/verilog/src/unimacro/ +libext+.v
-y $XILINX_ISE/ISE_DS/ISE/verilog/src/simprims/ +libext+.v
$XILINX_ISE/ISE_DS/ISE/verilog/src/glbl.v

// log
-l ./log/verilog.log
