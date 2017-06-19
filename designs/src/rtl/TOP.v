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
    parameter   HOST_ADDR_WIDTH         = 16;
    parameter   HOST_WE_WIDTH           = 24;
    parameter   HOST_RE_WIDTH           = 24;

    //
    parameter   MAX_BUF_SIZE            = 16;

    //
    parameter   DATA_WIDTH              = 8;

    // for internal signals
    wire                                cmr_vsync;
    wire                                cmr_hsync;
    wire                                cmr_de;
    wire                                cmr_field;
    
    wire    [PIXEL_WIDTH -1: 0]         cmr_data_l;
    wire    [PIXEL_WIDTH -1: 0]         cmr_data_r;

    wire                                grav_sel_en;

    wire    [ADDR_WIDTH -1: 0]          cmr_addr;
    wire                                cmr_wea;
    wire                                cmr_web;

    wire    [ADDR_WIDTH -1: 0]          cmr_hsize;
    wire    [ADDR_WIDTH -1: 0]          cmr_vsize;

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

    //
    wire    [SUM_S_WIDTH -1: 0]         sum_s;
    wire    [SUM_SX_WIDTH -1: 0]        sum_sx;
    wire    [SUM_SY_WIDTH -1: 0]        sum_sy;
    wire    [SUM_SX_WIDTH -1: 0]        quotient_sx;
    wire    [SUM_SY_WIDTH -1: 0]        quotient_sy;

    wire                                start_trig;
    wire                                start_q_trig;
    wire                                uart_start_trig;

    wire                                out_sel;

    wire    [4 -1: 0]                   calc_state;

    //
    wire                                clk_uart_x8;

    //
    wire    [DATA_WIDTH -1: 0]          uart_inp_data;
    wire    [DATA_WIDTH -1: 0]          uart_out_data;
    wire    [DATA_WIDTH -1: 0]          uart_calc_data;
    wire    [DATA_WIDTH -1: 0]          uart_host_data;

    //
    wire    [HOST_ADDR_WIDTH -1: 0]     host_if_addr;
    wire                                host_if_we;
    wire                                host_if_re;
    wire    [DATA_WIDTH -1: 0]          host_if_wdata;
    wire    [DATA_WIDTH -1: 0]          host_if_rdata;

    //
    wire    [HOST_WE_WIDTH -1: 0]       host_we_bit;
    wire    [HOST_RE_WIDTH -1: 0]       host_re_bit;
    wire    [DATA_WIDTH -1: 0]          host_if_wd;
    wire    [DATA_WIDTH -1: 0]          host_if_rd;

    //
    wire    [DATA_WIDTH -1: 0]          eye_reg_rd;

    //
    wire    [MAX_BUF_SIZE * 8 -1: 0]    uart_rx_fifo;

    // Reset Signal
    wire                                cclk_rst_n;
    wire                                vga_clk_rst_n;

    //
    wire    [PIXEL_WIDTH -1: 0]         threshold;
    wire                                vgaout_mode;


    // 
//    assign  threshold = 8'h01;
//    assign  threshold = JP;
    // vgaout_mode:1=raw, 0=digitized


    // Instance
    INP_CAMERA_DATA  #( .PIXEL_WIDTH(PIXEL_WIDTH) )    m_INP_CAMERA_DATA (.CLK(CCLK), .RST_N(RST_N), 
                                                .iLVAL_POL(1'b1), .iFVAL_POL(1'b1), .iDVAL_POL(1'b0), 
                                                .iLVAL(LVAL), .iFVAL(FVAL), .iDVAL(DVAL), .iDATA_L(DATA_L), .iDATA_R(DATA_R),
                                                .oVSYNC(cmr_vsync), .oHSYNC(cmr_hsync), .oDE(cmr_de), .oFIELD(cmr_field), 
                                                .oDATA_L(cmr_data_l), .oDATA_R(cmr_data_r)
    );


    CLctrl #( .ADDR_WIDTH(ADDR_WIDTH), .MDATA_WIDTH(640), .PIXEL_WIDTH(PIXEL_WIDTH) ) m_CLctrl ( .CCLK(CCLK), .RST_N(cclk_rst_n),
                                                .iVSYNC(cmr_vsync), .iHSYNC(cmr_hsync), .iDE(cmr_de), .iDATA_L(cmr_data_l), .iDATA_R(cmr_data_r),
                                                //
                                                .iVGAout_mode(vgaout_mode), .iMEM_SEL(cmr_field), .iTHRESHOLD(threshold),
                                                .oWEA(wea), .oWEB(web), .oCL_ROW(cl_row),
                                                .oMEMIN_0(memin_0), .oMEMIN_1(memin_1), .oMEMIN_2(memin_2), 
                                                .oMEMIN_3(memin_3), .oMEMIN_4(memin_4), .oMEMIN_5(memin_5), 
                                                .oHSIZE(cmr_hsize), .oVSIZE(cmr_vsize)
    );

    // Calc gravity
    CALC_GRAVITY_Y #( .ADDR_WIDTH(ADDR_WIDTH), .MDATA_WIDTH(640), .MAX_Y_ADDR(480), .PIXEL_WIDTH(8) ) 
                                                m_CALC_GRAVITY_Y ( .CCLK(CCLK), .RST_N(cclk_rst_n),
                                                //
                                                .iVSYNC(cmr_vsync),
                                                //
                                                .iHSIZE(cmr_hsize),
                                                .iVSIZE(cmr_vsize),
                                                // 
                                                .iDATA_EN(memout_cx_en),
                                                .iMEMIN  (memout_cx),
                                                .oADDR   (grav_addr),
                                                // 
                                                .oSELECT_EN(grav_sel_en),
                                                //
                                                .iBUSY(uart_calc_busy),
                                                //
                                                .oSTART_TRIG  (start_trig  ),
                                                .oSTART_Q_TRIG(start_q_trig),
                                                //
                                                .oSUM_S (sum_s ),
                                                .oSUM_SX(sum_sx),
                                                .oSUM_SY(sum_sy),
                                                .oQUOTIENT_SX(quotient_sx),
                                                .oQUOTIENT_SY(quotient_sy),
                                                // Debug
                                                .oSTATE(calc_state)
    );


    // Memory Controller
    MEMOUTSEL       #( .DATA_WIDTH(640) )   m_MEMOUTSEL0(.iMEMOUT_0A(memout_0a), .iMEMOUT_0B(memout_0b), .iMEM_SEL(mem_sel), .oMEMOUT_0X(memout_0x));
    MEMOUTSEL       #( .DATA_WIDTH(640) )   m_MEMOUTSEL1(.iMEMOUT_0A(memout_1a), .iMEMOUT_0B(memout_1b), .iMEM_SEL(mem_sel), .oMEMOUT_0X(memout_1x));
    MEMOUTSEL       #( .DATA_WIDTH(640) )   m_MEMOUTSEL2(.iMEMOUT_0A(memout_2a), .iMEMOUT_0B(memout_2b), .iMEM_SEL(mem_sel), .oMEMOUT_0X(memout_2x));
    MEMOUTSEL       #( .DATA_WIDTH(640) )   m_MEMOUTSEL3(.iMEMOUT_0A(memout_3a), .iMEMOUT_0B(memout_3b), .iMEM_SEL(mem_sel), .oMEMOUT_0X(memout_3x));
    MEMOUTSEL       #( .DATA_WIDTH(640) )   m_MEMOUTSEL4(.iMEMOUT_0A(memout_4a), .iMEMOUT_0B(memout_4b), .iMEM_SEL(mem_sel), .oMEMOUT_0X(memout_4x));
    MEMOUTSEL       #( .DATA_WIDTH(640) )   m_MEMOUTSEL5(.iMEMOUT_0A('h0      ), .iMEMOUT_0B('h0      ), .iMEM_SEL(mem_sel), .oMEMOUT_0X(memout_5x));
//    MEMOUTSEL       #( .DATA_WIDTH(640) )   m_MEMOUTSEL5(.iMEMOUT_0A(memout_5a), .iMEMOUT_0B(memout_5b), .iMEM_SEL(mem_sel), .oMEMOUT_0X(memout_5x));
    // 
    CYCLE_DELAY #( .DATA_WIDTH(1), .DELAY(1) )  m_MEM_DATA_EN_DELAY(.CLK(CCLK), .RST_N(RST_N), .iD(grav_sel_en), .oD(memout_cx_en) );

    //
    assign  cmr_addr  = (grav_sel_en      ) ? grav_addr: cl_row;
    assign  cmr_wea   = (grav_sel_en      ) ? 1'b0     : wea;
    assign  cmr_web   = (grav_sel_en      ) ? 1'b0     : web;
    assign  memout_cx = (cmr_field==1'b0  ) ? memout_ca: memout_cb;

    // Dual Port SRAMには1 word = 1line分のデータを書き込む for GRAV_CALC
    MEM m_MEMCA( .clka(CCLK   ), .addra(cmr_addr  ), .dina(memin_0), .ena(~cmr_field        ), .wea(cmr_wea), .douta(memout_ca),
                 .clkb(1'b0   ), .addrb('h0       ), .dinb('h0    ), .enb(1'b0              ), .web(1'b0   ), .doutb(         ) );    
    MEM m_MEMCB( .clka(CCLK   ), .addra(cmr_addr  ), .dina(memin_0), .ena( cmr_field        ), .wea(cmr_web), .douta(memout_cb),
                 .clkb(1'b0   ), .addrb('h0       ), .dinb('h0    ), .enb(1'b0              ), .web(1'b0   ), .doutb(         ) );    

    // Dual Port SRAMには1 word = 1line分のデータを書き込む
    MEM m_MEMA0( .clka(CCLK   ), .addra(cmr_addr  ), .dina(memin_0), .ena(~cmr_field        ), .wea(cmr_wea), .douta(         ),
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0   ), .doutb(memout_0a) );    
    MEM m_MEMB0( .clka(CCLK   ), .addra(cmr_addr  ), .dina(memin_0), .ena( cmr_field        ), .wea(cmr_web), .douta(         ),
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0   ), .doutb(memout_0b) );    

    // for Raw Video out
    MEM m_MEMA1( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_1), .ena(~cmr_field        ), .wea(cmr_wea), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0   ), .doutb(memout_1a) );    
    MEM m_MEMB1( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_1), .ena( cmr_field        ), .wea(cmr_web), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0   ), .doutb(memout_1b) );    
    MEM m_MEMA2( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_2), .ena(~cmr_field        ), .wea(cmr_wea), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0   ), .doutb(memout_2a) );    
    MEM m_MEMB2( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_2), .ena( cmr_field        ), .wea(cmr_web), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0   ), .doutb(memout_2b) );    
    MEM m_MEMA3( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_3), .ena(~cmr_field        ), .wea(cmr_wea), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0   ), .doutb(memout_3a) );    
    MEM m_MEMB3( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_3), .ena( cmr_field        ), .wea(cmr_web), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0   ), .doutb(memout_3b) );    
    MEM m_MEMA4( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_4), .ena(~cmr_field        ), .wea(cmr_wea), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0   ), .doutb(memout_4a) );    
    MEM m_MEMB4( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_4), .ena( cmr_field        ), .wea(cmr_web), 
                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0   ), .doutb(memout_4b) );    
//    MEM m_MEMA5( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_5), .ena(~cmr_field        ), .wea(cmr_wea), 
//                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0   ), .doutb(memout_5a) );    
//    MEM m_MEMB5( .clka(CCLK   ), .addra(cl_row    ), .dina(memin_5), .ena( cmr_field        ), .wea(cmr_web), 
//                 .clkb(VGA_CLK), .addrb(tmg_vcount), .dinb('h0    ), .enb(1'b1              ), .web(1'b0   ), .doutb(memout_5b) );    

    // for Meta-stable 
    CYCLE_DELAY #( .DATA_WIDTH(1), .DELAY(2) )    m_MEM_SEL_DLY2( .CLK(CCLK), .RST_N(RST_N), .iD(mem_sel), .oD(mem_sel_sync_cclk) );

    // Video Timing Controller
    TMG_CTRL #( .PARAM_WIDTH(10) ) m_TMG_CTRL ( .CLK(VGA_CLK), .RST_N(vga_clk_rst_n), 
                                   .iHTOTAL(800), .iHACT(640), .iHS_WIDTH(96), .iHS_BP(48),
                                   .iVTOTAL(525), .iVACT(480), .iVS_WIDTH( 2), .iVS_BP(33),
                                   .oHSYNC(tmg_hsync), .oVSYNC(tmg_vsync), .oDE(tmg_de), .oFIELD(mem_sel), 
                                   .oHTCOUNT(), .oVTCOUNT(),
                                   .oHDCOUNT(tmg_hcount), .oVDCOUNT(tmg_vcount)
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
                                    .iCURSOR_EN  (cursor_en  ),
                                    // iVGAout_mode:1=raw, 0=digitized
                                    //
                                    //
                                    .iPOINT_X(quotient_sx[10 -1: 0]), .iPOINT_Y(quotient_sy[10 -1: 0]),
                                    //
                                    .oVGA_HSYNC(pixel_hsync), .oVGA_VSYNC(pixel_vsync), .oVGA_DE(pixel_de),
                                    .oVGA_R(pixel_r0), .oVGA_G(pixel_g0), .oVGA_B(pixel_b0)
    );

    //
    OUT_VIDEO_DATA #( .PIXEL_WIDTH(PIXEL_WIDTH) ) m_OUT_VIDEO_DATA(.CLK(VGA_CLK), .RST_N(RST_N), 
                                     .iVSYNC_POL(1'b0), .iHSYNC_POL(1'b0),
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

    //
    assign  uart_out_de   = (uart_sw) ? uart_host_de  : uart_calc_de;
    assign  uart_out_data = (uart_sw) ? uart_host_data: uart_calc_data;

    // UART (temporal)
    UART_TX_CORE #( .OVER_SAMPLING(8) )    m_UART_TX_CORE( .CLK(clk_uart_x8), .RST_N(RST_N), 
                .iSEVEN_BIT (1'b1),        // Low = 8bit,        High = 7bit
                .iPARITY_EN (1'b0),        // Low = Non Parity,  High = Parity Enable
                .iODD_PARITY(1'b0),        // Low = Even Parity, High = Odd Parity
                .iSTOP_BIT  (1'b0),        // Low = 1bit,        High = 2bit
                //
                .iDE  (uart_out_de  ),
                .iDATA(uart_out_data),
                //
                .oUART_TX_BUSY(tx_busy),
                .oUART_TX     (UART_TXD)
    );

    UART_RX_CORE #( .OVER_SAMPLING(8) )    m_UART_RX_CORE ( .CLK(clk_uart_x8), .RST_N(RST_N),
                .iSEVEN_BIT (1'b1),        // Low = 8bit,        High = 7bit
                .iPARITY_EN (1'b0),        // Low = Non Parity,  High = Parity Enable
                .iODD_PARITY(1'b0),        // Low = Even Parity, High = Odd Parity
                .iSTOP_BIT  (1'b0),        // Low = 1bit,        High = 2bit
                //
                .iUART_RX(UART_RXD),
                //
                .oRETRY       (),
                .oPARITY_ERROR(),
                //
                .oDE  (uart_inp_de  ),
                .oDATA(uart_inp_data)
    );

    assign  uart_start_trig = (out_sel==1'b1) ? start_q_trig: start_trig;

    //  Ezpand signal
    // 27[cycle] + alpha
    EXPAND_SIGNAL #( .EXPAND_NUM(30) ) m_EXPAND_SIG_UART_START_TRIG ( .CLK(CLK), .RST_N(RST_N), .iS(uart_start_trig), .oS(expand_uart_start_trig) );

    UART_IF m_UART_IF( .CLK(clk_uart_x8), .RST_N(RST_N),
                .iOUT_SEL(out_sel),
                //
                .iSUM_S (sum_s ),
                .iSUM_SX(sum_sx),
                .iSUM_SY(sum_sy),
                .iQUOTIENT_SX(quotient_sx),
                .iQUOTIENT_SY(quotient_sy),
                //
                .iTRIG(expand_uart_start_trig),
                //
                .iUART_TX_BUSY(tx_busy),
                //
                .oBUSY(uart_calc_busy),
                //
                .oDE  (uart_calc_de  ),
                .oDATA(uart_calc_data)
    );

    //
    assign  host_if_rd = eye_reg_rd;

    //
    HOST_IF_CORE #( .ADDR_WIDTH(16), .FIFO_DATA_WIDTH(16*8) )   m_HOST_IF_CORE ( .CLK(CLK), .RST_N(RST_N),
                // for Internal Bus
                .oOUT_ADDR(host_if_addr ),
                .oOUT_WE  (host_if_we   ),
                .oOUT_RE  (host_if_re   ),
                .oOUT_DATA(host_if_wdata),
                .iRD      (host_if_rdata),
                // from UART_RECEIVER_FIFO
                .iDE        (uart_rx_fifo_int),
                .iDATA      (uart_rx_fifo),
                .oBUFFER_CLR(buf_clr),
                //
                .iUART_TX_BUSY(tx_busy),
                //
                .oBUSY(uart_host_busy),
                //
                .oDE  (uart_host_de  ),
                .oDATA(uart_host_data)
            );

    REG_BUS_IF #( .ADDR_WIDTH(16), .WE_WIDTH(24), .RE_WIDTH(24) )     m_REG_BUF_IF ( .CLK(CLK), .RST_N(RST_N),
                // from/to HOST_IF
                .iADDR (host_if_addr),
                .iWE   (host_if_we),
                .iRE   (host_if_re),
                .iDATA (host_if_wdata),
                .oRD_EN(host_if_rden),
                .oRD   (host_if_rdata),
                // from/to each REG module
                .oWE_BIT(host_we_bit),
                .oRE_BIT(host_re_bit),
                .oWD    (host_if_wd),
                .iRD_EN (host_if_re),
                .iRD    (host_if_rd)
            );

    EXPAND_SIGNAL #( .EXPAND_NUM(27) ) m_EXPAND_SIG_BUF_CLR ( .CLK(CLK), .RST_N(RST_N), .iS(buf_clr), .oS(buffer_clr) );

    UART_RECEIVER_FIFO #( .BUFFER_SIZE(16) )    m_UART_RECEIVER_FIFO ( .CLK(clk_uart_x8), .RST_N(RST_N),
                //
                .iCLR (buffer_clr   ),
                //
                .iDE  (uart_inp_de  ),
                .iDATA(uart_inp_data),
                //
                .oINT (uart_rx_fifo_int),
                .oDATA(uart_rx_fifo)
            );

    EYE_TRACKER_REG     m_EYE_TRACKER_REG ( .CLK(CLK), .RST_N(RST_N),
                // from/to HOST_IF
                .iWE_BIT(host_we_bit), 
                .iRE_BIT(host_re_bit), 
                .iDATA  (host_if_wd ),
                .oRD    (eye_reg_rd ),
                //
                .iFVSYNC(cmr_vsync),
                .iRVSYNC(tmg_vsync),
                //
                .iSUM_S (sum_s ),
                .iSUM_SX(sum_sx),
                .iSUM_SY(sum_sy),
                .iQUOTIENT_SX(quotient_sx),
                .iQUOTIENT_SY(quotient_sy),
                //
                .oUART_SW     (uart_sw    ),
                .oVGA_OUT_MODE(vgaout_mode),
                .oTHRESHOLD   (threshold  ),
                .oCURSOR_EN   (cursor_en  ),
                .oOUT_SEL     (out_sel    )
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
        .probe7(start_trig/*pixel_de*/),
        .probe8(cmr_vsync),
        .probe9(cmr_hsync),
        .probe10(cmr_de),
        .probe11(mem_sel /*memout_cx_en*/),
        .probe12(grav_sel_en),
        .probe13(cmr_field/*busy*/),
        .probe14(UART_TXD),
        .probe15(calc_state),
        .probe16(VGA_VSYNC),
        .probe17(VGA_HSYNC),
        .probe18(VGA_R),
        .probe19(sum_s[0]),
        .probe20(sum_s[1]),
        .probe21(cmr_addr[9] /*sum_s[2]*/),
        .probe22(cmr_addr[7:0] /*threshold[7:0]*/),
        .probe23(cmr_addr[8] /*sum_s[3]*/)
/*
        .probe19(clk_uart_x8),
        .probe20(start_trig),
        .probe21(uart_de),
        .probe22(uart_data),
        .probe23(tx_busy)
*/
//        .probe24(sum_s),
//        .probe25(sum_sy)
/*
.probe18(sum_s[7:0]),
.probe19(sum_s[8]),
.probe20(sum_s[9]),
.probe21(sum_s[10]),
.probe22(sum_s[18:11]),
.probe23(sum_s[19])
*/
);

endmodule
