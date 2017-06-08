// -----------------------------------------------------------------------------
//  Title         : Input Camera Data
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : INP_CAMERA_DATA.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 1/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : 
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module INP_CAMERA_DATA #(
    parameter   PIXEL_WIDTH = 8
) (
    // 
    input   wire                            CLK,
    input   wire                            RST_N,
    //
    input   wire                            iLVAL_POL,
    input   wire                            iFVAL_POL,
    input   wire                            iDVAL_POL,
    //
    input   wire                            iLVAL,
    input   wire                            iFVAL,
    input   wire                            iDVAL,
    input   wire    [PIXEL_WIDTH -1: 0]     iDATA_L,
    input   wire    [PIXEL_WIDTH -1: 0]     iDATA_R,
    //
    output  wire                            oVSYNC,
    output  wire                            oHSYNC,
    output  wire                            oDE,
    output  wire                            oFIELD,
    output  wire    [PIXEL_WIDTH -1: 0]     oDATA_L,
    output  wire    [PIXEL_WIDTH -1: 0]     oDATA_R
);

    // 
    reg                                     lval;
    reg                                     fval;
    reg                                     dval;
    reg                                     field;
    reg             [PIXEL_WIDTH -1: 0]     data_l;
    reg             [PIXEL_WIDTH -1: 0]     data_r;

    wire                                    rise_vsync;
    wire                                    fall_vsync;

    wire                                    hsync;
    wire                                    vsync;
    wire                                    de;

    //
    assign  vsync = fval ^ iFVAL_POL;
    assign  hsync = lval ^ iLVAL_POL;
    assign  de    = (fval & lval & dval ) ^ iDVAL_POL;

    // 
    assign  oVSYNC  = vsync;
    assign  oHSYNC  = hsync & ~vsync;
    assign  oDE     = de;
    assign  oFIELD  = field;
    assign  oDATA_L = data_l;
    assign  oDATA_R = data_r;

    //
    DET_EDGE m_DET_VSYNC_EDGE( .CLK(CLK), .RST_N(RST_N), .iS(iFVAL ^ iFVAL_POL), .oRISE(rise_vsync), .oFALL(fall_vsync) );
    

    //
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            lval   <= 1'b0;
            fval   <= 1'b0;
            dval   <= 1'b0;
            data_l <= 'h0;
            data_r <= 'h0;
        end else begin
            lval   <= iLVAL;
            fval   <= iFVAL;
            dval   <= iDVAL;
            data_l <= iDATA_L;
            data_r <= iDATA_R;
        end
    end

    //
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            field <= 1'b0;
        end else if (fall_vsync) begin
            field <= ~field;
        end else begin
            field <= field;
        end
    end

endmodule
