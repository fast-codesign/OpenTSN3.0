// Copyright (C) 1953-2021 NUDT
// Verilog module name - network_output_process
// Version: NOP_V1.0
// Created:
//         by - fenglin 
//         at - 1.2021
////////////////////////////////////////////////////////////////////////////
// Description:
//        switch output process for all outport
//              - number of outport: 5 
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module network_output_process
(
       i_clk,
       i_rst_n,
       
       i_gmii_clk_p0,
       i_gmii_clk_p1,
       i_gmii_clk_p2,
       i_gmii_clk_p3,
       i_gmii_clk_p4,
       
       i_gmii_rst_n_p0,
       i_gmii_rst_n_p1,
       i_gmii_rst_n_p2,
       i_gmii_rst_n_p3,
       i_gmii_rst_n_p4,
           
       i_qbv_or_qch,
       iv_time_slot,
       i_time_slot_switch,
//port0           
       iv_pkt_bufid_p0,
       iv_pkt_type_p0,
       i_frag_last_p0,
       i_pkt_bufid_wr_p0,

       ov_pkt_bufid_p0,
       o_pkt_bufid_wr_p0,
       i_pkt_bufid_ack_p0,  
       
       ov_pkt_raddr_p0,
       o_pkt_rd_p0,
       i_pkt_raddr_ack_p0,
       
       iv_pkt_data_p0,
       i_pkt_data_wr_p0,
       
       ov_gmii_txd_p0,
       o_gmii_tx_en_p0,
       o_gmii_tx_er_p0,
       o_gmii_tx_clk_p0,

       i_timer_rst_p0,  
       
       o_port0_outpkt_pulse,   
       
       iv_nop0_ram_addr,       
       iv_nop0_ram_wdata,      
       i_nop0_ram_wr,          
       ov_nop0_ram_rdata,      
       i_nop0_ram_rd, 

       ov_osc_state_p0,
       ov_prc_state_p0,
       ov_opc_state_p0,       
//port1
       iv_pkt_bufid_p1,
       iv_pkt_type_p1,
       i_frag_last_p1,
       i_pkt_bufid_wr_p1,

       ov_pkt_bufid_p1,
       o_pkt_bufid_wr_p1,
       i_pkt_bufid_ack_p1,  
       
       ov_pkt_raddr_p1,
       o_pkt_rd_p1,
       i_pkt_raddr_ack_p1,
       
       iv_pkt_data_p1,
       i_pkt_data_wr_p1,
       
       ov_gmii_txd_p1,
       o_gmii_tx_en_p1,
       o_gmii_tx_er_p1,
       o_gmii_tx_clk_p1,

       i_timer_rst_p1, 

       o_port1_outpkt_pulse,   
       
       iv_nop1_ram_addr,       
       iv_nop1_ram_wdata,      
       i_nop1_ram_wr,          
       ov_nop1_ram_rdata,      
       i_nop1_ram_rd, 
       
       ov_osc_state_p1,
       ov_prc_state_p1,
       ov_opc_state_p1, 
//port2        
       iv_pkt_bufid_p2,
       iv_pkt_type_p2,
       i_frag_last_p2,
       i_pkt_bufid_wr_p2,

       ov_pkt_bufid_p2,
       o_pkt_bufid_wr_p2,
       i_pkt_bufid_ack_p2,  
       
       ov_pkt_raddr_p2,
       o_pkt_rd_p2,
       i_pkt_raddr_ack_p2,
       
       iv_pkt_data_p2,
       i_pkt_data_wr_p2,
       
       ov_gmii_txd_p2,
       o_gmii_tx_en_p2,
       o_gmii_tx_er_p2,
       o_gmii_tx_clk_p2,

       i_timer_rst_p2,

       o_port2_outpkt_pulse,   
       
       iv_nop2_ram_addr,       
       iv_nop2_ram_wdata,      
       i_nop2_ram_wr,          
       ov_nop2_ram_rdata,      
       i_nop2_ram_rd, 
       
       ov_osc_state_p2,
       ov_prc_state_p2,
       ov_opc_state_p2, 
//port3        
       iv_pkt_bufid_p3,
       iv_pkt_type_p3,
       i_frag_last_p3,
       i_pkt_bufid_wr_p3,

       ov_pkt_bufid_p3,
       o_pkt_bufid_wr_p3,
       i_pkt_bufid_ack_p3,  
       
       ov_pkt_raddr_p3,
       o_pkt_rd_p3,
       i_pkt_raddr_ack_p3,
       
       iv_pkt_data_p3,
       i_pkt_data_wr_p3,
       
       ov_gmii_txd_p3,
       o_gmii_tx_en_p3,
       o_gmii_tx_er_p3,
       o_gmii_tx_clk_p3,

       i_timer_rst_p3, 
       
       o_port3_outpkt_pulse,   
       
       iv_nop3_ram_addr,       
       iv_nop3_ram_wdata,      
       i_nop3_ram_wr,          
       ov_nop3_ram_rdata,      
       i_nop3_ram_rd, 
       
       ov_osc_state_p3,
       ov_prc_state_p3,
       ov_opc_state_p3, 
//port4        
       iv_pkt_bufid_p4,
       iv_pkt_type_p4,
       i_frag_last_p4,
       i_pkt_bufid_wr_p4,

       ov_pkt_bufid_p4,
       o_pkt_bufid_wr_p4,
       i_pkt_bufid_ack_p4,  
       
       ov_pkt_raddr_p4,
       o_pkt_rd_p4,
       i_pkt_raddr_ack_p4,
       
       iv_pkt_data_p4,
       i_pkt_data_wr_p4,
       
       ov_gmii_txd_p4,
       o_gmii_tx_en_p4,
       o_gmii_tx_er_p4,
       o_gmii_tx_clk_p4,

       i_timer_rst_p4,
       
       o_port4_outpkt_pulse,   
       
       iv_nop4_ram_addr,       
       iv_nop4_ram_wdata,      
       i_nop4_ram_wr,          
       ov_nop4_ram_rdata,      
       i_nop4_ram_rd, 
       
       ov_osc_state_p4,
       ov_prc_state_p4,
       ov_opc_state_p4, 

       o_fifo_overflow_pulse_p0,    
       o_fifo_overflow_pulse_p1,    
       o_fifo_overflow_pulse_p2,    
       o_fifo_overflow_pulse_p3,    
       o_fifo_overflow_pulse_p4      
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;

input                  i_gmii_clk_p0;
input                  i_gmii_clk_p1;
input                  i_gmii_clk_p2;
input                  i_gmii_clk_p3;
input                  i_gmii_clk_p4;

input                  i_gmii_rst_n_p0;
input                  i_gmii_rst_n_p1;
input                  i_gmii_rst_n_p2;
input                  i_gmii_rst_n_p3;
input                  i_gmii_rst_n_p4;

output                 o_fifo_overflow_pulse_p0;
output                 o_fifo_overflow_pulse_p1;
output                 o_fifo_overflow_pulse_p2;
output                 o_fifo_overflow_pulse_p3;
output                 o_fifo_overflow_pulse_p4;

input                  i_qbv_or_qch;
input     [9:0]        iv_time_slot;
input                  i_time_slot_switch;
//port0           
input     [8:0]        iv_pkt_bufid_p0;
input     [2:0]        iv_pkt_type_p0;
input                  i_frag_last_p0;
input                  i_pkt_bufid_wr_p0;

output    [8:0]        ov_pkt_bufid_p0;
output                 o_pkt_bufid_wr_p0;
input                  i_pkt_bufid_ack_p0;  
       
output    [15:0]       ov_pkt_raddr_p0;
output                 o_pkt_rd_p0;
input                  i_pkt_raddr_ack_p0;
       
input     [133:0]      iv_pkt_data_p0;
input                  i_pkt_data_wr_p0;
       
output    [7:0]        ov_gmii_txd_p0;
output                 o_gmii_tx_en_p0;
output                 o_gmii_tx_er_p0;
output                 o_gmii_tx_clk_p0;

input                  i_timer_rst_p0; 

output                 o_port0_outpkt_pulse;

input     [9:0]        iv_nop0_ram_addr;    
input     [7:0]        iv_nop0_ram_wdata;   
input                  i_nop0_ram_wr;       
output    [7:0]        ov_nop0_ram_rdata;   
input                  i_nop0_ram_rd;

output    [1:0]        ov_osc_state_p0;                 
output    [1:0]        ov_prc_state_p0;                 
output    [2:0]        ov_opc_state_p0;        
 
 //port1              
input     [8:0]        iv_pkt_bufid_p1;
input     [2:0]        iv_pkt_type_p1;
input                  i_frag_last_p1;
input                  i_pkt_bufid_wr_p1;

output    [8:0]        ov_pkt_bufid_p1;
output                 o_pkt_bufid_wr_p1;
input                  i_pkt_bufid_ack_p1;  
       
output    [15:0]       ov_pkt_raddr_p1;
output                 o_pkt_rd_p1;
input                  i_pkt_raddr_ack_p1;
       
input     [133:0]      iv_pkt_data_p1;
input                  i_pkt_data_wr_p1;
       
output    [7:0]        ov_gmii_txd_p1;
output                 o_gmii_tx_en_p1;
output                 o_gmii_tx_er_p1;
output                 o_gmii_tx_clk_p1;

input                  i_timer_rst_p1; 

output                 o_port1_outpkt_pulse;

input     [9:0]        iv_nop1_ram_addr;    
input     [7:0]        iv_nop1_ram_wdata;   
input                  i_nop1_ram_wr;       
output    [7:0]        ov_nop1_ram_rdata;   
input                  i_nop1_ram_rd;

output    [1:0]        ov_osc_state_p1;                 
output    [1:0]        ov_prc_state_p1;                 
output    [2:0]        ov_opc_state_p1;   
//port2           
input     [8:0]        iv_pkt_bufid_p2;
input     [2:0]        iv_pkt_type_p2;
input                  i_frag_last_p2;
input                  i_pkt_bufid_wr_p2;

output    [8:0]        ov_pkt_bufid_p2;
output                 o_pkt_bufid_wr_p2;
input                  i_pkt_bufid_ack_p2;  
       
output    [15:0]       ov_pkt_raddr_p2;
output                 o_pkt_rd_p2;
input                  i_pkt_raddr_ack_p2;
       
input     [133:0]      iv_pkt_data_p2;
input                  i_pkt_data_wr_p2;
       
output    [7:0]        ov_gmii_txd_p2;
output                 o_gmii_tx_en_p2;
output                 o_gmii_tx_er_p2;
output                 o_gmii_tx_clk_p2;

input                  i_timer_rst_p2; 

output                 o_port2_outpkt_pulse;

input     [9:0]        iv_nop2_ram_addr;    
input     [7:0]        iv_nop2_ram_wdata;   
input                  i_nop2_ram_wr;       
output    [7:0]        ov_nop2_ram_rdata;   
input                  i_nop2_ram_rd;

output    [1:0]        ov_osc_state_p2;                 
output    [1:0]        ov_prc_state_p2;                 
output    [2:0]        ov_opc_state_p2;   
//port3           
input     [8:0]        iv_pkt_bufid_p3;
input     [2:0]        iv_pkt_type_p3;
input                  i_frag_last_p3;
input                  i_pkt_bufid_wr_p3;

output    [8:0]        ov_pkt_bufid_p3;
output                 o_pkt_bufid_wr_p3;
input                  i_pkt_bufid_ack_p3;  
       
output    [15:0]       ov_pkt_raddr_p3;
output                 o_pkt_rd_p3;
input                  i_pkt_raddr_ack_p3;
       
input     [133:0]      iv_pkt_data_p3;
input                  i_pkt_data_wr_p3;
       
output    [7:0]        ov_gmii_txd_p3;
output                 o_gmii_tx_en_p3;
output                 o_gmii_tx_er_p3;
output                 o_gmii_tx_clk_p3;

input                  i_timer_rst_p3;

output                 o_port3_outpkt_pulse;

input     [9:0]        iv_nop3_ram_addr;    
input     [7:0]        iv_nop3_ram_wdata;   
input                  i_nop3_ram_wr;       
output    [7:0]        ov_nop3_ram_rdata;   
input                  i_nop3_ram_rd; 

output    [1:0]        ov_osc_state_p3;                 
output    [1:0]        ov_prc_state_p3;                 
output    [2:0]        ov_opc_state_p3; 
//port4           
input     [8:0]        iv_pkt_bufid_p4;
input     [2:0]        iv_pkt_type_p4;
input                  i_frag_last_p4;
input                  i_pkt_bufid_wr_p4;

output    [8:0]        ov_pkt_bufid_p4;
output                 o_pkt_bufid_wr_p4;
input                  i_pkt_bufid_ack_p4;  
       
output    [15:0]       ov_pkt_raddr_p4;
output                 o_pkt_rd_p4;
input                  i_pkt_raddr_ack_p4;
       
input     [133:0]      iv_pkt_data_p4;
input                  i_pkt_data_wr_p4;
       
output    [7:0]        ov_gmii_txd_p4;
output                 o_gmii_tx_en_p4;
output                 o_gmii_tx_er_p4;
output                 o_gmii_tx_clk_p4;

input                  i_timer_rst_p4; 

output                 o_port4_outpkt_pulse;

input     [9:0]        iv_nop4_ram_addr;    
input     [7:0]        iv_nop4_ram_wdata;   
input                  i_nop4_ram_wr;       
output    [7:0]        ov_nop4_ram_rdata;   
input                  i_nop4_ram_rd;

output    [1:0]        ov_osc_state_p4;                 
output    [1:0]        ov_prc_state_p4;                 
output    [2:0]        ov_opc_state_p4; 


network_output_port network_output_port0_inst
(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                       
.i_gmii_clk             (i_gmii_clk_p0),
.i_gmii_rst_n           (i_gmii_rst_n_p0),

.i_qbv_or_qch           (i_qbv_or_qch),
.iv_time_slot           (iv_time_slot),
.i_time_slot_switch     (i_time_slot_switch),
                      
.iv_pkt_bufid           (iv_pkt_bufid_p0),
.iv_pkt_type            (iv_pkt_type_p0),
.i_pkt_bufid_wr         (i_pkt_bufid_wr_p0),
                      
.ov_pkt_bufid           (ov_pkt_bufid_p0),
.o_pkt_bufid_wr         (o_pkt_bufid_wr_p0),
.i_pkt_bufid_ack        (i_pkt_bufid_ack_p0),
                     
.ov_pkt_raddr           (ov_pkt_raddr_p0),
.o_pkt_rd               (o_pkt_rd_p0),
.i_pkt_raddr_ack        (i_pkt_raddr_ack_p0),
                     
.iv_pkt_data            (iv_pkt_data_p0),
.i_pkt_data_wr          (i_pkt_data_wr_p0),
                     
.ov_gmii_txd            (ov_gmii_txd_p0),
.o_gmii_tx_en           (o_gmii_tx_en_p0),
.o_gmii_tx_er           (o_gmii_tx_er_p0),
.o_gmii_tx_clk          (o_gmii_tx_clk_p0),
                        
.i_timer_rst            (i_timer_rst_p0),

.o_outpkt_pulse         (o_port0_outpkt_pulse),
.o_fifo_overflow_pulse  (o_fifo_overflow_pulse_p0),

.iv_gate_ram_addr       (iv_nop0_ram_addr),
.iv_gate_ram_wdata      (iv_nop0_ram_wdata),
.i_gate_ram_wr          (i_nop0_ram_wr),
.ov_gate_ram_rdata      (ov_nop0_ram_rdata),
.i_gate_ram_rd          (i_nop0_ram_rd),
                        
.ov_osc_state           (ov_osc_state_p0),
.ov_prc_state           (ov_prc_state_p0),
.ov_opc_state           (ov_opc_state_p0)
);  

network_output_port network_output_port1_inst
(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                       
.i_gmii_clk             (i_gmii_clk_p1),
.i_gmii_rst_n           (i_gmii_rst_n_p1),
                       
.i_qbv_or_qch           (i_qbv_or_qch),
.iv_time_slot           (iv_time_slot),
.i_time_slot_switch     (i_time_slot_switch),
                      
.iv_pkt_bufid           (iv_pkt_bufid_p1),
.iv_pkt_type            (iv_pkt_type_p1),
.i_pkt_bufid_wr         (i_pkt_bufid_wr_p1),
                      
.ov_pkt_bufid           (ov_pkt_bufid_p1),
.o_pkt_bufid_wr         (o_pkt_bufid_wr_p1),
.i_pkt_bufid_ack        (i_pkt_bufid_ack_p1),
                     
.ov_pkt_raddr           (ov_pkt_raddr_p1),
.o_pkt_rd               (o_pkt_rd_p1),
.i_pkt_raddr_ack        (i_pkt_raddr_ack_p1),
                     
.iv_pkt_data            (iv_pkt_data_p1),
.i_pkt_data_wr          (i_pkt_data_wr_p1),
                     
.ov_gmii_txd            (ov_gmii_txd_p1),
.o_gmii_tx_en           (o_gmii_tx_en_p1),
.o_gmii_tx_er           (o_gmii_tx_er_p1),
.o_gmii_tx_clk          (o_gmii_tx_clk_p1),
                        
.i_timer_rst            (i_timer_rst_p1),

.o_outpkt_pulse         (o_port1_outpkt_pulse),
.o_fifo_overflow_pulse  (o_fifo_overflow_pulse_p1),

.iv_gate_ram_addr       (iv_nop1_ram_addr),
.iv_gate_ram_wdata      (iv_nop1_ram_wdata),
.i_gate_ram_wr          (i_nop1_ram_wr),
.ov_gate_ram_rdata      (ov_nop1_ram_rdata),
.i_gate_ram_rd          (i_nop1_ram_rd),

.ov_osc_state           (ov_osc_state_p1),
.ov_prc_state           (ov_prc_state_p1),
.ov_opc_state           (ov_opc_state_p1)
); 

network_output_port network_output_port2_inst
(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                       
.i_gmii_clk             (i_gmii_clk_p2),
.i_gmii_rst_n           (i_gmii_rst_n_p2),
                       
.i_qbv_or_qch           (i_qbv_or_qch),
.iv_time_slot           (iv_time_slot),
.i_time_slot_switch     (i_time_slot_switch),
                      
.iv_pkt_bufid           (iv_pkt_bufid_p2),
.iv_pkt_type            (iv_pkt_type_p2),
.i_pkt_bufid_wr         (i_pkt_bufid_wr_p2),
                      
.ov_pkt_bufid           (ov_pkt_bufid_p2),
.o_pkt_bufid_wr         (o_pkt_bufid_wr_p2),
.i_pkt_bufid_ack        (i_pkt_bufid_ack_p2),
                     
.ov_pkt_raddr           (ov_pkt_raddr_p2),
.o_pkt_rd               (o_pkt_rd_p2),
.i_pkt_raddr_ack        (i_pkt_raddr_ack_p2),
                     
.iv_pkt_data            (iv_pkt_data_p2),
.i_pkt_data_wr          (i_pkt_data_wr_p2),
                     
.ov_gmii_txd            (ov_gmii_txd_p2),
.o_gmii_tx_en           (o_gmii_tx_en_p2),
.o_gmii_tx_er           (o_gmii_tx_er_p2),
.o_gmii_tx_clk          (o_gmii_tx_clk_p2),
                        
.i_timer_rst            (i_timer_rst_p2),

.o_outpkt_pulse         (o_port2_outpkt_pulse),
.o_fifo_overflow_pulse  (o_fifo_overflow_pulse_p2),

.iv_gate_ram_addr       (iv_nop2_ram_addr),
.iv_gate_ram_wdata      (iv_nop2_ram_wdata),
.i_gate_ram_wr          (i_nop2_ram_wr),
.ov_gate_ram_rdata      (ov_nop2_ram_rdata),
.i_gate_ram_rd          (i_nop2_ram_rd),

.ov_osc_state           (ov_osc_state_p2),
.ov_prc_state           (ov_prc_state_p2),
.ov_opc_state           (ov_opc_state_p2)
);                                            

network_output_port network_output_port3_inst
(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                       
.i_gmii_clk             (i_gmii_clk_p3),
.i_gmii_rst_n           (i_gmii_rst_n_p3),
                      
.i_qbv_or_qch           (i_qbv_or_qch),
.iv_time_slot           (iv_time_slot),
.i_time_slot_switch     (i_time_slot_switch),
                      
.iv_pkt_bufid           (iv_pkt_bufid_p3),
.iv_pkt_type            (iv_pkt_type_p3),
.i_pkt_bufid_wr         (i_pkt_bufid_wr_p3),
                      
.ov_pkt_bufid           (ov_pkt_bufid_p3),
.o_pkt_bufid_wr         (o_pkt_bufid_wr_p3),
.i_pkt_bufid_ack        (i_pkt_bufid_ack_p3),
                     
.ov_pkt_raddr           (ov_pkt_raddr_p3),
.o_pkt_rd               (o_pkt_rd_p3),
.i_pkt_raddr_ack        (i_pkt_raddr_ack_p3),
                     
.iv_pkt_data            (iv_pkt_data_p3),
.i_pkt_data_wr          (i_pkt_data_wr_p3),
                     
.ov_gmii_txd            (ov_gmii_txd_p3),
.o_gmii_tx_en           (o_gmii_tx_en_p3),
.o_gmii_tx_er           (o_gmii_tx_er_p3),
.o_gmii_tx_clk          (o_gmii_tx_clk_p3),
                        
.i_timer_rst            (i_timer_rst_p3),

.o_outpkt_pulse         (o_port3_outpkt_pulse),
.o_fifo_overflow_pulse  (o_fifo_overflow_pulse_p3),

.iv_gate_ram_addr       (iv_nop3_ram_addr),
.iv_gate_ram_wdata      (iv_nop3_ram_wdata),
.i_gate_ram_wr          (i_nop3_ram_wr),
.ov_gate_ram_rdata      (ov_nop3_ram_rdata),
.i_gate_ram_rd          (i_nop3_ram_rd),

.ov_osc_state           (ov_osc_state_p3),
.ov_prc_state           (ov_prc_state_p3),
.ov_opc_state           (ov_opc_state_p3)
); 

network_output_port network_output_port4_inst
(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                       
.i_gmii_clk             (i_gmii_clk_p4),
.i_gmii_rst_n           (i_gmii_rst_n_p4),

.i_qbv_or_qch           (1'b1),
.iv_time_slot           (iv_time_slot),
.i_time_slot_switch     (i_time_slot_switch),

.iv_pkt_bufid           (iv_pkt_bufid_p4),
.iv_pkt_type            (iv_pkt_type_p4),
.i_pkt_bufid_wr         (i_pkt_bufid_wr_p4),
                      
.ov_pkt_bufid           (ov_pkt_bufid_p4),
.o_pkt_bufid_wr         (o_pkt_bufid_wr_p4),
.i_pkt_bufid_ack        (i_pkt_bufid_ack_p4),
                     
.ov_pkt_raddr           (ov_pkt_raddr_p4),
.o_pkt_rd               (o_pkt_rd_p4),
.i_pkt_raddr_ack        (i_pkt_raddr_ack_p4),
                     
.iv_pkt_data            (iv_pkt_data_p4),
.i_pkt_data_wr          (i_pkt_data_wr_p4),
                     
.ov_gmii_txd            (ov_gmii_txd_p4),
.o_gmii_tx_en           (o_gmii_tx_en_p4),
.o_gmii_tx_er           (o_gmii_tx_er_p4),
.o_gmii_tx_clk          (o_gmii_tx_clk_p4),
                        
.i_timer_rst            (i_timer_rst_p4),

.o_outpkt_pulse         (o_port4_outpkt_pulse),
.o_fifo_overflow_pulse  (o_fifo_overflow_pulse_p4),

.iv_gate_ram_addr       (iv_nop4_ram_addr),
.iv_gate_ram_wdata      (iv_nop4_ram_wdata),
.i_gate_ram_wr          (i_nop4_ram_wr),
.ov_gate_ram_rdata      (ov_nop4_ram_rdata),
.i_gate_ram_rd          (i_nop4_ram_rd),

.ov_osc_state           (ov_osc_state_p4),
.ov_prc_state           (ov_prc_state_p4),
.ov_opc_state           (ov_opc_state_p4)
); 
   
endmodule