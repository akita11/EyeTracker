// -----------------------------------------------------------------------------
//  Title         : CLK25M
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : CLK25M.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 1/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Generate 25[MHz] via an internal PLL
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module CLK25M(
    // 
    input   wire                            CLK,
    input   wire                            RST_N,
    output  wire                            CLKOUT
);

    CLKGEN_MMCM     m_CLKGEN_MMCM ( .clk_in1(CLK), .resetn(RST_N), .clk_out1(CLKOUT), .locked() );

endmodule
