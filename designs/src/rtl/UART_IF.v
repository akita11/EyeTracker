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
    input   wire    [SUM_S_WIDTH -1: 0]         iSUM_S,
    input   wire    [SUM_SX_WIDTH -1: 0]        iSUM_SX,
    input   wire    [SUM_SY_WIDTH -1: 0]        iSUM_SY,
    //
    input   wire                                iTRIG,
    //
    input   wire                                iUART_TX_BUSY,
    //
    output  wire                                oBUSY,
    //
    output  wire                                oDE,
    output  wire    [DATA_WIDTH -1 : 0]         oDATA
);

    // 
    localparam      IDLE_STATE                  = 4'b0000,
                    PRE_S                       = 4'b0001,
                    OUT_S                       = 4'b0010,
                    WAIT_S                      = 4'b0011,
                    PRE_SX                      = 4'b0100,
                    OUT_SX                      = 4'b0101,
                    WAIT_SX                     = 4'b0110,
                    PRE_SY                      = 4'b0111,
                    OUT_SY                      = 4'b1000,
                    WAIT_SY                     = 4'b1001,
                    PRE_LF                      = 4'b1010,
                    OUT_LF                      = 4'b1011,
                    WAIT_LF                     = 4'b1100;

    //
    localparam      STATE_WIDTH                 = 4;
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
    DET_EDGE m_DET_TRIG_EDGE( .CLK(CLK), .RST_N(RST_N), .iS(iTRIG), .oRISE(start_trig), .oFALL() );
    DET_EDGE m_DET_BUSY_EDGE( .CLK(CLK), .RST_N(RST_N), .iS(iUART_TX_BUSY), .oRISE(rise_busy), .oFALL(fall_busy) );

    //
    CONV_ASCII #( .DATA_WIDTH(20) ) m_CONV_ASCII_S  ( .CLK(CLK), .RST_N(RST_N), .iDATA(iSUM_S ), .oASCII(ascii_s ) );
    CONV_ASCII #( .DATA_WIDTH(28) ) m_CONV_ASCII_SX ( .CLK(CLK), .RST_N(RST_N), .iDATA(iSUM_SX), .oASCII(ascii_sx) );
    CONV_ASCII #( .DATA_WIDTH(28) ) m_CONV_ASCII_SY ( .CLK(CLK), .RST_N(RST_N), .iDATA(iSUM_SY), .oASCII(ascii_sy) );

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

                                    next_state      <= PRE_SX;
                                    //
                                    next_wait_count <= 'h0;
                                    //
                                    next_com_out_en <= 1'b0;
                                    next_out_data   <= out_data;
                                    //
                                    next_hold_data  <= ascii_sx;
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
