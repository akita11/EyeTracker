// -----------------------------------------------------------------------------
//  Title         : Mathmatics Divider Control
//  Project       : Common
// -----------------------------------------------------------------------------
//  File          : MATH_DIV_CTRL.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 6/11
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Mathmatics
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module MATH_DIV_CTRL #(
) (
    input   wire                                CLK,
    input   wire                                RST_N,
    //
    input   wire                                iDIVIDEND_TREADY,
    input   wire                                iDIVISOR_TREADY,
    input   wire                                iDOUT_TVALID,
    //
    output  wire                                oDIVIDEND_TVALID,
    output  wire                                oDIVISOR_TVALID
);

    // 
    localparam      IDLE_STATE                  = 4'b0000,
                    SET_DIVIDEND                = 4'b0001,
                    SET_DIVISOR                 = 4'b0010,
                    CALC_DIV_OUT                = 4'b0011;

    //
    localparam      STATE_WIDTH                 = 4;

    //
    wire                                        start_trig;

    wire                                        load_en;

    //
    reg     [STATE_WIDTH -1: 0]                 next_state, state;
    reg                                         next_dividend_tvalid, dividend_tvalid;
    reg                                         next_divisor_tvalid, divisor_tvalid;
//  reg                                         next_divid_load_en, divid_load_en;

    //
    assign  oDIVIDEND_TVALID = dividend_tvalid;
    assign  oDIVISOR_TVALID  = divisor_tvalid;

    // 
    DET_EDGE m_DET_START_TRIG( .CLK(CLK), .RST_N(RST_N), .iS(iDE), .oRISE(start_trig), .oFALL() );

    //
//    DFF_REG #( .DATA_WIDTH(8), .INIT_VAL(8'h00) ) m_DIVIDED_SX_L( .CLK(CLK), .RST_N(RST_N), .iWE(load_en), .iD(iDATA), .oD(DIVIDED_SX[ 7: 0]) );
//    DFF_REG #( .DATA_WIDTH(8), .INIT_VAL(8'h00) ) m_DIVIDED_SX_H( .CLK(CLK), .RST_N(RST_N), .iWE(load_en), .iD(iDATA), .oD(oDIVIDED_SX[15: 8]) );

    //
//    DFF_REG #( .DATA_WIDTH(8), .INIT_VAL(8'h00) ) m_DIVIDED_SY_L( .CLK(CLK), .RST_N(RST_N), .iWE(load_en), .iD(iDATA), .oD(oDIVIDED_SY[ 7: 0]) );
//    DFF_REG #( .DATA_WIDTH(8), .INIT_VAL(8'h00) ) m_DIVIDED_SY_H( .CLK(CLK), .RST_N(RST_N), .iWE(load_en), .iD(iDATA), .oD(oDIVIDED_SY[15: 8]) );

    //
    assign  load_en = iDIVIDEND_TREADY & iDIVISOR_TREADY & iDOUT_TVALID;

    //
    always @(*) begin
        case (state)
            IDLE_STATE: begin
                            if (start_trig) begin
                                next_state           <= SET_DIVIDEND;
                                //
                                next_dividend_tvalid <= 1'b1;
                                //
                                next_divisor_tvalid  <= 1'b0;
                                //
                            end else begin
                                next_state           <= state;
                                //
                                next_dividend_tvalid <= dividend_tvalid;
                                //
                                next_divisor_tvalid  <= divisor_tvalid;
                            end
                        end
            SET_DIVIDEND:begin
                            if (iDIVIDEND_TREADY) begin
                                next_state           <= SET_DIVISOR;
                                //
                                next_dividend_tvalid <= 1'b0;
                                //
                                next_divisor_tvalid  <= 1'b1;
                            end else begin
                                next_state           <= state;
                                //
                                next_dividend_tvalid <= dividend_tvalid;
                                //
                                next_divisor_tvalid  <= divisor_tvalid;
                            end
                        end
            SET_DIVISOR:begin
                            if (load_en) begin
                                next_state           <= SET_DIVISOR;
                                //
                                next_dividend_tvalid <= 1'b0;
                                //
                                next_divisor_tvalid  <= 1'b1;
                            end else begin
                                next_state           <= state;
                                //
                                next_dividend_tvalid <= dividend_tvalid;
                                //
                                next_divisor_tvalid  <= divisor_tvalid;
                            end
                        end
            CALC_DIV_OUT:begin
                            next_state           <= IDLE_STATE;
                            //
                            next_dividend_tvalid <= 1'b0;
                            //
                            next_divisor_tvalid  <= 1'b0;
                        end
            default:    begin
                            next_state           <= IDLE_STATE;
                            //
                            next_dividend_tvalid <= 1'b0;
                            //
                            next_divisor_tvalid  <= 1'b0;
                        end
        endcase
    end

    //
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            state           <= IDLE_STATE;
            //
            dividend_tvalid <= 1'b0;
            //
            divisor_tvalid  <= 1'b0;
        end else begin
            state           <= next_state;
            //
            dividend_tvalid <= next_dividend_tvalid;
            //
            divisor_tvalid  <= next_divisor_tvalid;
        end
    end

endmodule
