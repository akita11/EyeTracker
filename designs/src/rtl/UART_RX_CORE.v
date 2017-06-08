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

module UART_RX_CORE #(
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
    input   wire                                iUART_RX,
    //
    output  wire                                oRETRY,
    output  wire                                oPARITY_ERROR,
    //
    output  wire                                oDE,
    output  wire    [DATA_WIDTH -1 : 0]         oDATA
);

    // 
    localparam      IDLE_STATE                  = 4'b0000,
                    CHECK_START_BIT             = 4'b0001,
                    LATCH_DATA                  = 4'b0010,
                    LATCH_PARITY                = 4'b0011,
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
    reg     [$clog2(OVER_SAMPLING): 0]          next_latch_count, latch_count;
    reg                                         next_retry, retry;
    reg                                         next_parity_error, parity_error;
    reg                                         next_de, de;
    reg     [DATA_WIDTH -1 : 0]                 next_data, data;

    //
    assign  oRETRY        = retry;
    assign  oPARITY_ERROR = parity_error;
    //
    assign  oDE           = de;
    assign  oDATA         = data;

    // 
    always @(*) begin
        case (state)
            IDLE_STATE:     begin
                                //
                                next_wait_count   <= 'h0;
                                //
                                next_retry        <= 1'b0;
                                next_parity_error <= 1'b0;
                                //
                                next_de           <= 1'b0;
                                next_data         <= 'h0;
                                // 
                                if (iUART_RX == 1'b0) begin
                                    next_state        <= CHECK_START_BIT;
                                    next_latch_count  <= (OVER_SAMPLING - 'h1) - 'h1;
                                end else begin
                                    next_state        <= state;
                                    //
                                    next_latch_count  <= 'h0;
                                end
                            end
            CHECK_START_BIT:begin
                                //
                                next_retry        <= 1'b0;
                                next_parity_error <= 1'b0;
                                //
                                next_de           <= 1'b0;
                                next_data         <= 'h0;
                                // 
                                if (iUART_RX == 1'b0) begin
                                    if (latch_count == 'h0) begin
                                        next_state       <= LATCH_DATA;
                                        //
                                        next_wait_count  <= (iSEVEN_BIT) ? 'h7 - 'h1: 'h8 - 'h1;
                                        next_latch_count <= (OVER_SAMPLING - 'h1);
                                    end else begin
                                        next_state       <= state;
                                        //
                                        next_wait_count  <= wait_count;
                                        next_latch_count <= latch_count - 'h1;
                                    end
                                end else begin
                                    // Cancel
                                    next_state       <= IDLE_STATE;
                                    //
                                    next_wait_count  <= 'h0;
                                    next_latch_count <= 'h0;
                                end
                            end
            LATCH_DATA:     begin
                                //
                                next_retry        <= 1'b0;
                                next_parity_error <= 1'b0;
                                // 
                                if (latch_count == 'h0) begin
                                    next_latch_count <= (OVER_SAMPLING - 'h1);
                                    //
                                    next_de          <= 1'b0;
                                    //
                                    if (wait_count == 'h0) begin
                                        next_state       <= (iPARITY_EN) ? LATCH_PARITY: STOP_BIT;
                                        //
                                        next_wait_count  <= 'h0;
                                        //
                                        next_data        <= (iSEVEN_BIT) ? { 1'b0, iUART_RX, data[7:2] }: { iUART_RX, data[7:1] };
                                    end else begin
                                        next_state       <= state;
                                        //
                                        next_wait_count  <= wait_count - 'h1;
                                        //
                                        next_data        <= { iUART_RX, data[7:1] };
                                    end
                                end else begin
                                    next_state        <= state;
                                    //
                                    next_wait_count   <= wait_count;
                                    next_latch_count  <= latch_count - 'h1;
                                    //
                                    next_de           <= 1'b0;
                                    next_data         <= data;
                                end
                            end
            LATCH_PARITY:   begin
                                //
                                next_de           <= 1'b0;
                                next_data         <= data;
                                // 
                                if (latch_count == 'h0) begin
                                    next_state        <= STOP_BIT;
                                    //
                                    next_wait_count   <= (iSTOP_BIT) ? 'h2 - 'h1: 'h1 - 'h1;
                                    next_latch_count  <= (OVER_SAMPLING - 'h1);
                                    //
                                    next_retry        <= 1'b0;
                                    next_parity_error <= (iSEVEN_BIT) ? ^data[6:0] ^ iUART_RX ^ iODD_PARITY: ^data[7:0]  ^ iUART_RX ^ iODD_PARITY;
                                end else begin
                                    next_state        <= state;
                                    //
                                    next_wait_count   <= 'h0;
                                    next_latch_count  <= latch_count - 'h1;
                                    //
                                    next_retry        <= 1'b0;
                                    next_parity_error <= 1'b0;
                                end
                            end
            STOP_BIT:       begin
                                if (latch_count == 'h0) begin
                                    if (iUART_RX == 1'b1) begin
                                        if (wait_count == 'h0) begin
                                            next_state       <= IDLE_STATE;
                                            //
                                            next_wait_count  <= 'h0;
                                            next_latch_count <= 'h0;
                                            //
                                            next_retry        <= (parity_error) ? 1'b1: retry;
                                            next_parity_error <= parity_error;
                                            //
                                            next_de           <= 1'b1;
                                            next_data         <= data;
                                        end else begin
                                            next_state       <= state;
                                            //
                                            next_wait_count  <= wait_count - 'h1;
                                            next_latch_count  <= (OVER_SAMPLING - 'h1);
                                            //
                                            next_retry        <= retry;
                                            next_parity_error <= parity_error;
                                            //
                                            next_de           <= 1'b0;
                                            next_data         <= data;
                                        end
                                    end else begin
                                        next_state       <= IDLE_STATE;
                                        //
                                        next_wait_count  <= 'h0;
                                        next_latch_count <= 'h0;
                                        //
                                        next_retry        <= 1'b1;
                                        next_parity_error <= parity_error;
                                        //
                                        next_de           <= 1'b0;
                                        next_data         <= data;
                                    end
                                end else begin
                                    next_state       <= IDLE_STATE;
                                    //
                                    next_wait_count  <= wait_count;
                                    next_latch_count <= latch_count - 'h1;
                                    //
                                    next_retry        <= 1'b0;
                                    next_parity_error <= parity_error;
                                    //
                                    next_de           <= 1'b0;
                                    next_data         <= data;
                                end
                            end
            default:        begin
                                next_state        <= IDLE_STATE;
                                //
                                next_wait_count   <= 'h0;
                                next_latch_count  <= 'h0;
                                //
                                next_retry        <= 1'b0;
                                next_parity_error <= 1'b0;
                                //
                                next_de           <= 1'b0;
                                next_data         <= 'h0;
                            end
        endcase
    end

    // 
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            state       <= IDLE_STATE;
            //
            wait_count  <= 'h0;
            latch_count <= 'h0;
            //
            de          <= 1'b0;
            data        <= 'h0;
        end else begin
            state       <= next_state;
            //
            wait_count  <= next_wait_count;
            latch_count <= next_latch_count;
            //
            de          <= next_de;
            data        <= next_data;
        end
    end

endmodule
