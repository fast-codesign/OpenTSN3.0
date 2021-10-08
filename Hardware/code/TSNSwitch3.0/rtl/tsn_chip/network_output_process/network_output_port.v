// Copyright (C) 1953-2020 NUDT
// Verilog module name - network_output_port
// Version: NOP_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//        switch output port
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module network_output_port
(
       i_clk,
       i_rst_n,
       
       i_gmii_clk,
       i_gmii_rst_n,
       
       i_qbv_or_qch,
       iv_time_slot,
       i_time_slot_switch,
       
       iv_pkt_bufid,
       iv_pkt_type,
       i_pkt_bufid_wr,
       
       ov_pkt_bufid,
       o_pkt_bufid_wr,
       i_pkt_bufid_ack, 
       
       ov_pkt_raddr,
       o_pkt_rd,
       i_pkt_raddr_ack,
       
       iv_pkt_data,
       i_pkt_data_wr,
       
       ov_gmii_txd,
       o_gmii_tx_en,
       o_gmii_tx_er,
       o_gmii_tx_clk,
       
       i_timer_rst,
       
       o_outpkt_pulse,
       o_fifo_overflow_pulse,       
           
       iv_gate_ram_addr,         
       iv_gate_ram_wdata,        
       i_gate_ram_wr,            
       ov_gate_ram_rdata,        
       i_gate_ram_rd,

       ov_osc_state,
       ov_prc_state,
       ov_opc_state
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;

input                  i_gmii_clk;
input                  i_gmii_rst_n;

input                  i_qbv_or_qch;
input      [9:0]       iv_time_slot; 
input                  i_time_slot_switch; 
//port0           
input     [8:0]        iv_pkt_bufid;
input     [2:0]        iv_pkt_type;
input                  i_pkt_bufid_wr;

output    [8:0]        ov_pkt_bufid;
output                 o_pkt_bufid_wr;
input                  i_pkt_bufid_ack; 
       
output    [15:0]       ov_pkt_raddr;
output                 o_pkt_rd;
input                  i_pkt_raddr_ack;
       
input     [133:0]      iv_pkt_data;
input                  i_pkt_data_wr;
       
output    [7:0]        ov_gmii_txd;
output                 o_gmii_tx_en;
output                 o_gmii_tx_er;
output                 o_gmii_tx_clk;

input                  i_timer_rst;  

output                 o_outpkt_pulse;
output                 o_fifo_overflow_pulse;           
           
input     [9:0]        iv_gate_ram_addr;         
input     [7:0]        iv_gate_ram_wdata;        
input                  i_gate_ram_wr;           
output    [7:0]        ov_gate_ram_rdata;        
input                  i_gate_ram_rd; 

output    [1:0]        ov_osc_state;                 
output    [1:0]        ov_prc_state;                 
output    [2:0]        ov_opc_state; 

//wire
wire       [2:0]       wv_queue_id_niq2nos; 
wire                   w_queue_id_wr_niq2nos;
wire       [7:0]       wv_queue_empty_niq2nos;  
wire       [8:0]       wv_pkt_bufid_nos2ntx;    
wire                   w_pkt_bufid_wr_nos2ntx;
wire                   w_pkt_bufid_ack_ntx2nos;

wire       [8:0]       wv_queue_wdata_niq2nqm;
wire       [8:0]       wv_queue_waddr_niq2nqm;  
wire                   w_queue_wr_niq2nqm;       
                        
wire       [8:0]       wv_queue_raddr_nos2nqm;   
wire                   w_queue_rd_nos2nqm;

wire       [8:0]       wv_rd_queue_data_nqm2nos;
wire                   w_rd_queue_data_wr_nqm2nos;

wire       [1:0]       wv_gate_ctrl_vector_qgc2niq;
wire       [7:0]       wv_gate_ctrl_vector_qgc2nos;

wire       [2:0]       wv_schqueue_id_nos2niq;  
wire                   w_schqueue_id_wr_nos2niq;

network_input_queue network_input_queue_inst(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                        
.iv_pkt_bufid           (iv_pkt_bufid),
.iv_pkt_type            (iv_pkt_type),
.i_pkt_bufid_wr         (i_pkt_bufid_wr),
 
.i_qbv_or_qch           (i_qbv_or_qch),
.iv_gate_ctrl_vector    (wv_gate_ctrl_vector_qgc2niq),

.iv_schdule_id          (wv_schqueue_id_nos2niq),
.i_schdule_id_wr        (w_schqueue_id_wr_nos2niq), 
                       
.ov_queue_data          (wv_queue_wdata_niq2nqm),
.ov_queue_waddr         (wv_queue_waddr_niq2nqm),
.o_queue_wr             (w_queue_wr_niq2nqm),
                 
.ov_queue_id            (wv_queue_id_niq2nos),
.o_queue_id_wr          (w_queue_id_wr_niq2nos),
.ov_queue_empty         (wv_queue_empty_niq2nos)
);

queue_gate_control queue_gate_control_inst(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),

.iv_ram_addr            (iv_gate_ram_addr),
.iv_ram_wdata           (iv_gate_ram_wdata),
.i_ram_wr               (i_gate_ram_wr),
.ov_ram_rdata           (ov_gate_ram_rdata),
.i_ram_rd               (i_gate_ram_rd),
 
.i_qbv_or_qch           (i_qbv_or_qch),
.iv_time_slot           (iv_time_slot),
.i_time_slot_switch     (i_time_slot_switch),

.ov_in_gate_ctrl_vector (wv_gate_ctrl_vector_qgc2niq),
.ov_out_gate_ctrl_vector(wv_gate_ctrl_vector_qgc2nos)
);

network_queue_manage network_queue_manage_inst(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                        
.iv_queue_wdata         (wv_queue_wdata_niq2nqm),
.iv_queue_waddr         (wv_queue_waddr_niq2nqm),                   
.i_queue_wr             (w_queue_wr_niq2nqm),                     
                                                 
.iv_queue_raddr         (wv_queue_raddr_nos2nqm),                      
.i_queue_rd             (w_queue_rd_nos2nqm),
                        
.ov_queue_rdata         (wv_rd_queue_data_nqm2nos),
.o_queue_rdata_valid    (w_rd_queue_data_wr_nqm2nos)
);


network_output_schedule network_output_schedule_inst(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                      
.iv_pkt_bufid           (wv_queue_waddr_niq2nqm),
.iv_pkt_next_bufid      (wv_queue_wdata_niq2nqm),
.iv_queue_id            (wv_queue_id_niq2nos),
.i_queue_id_wr          (w_queue_id_wr_niq2nos),
.iv_queue_empty         (wv_queue_empty_niq2nos),

.ov_schdule_id          (wv_schqueue_id_nos2niq),
.o_schdule_id_wr        (w_schqueue_id_wr_nos2niq),  
                       
.iv_gate_ctrl_vector    (wv_gate_ctrl_vector_qgc2nos),
                      
.ov_queue_raddr         (wv_queue_raddr_nos2nqm),
.o_queue_rd             (w_queue_rd_nos2nqm),
.iv_rd_queue_data       (wv_rd_queue_data_nqm2nos),
.i_rd_queue_data_wr     (w_rd_queue_data_wr_nqm2nos),
                      
.ov_pkt_bufid           (wv_pkt_bufid_nos2ntx),
.o_pkt_bufid_wr         (w_pkt_bufid_wr_nos2ntx),
                       
.i_pkt_bufid_ack        (w_pkt_bufid_ack_ntx2nos),

.ov_osc_state           (ov_osc_state)
);

network_tx network_tx_inst(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),

.i_gmii_clk             (i_gmii_clk),
.i_gmii_rst_n           (i_gmii_rst_n),
                       
.iv_pkt_bufid           (wv_pkt_bufid_nos2ntx),
.i_pkt_bufid_wr         (w_pkt_bufid_wr_nos2ntx),
.o_pkt_bufid_ack        (w_pkt_bufid_ack_ntx2nos),
                                                     
.ov_pkt_bufid           (ov_pkt_bufid),                        
.o_pkt_bufid_wr         (o_pkt_bufid_wr),                           
.i_pkt_bufid_ack        (i_pkt_bufid_ack),                      
                                                   
.ov_pkt_raddr           (ov_pkt_raddr),                        
.o_pkt_rd               (o_pkt_rd),                        
.i_pkt_raddr_ack        (i_pkt_raddr_ack),                      
                                                   
.iv_pkt_data            (iv_pkt_data),                        
.i_pkt_data_wr          (i_pkt_data_wr),                      
                                                   
.ov_gmii_txd            (ov_gmii_txd),                        
.o_gmii_tx_en           (o_gmii_tx_en),                        
.o_gmii_tx_er           (o_gmii_tx_er),                      
.o_gmii_tx_clk          (o_gmii_tx_clk),                        
                                                  
.i_timer_rst            (i_timer_rst),

.ov_prc_state           (ov_prc_state),
.ov_opc_state           (ov_opc_state),

.o_outpkt_pulse         (o_outpkt_pulse),
.o_fifo_overflow_pulse  (o_fifo_overflow_pulse)                      
);                                                

endmodule