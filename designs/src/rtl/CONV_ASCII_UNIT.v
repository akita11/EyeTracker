// -----------------------------------------------------------------------------
//  Title         : Convert Ascii Unit
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : CONV_ASCII_UNIT.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 4/14
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Calculate center of gravity
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module CONV_ASCII_UNIT (
    input   wire                            CLK,
    input   wire                            RST_N,
    //
    input   wire    [DATA_WIDTH -1: 0]      iD,
    //
    output  reg     [DATA_WIDTH * 2 -1: 0]  oD
);
    //
    localparam      DATA_WIDTH              = 4;

    //
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            oD <= "0";
        end else if (iD > 9) begin
            oD <= "A" + iD - 'hA;
        end else begin
            oD <= "0" + iD;
        end
    end

endmodule
