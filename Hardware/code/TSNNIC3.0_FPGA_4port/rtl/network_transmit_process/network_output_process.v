// Copyright (C) 1953-2020 NUDT
// Verilog module name - network_output_process
// Version: NOP_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//        switch output process for all outport
//              - number of outport: 3 
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module network_output_process
(
       i_clk,
       i_rst_n,
       
       i_gmii_clk_p0,
       i_gmii_clk_p1,
       
       i_gmii_rst_n_p0,
       i_gmii_rst_n_p1,
                    
       iv_tsntag_host2p0,
       iv_bufid_host2p0,
       i_descriptor_wr_host2p0,
       o_descriptor_ack_p02host,
       
       iv_tsntag_network2p0,
       iv_bufid_network2p0,
       i_descriptor_wr_network2p0,
       o_descriptor_ack_p02network,   

       ov_pkt_bufid_p0,
       o_pkt_bufid_wr_p0,
       i_pkt_bufid_ack_p0,  
       
       ov_pkt_raddr_p0,
       o_pkt_rd_p0,
       i_pkt_raddr_ack_p0,
       
       iv_pkt_data_p0,
       i_pkt_data_wr_p0,
       
       o_port0_outpkt_pulse, 
       o_fifo_overflow_pulse_p0,  
       
       ov_gmii_txd_p0,
       o_gmii_tx_en_p0,
       o_gmii_tx_er_p0,
       o_gmii_tx_clk_p0,

       i_timer_rst_p0,     
//port1      
       iv_tsntag_host2p1,
       iv_bufid_host2p1,
       i_descriptor_wr_host2p1,
       o_descriptor_ack_p12host,
       
       iv_tsntag_network2p1,
       iv_bufid_network2p1,
       i_descriptor_wr_network2p1,
       o_descriptor_ack_p12network,    

       ov_pkt_bufid_p1,
       o_pkt_bufid_wr_p1,
       i_pkt_bufid_ack_p1,  
       
       ov_pkt_raddr_p1,
       o_pkt_rd_p1,
       i_pkt_raddr_ack_p1,
       
       iv_pkt_data_p1,
       i_pkt_data_wr_p1,
       
       o_port1_outpkt_pulse,
       o_fifo_overflow_pulse_p1,  
       
       ov_gmii_txd_p1,
       o_gmii_tx_en_p1,
       o_gmii_tx_er_p1,
       o_gmii_tx_clk_p1,

       i_timer_rst_p1    
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;

input                  i_gmii_clk_p0;
input                  i_gmii_clk_p1;

input                  i_gmii_rst_n_p0;
input                  i_gmii_rst_n_p1;
//port0           
//tsntag & bufid input from host_port
input          [47:0]  iv_tsntag_host2p0;
input          [8:0]   iv_bufid_host2p0;
input                  i_descriptor_wr_host2p0;
output                 o_descriptor_ack_p02host;
//tsntag & bufid input from hcp_port
input          [47:0]  iv_tsntag_network2p0;
input          [8:0]   iv_bufid_network2p0;
input                  i_descriptor_wr_network2p0;
output                 o_descriptor_ack_p02network;

output    [8:0]        ov_pkt_bufid_p0;
output                 o_pkt_bufid_wr_p0;
input                  i_pkt_bufid_ack_p0;  
       
output    [15:0]       ov_pkt_raddr_p0;
output                 o_pkt_rd_p0;
input                  i_pkt_raddr_ack_p0;
       
input     [133:0]      iv_pkt_data_p0;
input                  i_pkt_data_wr_p0;

output                 o_port0_outpkt_pulse;
output                 o_fifo_overflow_pulse_p0;
      
output    [7:0]        ov_gmii_txd_p0;
output                 o_gmii_tx_en_p0;
output                 o_gmii_tx_er_p0;
output                 o_gmii_tx_clk_p0;
input                  i_timer_rst_p0;       
 //port1  
//tsntag & bufid input from host_port
input          [47:0]  iv_tsntag_host2p1;
input          [8:0]   iv_bufid_host2p1;
input                  i_descriptor_wr_host2p1;
output                 o_descriptor_ack_p12host;
//tsntag & bufid input from hcp_port
input          [47:0]  iv_tsntag_network2p1;
input          [8:0]   iv_bufid_network2p1;
input                  i_descriptor_wr_network2p1;
output                 o_descriptor_ack_p12network;

output    [8:0]        ov_pkt_bufid_p1;
output                 o_pkt_bufid_wr_p1;
input                  i_pkt_bufid_ack_p1;  
       
output    [15:0]       ov_pkt_raddr_p1;
output                 o_pkt_rd_p1;
input                  i_pkt_raddr_ack_p1;
       
input     [133:0]      iv_pkt_data_p1;
input                  i_pkt_data_wr_p1;

output                 o_port1_outpkt_pulse;
output                 o_fifo_overflow_pulse_p1;
       
output    [7:0]        ov_gmii_txd_p1;
output                 o_gmii_tx_en_p1;
output                 o_gmii_tx_er_p1;
output                 o_gmii_tx_clk_p1;

input                  i_timer_rst_p1; 
network_transmit_port network_transmit_port0_connect_with_hcp(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                       
.i_host_gmii_tx_clk     (i_gmii_clk_p0),
.i_gmii_rst_n_host      (i_gmii_rst_n_p0),

.iv_cfg_finish          (2'b0),

.iv_tsntag_host         (iv_tsntag_host2p0),
.iv_bufid_host          (iv_bufid_host2p0),
.i_descriptor_wr_host   (i_descriptor_wr_host2p0),
.o_descriptor_ack_host  (o_descriptor_ack_p02host),

.iv_tsntag_network      (iv_tsntag_network2p0),
.iv_bufid_network       (iv_bufid_network2p0),
.i_descriptor_wr_network(i_descriptor_wr_network2p0),
.o_descriptor_ack_network(o_descriptor_ack_p02network),
                      
.ov_pkt_bufid           (ov_pkt_bufid_p0),
.o_pkt_bufid_wr         (o_pkt_bufid_wr_p0),
.i_pkt_bufid_ack        (i_pkt_bufid_ack_p0),
                     
.ov_pkt_raddr           (ov_pkt_raddr_p0),
.o_pkt_rd               (o_pkt_rd_p0),
.i_pkt_raddr_ack        (i_pkt_raddr_ack_p0),
                     
.iv_pkt_data            (iv_pkt_data_p0),
.i_pkt_data_wr          (i_pkt_data_wr_p0),

.o_pkt_cnt_pulse        (o_port0_outpkt_pulse),
.o_fifo_overflow_pulse  (o_fifo_overflow_pulse_p0),

.o_ts_underflow_error_pulse(),
.o_ts_overflow_error_pulse(), 
       
.ov_gmii_txd            (ov_gmii_txd_p0),
.o_gmii_tx_en           (o_gmii_tx_en_p0),
.o_gmii_tx_er           (o_gmii_tx_er_p0),
.o_gmii_tx_clk          (o_gmii_tx_clk_p0),
 
.iv_syned_global_time   (48'b0), 
.i_timer_rst            (i_timer_rst_p0),

.hos_state              (),
.hoi_state              (),
.bufid_state            (),
.pkt_read_state         (),
.tsm_state              (),
.ssm_state              (),  

.iv_submit_slot_table_wdata (),
.i_submit_slot_table_wr     (),
.iv_submit_slot_table_addr  (),
.ov_submit_slot_table_rdata (),
.i_submit_slot_table_rd     (),
.iv_submit_slot_table_period()  
);  
network_transmit_port network_transmit_port1_connect_with_network(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                       
.i_host_gmii_tx_clk     (i_gmii_clk_p1),
.i_gmii_rst_n_host      (i_gmii_rst_n_p1),

.iv_cfg_finish          (2'b0),

.iv_tsntag_host         (iv_tsntag_host2p1),
.iv_bufid_host          (iv_bufid_host2p1),
.i_descriptor_wr_host   (i_descriptor_wr_host2p1),
.o_descriptor_ack_host  (o_descriptor_ack_p12host),

.iv_tsntag_network       (iv_tsntag_network2p1),
.iv_bufid_network        (iv_bufid_network2p1),
.i_descriptor_wr_network (i_descriptor_wr_network2p1),
.o_descriptor_ack_network(o_descriptor_ack_p12network),
                      
.ov_pkt_bufid           (ov_pkt_bufid_p1),
.o_pkt_bufid_wr         (o_pkt_bufid_wr_p1),
.i_pkt_bufid_ack        (i_pkt_bufid_ack_p1),
                     
.ov_pkt_raddr           (ov_pkt_raddr_p1),
.o_pkt_rd               (o_pkt_rd_p1),
.i_pkt_raddr_ack        (i_pkt_raddr_ack_p1),
                     
.iv_pkt_data            (iv_pkt_data_p1),
.i_pkt_data_wr          (i_pkt_data_wr_p1),

.o_pkt_cnt_pulse        (o_port1_outpkt_pulse),
.o_fifo_overflow_pulse  (o_fifo_overflow_pulse_p1),

.o_ts_underflow_error_pulse(),
.o_ts_overflow_error_pulse(), 
       
.ov_gmii_txd            (ov_gmii_txd_p1),
.o_gmii_tx_en           (o_gmii_tx_en_p1),
.o_gmii_tx_er           (o_gmii_tx_er_p1),
.o_gmii_tx_clk          (o_gmii_tx_clk_p1),
 
.iv_syned_global_time   (), 
.i_timer_rst            (i_timer_rst_p1),

.hos_state              (),
.hoi_state              (),
.bufid_state            (),
.pkt_read_state         (),
.tsm_state              (),
.ssm_state              (),  

.iv_submit_slot_table_wdata (),
.i_submit_slot_table_wr     (),
.iv_submit_slot_table_addr  (),
.ov_submit_slot_table_rdata (),
.i_submit_slot_table_rd     (),
.iv_submit_slot_table_period()  
);  
endmodule