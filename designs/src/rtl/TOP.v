// -----------------------------------------------------------------------------
//  Title         : Top module
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : TOP.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 1/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Top module for Camera Link
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale                                  1ns/1ps

module TOP #(  
    parameter   PIXEL_WIDTH             =   8,
    parameter   ADDR_WIDTH              =  10,
    parameter   PIX_HACT                = 640
) (
    input   wire                        CLK,                // 50MHz
    input   wire                        RST_N,
    //
    input   wire                        UART_RXD,
    output  wire                        UART_TXD,
    //
    input   wire                        DUMMY0,
    input   wire                        DUMMY1,
    //
    input   wire    [JP_WIDTH -1: 0]    JP,
    //
    input   wire                        CCLK,
    input   wire                        FVAL,
    input   wire                        DVAL,
    input   wire                        LVAL,
    input   wire    [PIXEL_WIDTH -1: 0] DATA_L,
    input   wire    [PIXEL_WIDTH -1: 0] DATA_R,
    //
    output  wire                        VGA_CLK,
    output  wire                        VGA_VSYNC,
    output  wire                        VGA_HSYNC,
    output  wire    [PIXEL_WIDTH -1: 0] VGA_R,
    output  wire    [PIXEL_WIDTH -1: 0] VGA_G,
    output  wire    [PIXEL_WIDTH -1: 0] VGA_B
);
    // parameter
    parameter   JP_WIDTH                = 8;

    //
    parameter   SUM_S_WIDTH             = 20;
    parameter   SUM_SX_WIDTH            = 28;
    parameter   SUM_SY_WIDTH            = 28;

    //
    parameter   DATA_WIDTH              = 8;

    // for internal signals
    wire                                cmr_vsync;
    wire                                cmr_hsync;
    wire                                cmr_de;
    
    wire    [PIXEL_WIDTH -1: 0]         cmr_data_l;
    wire    [PIXEL_WIDTH -1: 0]         cmr_data_r;

    wire                                grav_sel_en;

    wire    [ADDR_WIDTH -1: 0]          cmr_addr;

    wire    [ADDR_WIDTH -1: 0]          cl_row;

    wire    [ADDR_WIDTH -1: 0]          grav_addr;

    wire    [PIX_HACT -1: 0]            memin_0;
    wire    [PIX_HACT -1: 0]            memin_1;    // for Raw Video out
    wire    [PIX_HACT -1: 0]            memin_2;    // for Raw Video out
    wire    [PIX_HACT -1: 0]            memin_3;    // for Raw Video out
    wire    [PIX_HACT -1: 0]            memin_4;    // for Raw Video out
    wire    [PIX_HACT -1: 0]            memin_5;    // for Raw Video out

    wire    [PIX_HACT -1: 0]            memout_cx, memout_ca, memout_cb;

    wire    [PIX_HACT -1: 0]            memout_0x, memout_0a, memout_0b;
    wire    [PIX_HACT -1: 0]            memout_1x, memout_1a, memout_1b;    //  for Raw Video out
    wire    [PIX_HACT -1: 0]            memout_2x, memout_2a, memout_2b;    //  for Raw Video out
    wire    [PIX_HACT -1: 0]            memout_3x, memout_3a, memout_3b;    //  for Raw Video out
    wire    [PIX_HACT -1: 0]            memout_4x, memout_4a, memout_4b;    //  for Raw Video out
    wire    [PIX_HACT -1: 0]            memout_5x, memout_5a, memout_5b;    //  for Raw Video out
    
    wire                                mem_sel;
    wire                                mem_sel_sync_cclk;

    wire    [ADDR_WIDTH -1: 0]          vga_vcount;

    wire    [ADDR_WIDTH -1: 0]          tmg_hcount;
    wire    [ADDR_WIDTH -1: 0]          tmg_vcount;

    wire                                tmg_hsync;
    wire                                tmg_vsync;
    wire                                tmg_de;

    wire                                pixel_hsync;
    wire                                pixel_vsync;
    wire                                pixel_de;
    wire    [PIXEL_WIDTH -1: 0]         pixel_r0;
    wire    [PIXEL_WIDTH -1: 0]         pixel_g0;
    wire    [PIXEL_WIDTH -1: 0]         pixel_b0;

    wire                                out_pixel_hsync;
    wire                                out_pixel_vsync;
    wire                                out_pixel_de;
    wire    [PIXEL_WIDTH -1: 0]         out_pixel_r0;
    wire    [PIXEL_WIDTH -1: 0]         out_pixel_g0;
    wire    [PIXEL_WIDTH -1: 0]         out_pixel_b0;

    //
    wire    [SUM_S_WIDTH -1: 0]         sum_s;
    wire    [SUM_SX_WIDTH -1: 0]        sum_sx;
    wire    [SUM_SY_WIDTH -1: 0]        sum_sy;

    wire    [4 -1: 0]                   calc_state;

    //
    wire                                clk_uart_x8;

    //
    wire    [DATA_WIDTH -1: 0]          uart_data;

    // Reset Signal
    wire                                cclk_rst_n;
    wire                                vga_clk_rst_n;

    //
    wire    [PIXEL_WIDTH -1: 0]         threshold;
    wire                                vgaout_mode;


    // 
//    assign  threshold = 8'h01;
    assign  threshold = JP;
    // vgaout_mode:1=raw, 0=digitized
    assign  vgaout_mode = 1'b1;


    // Instance
    INP_CAMERA_DATA  #( .PIXEL_WIDTH(PIXEL_WIDTH) )    m_INP_CAMERA_DATA (.CLK(CCLK), .RST_N(RST_N), 
                                                .iLVAL_POL(1'b1), .iFVAL_POL(1'b1), .iDVAL_POL(1'b0), 
                                                .iLVAL(LVAL), .iFVAL(FVAL), .iDVAL(DVAL), .iDATA_L(DATA_L), .iDATA_R(DATA_R),
                                                .oVSYNC(cmr_vsync), .oHSYNC(cmr_hsync), .oDE(cmr_de), .oDATA_L(cmr_data_l), .oDATA_R(cmr_data_r)
    );


    CLctrl #( .ADDR_WIDTH(ADDR_WIDTH), .MDATA_WIDTH(640), .PIXEL_WIDTH(PIXEL_WIDTH) ) m_CLctrl ( .CCLK(CCLK), .RST_N(cclk_rst_n),
                                                .iVSYNC(cmr_vsync), .iHSYNC(cmr_hsync), .iDE(cmr_de), .iDATA_L(cmr_data_l), .iDATA_R(cmr_data_r),
                                                //
                                                .iVGAout_mode(vgaout_mode), .iMEM_SEL(mem_sel_sync_cclk), .iTHRESHOLD(threshold),
                                                .oWEA(wea), .oWEB(web), .oCL_ROW(cl_row),
                                                .oMEMIN_0(memin_0), .oMEMIN_1(memin_1), .oMEMIN_2(memin_2), 
                                                .oMEMIN_3(memin_3), .oMEMIN_4(memin_4), .oMEMIN_5(memin_5)
    );

    // Calc gravity
    CALC_GRAVITY_Y #( .ADDR_WIDTH(11), .MDATA_WIDTH(640), .MAX_Y_ADDR(480), .PIXEL_WIDTH(8) ) 
                                                m_CALC_GRAVITY_Y ( .CCLK(CCLK), .RST_N(cclk_rst_n),
                                                //
                                                .iTHRESHOLD(threshold),
                                                //
                                                .iVSYNC(cmr_vsync),
                                                .iDATA_L(cmr_data_l), .iDATA_R(cmr_data_r),
                                                // 
                                                .iDATA_EN(memout_cx_en),
                                                .iMEMIN  (memout_cx),
                                                .oADDR   (grav_addr),
                                                // 
                                                .oSELECT_EN(grav_sel_en),
                                                //
                                                .iBUSY(busy),
                                                //
                                                .oSTART_TRIG(start_trig),
                                                //
                                                .oSUM_S (sum_s ),
                                                .oSUM_SX(sum_sx),
                                                .oSUM_SY(sum_sy),
                                                // Debug
                                                .oSTATE(calc_state)
    );


    // Memory Controller
    MEMOUTSEL       #( .DATA_WIDTH(640) )   m_MEMOUTSEL0(.iMEMOUT_0A(memout_0a), .iMEMOUT_0B(memout_0b), .iMEM_SEL(mem_sel), .oMEMOUT_0X(memout_0x));
    MEMOUTSEL       #( .DATA_WIDTH(640) )   m_MEMOUTSEL1(.iMEMOUT_0A(memout_1a), .iMEMOUT_0B(memout_1b), .iMEM_SEL(mem_sel), .oMEMOUT_0X(memout_1x));
    MEMOUTSEL       #( .DATA_WIDTH(640) )   m_MEMOUTSEL2(.iMEMOUT_0A(memout_2a), .iMEMOUT_0B(memout_2b), .iMEM_SEL(mem_sel), .oMEMOUT_0X(memout_2x));
    MEMOUTSEL       #( .DATA_WIDTH(640) )   m_MEMOUTSEL3(.iMEMOUT_0A(memout_3a), .iMEMOUT_0B(memout_3b), .iMEM_SEL(mem_sel), .oMEMOUT_0X(memout_3x));
    MEMOUTSEL       #( .DATA_WIDTH(640) )   m_MEMOUTSEL4(.iMEMOUT_0A(memout_4a), .iMEMOUT_0B(memout_4b), .iMEM_SEL(mem_sel), .oMEMOUT_0X(memout_4x));
    MEMOUTSEL       #( .DATA_WIDTH(640) )   m_MEMOUTSEL5(.iMEMOUT_0A(memout_5a), .iMEMOUT_0B(memout_5b), .iMEM_SEL(mem_sel), .oMEMOUT_0X(memout_5x));
    // 
    CYCLE_DELAY #( .DATA_WIDTH(1), .DELAY(1) )  m_MEM_DATA_EN_DELAY(.CLK(CCLK), .RST_N(RST_N), .iD(grav_sel_en), .oD(memout_cx_en) );

    //
    assign  cmr_addr  = (grav_sel_en      ) ? grav_addr: cl_row;
    assign  memout_cx = (mem_sel_sync_cclk) ? memout_ca: memout_cb;

    // Dual Port SRAM‚É‚Í1 word = 1line•ª‚Ìƒf[ƒ^‚ð‘‚«ž‚Þ
    MEM m_MEMA0( .clka(CCLK   ), .addra(cmr_addr  ), .dina(memin_0), .ena(~mem_sel_sync_cclk), .wea(wea ), .douta(memout_ca),
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0), .doutb(memout_0a) );    
    MEM m_MEMB0( .clka(CCLK   ), .addra(cmr_addr  ), .dina(memin_0), .ena( mem_sel_sync_cclk), .wea(web ), .douta(memout_cb),
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0), .doutb(memout_0b) );    

    // for Raw Video out
    MEM m_MEMA1( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_1), .ena(~mem_sel_sync_cclk), .wea(wea), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0), .doutb(memout_1a) );    
    MEM m_MEMB1( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_1), .ena( mem_sel_sync_cclk), .wea(web), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0), .doutb(memout_1b) );    
    MEM m_MEMA2( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_2), .ena(~mem_sel_sync_cclk), .wea(wea), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0), .doutb(memout_2a) );    
    MEM m_MEMB2( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_2), .ena( mem_sel_sync_cclk), .wea(web), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0), .doutb(memout_2b) );    
    MEM m_MEMA3( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_3), .ena(~mem_sel_sync_cclk), .wea(wea), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0), .doutb(memout_3a) );    
    MEM m_MEMB3( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_3), .ena( mem_sel_sync_cclk), .wea(web), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0), .doutb(memout_3b) );    
    MEM m_MEMA4( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_4), .ena(~mem_sel_sync_cclk), .wea(wea), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0), .doutb(memout_4a) );    
    MEM m_MEMB4( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_4), .ena( mem_sel_sync_cclk), .wea(web), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0), .doutb(memout_4b) );    
    MEM m_MEMA5( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_5), .ena(~mem_sel_sync_cclk), .wea(wea), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0), .doutb(memout_5a) );    
    MEM m_MEMB5( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_5), .ena( mem_sel_sync_cclk), .wea(web), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0), .doutb(memout_5b) );    

    // for Meta-stable 
    CYCLE_DELAY #( .DATA_WIDTH(1), .DELAY(2) )    m_MEM_SEL_DLY2( .CLK(CCLK), .RST_N(RST_N), .iD(mem_sel), .oD(mem_sel_sync_cclk) );

    // Video Timing Controller
    TMG_CTRL #( .PARAM_WIDTH(10) ) m_TMG_CTRL ( .CLK(VGA_CLK), .RST_N(vga_clk_rst_n), 
                                   .iHTOTAL(800), .iHACT(640), .iHS_WIDTH(96), .iHS_BP(48), .iHS_POL(1'b1),
                                   .iVTOTAL(525), .iVACT(480), .iVS_WIDTH( 2), .iVS_BP(33), .iVS_POL(1'b1),
                                   .oHSYNC(tmg_hsync), .oVSYNC(tmg_vsync), .oDE(tmg_de), .oFIELD(mem_sel), 
                                   .oHCOUNT(tmg_hcount), .oVCOUNT(tmg_vcount)
    );

    //
    VGAout #( .PARAM_WIDTH(10), .ADDR_WIDTH(ADDR_WIDTH), .HACTIVE(640), .VACTIVE(480), .PIXEL_WIDTH(PIXEL_WIDTH) ) m_VGAout (
                                    .VCLK(VGA_CLK), .RST_N(RST_N),
                                    .iVSYNC(tmg_vsync), .iHSYNC(tmg_hsync), .iDE(tmg_de),
                                    .iH_ADDR(tmg_hcount), .iV_ADDR(tmg_vcount),
                                    //
                                    .iMEMOUT_0(memout_0x), .iMEMOUT_1(memout_1x), .iMEMOUT_2(memout_2x),
                                    .iMEMOUT_3(memout_3x), .iMEMOUT_4(memout_4x), .iMEMOUT_5(memout_5x),
                                    //
                                    .iVGAout_mode(vgaout_mode),
                                    // iVGAout_mode:1=raw, 0=digitized
                                    //
                                    //
                                    .iPOINT_X('h100), .iPOINT_Y('h100),
                                    //
                                    .oVGA_HSYNC(pixel_hsync), .oVGA_VSYNC(pixel_vsync), .oVGA_DE(pixel_de),
                                    .oVGA_R(pixel_r0), .oVGA_G(pixel_g0), .oVGA_B(pixel_b0)
    );

    // for high fanout issue
    CYCLE_DELAY #( .DATA_WIDTH(1), .DELAY(1) )    m_PIXEL_HSYNC_DLY ( .CLK(VCLK), .RST_N(RST_N), .iD(pixel_hsync), .oD(out_pixel_hsync) );
    CYCLE_DELAY #( .DATA_WIDTH(1), .DELAY(1) )    m_PIXEL_VSYNC_DLY ( .CLK(VCLK), .RST_N(RST_N), .iD(pixel_vsync), .oD(out_pixel_vsync) );
    CYCLE_DELAY #( .DATA_WIDTH(1), .DELAY(1) )    m_PIXEL_DE_DLY    ( .CLK(VCLK), .RST_N(RST_N), .iD(pixel_de   ), .oD(out_pixel_de   ) );
    CYCLE_DELAY #( .DATA_WIDTH(8), .DELAY(1) )    m_PIXEL_VGA_R_DLY ( .CLK(VCLK), .RST_N(RST_N), .iD(pixel_r0   ), .oD(out_pixel_r0   ) );
    CYCLE_DELAY #( .DATA_WIDTH(8), .DELAY(1) )    m_PIXEL_VGA_G_DLY ( .CLK(VCLK), .RST_N(RST_N), .iD(pixel_g0   ), .oD(out_pixel_g0   ) );
    CYCLE_DELAY #( .DATA_WIDTH(8), .DELAY(1) )    m_PIXEL_VGA_B_DLY ( .CLK(VCLK), .RST_N(RST_N), .iD(pixel_b0   ), .oD(out_pixel_b0   ) );

    //
    OUT_VIDEO_DATA #( .PIXEL_WIDTH(PIXEL_WIDTH) ) m_OUT_VIDEO_DATA(.CLK(VGA_CLK), .RST_N(RST_N), 
                                     .iVSYNC_POL(1'b1), .iHSYNC_POL(1'b1),
                                     .iVSYNC(pixel_vsync), .iHSYNC(pixel_hsync), .iDE(pixel_de), .iR0(pixel_r0), .iG0(pixel_g0), .iB0(pixel_b0),
                                     .oVSYNC(VGA_VSYNC), .oHSYNC(VGA_HSYNC), .oDE(), .oR0(VGA_R), .oG0(VGA_G), .oB0(VGA_B)
    );

    // Clock Control
    CLK25M  m_CLK25M ( .CLK(CLK), .RST_N(RST_N), .CLKOUT(VGA_CLK) );

    //            =>       x8  / 50MHz / 27 
    // 230400 bps => 1843.2KHz / 1801.851KHz
    CLK_DIVIDER #( .DIVIDE(27) )    m_CLK_UART( .CLK(CLK), .RST_N(RST_N), .oDIV_CLK(clk_uart_x8) );

    // Reset Control
    ASYNC_SYNC_RST  m_CCLK_RST_N    ( .CLK(CCLK   ), .RST_N(RST_N), .SYNC_RST_N(cclk_rst_n   ) );
    ASYNC_SYNC_RST  m_VGA_CLK_RST_N ( .CLK(VGA_CLK), .RST_N(RST_N), .SYNC_RST_N(vga_clk_rst_n) );

    // UART (temporal)
    UART_TX_CORE #( .OVER_SAMPLING(16) )    m_UART_TX_CORE( .CLK(clk_uart_x8), .RST_N(RST_N), 
                .iSEVEN_BIT(1'b1),         // Low = 8bit,        High = 7bit
                .iPARITY_EN(1'b0),         // Low = Non Parity,  High = Parity Enable
                .iODD_PARITY(1'b0),        // Low = Even Parity, High = Odd Parity
                .iSTOP_BIT(1'b0),          // Low = 1bit,        High = 2bit
                //
                .iDE(uart_de),
                .iDATA(uart_data),
                //
                .oUART_TX_BUSY(tx_busy),
                .oUART_TX(UART_TXD)
    );

    UART_RX_CORE #( .OVER_SAMPLING(8) )    m_UART_RX_CORE ( .CLK(clk_uart_x8), .RST_N(RST_N),
                .iSEVEN_BIT(1'b1),         // Low = 8bit,        High = 7bit
                .iPARITY_EN(1'b0),         // Low = Non Parity,  High = Parity Enable
                .iODD_PARITY(1'b0),        // Low = Even Parity, High = Odd Parity
                .iSTOP_BIT(1'b0),          // Low = 1bit,        High = 2bit
                //
                .iUART_RX(UART_RXD),
                //
                .oRETRY(),
                .oPARITY_ERROR(),
                //
                .oDE(),
                .oDATA()
    );

    UART_IF m_UART_IF( .CLK(clk_uart_x8), .RST_N(RST_N),
                .iSUM_S (sum_s ),
                .iSUM_SX(sum_sy),
                .iSUM_SY(sum_sx),
                //
                .iTRIG(start_trig),
                //
                .iUART_TX_BUSY(tx_busy),
                //
                .oBUSY(busy),
                //
                .oDE(uart_de),
                .oDATA(uart_data)
    );


    // DUMMY pin
    DFF #( .DATA_WIDTH(1) ) m_DUMMY0( .CLK(CLK), .RST_N(RST_N), .iD(DUMMY0), .oD() );
    DFF #( .DATA_WIDTH(1) ) m_DUMMY1( .CLK(CLK), .RST_N(RST_N), .iD(DUMMY1), .oD() );

    // ILA

    ILA m_ILA(
        .clk(VGA_CLK),
        //
        .probe0(FVAL),
        .probe1(LVAL),
        .probe2(DVAL),
        .probe3(DATA_L),
        .probe4(DATA_R),
        .probe5(pixel_vsync),
        .probe6(pixel_hsync),
        .probe7(pixel_de),
        .probe8(cmr_vsync),
        .probe9(cmr_hsync),
        .probe10(cmr_de),
        .probe11(memout_cx_en),
        .probe12(grav_sel_en),
        .probe13(busy),
        .probe14(UART_TXD),
        .probe15(calc_state),
        .probe16(VGA_VSYNC),
        .probe17(VGA_HSYNC),
        .probe18(VGA_R),
        .probe19(clk_uart_x8),
        .probe20(start_trig),
        .probe21(uart_de),
        .probe22(uart_data),
        .probe23(tx_busy) /*,*/
//        .probe24(sum_s),
//        .probe25(sum_sy)
    );


endmodule
