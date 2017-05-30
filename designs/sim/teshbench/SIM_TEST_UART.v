// -----------------------------------------------------------------------------
//  Title         : Test for UART module
//  Project       : Common Project
// -----------------------------------------------------------------------------
//  File          : SIM_TEST_UART.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 4/ 2
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Test for UART module
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale      1ps/1ps

`define             CLOCK_PERIOD            20000           // 50[MHz]
//`define             CCLOCK_PERIOD           25000           // 40[MHz]
`define             CCLOCK_PERIOD           25000           // 50[MHz]
`define             MAX_INPUT_FRAME         60

module  SIM_TOP();
    //
    parameter           HTOTAL          = 360;
    parameter           VTOTAL          = 492;
    parameter           HACTIVE         = 320;
    parameter           VACTIVE         = 480;
    //
    parameter           PIXEL_WIDTH     = 8;
    //
    parameter           JP_WIDTH        = 8;

    //
    reg                                 clk;
    reg                                 cclk;
    reg                                 resetn;
    reg                                 start_camera;
    //
    reg     [JP_WIDTH -1: 0]            jp_set;

    //
    reg     [PIXEL_WIDTH -1: 0]         data_r;
    reg     [PIXEL_WIDTH -1: 0]         data_l;
    reg                                 fval, dval, lval;

    wire                                vga_clk;
    wire                                vga_vsync;
    wire                                vga_hsync;
    wire    [PIXEL_WIDTH -1: 0]         vga_r;
    wire    [PIXEL_WIDTH -1: 0]         vga_g;
    wire    [PIXEL_WIDTH -1: 0]         vga_b;
    //
    integer                             i, j, l, k;
    //
    TOP #( .PIXEL_WIDTH(PIXEL_WIDTH), .ADDR_WIDTH(9), .PIX_HACT(640) )    m_TOP(
        .CLK(clk), .RST_N(resetn),
        .UART_RXD(1'b0), .UART_TXD(),
        .JP(jp_set), .DUMMY0(1'b1), .DUMMY1(1'b1),
        .CCLK(cclk), .FVAL(fval), .DVAL(dval), .LVAL(lval), .DATA_L(data_l), .DATA_R(data_r),
        .VGA_CLK(vga_clk), .VGA_VSYNC(vga_vsync), .VGA_HSYNC(vga_hsync), .VGA_R(vga_r), .VGA_G(vga_g), .VGA_B(vga_b) 
        );

    // Simulation control
    initial begin
        clk          <= 1'b1;
        cclk         <= 1'b0;
        resetn       <= 1'b1;
        start_camera <= 1'b0;
        //
//        jp_set <= 8'h7F;
        jp_set <= 8'h01;
        //
        repeat (40) begin
            @(posedge clk);
        end
        resetn <= #(`CLOCK_PERIOD/8) 1'b0;
        repeat (100) begin
            @(posedge clk);
        end
        resetn <= #(`CLOCK_PERIOD/8) 1'b1;
        //
//        @(posedge m_TOP.m_CLK25M.m_CLKGEN_MMCM.locked)
        // 
        repeat (500) begin
            @(posedge clk);
        end
        start_camera <= 1;
    end

    initial begin
        data_r = 0;
        data_l = 0;
        //
        fval   = 0;
        dval   = 0;
        lval   = 0;
        //
        @(posedge start_camera);
        l = 0;
        k = 0;
        //
        @(posedge cclk);
        //
        repeat (`MAX_INPUT_FRAME) begin
            //
            for (j=0;j<VTOTAL;j=j+1) begin
                if (j>=(VTOTAL-VACTIVE-1)) begin
                    fval = 1;
                end else begin
                    fval = 0;
                end
                for (i=0;i<HTOTAL;i=i+1) begin
                    // dval = lval (DE)
                    if (i>=(HTOTAL-HACTIVE-1)) begin
                        lval = 1;
                        dval = fval;
                    end else begin
                        lval = 0;
                        dval = 0;
                    end
                    data_r = (l     ) & 255;
                    data_l = (l + 16) & 255;
                    @(posedge cclk);
                    l = l + 1;
                end
            end
        end
        //
        $finish;
    end

    always #(`CLOCK_PERIOD/2) begin
        clk <=  ~clk;
    end

    always #(`CCLOCK_PERIOD/2) begin
        cclk <=  ~cclk;
    end

endmodule
