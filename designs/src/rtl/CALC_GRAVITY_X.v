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

module CALC_GRAVITY_X #(
    parameter   ADDR_WIDTH  = 11,
    parameter   MDATA_WIDTH = 640,
    parameter   PIXEL_WIDTH = 8
) (
    // 
    input   wire                            CCLK,
    input   wire                            RST_N,
    //
    input   wire                            iFVAL,
    input   wire                            iDVAL,
    input   wire                            iLVAL,
    input   wire    [PIXEL_WIDTH -1: 0]     iDATA_L,
    input   wire    [PIXEL_WIDTH -1: 0]     iDATA_R,
    //
    input   wire                            iVGAout_mode,
    input   wire    [PIXEL_WIDTH -1: 0]     iTHRESHOLD,
    //
    output  reg                             oWEA,
    output  reg                             oWEB,
    output  wire    [ADDR_WIDTH -1: 0]      oCL_ROW,
    output  reg     [MDATA_WIDTH -1: 0]     oMEMIN_0,
    output  reg     [MDATA_WIDTH -1: 0]     oMEMIN_1,   // for Row VGA out
    output  reg     [MDATA_WIDTH -1: 0]     oMEMIN_2,   // for Row VGA out
    output  reg     [MDATA_WIDTH -1: 0]     oMEMIN_3,   // for Row VGA out
    output  reg     [MDATA_WIDTH -1: 0]     oMEMIN_4,   // for Row VGA out
    output  reg     [MDATA_WIDTH -1: 0]     oMEMIN_5    // for Row VGA out
);

    // 
    localparam      IDLE_STATE              

    // 
    reg     [ADDR_WIDTH -1: 0]              next_col, col;
    reg     [ADDR_WIDTH -1: 0]              next_row, row;
    //
    wire                                    flag_l, flag_r;


    // オリジナルアルゴリズム
    // CL_ROWはY方向
    // colは2づつ増える
    // DATA_Lが閾値を超えたらMEMIN_0[col  ]を1にする
    // DATA_Rが閾値を超えたらMEMIN_0[col+1]を1にする
    // MEM_SELが1のときはWEBに書き込み、0のときはWEAに書き込む
    // それ以外は
    // MEMIN_x[col  ]  DATA_L[8 - x] (x => 1 to 5)
    // MEMIN_x[col+1]  DATA_R[8 - x] (x => 1 to 5)

    DET_EDGE m_DET_DVAL_EDGE( .CLK(CCLK), .RST_N(RST_N), .iS(iDVAL), .oRISE(rise_dval), .oFALL(fall_dval) );
    DET_EDGE m_DET_FVAL_EDGE( .CLK(CCLK), .RST_N(RST_N), .iS(iFVAL), .oRISE(rise_fval), .oFALL(fall_fval) );

    // 
    always @(*) begin
        if (rise_fval) begin
            next_col <= 'h0;
            next_row <= 'h0;
        end else if (rise_dval) begin
            next_col <= 'h0;
            next_row <= row;
        end else if (fall_dval) begin
            next_col <= 'h0;
            next_row <= row + 'h1;
        end else if (iDVAL) begin
            next_col <= col + 'h2;
            next_row <= row;
        end else begin
            next_col <= col;
            next_row <= row;
        end
    end

    // 
    always @(posedge CCLK or negedge RST_N) begin
        if (!RST_N) begin
            col <= 'h0;
            row <= 'h0;
        end else begin
            col <= next_col;
            row <= next_row;
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

endmodule
