// -----------------------------------------------------------------------------
//  Title         : Multi Frame Control
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : FRAME_CTRL.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 4/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Mult Frame Control
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module FRAME_CTRL #(
    parameter   MAX_FRAME                   = 3
    
) (
    // 
    input   wire                            CCLK,
    input   wire                            RST_N,
    //
    input   wire                            iVSYNC_A,
    output  wire    [-1: 0] oFRAME_NUM_A

    //
    input   wire                            iVSYNC_B
    output  wire    [-1: 0] oFRAME_NUMB
);

    //
    localparam      STATE_WIDTH             = 4;
    localparam      SUM_S_WIDTH             = 12;
    localparam      SUM_SX_WIDTH            = 18;
    localparam      SUM_SY_WIDTH            = 18;

    // 
    localparam      IDLE_STATE              = 4'b0000,
                    CALC_Y_DIR              = 4'b0001,
                    CALC_X_DIR              = 4'b0010;

    // 
    reg     [STATE_WIDTH -1: 0]             next_state, state;
    reg                                     next_select_en, select_en;
    reg     [ADDR_WIDTH -1: 0]              next_addr, addr;
    reg     [SUM_S_WIDTH -1 :0]             next_sum_s, sum_s;
    reg     [SUM_SX_WIDTH -1 :0]            next_sum_sx, sum_sx;
    reg     [SUM_SY_WIDTH -1 :0]            next_sum_sy, sum_sy;

    //
    assign  oSELECT_EN = select_en;

    // オリジナルアルゴリズム
    // CL_ROWはY方向
    // colは2づつ増える
    // DATA_Lが閾値を超えたらMEMIN_0[col  ]を1にする
    // DATA_Rが閾値を超えたらMEMIN_0[col+1]を1にする
    // MEM_SELが1のときはWEBに書き込み、0のときはWEAに書き込む
    // それ以外は
    // MEMIN_x[col  ]  DATA_L[8 - x] (x => 1 to 5)
    // MEMIN_x[col+1]  DATA_R[8 - x] (x => 1 to 5)

    DET_EDGE m_DET_FVAL_EDGE( .CLK(CCLK), .RST_N(RST_N), .iS(iFVAL), .oRISE(rise_fval), .oFALL(fall_fval) );

    // 
    // ADDRをインクリメントしY_MAX_ADDRまで加算     ∑y x Pxy
    // 
    //      ２次元配列に加算結果を保持
    // 
    // どうやって加算回路を作成するか？
    // 
    //      
    // 
    always @(*) begin
        case (state)
            IDLE_STATE: begin
                            next_addr      <= 'h0;
                            //
                            next_sum_s     <= 'h0;
                            next_sum_sx    <= 'h0;
                            next_sum_sy    <= 'h0;
                            // 
                            if (rise_fval) begin
                                next_state     <= CALC_Y_DIR;
                                // 
                                next_select_en <= 1'b1;
                            end else begin
                                next_state     <= state;
                                // 
                                next_select_en <= 1'b0;
                            end
                        end
            CALC_Y_DIR: begin
                            if (addr==MAX_Y_ADDR) begin
                                next_state     <= CALC_X_DIR;
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
                                next_select_en <= 1'b1;
                                // 
                                next_addr      <= addr + 'h1;
                                //
                                next_sum_s     <= sum_s + count_val;
                                next_sum_sx    <= sum_sx;
                                next_sum_sy    <= sum_sy;
                            end
                        end
            CALC_X_DIR: begin
                            next_state <= IDLE_STATE;
                            //
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
                            next_state <= IDLE_STATE;
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
    COUNT_HIGH_BIT #( .BIT_WIDTH(640) ) m_COUNT_HIGH_BIT ( .iBIT(iMEMIN), .oCOUNT(count_val) );


    // 
    always @(posedge CCLK or negedge RST_N) begin
        if (!RST_N) begin
            state     <= IDLE_STATE;
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
            select_en <= next_select_en;
            // 
            addr      <= next_addr;
            //
            sum_s     <= next_sum_s;
            sum_sx    <= next_sum_sx;
            sum_sy    <= next_sum_sy;
        end
    end

    // sum_s    <= 
    // sum_sx   <= 
    // sum_sy   <= 
    // sum_x_s  <= 
    // sum_x_sx <= 
    // sum_x_sy <= 

    assign  flag_l = (iDATA_L > iTHRESHOLD) ? 1'b1: 1'b0;
    assign  flag_r = (iDATA_R > iTHRESHOLD) ? 1'b1: 1'b0;

/*
    // Active High : iFVAL
    // 
    always @(*) begin
        case (state)
            IDEL_STATE: begin
                            if (rise_fval) begin
                                
                            end
                        end
            
            default:begin
                        next_state <= IDEL_STATE;
                    end
        endcase
    end


    always @(posedgde CLK or negedge RST_N) begin
        if (!RST_N) begin
            
        end else begin
            
        end
    end

    // 
    generate
        genvar                                      i;
        //
        for (i=0; i< MDATA_WIDTH; i=i+1) begin: inst_loop
            SUM_UNIT #( .FACTOR_WIDTH(i), .IDATA_WIDTH(1), .ODATA_WIDTH() ) m_SUM_UNIT(
                .CLK(CLK), .RST_N(RST_N), 
                //
                .iCLR(), .iDATA_EN(iDATA_EN), .iFACTOR(i), .iD(iMEMIN[i]), 
                //
                .oD()
            );
        end
    endgenerate
*/

endmodule
