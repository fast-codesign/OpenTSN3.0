/////////////////////////////////////////////////////////////////
// NUDT.  All rights reserved.
//*************************************************************
//                     Basic Information
//*************************************************************
//Vendor: NUDT
//FAST URL://www.fastswitch.org 
//Target Device: Xilinx
//Filename: um.v
//Version: 1.0
//date: 2019/08/12
//Author : Peng Jintao
//*************************************************************
//                     Module Description
//*************************************************************
// UM(User Module):top module.
// 
//*************************************************************
//                     Revision List
//*************************************************************
//	rn1: 
//      date:  
//      modifier: 
//      description: 
//////////////////////////////////////////////////////////////
module um(
input clk,
input rst_n, 

output[47:0]  ov_dmac,
output[47:0]  ov_smac, 
output        o_time_slot_switch,
output[9:0]   ov_time_slot, 
output        o_timer_rst,
output[47:0]  ov_syned_global_time,
output        o_s_pulse,
// port02um
input          iv_data_wr_p0,
input  [133:0] iv_data_p0,
input  [18:0]  iv_relative_time_p0,

output [133:0] ov_data_p0,
output         o_data_wr_p0,
input  [6:0]   iv_fifo_usedw_p0,     
// port12um
input          iv_data_wr_p1,
input  [133:0] iv_data_p1,
input  [18:0]  iv_relative_time_p1,

output [133:0] ov_data_p1,
output         o_data_wr_p1,
input  [6:0]   iv_fifo_usedw_p1,    
// port22um
input          iv_data_wr_p2,
input  [133:0] iv_data_p2,
input  [18:0]  iv_relative_time_p2,

output [133:0] ov_data_p2,
output         o_data_wr_p2,
input  [6:0]   iv_fifo_usedw_p2,   
// port32um
input          iv_data_wr_p3,
input  [133:0] iv_data_p3,
input  [18:0]  iv_relative_time_p3,

output [133:0] ov_data_p3,
output         o_data_wr_p3,
input  [6:0]   iv_fifo_usedw_p3
);

assign ov_data_p2 = 134'b0;
assign o_data_wr_p2 = 1'b0;
//lcm-pgm
wire          lcm2pgm_addr_shift;
wire          test_start; 
wire          lau_update_finish;
wire          w_reg_rst;

wire   [11:0] lcm2pgm_pkt_1_len;
wire   [11:0] lcm2pgm_pkt_2_len;
wire   [11:0] lcm2pgm_pkt_3_len;
wire   [11:0] lcm2pgm_pkt_4_len;
wire   [11:0] lcm2pgm_pkt_5_len;
wire   [11:0] lcm2pgm_pkt_6_len;
wire   [11:0] lcm2pgm_pkt_7_len;
wire   [11:0] lcm2pgm_pkt_8_len;
 
wire   [15:0] lcm2pgm_tb_1_size; 
wire   [15:0] lcm2pgm_tb_1_rate;
wire   [15:0] lcm2pgm_tb_2_size; 
wire   [15:0] lcm2pgm_tb_2_rate;
wire   [15:0] lcm2pgm_tb_3_size; 
wire   [15:0] lcm2pgm_tb_3_rate;
wire   [15:0] lcm2pgm_tb_4_size; 
wire   [15:0] lcm2pgm_tb_4_rate;
wire   [15:0] lcm2pgm_tb_5_size; 
wire   [15:0] lcm2pgm_tb_5_rate;
wire   [15:0] lcm2pgm_tb_6_size; 
wire   [15:0] lcm2pgm_tb_6_rate;
wire   [15:0] lcm2pgm_tb_7_size; 
wire   [15:0] lcm2pgm_tb_7_rate;
wire   [15:0] lcm2pgm_tb_8_size; 
wire   [15:0] lcm2pgm_tb_8_rate;
 
wire   [31:0] pgm2lcm_pkt_1_cnt;
wire   [31:0] pgm2lcm_pkt_2_cnt;
wire   [31:0] pgm2lcm_pkt_3_cnt;
wire   [31:0] pgm2lcm_pkt_4_cnt;
wire   [31:0] pgm2lcm_pkt_5_cnt;
wire   [31:0] pgm2lcm_pkt_6_cnt;
wire   [31:0] pgm2lcm_pkt_7_cnt;
wire   [31:0] pgm2lcm_pkt_8_cnt;
//LCM-FSM  
wire   [31:0] fsm2lcm_pkt_1_cnt;
wire   [31:0] fsm2lcm_pkt_2_cnt;
wire   [31:0] fsm2lcm_pkt_3_cnt;
wire   [31:0] fsm2lcm_pkt_4_cnt;
wire   [31:0] fsm2lcm_pkt_5_cnt;
wire   [31:0] fsm2lcm_pkt_6_cnt;
wire   [31:0] fsm2lcm_pkt_7_cnt;
wire   [31:0] fsm2lcm_pkt_8_cnt;

wire   [103:0]lcm2fsm_rule_5tuple_1;
wire   [103:0]lcm2fsm_mask_1;
wire   [103:0]lcm2fsm_rule_5tuple_2;
wire   [103:0]lcm2fsm_mask_2;
wire   [103:0]lcm2fsm_rule_5tuple_3;
wire   [103:0]lcm2fsm_mask_3;
wire   [103:0]lcm2fsm_rule_5tuple_4;
wire   [103:0]lcm2fsm_mask_4;
wire   [103:0]lcm2fsm_rule_5tuple_5;
wire   [103:0]lcm2fsm_mask_5;
wire   [103:0]lcm2fsm_rule_5tuple_6;
wire   [103:0]lcm2fsm_mask_6;
wire   [103:0]lcm2fsm_rule_5tuple_7;
wire   [103:0]lcm2fsm_mask_7;
wire   [103:0]lcm2fsm_rule_5tuple_8;
wire   [103:0]lcm2fsm_mask_8;
//LCM-SSM 
wire   [15:0] lcm2ssm_samp_freq;
wire   [31:0] ssm2lcm_pkt_cnt;
//LCM to GCL_RAM
wire          lcm2ram_gc_wr;
wire   [4:0]  lcm2ram_gc_addr;
wire   [127:0]lcm2ram_gc;
//GCL_RAM to PGM
wire          ram2pgm_gc_rd;
wire   [4:0]  ram2pgm_gc_addr;
wire   [127:0]ram2pgm_gc;
//LCM to PKT_HDR_RAM
wire          lcm2ram_pkt_hdr_wr;
wire   [5:0]  lcm2ram_pkt_hdr_addr;
wire   [127:0]lcm2ram_pkt_hdr;
//PKT_HDR_RAM to PGM 
wire          ram2pgm_pkt_hdr_rd;
wire   [5:0]  ram2pgm_pkt_hdr_addr;
wire   [127:0]ram2pgm_pkt_hdr;

wire   [1:0]  wv_cfg_finish;

wire   [10:0] wv_time_slot_period;
wire          w_data_lcm_req;
wire          w_data_lcm_ack;
wire   [133:0]wv_data_lcm ; 
wire   [133:0]wv_data_ssm ; 
wire          w_data_ssm_wr;
 
local_control_management local_control_management_inst(
.i_clk(clk),
.i_rst_n(rst_n), 

.ov_dmac(ov_dmac),
.ov_smac(ov_smac), 
.o_time_slot_switch(o_time_slot_switch),
.ov_time_slot_period(wv_time_slot_period),
.ov_time_slot(ov_time_slot), 
.o_timer_rst(o_timer_rst),
.ov_syned_global_time(ov_syned_global_time),
.o_s_pulse(o_s_pulse),
.ov_cfg_finish(wv_cfg_finish),
// port02um

.iv_data_p3(iv_data_p3),//增加
.i_data_wr_p3(iv_data_wr_p3),//增加
.o_data_lcm2mux_req(w_data_lcm_req),//增加
.i_data_mux2lcm_ack(w_data_lcm_ack),//增加
.ov_data_lcm2mux   (wv_data_lcm   ),//增加
.iv_data(iv_data_p0),
.iv_relative_time(iv_relative_time_p0),
.i_data_wr(iv_data_wr_p0),
.o_data_wr(o_data_wr_p0),
.ov_data(ov_data_p0),
.iv_fifo_usedw(iv_fifo_usedw_p0),
//output to PGM
.out_lcm_pkt_1_len(lcm2pgm_pkt_1_len),
.out_lcm_pkt_2_len(lcm2pgm_pkt_2_len),
.out_lcm_pkt_3_len(lcm2pgm_pkt_3_len),
.out_lcm_pkt_4_len(lcm2pgm_pkt_4_len),
.out_lcm_pkt_5_len(lcm2pgm_pkt_5_len),
.out_lcm_pkt_6_len(lcm2pgm_pkt_6_len),
.out_lcm_pkt_7_len(lcm2pgm_pkt_7_len),
.out_lcm_pkt_8_len(lcm2pgm_pkt_8_len),
                   
.out_lcm_tb_1_size(lcm2pgm_tb_1_size), 
.out_lcm_tb_1_rate(lcm2pgm_tb_1_rate),
.out_lcm_tb_2_size(lcm2pgm_tb_2_size), 
.out_lcm_tb_2_rate(lcm2pgm_tb_2_rate),
.out_lcm_tb_3_size(lcm2pgm_tb_3_size), 
.out_lcm_tb_3_rate(lcm2pgm_tb_3_rate),
.out_lcm_tb_4_size(lcm2pgm_tb_4_size), 
.out_lcm_tb_4_rate(lcm2pgm_tb_4_rate),
.out_lcm_tb_5_size(lcm2pgm_tb_5_size), 
.out_lcm_tb_5_rate(lcm2pgm_tb_5_rate),
.out_lcm_tb_6_size(lcm2pgm_tb_6_size), 
.out_lcm_tb_6_rate(lcm2pgm_tb_6_rate),
.out_lcm_tb_7_size(lcm2pgm_tb_7_size), 
.out_lcm_tb_7_rate(lcm2pgm_tb_7_rate),
.out_lcm_tb_8_size(lcm2pgm_tb_8_size), 
.out_lcm_tb_8_rate(lcm2pgm_tb_8_rate),
//output to FSM
.out_lcm_rule_5tuple_1(lcm2fsm_rule_5tuple_1),
.out_lcm_mask_1(lcm2fsm_mask_1),
.out_lcm_rule_5tuple_2(lcm2fsm_rule_5tuple_2),
.out_lcm_mask_2(lcm2fsm_mask_2),
.out_lcm_rule_5tuple_3(lcm2fsm_rule_5tuple_3),
.out_lcm_mask_3(lcm2fsm_mask_3),
.out_lcm_rule_5tuple_4(lcm2fsm_rule_5tuple_4),
.out_lcm_mask_4(lcm2fsm_mask_4),
.out_lcm_rule_5tuple_5(lcm2fsm_rule_5tuple_5),
.out_lcm_mask_5(lcm2fsm_mask_5),
.out_lcm_rule_5tuple_6(lcm2fsm_rule_5tuple_6),
.out_lcm_mask_6(lcm2fsm_mask_6),
.out_lcm_rule_5tuple_7(lcm2fsm_rule_5tuple_7),
.out_lcm_mask_7(lcm2fsm_mask_7),
.out_lcm_rule_5tuple_8(lcm2fsm_rule_5tuple_8),
.out_lcm_mask_8(lcm2fsm_mask_8),
//output to SSM
.out_lcm_samp_freq(lcm2ssm_samp_freq),  //sample a PKT every several PKTs.
/*******************SA*******************/
//receive from PGM
.in_pgm2lcm_pkt_1_cnt(pgm2lcm_pkt_1_cnt),
.in_pgm2lcm_pkt_2_cnt(pgm2lcm_pkt_2_cnt),
.in_pgm2lcm_pkt_3_cnt(pgm2lcm_pkt_3_cnt),
.in_pgm2lcm_pkt_4_cnt(pgm2lcm_pkt_4_cnt),
.in_pgm2lcm_pkt_5_cnt(pgm2lcm_pkt_5_cnt),
.in_pgm2lcm_pkt_6_cnt(pgm2lcm_pkt_6_cnt),
.in_pgm2lcm_pkt_7_cnt(pgm2lcm_pkt_7_cnt),
.in_pgm2lcm_pkt_8_cnt(pgm2lcm_pkt_8_cnt),

.in_fsm2lcm_pkt_1_cnt(fsm2lcm_pkt_1_cnt),
.in_fsm2lcm_pkt_2_cnt(fsm2lcm_pkt_2_cnt),
.in_fsm2lcm_pkt_3_cnt(fsm2lcm_pkt_3_cnt),
.in_fsm2lcm_pkt_4_cnt(fsm2lcm_pkt_4_cnt),
.in_fsm2lcm_pkt_5_cnt(fsm2lcm_pkt_5_cnt),
.in_fsm2lcm_pkt_6_cnt(fsm2lcm_pkt_6_cnt),
.in_fsm2lcm_pkt_7_cnt(fsm2lcm_pkt_7_cnt),
.in_fsm2lcm_pkt_8_cnt(fsm2lcm_pkt_8_cnt), 
//receive from SSM
.in_ssm2lcm_pkt_cnt(ssm2lcm_pkt_cnt),
//transmit to PGM
.out_lcm_addr_shift(lcm2pgm_addr_shift),
.out_lcm_test_start(test_start),
.o_lau_update_finish(lau_update_finish),
.o_reg_rst(w_reg_rst), //to pgm and fsm and ssm.
//transmit to PKT_HDR_RAM
.out_lcm_pkt_hdr_wr(lcm2ram_pkt_hdr_wr),
.out_lcm_pkt_hdr_addr(lcm2ram_pkt_hdr_addr),
.out_lcm_pkt_hdr(lcm2ram_pkt_hdr),
//transmit to GCL_RAM
.out_lcm_gc_wr(lcm2ram_gc_wr),
.out_lcm_gc_addr(lcm2ram_gc_addr),
.out_lcm_gc(lcm2ram_gc)
);            

PGM PGM_inst(
.clk(clk),
.rst_n(rst_n),

.cnt_rst(w_reg_rst),
.timestamp(48'b0),
.i_time_slot_switch(o_time_slot_switch),
.iv_time_slot(ov_time_slot), 
.iv_time_slot_period(wv_time_slot_period),
.in_pgm_addr_shift(lcm2pgm_addr_shift),
.in_pgm_test_start(test_start), 
.lau_update_finish(lau_update_finish),
.iv_cfg_finish(wv_cfg_finish),
   
.in_pgm_pkt_1_len(lcm2pgm_pkt_1_len),
.in_pgm_pkt_2_len(lcm2pgm_pkt_2_len),
.in_pgm_pkt_3_len(lcm2pgm_pkt_3_len),
.in_pgm_pkt_4_len(lcm2pgm_pkt_4_len),
.in_pgm_pkt_5_len(lcm2pgm_pkt_5_len),
.in_pgm_pkt_6_len(lcm2pgm_pkt_6_len),
.in_pgm_pkt_7_len(lcm2pgm_pkt_7_len),
.in_pgm_pkt_8_len(lcm2pgm_pkt_8_len),
                  
.in_pgm_tb_1_size(lcm2pgm_tb_1_size), 
.in_pgm_tb_1_rate(lcm2pgm_tb_1_rate),
.in_pgm_tb_2_size(lcm2pgm_tb_2_size), 
.in_pgm_tb_2_rate(lcm2pgm_tb_2_rate),
.in_pgm_tb_3_size(lcm2pgm_tb_3_size), 
.in_pgm_tb_3_rate(lcm2pgm_tb_3_rate),
.in_pgm_tb_4_size(lcm2pgm_tb_4_size), 
.in_pgm_tb_4_rate(lcm2pgm_tb_4_rate),
.in_pgm_tb_5_size(lcm2pgm_tb_5_size), 
.in_pgm_tb_5_rate(lcm2pgm_tb_5_rate),
.in_pgm_tb_6_size(lcm2pgm_tb_6_size), 
.in_pgm_tb_6_rate(lcm2pgm_tb_6_rate),
.in_pgm_tb_7_size(lcm2pgm_tb_7_size), 
.in_pgm_tb_7_rate(lcm2pgm_tb_7_rate),
.in_pgm_tb_8_size(lcm2pgm_tb_8_size), 
.in_pgm_tb_8_rate(lcm2pgm_tb_8_rate),

.out_pgm_pkt_1_cnt(pgm2lcm_pkt_1_cnt),
.out_pgm_pkt_2_cnt(pgm2lcm_pkt_2_cnt),
.out_pgm_pkt_3_cnt(pgm2lcm_pkt_3_cnt),
.out_pgm_pkt_4_cnt(pgm2lcm_pkt_4_cnt),
.out_pgm_pkt_5_cnt(pgm2lcm_pkt_5_cnt),
.out_pgm_pkt_6_cnt(pgm2lcm_pkt_6_cnt),
.out_pgm_pkt_7_cnt(pgm2lcm_pkt_7_cnt),
.out_pgm_pkt_8_cnt(pgm2lcm_pkt_8_cnt),

.in_pgm_fifo_usedw(iv_fifo_usedw_p1), 

.out_pgm_gcl_rd(ram2pgm_gc_rd),   
.out_pgm_gcl_addr(ram2pgm_gc_addr),    
.in_pgm_gc(ram2pgm_gc),         

.out_pgm_pkt_hdr_rd(ram2pgm_pkt_hdr_rd),
.out_pgm_pkt_hdr_addr(ram2pgm_pkt_hdr_addr),
.in_pgm_pkt_hdr(ram2pgm_pkt_hdr),

.out_pgm_data(ov_data_p1 ),
.out_pgm_data_wr(o_data_wr_p1),
.out_pgm_data_valid(),
.out_pgm_data_valid_wr()
);

fsm fsm_1_inst(
.clk(clk),
.rst_n(rst_n),

//.in_fsm_test_start(test_start), 
.cnt_rst(w_reg_rst),
.pktin_data(iv_data_p2),
.pktin_data_wr(iv_data_wr_p2),

.lcm2fsm_5tuple(lcm2fsm_rule_5tuple_1),
.lcm2fsm_5tuplemask(lcm2fsm_mask_1),

.fsm_byte_num(),
.fsm_pkt_num(fsm2lcm_pkt_1_cnt)
);

fsm fsm_2_inst(
.clk(clk),
.rst_n(rst_n),

//.in_fsm_test_start(test_start), 
.cnt_rst(w_reg_rst),
.pktin_data(iv_data_p2),
.pktin_data_wr(iv_data_wr_p2),

.lcm2fsm_5tuple(lcm2fsm_rule_5tuple_2),
.lcm2fsm_5tuplemask(lcm2fsm_mask_2),

.fsm_byte_num(),
.fsm_pkt_num(fsm2lcm_pkt_2_cnt)
);

fsm fsm_3_inst(
.clk(clk),
.rst_n(rst_n),

//.in_fsm_test_start(test_start), 
.cnt_rst(w_reg_rst),
.pktin_data(iv_data_p2),
.pktin_data_wr(iv_data_wr_p2),

.lcm2fsm_5tuple(lcm2fsm_rule_5tuple_3),
.lcm2fsm_5tuplemask(lcm2fsm_mask_3),

.fsm_byte_num(),
.fsm_pkt_num(fsm2lcm_pkt_3_cnt)
);

fsm fsm_4_inst(
.clk(clk),
.rst_n(rst_n),

//.in_fsm_test_start(test_start), 
.cnt_rst(w_reg_rst),
.pktin_data(iv_data_p2),
.pktin_data_wr(iv_data_wr_p2),

.lcm2fsm_5tuple(lcm2fsm_rule_5tuple_4),
.lcm2fsm_5tuplemask(lcm2fsm_mask_4),

.fsm_byte_num(),
.fsm_pkt_num(fsm2lcm_pkt_4_cnt)
);

fsm fsm_5_inst(
.clk(clk),
.rst_n(rst_n),

//.in_fsm_test_start(test_start), 
.cnt_rst(w_reg_rst),
.pktin_data(iv_data_p2),
.pktin_data_wr(iv_data_wr_p2),

.lcm2fsm_5tuple(lcm2fsm_rule_5tuple_5),
.lcm2fsm_5tuplemask(lcm2fsm_mask_5),

.fsm_byte_num(),
.fsm_pkt_num(fsm2lcm_pkt_5_cnt)
);

fsm fsm_6_inst(
.clk(clk),
.rst_n(rst_n),

//.in_fsm_test_start(test_start), 
.cnt_rst(w_reg_rst),
.pktin_data(iv_data_p2),
.pktin_data_wr(iv_data_wr_p2),

.lcm2fsm_5tuple(lcm2fsm_rule_5tuple_6),
.lcm2fsm_5tuplemask(lcm2fsm_mask_6),

.fsm_byte_num(),
.fsm_pkt_num(fsm2lcm_pkt_6_cnt)
);

fsm fsm_7_inst(
.clk(clk),
.rst_n(rst_n),

//.in_fsm_test_start(test_start), 
.cnt_rst(w_reg_rst),
.pktin_data(iv_data_p2),
.pktin_data_wr(iv_data_wr_p2),

.lcm2fsm_5tuple(lcm2fsm_rule_5tuple_7),
.lcm2fsm_5tuplemask(lcm2fsm_mask_7),

.fsm_byte_num(),
.fsm_pkt_num(fsm2lcm_pkt_7_cnt)
);

fsm fsm_8_inst(
.clk(clk),
.rst_n(rst_n),

//.in_fsm_test_start(test_start), 
.cnt_rst(w_reg_rst),
.pktin_data(iv_data_p2),
.pktin_data_wr(iv_data_wr_p2),

.lcm2fsm_5tuple(lcm2fsm_rule_5tuple_8),
.lcm2fsm_5tuplemask(lcm2fsm_mask_8),

.fsm_byte_num(),
.fsm_pkt_num(fsm2lcm_pkt_8_cnt)
);

ssm ssm_inst(
.clk(clk),
.rst_n(rst_n),

.cnt_rst(w_reg_rst),
//.in_fsm_test_start(test_start), 
.iv_dmac(ov_dmac),
.iv_smac(ov_smac),
.pktin_data(iv_data_p2),
.pktin_data_wr(iv_data_wr_p2),

.lcm2ssm_time(ov_syned_global_time),
.sample_freq(lcm2ssm_samp_freq),
.pkt_num(ssm2lcm_pkt_cnt),

.pktout_data   (wv_data_ssm  ),
.pktout_data_wr(w_data_ssm_wr),
//.pktout_data(ov_data_p3),
//.pktout_data_wr(o_data_wr_p3),
.pktout_data_valid(),
.pktout_data_valid_wr()
); 

nic_mux nic_mux_inst( //新增
.i_clk(clk),
.i_rst_n(rst_n),
.i_data_lcm_req(w_data_lcm_req),
.o_data_lcm_ack(w_data_lcm_ack),
.iv_data_lcm   (wv_data_lcm   ),
.iv_data_ssm   (wv_data_ssm   ),
.i_data_ssm_wr (w_data_ssm_wr ),
.ov_data(ov_data_p3),
.o_data_wr(o_data_wr_p3)
);
/*
ram_128_32 cache_gcl(    
.clka(clk),
.ena(lcm2ram_gc_wr),
.dina(lcm2ram_gc),
.wea(1'b1),
.addra(lcm2ram_gc_addr),	
   
.clkb(clk),
.enb(ram2pgm_gc_rd),
.addrb(ram2pgm_gc_addr),
.doutb(ram2pgm_gc)    
);
*/
ram_sdport_w128d32 ram_sdport_w128d32_inst(
.data(lcm2ram_gc),      //  ram_input.datain
.wraddress(lcm2ram_gc_addr), //           .wraddress
.rdaddress(ram2pgm_gc_addr), //           .rdaddress
.wren(lcm2ram_gc_wr),      //           .wren
.clock(clk),     //           .clock
.rden(ram2pgm_gc_rd),      //           .rden
.q(ram2pgm_gc)          // ram_output.dataout
);
/*
ram_128_64 cache_pkt_hdr(    
.clka(clk),
.ena(lcm2ram_pkt_hdr_wr),
.dina(lcm2ram_pkt_hdr),
.wea(1'b1),
.addra(lcm2ram_pkt_hdr_addr),	
   
.clkb(clk),
.enb(ram2pgm_pkt_hdr_rd),
.addrb(ram2pgm_pkt_hdr_addr),
.doutb(ram2pgm_pkt_hdr)    
);
*/
ram_sdport_w128d64 ram_sdport_w128d64_inst(
.data(lcm2ram_pkt_hdr),      //  ram_input.datain
.wraddress(lcm2ram_pkt_hdr_addr), //           .wraddress
.rdaddress(ram2pgm_pkt_hdr_addr), //           .rdaddress
.wren(lcm2ram_pkt_hdr_wr),      //           .wren
.clock(clk),     //           .clock
.rden(ram2pgm_pkt_hdr_rd),      //           .rden
.q(ram2pgm_pkt_hdr)          // ram_output.dataout
);
endmodule



