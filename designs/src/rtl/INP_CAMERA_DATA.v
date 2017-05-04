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
    output  wire    [PIXEL_WIDTH -1: 0]     oDATA_L,
    output  wire    [PIXEL_WIDTH -1: 0]     oDATA_R
);

    // 
    reg                                     lval;
    reg                                     fval;
    reg                                     dval;
    reg             [PIXEL_WIDTH -1: 0]     data_l;
    reg             [PIXEL_WIDTH -1: 0]     data_r;

    // 
    assign  oVSYNC  = fval ^ iFVAL_POL;
    assign  oHSYNC  = lval ^ iLVAL_POL;
    assign  oDE     = (fval & lval & dval ) ^ iDVAL_POL;
    assign  oDATA_L = data_l;
    assign  oDATA_R = data_r;

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

endmodule
