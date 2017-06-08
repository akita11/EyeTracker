// -----------------------------------------------------------------------------
//  Title         : Count High bit
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : COUNT_HIGH_BIT.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 3/25
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Calculate center of gravity
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module COUNT_HIGH_BIT #(
    parameter   BIT_WIDTH   = 32
) (
    input   wire    [BIT_WIDTH -1: 0]               iBIT,
    output  wire    [$clog2(BIT_WIDTH): 0]          oCOUNT
);

    reg     [$clog2(BIT_WIDTH): 0]                  sum;

/*
    localparam  UPPER_WIDTH = BIT_WIDTH >> 1;
    localparam  LOWER_WIDTH = BIT_WIDTH - UPPER_WIDTH;

    wire    [$clog2(BIT_WIDTH): 0]                  count_upper_side;
    wire    [$clog2(BIT_WIDTH): 0]                  count_lower_side;

    if (BIT_WIDTH == 0) begin
        assign  oCOUNT = iBIT;
    end else begin
        //
        COUNT_HIGH_BIT #( .BIT_WIDTH(UPPER_WIDTH) ) m_COUNT_UPPER_SIDE( .iBIT(iBIT[BIT_WIDTH   -1: LOWER_WIDTH]), .oCOUNT(count_upper_side) );
        COUNT_HIGH_BIT #( .BIT_WIDTH(LOWER_WIDTH) ) m_COUNT_LOWER_SIDE( .iBIT(iBIT[LOWER_WIDTH -1:           0]), .oCOUNT(count_lower_side) );
        //
        assign  oCOUNT = count_upper_side + count_lower_side;
    end
*/

    integer                                         i;

    always @(*) begin
        sum = 0;
        for(i=0;i<BIT_WIDTH;i=i+1)
        sum = sum + iBIT[i];
    end
 
    assign oCOUNT = sum;

endmodule
