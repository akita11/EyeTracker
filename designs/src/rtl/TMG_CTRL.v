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
    output  wire    [PARAM_WIDTH -1: 0]     oHTCOUNT,
    output  wire    [PARAM_WIDTH -1: 0]     oVTCOUNT,
    output  wire    [PARAM_WIDTH -1: 0]     oHDCOUNT,
    output  wire    [PARAM_WIDTH -1: 0]     oVDCOUNT
);

    reg                                     next_hsync, hsync;
    reg                                     next_vsync, vsync;
    reg                                     next_hde, hde;
    reg                                     next_vde, vde;
    reg                                     next_field, field;

    reg     [PARAM_WIDTH -1: 0]             next_htcount, htcount;
    reg     [PARAM_WIDTH -1: 0]             next_vtcount, vtcount;
    reg     [PARAM_WIDTH -1: 0]             next_hdcount, hdcount;
    reg     [PARAM_WIDTH -1: 0]             next_vdcount, vdcount;

    // 
    assign  oHSYNC = hsync;
    assign  oVSYNC = vsync;
    assign  oDE    = hde & vde;
    assign  oFIELD = field;

    assign  oHTCOUNT = htcount;
    assign  oVTCOUNT = vtcount;
    assign  oHDCOUNT = hdcount;
    assign  oVDCOUNT = vdcount;
    // 
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N == 1'b1) begin
            htcount <= 'h0;
            vtcount <= 'h0;
            hdcount <= 'h0;
            vdcount <= 'h0;
            // 
            hsync   <= 1'b1;
            hde     <= 1'b0;
            // 
            vsync   <= 1'b1;
            vde     <= 1'b0;
            // 
            field   <= 1'b0;
        end else begin
            htcount <= next_htcount;
            vtcount <= next_vtcount;
            hdcount <= next_hdcount;
            vdcount <= next_vdcount;
            // 
            hsync   <= next_hsync;
            hde     <= next_hde;
            // 
            vsync   <= next_vsync;
            vde     <= next_vde;
            // 
            field   <= next_field;
        end
    end

    // Count up hcount & vcount
    always @(*) begin
        if (htcount == iHTOTAL - 'h1) begin
            if (vtcount == iVTOTAL - 'h1) begin
                next_htcount <= 'h0;
                next_vtcount <= 'h0;
                //
                next_field   <= ~field;
            end else begin
                next_htcount <= 'h0;
                next_vtcount <= vtcount + 'h1;
                //
                next_field   <= field;
            end
        end else begin
            next_htcount <= htcount + 'h1;
            next_vtcount <= vtcount;
            //
            next_field   <= field;
        end
    end

    // Generate hsync & hde
    always @(*) begin
        if (htcount == (iHS_WIDTH - 'h1)) begin
            next_hdcount <= 'h0;
            next_hsync   <= 1'b0;
            next_hde     <= 1'b0;
        end else if (htcount == (iHS_WIDTH + iHS_BP - 'h1)) begin
            next_hdcount <= hdcount;
            next_hsync   <= 1'b0;
            next_hde     <= 1'b1;
        end else if (htcount == (iHS_WIDTH + iHS_BP + iHACT - 'h1)) begin
            next_hdcount <= hdcount;
            next_hsync   <= 1'b0;
            next_hde     <= 1'b0;
        end else if (htcount == (iHTOTAL - 'h1)) begin
            next_hdcount <= 'h0;
            next_hsync   <= 1'b1;
            next_hde     <= 1'b0;
        end else begin
            next_hdcount <= ((hde==1'b1) && (vde==1'b1)) ? hdcount + 'h1: hdcount;
            next_hsync   <= hsync;
            next_hde     <= hde;
        end
    end

    // Generate vsync & vde
    always @(*) begin
        if (next_vtcount == (iVS_WIDTH - 'h1)) begin
            next_vdcount <= 'h0;
            next_vsync   <= 1'b0;
            next_vde     <= 1'b0;
        end else if (next_vtcount == (iVS_WIDTH + iVS_BP - 'h1)) begin
            next_vdcount <= vdcount;
            next_vsync   <= 1'b0;
            next_vde     <= 1'b1;
        end else if (next_vtcount == (iVS_WIDTH + iVS_BP + iVACT - 'h1)) begin
            next_vdcount <= vdcount;
            next_vsync   <= 1'b0;
            next_vde     <= 1'b0;
        end else if (next_vtcount == (iVTOTAL - 'h1)) begin
            next_vdcount <= 'h0;
            next_vsync   <= 1'b1;
            next_vde     <= 1'b0;
        end else begin
            next_vdcount <= ((vde==1'b1) && (htcount == (iHTOTAL - 'h1))) ? vdcount + 'h1: vdcount;
            next_vsync   <= vsync;
            next_vde     <= vde;
        end
    end

endmodule
