// -----------------------------------------------------------------------------
//  Title         : Convert Hex Unit
//  Project       : Common Library
// -----------------------------------------------------------------------------
//  File          : CONV_HEX_UNIT.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 6/10
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Calculate center of gravity
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module CONV_HEX_UNIT (
    input   wire                            CLK,
    input   wire                            RST_N,
    //
    input   wire    [DATA_WIDTH * 2 -1: 0]  iD,
    //
    output  reg     [DATA_WIDTH     -1: 0]  oD
);
    //
    localparam      DATA_WIDTH              = 4;

    //
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            oD <= 'h0;
        end else if ((iD >= "0") && (iD <= "9")) begin
            oD <= iD - "0";
        end else if ((iD >= "A") && (iD <= "F")) begin
            oD <= iD - "A" + 'hA;
        end else if ((iD >= "a") && (iD <= "f")) begin
            oD <= iD - "a" + 'hA;
        end else begin
            oD <= 'h0;
        end
    end

endmodule
