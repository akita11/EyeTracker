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

module EXPAND_SIGNAL #(
    parameter   EXPAND_NUM = 1
) (
    input   wire                            CLK,
    input   wire                            RST_N,
    input   wire                            iS,
    output  wire                            oS
);

    wire                                    start_trig;

    reg     [$clog2(EXPAND_NUM): 0]         counter;
    reg                                     sig;

    //
    assign  oS = sig;

    // 
    DET_EDGE m_DET_START_TRIG( .CLK(CLK), .RST_N(RST_N), .iS(iS), .oRISE(start_trig), .oFALL() );

    //
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            counter <= 'h0;
            sig     <= 1'b0;
        end else if (start_trig) begin
            counter <= EXPAND_NUM -'h1;
            sig     <= 1'b1;
        end else if (counter != 'h0) begin
            counter <= counter -'h1;
            sig     <= sig;
        end else begin
            counter <= 'h0;
            sig     <= 1'b0;
        end
    end

endmodule

module DFF_REG #(
    parameter   DATA_WIDTH = 1,
    parameter   INIT_VAL   = 'h0
) (
    input   wire                            CLK,
    input   wire                            RST_N,
    input   wire                            iWE,
    input   wire    [DATA_WIDTH -1: 0]      iD,
    output  reg     [DATA_WIDTH -1: 0]      oD
);

    //
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            oD <= INIT_VAL;
        end else begin
            oD <= (iWE) ? iD: oD;
        end
    end

endmodule
