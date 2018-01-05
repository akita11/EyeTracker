// -----------------------------------------------------------------------------
//  Title         : Count Low and High for Debug
//  Project       : EyeTracker
// -----------------------------------------------------------------------------
//  File          : DBG_CNT_L_H.v
//  Author        : K.Ishiwatari
//  Created       : 2018/ 1/ 5
//  Last modified : 
// -----------------------------------------------------------------------------
//  Description   : Count Low and High for Debug
// -----------------------------------------------------------------------------
//  Copyright (C) 2017 K.Ishiwatari All Rights Reserved.
// -----------------------------------------------------------------------------

`timescale  1ns/1ps

module DBG_CNT_L_H #(
    parameter   C_CNT_WH                = 12,
    parameter   WE_WIDTH                = 8,
    parameter   RE_WIDTH                = 8
) (
    input   wire                        CLK,
    input   wire                        RST_N,
    // from/to HOST_IF
    input   wire    [WE_WIDTH -1: 0]    iWE_BIT,
    input   wire    [RE_WIDTH -1: 0]    iRE_BIT,
    input   wire    [DATA_WIDTH -1: 0]  iDATA,
    output  wire    [DATA_WIDTH -1: 0]  oRD,
    //
    input   wire                        iCLR,
    input   wire                        iSIG
);

    //
    localparam      DATA_WIDTH                  = 8;

    //
    wire                                        clr_sig;
    wire                                        syn_sig;
    wire                                        rise;
    wire                                        fall;
    //
    reg     [DATA_WIDTH -1: 0]                  rd0_data;
    reg     [DATA_WIDTH -1: 0]                  rd1_data;
    //
    reg                                         next_hi_we, hi_we;
    reg                                         next_lo_we, lo_we;
    reg     [C_CNT_WH -1: 0]                    next_hi_cnt, hi_cnt;
    reg     [C_CNT_WH -1: 0]                    next_lo_cnt, lo_cnt;
    wire    [C_CNT_WH -1: 0]                    hi_cnt0;
    wire    [C_CNT_WH -1: 0]                    hi_cnt1;
    wire    [C_CNT_WH -1: 0]                    hi_cnt2;
    wire    [C_CNT_WH -1: 0]                    hi_cnt3;
    wire    [C_CNT_WH -1: 0]                    lo_cnt0;
    wire    [C_CNT_WH -1: 0]                    lo_cnt1;
    wire    [C_CNT_WH -1: 0]                    lo_cnt2;
    wire    [C_CNT_WH -1: 0]                    lo_cnt3;

    //
    assign  clr = (iWE_BIT[0] & iDATA[0]);

    //
    CYCLE_DELAY #( .DATA_WIDTH(1), .DELAY(2) ) m_SYNC_SIG( .CLK(CLK), .RST_N(RST_N), .iD(iSIG), .oD(syn_sig) );
    DET_EDGE m_DET_EDGE( .CLK(CLK), .RST_N(RST_N), .iS(syn_sig), .oRISE(rise), .oFALL(fall) );

    // High
    always @(*) begin
        casex ({clr_sig,syn_sig,rise,fall})
            4'b00_00:   begin
                            next_hi_we  <= 1'b0;
                            next_lo_we  <= 1'b0;
                            next_hi_cnt <= hi_cnt;
                            next_lo_cnt <= lo_cnt + 'h1;
                        end
            4'b00_01:   begin
                            next_hi_we  <= 1'b1;
                            next_lo_we  <= 1'b0;
                            next_hi_cnt <= hi_cnt;
                            next_lo_cnt <= 'h0;
                        end
            4'b00_10:   begin
                            next_hi_we  <= 1'b0;
                            next_lo_we  <= 1'b1;
                            next_hi_cnt <= 'h0;
                            next_lo_cnt <= lo_cnt;
                        end
            4'b01_00:   begin
                            next_hi_we  <= 1'b0;
                            next_lo_we  <= 1'b0;
                            next_hi_cnt <= hi_cnt + 'h1;
                            next_lo_cnt <= lo_cnt;
                        end
            4'b01_01:   begin
                            next_hi_we  <= 1'b1;
                            next_lo_we  <= 1'b0;
                            next_hi_cnt <= hi_cnt;
                            next_lo_cnt <= 'h0;
                        end
            4'b01_10:   begin
                            next_hi_we  <= 1'b0;
                            next_lo_we  <= 1'b1;
                            next_hi_cnt <= 'h0;
                            next_lo_cnt <= lo_cnt;
                        end
            4'b1x_xx:   begin
                            next_hi_we  <= 1'b0;
                            next_lo_we  <= 1'b0;
                            next_hi_cnt <= 'h0;
                            next_lo_cnt <= 'h0;
                        end
            default:    begin
                            next_hi_we  <= 1'b0;
                            next_lo_we  <= 1'b0;
                            next_hi_cnt <= 'h0;
                            next_lo_cnt <= 'h0;
                        end
        endcase
    end

    //
    always @(posedge CLK or negedge RST_N) begin
        if (!RST_N) begin
            hi_we  <= 1'b0;
            lo_we  <= 1'b0;
            hi_cnt <= 'h0;
            lo_cnt <= 'h0;
        end else begin
            hi_we  <= next_hi_we;
            lo_we  <= next_lo_we;
            hi_cnt <= next_hi_cnt;
            lo_cnt <= next_lo_cnt;
        end
    end

    //
    assign  oRD    = rd0_data | rd1_data;

    //
    DFF_REG   #( .DATA_WIDTH(8), .INIT_VAL(8'h0 ) ) m_DBG_HI_CNT0_L( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(hi_we), .iD(hi_cnt [ 7: 0]), .oD(hi_cnt0[ 7: 0]) );
    DFF_REG   #( .DATA_WIDTH(4), .INIT_VAL(4'h0 ) ) m_DBG_HI_CNT0_H( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(hi_we), .iD(hi_cnt [11: 8]), .oD(hi_cnt0[11: 8]) );
    DFF_REG   #( .DATA_WIDTH(8), .INIT_VAL(8'h0 ) ) m_DBG_HI_CNT1_L( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(hi_we), .iD(hi_cnt0[ 7: 0]), .oD(hi_cnt1[ 7: 0]) );
    DFF_REG   #( .DATA_WIDTH(4), .INIT_VAL(4'h0 ) ) m_DBG_HI_CNT1_H( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(hi_we), .iD(hi_cnt0[11: 8]), .oD(hi_cnt1[11: 8]) );
    DFF_REG   #( .DATA_WIDTH(8), .INIT_VAL(8'h0 ) ) m_DBG_HI_CNT2_L( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(hi_we), .iD(hi_cnt1[ 7: 0]), .oD(hi_cnt2[ 7: 0]) );
    DFF_REG   #( .DATA_WIDTH(4), .INIT_VAL(4'h0 ) ) m_DBG_HI_CNT2_H( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(hi_we), .iD(hi_cnt1[11: 8]), .oD(hi_cnt2[11: 8]) );
    DFF_REG   #( .DATA_WIDTH(8), .INIT_VAL(8'h0 ) ) m_DBG_HI_CNT3_L( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(hi_we), .iD(hi_cnt2[ 7: 0]), .oD(hi_cnt3[ 7: 0]) );
    DFF_REG   #( .DATA_WIDTH(4), .INIT_VAL(4'h0 ) ) m_DBG_HI_CNT3_H( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(hi_we), .iD(hi_cnt2[11: 8]), .oD(hi_cnt3[11: 8]) );

    //
    DFF_REG   #( .DATA_WIDTH(8), .INIT_VAL(8'h0 ) ) m_DBG_LO_CNT0_L( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(lo_we), .iD(lo_cnt [ 7: 0]), .oD(lo_cnt0[ 7: 0]) );
    DFF_REG   #( .DATA_WIDTH(4), .INIT_VAL(4'h0 ) ) m_DBG_LO_CNT0_H( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(lo_we), .iD(lo_cnt [11: 8]), .oD(lo_cnt0[11: 8]) );
    DFF_REG   #( .DATA_WIDTH(8), .INIT_VAL(8'h0 ) ) m_DBG_LO_CNT1_L( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(lo_we), .iD(lo_cnt0[ 7: 0]), .oD(lo_cnt1[ 7: 0]) );
    DFF_REG   #( .DATA_WIDTH(4), .INIT_VAL(4'h0 ) ) m_DBG_LO_CNT1_H( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(lo_we), .iD(lo_cnt0[11: 8]), .oD(lo_cnt1[11: 8]) );
    DFF_REG   #( .DATA_WIDTH(8), .INIT_VAL(8'h0 ) ) m_DBG_LO_CNT2_L( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(lo_we), .iD(lo_cnt1[ 7: 0]), .oD(lo_cnt2[ 7: 0]) );
    DFF_REG   #( .DATA_WIDTH(4), .INIT_VAL(4'h0 ) ) m_DBG_LO_CNT2_H( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(lo_we), .iD(lo_cnt1[11: 8]), .oD(lo_cnt2[11: 8]) );
    DFF_REG   #( .DATA_WIDTH(8), .INIT_VAL(8'h0 ) ) m_DBG_LO_CNT3_L( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(lo_we), .iD(lo_cnt2[ 7: 0]), .oD(lo_cnt3[ 7: 0]) );
    DFF_REG   #( .DATA_WIDTH(4), .INIT_VAL(4'h0 ) ) m_DBG_LO_CNT3_H( .CLK(CLK), .RST_N(RST_N | ~clr_sig), .iWE(lo_we), .iD(lo_cnt2[11: 8]), .oD(lo_cnt3[11: 8]) );

    //
    always @(*) begin
        case (iRE_BIT[ 7: 0])
            8'b0000_0001:   rd0_data <= { hi_cnt0[ 7: 0] };
            8'b0000_0010:   rd0_data <= { 4'b0000, hi_cnt0[11: 8] };
            8'b0000_0100:   rd0_data <= { hi_cnt1[ 7: 0] };
            8'b0000_1000:   rd0_data <= { 4'b0000, hi_cnt1[11: 8] };
            8'b0001_0000:   rd0_data <= { hi_cnt0[ 7: 0] };
            8'b0010_0000:   rd0_data <= { 4'b0000, hi_cnt2[11: 8] };
            8'b0100_0000:   rd0_data <= { hi_cnt1[ 7: 0] };
            8'b1000_0000:   rd0_data <= { 4'b0000, hi_cnt3[11: 8] };
            default:        rd0_data <= 'h00;
        endcase
    end

    //
    always @(*) begin
        case (iRE_BIT[15: 8])
            8'b0000_0001:   rd1_data <= { lo_cnt0[ 7: 0] };
            8'b0000_0010:   rd1_data <= { 4'b0000, lo_cnt0[11: 8] };
            8'b0000_0100:   rd1_data <= { lo_cnt1[ 7: 0] };
            8'b0000_1000:   rd1_data <= { 4'b0000, lo_cnt1[11: 8] };
            8'b0001_0000:   rd1_data <= { lo_cnt0[ 7: 0] };
            8'b0010_0000:   rd1_data <= { 4'b0000, lo_cnt2[11: 8] };
            8'b0100_0000:   rd1_data <= { lo_cnt1[ 7: 0] };
            8'b1000_0000:   rd1_data <= { 4'b0000, lo_cnt3[11: 8] };
            default:        rd1_data <= 'h00;
        endcase
    end

endmodule
