// -----------------------------------------------------------------------------
//  Title         : UART IF
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : UART_IF.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 4/15
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : UART IF
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module UART_IF #(
) (
    input   wire                                CLK,
    input   wire                                RST_N,
    //
    input   wire                                iOUT_SEL,
    //
    input   wire    [SUM_S_WIDTH  -1: 0]        iSUM_S,
    input   wire    [SUM_SX_WIDTH -1: 0]        iSUM_SX,
    input   wire    [SUM_SY_WIDTH -1: 0]        iSUM_SY,
    input   wire    [SUM_S_WIDTH  -1: 0]        iFRACTIONAL_SX,
    input   wire    [SUM_S_WIDTH  -1: 0]        iFRACTIONAL_SY,
    input   wire    [SUM_SX_WIDTH -1: 0]        iQUOTIENT_SX,
    input   wire    [SUM_SY_WIDTH -1: 0]        iQUOTIENT_SY,
    //
    input   wire                                iTRIG,
    //
    input   wire                                iUART_TX_BUSY,
    //
    output  wire                                oBUSY,
    //
    output  wire                                oDE,
    output  wire    [DATA_WIDTH -1 : 0]         oDATA,
    //
    output  wire                                oRSLT_S_FF,
    output  wire                                oRSLT_SX_FF,
    output  wire                                oRSLT_SY_FF,
    output  wire                                oRSLT_QSX_FF,
    output  wire                                oRSLT_QSY_FF
);

    // 
    localparam      IDLE_STATE                  = 5'b0_0000,
                    PRE_S                       = 5'b0_0001,
                    OUT_S                       = 5'b0_0010,
                    WAIT_S                      = 5'b0_0011,
                    PRE_SX                      = 5'b0_0100,
                    OUT_SX                      = 5'b0_0101,
                    WAIT_SX                     = 5'b0_0110,
                    PRE_SY                      = 5'b0_0111,
                    OUT_SY                      = 5'b0_1000,
                    WAIT_SY                     = 5'b0_1001,
                    PRE_QSX                     = 5'b0_1010,
                    OUT_QSX                     = 5'b0_1011,
                    WAIT_QSX                    = 5'b0_1100,
                    PRE_QSY                     = 5'b0_1101,
                    OUT_QSY                     = 5'b0_1110,
                    WAIT_QSY                    = 5'b0_1111,
                    PRE_LF                      = 5'b1_0000,
                    OUT_LF                      = 5'b1_0001,
                    WAIT_LF                     = 5'b1_0010;

    //
    localparam      STATE_WIDTH                 = 5;
    localparam      COUNTER_WIDTH               = 4;
    localparam      DATA_WIDTH                  = 8;

    localparam      SUM_S_WIDTH                 = 20;
    localparam      SUM_SX_WIDTH                = 28;
    localparam      SUM_SY_WIDTH                = 28;

    localparam      HOLD_DATA_WIDTH             = 28 * 2;

    //
    wire                                        start_trig;

    wire                                        rise_busy;
    wire                                        fall_busy;

    wire    [SUM_S_WIDTH * 2 -1: 0]             ascii_s;
    wire    [SUM_SX_WIDTH * 2 -1: 0]            ascii_sx;
    wire    [SUM_SY_WIDTH * 2 -1: 0]            ascii_sy;
    wire    [SUM_SX_WIDTH * 2 -1: 0]            ascii_qsx;
    wire    [SUM_SY_WIDTH * 2 -1: 0]            ascii_qsy;

    //
    reg     [STATE_WIDTH -1: 0]                 next_state, state;
    reg     [COUNTER_WIDTH -1: 0]               next_wait_count, wait_count;
    reg                                         next_com_out_en, com_out_en;
    reg     [DATA_WIDTH -1 : 0]                 next_out_data, out_data;
    reg     [HOLD_DATA_WIDTH -1: 0]             next_hold_data, hold_data;
    reg                                         next_busy, busy;

    //
    assign  oBUSY = busy;

    //
    assign  oDE = com_out_en;
    assign  oDATA = out_data;

    //
    CYCLE_DELAY #( .DATA_WIDTH(1), .DELAY(1) )  m_TRIG_DLY( .CLK(CLK), .RST_N(RST_N), .iD(iTRIG), .oD(trig_dly) );

    //
    DET_EDGE m_DET_TRIG_EDGE( .CLK(CLK), .RST_N(RST_N), .iS(trig_dly), .oRISE(start_trig), .oFALL() );
    DET_EDGE m_DET_BUSY_EDGE( .CLK(CLK), .RST_N(RST_N), .iS(iUART_TX_BUSY), .oRISE(rise_busy), .oFALL(fall_busy) );

    //
    CONV_ASCII #( .DATA_WIDTH(20) ) m_CONV_ASCII_S   ( .CLK(CLK), .RST_N(RST_N), .iDATA(iSUM_S      ), .oASCII(ascii_s  ) );
    CONV_ASCII #( .DATA_WIDTH(28) ) m_CONV_ASCII_SX  ( .CLK(CLK), .RST_N(RST_N), .iDATA(iSUM_SX     ), .oASCII(ascii_sx ) );
    CONV_ASCII #( .DATA_WIDTH(28) ) m_CONV_ASCII_SY  ( .CLK(CLK), .RST_N(RST_N), .iDATA(iSUM_SY     ), .oASCII(ascii_sy ) );
    CONV_ASCII #( .DATA_WIDTH(28) ) m_CONV_ASCII_QSX ( .CLK(CLK), .RST_N(RST_N), .iDATA({iQUOTIENT_SX[11: 0], iFRACTIONAL_SX[19: 4]}), .oASCII(ascii_qsx) );
    CONV_ASCII #( .DATA_WIDTH(28) ) m_CONV_ASCII_QSY ( .CLK(CLK), .RST_N(RST_N), .iDATA({iQUOTIENT_SY[11: 0], iFRACTIONAL_SY[19: 4]}), .oASCII(ascii_qsy) );

    //
    IS_XDIGIT #( .DATA_WIDTH(SUM_S_WIDTH  * 2) ) m_IS_XDIGIT_S  ( .CLK(CLK), .RST_N(RST_N), .iCHAR(ascii_s  ), .oRESULT(rslt_s  ), .oRESULT_FF(oRSLT_S_FF  ) );
    IS_XDIGIT #( .DATA_WIDTH(SUM_SX_WIDTH * 2) ) m_IS_XDIGIT_SX ( .CLK(CLK), .RST_N(RST_N), .iCHAR(ascii_sx ), .oRESULT(rslt_sx ), .oRESULT_FF(oRSLT_SX_FF ) );
    IS_XDIGIT #( .DATA_WIDTH(SUM_SY_WIDTH * 2) ) m_IS_XDIGIT_SY ( .CLK(CLK), .RST_N(RST_N), .iCHAR(ascii_sy ), .oRESULT(rslt_sy ), .oRESULT_FF(oRSLT_SY_FF ) );
    IS_XDIGIT #( .DATA_WIDTH(SUM_SX_WIDTH * 2) ) m_IS_XDIGIT_QSX( .CLK(CLK), .RST_N(RST_N), .iCHAR(ascii_qsx), .oRESULT(rslt_qsx), .oRESULT_FF(oRSLT_QSX_FF) );
    IS_XDIGIT #( .DATA_WIDTH(SUM_SY_WIDTH * 2) ) m_IS_XDIGIT_QSY( .CLK(CLK), .RST_N(RST_N), .iCHAR(ascii_qsy), .oRESULT(rslt_qsy), .oRESULT_FF(oRSLT_QSY_FF) );

    //
    always @(*) begin
        case (state)
            IDLE_STATE: begin
                            if (start_trig) begin
                                next_state      <= PRE_S;
                                //
                                next_wait_count <= 'h0;
                                //
                                next_com_out_en <= 1'b0;
                                next_out_data   <= 'hFF;
                                //
                                next_hold_data  <= { ascii_s, 16'h0 };
                                //
                                next_busy       <= 1'b1;
                            end else begin
                                next_state      <= state;
                                // 
                                next_wait_count <= wait_count;
                                //
                                next_com_out_en <= 1'b0;
                                next_out_data   <= out_data;
                                //
                                next_hold_data  <= 'h0;
                                //
                                next_busy       <= 1'b0;
                            end
                        end
            PRE_S:  begin
                            next_state      <= OUT_S;
                            //
                            next_wait_count <= 'h5 - 'h1;
                            //
                            next_com_out_en <= 1'b1;
                            next_out_data   <= hold_data[HOLD_DATA_WIDTH - 1: HOLD_DATA_WIDTH -1 - 7];
                            //
                            next_hold_data  <= { hold_data[HOLD_DATA_WIDTH - 1 - 8: 0], 8'h0 };
                            //
                            next_busy       <= 1'b1;
                        end
            OUT_S:      begin
                            //
                            next_wait_count <= wait_count;
                            //
                            next_out_data   <= out_data;
                            //
                            next_hold_data  <= hold_data;
                            //
                            next_busy       <= 1'b1;
                            //
                            if (rise_busy) begin
                                next_state      <= WAIT_S;
                                //
                                next_com_out_en <= 1'b0;
                            end else begin
                                next_state      <= state;
                                //
                                next_com_out_en <= 1'b1;
                            end
                        end
            WAIT_S:     begin
                            next_busy       <= 1'b1;
                            //
                            if (iUART_TX_BUSY) begin
                                next_state      <= state;
                                //
                                next_wait_count <= wait_count;
                                //
                                next_com_out_en <= 1'b0;
                                next_out_data   <= out_data;
                                //
                                next_hold_data  <= hold_data;
                            end else begin
                                if (wait_count == 'h0) begin
                                    next_state      <= (iOUT_SEL==1'b1) ? PRE_QSX: PRE_SX;
                                    //
                                    next_wait_count <= 'h0;
                                    //
                                    next_com_out_en <= 1'b0;
                                    next_out_data   <= out_data;
                                    //
                                    next_hold_data  <= (iOUT_SEL==1'b1) ? ascii_qsx: ascii_sx;
                                end else begin
                                    next_state      <= OUT_S;
                                    //
                                    next_wait_count <= wait_count - 'h1;
                                    //
                                    next_com_out_en <= 1'b1;
                                    next_out_data   <= hold_data[HOLD_DATA_WIDTH - 1: HOLD_DATA_WIDTH - 1 - 7];
                                    //
                                    next_hold_data  <= { hold_data[HOLD_DATA_WIDTH - 1 - 8: 0], 8'h0 };
                                end
                            end
                        end
            PRE_SX:     begin
                            next_state      <= OUT_SX;
                            //
                            next_wait_count <= 'h7 - 'h1;
                            //
                            next_com_out_en <= 1'b1;
                            next_out_data   <= hold_data[HOLD_DATA_WIDTH - 1: HOLD_DATA_WIDTH -1 - 7];
                            //
                            next_hold_data  <= { hold_data[HOLD_DATA_WIDTH - 1 - 8: 0], 8'h0 };
                            //
                            next_busy       <= 1'b1;
                        end
            OUT_SX:     begin
                            //
                            next_wait_count <= wait_count;
                            //
                            next_out_data   <= out_data;
                            //
                            next_hold_data  <= hold_data;
                            //
                            next_busy       <= 1'b1;
                            //
                            if (rise_busy) begin
                                next_state      <= WAIT_SX;
                                //
                                next_com_out_en <= 1'b0;
                            end else begin
                                next_state      <= state;
                                //
                                next_com_out_en <= 1'b1;
                            end
                        end
            WAIT_SX:    begin
                            next_busy       <= 1'b1;
                            //
                            if (iUART_TX_BUSY) begin
                                next_state      <= state;
                                //
                                next_wait_count <= wait_count;
                                //
                                next_com_out_en <= 1'b0;
                                next_out_data   <= out_data;
                                //
                                next_hold_data  <= hold_data;
                            end else begin
                                if (wait_count == 'h0) begin
                                    next_state      <= PRE_SY;
                                    //
                                    next_wait_count <= 'h0;
                                    //
                                    next_com_out_en <= 1'b0;
                                    next_out_data   <= out_data;
                                    //
                                    next_hold_data  <= ascii_sy;
                                end else begin
                                    next_state      <= OUT_SX;
                                    //
                                    next_wait_count <= wait_count - 'h1;
                                    //
                                    next_com_out_en <= 1'b1;
                                    next_out_data   <= hold_data[HOLD_DATA_WIDTH - 1: HOLD_DATA_WIDTH - 1 - 7];
                                    //
                                    next_hold_data  <= { hold_data[HOLD_DATA_WIDTH - 1 - 8: 0], 8'h0 };
                                end
                            end
                        end
            PRE_SY:     begin
                            next_state      <= OUT_SY;
                            //
                            next_wait_count <= 'h7 - 'h1;
                            //
                            next_com_out_en <= 1'b1;
                            next_out_data   <= hold_data[HOLD_DATA_WIDTH - 1: HOLD_DATA_WIDTH -1 - 7];
                            //
                            next_hold_data  <= { hold_data[HOLD_DATA_WIDTH - 1 - 8: 0], 8'h0 };
                            //
                            next_busy       <= 1'b1;
                        end
            OUT_SY:     begin
                            //
                            next_wait_count <= wait_count;
                            //
                            next_out_data   <= out_data;
                            //
                            next_hold_data  <= hold_data;
                            //
                            next_busy       <= 1'b1;
                            //
                            if (rise_busy) begin
                                next_state      <= WAIT_SY;
                                //
                                next_com_out_en <= 1'b0;
                            end else begin
                                next_state      <= state;
                                //
                                next_com_out_en <= 1'b1;
                            end
                        end
            WAIT_SY:    begin
                            if (iUART_TX_BUSY) begin
                                next_state      <= state;
                                //
                                next_wait_count <= wait_count;
                                //
                                next_com_out_en <= 1'b0;
                                next_out_data   <= out_data;
                                //
                                next_hold_data  <= hold_data;
                                //
                                next_busy       <= 1'b1;
                            end else begin
                                if (wait_count == 'h0) begin
                                    next_state      <= PRE_LF;
                                    //
                                    next_wait_count <= 'h0;
                                    //
                                    next_com_out_en <= 1'b0;
                                    next_out_data   <= 'hFF;
                                    //
//                                    next_hold_data  <= 8'h0A;
                                    next_hold_data  <= {8'h0A, 48'h0 };
                                     //
                                    next_busy       <= 1'b1;
                                end else begin
                                    next_state      <= OUT_SY;
                                    //
                                    next_wait_count <= wait_count - 'h1;
                                    //
                                    next_com_out_en <= 1'b1;
                                    next_out_data   <= hold_data[HOLD_DATA_WIDTH - 1: HOLD_DATA_WIDTH - 1 - 7];
                                    //
                                    next_hold_data  <= { hold_data[HOLD_DATA_WIDTH - 1 - 8: 0], 8'h0 };
                                    //
                                    next_busy       <= 1'b1;
                                end
                            end
                        end
            PRE_QSX:    begin
                            next_state      <= OUT_QSX;
                            //
                            next_wait_count <= 'h7 - 'h1;
                            //
                            next_com_out_en <= 1'b1;
                            next_out_data   <= hold_data[HOLD_DATA_WIDTH - 1: HOLD_DATA_WIDTH -1 - 7];
                            //
                            next_hold_data  <= { hold_data[HOLD_DATA_WIDTH - 1 - 8: 0], 8'h0 };
                            //
                            next_busy       <= 1'b1;
                        end
            OUT_QSX:    begin
                            //
                            next_wait_count <= wait_count;
                            //
                            next_out_data   <= out_data;
                            //
                            next_hold_data  <= hold_data;
                            //
                            next_busy       <= 1'b1;
                            //
                            if (rise_busy) begin
                                next_state      <= WAIT_QSX;
                                //
                                next_com_out_en <= 1'b0;
                            end else begin
                                next_state      <= state;
                                //
                                next_com_out_en <= 1'b1;
                            end
                        end
            WAIT_QSX:   begin
                            next_busy       <= 1'b1;
                            //
                            if (iUART_TX_BUSY) begin
                                next_state      <= state;
                                //
                                next_wait_count <= wait_count;
                                //
                                next_com_out_en <= 1'b0;
                                next_out_data   <= out_data;
                                //
                                next_hold_data  <= hold_data;
                            end else begin
                                if (wait_count == 'h0) begin
                                    next_state      <= PRE_QSY;
                                    //
                                    next_wait_count <= 'h0;
                                    //
                                    next_com_out_en <= 1'b0;
                                    next_out_data   <= out_data;
                                    //
                                    next_hold_data  <= ascii_qsy;
                                end else begin
                                    next_state      <= OUT_QSX;
                                    //
                                    next_wait_count <= wait_count - 'h1;
                                    //
                                    next_com_out_en <= 1'b1;
                                    next_out_data   <= hold_data[HOLD_DATA_WIDTH - 1: HOLD_DATA_WIDTH - 1 - 7];
                                    //
                                    next_hold_data  <= { hold_data[HOLD_DATA_WIDTH - 1 - 8: 0], 8'h0 };
                                end
                            end
                        end
            PRE_QSY:    begin
                            next_state      <= OUT_QSY;
                            //
                            next_wait_count <= 'h7 - 'h1;
                            //
                            next_com_out_en <= 1'b1;
                            next_out_data   <= hold_data[HOLD_DATA_WIDTH - 1: HOLD_DATA_WIDTH -1 - 7];
                            //
                            next_hold_data  <= { hold_data[HOLD_DATA_WIDTH - 1 - 8: 0], 8'h0 };
                            //
                            next_busy       <= 1'b1;
                        end
            OUT_QSY:    begin
                            //
                            next_wait_count <= wait_count;
                            //
                            next_out_data   <= out_data;
                            //
                            next_hold_data  <= hold_data;
                            //
                            next_busy       <= 1'b1;
                            //
                            if (rise_busy) begin
                                next_state      <= WAIT_QSY;
                                //
                                next_com_out_en <= 1'b0;
                            end else begin
                                next_state      <= state;
                                //
                                next_com_out_en <= 1'b1;
                            end
                        end
            WAIT_QSY:   begin
                            if (iUART_TX_BUSY) begin
                                next_state      <= state;
                                //
                                next_wait_count <= wait_count;
                                //
                                next_com_out_en <= 1'b0;
                                next_out_data   <= out_data;
                                //
                                next_hold_data  <= hold_data;
                                //
                                next_busy       <= 1'b1;
                            end else begin
                                if (wait_count == 'h0) begin
                                    next_state      <= PRE_LF;
                                    //
                                    next_wait_count <= 'h0;
                                    //
                                    next_com_out_en <= 1'b0;
                                    next_out_data   <= 'hFF;
                                    //
//                                    next_hold_data  <= 8'h0A;
                                    next_hold_data  <= {8'h0A, 48'h0 };
                                     //
                                    next_busy       <= 1'b1;
                                end else begin
                                    next_state      <= OUT_QSY;
                                    //
                                    next_wait_count <= wait_count - 'h1;
                                    //
                                    next_com_out_en <= 1'b1;
                                    next_out_data   <= hold_data[HOLD_DATA_WIDTH - 1: HOLD_DATA_WIDTH - 1 - 7];
                                    //
                                    next_hold_data  <= { hold_data[HOLD_DATA_WIDTH - 1 - 8: 0], 8'h0 };
                                    //
                                    next_busy       <= 1'b1;
                                end
                            end
                        end
            PRE_LF:     begin
                            next_state      <= OUT_LF;
                            //
                            next_wait_count <= 'h1 - 'h1;
                            //
                            next_com_out_en <= 1'b1;
                            next_out_data   <= hold_data[HOLD_DATA_WIDTH - 1: HOLD_DATA_WIDTH -1 - 7];
                            //
                            next_hold_data  <= { hold_data[HOLD_DATA_WIDTH - 1 - 8: 0], 8'h0 };
                            //
                            next_busy       <= 1'b1;
                        end
            OUT_LF:     begin
                            //
                            next_wait_count <= wait_count;
                            //
                            next_out_data   <= out_data;
                            //
                            next_hold_data  <= hold_data;
                            //
                            next_busy       <= 1'b1;
                            //
                            if (rise_busy) begin
                                next_state      <= WAIT_LF;
                                //
                                next_com_out_en <= 1'b0;
                            end else begin
                                next_state      <= state;
                                //
                                next_com_out_en <= 1'b1;
                            end
                        end
            WAIT_LF:    begin
                            if (iUART_TX_BUSY) begin
                                next_state      <= state;
                                //
                                next_wait_count <= wait_count;
                                //
                                next_com_out_en <= 1'b0;
                                next_out_data   <= out_data;
                                //
                                next_hold_data  <= hold_data;
                                //
                                next_busy       <= 1'b1;
                            end else begin
                                if (wait_count == 'h0) begin
                                    next_state      <= IDLE_STATE;
                                    //
                                    next_wait_count <= 'h0;
                                    //
                                    next_com_out_en <= 1'b0;
                                    next_out_data   <= 'hFF;
                                    //
                                    next_hold_data  <= 'h0;
                                    //
                                    next_busy       <= 1'b1;
                                end else begin
                                    next_state      <= OUT_SY;
                                    //
                                    next_wait_count <= wait_count - 'h1;
                                    //
                                    next_com_out_en <= 1'b1;
                                    next_out_data   <= hold_data[HOLD_DATA_WIDTH - 1: HOLD_DATA_WIDTH - 1 - 7];
                                    //
                                    next_hold_data  <= { hold_data[HOLD_DATA_WIDTH - 1 - 8: 0], 8'h0 };
                                    //
                                    next_busy       <= 1'b1;
                                end
                            end
                        end
            default:    begin
                            next_state      <= IDLE_STATE;
                            // 
                            next_wait_count <= 'h0;
                            //
                            next_com_out_en <= 1'b0;
                            next_out_data   <= 'hFF;
                            //
                            next_hold_data  <= 'h0;
                            //
                            next_busy       <= 1'b0;
                        end
        endcase
    end

    // 
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            state      <= IDLE_STATE;
            //
            wait_count <= 'h0;
            //
            com_out_en <= 1'b0;
            out_data   <= 'hFF;
            //
            hold_data  <= 'h0;
            //
            busy       <= 1'b0;
        end else begin
            state      <= next_state;
            //
            wait_count <= next_wait_count;
            //
            com_out_en <= next_com_out_en;
            out_data   <= next_out_data;
            //
            hold_data  <= next_hold_data;
            //
            busy       <= next_busy;
        end
    end

endmodule
