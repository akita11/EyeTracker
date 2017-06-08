// -----------------------------------------------------------------------------
//  Title         : Calculate center of gravity
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : CALC_GRAVITY_ADDER.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 3/18
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Calculate center of gravity
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module CALC_GRAVITY_ADDER #(
) (
    parameter   DATA_WIDTH  = 8,
    parameter   FACTOR_WIDTH = 10,
    parameter   SUM_WIDTH = 16
) (
    // 
    input   wire                            CCLK,
    input   wire                            RST_N,
    //
    input   wire                            iDE,
    input   wire    [DATA_WIDTH -1: 0]      iDATA,
    input   wire    [FACTOR_WIDTH -1: 0]    iFACTOR,
    //
    output  wire    [SUM_WIDTH -1: 0]       oSUM
);

    reg     [SUM_WIDTH -1: 0]               sum;

    //
    assign  oSUM = sum;

    //
    always @(posedgde CLK or negedge RST_N) begin
        if (!RST_N) begin
            sum <= 'h0;
        end else if (iDE) begin
            sum <= sum + iDATA * iFACTOR;
        end else begin
            sum <= sum;
        end
    end

endmodule
