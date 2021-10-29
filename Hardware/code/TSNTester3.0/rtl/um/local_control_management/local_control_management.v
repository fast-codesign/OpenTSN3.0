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
module local_control_management(
input         i_clk,
input         i_rst_n, 

output[47:0]  ov_dmac,
output[47:0]  ov_smac, 
output        o_time_slot_switch,
output[9:0]   ov_time_slot, 
output[10:0]  ov_time_slot_period,
output        o_timer_rst,
output[47:0]  ov_syned_global_time,
output        o_s_pulse,
output[1:0]   ov_cfg_finish,
// port02um
input [133:0] iv_data,
input [18:0]  iv_relative_time,
input         i_data_wr,
input         i_data_wr_p3,//
input [133:0] iv_data_p3,//
output        o_data_wr,
output[133:0] ov_data,
input [6:0]   iv_fifo_usedw,

output       	o_data_lcm2mux_req,
input           i_data_mux2lcm_ack,
output   [133:0]ov_data_lcm2mux,
/*******************CA*******************/
//output to PGM
output [11:0] out_lcm_pkt_1_len,
output [11:0] out_lcm_pkt_2_len,
output [11:0] out_lcm_pkt_3_len,
output [11:0] out_lcm_pkt_4_len,
output [11:0] out_lcm_pkt_5_len,
output [11:0] out_lcm_pkt_6_len,
output [11:0] out_lcm_pkt_7_len,
output [11:0] out_lcm_pkt_8_len,

output [15:0] out_lcm_tb_1_size, 
output [15:0] out_lcm_tb_1_rate,
output [15:0] out_lcm_tb_2_size, 
output [15:0] out_lcm_tb_2_rate,
output [15:0] out_lcm_tb_3_size, 
output [15:0] out_lcm_tb_3_rate,
output [15:0] out_lcm_tb_4_size, 
output [15:0] out_lcm_tb_4_rate,
output [15:0] out_lcm_tb_5_size, 
output [15:0] out_lcm_tb_5_rate,
output [15:0] out_lcm_tb_6_size, 
output [15:0] out_lcm_tb_6_rate,
output [15:0] out_lcm_tb_7_size, 
output [15:0] out_lcm_tb_7_rate,
output [15:0] out_lcm_tb_8_size, 
output [15:0] out_lcm_tb_8_rate,
//output to FSM
output [103:0]out_lcm_rule_5tuple_1,
output [103:0]out_lcm_mask_1,
output [103:0]out_lcm_rule_5tuple_2,
output [103:0]out_lcm_mask_2,
output [103:0]out_lcm_rule_5tuple_3,
output [103:0]out_lcm_mask_3,
output [103:0]out_lcm_rule_5tuple_4,
output [103:0]out_lcm_mask_4,
output [103:0]out_lcm_rule_5tuple_5,
output [103:0]out_lcm_mask_5,
output [103:0]out_lcm_rule_5tuple_6,
output [103:0]out_lcm_mask_6,
output [103:0]out_lcm_rule_5tuple_7,
output [103:0]out_lcm_mask_7,
output [103:0]out_lcm_rule_5tuple_8,
output [103:0]out_lcm_mask_8,
//output to SSM
output [15:0] out_lcm_samp_freq,  //sample a PKT every several PKTs.
/*******************SA*******************/
//receive from PGM
input  [31:0] in_pgm2lcm_pkt_1_cnt,
input  [31:0] in_pgm2lcm_pkt_2_cnt,
input  [31:0] in_pgm2lcm_pkt_3_cnt,
input  [31:0] in_pgm2lcm_pkt_4_cnt,
input  [31:0] in_pgm2lcm_pkt_5_cnt,
input  [31:0] in_pgm2lcm_pkt_6_cnt,
input  [31:0] in_pgm2lcm_pkt_7_cnt,
input  [31:0] in_pgm2lcm_pkt_8_cnt,
//receive from FSM
input  [31:0] in_fsm2lcm_pkt_1_cnt,
input  [31:0] in_fsm2lcm_pkt_2_cnt,
input  [31:0] in_fsm2lcm_pkt_3_cnt,
input  [31:0] in_fsm2lcm_pkt_4_cnt,
input  [31:0] in_fsm2lcm_pkt_5_cnt,
input  [31:0] in_fsm2lcm_pkt_6_cnt,
input  [31:0] in_fsm2lcm_pkt_7_cnt,
input  [31:0] in_fsm2lcm_pkt_8_cnt,   
//receive from SSM
input  [31:0] in_ssm2lcm_pkt_cnt,
//transmit to PGM
output        out_lcm_addr_shift,
output        out_lcm_test_start,
output        o_lau_update_finish,
output	      o_reg_rst, //to pgm and fsm and ssm.
//transmit to PKT_HDR_RAM
output        out_lcm_pkt_hdr_wr,
output [5:0]  out_lcm_pkt_hdr_addr,
output [127:0]out_lcm_pkt_hdr,
//transmit to GCL_RAM
output        out_lcm_gc_wr,
output [4:0]  out_lcm_gc_addr,
output [127:0]out_lcm_gc
);
//dmux to fem/fdm/lcm/npm
wire   [133:0]wv_data;
wire  	      w_data_csm_wr;
wire  	      w_data_npm_wr;
wire  	      w_data_fem_wr;
wire  	      w_data_fdm_wr;
wire   [18:0] wv_relative_time;

//configure regist
wire [48:0]      wv_time_offset;
wire             w_time_offset_wr;
wire [10:0]      wv_slot_len;
wire [23:0]      wv_offset_period;
wire [11:0]      wv_report_period;
//lcm/fem/fdm to mux
wire        	  w_data_lcm2mux_req;
wire              w_data_mux2lcm_ack;
wire  [133:0]	  wv_data_lcm2mux;

wire  [133:0]	  wv_data_fem2mux;
wire	          w_data_fem2mux_wr;

wire  [133:0]	  wv_data_fdm2mux;
wire	          w_data_fdm2mux_wr;

wire  [133:0]	  wv_data_mux2iop;
wire 	          w_data_mux2iop_wr;
dmux dmux_inst
(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data(iv_data),
.iv_relative_time(iv_relative_time),
.i_data_wr(i_data_wr),

.ov_relative_time(wv_relative_time),

.ov_data(wv_data),
.o_data_csm_wr(w_data_csm_wr),
.o_data_npm_wr(w_data_npm_wr),
.o_data_fem_wr(w_data_fem_wr),
.o_data_fdm_wr(w_data_fdm_wr)
);

frame_decapsulation_module frame_decapsulation_module_inst
(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.i_timer_rst(o_timer_rst),
.iv_syned_global_time(ov_syned_global_time),
.iv_data(wv_data),
.iv_relative_time(wv_relative_time),
.i_data_wr(w_data_fdm_wr),

.ov_data(wv_data_fdm2mux),
.o_data_wr(w_data_fdm2mux_wr)
);

frame_encapsulation_module frame_encapsulation_module_inst
(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_dmac(ov_dmac),
.iv_smac(ov_smac),

.i_timer_rst(o_timer_rst),
.iv_syned_global_time(ov_syned_global_time),
 
.iv_data(wv_data),
.iv_relative_time(wv_relative_time),       
.i_data_wr(w_data_fem_wr),

.ov_data(wv_data_fem2mux),
.o_data_wr(w_data_fem2mux_wr)   
);

nmac_parse_module nmac_parse_module_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data(wv_data),
.i_data_wr(w_data_npm_wr),   

.i_reg_rst(o_reg_rst),
.ov_time_offset(wv_time_offset),
.o_time_offset_wr(w_time_offset_wr),
.ov_cfg_finish(ov_cfg_finish),
.ov_slot_len(wv_slot_len),
.ov_inject_slot_period(ov_time_slot_period),

.ov_offset_period(wv_offset_period),
.ov_report_period(wv_report_period),

.ov_nmac_dmac(ov_dmac),
.ov_nmac_smac(ov_smac)
);
 
config_state_management  config_state_management_inst(
.clk(i_clk),
.rst_n(i_rst_n),

.iv_dmac(ov_dmac),
.iv_smac(ov_smac),

.in_lcm_data(iv_data_p3),    
.in_lcm_data_wr(i_data_wr_p3),

//.in_lcm_data(wv_data),
//.in_lcm_data_wr(w_data_csm_wr),

.i_time_slot_switch(o_time_slot_switch),
.iv_time_slot(ov_time_slot),
.iv_timestamp(ov_syned_global_time),
.i_report_pulse(o_s_pulse),

.out_lcm_pkt_1_len(out_lcm_pkt_1_len),
.out_lcm_pkt_2_len(out_lcm_pkt_2_len),
.out_lcm_pkt_3_len(out_lcm_pkt_3_len),
.out_lcm_pkt_4_len(out_lcm_pkt_4_len),
.out_lcm_pkt_5_len(out_lcm_pkt_5_len),
.out_lcm_pkt_6_len(out_lcm_pkt_6_len),
.out_lcm_pkt_7_len(out_lcm_pkt_7_len),
.out_lcm_pkt_8_len(out_lcm_pkt_8_len),

.out_lcm_tb_1_size(out_lcm_tb_1_size), 
.out_lcm_tb_1_rate(out_lcm_tb_1_rate),
.out_lcm_tb_2_size(out_lcm_tb_2_size), 
.out_lcm_tb_2_rate(out_lcm_tb_2_rate),
.out_lcm_tb_3_size(out_lcm_tb_3_size), 
.out_lcm_tb_3_rate(out_lcm_tb_3_rate),
.out_lcm_tb_4_size(out_lcm_tb_4_size), 
.out_lcm_tb_4_rate(out_lcm_tb_4_rate),
.out_lcm_tb_5_size(out_lcm_tb_5_size), 
.out_lcm_tb_5_rate(out_lcm_tb_5_rate),
.out_lcm_tb_6_size(out_lcm_tb_6_size), 
.out_lcm_tb_6_rate(out_lcm_tb_6_rate),
.out_lcm_tb_7_size(out_lcm_tb_7_size), 
.out_lcm_tb_7_rate(out_lcm_tb_7_rate),
.out_lcm_tb_8_size(out_lcm_tb_8_size), 
.out_lcm_tb_8_rate(out_lcm_tb_8_rate),

.out_lcm_rule_5tuple_1(out_lcm_rule_5tuple_1),
.out_lcm_mask_1(out_lcm_mask_1),
.out_lcm_rule_5tuple_2(out_lcm_rule_5tuple_2),
.out_lcm_mask_2(out_lcm_mask_2),
.out_lcm_rule_5tuple_3(out_lcm_rule_5tuple_3),
.out_lcm_mask_3(out_lcm_mask_3),
.out_lcm_rule_5tuple_4(out_lcm_rule_5tuple_4),
.out_lcm_mask_4(out_lcm_mask_4),
.out_lcm_rule_5tuple_5(out_lcm_rule_5tuple_5),
.out_lcm_mask_5(out_lcm_mask_5),
.out_lcm_rule_5tuple_6(out_lcm_rule_5tuple_6),
.out_lcm_mask_6(out_lcm_mask_6),
.out_lcm_rule_5tuple_7(out_lcm_rule_5tuple_7),
.out_lcm_mask_7(out_lcm_mask_7),
.out_lcm_rule_5tuple_8(out_lcm_rule_5tuple_8),
.out_lcm_mask_8(out_lcm_mask_8),

.out_lcm_samp_freq(out_lcm_samp_freq),

.in_pgm2lcm_pkt_1_cnt(in_pgm2lcm_pkt_1_cnt),
.in_pgm2lcm_pkt_2_cnt(in_pgm2lcm_pkt_2_cnt),
.in_pgm2lcm_pkt_3_cnt(in_pgm2lcm_pkt_3_cnt),
.in_pgm2lcm_pkt_4_cnt(in_pgm2lcm_pkt_4_cnt),
.in_pgm2lcm_pkt_5_cnt(in_pgm2lcm_pkt_5_cnt),
.in_pgm2lcm_pkt_6_cnt(in_pgm2lcm_pkt_6_cnt),
.in_pgm2lcm_pkt_7_cnt(in_pgm2lcm_pkt_7_cnt),
.in_pgm2lcm_pkt_8_cnt(in_pgm2lcm_pkt_8_cnt),

.in_fsm2lcm_pkt_1_cnt(in_fsm2lcm_pkt_1_cnt),
.in_fsm2lcm_pkt_2_cnt(in_fsm2lcm_pkt_2_cnt),
.in_fsm2lcm_pkt_3_cnt(in_fsm2lcm_pkt_3_cnt),
.in_fsm2lcm_pkt_4_cnt(in_fsm2lcm_pkt_4_cnt),
.in_fsm2lcm_pkt_5_cnt(in_fsm2lcm_pkt_5_cnt),
.in_fsm2lcm_pkt_6_cnt(in_fsm2lcm_pkt_6_cnt),
.in_fsm2lcm_pkt_7_cnt(in_fsm2lcm_pkt_7_cnt),
.in_fsm2lcm_pkt_8_cnt(in_fsm2lcm_pkt_8_cnt),

.in_ssm2lcm_pkt_cnt(in_ssm2lcm_pkt_cnt),

.out_lcm_addr_shift(out_lcm_addr_shift),                    
.out_lcm_test_start(out_lcm_test_start),
.o_lau_update_finish(o_lau_update_finish),

.o_reg_rst(o_reg_rst),

.out_lcm_pkt_hdr_wr(out_lcm_pkt_hdr_wr),
.out_lcm_pkt_hdr_addr(out_lcm_pkt_hdr_addr),
.out_lcm_pkt_hdr(out_lcm_pkt_hdr),

.out_lcm_gc_wr(out_lcm_gc_wr),
.out_lcm_gc_addr(out_lcm_gc_addr),
.out_lcm_gc(out_lcm_gc),

.o_data_lcm2mux_req(o_data_lcm2mux_req),//
.i_data_mux2lcm_ack(i_data_mux2lcm_ack),//
.ov_data_lcm2mux(ov_data_lcm2mux)//
);

mux mux_inst
(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.i_data_lcm_req(1'b0),//
.o_data_lcm_ack(),//
.iv_data_lcm(134'b0),//

.iv_data_fem(wv_data_fem2mux),
.i_data_fem_wr(w_data_fem2mux_wr),

.iv_data_fdm(wv_data_fdm2mux),
.i_data_fdm_wr(w_data_fdm2mux_wr),

.ov_data(ov_data),
.o_data_wr(o_data_wr)
);
global_time_sync global_time_sync_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.i_reg_rst(o_reg_rst),
.iv_time_offset(wv_time_offset),
.i_time_offset_wr(w_time_offset_wr),
.iv_offset_period(wv_offset_period),
.pluse_s(o_s_pulse),
.iv_cfg_finish(ov_cfg_finish),
.iv_report_period(wv_report_period),

.ov_syned_time(ov_syned_global_time),
.o_timer_reset_pluse(o_timer_rst)
);

time_slot_calculation time_slot_calculation_inst
(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_syned_global_time(ov_syned_global_time),
.iv_time_slot_length(wv_slot_len),

.iv_table_period(ov_time_slot_period),

.ov_time_slot(ov_time_slot),
.o_time_slot_switch(o_time_slot_switch)       
);
endmodule



