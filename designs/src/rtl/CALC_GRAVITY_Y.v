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
    input   wire                                        CCLK,
    input   wire                                        RST_N,
    //
    input   wire                                        iVSYNC,
    //
    input   wire    [ADDR_WIDTH -1: 0]                  iHSIZE,
    input   wire    [ADDR_WIDTH -1: 0]                  iVSIZE,
    //
    input   wire                                        iDATA_EN,
    input   wire    [MDATA_WIDTH -1: 0]                 iMEMIN,
    output  wire    [ADDR_WIDTH -1: 0]                  oADDR,
    //
    output  wire                                        oSELECT_EN,
    //
    input   wire                                        iBUSY,
    //
    output  wire                                        oSTART_S_TRIG,
    output  wire                                        oSTART_Q_TRIG,
    //
    output  wire    [SUM_S_WIDTH -1: 0]                 oSUM_S,
    output  wire    [SUM_SX_WIDTH -1: 0]                oSUM_SX,
    output  wire    [SUM_SY_WIDTH -1: 0]                oSUM_SY,
    output  wire    [SUM_SX_WIDTH -1: 0]                oQUOTIENT_SX,
    output  wire    [SUM_SY_WIDTH -1: 0]                oQUOTIENT_SY,
    // Debug
    output  wire    [STATE_WIDTH -1: 0]                 oSTATE
);

    //
    localparam      SUM_S_WIDTH                         = 20;
    localparam      SUM_SX_WIDTH                        = 28;
    localparam      SUM_SY_WIDTH                        = 28;

    //
    localparam      STATE_WIDTH                         = 4;
    // 
    localparam      IDLE_STATE                          = 4'b0000,
                    CALC_Y_DIR                          = 4'b0001,
                    CALC_X_DIR                          = 4'b0010,
                    CALC_GRAV                           = 4'b0011,
                    PRE_WAIT                            = 4'b0100,
                    WAIT_OUTPUT                         = 4'b0101;

    //
    wire    [$clog2(MDATA_WIDTH): 0]                    count_val;

    wire    [SUM_S_WIDTH -1: 0]                         pe [0:MDATA_WIDTH - 1];

    // 
    reg     [STATE_WIDTH -1: 0]                         next_state, state;
    reg     [$clog2(MDATA_WIDTH) + 3: 0]                next_counter, counter;
    reg                                                 next_clear, clear;
    reg                                                 next_select_en, select_en;
    reg     [ADDR_WIDTH -1: 0]                          next_addr, addr;
    reg                                                 next_s_trig, s_trig;
    reg     [SUM_S_WIDTH -1 :0]                         next_sum_s, sum_s;
    reg     [SUM_SX_WIDTH -1 :0]                        next_sum_sx, sum_sx;
    reg     [SUM_SY_WIDTH -1 :0]                        next_sum_sy, sum_sy;

    //
    wire    [SUM_S_WIDTH + SUM_SX_WIDTH + 8 - 1: 0]     div_sum_sx_sum_s;
    wire    [SUM_S_WIDTH + SUM_SY_WIDTH + 8 - 1: 0]     div_sum_sy_sum_s;

    //
    assign  oSELECT_EN     = select_en;
    assign  oADDR          = addr;

    assign  oSTART_S_TRIG  = s_trig_dly;

    //
    assign  oSUM_S         = sum_s;
    assign  oSUM_SX        = sum_sx;
    assign  oSUM_SY        = sum_sy;

    // for Debug
    assign  oSTATE  = state;

    //
    DET_EDGE m_DET_VSYNC_EDGE( .CLK(CCLK), .RST_N(RST_N), .iS(iVSYNC), .oRISE(rise_vsync), .oFALL(fall_vsync) );
    DET_EDGE m_DET_BUSY_EDGE ( .CLK(CCLK), .RST_N(RST_N), .iS(iBUSY ), .oRISE(rise_busy ), .oFALL(fall_busy ) );

    //
    CYCLE_DELAY #( .DATA_WIDTH(1), .DELAY(1) )  m_TRIG_DLY( .CLK(CCLK), .RST_N(RST_N), .iD(s_trig), .oD(s_trig_dly) );

    // 
    COUNT_HIGH_BIT #( .BIT_WIDTH(MDATA_WIDTH) ) m_COUNT_HIGH_BIT    ( .iBIT(iMEMIN), .oCOUNT(count_val) );

    // 
    generate
        genvar                                          i;
        //
        for (i=0; i< MDATA_WIDTH; i=i+1) begin: inst_loop
            SUM_UNIT #( .FACTOR_WIDTH($clog2(MDATA_WIDTH)), .IDATA_WIDTH(1), .ODATA_WIDTH(SUM_S_WIDTH) ) m_SUM_UNIT(
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
                            next_s_trig    <= 1'b0;
                            if (rise_vsync) begin
                                next_state     <= CALC_Y_DIR;
                                // 
                                next_clear     <= 1'b0;
                                // 
                                next_select_en <= 1'b1;
                                //
                                next_sum_s     <= 'h0;
                                next_sum_sx    <= 'h0;
                                next_sum_sy    <= 'h0;
                            end else begin
                                next_state     <= state;
                                // 
                                next_select_en <= 1'b0;
                                //
                                next_sum_s     <= sum_s;
                                next_sum_sx    <= sum_sx;
                                next_sum_sy    <= sum_sy;
                            end
                        end
            CALC_Y_DIR: begin
                            next_clear     <= clear;
                            //
                            next_s_trig    <= 1'b0;
                            //
                            if (addr==iVSIZE) begin         // 
                                next_state     <= CALC_X_DIR;
                                // 
                                next_counter   <= iHSIZE - 'h1;
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
                                next_counter   <= 'h1FF;
                                //
                                next_s_trig    <= 1'b1;
                                //
                                next_sum_sx    <= sum_sx + pe[counter];
                            end else begin
                                next_state     <= state;
                                //
                                next_counter   <= counter - 'h1;
                                //
                                next_s_trig    <= 1'b0;
                                //
                                next_sum_sx    <= sum_sx + pe[counter];
                            end
                        end
            CALC_GRAV:  begin
                            // 
                            next_clear     <= clear;
                            //
                            next_select_en <= select_en;
                            // 
                            next_addr      <= 'h0;
                            //
                            next_sum_s     <= sum_s;
                            next_sum_sx    <= sum_sx;
                            next_sum_sy    <= sum_sy;
                            //
                            if (counter == 'h0) begin
                                next_state     <= PRE_WAIT;
                                // 
                                next_counter   <= 'h1FF;
                                //
                                next_s_trig    <= 1'b0;
                            end else begin
                                next_state     <= state;
                                // 
                                next_counter   <= counter - 'h1;
                                //
                                next_s_trig    <= s_trig;
                            end
                        end
            PRE_WAIT:   begin
                            // 
                            next_clear     <= clear;
                            //
                            next_select_en <= select_en;
                            // 
                            next_addr      <= addr;
                            //
                            next_s_trig    <= 1'b0;
                            //
                            next_sum_s     <= sum_s;
                            next_sum_sx    <= sum_sx;
                            next_sum_sy    <= sum_sy;
                            //
                            if (rise_busy) begin
                                next_state     <= WAIT_OUTPUT;
                                // 
                                next_counter   <= counter;
                            end else if (counter=='h0) begin
                                next_state     <= WAIT_OUTPUT;
                                // 
                                next_counter   <= 'hFFF;
                            end else begin
                                next_state     <= state;
                                // 
                                next_counter   <= counter - 'h1;
                            end
                        end
            WAIT_OUTPUT:begin
                            //
                            next_s_trig    <= 1'b0;
                            //
                            next_sum_s     <= sum_s;
                            next_sum_sx    <= sum_sx;
                            next_sum_sy    <= sum_sy;
                            //
                            if (fall_busy) begin
                                next_state     <= IDLE_STATE;
                                // 
                                next_counter   <= 'h0;
                                // 
                                next_clear     <= 1'b1;
                                //
                                next_select_en <= 1'b0;
                                // 
                                next_addr      <= 'h0;
                            end else if (counter=='h0) begin
                                next_state     <= IDLE_STATE;
                                // 
                                next_counter   <= 'h0;
                                // 
                                next_clear     <= 1'b1;
                                //
                                next_select_en <= 1'b0;
                                // 
                                next_addr      <= 'h0;
                            end else begin
                                next_state     <= state;
                                // 
                                next_counter   <= counter - 'h1;
                                // 
                                next_clear     <= clear;
                                //
                                next_select_en <= select_en;
                                // 
                                next_addr      <= addr;
                            //
                            end
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
                            next_s_trig    <= 1'b0;
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
            s_trig    <= 1'b0;
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
            s_trig    <= next_s_trig;
            //
            sum_s     <= next_sum_s;
            sum_sx    <= next_sum_sx;
            sum_sy    <= next_sum_sy;
        end
    end

    //
    DFF_REG #( .DATA_WIDTH(8), .INIT_VAL(8'h00) ) m_DIVIDED_SX_L ( .CLK(CCLK), .RST_N(RST_N), 
                                                                   .iWE(divid_sx_load_en), .iD(div_sum_sx_sum_s[31:24]), .oD(oQUOTIENT_SX[ 7: 0]) );
    DFF_REG #( .DATA_WIDTH(8), .INIT_VAL(8'h00) ) m_DIVIDED_SX_LM( .CLK(CCLK), .RST_N(RST_N), 
                                                                   .iWE(divid_sx_load_en), .iD(div_sum_sx_sum_s[39:32]), .oD(oQUOTIENT_SX[15: 8]) );
    DFF_REG #( .DATA_WIDTH(8), .INIT_VAL(8'h00) ) m_DIVIDED_SX_HM( .CLK(CCLK), .RST_N(RST_N), 
                                                                   .iWE(divid_sx_load_en), .iD(div_sum_sx_sum_s[47:40]), .oD(oQUOTIENT_SX[23:16]) );
    DFF_REG #( .DATA_WIDTH(4), .INIT_VAL(8'h00) ) m_DIVIDED_SX_H ( .CLK(CCLK), .RST_N(RST_N), 
                                                                   .iWE(divid_sx_load_en), .iD(div_sum_sx_sum_s[51:48]), .oD(oQUOTIENT_SX[27:24]) );

    //
    DFF_REG #( .DATA_WIDTH(8), .INIT_VAL(8'h00) ) m_DIVIDED_SY_L ( .CLK(CCLK), .RST_N(RST_N), 
                                                                   .iWE(divid_sy_load_en), .iD(div_sum_sy_sum_s[31:24]), .oD(oQUOTIENT_SY[ 7: 0]) );
    DFF_REG #( .DATA_WIDTH(8), .INIT_VAL(8'h00) ) m_DIVIDED_SY_LM( .CLK(CCLK), .RST_N(RST_N), 
                                                                   .iWE(divid_sy_load_en), .iD(div_sum_sy_sum_s[39:32]), .oD(oQUOTIENT_SY[15: 8]) );
    DFF_REG #( .DATA_WIDTH(8), .INIT_VAL(8'h00) ) m_DIVIDED_SY_HM( .CLK(CCLK), .RST_N(RST_N), 
                                                                   .iWE(divid_sy_load_en), .iD(div_sum_sy_sum_s[47:40]), .oD(oQUOTIENT_SY[23:16]) );
    DFF_REG #( .DATA_WIDTH(4), .INIT_VAL(8'h00) ) m_DIVIDED_SY_H ( .CLK(CCLK), .RST_N(RST_N), 
                                                                   .iWE(divid_sy_load_en), .iD(div_sum_sy_sum_s[51:48]), .oD(oQUOTIENT_SY[27:24]) );
    //
    CYCLE_DELAY #( .DATA_WIDTH(1), .DELAY(2) ) m_START_Q_TRIG_DLY ( .CLK(CCLK), .RST_N(RST_N), 
                                             .iD(divid_sx_load_en | divid_sy_load_en), .oD(oSTART_Q_TRIG) );

    //
    MATH_DIV_CTRL   m_MATH_DIV_SX_CTRL ( .CLK(CCLK), .RST_N(RST_N), 
                                         //
                                         .iTRIG(s_trig),
                                         //
                                         .iDIVIDEND_TREADY(1'b1),
                                         .iDIVISOR_TREADY (1'b1),
                                         .iDOUT_TVALID(dout_sx_tvalid),
                                         //
                                         .oDIVIDEND_TVALID(dividend_sx_tvalid), .oDIVISOR_TVALID(divisor_sx_tvalid),
                                         //
                                         .oDIVID_LOAD_EN(divid_sx_load_en)
            );

    //
    MATH_DIV_CTRL   m_MATH_DIV_SY_CTRL ( .CLK(CCLK), .RST_N(RST_N), 
                                         //
                                         .iTRIG(s_trig),
                                         //
                                         .iDIVIDEND_TREADY(1'b1),
                                         .iDIVISOR_TREADY (1'b1),
                                         .iDOUT_TVALID(dout_sy_tvalid),
                                         //
                                         .oDIVIDEND_TVALID(dividend_sy_tvalid), .oDIVISOR_TVALID(divisor_sy_tvalid),
                                         //
                                         .oDIVID_LOAD_EN(divid_sy_load_en)
            );

    //
    DIV_28_20   m_DIV_28_20_SX  (
            .aclk(CCLK), .aclken(1'b1), .aresetn(RST_N),
            .s_axis_divisor_tvalid (divisor_sx_tvalid), 
            .s_axis_divisor_tdata  ({4'h0, sum_s}),
            .s_axis_dividend_tvalid(dividend_sx_tvalid), 
            .s_axis_dividend_tdata ({4'h0, sum_sx}),
            .m_axis_dout_tvalid    (dout_sx_tvalid),
            .m_axis_dout_tdata     (div_sum_sx_sum_s),
            .m_axis_dout_tuser     ()
            );

    DIV_28_20   m_DIV_28_20_SY  (
            .aclk(CCLK), .aclken(1'b1), .aresetn(RST_N),
            .s_axis_divisor_tvalid (divisor_sy_tvalid), 
            .s_axis_divisor_tdata  ({4'h0, sum_s}),
            .s_axis_dividend_tvalid(dividend_sy_tvalid), 
            .s_axis_dividend_tdata ({4'h0, sum_sy}),
            .m_axis_dout_tvalid    (dout_sy_tvalid),
            .m_axis_dout_tdata     (div_sum_sy_sum_s),
            .m_axis_dout_tuser     ()
            );

endmodule
