// -----------------------------------------------------------------------------
//  Title         : Register Bus IF
//  Project       : Common
// -----------------------------------------------------------------------------
//  File          : HOST_IF.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 6/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : HOST IF
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module REG_BUS_IF #(
    parameter       ADDR_WIDTH      = 16,
    parameter       WE_WIDTH        = 8,
    parameter       RE_WIDTH        = 8
) (
    input   wire                                CLK,
    input   wire                                RST_N,
    // from/to HOST_IF
    input   wire    [ADDR_WIDTH -1: 0]          iADDR,
    input   wire                                iWE,
    input   wire                                iRE,
    input   wire    [DATA_WIDTH -1: 0]          iDATA,
    output  wire                                oRD_EN,
    output  wire    [DATA_WIDTH -1: 0]          oRD,
    // from/to each REG module
    output  wire    [WE_WIDTH -1: 0]            oWE_BIT,
    output  wire    [RE_WIDTH -1: 0]            oRE_BIT,
    output  wire    [DATA_WIDTH -1: 0]          oWD,
    input   wire                                iRD_EN,
    input   wire    [DATA_WIDTH -1: 0]          iRD
);

    //
    localparam      DATA_WIDTH                  = 8;

    //
    reg     [DATA_WIDTH -1: 0]                  wrt_data;
    reg     [DATA_WIDTH -1: 0]                  rd_data;

    reg     [WE_WIDTH -1: 0]                    we_bit;
    reg     [RE_WIDTH -1: 0]                    re_bit;

    reg                                         out_rd_en;

    integer                                     i;

    //
    assign  oWD    = wrt_data;
    assign  oRD_EN = out_rd_en;
    assign  oRD    = rd_data;

    //
    assign  oWE_BIT = we_bit;
    assign  oRE_BIT = re_bit;

    // for write_data/read_data
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            wrt_data <= 'h0;
            rd_data  <= 'h0;
        end else begin
            wrt_data <= (iWE   ) ? iDATA: wrt_data;
            rd_data  <= (iRD_EN) ?   iRD:  rd_data;
        end
    end

    // 
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            out_rd_en <= 1'b0;
        end else begin
            out_rd_en <= iRE;
        end
    end

    // for we_bit
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            we_bit <= 'h0;
        end else begin
            for (i=0;i<WE_WIDTH;i=i+1) begin
                if (iADDR == i) begin
                    we_bit[i] <= iWE;
                end else begin
                    we_bit[i] <= 1'b0;
                end
            end
        end
    end

    // for re_bit
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            re_bit <= 'h0;
        end else begin
            for (i=0;i<RE_WIDTH;i=i+1) begin
                if (iADDR == i) begin
                    re_bit[i] <= iRE;
                end else begin
                    re_bit[i] <= 1'b0;
                end
            end
        end
    end

endmodule
