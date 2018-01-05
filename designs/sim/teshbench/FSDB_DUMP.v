// -----------------------------------------------------------------------------
//  Title         : Dump waveform
//  Project       : Common Library
// -----------------------------------------------------------------------------
//  File          : FSDB_DUMP.v
//  Author        : K.Ishiwatari
//  Created       : 2018/ 1/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Dump waveform as top.fsdb
// -----------------------------------------------------------------------------
//  Copyright (C) 2018 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module FSDB_DUMP (
);
    initial begin
        $fsdbDumpfile("./fsdb/top.fsdb");
        $fsdbDumpvars(0,SIM_TOP.m_TOP);
    end

endmodule
