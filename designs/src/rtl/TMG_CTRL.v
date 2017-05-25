// -----------------------------------------------------------------------------
//  Title         : Timing Controller
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : TMG_CTRL.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 1/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Video Timing Controller
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module TMG_CTRL #(
    parameter   PARAM_WIDTH = 10
) (
    // 
    input   wire                            CLK,
    input   wire                            RST_N,
    //
    input   wire    [PARAM_WIDTH -1: 0]     iHTOTAL,
    input   wire    [PARAM_WIDTH -1: 0]     iHACT,
    input   wire    [PARAM_WIDTH -1: 0]     iHS_WIDTH,
    input   wire    [PARAM_WIDTH -1: 0]     iHS_BP,
    //
    input   wire    [PARAM_WIDTH -1: 0]     iVTOTAL,
    input   wire    [PARAM_WIDTH -1: 0]     iVACT,
    input   wire    [PARAM_WIDTH -1: 0]     iVS_WIDTH,
    input   wire    [PARAM_WIDTH -1: 0]     iVS_BP,
    //
    output  wire                            oHSYNC,
    output  wire                            oVSYNC,
    output  wire                            oDE,
    output  wire                            oFIELD,
    //
    output  wire    [PARAM_WIDTH -1: 0]     oHCOUNT,
    output  wire    [PARAM_WIDTH -1: 0]     oVCOUNT
);

    reg                                     next_hsync, hsync;
    reg                                     next_vsync, vsync;
    reg                                     next_hde, hde;
    reg                                     next_vde, vde;
    reg                                     next_field, field;

    reg     [PARAM_WIDTH -1: 0]             next_hcount, hcount;
    reg     [PARAM_WIDTH -1: 0]             next_vcount, vcount;

    // 
    assign  oHSYNC = hsync;
    assign  oVSYNC = vsync;
    assign  oDE    = hde & vde;
    assign  oFIELD = field;

    assign  oHCOUNT = hcount;
    assign  oVCOUNT = vcount;
    // 
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N == 1'b1) begin
            hcount <= 'h0;
            vcount <= 'h0;
            // 
            hsync  <= 1'b1;
            hde    <= 1'b0;
            // 
            vsync  <= 1'b1;
            vde    <= 1'b0;
            // 
            field  <= 1'b0;
        end else begin
            hcount <= next_hcount;
            vcount <= next_vcount;
            // 
            hsync  <= next_hsync;
            hde    <= next_hde;
            // 
            vsync  <= next_vsync;
            vde    <= next_vde;
            // 
            field  <= next_field;
        end
    end

    // Count up hcount & vcount
    always @(*) begin
        if (hcount == iHTOTAL - 'h1) begin
            if (vcount == iVTOTAL - 'h1) begin
                next_hcount <= 'h0;
                next_vcount <= 'h0;
                //
                next_field  <= ~field;
            end else begin
                next_hcount <= 'h0;
                next_vcount <= vcount + 'h1;
                //
                next_field  <= field;
            end
        end else begin
            next_hcount <= hcount + 'h1;
            next_vcount <= vcount;
            //
            next_field  <= field;
        end
    end

    // Generate hsync & hde
    always @(*) begin
        if (hcount == (iHS_WIDTH - 'h1)) begin
            next_hsync <= 1'b0;
            next_hde   <= 1'b0;
        end else if (hcount == (iHS_WIDTH + iHS_BP - 'h1)) begin
            next_hsync <= 1'b0;
            next_hde   <= 1'b1;
        end else if (hcount == (iHS_WIDTH + iHS_BP + iHACT - 'h1)) begin
            next_hsync <= 1'b0;
            next_hde   <= 1'b0;
        end else if (hcount == (iHTOTAL - 'h1)) begin
            next_hsync <= 1'b1;
            next_hde   <= 1'b0;
        end else begin
            next_hsync <= hsync;
            next_hde   <= hde;
        end
    end

    // Generate vsync & vde
    always @(*) begin
        if (next_vcount == (iVS_WIDTH - 'h1)) begin
            next_vsync <= 1'b0;
            next_vde   <= 1'b0;
        end else if (next_vcount == (iVS_WIDTH + iVS_BP - 'h1)) begin
            next_vsync <= 1'b0;
            next_vde   <= 1'b1;
        end else if (next_vcount == (iVS_WIDTH + iVS_BP + iVACT - 'h1)) begin
            next_vsync <= 1'b0;
            next_vde   <= 1'b0;
        end else if (next_vcount == (iVTOTAL - 'h1)) begin
            next_vsync <= 1'b1;
            next_vde   <= 1'b0;
        end else begin
            next_vsync <= vsync;
            next_vde   <= vde;
        end
    end

endmodule
