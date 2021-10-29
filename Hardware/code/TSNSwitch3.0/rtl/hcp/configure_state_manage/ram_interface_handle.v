// Copyright (C) 1953-2020 NUDT
// Verilog module name - ram_interface_handle
// Version: RIH_V1.0
// Created:
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         dock with ram interface
///////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module ram_interface_handle
(
       i_clk,
       i_rst_n,
       
       iv_wdata,
       iv_waddr,
       iv_wr,
       
       ov_rdata,
       iv_raddr,
       iv_rd,
       
       iv_mapping_wdata,
       iv_mapping_waddr,
       i_mapping_wr,
       ov_mapping_rdata,
       iv_mapping_raddr,
       i_mapping_rd,
       
       iv_inverse_mapping_wdata,
       iv_inverse_mapping_waddr,
       i_inverse_mapping_wr,
       ov_inverse_mapping_rdata,
       iv_inverse_mapping_raddr,
       i_inverse_mapping_rd,     
       
       ov_tss_ram_addr,
       ov_tss_ram_wdata,
       o_tss_ram_wr,
       iv_tss_ram_rdata,
       o_tss_ram_rd,
       
       ov_tis_ram_addr,
       ov_tis_ram_wdata,
       o_tis_ram_wr,
       iv_tis_ram_rdata,
       o_tis_ram_rd,
       
       ov_flt_ram_addr,
       ov_flt_ram_wdata,
       o_flt_ram_wr,
       iv_flt_ram_rdata,
       o_flt_ram_rd,
       
       ov_qgc0_ram_addr,
       ov_qgc0_ram_wdata,
       o_qgc0_ram_wr,
       iv_qgc0_ram_rdata,
       o_qgc0_ram_rd,
       
       ov_qgc1_ram_addr,
       ov_qgc1_ram_wdata,
       o_qgc1_ram_wr,
       iv_qgc1_ram_rdata,
       o_qgc1_ram_rd,
       
       ov_qgc2_ram_addr,
       ov_qgc2_ram_wdata,
       o_qgc2_ram_wr,
       iv_qgc2_ram_rdata,
       o_qgc2_ram_rd,
       
       ov_qgc3_ram_addr,
       ov_qgc3_ram_wdata,
       o_qgc3_ram_wr,
       iv_qgc3_ram_rdata,
       o_qgc3_ram_rd,
       
       ov_qgc4_ram_addr,
       ov_qgc4_ram_wdata,
       o_qgc4_ram_wr,
       iv_qgc4_ram_rdata,
       o_qgc4_ram_rd,
       
       ov_qgc5_ram_addr,
       ov_qgc5_ram_wdata,
       o_qgc5_ram_wr,
       iv_qgc5_ram_rdata,
       o_qgc5_ram_rd,
       
       ov_qgc6_ram_addr,
       ov_qgc6_ram_wdata,
       o_qgc6_ram_wr,
       iv_qgc6_ram_rdata,
       o_qgc6_ram_rd,
       
       ov_qgc7_ram_addr,
       ov_qgc7_ram_wdata,
       o_qgc7_ram_wr,
       iv_qgc7_ram_rdata,
       o_qgc7_ram_rd 
);

// I/O
// i_clk & rst
input                  i_clk;
input                  i_rst_n;

//configure RAM
input     [15:0]       iv_wdata;
input     [15:0]       iv_waddr;
input     [10:0]       iv_wr;
                       
input     [15:0]       iv_raddr;
output reg[15:0]       ov_rdata;
input     [10:0]       iv_rd;

input      [151:0]     iv_mapping_wdata;
input      [4:0]       iv_mapping_waddr;
input                  i_mapping_wr;
output reg [151:0]     ov_mapping_rdata;
input      [4:0]       iv_mapping_raddr;
input                  i_mapping_rd;

input      [61:0]      iv_inverse_mapping_wdata;
input      [7:0]       iv_inverse_mapping_waddr;
input                  i_inverse_mapping_wr;
output reg [61:0]      ov_inverse_mapping_rdata;
input      [7:0]       iv_inverse_mapping_raddr;
input                  i_inverse_mapping_rd;

output reg[9:0]        ov_tss_ram_addr;
output reg[15:0]       ov_tss_ram_wdata;
output reg             o_tss_ram_wr;
input     [15:0]       iv_tss_ram_rdata;
output reg             o_tss_ram_rd;
       
output reg[9:0]        ov_tis_ram_addr;
output reg[15:0]       ov_tis_ram_wdata;
output reg             o_tis_ram_wr;
input     [15:0]       iv_tis_ram_rdata;
output reg             o_tis_ram_rd;
       
output reg[13:0]       ov_flt_ram_addr;
output reg[8:0]        ov_flt_ram_wdata;
output reg             o_flt_ram_wr;
input     [8:0]        iv_flt_ram_rdata;
output reg             o_flt_ram_rd;
       
output reg[9:0]        ov_qgc0_ram_addr;
output reg[7:0]        ov_qgc0_ram_wdata;
output reg             o_qgc0_ram_wr;
input     [7:0]        iv_qgc0_ram_rdata;
output reg             o_qgc0_ram_rd;
              
output reg[9:0]        ov_qgc1_ram_addr;
output reg[7:0]        ov_qgc1_ram_wdata;
output reg             o_qgc1_ram_wr;
input     [7:0]        iv_qgc1_ram_rdata;
output reg             o_qgc1_ram_rd;
              
output reg[9:0]        ov_qgc2_ram_addr;
output reg[7:0]        ov_qgc2_ram_wdata;
output reg             o_qgc2_ram_wr;
input     [7:0]        iv_qgc2_ram_rdata;
output reg             o_qgc2_ram_rd;
              
output reg[9:0]        ov_qgc3_ram_addr;
output reg[7:0]        ov_qgc3_ram_wdata;
output reg             o_qgc3_ram_wr;
input     [7:0]        iv_qgc3_ram_rdata;
output reg             o_qgc3_ram_rd;
              
output reg[9:0]        ov_qgc4_ram_addr;
output reg[7:0]        ov_qgc4_ram_wdata;
output reg             o_qgc4_ram_wr;
input     [7:0]        iv_qgc4_ram_rdata;
output reg             o_qgc4_ram_rd;
              
output reg[9:0]        ov_qgc5_ram_addr;
output reg[7:0]        ov_qgc5_ram_wdata;
output reg             o_qgc5_ram_wr;
input     [7:0]        iv_qgc5_ram_rdata;
output reg             o_qgc5_ram_rd;
              
output reg[9:0]        ov_qgc6_ram_addr;
output reg[7:0]        ov_qgc6_ram_wdata;
output reg             o_qgc6_ram_wr;
input     [7:0]        iv_qgc6_ram_rdata;
output reg             o_qgc6_ram_rd;
              
output reg[9:0]        ov_qgc7_ram_addr;
output reg[7:0]        ov_qgc7_ram_wdata;
output reg             o_qgc7_ram_wr;
input     [7:0]        iv_qgc7_ram_rdata;
output reg             o_qgc7_ram_rd;



reg     [10:0]        read_ram_delay0;
reg     [10:0]        read_ram_delay1;
reg     [10:0]        read_ram_delay2;
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        ov_tss_ram_addr    <= 10'h0;
        ov_tss_ram_wdata   <= 16'h0;
        o_tss_ram_wr       <= 1'h0;
        o_tss_ram_rd       <= 1'h0;
                          
        ov_tis_ram_addr    <= 10'h0;
        ov_tis_ram_wdata   <= 16'h0;
        o_tis_ram_wr       <= 1'h0;
        o_tis_ram_rd       <= 1'h0;
                          
        ov_flt_ram_addr    <= 14'h0;
        ov_flt_ram_wdata   <= 9'h0;
        o_flt_ram_wr       <= 1'h0;
        o_flt_ram_rd       <= 1'h0;
                           
        ov_qgc0_ram_addr   <= 10'h0;
        ov_qgc0_ram_wdata  <= 8'h0;
        o_qgc0_ram_wr      <= 1'h0;
        o_qgc0_ram_rd      <= 1'h0;
       
        ov_qgc1_ram_addr   <= 10'h0;
        ov_qgc1_ram_wdata  <= 8'h0;
        o_qgc1_ram_wr      <= 1'h0;
        o_qgc1_ram_rd      <= 1'h0;
       
        ov_qgc2_ram_addr   <= 10'h0;
        ov_qgc2_ram_wdata  <= 8'h0;
        o_qgc2_ram_wr      <= 1'h0;
        o_qgc2_ram_rd      <= 1'h0;
        
        ov_qgc3_ram_addr   <= 10'h0;
        ov_qgc3_ram_wdata  <= 8'h0;
        o_qgc3_ram_wr      <= 1'h0;
        o_qgc3_ram_rd      <= 1'h0;
        
        ov_qgc4_ram_addr   <= 10'h0;
        ov_qgc4_ram_wdata  <= 8'h0;
        o_qgc4_ram_wr      <= 1'h0;
        o_qgc4_ram_rd      <= 1'h0;
        
        ov_qgc5_ram_addr   <= 10'h0;
        ov_qgc5_ram_wdata  <= 8'h0;
        o_qgc5_ram_wr      <= 1'h0;
        o_qgc5_ram_rd      <= 1'h0;
        
        ov_qgc6_ram_addr   <= 10'h0;
        ov_qgc6_ram_wdata  <= 8'h0;
        o_qgc6_ram_wr      <= 1'h0;
        o_qgc6_ram_rd      <= 1'h0;
        
        ov_qgc7_ram_addr   <= 10'h0;
        ov_qgc7_ram_wdata  <= 8'h0;
        o_qgc7_ram_wr      <= 1'h0;
        o_qgc7_ram_rd      <= 1'h0;
    end
    else begin
        if(|iv_rd == 1'b1)begin//have read RAM request
             if(iv_wr[0] == 1'b1)begin//if have write RAM request,can not read this RAM
                 ov_tss_ram_addr  <= iv_waddr[9:0];
                 ov_tss_ram_wdata <= iv_wdata;
                 o_tss_ram_wr     <= 1'b1;
                 
                 ov_tis_ram_addr  <= iv_raddr[9:0];
                 o_tis_ram_rd     <= iv_rd[1];
                 ov_flt_ram_addr  <= iv_raddr[13:0];
                 o_flt_ram_rd     <= iv_rd[2];
                 ov_qgc0_ram_addr <= iv_raddr[9:0];
                 o_qgc0_ram_rd    <= iv_rd[3];
                 ov_qgc1_ram_addr <= iv_raddr[9:0];
                 o_qgc1_ram_rd    <= iv_rd[4];
                 ov_qgc2_ram_addr <= iv_raddr[9:0];
                 o_qgc2_ram_rd    <= iv_rd[5];
                 ov_qgc3_ram_addr <= iv_raddr[9:0];
                 o_qgc3_ram_rd    <= iv_rd[6];
                 ov_qgc4_ram_addr <= iv_raddr[9:0];
                 o_qgc4_ram_rd    <= iv_rd[7];
                 ov_qgc5_ram_addr <= iv_raddr[9:0];
                 o_qgc5_ram_rd    <= iv_rd[8];
                 ov_qgc6_ram_addr <= iv_raddr[9:0];
                 o_qgc6_ram_rd    <= iv_rd[9];
                 ov_qgc7_ram_addr <= iv_raddr[9:0];
                 o_qgc7_ram_rd    <= iv_rd[10];
             end
             else if(iv_wr[1] == 1'b1)begin//if have write RAM request,can not read this RAM
                 ov_tis_ram_addr  <= iv_waddr[9:0];
                 ov_tis_ram_wdata <= iv_wdata;
                 o_tis_ram_wr     <= 1'b1;
                 
                 ov_tss_ram_addr  <= iv_raddr[9:0];
                 o_tss_ram_rd     <= iv_rd[0];
                 ov_flt_ram_addr  <= iv_raddr[13:0];
                 o_flt_ram_rd     <= iv_rd[2];
                 ov_qgc0_ram_addr <= iv_raddr[9:0];
                 o_qgc0_ram_rd    <= iv_rd[3];
                 ov_qgc1_ram_addr <= iv_raddr[9:0];
                 o_qgc1_ram_rd    <= iv_rd[4];
                 ov_qgc2_ram_addr <= iv_raddr[9:0];
                 o_qgc2_ram_rd    <= iv_rd[5];
                 ov_qgc3_ram_addr <= iv_raddr[9:0];
                 o_qgc3_ram_rd    <= iv_rd[6];
                 ov_qgc4_ram_addr <= iv_raddr[9:0];
                 o_qgc4_ram_rd    <= iv_rd[7];
                 ov_qgc5_ram_addr <= iv_raddr[9:0];
                 o_qgc5_ram_rd    <= iv_rd[8];
                 ov_qgc6_ram_addr <= iv_raddr[9:0];
                 o_qgc6_ram_rd    <= iv_rd[9];
                 ov_qgc7_ram_addr <= iv_raddr[9:0];
                 o_qgc7_ram_rd    <= iv_rd[10];
             end
             else if(iv_wr[2] == 1'b1)begin//if have write RAM request,can not read this RAM
                 ov_flt_ram_addr  <= iv_waddr[13:0];
                 ov_flt_ram_wdata <= iv_wdata[8:0];
                 o_flt_ram_wr     <= 1'b1;
                 
                 ov_tss_ram_addr  <= iv_raddr[9:0];
                 o_tss_ram_rd     <= iv_rd[0];
                 ov_tis_ram_addr  <= iv_raddr[9:0];
                 o_tis_ram_rd     <= iv_rd[1];
                 ov_qgc0_ram_addr <= iv_raddr[9:0];
                 o_qgc0_ram_rd    <= iv_rd[3];
                 ov_qgc1_ram_addr <= iv_raddr[9:0];
                 o_qgc1_ram_rd    <= iv_rd[4];
                 ov_qgc2_ram_addr <= iv_raddr[9:0];
                 o_qgc2_ram_rd    <= iv_rd[5];
                 ov_qgc3_ram_addr <= iv_raddr[9:0];
                 o_qgc3_ram_rd    <= iv_rd[6];
                 ov_qgc4_ram_addr <= iv_raddr[9:0];
                 o_qgc4_ram_rd    <= iv_rd[7];
                 ov_qgc5_ram_addr <= iv_raddr[9:0];
                 o_qgc5_ram_rd    <= iv_rd[8];
                 ov_qgc6_ram_addr <= iv_raddr[9:0];
                 o_qgc6_ram_rd    <= iv_rd[9];
                 ov_qgc7_ram_addr <= iv_raddr[9:0];
                 o_qgc7_ram_rd    <= iv_rd[10];
             end
             else if(iv_wr[3] == 1'b1)begin//if have write RAM request,can not read this RAM
                 ov_qgc0_ram_addr  <= iv_waddr[9:0];
                 ov_qgc0_ram_wdata <= iv_wdata[7:0];
                 o_qgc0_ram_wr     <= 1'b1;
                 
                 ov_tss_ram_addr  <= iv_raddr[9:0];
                 o_tss_ram_rd     <= iv_rd[0];
                 ov_tis_ram_addr  <= iv_raddr[9:0];
                 o_tis_ram_rd     <= iv_rd[1];
                 ov_flt_ram_addr <= iv_raddr[13:0];
                 o_flt_ram_rd    <= iv_rd[2];
                 ov_qgc1_ram_addr <= iv_raddr[9:0];
                 o_qgc1_ram_rd    <= iv_rd[4];
                 ov_qgc2_ram_addr <= iv_raddr[9:0];
                 o_qgc2_ram_rd    <= iv_rd[5];
                 ov_qgc3_ram_addr <= iv_raddr[9:0];
                 o_qgc3_ram_rd    <= iv_rd[6];
                 ov_qgc4_ram_addr <= iv_raddr[9:0];
                 o_qgc4_ram_rd    <= iv_rd[7];
                 ov_qgc5_ram_addr <= iv_raddr[9:0];
                 o_qgc5_ram_rd    <= iv_rd[8];
                 ov_qgc6_ram_addr <= iv_raddr[9:0];
                 o_qgc6_ram_rd    <= iv_rd[9];
                 ov_qgc7_ram_addr <= iv_raddr[9:0];
                 o_qgc7_ram_rd    <= iv_rd[10];
             end
             else if(iv_wr[4] == 1'b1)begin//if have write RAM request,can not read this RAM
                 ov_qgc1_ram_addr  <= iv_waddr[9:0];
                 ov_qgc1_ram_wdata <= iv_wdata[7:0];
                 o_qgc1_ram_wr     <= 1'b1;
                 
                 ov_tss_ram_addr  <= iv_raddr[9:0];
                 o_tss_ram_rd     <= iv_rd[0];
                 ov_tis_ram_addr  <= iv_raddr[9:0];
                 o_tis_ram_rd     <= iv_rd[1];
                 ov_flt_ram_addr <= iv_raddr[13:0];
                 o_flt_ram_rd    <= iv_rd[2];
                 ov_qgc0_ram_addr <= iv_raddr[9:0];
                 o_qgc0_ram_rd    <= iv_rd[3];
                 ov_qgc2_ram_addr <= iv_raddr[9:0];
                 o_qgc2_ram_rd    <= iv_rd[5];
                 ov_qgc3_ram_addr <= iv_raddr[9:0];
                 o_qgc3_ram_rd    <= iv_rd[6];
                 ov_qgc4_ram_addr <= iv_raddr[9:0];
                 o_qgc4_ram_rd    <= iv_rd[7];
                 ov_qgc5_ram_addr <= iv_raddr[9:0];
                 o_qgc5_ram_rd    <= iv_rd[8];
                 ov_qgc6_ram_addr <= iv_raddr[9:0];
                 o_qgc6_ram_rd    <= iv_rd[9];
                 ov_qgc7_ram_addr <= iv_raddr[9:0];
                 o_qgc7_ram_rd    <= iv_rd[10];
             end
             else if(iv_wr[5] == 1'b1)begin//if have write RAM request,can not read this RAM
                 ov_qgc2_ram_addr  <= iv_waddr[9:0];
                 ov_qgc2_ram_wdata <= iv_wdata[7:0];
                 o_qgc2_ram_wr     <= 1'b1;
                 
                 ov_tss_ram_addr  <= iv_raddr[9:0];
                 o_tss_ram_rd     <= iv_rd[0];
                 ov_tis_ram_addr  <= iv_raddr[9:0];
                 o_tis_ram_rd     <= iv_rd[1];
                 ov_flt_ram_addr <= iv_raddr[13:0];
                 o_flt_ram_rd    <= iv_rd[2];
                 ov_qgc0_ram_addr <= iv_raddr[9:0];
                 o_qgc0_ram_rd    <= iv_rd[3];
                 ov_qgc1_ram_addr <= iv_raddr[9:0];
                 o_qgc1_ram_rd    <= iv_rd[4];
                 ov_qgc3_ram_addr <= iv_raddr[9:0];
                 o_qgc3_ram_rd    <= iv_rd[6];
                 ov_qgc4_ram_addr <= iv_raddr[9:0];
                 o_qgc4_ram_rd    <= iv_rd[7];
                 ov_qgc5_ram_addr <= iv_raddr[9:0];
                 o_qgc5_ram_rd    <= iv_rd[8];
                 ov_qgc6_ram_addr <= iv_raddr[9:0];
                 o_qgc6_ram_rd    <= iv_rd[9];
                 ov_qgc7_ram_addr <= iv_raddr[9:0];
                 o_qgc7_ram_rd    <= iv_rd[10];
             end
             else if(iv_wr[6] == 1'b1)begin//if have write RAM request,can not read this RAM
                 ov_qgc3_ram_addr  <= iv_waddr[9:0];
                 ov_qgc3_ram_wdata <= iv_wdata[7:0];
                 o_qgc3_ram_wr     <= 1'b1;
                 
                 ov_tss_ram_addr  <= iv_raddr[9:0];
                 o_tss_ram_rd     <= iv_rd[0];
                 ov_tis_ram_addr  <= iv_raddr[9:0];
                 o_tis_ram_rd     <= iv_rd[1];
                 ov_flt_ram_addr <= iv_raddr[13:0];
                 o_flt_ram_rd    <= iv_rd[2];
                 ov_qgc0_ram_addr <= iv_raddr[9:0];
                 o_qgc0_ram_rd    <= iv_rd[3];
                 ov_qgc1_ram_addr <= iv_raddr[9:0];
                 o_qgc1_ram_rd    <= iv_rd[4];
                 ov_qgc2_ram_addr <= iv_raddr[9:0];
                 o_qgc2_ram_rd    <= iv_rd[5];
                 ov_qgc4_ram_addr <= iv_raddr[9:0];
                 o_qgc4_ram_rd    <= iv_rd[7];
                 ov_qgc5_ram_addr <= iv_raddr[9:0];
                 o_qgc5_ram_rd    <= iv_rd[8];
                 ov_qgc6_ram_addr <= iv_raddr[9:0];
                 o_qgc6_ram_rd    <= iv_rd[9];
                 ov_qgc7_ram_addr <= iv_raddr[9:0];
                 o_qgc7_ram_rd    <= iv_rd[10];
             end
             else if(iv_wr[7] == 1'b1)begin//if have write RAM request,can not read this RAM
                 ov_qgc4_ram_addr  <= iv_waddr[9:0];
                 ov_qgc4_ram_wdata <= iv_wdata[7:0];
                 o_qgc4_ram_wr     <= 1'b1;
                 
                 ov_tss_ram_addr  <= iv_raddr[9:0];
                 o_tss_ram_rd     <= iv_rd[0];
                 ov_tis_ram_addr  <= iv_raddr[9:0];
                 o_tis_ram_rd     <= iv_rd[1];
                 ov_flt_ram_addr <= iv_raddr[13:0];
                 o_flt_ram_rd    <= iv_rd[2];
                 ov_qgc0_ram_addr <= iv_raddr[9:0];
                 o_qgc0_ram_rd    <= iv_rd[3];
                 ov_qgc1_ram_addr <= iv_raddr[9:0];
                 o_qgc1_ram_rd    <= iv_rd[4];
                 ov_qgc2_ram_addr <= iv_raddr[9:0];
                 o_qgc2_ram_rd    <= iv_rd[5];
                 ov_qgc3_ram_addr <= iv_raddr[9:0];
                 o_qgc3_ram_rd    <= iv_rd[6];
                 ov_qgc5_ram_addr <= iv_raddr[9:0];
                 o_qgc5_ram_rd    <= iv_rd[8];
                 ov_qgc6_ram_addr <= iv_raddr[9:0];
                 o_qgc6_ram_rd    <= iv_rd[9];
                 ov_qgc7_ram_addr <= iv_raddr[9:0];
                 o_qgc7_ram_rd    <= iv_rd[10];
             end
             else if(iv_wr[8] == 1'b1)begin//if have write RAM request,can not read this RAM
                 ov_qgc5_ram_addr  <= iv_waddr[9:0];
                 ov_qgc5_ram_wdata <= iv_wdata[7:0];
                 o_qgc5_ram_wr     <= 1'b1;
                 
                 ov_tss_ram_addr  <= iv_raddr[9:0];
                 o_tss_ram_rd     <= iv_rd[0];
                 ov_tis_ram_addr  <= iv_raddr[9:0];
                 o_tis_ram_rd     <= iv_rd[1];
                 ov_flt_ram_addr <= iv_raddr[13:0];
                 o_flt_ram_rd    <= iv_rd[2];
                 ov_qgc0_ram_addr <= iv_raddr[9:0];
                 o_qgc0_ram_rd    <= iv_rd[3];
                 ov_qgc1_ram_addr <= iv_raddr[9:0];
                 o_qgc1_ram_rd    <= iv_rd[4];
                 ov_qgc2_ram_addr <= iv_raddr[9:0];
                 o_qgc2_ram_rd    <= iv_rd[5];
                 ov_qgc3_ram_addr <= iv_raddr[9:0];
                 o_qgc3_ram_rd    <= iv_rd[6];
                 ov_qgc4_ram_addr <= iv_raddr[9:0];
                 o_qgc4_ram_rd    <= iv_rd[7];
                 ov_qgc6_ram_addr <= iv_raddr[9:0];
                 o_qgc6_ram_rd    <= iv_rd[9];
                 ov_qgc7_ram_addr <= iv_raddr[9:0];
                 o_qgc7_ram_rd    <= iv_rd[10];
             end
             else if(iv_wr[9] == 1'b1)begin//if have write RAM request,can not read this RAM
                 ov_qgc6_ram_addr  <= iv_waddr[9:0];
                 ov_qgc6_ram_wdata <= iv_wdata[7:0];
                 o_qgc6_ram_wr     <= 1'b1;
                 
                 ov_tss_ram_addr  <= iv_raddr[9:0];
                 o_tss_ram_rd     <= iv_rd[0];
                 ov_tis_ram_addr  <= iv_raddr[9:0];
                 o_tis_ram_rd     <= iv_rd[1];
                 ov_flt_ram_addr <= iv_raddr[13:0];
                 o_flt_ram_rd    <= iv_rd[2];
                 ov_qgc0_ram_addr <= iv_raddr[9:0];
                 o_qgc0_ram_rd    <= iv_rd[3];
                 ov_qgc1_ram_addr <= iv_raddr[9:0];
                 o_qgc1_ram_rd    <= iv_rd[4];
                 ov_qgc2_ram_addr <= iv_raddr[9:0];
                 o_qgc2_ram_rd    <= iv_rd[5];
                 ov_qgc3_ram_addr <= iv_raddr[9:0];
                 o_qgc3_ram_rd    <= iv_rd[6];
                 ov_qgc4_ram_addr <= iv_raddr[9:0];
                 o_qgc4_ram_rd    <= iv_rd[7];
                 ov_qgc5_ram_addr <= iv_raddr[9:0];
                 o_qgc5_ram_rd    <= iv_rd[8];
                 ov_qgc7_ram_addr <= iv_raddr[9:0];
                 o_qgc7_ram_rd    <= iv_rd[10];
             end
             else if(iv_wr[10] == 1'b1)begin//if have write RAM request,can not read this RAM
                 ov_qgc7_ram_addr  <= iv_waddr[9:0];
                 ov_qgc7_ram_wdata <= iv_wdata[7:0];
                 o_qgc7_ram_wr     <= 1'b1;
                 
                 ov_tss_ram_addr  <= iv_raddr[9:0];
                 o_tss_ram_rd     <= iv_rd[0];
                 ov_tis_ram_addr  <= iv_raddr[9:0];
                 o_tis_ram_rd     <= iv_rd[1];
                 ov_flt_ram_addr <= iv_raddr[13:0];
                 o_flt_ram_rd    <= iv_rd[2];
                 ov_qgc0_ram_addr <= iv_raddr[9:0];
                 o_qgc0_ram_rd    <= iv_rd[3];
                 ov_qgc1_ram_addr <= iv_raddr[9:0];
                 o_qgc1_ram_rd    <= iv_rd[4];
                 ov_qgc2_ram_addr <= iv_raddr[9:0];
                 o_qgc2_ram_rd    <= iv_rd[5];
                 ov_qgc3_ram_addr <= iv_raddr[9:0];
                 o_qgc3_ram_rd    <= iv_rd[6];
                 ov_qgc4_ram_addr <= iv_raddr[9:0];
                 o_qgc4_ram_rd    <= iv_rd[7];
                 ov_qgc5_ram_addr <= iv_raddr[9:0];
                 o_qgc5_ram_rd    <= iv_rd[8];
                 ov_qgc6_ram_addr <= iv_raddr[9:0];
                 o_qgc6_ram_rd    <= iv_rd[9];
             end 
             else begin//just read this RAM
                 o_tss_ram_wr      <= 1'b0;
                 o_tis_ram_wr      <= 1'b0;
                 o_flt_ram_wr      <= 1'b0;
                 o_qgc0_ram_wr     <= 1'b0;
                 o_qgc1_ram_wr     <= 1'b0;
                 o_qgc2_ram_wr     <= 1'b0;
                 o_qgc3_ram_wr     <= 1'b0;
                 o_qgc4_ram_wr     <= 1'b0;
                 o_qgc5_ram_wr     <= 1'b0;
                 o_qgc6_ram_wr     <= 1'b0;
                 o_qgc7_ram_wr     <= 1'b0;
                 
                 ov_tss_ram_addr  <= iv_raddr[9:0];
                 o_tss_ram_rd     <= iv_rd[0];
                 ov_tis_ram_addr  <= iv_raddr[9:0];
                 o_tis_ram_rd     <= iv_rd[1];
                 ov_flt_ram_addr <= iv_raddr[13:0];
                 o_flt_ram_rd    <= iv_rd[2];
                 ov_qgc0_ram_addr <= iv_raddr[9:0];
                 o_qgc0_ram_rd    <= iv_rd[3];
                 ov_qgc1_ram_addr <= iv_raddr[9:0];
                 o_qgc1_ram_rd    <= iv_rd[4];
                 ov_qgc2_ram_addr <= iv_raddr[9:0];
                 o_qgc2_ram_rd    <= iv_rd[5];
                 ov_qgc3_ram_addr <= iv_raddr[9:0];
                 o_qgc3_ram_rd    <= iv_rd[6];
                 ov_qgc4_ram_addr <= iv_raddr[9:0];
                 o_qgc4_ram_rd    <= iv_rd[7];
                 ov_qgc5_ram_addr <= iv_raddr[9:0];
                 o_qgc5_ram_rd    <= iv_rd[8];
                 ov_qgc6_ram_addr <= iv_raddr[9:0];
                 o_qgc6_ram_rd    <= iv_rd[9];
                 ov_qgc7_ram_addr <= iv_raddr[9:0];
                 o_qgc7_ram_rd    <= iv_rd[10];
             end 
        end
        else begin//it is have not read request,just write RAM base on the write request
             o_tss_ram_rd      <= 1'b0;
             o_tis_ram_rd      <= 1'b0;
             o_flt_ram_rd      <= 1'b0;
             o_qgc0_ram_rd     <= 1'b0;
             o_qgc1_ram_rd     <= 1'b0;
             o_qgc2_ram_rd     <= 1'b0;
             o_qgc3_ram_rd     <= 1'b0;
             o_qgc4_ram_rd     <= 1'b0;
             o_qgc5_ram_rd     <= 1'b0;
             o_qgc6_ram_rd     <= 1'b0;
             o_qgc7_ram_rd     <= 1'b0;
             if(iv_wr[0] == 1'b1)begin
                 ov_tss_ram_addr  <= iv_waddr[9:0];
                 ov_tss_ram_wdata <= iv_wdata;
                 o_tss_ram_wr     <= 1'b1;
             end
             else if(iv_wr[1] == 1'b1)begin
                 ov_tis_ram_addr  <= iv_waddr[9:0];
                 ov_tis_ram_wdata <= iv_wdata;
                 o_tis_ram_wr     <= 1'b1;
             end
             else if(iv_wr[2] == 1'b1)begin
                 ov_flt_ram_addr  <= iv_waddr[13:0];
                 ov_flt_ram_wdata <= iv_wdata[8:0];
                 o_flt_ram_wr     <= 1'b1;
             end
             else if(iv_wr[3] == 1'b1)begin
                 ov_qgc0_ram_addr  <= iv_waddr[9:0];
                 ov_qgc0_ram_wdata <= iv_wdata[7:0];
                 o_qgc0_ram_wr     <= 1'b1;
             end
             else if(iv_wr[4] == 1'b1)begin
                 ov_qgc1_ram_addr  <= iv_waddr[9:0];
                 ov_qgc1_ram_wdata <= iv_wdata[7:0];
                 o_qgc1_ram_wr     <= 1'b1;
             end
             else if(iv_wr[5] == 1'b1)begin
                 ov_qgc2_ram_addr  <= iv_waddr[9:0];
                 ov_qgc2_ram_wdata <= iv_wdata[7:0];
                 o_qgc2_ram_wr     <= 1'b1;
             end
             else if(iv_wr[6] == 1'b1)begin
                 ov_qgc3_ram_addr  <= iv_waddr[9:0];
                 ov_qgc3_ram_wdata <= iv_wdata[7:0];
                 o_qgc3_ram_wr     <= 1'b1;
             end
             else if(iv_wr[7] == 1'b1)begin
                 ov_qgc4_ram_addr  <= iv_waddr[9:0];
                 ov_qgc4_ram_wdata <= iv_wdata[7:0];
                 o_qgc4_ram_wr     <= 1'b1;
             end
             else if(iv_wr[8] == 1'b1)begin
                 ov_qgc5_ram_addr  <= iv_waddr[9:0];
                 ov_qgc5_ram_wdata <= iv_wdata[7:0];
                 o_qgc5_ram_wr     <= 1'b1;
             end
             else if(iv_wr[9] == 1'b1)begin
                 ov_qgc6_ram_addr  <= iv_waddr[9:0];
                 ov_qgc6_ram_wdata <= iv_wdata[7:0];
                 o_qgc6_ram_wr     <= 1'b1;
             end
             else if(iv_wr[10] == 1'b1)begin
                 ov_qgc7_ram_addr  <= iv_waddr[9:0];
                 ov_qgc7_ram_wdata <= iv_wdata[7:0];
                 o_qgc7_ram_wr     <= 1'b1;
             end 
             else begin
                 o_tss_ram_wr      <= 1'b0;
                 o_tis_ram_wr      <= 1'b0;
                 o_flt_ram_wr      <= 1'b0;
                 o_qgc0_ram_wr     <= 1'b0;
                 o_qgc1_ram_wr     <= 1'b0;
                 o_qgc2_ram_wr     <= 1'b0;
                 o_qgc3_ram_wr     <= 1'b0;
                 o_qgc4_ram_wr     <= 1'b0;
                 o_qgc5_ram_wr     <= 1'b0;
                 o_qgc6_ram_wr     <= 1'b0;
                 o_qgc7_ram_wr     <= 1'b0;
             end
        end
    end
end


always @(posedge i_clk or negedge i_rst_n) begin // read ram have two cycle delay
    if(i_rst_n == 1'b0)begin
        read_ram_delay0    <= 11'd0;
        read_ram_delay1    <= 11'd0;
        read_ram_delay2    <= 11'd0;
    end
    else begin
        read_ram_delay0    <= iv_rd;
        read_ram_delay1    <= read_ram_delay0;
        read_ram_delay2    <= read_ram_delay1;
    end
end


always @(posedge i_clk or negedge i_rst_n) begin // read ram have two cycle delay
    if(i_rst_n == 1'b0)begin
        ov_rdata    <= 16'h0;
    end
    else begin
        if(|read_ram_delay2 == 1'b1)begin
            case(read_ram_delay2)
                11'b00000000001: ov_rdata    <= iv_tss_ram_rdata;
                11'b00000000010: ov_rdata    <= iv_tis_ram_rdata;
                11'b00000000100: ov_rdata    <= {7'h0,iv_flt_ram_rdata};
                11'b00000001000: ov_rdata    <= {8'h0,iv_qgc0_ram_rdata};
                11'b00000010000: ov_rdata    <= {8'h0,iv_qgc1_ram_rdata};
                11'b00000100000: ov_rdata    <= {8'h0,iv_qgc2_ram_rdata};
                11'b00001000000: ov_rdata    <= {8'h0,iv_qgc3_ram_rdata};
                11'b00010000000: ov_rdata    <= {8'h0,iv_qgc4_ram_rdata};
                11'b00100000000: ov_rdata    <= {8'h0,iv_qgc5_ram_rdata};
                11'b01000000000: ov_rdata    <= {8'h0,iv_qgc6_ram_rdata};
                11'b10000000000: ov_rdata    <= {8'h0,iv_qgc7_ram_rdata};
            endcase
        end
        else begin
            ov_rdata    <= ov_rdata;
        end
    end
end

endmodule