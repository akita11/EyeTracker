// -----------------------------------------------------------------------------
//  Title         : CORE LOGIC (HOST IF)
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : HOST_IF_CORE.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 6/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : HOST IF
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module HOST_IF_CORE #(
    parameter       ADDR_WIDTH      = 16,
    parameter       FIFO_DATA_WIDTH = 16*8
) (
    input   wire                                CLK,
    input   wire                                RST_N,
    // for Internal Bus
    output  wire    [ADDR_WIDTH -1 : 0]         oOUT_ADDR,
    output  wire                                oOUT_WE,
    output  wire                                oOUT_RE,
    output  wire    [DATA_WIDTH -1 : 0]         oOUT_DATA,
    input   wire    [DATA_WIDTH -1 : 0]         iRD,
    // from from UART_RECEIVER_FIFO
    input   wire                                iDE,
    input   wire    [FIFO_DATA_WIDTH -1 : 0]    iDATA,
    output  wire                                oBUFFER_CLR,
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
                    RD_ACCESS                   = 4'b0001,
                    WR_ACCESS                   = 4'b0010,
                    OUT_MSG                     = 4'b0011,
                    WAIT_BUSY                   = 4'b0100,
                    WAIT_READY                  = 4'b0101;

    //
    localparam      STATE_WIDTH                 = 4;
    localparam      COUNTER_WIDTH               = 4;
    localparam      DATA_WIDTH                  = 8;

    localparam      HOLD_DATA_WIDTH             = 9 * 8;

    //
    wire                                        start_trig;

    wire                                        rise_busy;
    wire                                        fall_busy;

    //
    reg     [STATE_WIDTH -1: 0]                 next_state, state;
    reg                                         next_buf_clr, buf_clr;
    reg     [COUNTER_WIDTH -1: 0]               next_wait_count, wait_count;
    reg     [ADDR_WIDTH -1: 0]                  next_out_addr, out_addr;
    reg                                         next_out_we, out_we;
    reg                                         next_out_re, out_re;
    reg     [DATA_WIDTH -1 : 0]                 next_out_data, out_data;
    reg                                         next_uart_de, uart_de;
    reg     [DATA_WIDTH -1 : 0]                 next_uart_data, uart_data;
    reg     [HOLD_DATA_WIDTH -1: 0]             next_hold_data, hold_data;

    //
    wire    [DATA_WIDTH * 1 -1 : 0]             inp_cmd_1w;
    wire    [DATA_WIDTH * 2 -1 : 0]             inp_cmd_2w;
    wire    [DATA_WIDTH * 3 -1 : 0]             inp_cmd_3w;
    wire    [DATA_WIDTH * 4 -1 : 0]             inp_cmd_4w;
    wire    [DATA_WIDTH * 5 -1 : 0]             inp_cmd_5w;

    wire    [DATA_WIDTH * 4 -1 : 0]             inp_addr_str;
    wire    [DATA_WIDTH * 1 -1 : 0]             inp_sepa_str;
    wire    [DATA_WIDTH * 2 -1 : 0]             inp_data_str;

    wire    [HOLD_DATA_WIDTH -1: 0]             ok_msg_str;
    wire    [HOLD_DATA_WIDTH -1: 0]             ng_msg_str;
    wire    [HOLD_DATA_WIDTH -1: 0]             rd_msg_str;
    wire    [HOLD_DATA_WIDTH -1: 0]             null_str;

    wire    [DATA_WIDTH * 2 -1 : 0]             rd_ascii;

    wire    [ADDR_WIDTH -1: 0]                  inp_addr;
    wire    [DATA_WIDTH -1 : 0]                 inp_data;

    //
    assign  oOUT_ADDR = out_addr;
    assign  oOUT_WE   = out_we;
    assign  oOUT_RE   = out_re;
    assign  oOUT_DATA = out_data;

    //
//    assign  oBUSY = busy;

    //
    assign  oBUFFER_CLR = buf_clr;

    //
    assign  oDE   = uart_de;
    assign  oDATA = uart_data;

    //
    DET_EDGE m_DET_TRIG_EDGE( .CLK(CLK), .RST_N(RST_N), .iS(iDE), .oRISE(start_trig), .oFALL() );
    DET_EDGE m_DET_BUSY_EDGE( .CLK(CLK), .RST_N(RST_N), .iS(iUART_TX_BUSY), .oRISE(rise_busy), .oFALL(fall_busy) );

    //

    // - Write Command
    //     Input  : "wr 4桁のアドレス 2桁のデータ"+"crlf"
    //     Output : "OK"+"crlf" or "NG"+"crlf"
    // 
    // - Read Command
    //     Input  : "rd 4桁のアドレス"+"lf"
    //     Output : "OK"+"crlf"+"2桁のデータ"+"crlf"
    // 
    // - Stop "Output value" command
    //     Input  : "stop"+"crlf"
    //     Output : "OK"+"crlf"
    // 
    // - Start "Output value" command
    //     Input  : "start"+"crlf"
    //     Output : "OK"+"crlf"
    //

    //
    assign  inp_cmd_1w = { iDATA[ 7: 0] };
    assign  inp_cmd_2w = {   inp_cmd_1w, iDATA[15: 8] };
    assign  inp_cmd_3w = {   inp_cmd_2w, iDATA[23:16] };
    assign  inp_cmd_4w = {   inp_cmd_3w, iDATA[31:24] };
    assign  inp_cmd_5w = {   inp_cmd_4w, iDATA[39:32] };

    assign  inp_addr_str = { iDATA[31:24], iDATA[39:32], iDATA[47:40], iDATA[55:48] };
    assign  inp_sepa_str = { iDATA[63:56] };
    assign  inp_data_str = { iDATA[71:64], iDATA[79:72] };

    //
//    assign  ok_msg_str = { 8'h00, 8'h00, 8'h00, 8'h00,                     8'h00, 8'h0A, 8'h0D, "K", "O" };
//    assign  ng_msg_str = { 8'h00, 8'h00, 8'h00, 8'h00,                     8'h00, 8'h0A, 8'h0D, "G", "N" };
//    assign  rd_msg_str = { 8'h00, 8'h0A, 8'h0D, rd_ascii[ 7: 0], rd_ascii[15: 8], 8'h0A, 8'h0D, "K", "O" };
    assign  ok_msg_str = { 8'h00, 8'h00, 8'h00, 8'h00,           8'h00,           8'h00, 8'h0A,   "K",   "O" };
    assign  ng_msg_str = { 8'h00, 8'h00, 8'h00, 8'h00,           8'h00,           8'h00, 8'h0A,   "G",   "N" };
    assign  rd_msg_str = { 8'h00, 8'h00, 8'h00, 8'h0A, rd_ascii[ 7: 0], rd_ascii[15: 8], 8'h0A,   "K",   "O" };
    assign  null_str   = { 8'h00, 8'h00, 8'h00, 8'h00,           8'h00,           8'h00, 8'h00, 8'h00, 8'h00 };

    //
    CONV_HEX #( .CHAR_NUM(4) ) m_CONV_HEX_ADDR ( .CLK(CLK), .RST_N(RST_N), .iASCII(inp_addr_str), .oDATA(inp_addr) );
    CONV_HEX #( .CHAR_NUM(2) ) m_CONV_HEX_DATA ( .CLK(CLK), .RST_N(RST_N), .iASCII(inp_data_str), .oDATA(inp_data) );

    //
    CONV_ASCII #( .DATA_WIDTH(8) ) m_CONV_ASCII_RD ( .CLK(CLK), .RST_N(RST_N), .iDATA(iRD), .oASCII(rd_ascii) );

    //
    always @(*) begin
        case (state)
            IDLE_STATE: begin
                            if (start_trig) begin
                                if ((inp_cmd_4w == "stop") || (inp_cmd_4w == "STOP")) begin
                                    next_state      <= OUT_MSG;
                                    //
                                    next_wait_count <= 'h4;
                                    //
                                    next_buf_clr    <= 1'b0;
                                    //
                                    next_out_addr   <= 'h0000;
                                    next_out_we     <= 1'b1;
                                    next_out_re     <= 1'b0;
                                    next_out_data   <= 8'h01;
                                    //
                                    next_uart_de    <= 1'h0;
                                    next_uart_data  <= 'hFF;
                                    next_hold_data  <= ok_msg_str;
                                end else if ((inp_cmd_5w == "start") || (inp_cmd_5w == "START")) begin
                                    next_state      <= OUT_MSG;
                                    //
                                    next_wait_count <= 'h0;
                                    //
                                    next_buf_clr    <= 1'b0;
                                    //
                                    next_out_addr   <= 'h0000;
                                    next_out_we     <= 1'b1;
                                    next_out_re     <= 1'b0;
                                    next_out_data   <= 8'h00;
                                    //
                                    next_uart_de    <= 1'h0;
                                    next_uart_data  <= 'hFF;
                                    next_hold_data  <= null_str;
                                end else if ((inp_cmd_3w == "rd ") || (inp_cmd_3w == "RD ")) begin
                                    next_state      <= RD_ACCESS;
                                    //
                                    next_wait_count <= 'h2 - 'h1;
                                    //
                                    next_buf_clr    <= 1'b0;
                                    //
                                    next_out_addr   <= inp_addr;
                                    next_out_we     <= 1'b0;
                                    next_out_re     <= 1'b1;
                                    next_out_data   <= out_data;
                                    //
                                    next_uart_de    <= uart_de;
                                    next_uart_data  <= uart_data;
                                    next_hold_data  <= ok_msg_str;
                                end else if ((inp_cmd_3w == "wr ") || (inp_cmd_3w == "WR ")) begin
                                    next_state      <= WR_ACCESS;
                                    //
                                    next_wait_count <= 'h0;
                                    //
                                    next_buf_clr    <= 1'b0;
                                    //
                                    next_out_addr   <= inp_addr;
                                    next_out_we     <= 1'b1;
                                    next_out_re     <= 1'b0;
                                    next_out_data   <= inp_data;
                                    //
                                    next_uart_de    <= uart_de;
                                    next_uart_data  <= uart_data;
                                    next_hold_data  <= ok_msg_str;
                                end else begin
                                    next_state      <= OUT_MSG;
                                    //
                                    next_wait_count <= 'h0;
                                    //
                                    next_buf_clr    <= 1'b0;
                                    //
                                    next_out_addr   <= inp_addr;
                                    next_out_we     <= 1'b0;
                                    next_out_re     <= 1'b0;
                                    next_out_data   <= inp_data;
                                    //
                                    next_uart_de    <= uart_de;
                                    next_uart_data  <= uart_data;
                                    next_hold_data  <= ng_msg_str;
                                end
                            end else begin
                                next_state      <= state;
                                //
                                next_wait_count <= wait_count;
                                //
                                next_buf_clr    <= 1'b0;
                                //
                                next_out_addr   <= out_addr;
                                next_out_we     <= out_we;
                                next_out_re     <= out_re;
                                next_out_data   <= out_data;
                                //
                                next_uart_de    <= uart_de;
                                next_uart_data  <= uart_data;
                                next_hold_data  <= hold_data;
                            end
                        end
            RD_ACCESS:  begin
                            if (wait_count == 'h0) begin
                                next_state      <= OUT_MSG;
                                //
                                next_wait_count <= 'h0;
                                //
                                next_buf_clr    <= 1'b0;
                                //
                                next_out_addr   <= inp_addr;
                                next_out_we     <= 1'b0;
                                next_out_re     <= 1'b0;
                                next_out_data   <= inp_data;
                                //
                                next_uart_de    <= uart_de;
                                next_uart_data  <= uart_data;
                                next_hold_data  <= rd_msg_str;
                            end else begin
                                next_state      <= state;
                                //
                                next_wait_count <= wait_count - 'h1;
                                //
                                next_buf_clr    <= 1'b0;
                                //
                                next_out_addr   <= out_addr;
                                next_out_we     <= out_we;
                                next_out_re     <= out_re;
                                next_out_data   <= out_data;
                                //
                                next_uart_de    <= uart_de;
                                next_uart_data  <= uart_data;
                                next_hold_data  <= hold_data;
                            end
                        end
            WR_ACCESS:  begin
                            next_state      <= OUT_MSG;
                            //
                            next_wait_count <= 'h0;
                            //
                            next_buf_clr    <= 1'b0;
                            //
                            next_out_addr   <= inp_addr;
                            next_out_we     <= 1'b0;
                            next_out_re     <= 1'b0;
                            next_out_data   <= inp_data;
                            //
                            next_uart_de    <= uart_de;
                            next_uart_data  <= uart_data;
                            next_hold_data  <= ok_msg_str;
                        end
            OUT_MSG:    begin
                            if (hold_data[ 7: 0] == 8'h00) begin
                                next_state      <= IDLE_STATE;
                                //
                                next_wait_count <= 'h0;
                                //
                                next_buf_clr    <= 1'b1;
                                //
                                next_out_addr   <= 'h0;
                                next_out_we     <= 1'b0;
                                next_out_re     <= 1'b0;
                                next_out_data   <= 'h0;
                                //
                                next_uart_de    <= 1'b0;
                                next_uart_data  <= 'h0;
                                next_hold_data  <= 'h0;
                            end else begin
                                next_state      <= WAIT_BUSY;
                                //
                                next_wait_count <= wait_count + 'h1;
                                //
                                next_buf_clr    <= 1'b0;
                                //
                                next_out_addr   <= out_addr;
                                next_out_we     <= out_we;
                                next_out_re     <= out_re;
                                next_out_data   <= out_data;
                                //
                                next_uart_de    <= 1'b1;
                                next_uart_data  <= hold_data[ 7: 0];
                                next_hold_data  <= { 8'h0, hold_data[HOLD_DATA_WIDTH -1: 8] };
                            end
                        end
            WAIT_BUSY:  begin
                            //
                            next_wait_count <= wait_count;
                            //
                            next_buf_clr    <= buf_clr;
                            //
                            next_out_addr   <= out_addr;
                            next_out_data   <= out_data;
                            //
                            next_uart_data  <= uart_data;
                            next_hold_data  <= hold_data;
                            //
                            if (iUART_TX_BUSY) begin
                                next_state      <= WAIT_READY;
                                //
                                next_out_we     <= 1'b0;
                                next_out_re     <= 1'b0;
                                //
                                next_uart_de    <= 1'b0;
                            end else begin
                                next_state      <= state;
                                //
                                next_out_we     <= out_we;
                                next_out_re     <= out_re;
                                //
                                next_uart_de    <= uart_de;
                            end
                        end
            WAIT_READY: begin
                            //
                            next_wait_count <= wait_count;
                            //
                            next_buf_clr    <= buf_clr;
                            //
                            next_out_addr   <= out_addr;
                            next_out_we     <= out_we;
                            next_out_re     <= out_re;
                            next_out_data   <= out_data;
                            //
                            next_uart_de    <= uart_de;
                            next_uart_data  <= uart_data;
                            next_hold_data  <= hold_data;
                            //
                            if (!iUART_TX_BUSY) begin
                                next_state      <= OUT_MSG;
                            end else begin
                                next_state      <= state;
                            end
                        end
            default:    begin
                            next_state      <= IDLE_STATE;
                            //
                            next_wait_count <= 'h0;
                            //
                            next_buf_clr    <= 1'b0;
                            //
                            next_out_addr   <= 'h0;
                            next_out_we     <= 1'b0;
                            next_out_re     <= 1'b0;
                            next_out_data   <= 'h0;
                            //
                            next_uart_de    <= 1'b0;
                            next_uart_data  <= 'h0;
                            next_hold_data  <= 'h0;
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
            buf_clr    <= 1'b0;
            //
            out_addr   <= 'h0;
            out_we     <= 1'b0;
            out_re     <= 1'b0;
            out_data   <= 'h0;
            //
            uart_de    <= 1'b0;
            uart_data  <= 'h0;
            hold_data  <= 'h0;
        end else begin
            state      <= next_state;
            //
            wait_count <= next_wait_count;
            //
            buf_clr    <= next_buf_clr;
            //
            out_addr   <= next_out_addr;
            out_we     <= next_out_we;
            out_re     <= next_out_re;
            out_data   <= next_out_data;
            //
            uart_de    <= next_uart_de;
            uart_data  <= next_uart_data;
            hold_data  <= next_hold_data;
        end
    end

endmodule
