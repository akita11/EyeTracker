// -----------------------------------------------------------------------------
//  Title         : Is Function
//  Project       : Common Library
// -----------------------------------------------------------------------------
//  File          : IS_FUNC.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 4/15
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : UART Rx core
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module IS_XDIGIT #(
    parameter   DATA_WIDTH = 8
) (
    input   wire                                CLK,
    input   wire                                RST_N,
    //
    input   wire    [DATA_WIDTH -1: 0]          iCHAR,
    //
    output  wire                                oRESULT,
    output  reg                                 oRESULT_FF
);

    //
    wire    [DATA_WIDTH / 8 -1: 0]              result;

    //
    assign  oRESULT = &result;

    //
    generate
        genvar                                      i;
        //
        for (i=0; i< DATA_WIDTH; i=i+8) begin: inst_loop
            IS_XDIGIT_UNIT m_IS_XDIGIT_UNIT(
                .iCHAR(iCHAR[i+7:i]), 
                //
                .oRESULT(result[i/8])
            );
        end
    endgenerate

    //
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            oRESULT_FF = 1'b0;
        end else begin
            oRESULT_FF = &result;
        end
    end

endmodule

module IS_XDIGIT_UNIT (
    input   wire    [DATA_WIDTH -1: 0]          iCHAR,
    //
    output  wire                                oRESULT
);

    localparam  DATA_WIDTH                      = 8;

    //
    reg                                         result;

    //
    assign  oRESULT = result;

    //
    always @(*) begin
        if ((iCHAR>= "0") && (iCHAR<= "9")) begin
            result <= 1'b1;
        end else if ((iCHAR>= "A") && (iCHAR<= "F")) begin
            result <= 1'b1;
        end else if ((iCHAR>= "a") && (iCHAR<= "f")) begin
            result <= 1'b1;
        end else begin
            result <= 1'b0;
        end
    end

endmodule
