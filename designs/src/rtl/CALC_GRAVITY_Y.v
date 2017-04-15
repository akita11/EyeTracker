// -----------------------------------------------------------------------------
//  Title         : Calculate center of gravity
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : CALC_GRAVITY.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 3/18
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Calculate center of gravity
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module CALC_GRAVITY_Y #(
    parameter   ADDR_WIDTH  = 11,
    parameter   MDATA_WIDTH = 640,
    parameter   MAX_Y_ADDR  = 480,
    parameter   PIXEL_WIDTH = 8
) (
    // 
    input   wire                            CCLK,
    input   wire                            RST_N,
    //
    input   wire    [PIXEL_WIDTH -1: 0]     iTHRESHOLD,
    //
    input   wire                            iFVAL,
    input   wire    [PIXEL_WIDTH -1: 0]     iDATA_L,
    input   wire    [PIXEL_WIDTH -1: 0]     iDATA_R,
    //
    input   wire                            iDATA_EN,
    input   wire    [MDATA_WIDTH -1: 0]     iMEMIN,
    output  wire    [ADDR_WIDTH -1: 0]      oADDR,
    //
    output  wire                            oSELECT_EN
);

    //
    localparam      STATE_WIDTH             = 4;
    localparam      SUM_S_WIDTH             = 20;
    localparam      SUM_SX_WIDTH            = 28;
    localparam      SUM_SY_WIDTH            = 28;

    // 
    localparam      IDLE_STATE              = 4'b0000,
                    CALC_Y_DIR              = 4'b0001,
                    CALC_X_DIR              = 4'b0010,
                    CALC_GRAV               = 4'b0011,
                    OUT_UART_S              = 4'b0100,
                    OUT_UART_SX             = 4'b0101,
                    OUT_UART_SY             = 4'b0110;

    //
    wire    [$clog2(MDATA_WIDTH): 0]        count_val;

    wire    [SUM_S_WIDTH -1: 0]             pe [0:MDATA_WIDTH - 1];

    wire    [48 -1: 0]                      div_sum_sx_sum_s;
    wire    [48 -1: 0]                      div_sum_sy_sum_s;

    // 
    reg     [STATE_WIDTH -1: 0]             next_state, state;
    reg     [$clog2(MDATA_WIDTH): 0]        next_counter, counter;
    reg                                     next_clear, clear;
    reg                                     next_select_en, select_en;
    reg     [ADDR_WIDTH -1: 0]              next_addr, addr;
    reg     [SUM_S_WIDTH -1 :0]             next_sum_s, sum_s;
    reg     [SUM_SX_WIDTH -1 :0]            next_sum_sx, sum_sx;
    reg     [SUM_SY_WIDTH -1 :0]            next_sum_sy, sum_sy;

    //
    assign  oSELECT_EN = select_en;
    assign  oADDR = addr;

    // sum_s    <= 
    // sum_sx   <= 
    // sum_sy   <= 
    // sum_x_s  <= 
    // sum_x_sx <= 
    // sum_x_sy <= 

    assign  flag_l = (iDATA_L > iTHRESHOLD) ? 1'b1: 1'b0;
    assign  flag_r = (iDATA_R > iTHRESHOLD) ? 1'b1: 1'b0;

    //
    DET_EDGE m_DET_FVAL_EDGE( .CLK(CCLK), .RST_N(RST_N), .iS(iFVAL), .oRISE(rise_fval), .oFALL(fall_fval) );

    // 
    COUNT_HIGH_BIT #( .BIT_WIDTH(MDATA_WIDTH) ) m_COUNT_HIGH_BIT    ( .iBIT(iMEMIN), .oCOUNT(count_val) );

    // 
    generate
        genvar                                      i;
        //
        for (i=0; i< MDATA_WIDTH; i=i+1) begin: inst_loop
            SUM_UNIT #( .FACTOR_WIDTH(10), .IDATA_WIDTH(1), .ODATA_WIDTH(18) ) m_SUM_UNIT(
                .CLK(CCLK), .RST_N(RST_N), 
                //
                .iCLR(clear), .iDATA_EN(iDATA_EN), .iFACTOR(i), .iD(iMEMIN[i]), 
                //
                .oD(pe[i])
            );
        end
    endgenerate

    // 
    always @(*) begin
        case (state)
            IDLE_STATE: begin
                            next_counter   <= 'h0;
                            //
                            next_addr      <= 'h0;
                            //
                            next_sum_s     <= 'h0;
                            next_sum_sx    <= 'h0;
                            next_sum_sy    <= 'h0;
                            // 
                            if (rise_fval) begin
                                next_state     <= CALC_Y_DIR;
                                // 
                                next_clear     <= 1'b0;
                                // 
                                next_select_en <= 1'b1;
                            end else begin
                                next_state     <= state;
                                // 
                                next_select_en <= 1'b0;
                            end
                        end
            CALC_Y_DIR: begin
                            next_clear     <= clear;
                            //
                            if (addr==MAX_Y_ADDR) begin         // 
                                next_state     <= CALC_X_DIR;
                                // 
                                next_counter   <= MDATA_WIDTH - 'h1;
                                //
                                next_select_en <= select_en;
                                // 
                                next_addr      <= 'h0;
                                //
                                next_sum_s     <= sum_s;
                                next_sum_sx    <= sum_sx;
                                next_sum_sy    <= sum_sy;
                            end else begin
                                next_state     <= state;
                                // 
                                next_counter   <= counter;
                                //
                                next_select_en <= 1'b1;
                                // 
                                next_addr      <= addr + 'h1;
                                //
                                next_sum_s     <= sum_s  + count_val;
                                next_sum_sx    <= sum_sx ;
                                next_sum_sy    <= sum_sy + addr * count_val;
                            end
                        end
            CALC_X_DIR: begin
                            next_clear     <= clear;
                            //
                            next_select_en <= select_en;
                            //
                            next_addr      <= addr;
                            //
                            next_sum_s     <= sum_s;
                            next_sum_sy    <= sum_sy;
                            //
                            if (counter=='h0) begin 
                                next_state <= CALC_GRAV;
                                // 
                                next_counter   <= 'h0;
                                //
                                next_sum_sx    <= sum_sx + pe[counter];
                            end else begin
                                next_state     <= state;
                                //
                                next_counter   <= counter - 'h1;
                                //
                                next_sum_sx    <= sum_sx + pe[counter];
                            end
                        end
            CALC_GRAV:  begin
                            next_state     <= IDLE_STATE;
                            // 
                            next_counter   <= 'h0;
                            // 
                            next_clear     <= 1'b1;
                            //
                            next_select_en <= 1'b0;
                            // 
                            next_addr      <= 'h0;
                            //
                            next_sum_s     <= 'h0;
                            next_sum_sx    <= 'h0;
                            next_sum_sy    <= 'h0;
                        end
            OUT_UART_S: begin
                            next_state     <= IDLE_STATE;
                            // 
                            next_counter   <= 'h0;
                            // 
                            next_clear     <= 1'b1;
                            //
                            next_select_en <= 1'b0;
                            // 
                            next_addr      <= 'h0;
                            //
                            next_sum_s     <= 'h0;
                            next_sum_sx    <= 'h0;
                            next_sum_sy    <= 'h0;
                        end
            OUT_UART_SX:begin
                            next_state     <= IDLE_STATE;
                            // 
                            next_counter   <= 'h0;
                            // 
                            next_clear     <= 1'b1;
                            //
                            next_select_en <= 1'b0;
                            // 
                            next_addr      <= 'h0;
                            //
                            next_sum_s     <= 'h0;
                            next_sum_sx    <= 'h0;
                            next_sum_sy    <= 'h0;
                        end
            OUT_UART_SY:begin
                            next_state     <= IDLE_STATE;
                            // 
                            next_counter   <= 'h0;
                            // 
                            next_clear     <= 1'b1;
                            //
                            next_select_en <= 1'b0;
                            // 
                            next_addr      <= 'h0;
                            //
                            next_sum_s     <= 'h0;
                            next_sum_sx    <= 'h0;
                            next_sum_sy    <= 'h0;
                        end
            default:    begin
                            next_state     <= IDLE_STATE;
                            // 
                            next_counter   <= 'h0;
                            // 
                            next_clear     <= 1'b1;
                            //
                            next_select_en <= 1'b0;
                            // 
                            next_addr      <= 'h0;
                            //
                            next_sum_s     <= 'h0;
                            next_sum_sx    <= 'h0;
                            next_sum_sy    <= 'h0;
                        end
        endcase
    end

    // 
    always @(posedge CCLK or negedge RST_N) begin
        if (!RST_N) begin
            state     <= IDLE_STATE;
            //
            counter   <= 'h0;
            //
            clear     <= 1'b0;
            //
            select_en <= 1'b0;
            // 
            addr      <= 'h0;
            //
            sum_s     <= 'h0;
            sum_sx    <= 'h0;
            sum_sy    <= 'h0;
        end else begin
            state     <= next_state;
            //
            counter   <= next_counter;
            //
            clear     <= next_clear;
            //
            select_en <= next_select_en;
            // 
            addr      <= next_addr;
            //
            sum_s     <= next_sum_s;
            sum_sx    <= next_sum_sx;
            sum_sy    <= next_sum_sy;
        end
    end

    DIV_28_20_SX    m_DIV_28_20_SX  (
            .aclk(CCLK), .aclken(1'b1), .aresetn(RST_N),
            .s_axis_divisor_tvalid(1'b1), .s_axis_divisor_tready(),
            .s_axis_divisor_tdata({4'h0, sum_s}),
            .s_axis_dividend_tvalid(1'b1), .s_axis_dividend_tready(),
            .s_axis_dividend_tdata({4'h0, sum_sx}),
            .m_axis_dout_tvalid(),
            .m_axis_dout_tdata(div_sum_sx_sum_s)
            );

    DIV_28_20_SY    m_DIV_28_20_SY  (
            .aclk(CCLK), .aclken(1'b1), .aresetn(RST_N),
            .s_axis_divisor_tvalid(1'b1), .s_axis_divisor_tready(),
            .s_axis_divisor_tdata({4'h0, sum_s}),
            .s_axis_dividend_tvalid(1'b1), .s_axis_dividend_tready(),
            .s_axis_dividend_tdata({4'h0, sum_sy}),
            .m_axis_dout_tvalid(),
            .m_axis_dout_tdata(div_sum_sx_sum_s)
            );

endmodule
