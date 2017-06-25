// -----------------------------------------------------------------------------
//  Title         : EyeTracker Register
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : EYE_TRACKER_REG.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 6/11
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : EyeTracker
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module EYE_TRACKER_REG (
    input   wire                                CLK,
    input   wire                                RST_N,
    // from/to HOST_IF
    input   wire    [WE_WIDTH -1: 0]            iWE_BIT,
    input   wire    [RE_WIDTH -1: 0]            iRE_BIT,
    input   wire    [DATA_WIDTH -1: 0]          iDATA,
    output  wire    [DATA_WIDTH -1: 0]          oRD,
    //
    input   wire                                iFVSYNC,
    input   wire                                iRVSYNC,
    //
    input   wire    [SUM_S_WIDTH -1: 0]         iSUM_S,
    input   wire    [SUM_SX_WIDTH -1: 0]        iSUM_SX,
    input   wire    [SUM_SY_WIDTH -1: 0]        iSUM_SY,
    input   wire    [SUM_SX_WIDTH -1: 0]        iQUOTIENT_SX,
    input   wire    [SUM_SY_WIDTH -1: 0]        iQUOTIENT_SY,
    //
    output  wire                                oUART_SW,
    output  wire                                oVGA_OUT_MODE,
    output  wire    [DATA_WIDTH -1: 0]          oTHRESHOLD,
    output  wire                                oCURSOR_EN,
    output  wire                                oOUT_SEL
);

    //
    localparam      DATA_WIDTH                  = 8;
    localparam      WE_WIDTH                    = 24;
    localparam      RE_WIDTH                    = 24;

    //
    localparam      SUM_S_WIDTH                 = 20;
    localparam      SUM_SX_WIDTH                = 28;
    localparam      SUM_SY_WIDTH                = 28;

    //
    reg     [DATA_WIDTH -1: 0]                  rd0_data;
    reg     [DATA_WIDTH -1: 0]                  rd1_data;

    //
    assign  oRD    = rd0_data | rd1_data;

    //
    DFF_REG   #( .DATA_WIDTH(1), .INIT_VAL(1'b0 ) ) m_UART_SW      ( .CLK(CLK), .RST_N(RST_N), .iWE(iWE_BIT[0]), .iD(iDATA[  0]), .oD(oUART_SW     ) );
    DFF_REG   #( .DATA_WIDTH(1), .INIT_VAL(1'b1 ) ) m_VGA_OUT_MODE ( .CLK(CLK), .RST_N(RST_N), .iWE(iWE_BIT[1]), .iD(iDATA[  0]), .oD(oVGA_OUT_MODE) );
    DFF_REG   #( .DATA_WIDTH(8), .INIT_VAL(8'h01) ) m_THRESHOLD    ( .CLK(CLK), .RST_N(RST_N), .iWE(iWE_BIT[2]), .iD(iDATA[7:0]), .oD(oTHRESHOLD   ) );
    DFF_REG   #( .DATA_WIDTH(1), .INIT_VAL(1'b1 ) ) m_CURSOR_EN    ( .CLK(CLK), .RST_N(RST_N), .iWE(iWE_BIT[3]), .iD(iDATA[  0]), .oD(oCURSOR_EN   ) );
    DFF_REG   #( .DATA_WIDTH(1), .INIT_VAL(1'b1 ) ) m_OUT_SEL      ( .CLK(CLK), .RST_N(RST_N), .iWE(iWE_BIT[3]), .iD(iDATA[  1]), .oD(oOUT_SEL     ) );

    //
    always @(*) begin
        case (iRE_BIT[15: 0])
            16'b0000_0000_0000_0001:    rd0_data <= { 7'b0000_000, oUART_SW };
            16'b0000_0000_0000_0010:    rd0_data <= { 7'b0000_000, oVGA_OUT_MODE };
            16'b0000_0000_0000_0100:    rd0_data <= oTHRESHOLD;
            16'b0000_0000_0000_1000:    rd0_data <= { 6'b0000_00, oOUT_SEL, oCURSOR_EN };
            16'b0000_0000_0001_0000:    rd0_data <= iSUM_S[ 7: 0];
            16'b0000_0000_0010_0000:    rd0_data <= iSUM_S[15: 8];
            16'b0000_0000_0100_0000:    rd0_data <= { 4'h0, iSUM_S[19:16] };
            16'b0000_0000_1000_0000:    rd0_data <= 8'h0;
            16'b0000_0001_0000_0000:    rd0_data <= iSUM_SX[ 7: 0];
            16'b0000_0010_0000_0000:    rd0_data <= iSUM_SX[15: 8];
            16'b0000_0100_0000_0000:    rd0_data <= iSUM_SX[23:16];
            16'b0000_1000_0000_0000:    rd0_data <= { 4'h0, iSUM_SX[27:24] };
            16'b0001_0000_0000_0000:    rd0_data <= iSUM_SY[ 7: 0];
            16'b0010_0000_0000_0000:    rd0_data <= iSUM_SY[15: 8];
            16'b0100_0000_0000_0000:    rd0_data <= iSUM_SY[23:16];
            16'b1000_0000_0000_0000:    rd0_data <= { 4'h0, iSUM_SY[27:24] };
            default:                    rd0_data <= 'h00;
        endcase
    end

    always @(*) begin
        case (iRE_BIT[23:16])
            8'b0000_0001:   rd1_data <= iQUOTIENT_SX[ 7: 0];
            8'b0000_0010:   rd1_data <= iQUOTIENT_SX[15: 8];
            8'b0000_0100:   rd1_data <= iQUOTIENT_SX[23:16];
            8'b0000_1000:   rd1_data <= { 4'h0, iQUOTIENT_SX[27:24] };
            8'b0001_0000:   rd1_data <= iQUOTIENT_SY[ 7: 0];
            8'b0010_0000:   rd1_data <= iQUOTIENT_SY[15: 8];
            8'b0100_0000:   rd1_data <= iQUOTIENT_SY[23:16];
            8'b1000_0000:   rd1_data <= { 4'h0, iQUOTIENT_SY[27:24] };
            default:        rd1_data <= 'h00;
        endcase
    end

endmodule
