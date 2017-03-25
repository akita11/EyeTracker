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
    input   wire    [(1<<BIT_WIDTH) -1: 0]  iBIT,
    output  wire    [BIT_WIDTH: 0]          oCOUNT
);

    localparam  TOTAL_WIDTH = 1 << BIT_WIDTH;
    localparam  HALF_WIDTH  = 1 << (BIT_WIDTH - 1);

    wire    [BIT_WIDTH   -1: 0]             count_upper_side;
    wire    [BIT_WIDTH   -1: 0]             count_lower_side;

    if (BIT_WIDTH == 0) begin
        assign  oCOUNT = iBIT;
    end else begin
        //
        COUNT_HIGH_BIT #( .BIT_WIDTH(BIT_WIDTH-1) ) m_COUNT_UPPER_SIDE( .iBIT(iBIT[TOTAL_WIDTH -1: HALF_WIDTH]), .oCOUNT(count_upper_side) );
        COUNT_HIGH_BIT #( .BIT_WIDTH(BIT_WIDTH-1) ) m_COUNT_LOWER_SIDE( .iBIT(iBIT[HALF_WIDTH  -1:          0]), .oCOUNT(count_lower_side) );
        //
        assign  oCOUNT = count_upper_side + count_lower_side;
    end

endmodule
