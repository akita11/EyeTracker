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
    output  wire                                oUART_SW,
    output  wire                                oVGA_OUT_MODE,
    output  wire    [DATA_WIDTH -1: 0]          oTHRESHOLD
);

    //
    localparam      DATA_WIDTH                  = 8;
    localparam      WE_WIDTH                    = 4;
    localparam      RE_WIDTH                    = 4;

    //
    reg     [DATA_WIDTH -1: 0]                  rd_data;

    //
    assign  oRD    = rd_data;

    //
    DFF_REG #( .DATA_WIDTH(1), .INIT_VAL(1'b0 ) ) m_UART_SW      ( .CLK(CLK), .RST_N(RST_N), .iWE(iWE_BIT[0]), .iD(iDATA), .oD(oUART_SW     ) );
    DFF_REG #( .DATA_WIDTH(1), .INIT_VAL(1'b1 ) ) m_VGA_OUT_MODE ( .CLK(CLK), .RST_N(RST_N), .iWE(iWE_BIT[1]), .iD(iDATA), .oD(oVGA_OUT_MODE) );
    DFF_REG #( .DATA_WIDTH(8), .INIT_VAL(8'h01) ) m_THRESHOLD    ( .CLK(CLK), .RST_N(RST_N), .iWE(iWE_BIT[2]), .iD(iDATA), .oD(oTHRESHOLD   ) );

    //
    always @(*) begin
        case (iRE_BIT)
            4'b0001:    rd_data <= { 7'b0000_000, oUART_SW };
            4'b0010:    rd_data <= { 7'b0000_000, oVGA_OUT_MODE };
            4'b0100:    rd_data <= oTHRESHOLD;
            4'b1000:    rd_data <= 8'h00;
            default:    rd_data <= 'h00;
        endcase
    end

endmodule
