// Copyright (C) 1953-2020 NUDT
// Verilog module name - regroup_lookup_table
// Version: regroup_lookup_table_V1.0
// Created:
//         by - peng jintao 
//         at - 08.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         lookup regroup table.
//             - lookup table and get dmac and outport of packet; 
//             - replace tsntag of first frag with dmac;
//             - discard the first 16B of middle frag or last frag;
//             - add 16B metadata;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module frame_inverse_mapping
(
       i_clk,
       i_rst_n,
       
	   iv_descriptor,
	   i_descriptor_wr,
       o_descriptor_ready,

       iv_regroup_ram_wdata,     
       i_regroup_ram_wr,
       iv_regroup_ram_addr,
       ov_regroup_ram_rdata,
       i_regroup_ram_rd,
	   
	   ov_dmac,
	   ov_bufid,
       o_lookup_table_match_flag,
       o_dmac_replace_flag,
       o_descriptor_wr,
       i_descriptor_ready
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// pkt input
input       [23:0]     iv_descriptor;
input                  i_descriptor_wr;
output                 o_descriptor_ready;
//ram write - porta 
input       [61:0]	   iv_regroup_ram_wdata;
input       	       i_regroup_ram_wr;
input       [7:0]	   iv_regroup_ram_addr;
output      [61:0]     ov_regroup_ram_rdata;
input                  i_regroup_ram_rd;
//result of look up table
output      [47:0]	   ov_dmac;
output      [8:0]	   ov_bufid;
output                 o_lookup_table_match_flag;
output                 o_dmac_replace_flag;
output                 o_descriptor_wr;
input                  i_descriptor_ready;
//read ram - portb
wire        [61:0]	   wv_regroup_ram_rdata;
wire       	           w_regroup_ram_rd;
wire        [7:0]	   wv_regroup_ram_raddr;
lookup_inversemapping_table lookup_inversemapping_table_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_descriptor(iv_descriptor),
.i_descriptor_wr(i_descriptor_wr),
.o_descriptor_ready(o_descriptor_ready),

.iv_regroup_ram_rdata(wv_regroup_ram_rdata),
.o_regroup_ram_rd(w_regroup_ram_rd),
.ov_regroup_ram_raddr(wv_regroup_ram_raddr),

.ov_dmac(ov_dmac),
.ov_bufid(ov_bufid),
.o_lookup_table_match_flag(o_lookup_table_match_flag),
.o_dmac_replace_flag(o_dmac_replace_flag),
.o_descriptor_wr(o_descriptor_wr),
.i_descriptor_ready(i_descriptor_ready)
);

ram_62_256 regroup_map_table
(
.address_a(iv_regroup_ram_addr),
.address_b(wv_regroup_ram_raddr),
.clock(i_clk),
.data_a(iv_regroup_ram_wdata),
.data_b(62'b0),
.rden_a(i_regroup_ram_rd),
.rden_b(w_regroup_ram_rd),
.wren_a(i_regroup_ram_wr),
.wren_b(1'b0),
.q_a(ov_regroup_ram_rdata),
.q_b(wv_regroup_ram_rdata)
);
endmodule