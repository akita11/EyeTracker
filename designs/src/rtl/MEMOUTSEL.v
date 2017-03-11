// -----------------------------------------------------------------------------
//  Title         : Output selected memory value module
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : MEMOUTSEL.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 1/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Modified this file from original MEMOUTSEL to improve readability.
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module MEMOUTSEL #(
    parameter   DATA_WIDTH = 640
) (
    //
    input   wire    [DATA_WIDTH -1: 0]      iMEMOUT_0A,
    input   wire    [DATA_WIDTH -1: 0]      iMEMOUT_0B,
    input   wire                            iMEM_SEL,
    //
    output  wire    [DATA_WIDTH -1: 0]      oMEMOUT_0X
);

    // 
    assign  oMEMOUT_0X = (iMEM_SEL) ? iMEMOUT_0A: iMEMOUT_0B;

endmodule
