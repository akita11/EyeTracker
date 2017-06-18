// -----------------------------------------------------------------------------
//  Title         : Simulation Top module
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : SIM_TOP.v
//  Author        : K.Ishiwatari
//  Created       : 2017/ 1/ 1
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Simulation Top module
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
    parameter           DATA_WIDTH      = 8;

    //
    reg                                 clk;
    reg                                 cclk;
    reg                                 resetn;
    reg                                 start_camera;
    reg                                 start_reg_set;
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
    reg                                 tx_inp_de;
    reg     [DATA_WIDTH -1: 0]          tx_inp_data;
    wire                                rx_out_de;
    wire    [DATA_WIDTH -1: 0]          rx_out_data;
    //
    integer                             i, j, l, k;
    //
    TOP #( .PIXEL_WIDTH(PIXEL_WIDTH), .ADDR_WIDTH(10), .PIX_HACT(640) )    m_TOP(
        .CLK(clk), .RST_N(resetn),
        .UART_RXD(uart_rx), .UART_TXD(uart_tx),
        .JP(jp_set), .DUMMY0(1'b1), .DUMMY1(1'b1),
        .CCLK(cclk), .FVAL(fval), .DVAL(dval), .LVAL(lval), .DATA_L(data_l), .DATA_R(data_r),
        .VGA_CLK(vga_clk), .VGA_VSYNC(vga_vsync), .VGA_HSYNC(vga_hsync), .VGA_R(vga_r), .VGA_G(vga_g), .VGA_B(vga_b) 
        );

    CLK_DIVIDER #( .DIVIDE(27) ) UART_CLK_TB ( .CLK(clk), .RST_N(resetn), .oDIV_CLK(uart_clk) );

    UART_TX_CORE #( .OVER_SAMPLING(8) ) UART_TX_CORE_TB ( .CLK(uart_clk), .RST_N(resetn), 
                                      .iSEVEN_BIT (1'b1),        // Low = 8bit,        High = 7bit
                                      .iPARITY_EN (1'b0),        // Low = Non Parity,  High = Parity Enable
                                      .iODD_PARITY(1'b0),        // Low = Even Parity, High = Odd Parity
                                      .iSTOP_BIT  (1'b0),        // Low = 1bit,        High = 2bit
                                      //
                                      .iDE  (tx_inp_de),
                                      .iDATA(tx_inp_data),
                                      //
                                      .oUART_TX_BUSY(uart_tx_busy),
                                      .oUART_TX     (uart_rx)
                                    );

    UART_RX_CORE #( .OVER_SAMPLING(8) ) UART_RX_CORE_TB ( .CLK(uart_clk), .RST_N(resetn), 
                                      //
                                      .iSEVEN_BIT (1'b1),        // Low = 8bit,        High = 7bit
                                      .iPARITY_EN (1'b0),        // Low = Non Parity,  High = Parity Enable
                                      .iODD_PARITY(1'b0),        // Low = Even Parity, High = Odd Parity
                                      .iSTOP_BIT  (1'b0),        // Low = 1bit,        High = 2bit
                                      //
                                      .iUART_RX(uart_tx),
                                      //
                                      .oRETRY       (),
                                      .oPARITY_ERROR(),
                                      //
                                      .oDE  (rx_out_de),
                                      .oDATA(rx_out_data)
                                    );

    // Simulation control
    initial begin
        clk           <= 1'b1;
        cclk          <= 1'b0;
        resetn        <= 1'b1;
        start_camera  <= 1'b0;
        start_reg_set <= 1'b0;
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
        start_reg_set <= 1'b1;
        // 
        repeat (500) begin
            @(posedge clk);
        end
        start_camera  <= 1;
    end

    initial begin
        data_r = 0;
        data_l = 0;
        //
        fval   = 0;
        dval   = 0;
        lval   = 0;
        //
        i = 0;
        j = 0;
        l = 0;
        k = 0;
        //
        @(posedge start_camera);
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

    //
    initial begin
        //
        tx_inp_de   <= 1'b0;
        tx_inp_data <= 'h0;
        @(posedge start_reg_set);
        //
        //
        printk("s");
        printk("t");
        printk("o");
        printk("p");
        printk('h0A);
        //
        repeat (10000) begin
            @(posedge clk);
        end
        //
        printk("r");
        printk("d");
        printk(" ");
        printk("0");
        printk("0");
        printk("0");
        printk("0");
        printk('h0A);
        // EXP = 0x01
        repeat (10000) begin
            @(posedge clk);
        end
        //
        printk("r");
        printk("d");
        printk(" ");
        printk("0");
        printk("0");
        printk("0");
        printk("1");
        printk('h0A);
        // EXP = 0x01
        repeat (10000) begin
            @(posedge clk);
        end
        //
        printk("r");
        printk("d");
        printk(" ");
        printk("0");
        printk("0");
        printk("0");
        printk("2");
        printk('h0A);
        // EXP = 0x01
        repeat (10000) begin
            @(posedge clk);
        end
        //
        printk("r");
        printk("d");
        printk('h08);
        printk('h08);
        printk("w");
        printk("r");
        printk(" ");
        printk("2");
        printk("0");
        printk("0");
        printk("2");
        printk(" ");
        printk("F");
        printk("E");
        printk('h0A);
        //
        repeat (10000) begin
            @(posedge clk);
        end
        //
        printk("r");
        printk("d");
        printk('h08);
        printk('h08);
        printk("w");
        printk("r");
        printk(" ");
        printk("0");
        printk("0");
        printk("0");
        printk("0");
        printk(" ");
        printk("0");
        printk("1");
        printk('h0A);
        //
        repeat (10000) begin
            @(posedge clk);
        end
        //
        printk("r");
        printk("d");
        printk('h08);
        printk('h08);
        printk("w");
        printk("r");
        printk(" ");
        printk("0");
        printk("0");
        printk("0");
        printk("1");
        printk(" ");
        printk("0");
        printk("1");
        printk('h0A);
        //
        repeat (10000) begin
            @(posedge clk);
        end
        //
        repeat (10000) begin
            @(posedge clk);
        end
        //
        printk("w");
        printk("r");
        printk(" ");
        printk("0");
        printk("0");
        printk("0");
        printk("2");
        printk(" ");
        printk("F");
        printk("E");
        printk('h0A);
        //
        repeat (10000) begin
            @(posedge clk);
        end
    end

    // Generate Clock
    always begin
        clk = 1'b1;
        #(`CLOCK_PERIOD/2)  clk = 1'b0;
        #(`CLOCK_PERIOD/2);
    end

    always begin
        cclk = 1'b1;
        #(`CCLOCK_PERIOD/2) cclk = 1'b0;
        #(`CCLOCK_PERIOD/2);
    end

    // printk
    task printk;
        input wire  [7:0] data;
        begin
            tx_inp_de   <= 1'b1;
            tx_inp_data <= data;
            //
            $display("[UART Tx] %s",tx_inp_data);
            repeat (16) begin
               @(posedge uart_clk);
            end
            tx_inp_de   <= 1'b0;
            repeat (16) begin
               @(posedge uart_clk);
            end
            @(negedge uart_tx_busy);
            //
            repeat (16) begin
               @(posedge uart_clk);
            end
        end
    endtask

    //
    always begin
        @(posedge rx_out_de);
        #1
        $display("[UART Rx] %s",rx_out_data);
    end

endmodule
