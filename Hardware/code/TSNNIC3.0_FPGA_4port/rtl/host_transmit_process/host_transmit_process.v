// Copyright (C) 1953-2020 NUDT
// Verilog module name - host_transmit_process 
// Version: HTP_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         transmit process of host.
//             -top module.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module host_transmit_process
(
       i_clk,
       i_rst_n,
          
       i_host_gmii_tx_clk,
       i_gmii_rst_n_host,
       
       iv_tsntag_hcp,
       iv_bufid_hcp,
       i_descriptor_wr_hcp,
       o_descriptor_ack_hcp,

       iv_tsntag_network,
       iv_bufid_network,
       i_descriptor_wr_network,
       o_descriptor_ack_network,
      
       iv_cfg_finish,
       
       iv_regroup_ram_wdata,
       i_regroup_ram_wr,
       iv_regroup_ram_addr,
       ov_regroup_ram_rdata,
       i_regroup_ram_rd,
       
       ov_pkt_bufid,
       o_pkt_bufid_wr,
       i_pkt_bufid_ack, 
       
       ov_pkt_raddr,
       o_pkt_rd,
       i_pkt_raddr_ack,
       
       iv_pkt_data,
       i_pkt_data_wr,

       o_pkt_cnt_pulse,
       o_host_inqueue_discard_pulse,     
       o_fifo_overflow_pulse,       
       
       o_ts_underflow_error_pulse,
       o_ts_overflow_error_pulse, 
       
       ov_gmii_txd,
       o_gmii_tx_en,
       o_gmii_tx_er,
       o_gmii_tx_clk,
       
       iv_syned_global_time,
       i_timer_rst,       
       iv_time_slot_length,
       
       hos_state,
       hoi_state,
       bufid_state,
       pkt_read_state,
       tsm_state,
       ssm_state,  
       
       iv_submit_slot_table_wdata,
       i_submit_slot_table_wr,
       iv_submit_slot_table_addr,
       ov_submit_slot_table_rdata,
       i_submit_slot_table_rd,
       iv_submit_slot_table_period      
);

// I/O
// clk & rst
input                  i_clk;   
input                  i_rst_n;
//configuration finish and time synchronization finish
input      [1:0]       iv_cfg_finish; 
// clock of gmii_tx
input                  i_host_gmii_tx_clk;
input                  i_gmii_rst_n_host;
//tsntag & bufid input from host_port
input      [47:0]      iv_tsntag_hcp;
input      [8:0]       iv_bufid_hcp;
input                  i_descriptor_wr_hcp;
output                 o_descriptor_ack_hcp;
//tsntag & bufid input from hcp_port
input      [47:0]      iv_tsntag_network;
input      [8:0]       iv_bufid_network;
input                  i_descriptor_wr_network;
output                 o_descriptor_ack_network;
//ram write - porta 
input       [61:0]	   iv_regroup_ram_wdata;
input       	       i_regroup_ram_wr;
input       [7:0]	   iv_regroup_ram_addr;
output      [61:0]     ov_regroup_ram_rdata;
input                  i_regroup_ram_rd;
//receive pkt from PCB  
input       [133:0]    iv_pkt_data;
input                  i_pkt_data_wr;

output                 o_pkt_cnt_pulse;
output                 o_host_inqueue_discard_pulse; 
output                 o_fifo_overflow_pulse;
// pkt_bufid to PCB in order to release pkt_bufid
output     [8:0]       ov_pkt_bufid;
output                 o_pkt_bufid_wr;
input                  i_pkt_bufid_ack; 
// read address to PCB in order to read pkt data       
output     [15:0]      ov_pkt_raddr;
output                 o_pkt_rd;
input                  i_pkt_raddr_ack;
// reset signal of local timer 
input                  i_timer_rst;  
// synchronized global time 
input      [47:0]      iv_syned_global_time;

input      [10:0]      iv_time_slot_length;
// transmit pkt to phy     
output     [7:0]       ov_gmii_txd;
output                 o_gmii_tx_en;
output                 o_gmii_tx_er;
output                 o_gmii_tx_clk;

output     [1:0]       hos_state;
output     [3:0]       hoi_state;
output     [1:0]       bufid_state;
output     [2:0]       pkt_read_state;
output     [2:0]       tsm_state;
output     [2:0]       ssm_state; 

input      [15:0]      iv_submit_slot_table_wdata;
input                  i_submit_slot_table_wr;
input      [9:0]       iv_submit_slot_table_addr;
output     [15:0]      ov_submit_slot_table_rdata;
input                  i_submit_slot_table_rd;
input      [10:0]      iv_submit_slot_table_period;

output                 o_ts_underflow_error_pulse;
output                 o_ts_overflow_error_pulse;

wire       [12:0]      wv_nts_descriptor_wdata;
wire                   w_nts_descriptor_wr;

wire       [31:0]      wv_ts_cnt; 

wire       [22:0]      wv_descriptor_hqm2fim;
wire                   w_descriptor_wr_hqm2fim;
wire                   w_descriptor_ready_fim2hqm;

wire       [47:0]	   wv_dmac_fim2htx;
wire       [8:0]	   wv_bufid_fim2htx;
wire                   w_lookup_table_match_flag_fim2htx;
wire                   w_descriptor_wr_fim2htx;
wire                   w_descriptor_ready_htx2fim;
host_queue_management host_queue_management_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_tsntag_hcp(iv_tsntag_hcp),
.iv_bufid_hcp(iv_bufid_hcp),
.i_descriptor_wr_hcp(i_descriptor_wr_hcp),
.o_descriptor_ack_hcp(o_descriptor_ack_hcp),

.iv_tsntag_network(iv_tsntag_network),
.iv_bufid_network(iv_bufid_network),
.i_descriptor_wr_network(i_descriptor_wr_network),
.o_descriptor_ack_network(o_descriptor_ack_network),

.ov_descriptor(wv_descriptor_hqm2fim),
.o_descriptor_wr(w_descriptor_wr_hqm2fim),
.i_descriptor_ready(w_descriptor_ready_fim2hqm)
);
frame_inverse_mapping frame_inverse_mapping_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_descriptor(wv_descriptor_hqm2fim),
.i_descriptor_wr(w_descriptor_wr_hqm2fim),
.o_descriptor_ready(w_descriptor_ready_fim2hqm),

.iv_regroup_ram_wdata(iv_regroup_ram_wdata),     
.i_regroup_ram_wr(i_regroup_ram_wr),
.iv_regroup_ram_addr(iv_regroup_ram_addr),
.ov_regroup_ram_rdata(ov_regroup_ram_rdata),
.i_regroup_ram_rd(i_regroup_ram_rd),

.ov_dmac(wv_dmac_fim2htx),
.ov_bufid(wv_bufid_fim2htx),
.o_lookup_table_match_flag(w_lookup_table_match_flag_fim2htx),
.o_descriptor_wr(w_descriptor_wr_fim2htx),
.i_descriptor_ready(w_descriptor_ready_htx2fim)
);
host_tx host_tx_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.i_host_gmii_tx_clk(i_host_gmii_tx_clk),
.i_gmii_rst_n_host(i_gmii_rst_n_host),

.iv_pkt_descriptor({wv_dmac_fim2htx,~w_lookup_table_match_flag_fim2htx,~w_lookup_table_match_flag_fim2htx,~w_lookup_table_match_flag_fim2htx,~w_lookup_table_match_flag_fim2htx,wv_bufid_fim2htx}),
.i_pkt_descriptor_wr(w_descriptor_wr_fim2htx),
.o_pkt_descriptor_ready(w_descriptor_ready_htx2fim),

.ov_pkt_bufid(ov_pkt_bufid),
.o_pkt_bufid_wr(o_pkt_bufid_wr),
.i_pkt_bufid_ack(i_pkt_bufid_ack),  

.ov_pkt_raddr(ov_pkt_raddr),
.o_pkt_rd(o_pkt_rd),
.i_pkt_raddr_ack(i_pkt_raddr_ack),

.iv_pkt_data(iv_pkt_data),
.i_pkt_data_wr(i_pkt_data_wr),

.o_pkt_cnt_pulse(o_pkt_cnt_pulse),
.o_fifo_overflow_pulse(o_fifo_overflow_pulse),

.ov_gmii_txd(ov_gmii_txd),
.o_gmii_tx_en(o_gmii_tx_en),
.o_gmii_tx_er(o_gmii_tx_er),
.o_gmii_tx_clk(o_gmii_tx_clk),

.i_timer_rst(i_timer_rst), 
.iv_syned_global_time(iv_syned_global_time),

.hoi_state(hoi_state),
.bufid_state(bufid_state),
.pkt_read_state(pkt_read_state),
.ov_debug_ts_cnt(),
.ov_debug_cnt() 
);
/*
ts_submit_schedule ts_submit_schedule_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.iv_cfg_finish(iv_cfg_finish),       
.iv_syned_global_time(iv_syned_global_time),
.iv_time_slot_length(iv_time_slot_length),
    
.i_ts_submit_addr_ack(w_ts_submit_addr_ack),
.ov_ts_submit_addr(wv_ts_submit_addr),
.o_ts_submit_addr_wr(w_ts_submit_addr_wr),

.ssm_state(ssm_state),  
.iv_submit_slot_table_wdata(iv_submit_slot_table_wdata),
.i_submit_slot_table_wr(i_submit_slot_table_wr),
.iv_submit_slot_table_addr(iv_submit_slot_table_addr),
.ov_submit_slot_table_rdata(ov_submit_slot_table_rdata),
.i_submit_slot_table_rd(i_submit_slot_table_rd),
.iv_submit_slot_table_period(iv_submit_slot_table_period)

);

ts_submit_management ts_submit_management_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_pkt_type_hiq(iv_pkt_type),
.iv_ts_submit_addr_hiq(iv_ts_submit_addr),
.i_descriptor_wr_hiq(i_data_wr),

.iv_ts_descriptor(wv_ts_descriptor_wdata_hiq2tsm),
.i_ts_descriptor_wr(w_ts_descriptor_wr_hiq2tsm),
.iv_ts_descriptor_waddr(wv_ts_descriptor_waddr_hiq2tsm),

.iv_ts_submit_addr(wv_ts_submit_addr),
.i_ts_submit_addr_wr(w_ts_submit_addr_wr),
.o_ts_submit_addr_ack(w_ts_submit_addr_ack),

.ov_ts_descriptor(wv_ts_descriptor_tsm2hos),
.o_ts_descriptor_wr(w_ts_descriptor_wr_tsm2hos),
.i_ts_descriptor_ack(w_ts_descriptor_ack),

.ov_ts_cnt(wv_ts_cnt),
.o_ts_underflow_error_pulse(o_ts_underflow_error_pulse),
.tsm_state(tsm_state)    
); 
*/ 
endmodule