// -----------------------------------------------------------------------------
//  Title         : VGAout
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : VGAout.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 1/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Modified this file from original VGAout to improve readability.
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module VGAout #(
    parameter   PARAM_WIDTH = 10,
    parameter   ADDR_WIDTH  = 11,
    parameter   HACTIVE     = 640,
    parameter   VACTIVE     = 480,
    parameter   PIXEL_WIDTH = 8
) (
    // 
    input   wire                            VCLK,
    input   wire                            RST_N,
    //
    input   wire                            iVSYNC,
    input   wire                            iHSYNC,
    input   wire                            iDE,
    //
    input   wire    [ADDR_WIDTH -1: 0]      iH_ADDR,
    input   wire    [ADDR_WIDTH -1: 0]      iV_ADDR,
    //
    input   wire    [HACTIVE -1: 0]         iMEMOUT_0,
    input   wire    [HACTIVE -1: 0]         iMEMOUT_1,  // for VGA out
    input   wire    [HACTIVE -1: 0]         iMEMOUT_2,  // for VGA out
    input   wire    [HACTIVE -1: 0]         iMEMOUT_3,  // for VGA out
    input   wire    [HACTIVE -1: 0]         iMEMOUT_4,  // for VGA out
    input   wire    [HACTIVE -1: 0]         iMEMOUT_5,  // for VGA out
    //
    input   wire                            iVGAout_mode,
    //
    input   wire    [ADDR_WIDTH -1: 0]      iPOINT_X,
    input   wire    [ADDR_WIDTH -1: 0]      iPOINT_Y,
    //
    output  wire                            oVGA_HSYNC,
    output  wire                            oVGA_VSYNC,
    output  wire                            oVGA_DE,
    //
    output  reg     [PIXEL_WIDTH -1: 0]     oVGA_R,
    output  reg     [PIXEL_WIDTH -1: 0]     oVGA_G,
    output  reg     [PIXEL_WIDTH -1: 0]     oVGA_B
);

    wire                                    sel_memout_0;
    wire                                    sel_memout_1;
    wire                                    sel_memout_2;
    wire                                    sel_memout_3;
    wire                                    sel_memout_4;
    wire                                    sel_memout_5;
    wire    [PIXEL_WIDTH -1: 0]             mem_dat;

    wire                                    video_exist;
    wire                                    edge_area_en;
    wire                                    h_area_en;
    wire                                    v_area_en;
    // 
    reg                                     video_load_en;

    genvar                                  i;

    // 
    assign sel_memout_0 = iMEMOUT_0[iH_ADDR];
    assign sel_memout_1 = iMEMOUT_1[iH_ADDR];
    assign sel_memout_2 = iMEMOUT_2[iH_ADDR];
    assign sel_memout_3 = iMEMOUT_3[iH_ADDR];
    assign sel_memout_4 = iMEMOUT_4[iH_ADDR];
    assign sel_memout_5 = iMEMOUT_5[iH_ADDR];

    assign  mem_dat = (iVGAout_mode==1'b0) ? {sel_memout_0, sel_memout_0, 6'b000000}: {sel_memout_1, sel_memout_2, sel_memout_3, sel_memout_4, sel_memout_5, 3'b000};

    //
    CYCLE_DELAY #( .DATA_WIDTH(1), .DELAY(1) ) m_CYCLE_DELAY_HSYNC( .CLK(VCLK), .RST_N(RST_N), .iD(iHSYNC), .oD(oVGA_HSYNC) );
    CYCLE_DELAY #( .DATA_WIDTH(1), .DELAY(1) ) m_CYCLE_DELAY_VSYNC( .CLK(VCLK), .RST_N(RST_N), .iD(iVSYNC), .oD(oVGA_VSYNC) );
    CYCLE_DELAY #( .DATA_WIDTH(1), .DELAY(1) ) m_CYCLE_DELAY_DE   ( .CLK(VCLK), .RST_N(RST_N), .iD(iDE   ), .oD(oVGA_DE   ) );

    // ------------------------------------------------------------------------------------------------------
    // Dual Port SRAMに座標情報を元にリードアドレスを与えデータを条件に合わせて加工、VGAデータとして出力する
    // ------------------------------------------------------------------------------------------------------
    // データ有効期間中か？
    // [Y]
    //      MEMOUT_0[HDadr]データが存在するか
    //      [Y]
    //          ポジションはエッジ部分か？
    //          [Y]
    //              黒を出力
    //          ポジションは設定した場所か? (設定ポイントからx, y共に±1か？)
    //          [Y]
    //              黒を出力
    //          ポジションは設定した場所か? (かつ設定ポイントからxは±1か？)
    //          [Y]
    //              RGB = MEMdat[HDadr]を出力
    //          [N]
    //              RGB = MEMdat[HDadr]を出力
    //      [N] (カメラデータからの信号が黒)
    //          ポジションはエッジ部分か？
    //          [Y]
    //              RGB = MEMdat[HDadr]を出力
    //          ポジションは設定した場所か? (設定ポイントからx, y共に±1か？)
    //          [Y]
    //              RGB = MEMdat[HDadr]を出力
    //          ポジションは設定した場所か? (かつ設定ポイントからxは±1か？)
    //          [Y]
    //              黒を出力
    //          [N]
    //              黒を出力
    // [N]
    //      黒を出力
    // 

    assign  video_exist  = | iMEMOUT_0[iH_ADDR];
    assign  edge_area_en = (iH_ADDR == 'h0) | (iH_ADDR == (HACTIVE - 'h1)) | (iV_ADDR == 'h0) | ( iV_ADDR == (VACTIVE - 'h1));
    assign  h_area_en    = (iH_ADDR == iPOINT_X - 'h1) | (iH_ADDR == iPOINT_X      ) | (iH_ADDR == iPOINT_X + 'h1);
    assign  v_area_en    = (iV_ADDR == iPOINT_Y - 'h1) | (iV_ADDR == iPOINT_Y      ) | (iV_ADDR == iPOINT_Y + 'h1);

    // 
    always @(*) begin
        casex ({iDE, video_exist, edge_area_en, h_area_en, v_area_en})
            // iDE => High
                // EXIST_VIDEO => Yes
                    // Location => Edge or iPOINT_X/iPOINT_Y ≦ ±1
                    'b1_1_1_xx, // 
                    'b1_1_0_11: // 
                        video_load_en <= 1'b0;
                    'b1_1_0_00, // 
                    'b1_1_0_01, // 
                    'b1_1_0_10: // 
                        video_load_en <= 1'b1;
                // EXIST_VIDEO => No
                    // Location => Edge or iPOINT_X/iPOINT_Y ≦ ±1
                    'b1_0_1_xx, // 
                    'b1_0_0_11: // 
                        video_load_en <= 1'b1;
                    'b1_0_0_00, // 
                    'b1_0_0_01, // 
                    'b1_0_0_10: // 
                        video_load_en <= 1'b0;
            // iDE => Low
            'b0_x_x_:
                video_load_en <= 1'b0;
        endcase
    end

    // 
    always @(posedge VCLK or negedge RST_N) begin
        if (!RST_N) begin
            oVGA_R <= 'h0;
            oVGA_G <= 'h0;
            oVGA_B <= 'h0;
        end else if (video_load_en) begin
            oVGA_R <= mem_dat;
            oVGA_G <= mem_dat;
            oVGA_B <= mem_dat;
        end else begin
            oVGA_R <= 'h0;
            oVGA_G <= 'h0;
            oVGA_B <= 'h0;
        end
    end

endmodule
