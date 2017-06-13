// -----------------------------------------------------------------------------
//  Title         : UART Rx core
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : UART_RX_CORE.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 3/18
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : UART Rx core
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module UART_TX_CORE #(
    parameter   OVER_SAMPLING = 4
) (
    input   wire                                CLK,
    input   wire                                RST_N,
    // 
    input   wire                                iSEVEN_BIT,         // Low = 8bit,        High = 7bit
    input   wire                                iPARITY_EN,         // Low = Non Parity,  High = Parity Enable
    input   wire                                iODD_PARITY,        // Low = Even Parity, High = Odd Parity
    input   wire                                iSTOP_BIT,          // Low = 1bit,        High = 2bit
    //
    input   wire                                iDE,
    input   wire    [DATA_WIDTH -1 : 0]         iDATA,
    //
    output  wire                                oUART_TX_BUSY,
    output  wire                                oUART_TX
);

    // 
    localparam      IDLE_STATE                  = 4'b0000,
                    START_BIT                   = 4'b0001,
                    OUT_DATA                    = 4'b0010,
                    OUT_PARITY                  = 4'b0011,
                    STOP_BIT                    = 4'b0100;

    //
    localparam      STATE_WIDTH                 = 4;
    localparam      COUNTER_WIDTH               = 4;
    localparam      DATA_WIDTH                  = 8;

    //
    wire                                        start_trig;

    //
    reg     [STATE_WIDTH -1: 0]                 next_state, state;
    reg     [COUNTER_WIDTH -1: 0]               next_wait_count, wait_count;
    reg     [$clog2(OVER_SAMPLING): 0]          next_hold_count, hold_count;
    reg                                         next_com_out_en, com_out_en;
    reg     [DATA_WIDTH -1 : 0]                 next_out_data, out_data;
    reg                                         next_tx_busy, tx_busy;

    // 
    assign  oUART_TX_BUSY = tx_busy;
    assign  oUART_TX = (com_out_en) ? out_data[0]: 1'b1;

    // 
    DET_EDGE m_DET_START_TRIG( .CLK(CLK), .RST_N(RST_N), .iS(iDE), .oRISE(start_trig), .oFALL() );

    // 
    always @(*) begin
        case (state)
            IDLE_STATE: begin
                            if (start_trig) begin
                                next_state      <= START_BIT;
                                //
                                next_wait_count <= 'h0;
                                next_hold_count <= (OVER_SAMPLING - 'h1);
                                //
                                next_com_out_en <= 1'b1;
                                next_out_data   <= 8'h00;
                                //
                                next_tx_busy    <= 1'b1;
                            end else begin
                                next_state      <= state;
                                // 
                                next_wait_count <= wait_count;
                                next_hold_count <= hold_count;
                                //
                                next_com_out_en <= 1'b0;
                                next_out_data   <= out_data;
                                //
                                next_tx_busy    <= 1'b0;
                            end
                        end
            START_BIT:  begin
                            next_tx_busy    <= 1'b1;
                            //
                            if (hold_count == 'h0) begin
                                next_hold_count <= (OVER_SAMPLING - 'h1);
                                //
                                if (wait_count == 'h0) begin
                                    next_state      <= OUT_DATA;
                                    //
                                    next_wait_count <= (iSEVEN_BIT) ? ('h7 - 'h1): ('h8 - 'h1);
                                    // 
                                    next_com_out_en <= 1'b1;
                                    next_out_data   <= iDATA;
                                end else begin
                                    next_state      <= state;
                                    //
                                    next_wait_count <= wait_count - 'h1;
                                    //
                                    next_com_out_en <= 1'b1;
                                    next_out_data   <= out_data;
                                end
                            end else begin
                                next_state      <= state;
                                //
                                next_wait_count <= wait_count;
                                next_hold_count <= hold_count - 'h1;
                                //
                                next_com_out_en <= com_out_en;
                                next_out_data   <= out_data;
                            end
                        end
            OUT_DATA:   begin
                            next_tx_busy    <= 1'b1;
                            //
                            if (hold_count == 'h0) begin
                                next_hold_count <= (OVER_SAMPLING - 'h1);
                                //
                                if (wait_count == 'h0) begin
                                    //
                                    next_com_out_en <= 1'b1;
                                    // 
                                    if (iPARITY_EN == 1'b1) begin
                                        next_state      <= OUT_PARITY;
                                        //
                                        next_wait_count <= 'h0;
                                        //
                                        next_com_out_en <= 1'b1;
                                        next_out_data   <= (iSEVEN_BIT) ? ^iDATA[6:0] ^ iODD_PARITY: ^iDATA[7:0] ^ iODD_PARITY;
                                    end else begin
                                        next_state      <= STOP_BIT;
                                        //
                                        next_wait_count <= (iSTOP_BIT) ? 'h2 - 'h1: 'h1 - 'h1;
                                        //
                                        next_out_data   <= 'hFF;
                                    end
                                end else begin
                                    next_state      <= state;
                                    // 
                                    next_wait_count <= wait_count - 'h1;
                                    //
                                    next_com_out_en <= 1'b1;
                                    next_out_data   <= {1'b0, out_data[7:1] };
                                end
                            end else begin
                                next_state      <= state;
                                // 
                                next_wait_count <= wait_count;
                                next_hold_count <= hold_count - 'h1;
                                //
                                next_com_out_en <= com_out_en;
                                next_out_data   <= out_data;
                            end
                        end
            OUT_PARITY: begin
                            next_tx_busy    <= 1'b1;
                            //
                            if (hold_count == 'h0) begin
                                next_state      <= STOP_BIT;
                                //
                                next_wait_count <= (iSTOP_BIT) ? 'h2 - 'h1: 'h1 - 'h1;
                                next_hold_count <= hold_count;
                                //
                                next_com_out_en <= 1'b1;
                                next_out_data   <= 'hFF;
                            end else begin
                                next_state      <= state;
                                //
                                next_wait_count <= wait_count;
                                next_hold_count <= (OVER_SAMPLING - 'h1);
                                //
                                next_com_out_en <= com_out_en;
                                next_out_data   <= out_data;
                            end
                        end
            STOP_BIT:   begin
                            if (hold_count == 'h0) begin
                                if (wait_count == 'h0) begin
                                    next_state      <= IDLE_STATE;
                                    // 
                                    next_wait_count <= 'h0;
                                    next_hold_count <= hold_count;
                                    //
                                    next_com_out_en <= 1'b0;
                                    next_out_data   <= 'hFF;
                                    //
                                    next_tx_busy    <= 1'b0;
                                end else begin
                                    next_state      <= state;
                                    // 
                                    next_wait_count <= wait_count - 'h1;
                                    next_hold_count <= hold_count;
                                    //
                                    next_com_out_en <= com_out_en;
                                    next_out_data   <= out_data;
                                    //
                                    next_tx_busy    <= 1'b1;
                                end
                            end else begin
                                next_state      <= state;
                                //
                                next_wait_count <= wait_count;
                                next_hold_count <= hold_count - 'h1;
                                //
                                next_com_out_en <= com_out_en;
                                next_out_data   <= out_data;
                                //
                                next_tx_busy    <= 1'b1;
                            end
                        end
            default:    begin
                            next_state      <= IDLE_STATE;
                            // 
                            next_wait_count <= 'h0;
                            next_hold_count <= 'h0;
                            //
                            next_com_out_en <= 1'b0;
                            next_out_data   <= 'hFF;
                            //
                            next_tx_busy    <= 1'b1;
                        end
        endcase
    end

    // 
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            state      <= IDLE_STATE;
            //
            wait_count <= 'h0;
            hold_count <= 'h0;
            //
            com_out_en <= 1'b0;
            out_data   <= 'hFF;
            //
            tx_busy    <= 1'b0;
        end else begin
            state      <= next_state;
            //
            wait_count <= next_wait_count;
            hold_count <= next_hold_count;
            //
            com_out_en <= next_com_out_en;
            out_data   <= next_out_data;
            //
            tx_busy    <= next_tx_busy;
        end
    end

endmodule
