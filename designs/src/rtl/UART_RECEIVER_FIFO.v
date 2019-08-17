// -----------------------------------------------------------------------------
//  Title         : UART_RECEIVER_FIFO
//  Project       : HOST IF
// -----------------------------------------------------------------------------
//  File          : UART_RECEIVER_FIFO.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 6/10
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : UART RECEIVER FIFO
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module UART_RECEIVER_FIFO #(
    parameter   BUFFER_SIZE     = 16
) (
    input   wire                                        CLK,
    input   wire                                        RST_N,
    //
    input   wire                                        iCLR,
    //
    input   wire                                        iDE,
    input   wire    [DATA_WIDTH -1 : 0]                 iDATA,
    //
    output  wire                                        oINT,
    output  wire    [DATA_WIDTH * BUFFER_SIZE -1 : 0]   oDATA
);
    //
    localparam      DATA_WIDTH                          = 8;

    //
    localparam      CHAR_CR                             = 8'h0D;
    localparam      CHAR_LF                             = 8'h0A;
    localparam      CHAR_BS                             = 8'h08;

    //
    wire                                                start_trig;

    //
    reg                                                 int;
    reg     [$clog2(BUFFER_SIZE): 0]                    pointer;
    reg     [DATA_WIDTH * BUFFER_SIZE -1 : 0]           fifo_buffer;

    //
    integer                                             i;

    //
    assign  oINT  = int;
    assign  oDATA = fifo_buffer;

    // 
    DET_EDGE m_DET_START_TRIG( .CLK(CLK), .RST_N(RST_N), .iS(iDE), .oRISE(start_trig), .oFALL() );

    //
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            int     <= 1'b0;
            pointer <= 'h0;
        end else if (iCLR) begin
            int     <= 1'b0;
            pointer <= 'h0;
        end else if (start_trig) begin
            if (iDATA==CHAR_LF) begin
                int     <= 1'b1;
                pointer <= 'h0;
            end else if (iDATA==CHAR_BS) begin
                int     <= 1'b0;
                pointer <= (pointer=='h0) ? pointer: pointer - 'h1;
            end else begin
                int     <= 1'b0;
                pointer <= pointer + 'h1;
            end
        end else begin
            int     <= int;
            pointer <= pointer;
        end
    end

    //
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            fifo_buffer <= 'h0;
        end else if (iCLR) begin
            for (i=0; i<BUFFER_SIZE;i=i+1) begin
                fifo_buffer[DATA_WIDTH*i  ] <= 1'b0;
                fifo_buffer[DATA_WIDTH*i+1] <= 1'b0;
                fifo_buffer[DATA_WIDTH*i+2] <= 1'b0;
                fifo_buffer[DATA_WIDTH*i+3] <= 1'b0;
                fifo_buffer[DATA_WIDTH*i+4] <= 1'b0;
                fifo_buffer[DATA_WIDTH*i+5] <= 1'b0;
                fifo_buffer[DATA_WIDTH*i+6] <= 1'b0;
                fifo_buffer[DATA_WIDTH*i+7] <= 1'b0;
            end
        end else begin
            for (i=0; i<BUFFER_SIZE;i=i+1) begin
                if (pointer == i) begin
                    fifo_buffer[DATA_WIDTH*i  ] <= (iDE) ? iDATA[0]: fifo_buffer[DATA_WIDTH*i  ];
                    fifo_buffer[DATA_WIDTH*i+1] <= (iDE) ? iDATA[1]: fifo_buffer[DATA_WIDTH*i+1];
                    fifo_buffer[DATA_WIDTH*i+2] <= (iDE) ? iDATA[2]: fifo_buffer[DATA_WIDTH*i+2];
                    fifo_buffer[DATA_WIDTH*i+3] <= (iDE) ? iDATA[3]: fifo_buffer[DATA_WIDTH*i+3];
                    fifo_buffer[DATA_WIDTH*i+4] <= (iDE) ? iDATA[4]: fifo_buffer[DATA_WIDTH*i+4];
                    fifo_buffer[DATA_WIDTH*i+5] <= (iDE) ? iDATA[5]: fifo_buffer[DATA_WIDTH*i+5];
                    fifo_buffer[DATA_WIDTH*i+6] <= (iDE) ? iDATA[6]: fifo_buffer[DATA_WIDTH*i+6];
                    fifo_buffer[DATA_WIDTH*i+7] <= (iDE) ? iDATA[7]: fifo_buffer[DATA_WIDTH*i+7];
                end else begin
                    fifo_buffer[DATA_WIDTH*i  ] <= fifo_buffer[DATA_WIDTH*i  ];
                    fifo_buffer[DATA_WIDTH*i+1] <= fifo_buffer[DATA_WIDTH*i+1];
                    fifo_buffer[DATA_WIDTH*i+2] <= fifo_buffer[DATA_WIDTH*i+2];
                    fifo_buffer[DATA_WIDTH*i+3] <= fifo_buffer[DATA_WIDTH*i+3];
                    fifo_buffer[DATA_WIDTH*i+4] <= fifo_buffer[DATA_WIDTH*i+4];
                    fifo_buffer[DATA_WIDTH*i+5] <= fifo_buffer[DATA_WIDTH*i+5];
                    fifo_buffer[DATA_WIDTH*i+6] <= fifo_buffer[DATA_WIDTH*i+6];
                    fifo_buffer[DATA_WIDTH*i+7] <= fifo_buffer[DATA_WIDTH*i+7];
                end
            end
        end
    end

endmodule
