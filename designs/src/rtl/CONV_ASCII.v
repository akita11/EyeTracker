// -----------------------------------------------------------------------------
//  Title         : Convert to Ascii code
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : CONV_ASCII.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 4/15
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : UART Rx core
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module CONV_ASCII #(
    parameter   DATA_WIDTH = 8
) (
    input   wire                                CLK,
    input   wire                                RST_N,
    //
    input   wire    [DATA_WIDTH -1 : 0]         iDATA,
    //
    output  wire    [DATA_WIDTH * 2 -1 : 0]     oASCII
);

    //
    generate
        genvar                                      i;
        //
        for (i=0; i< DATA_WIDTH; i=i+4) begin: inst_loop
            CONV_ASCII_UNIT m_CONV_ASCII_UNIT(
                .CLK(CLK), .RST_N(RST_N), 
                //
                .iD(iDATA[i+3:i]), 
                //
                .oD(oASCII[i*2+7:i*2])
            );
        end
    endgenerate

endmodule
