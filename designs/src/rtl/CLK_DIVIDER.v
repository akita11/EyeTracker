// -----------------------------------------------------------------------------
//  Title         : Clock Divider
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : CLK_DIVIDER.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 4/15
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Calculate center of gravity
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module CLK_DIVIDER #(
    parameter   DIVIDE      = 8
) (
    // 
    input   wire                            CLK,
    input   wire                            RST_N,
    //
    output  wire                            oDIV_CLK
);

    //
    reg     [$clog2(DIVIDE): 0]             counter;
    reg                                     div_clk;

    //
    assign  oDIV_CLK = div_clk;

    // 
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            div_clk <= 1'b0;
            counter <= 'h0;
        end else if (counter == (DIVIDE - 'h1)) begin
            div_clk <= 1'b0;
            counter <= 'h0;
        end else if (counter >= DIVIDE/2) begin
            div_clk <= 1'b1;
            counter <= counter + 1;
        end else begin
            div_clk <= div_clk;
            counter <= counter + 1;
        end
    end

endmodule
