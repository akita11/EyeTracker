// -----------------------------------------------------------------------------
//  Title         : Camera Link control module
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : CLctrl.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 1/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Modified this file from original CLctrl to improve readability.
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module CLctrl #(
    parameter   ADDR_WIDTH  = 11,
    parameter   MDATA_WIDTH = 640,
    parameter   PIXEL_WIDTH = 8
) (
    // 
    input   wire                            CCLK,
    input   wire                            RST_N,
    //
    input   wire                            iVSYNC,
    input   wire                            iHSYNC,
    input   wire                            iDE,
    input   wire    [PIXEL_WIDTH -1: 0]     iDATA_L,
    input   wire    [PIXEL_WIDTH -1: 0]     iDATA_R,
    //
    input   wire                            iVGAout_mode,
    input   wire                            iMEM_SEL,
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
    output  reg     [MDATA_WIDTH -1: 0]     oMEMIN_5,   // for Row VGA out
    output  wire    [ADDR_WIDTH -1: 0]      oHSIZE,
    output  wire    [ADDR_WIDTH -1: 0]      oVSIZE
);

    //
    reg                                     next_state, state;

    // 
    reg     [ADDR_WIDTH -1: 0]              next_col, col;
    reg     [ADDR_WIDTH -1: 0]              next_row, row;
    reg     [ADDR_WIDTH -1: 0]              next_hsize, hsize;
    reg     [ADDR_WIDTH -1: 0]              next_vsize, vsize;

    // 
    reg     [ADDR_WIDTH -1: 0]              next_calc_row, calc_row;

    // 
    integer                                 i;

    //
//    assign  oCL_ROW = (flag_calc_sum==1'b1) ? calc_row: row;
    assign  oCL_ROW = row;

    assign  oHSIZE = hsize;
    assign  oVSIZE = vsize;

    // オリジナルアルゴリズム
    // CL_ROWはY方向
    // colは2づつ増える
    // DATA_Lが閾値を超えたらMEMIN_0[col  ]を1にする←間違い。DATA_Lが閾値を下回ったらMEMIN_0[col  ]を1にする。それ以外は0にする
    // DATA_Rが閾値を超えたらMEMIN_0[col+1]を1にする←間違い。DATA_Rが閾値を下回ったらMEMIN_0[col+1]を1にする。それ以外は0にする
    // MEM_SELが1のときはWEBに書き込み、0のときはWEAに書き込む
    // それ以外は
    // MEMIN_x[col  ]  DATA_L[8 - x] (x => 1 to 5)
    // MEMIN_x[col+1]  DATA_R[8 - x] (x => 1 to 5)

    DET_EDGE m_DET_DVAL_EDGE( .CLK(CCLK), .RST_N(RST_N), .iS(iDE   ), .oRISE(rise_de   ), .oFALL(fall_de   ) );
    DET_EDGE m_DET_FVAL_EDGE( .CLK(CCLK), .RST_N(RST_N), .iS(iVSYNC), .oRISE(rise_vsync), .oFALL(fall_vsync) );

    // for Write Access
    always @(*) begin
        if (rise_vsync) begin
            next_col   <= 'h0;
            next_row   <= 'h0;
            //
            next_hsize <= hsize;
            next_vsize <= row;
        end else if (rise_de) begin
            next_col <= 'h0;
            next_row <= row;
            //
            next_hsize <= hsize;
            next_vsize <= vsize;
        end else if (fall_de) begin
            next_col <= 'h0;
            next_row <= row + 'h1;
            //
            next_hsize <= col;
            next_vsize <= vsize;
        end else if (iDE) begin
            next_col <= col + 'h2;
            next_row <= row;
            //
            next_hsize <= hsize;
            next_vsize <= vsize;
        end else begin
            next_col <= col;
            next_row <= row;
            //
            next_hsize <= hsize;
            next_vsize <= vsize;
        end
    end

    // for Write Access
    always @(posedge CCLK or negedge RST_N) begin
        if (!RST_N) begin
            col   <= 'h0;
            row   <= 'h0;
            //
            hsize <= 'h0;
            vsize <= 'h0;
        end else begin
            col   <= next_col;
            row   <= next_row;
            //
            hsize <= next_hsize;
            vsize <= next_vsize;
        end
    end

    //
    always @(posedge CCLK or negedge RST_N) begin
        if (!RST_N) begin
            oMEMIN_0 <= 'h0;
        end else begin
            for (i=0; i<MDATA_WIDTH;i=i+2) begin
                if (col == i) begin
                    oMEMIN_0[i  ] <= (iDATA_L<iTHRESHOLD) ? iDE: 1'b0; // flag=1 for dark pixel and when iDE = high
                    oMEMIN_0[i+1] <= (iDATA_R<iTHRESHOLD) ? iDE: 1'b0; // flag=1 for dark pixel and when iDE = high
                end else begin
                    oMEMIN_0[i  ] <= oMEMIN_0[i  ];
                    oMEMIN_0[i+1] <= oMEMIN_0[i+1];
                end
            end
        end
    end

    //
    always @(posedge CCLK or negedge RST_N) begin
        if (!RST_N) begin
            oMEMIN_1 <= 'h0;
            oMEMIN_2 <= 'h0;
            oMEMIN_3 <= 'h0;
            oMEMIN_4 <= 'h0;
            oMEMIN_5 <= 'h0;
        end else begin
            for (i=0; i<MDATA_WIDTH; i=i+2) begin
                if (col == i) begin
                    oMEMIN_1[i  ] <= iDATA_L[7];
                    oMEMIN_1[i+1] <= iDATA_R[7];
                    oMEMIN_2[i  ] <= iDATA_L[6];
                    oMEMIN_2[i+1] <= iDATA_R[6];
                    oMEMIN_3[i  ] <= iDATA_L[5];
                    oMEMIN_3[i+1] <= iDATA_R[5];
                    oMEMIN_4[i  ] <= iDATA_L[4];
                    oMEMIN_4[i+1] <= iDATA_R[4];
                    oMEMIN_5[i  ] <= iDATA_L[3];
                    oMEMIN_5[i+1] <= iDATA_R[3];
                end else begin
                    oMEMIN_1[i  ] <= oMEMIN_1[i  ]; // for Row VGA out
                    oMEMIN_1[i+1] <= oMEMIN_1[i+1]; // for Row VGA out
                    oMEMIN_2[i  ] <= oMEMIN_2[i  ]; // for Row VGA out
                    oMEMIN_2[i+1] <= oMEMIN_2[i+1]; // for Row VGA out
                    oMEMIN_3[i  ] <= oMEMIN_3[i  ]; // for Row VGA out
                    oMEMIN_3[i+1] <= oMEMIN_3[i+1]; // for Row VGA out
                    oMEMIN_4[i  ] <= oMEMIN_4[i  ]; // for Row VGA out
                    oMEMIN_4[i+1] <= oMEMIN_4[i+1]; // for Row VGA out
                    oMEMIN_5[i  ] <= oMEMIN_5[i  ]; // for Row VGA out
                    oMEMIN_5[i+1] <= oMEMIN_5[i+1]; // for Row VGA out
                end
            end
        end
    end

    //
    always @(posedge CCLK or negedge RST_N) begin
        if (!RST_N) begin
            oWEA <= 1'b0;
            oWEB <= 1'b0;
        end else if (iMEM_SEL) begin
            oWEA <= 1'b0;
            oWEB <= 1'b1 & iDE;
        end else begin
            oWEA <= 1'b1 & iDE;
            oWEB <= 1'b0;
        end
    end

endmodule
