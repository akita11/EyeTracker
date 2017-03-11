// -----------------------------------------------------------------------------
//  Title         : Common User Library
//  Project       : All projects
// -----------------------------------------------------------------------------
//  File          : USER_LIB.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 1/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Common User Library
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module DFF #(
    parameter   DATA_WIDTH = 1
) (
    input   wire                            CLK,
    input   wire                            RST_N,
    input   wire    [DATA_WIDTH -1: 0]      iD,
    output  reg     [DATA_WIDTH -1: 0]      oD
);

    //
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            oD <= 'h0;
        end else begin
            oD <= iD;
        end
    end

endmodule

module ASYNC_SYNC_RST (
    input   wire                            CLK,
    input   wire                            RST_N,
    output  wire                            SYNC_RST_N
);

    CYCLE_DELAY #( .DATA_WIDTH(1), .DELAY(3) ) m_ASYNC_SYN_GEN( .CLK(CLK), .RST_N(RST_N), .iD(1'b1), .oD(SYNC_RST_N) );

endmodule

module CYCLE_DELAY #(
    parameter   DATA_WIDTH = 1,
    parameter   DELAY = 1
) (
    input   wire                            CLK,
    input   wire                            RST_N,
    input   wire    [DATA_WIDTH -1: 0]      iD,
    output  wire    [DATA_WIDTH -1: 0]      oD
);

    //
    reg     [DATA_WIDTH -1: 0]              dly [0:DELAY -1];

    //
    integer                                 i;

    assign  oD = dly[DELAY -1];

    generate
        if (DELAY == 1) begin :one_bit
            always @(posedge CLK or negedge RST_N) begin
                if (!RST_N) begin
                    dly[0] <= 1'b0;
                end else begin
                    dly[0] <= iD;
                end
            end
        end else begin :multi_bits
            always @(posedge CLK or negedge RST_N) begin
                if (!RST_N) begin
                    for (i=0;i<DELAY;i=i+1) begin:loop_one
                        dly[i] <= 1'b0;
                    end
                end else begin
                    dly[0] <= iD;
                    for (i=0;i<DELAY-1;i=i+1) begin:loop_multi
                        dly[i+1] <= dly[i];
                    end
                end
            end
        end
    endgenerate

endmodule

module DET_EDGE (
    input   wire                            CLK,
    input   wire                            RST_N,
    input   wire                            iS,
    output  wire                            oRISE,
    output  wire                            oFALL
);

    reg                                     dly;

    assign  oRISE =  iS & ~dly;
    assign  oFALL = ~iS &  dly;
    
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            dly <= 1'b0;
        end else begin
            dly <= iS;
        end
    end

endmodule
