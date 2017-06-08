// -----------------------------------------------------------------------------
//  Title         : SUM Unit
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : SUM_UNIT.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 3/26
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Calculate center of gravity
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module SUM_UNIT #(
    parameter   FACTOR_WIDTH = 10,
    parameter   IDATA_WIDTH  = 8,
    parameter   ODATA_WIDTH  = 16
) (
    // 
    input   wire                            CLK,
    input   wire                            RST_N,
    //
    input   wire                            iCLR,
    //
    input   wire                            iDATA_EN,
    input   wire    [FACTOR_WIDTH -1: 0]    iFACTOR,
    input   wire    [IDATA_WIDTH -1: 0]     iD,
    //
    output  reg     [ODATA_WIDTH -1: 0]     oD
);

    //
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            oD <= 'h0;
        end else if (iCLR) begin
            oD <= 'h0;
        end else if (iDATA_EN) begin
            oD <= oD + iFACTOR * iD;
        end else begin
            oD <= oD;
        end
    end

endmodule
