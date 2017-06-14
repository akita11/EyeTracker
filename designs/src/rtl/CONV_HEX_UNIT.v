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
    output  reg                             oDEC_ERR,
    output  reg     [DATA_WIDTH     -1: 0]  oD
);
    //
    localparam      DATA_WIDTH              = 4;

    //
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            oDEC_ERR <= 1'b0;
            oD       <= 'h0;
        end else if ((iD >= "0") && (iD <= "9")) begin
            oDEC_ERR <= 1'b0;
            oD       <= iD - "0";
        end else if ((iD >= "A") && (iD <= "F")) begin
            oDEC_ERR <= 1'b0;
            oD       <= iD - "A" + 'hA;
        end else if ((iD >= "a") && (iD <= "f")) begin
            oDEC_ERR <= 1'b0;
            oD       <= iD - "a" + 'hA;
        end else begin
            oDEC_ERR <= 1'b1;
            oD       <= 'h0;
        end
    end

endmodule
