// Copyright (C) 1953-2020 NUDT
// Verilog module name - host_receicve_process
// Version: HRP_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         receive and process pkt from host.
//             - top module.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module host_receive_process
(
        i_clk,
        i_rst_n,
        i_gmii_rst_n_host,
        
        i_gmii_rx_clk,
        i_gmii_rx_dv,
        iv_gmii_rxd,
        i_gmii_rx_er,
       
        iv_cfg_finish,        
        i_timer_rst,
        iv_syned_global_time,
        iv_time_slot_length,
        iv_time_slot_period,       
        ov_time_slot,
        o_time_slot_switch,
        
        iv_bufid,
        i_bufid_wr,
        o_bufid_ack,
        
        ov_wdata,
        o_data_wr,
        ov_data_waddr,
        i_wdata_ack,
        
        iv_fmt_ram_addr,
        i_fmt_ram_wr,
        iv_fmt_ram_wdata,
	    ov_fmt_ram_rdata,
	    i_fmt_ram_rd,

        ov_nip_tsntag,
        ov_nip_bufid,
        o_nip_descriptor_wr,
        i_nip_descriptor_ack,
        
        ov_ip_tsntag,
        ov_ip_bufid,
        o_ip_descriptor_wr,
        i_ip_descriptor_ack,  
       
        ov_ts_descriptor,
        o_ts_descriptor_wr,
        i_ts_descriptor_ack,
        
        ov_nts_descriptor,
        o_nts_descriptor_wr,
        i_nts_descriptor_ack,
        
        o_pkt_cnt_pulse,
        o_pkt_discard_cnt_pulse,
        
        o_ts_underflow_error_pulse,
        o_ts_overflow_error_pulse, 
        
        iv_free_bufid_fifo_rdusedw,
        iv_map_req_threshold_value,
        
        prp_state,
        pdi_state,
        tom_state,
        descriptor_state,
        pkt_state,
        transmission_state,
        tim_state,   
        ism_state, 
        
        iv_injection_slot_table_wdata,
        i_injection_slot_table_wr,
        iv_injection_slot_table_addr,
        ov_injection_slot_table_rdata,
        i_injection_slot_table_rd,
    
        o_fifo_overflow_pulse, 
        o_fifo_underflow_pulse         
);
// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n; 
input                  i_gmii_rst_n_host;
//configuration finish and time synchronization finish
input      [1:0]       iv_cfg_finish;  
// send pkt data from gmii     
input      [7:0]       iv_gmii_rxd;
input                  i_gmii_rx_dv;
input                  i_gmii_rx_er;
input                  i_gmii_rx_clk;
// reset signal of local timer 
input                  i_timer_rst;  
// synchronized global time 
input      [47:0]      iv_syned_global_time;
input      [10:0]      iv_time_slot_length;

output     [9:0]       ov_time_slot;
output                 o_time_slot_switch;
// bufid input
input      [8:0]       iv_bufid;
input                  i_bufid_wr;
output                 o_bufid_ack;
// pkt output
output    [133:0]      ov_wdata;
output                 o_data_wr;
output    [15:0]       ov_data_waddr;
input                  i_wdata_ack;
//map table
input      [4:0]       iv_fmt_ram_addr;
input                  i_fmt_ram_wr;
input      [151:0]     iv_fmt_ram_wdata;
output     [151:0]     ov_fmt_ram_rdata;
input                  i_fmt_ram_rd;
//tsntag & bufid output for not ip frame
output    [47:0]       ov_nip_tsntag;
output    [8:0]        ov_nip_bufid;
output                 o_nip_descriptor_wr;
input                  i_nip_descriptor_ack;
//tsntag & bufid output 
output     [47:0]      ov_ip_tsntag;
output     [8:0]       ov_ip_bufid;
output                 o_ip_descriptor_wr;
input                  i_ip_descriptor_ack;
//threshold of discard
input      [8:0]       iv_free_bufid_fifo_rdusedw;
input      [8:0]       iv_map_req_threshold_value;

output                 o_pkt_cnt_pulse;
output                 o_pkt_discard_cnt_pulse;

output                 o_fifo_overflow_pulse;
output                 o_fifo_underflow_pulse;

output    [1:0]        prp_state;
output    [2:0]        pdi_state;
output    [1:0]        tom_state;
output    [2:0]        descriptor_state;
output    [2:0]        pkt_state;
output    [2:0]        transmission_state;
output    [2:0]        tim_state;
// descriptor of not ts pkt output
output    [45:0]       ov_nts_descriptor;
output                 o_nts_descriptor_wr;
input                  i_nts_descriptor_ack; 
// descriptor of ts pkt output
output    [45:0]       ov_ts_descriptor;
output                 o_ts_descriptor_wr;
input                  i_ts_descriptor_ack;

input      [15:0]      iv_injection_slot_table_wdata;
input                  i_injection_slot_table_wr;
input      [9:0]       iv_injection_slot_table_addr;
output     [15:0]      ov_injection_slot_table_rdata;
input                  i_injection_slot_table_rd;
output     [2:0]       ism_state; 
input      [10:0]      iv_time_slot_period; 
//count overflow error of 32 TS flow 
output                 o_ts_underflow_error_pulse;
output                 o_ts_overflow_error_pulse;
// internal reg&wire 
wire      [35:0]       wv_ts_descriptor;
wire                   w_ts_descriptor_wr;
wire      [4:0]        wv_ts_descriptor_waddr;
wire      [8:0]        wv_data_hrx2pmd;
wire                   w_data_wr_hrx2pmd;
wire      [4:0]        wv_ts_injection_addr;
wire                   w_ts_injection_addr_wr;
wire                   w_ts_injection_addr_ack;
wire      [31:0]       wv_ts_cnt;

network_rx host_rx_inst(
.clk_sys(i_clk),
.reset_n(i_rst_n),
.i_gmii_rst_n(i_gmii_rst_n_host),
.port_type(1'b1),
.cfg_finish(iv_cfg_finish), 

.iv_gmii_rxd(iv_gmii_rxd),
.i_gmii_dv(i_gmii_rx_dv),
.i_gmii_er(i_gmii_rx_er),
.clk_gmii_rx(i_gmii_rx_clk),
.timer_rst(i_timer_rst),
.ov_data(wv_data_hrx2pmd),
.o_data_wr(w_data_wr_hrx2pmd),
.ov_rec_ts(),
.o_pkt_valid_pulse(),
.gmii_fifo_rdfull(),
.gmii_fifo_empty(),
.gmii_read_state(),
.o_fifo_overflow_pulse(o_fifo_overflow_pulse), 
.o_fifo_underflow_pulse(o_fifo_underflow_pulse) 
);
packet_map_dispatch packet_map_dispatch_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data(wv_data_hrx2pmd),
.i_data_wr(w_data_wr_hrx2pmd),

.iv_bufid(iv_bufid),
.i_bufid_wr(i_bufid_wr),
.o_bufid_ack(o_bufid_ack),

.ov_wdata(ov_wdata),
.o_data_wr(o_data_wr),
.ov_data_waddr(ov_data_waddr),
.i_wdata_ack(i_wdata_ack),

.o_pkt_cnt_pulse(o_pkt_cnt_pulse),
.o_pkt_discard_cnt_pulse(o_pkt_discard_cnt_pulse),

.tom_state(tom_state),
.descriptor_state(descriptor_state),
.pkt_state(pkt_state),
.transmission_state(transmission_state),

.ov_ts_descriptor(wv_ts_descriptor),
.o_ts_descriptor_wr(w_ts_descriptor_wr),
.ov_ts_descriptor_waddr(wv_ts_descriptor_waddr),

.ov_nts_descriptor(ov_nts_descriptor),
.o_nts_descriptor_wr(o_nts_descriptor_wr),
.i_nts_descriptor_ack(i_nts_descriptor_ack),

.iv_free_bufid_fifo_rdusedw(iv_free_bufid_fifo_rdusedw),
.iv_map_req_threshold_value(iv_map_req_threshold_value),
     
.iv_fmt_ram_addr(iv_fmt_ram_addr),
.i_fmt_ram_wr(i_fmt_ram_wr),
.iv_fmt_ram_wdata(iv_fmt_ram_wdata),
.ov_fmt_ram_rdata(ov_fmt_ram_rdata),
.i_fmt_ram_rd(i_fmt_ram_rd),

.ov_nip_tsntag(ov_nip_tsntag),
.ov_nip_bufid(ov_nip_bufid),
.o_nip_descriptor_wr(o_nip_descriptor_wr),
.i_nip_descriptor_ack(i_nip_descriptor_ack),

.ov_ip_tsntag(ov_ip_tsntag),
.ov_ip_bufid(ov_ip_bufid),
.o_ip_descriptor_wr(o_ip_descriptor_wr),
.i_ip_descriptor_ack(i_ip_descriptor_ack)      
);
/*
ts_injection_schedule ts_injection_schedule_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),
.iv_cfg_finish(iv_cfg_finish),
       
.iv_syned_global_time(iv_syned_global_time),
.iv_time_slot_length(iv_time_slot_length),
.ov_time_slot(ov_time_slot),
.o_time_slot_switch(o_time_slot_switch),
    
.i_ts_injection_addr_ack(w_ts_injection_addr_ack),
.ov_ts_injection_addr(wv_ts_injection_addr),
.o_ts_injection_addr_wr(w_ts_injection_addr_wr),

.iv_injection_slot_table_wdata(iv_injection_slot_table_wdata),
.i_injection_slot_table_wr(i_injection_slot_table_wr),
.iv_injection_slot_table_addr(iv_injection_slot_table_addr),
.ov_injection_slot_table_rdata(ov_injection_slot_table_rdata),
.i_injection_slot_table_rd(i_injection_slot_table_rd),
.ism_state(ism_state),
.iv_injection_slot_table_period(iv_time_slot_period) 
);
ts_injection_management ts_injection_management_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_ts_descriptor(wv_ts_descriptor),
.i_ts_descriptor_wr(w_ts_descriptor_wr),
.iv_ts_descriptor_waddr(wv_ts_descriptor_waddr),

.iv_ts_injection_addr(wv_ts_injection_addr),
.i_ts_injection_addr_wr(w_ts_injection_addr_wr),
.o_ts_injection_addr_ack(w_ts_injection_addr_ack),

.ov_ts_descriptor(ov_ts_descriptor),
.o_ts_descriptor_wr(o_ts_descriptor_wr),
.i_ts_descriptor_ack(i_ts_descriptor_ack),

.ov_ts_cnt(wv_ts_cnt),
.o_ts_underflow_error_pulse(o_ts_underflow_error_pulse),
.tim_state(tim_state)    
); */      
endmodule