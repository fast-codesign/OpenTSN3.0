/////////////////////////////////////////////////////////////////
// NUDT.  All rights reserved.
//*************************************************************
//                     Basic Information
//*************************************************************
//Vendor: NUDT
//FAST URL://www.fastswitch.org 
//Target Device: Xilinx
//Filename: LCM.v
//Version: 1.0
//date: 2019/08/12
//Author : Peng Jintao
//*************************************************************
//                     Module Description
//*************************************************************
// LCM(Local Control Module):top module.
// 
//*************************************************************
//                     Revision List
//*************************************************************
//	rn1: 
//      date: 
//      modifier: 
//      description: 
//////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module config_state_management(
input              clk,
input              rst_n,

output             o_reg_rst, //to pgm and fsm and ssm.

input        [47:0]iv_dmac,
input        [47:0]iv_smac, 
input              i_time_slot_switch,
input        [9:0] iv_time_slot,
input        [47:0]iv_timestamp,
input              i_report_pulse,  
//receive from FPGA OS
input	     [133:0]in_lcm_data,
input	            in_lcm_data_wr,

output           	o_data_lcm2mux_req,
input               i_data_mux2lcm_ack,
output       [133:0]ov_data_lcm2mux,
/*******************CA*******************/
//output to PGM
output	      [11:0] out_lcm_pkt_1_len,
output	      [11:0] out_lcm_pkt_2_len,
output	      [11:0] out_lcm_pkt_3_len,
output	      [11:0] out_lcm_pkt_4_len,
output	      [11:0] out_lcm_pkt_5_len,
output	      [11:0] out_lcm_pkt_6_len,
output	      [11:0] out_lcm_pkt_7_len,
output	      [11:0] out_lcm_pkt_8_len,

output	 	  [15:0] out_lcm_tb_1_size, 
output	      [15:0] out_lcm_tb_1_rate,
output	 	  [15:0] out_lcm_tb_2_size, 
output	      [15:0] out_lcm_tb_2_rate,
output	 	  [15:0] out_lcm_tb_3_size, 
output	      [15:0] out_lcm_tb_3_rate,
output	 	  [15:0] out_lcm_tb_4_size, 
output	      [15:0] out_lcm_tb_4_rate,
output	 	  [15:0] out_lcm_tb_5_size, 
output	      [15:0] out_lcm_tb_5_rate,
output	 	  [15:0] out_lcm_tb_6_size, 
output	      [15:0] out_lcm_tb_6_rate,
output	 	  [15:0] out_lcm_tb_7_size, 
output	      [15:0] out_lcm_tb_7_rate,
output	 	  [15:0] out_lcm_tb_8_size, 
output	      [15:0] out_lcm_tb_8_rate,
//output to FSM
output	      [103:0]out_lcm_rule_5tuple_1,
output	      [103:0]out_lcm_mask_1,
output	      [103:0]out_lcm_rule_5tuple_2,
output	      [103:0]out_lcm_mask_2,
output	      [103:0]out_lcm_rule_5tuple_3,
output	      [103:0]out_lcm_mask_3,
output	      [103:0]out_lcm_rule_5tuple_4,
output	      [103:0]out_lcm_mask_4,
output	      [103:0]out_lcm_rule_5tuple_5,
output	      [103:0]out_lcm_mask_5,
output	      [103:0]out_lcm_rule_5tuple_6,
output	      [103:0]out_lcm_mask_6,
output	      [103:0]out_lcm_rule_5tuple_7,
output	      [103:0]out_lcm_mask_7,
output	      [103:0]out_lcm_rule_5tuple_8,
output	      [103:0]out_lcm_mask_8,
//output to SSM
output	      [15:0] out_lcm_samp_freq,  //sample a PKT every several PKTs.
/*******************SA*******************/
//receive from PGM
input	      [31:0] in_pgm2lcm_pkt_1_cnt,
input	      [31:0] in_pgm2lcm_pkt_2_cnt,
input	      [31:0] in_pgm2lcm_pkt_3_cnt,
input	      [31:0] in_pgm2lcm_pkt_4_cnt,
input	      [31:0] in_pgm2lcm_pkt_5_cnt,
input	      [31:0] in_pgm2lcm_pkt_6_cnt,
input	      [31:0] in_pgm2lcm_pkt_7_cnt,
input	      [31:0] in_pgm2lcm_pkt_8_cnt,
//receive from FSM
input	      [31:0] in_fsm2lcm_pkt_1_cnt,
input	      [31:0] in_fsm2lcm_pkt_2_cnt,
input	      [31:0] in_fsm2lcm_pkt_3_cnt,
input	      [31:0] in_fsm2lcm_pkt_4_cnt,
input	      [31:0] in_fsm2lcm_pkt_5_cnt,
input	      [31:0] in_fsm2lcm_pkt_6_cnt,
input	      [31:0] in_fsm2lcm_pkt_7_cnt,
input	      [31:0] in_fsm2lcm_pkt_8_cnt,  
//receive from SSM
input	      [31:0] in_ssm2lcm_pkt_cnt,
//transmit to PGM
output	             out_lcm_addr_shift,
output	             out_lcm_test_start,
output               o_lau_update_finish,
//transmit to PKT_HDR_RAM
output	             out_lcm_pkt_hdr_wr,
output	     [5:0]   out_lcm_pkt_hdr_addr,
output	     [127:0] out_lcm_pkt_hdr,
//transmit to GCL_RAM
output	             out_lcm_gc_wr,
output	     [4:0]   out_lcm_gc_addr,
output	     [127:0] out_lcm_gc
//transmit to FPGA OS
//output	     [133:0]out_lcm_data,
//output	            out_lcm_data_wr,
//output	            out_lcm_data_valid,
//output	            out_lcm_data_valid_wr
);
wire   phu_update_finish;
assign out_lcm_test_start = phu_update_finish; //after configuring 8 PKT headers,GCL and cmd array,test starts.
//***************************************************
//        Intermediate variable Declaration
//***************************************************
//all wire/reg/parameter variable 
//should be declare below here 
wire     [7:0]  pkt_hdr_seq;    //used to judge whether 8 PKT headers are cofigured successfully.
wire     [3:0]  gcl_array_seq;  //used to judge whether GCL and cmd array are cofigured successfully.
wire     [19:0] gcl_time_slot_cycle;   //=time_slot/8. support the max time slot is 500 us.
//sub-modules
PHU PHU_inst(
.clk(clk),
.rst_n(rst_n),
.i_lau_update_finish(o_lau_update_finish),
.in_phu_data(in_lcm_data),
.in_phu_data_wr(in_lcm_data_wr),
.out_phu_pkt_hdr_wr(out_lcm_pkt_hdr_wr),
.out_phu_pkt_hdr_addr(out_lcm_pkt_hdr_addr),
.out_phu_pkt_hdr(out_lcm_pkt_hdr),
.out_phu_pkt_hdr_seq(pkt_hdr_seq),
.out_phu_addr_shift(out_lcm_addr_shift),
.out_phu_update_finish(phu_update_finish)
);

LAU LAU_inst(
.clk(clk),
.rst_n(rst_n),
.in_lau_data(in_lcm_data),
.in_lau_data_wr(in_lcm_data_wr),
.out_lau_gc_wr(out_lcm_gc_wr),
.out_lau_gc_addr(out_lcm_gc_addr),
.out_lau_gc(out_lcm_gc),
.out_lau_gcl_array_seq(gcl_array_seq),

.out_lau_gcl_time_slot_cycle(gcl_time_slot_cycle),
.out_lau_pkt_1_len(out_lcm_pkt_1_len),
.out_lau_pkt_2_len(out_lcm_pkt_2_len),
.out_lau_pkt_3_len(out_lcm_pkt_3_len),
.out_lau_pkt_4_len(out_lcm_pkt_4_len),
.out_lau_pkt_5_len(out_lcm_pkt_5_len),
.out_lau_pkt_6_len(out_lcm_pkt_6_len),
.out_lau_pkt_7_len(out_lcm_pkt_7_len),
.out_lau_pkt_8_len(out_lcm_pkt_8_len),

.out_lau_tb_1_size(out_lcm_tb_1_size),
.out_lau_tb_1_rate(out_lcm_tb_1_rate),
.out_lau_tb_2_size(out_lcm_tb_2_size),
.out_lau_tb_2_rate(out_lcm_tb_2_rate),
.out_lau_tb_3_size(out_lcm_tb_3_size),
.out_lau_tb_3_rate(out_lcm_tb_3_rate),
.out_lau_tb_4_size(out_lcm_tb_4_size),
.out_lau_tb_4_rate(out_lcm_tb_4_rate),
.out_lau_tb_5_size(out_lcm_tb_5_size),
.out_lau_tb_5_rate(out_lcm_tb_5_rate),
.out_lau_tb_6_size(out_lcm_tb_6_size),
.out_lau_tb_6_rate(out_lcm_tb_6_rate),
.out_lau_tb_7_size(out_lcm_tb_7_size),
.out_lau_tb_7_rate(out_lcm_tb_7_rate),
.out_lau_tb_8_size(out_lcm_tb_8_size),
.out_lau_tb_8_rate(out_lcm_tb_8_rate),

.out_lau_rule_5tuple_1(out_lcm_rule_5tuple_1),
.out_lau_mask_1(out_lcm_mask_1),
.out_lau_rule_5tuple_2(out_lcm_rule_5tuple_2),
.out_lau_mask_2(out_lcm_mask_2),
.out_lau_rule_5tuple_3(out_lcm_rule_5tuple_3),
.out_lau_mask_3(out_lcm_mask_3),
.out_lau_rule_5tuple_4(out_lcm_rule_5tuple_4),
.out_lau_mask_4(out_lcm_mask_4),
.out_lau_rule_5tuple_5(out_lcm_rule_5tuple_5),
.out_lau_mask_5(out_lcm_mask_5),
.out_lau_rule_5tuple_6(out_lcm_rule_5tuple_6),
.out_lau_mask_6(out_lcm_mask_6),
.out_lau_rule_5tuple_7(out_lcm_rule_5tuple_7),
.out_lau_mask_7(out_lcm_mask_7),
.out_lau_rule_5tuple_8(out_lcm_rule_5tuple_8),
.out_lau_mask_8(out_lcm_mask_8),

.out_lau_samp_freq(out_lcm_samp_freq),

.out_lau_update_finish(o_lau_update_finish)
);

ARM ARM_inst(
.clk(clk),
.rst_n(rst_n),

.i_report_pulse(i_report_pulse),
.o_reg_rst(o_reg_rst),
.in_arm_test_start(out_lcm_test_start),

.in_arm_pkt_hdr_seq(pkt_hdr_seq),
.in_arm_gcl_array_seq(gcl_array_seq),

.in_arm_pkt_1_len(out_lcm_pkt_1_len),
.in_arm_pkt_2_len(out_lcm_pkt_2_len),
.in_arm_pkt_3_len(out_lcm_pkt_3_len),
.in_arm_pkt_4_len(out_lcm_pkt_4_len),
.in_arm_pkt_5_len(out_lcm_pkt_5_len),
.in_arm_pkt_6_len(out_lcm_pkt_6_len),
.in_arm_pkt_7_len(out_lcm_pkt_7_len),
.in_arm_pkt_8_len(out_lcm_pkt_8_len),

.in_arm_tb_1_size(out_lcm_tb_1_size),
.in_arm_tb_1_rate(out_lcm_tb_1_rate),
.in_arm_tb_2_size(out_lcm_tb_2_size),
.in_arm_tb_2_rate(out_lcm_tb_2_rate),
.in_arm_tb_3_size(out_lcm_tb_3_size),
.in_arm_tb_3_rate(out_lcm_tb_3_rate),
.in_arm_tb_4_size(out_lcm_tb_4_size),
.in_arm_tb_4_rate(out_lcm_tb_4_rate),
.in_arm_tb_5_size(out_lcm_tb_5_size),
.in_arm_tb_5_rate(out_lcm_tb_5_rate),
.in_arm_tb_6_size(out_lcm_tb_6_size),
.in_arm_tb_6_rate(out_lcm_tb_6_rate),
.in_arm_tb_7_size(out_lcm_tb_7_size),
.in_arm_tb_7_rate(out_lcm_tb_7_rate),
.in_arm_tb_8_size(out_lcm_tb_8_size),
.in_arm_tb_8_rate(out_lcm_tb_8_rate),

.in_arm_rule_5tuple_1(out_lcm_rule_5tuple_1),
.in_arm_mask_1(out_lcm_mask_1),
.in_arm_rule_5tuple_2(out_lcm_rule_5tuple_2),
.in_arm_mask_2(out_lcm_mask_2),
.in_arm_rule_5tuple_3(out_lcm_rule_5tuple_3),
.in_arm_mask_3(out_lcm_mask_3),
.in_arm_rule_5tuple_4(out_lcm_rule_5tuple_4),
.in_arm_mask_4(out_lcm_mask_4),
.in_arm_rule_5tuple_5(out_lcm_rule_5tuple_5),
.in_arm_mask_5(out_lcm_mask_5),
.in_arm_rule_5tuple_6(out_lcm_rule_5tuple_6),
.in_arm_mask_6(out_lcm_mask_6),
.in_arm_rule_5tuple_7(out_lcm_rule_5tuple_7),
.in_arm_mask_7(out_lcm_mask_7),
.in_arm_rule_5tuple_8(out_lcm_rule_5tuple_8),
.in_arm_mask_8(out_lcm_mask_8),

.in_arm_samp_freq(out_lcm_samp_freq),
.in_pgm2arm_pkt_1_cnt(in_pgm2lcm_pkt_1_cnt),
.in_pgm2arm_pkt_2_cnt(in_pgm2lcm_pkt_2_cnt),
.in_pgm2arm_pkt_3_cnt(in_pgm2lcm_pkt_3_cnt),
.in_pgm2arm_pkt_4_cnt(in_pgm2lcm_pkt_4_cnt),
.in_pgm2arm_pkt_5_cnt(in_pgm2lcm_pkt_5_cnt),
.in_pgm2arm_pkt_6_cnt(in_pgm2lcm_pkt_6_cnt),
.in_pgm2arm_pkt_7_cnt(in_pgm2lcm_pkt_7_cnt),
.in_pgm2arm_pkt_8_cnt(in_pgm2lcm_pkt_8_cnt),

.in_fsm2arm_pkt_1_cnt(in_fsm2lcm_pkt_1_cnt),
.in_fsm2arm_pkt_2_cnt(in_fsm2lcm_pkt_2_cnt),
.in_fsm2arm_pkt_3_cnt(in_fsm2lcm_pkt_3_cnt),
.in_fsm2arm_pkt_4_cnt(in_fsm2lcm_pkt_4_cnt),
.in_fsm2arm_pkt_5_cnt(in_fsm2lcm_pkt_5_cnt),
.in_fsm2arm_pkt_6_cnt(in_fsm2lcm_pkt_6_cnt),
.in_fsm2arm_pkt_7_cnt(in_fsm2lcm_pkt_7_cnt),
.in_fsm2arm_pkt_8_cnt(in_fsm2lcm_pkt_8_cnt),

.in_ssm2arm_pkt_cnt(in_ssm2lcm_pkt_cnt),

.in_arm_gcl_time_slot_cycle(gcl_time_slot_cycle),
.iv_timestamp(iv_timestamp),

.iv_dmac(iv_dmac),
.iv_smac(iv_smac),

.o_data_lcm2mux_req(o_data_lcm2mux_req),
.i_data_mux2lcm_ack(i_data_mux2lcm_ack),
.ov_data_lcm2mux(ov_data_lcm2mux)
);

endmodule

