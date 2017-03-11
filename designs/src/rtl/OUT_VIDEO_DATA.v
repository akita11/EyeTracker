// -----------------------------------------------------------------------------
//  Title         : Output Video Data
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : OUT_VIDEO_DATA.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 1/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : 
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module OUT_VIDEO_DATA #(
    parameter   PIXEL_WIDTH = 8
) (
    // 
    input   wire                            CLK,
    input   wire                            RST_N,
    //
    input   wire                            iHSYNC,
    input   wire                            iVSYNC,
    input   wire                            iDE,
    input   wire    [PIXEL_WIDTH -1: 0]     iR0,
    input   wire    [PIXEL_WIDTH -1: 0]     iG0,
    input   wire    [PIXEL_WIDTH -1: 0]     iB0,
    //
    output  wire                            oHSYNC,
    output  wire                            oVSYNC,
    output  wire                            oDE,
    output  wire    [PIXEL_WIDTH -1: 0]     oR0,
    output  wire    [PIXEL_WIDTH -1: 0]     oG0,
    output  wire    [PIXEL_WIDTH -1: 0]     oB0
);

    // 
    reg                                     hsync;
    reg                                     vsync;
    reg                                     de;
    reg             [PIXEL_WIDTH -1: 0]     r0;
    reg             [PIXEL_WIDTH -1: 0]     g0;
    reg             [PIXEL_WIDTH -1: 0]     b0;

    // 
    assign  oHSYNC = hsync;
    assign  oVSYNC = vsync;
    assign  oDE    = de;
    assign  oR0    = r0;
    assign  oG0    = g0;
    assign  oB0    = b0;

    //
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            hsync <= 1'b0;
            vsync <= 1'b0;
            de    <= 1'b0;
            r0    <= 'h0;
            g0    <= 'h0;
            b0    <= 'h0;
        end else begin
            hsync <= iHSYNC;
            vsync <= iVSYNC;
            de    <= iDE;
            r0    <= iR0;
            g0    <= iG0;
            b0    <= iB0;
        end
    end

endmodule
