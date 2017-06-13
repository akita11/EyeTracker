// -----------------------------------------------------------------------------
//  Title         : Convert to Hex from Ascii code
//  Project       : Common Library
// -----------------------------------------------------------------------------
//  File          : CONV_HEX.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 6/10
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : UART Rx core
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module CONV_HEX #(
    parameter   CHAR_NUM = 2
) (
    input   wire                                CLK,
    input   wire                                RST_N,
    //
    input   wire    [CHAR_NUM * 8 -1 : 0]       iASCII,
    //
    output  wire    [CHAR_NUM * 4 -1 : 0]       oDATA
);

    //
    generate
        genvar                                      i;
        //
        for (i=0; i< CHAR_NUM; i=i+1) begin: inst_loop
            CONV_HEX_UNIT m_CONV_HEX_UNIT(
                .CLK(CLK), .RST_N(RST_N), 
                //
                .iD(iASCII[i*8+7:i*8]), 
                //
                .oD(oDATA[i*4+3:i*4])
            );
        end
    endgenerate

endmodule
