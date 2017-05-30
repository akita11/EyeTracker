// -----------------------------------------------------------------------------
//  Title         : TEST_PATTERN_GENERATOR
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : TEST_PAT_GEN.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 5/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Modified this file from original VGAout to improve readability.
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module TEST_PAT_GEN #(
    parameter   PARAM_WIDTH = 10,
    parameter   ADDR_WIDTH  = 11,
    parameter   HACTIVE     = 640,
    parameter   VACTIVE     = 480,
    parameter   PIXEL_WIDTH = 8
) (
    // 
    input   wire                            VCLK,
    input   wire                            RST_N,
    //
    input   wire                            iVSYNC,
    input   wire                            iHSYNC,
    input   wire                            iDE,
    //
    input   wire    [ADDR_WIDTH -1: 0]      iH_ADDR,
    input   wire    [ADDR_WIDTH -1: 0]      iV_ADDR,
    //
    input   wire    [HACTIVE -1: 0]         iMEMOUT_0,
    input   wire    [HACTIVE -1: 0]         iMEMOUT_1,  // for VGA out
    input   wire    [HACTIVE -1: 0]         iMEMOUT_2,  // for VGA out
    input   wire    [HACTIVE -1: 0]         iMEMOUT_3,  // for VGA out
    input   wire    [HACTIVE -1: 0]         iMEMOUT_4,  // for VGA out
    input   wire    [HACTIVE -1: 0]         iMEMOUT_5,  // for VGA out
    //
    input   wire                            iVGAout_mode,
    //
    input   wire    [ADDR_WIDTH -1: 0]      iPOINT_X,
    input   wire    [ADDR_WIDTH -1: 0]      iPOINT_Y,
    //
    output  wire                            oVGA_HSYNC,
    output  wire                            oVGA_VSYNC,
    output  wire                            oVGA_DE,
    //
    output  reg     [PIXEL_WIDTH -1: 0]     oVGA_R,
    output  reg     [PIXEL_WIDTH -1: 0]     oVGA_G,
    output  reg     [PIXEL_WIDTH -1: 0]     oVGA_B
);

endmodule
