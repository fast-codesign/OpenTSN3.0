// Copyright (C) 1953-2020 NUDT
// Verilog module name - network_input_process_top  
// Version: NIP_top_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         Network input process top module
//         include 3 GMII network interface
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module network_input_process_top  
    (
        clk_sys,
        reset_n,
        
        i_gmii_rst_n_p0,
        i_gmii_rst_n_p1,
        i_gmii_rst_n_p2,
        i_gmii_rst_n_p3,
        i_gmii_rst_n_p4,    
        //network interface port 1 GMII RX signal
        clk_gmii_rx_p0,
        i_gmii_dv_p0,
        iv_gmii_rxd_p0,
        i_gmii_er_p0,
        //network interface port 2 GMII RX signal       
        clk_gmii_rx_p1,
        i_gmii_dv_p1,
        iv_gmii_rxd_p1,
        i_gmii_er_p1,
        //network interface port 3 GMII RX signal       
        clk_gmii_rx_p2,
        i_gmii_dv_p2,
        iv_gmii_rxd_p2,
        i_gmii_er_p2,
        // //network interface port 4 GMII RX signal        
         clk_gmii_rx_p3,
         i_gmii_dv_p3,
         iv_gmii_rxd_p3,
         i_gmii_er_p3,      
        // //network interface port 5 GMII RX signal        
         clk_gmii_rx_p4,
         i_gmii_dv_p4,
         iv_gmii_rxd_p4,
         i_gmii_er_p4,

        //timestamp sync reset signal
        timer_rst,
        //port type configuration. 1:terminal interface,0:network interface.
        port_type,
        //configuration of receiving pkt type.00:receive NMAC pkt;01:receive NMAC/PTP pkt;10:receive all pkt.
        cfg_finish,     
        //network interface port 1 receive pkt buffer id signal 
        i_pkt_bufid_wr_p0,
        iv_pkt_bufid_p0,
        o_pkt_bufid_ack_p0,
        //network interface port 2 receive pkt buffer id signal         
        i_pkt_bufid_wr_p1,
        iv_pkt_bufid_p1,
        o_pkt_bufid_ack_p1,
        //network interface port 3 receive pkt buffer id signal         
        i_pkt_bufid_wr_p2,
        iv_pkt_bufid_p2,
        o_pkt_bufid_ack_p2,
        //network interface port 4 receive pkt buffer id signal     
        i_pkt_bufid_wr_p3,
        iv_pkt_bufid_p3,
        o_pkt_bufid_ack_p3,
        //network interface port 5 receive pkt buffer id signal         
        i_pkt_bufid_wr_p4,
        iv_pkt_bufid_p4,
        o_pkt_bufid_ack_p4,
        
        //network interface port 1 send descriptor signal
        o_descriptor_wr_p0,
        ov_descriptor_p0,
        i_descriptor_ack_p0,
        //network interface port 2 send descriptor signal           
        o_descriptor_wr_p1,
        ov_descriptor_p1,
        i_descriptor_ack_p1,
        //network interface port 3 send descriptor signal           
        o_descriptor_wr_p2,
        ov_descriptor_p2,
        i_descriptor_ack_p2,
        //network interface port 4 send descriptor signal
        o_descriptor_wr_p3,
        ov_descriptor_p3,
        i_descriptor_ack_p3,
        //network interface port 5 send descriptor signal           
        o_descriptor_wr_p4,
        ov_descriptor_p4,
        i_descriptor_ack_p4,
        
        //network interface port 1 send 134bits pkt signal
        ov_pkt_p0,
        o_pkt_wr_p0,
        ov_pkt_bufadd_p0,
        i_pkt_ack_p0,
        //network interface port 2 send 134bits pkt signal
        ov_pkt_p1,
        o_pkt_wr_p1,
        ov_pkt_bufadd_p1,
        i_pkt_ack_p1,
        //network interface port 3 send 134bits pkt signal
        ov_pkt_p2,
        o_pkt_wr_p2,
        ov_pkt_bufadd_p2,
        i_pkt_ack_p2,
        //network interface port 4 send 134bits pkt signal
        ov_pkt_p3,
        o_pkt_wr_p3,
        ov_pkt_bufadd_p3,
        i_pkt_ack_p3,
        //network interface port 5 send 134bits pkt signal
        ov_pkt_p4,
        o_pkt_wr_p4,
        ov_pkt_bufadd_p4,
        i_pkt_ack_p4,
        
        iv_free_bufid_fifo_rdusedw,
        iv_be_threshold_value,
        iv_rc_threshold_value,
        iv_map_req_threshold_value,
        
        o_port0_inpkt_pulse,          
        o_port0_discard_pkt_pulse,
        o_port1_inpkt_pulse,            
        o_port1_discard_pkt_pulse,      
        o_port2_inpkt_pulse,            
        o_port2_discard_pkt_pulse,      
        o_port3_inpkt_pulse,            
        o_port3_discard_pkt_pulse,      
        o_port4_inpkt_pulse,            
        o_port4_discard_pkt_pulse,      


        o_fifo_underflow_pulse_p0,
        o_fifo_overflow_pulse_p0, 
        o_fifo_underflow_pulse_p1,
        o_fifo_overflow_pulse_p1, 
        o_fifo_underflow_pulse_p2,
        o_fifo_overflow_pulse_p2, 
        o_fifo_underflow_pulse_p3,
        o_fifo_overflow_pulse_p3, 
        o_fifo_underflow_pulse_p4,
        o_fifo_overflow_pulse_p4, 

        
        ov_gmii_read_state_p0,          
        o_gmii_fifo_full_p0,            
        o_gmii_fifo_empty_p0,           
        ov_descriptor_extract_state_p0, 
        ov_descriptor_send_state_p0,    
        ov_data_splice_state_p0,        
        ov_input_buf_interface_state_p0,
     
        ov_gmii_read_state_p1,          
        o_gmii_fifo_full_p1,            
        o_gmii_fifo_empty_p1,           
        ov_descriptor_extract_state_p1, 
        ov_descriptor_send_state_p1,    
        ov_data_splice_state_p1,        
        ov_input_buf_interface_state_p1,
      
        ov_gmii_read_state_p2,          
        o_gmii_fifo_full_p2,            
        o_gmii_fifo_empty_p2,           
        ov_descriptor_extract_state_p2, 
        ov_descriptor_send_state_p2,    
        ov_data_splice_state_p2,        
        ov_input_buf_interface_state_p2,
      
        ov_gmii_read_state_p3,          
        o_gmii_fifo_full_p3,            
        o_gmii_fifo_empty_p3,           
        ov_descriptor_extract_state_p3, 
        ov_descriptor_send_state_p3,    
        ov_data_splice_state_p3,        
        ov_input_buf_interface_state_p3,
       
        ov_gmii_read_state_p4,         
        o_gmii_fifo_full_p4,            
        o_gmii_fifo_empty_p4,           
        ov_descriptor_extract_state_p4, 
        ov_descriptor_send_state_p4,    
        ov_data_splice_state_p4,        
        ov_input_buf_interface_state_p4
   
    );

// I/O
// clk & rst
input                   clk_sys;
input                   reset_n;

input                   i_gmii_rst_n_p0;
input                   i_gmii_rst_n_p1;
input                   i_gmii_rst_n_p2;
input                   i_gmii_rst_n_p3;
input                   i_gmii_rst_n_p4;

//GMII RX input
input                   clk_gmii_rx_p0;
input                   i_gmii_dv_p0;
input       [7:0]       iv_gmii_rxd_p0;
input                   i_gmii_er_p0;
input                   clk_gmii_rx_p1;
input                   i_gmii_dv_p1;
input       [7:0]       iv_gmii_rxd_p1;
input                   i_gmii_er_p1;
input                   clk_gmii_rx_p2;
input                   i_gmii_dv_p2;
input       [7:0]       iv_gmii_rxd_p2;
input                   i_gmii_er_p2;
input                   clk_gmii_rx_p3;
input                   i_gmii_dv_p3;
input       [7:0]       iv_gmii_rxd_p3;
input                   i_gmii_er_p3;
input                   clk_gmii_rx_p4;
input                   i_gmii_dv_p4;
input       [7:0]       iv_gmii_rxd_p4;
input                   i_gmii_er_p4;

//timer reset pusle
input                   timer_rst;
input       [7:0]       port_type;
input       [1:0]       cfg_finish;
//pkt bufid input
input                   i_pkt_bufid_wr_p0;
input       [8:0]       iv_pkt_bufid_p0;
output                  o_pkt_bufid_ack_p0;
input                   i_pkt_bufid_wr_p1;
input       [8:0]       iv_pkt_bufid_p1;
output                  o_pkt_bufid_ack_p1;
input                   i_pkt_bufid_wr_p2;
input       [8:0]       iv_pkt_bufid_p2;
output                  o_pkt_bufid_ack_p2;
input                   i_pkt_bufid_wr_p3;
input       [8:0]       iv_pkt_bufid_p3;
output                  o_pkt_bufid_ack_p3;
input                   i_pkt_bufid_wr_p4;
input       [8:0]       iv_pkt_bufid_p4;
output                  o_pkt_bufid_ack_p4;

//descriptor output
output                  o_descriptor_wr_p0;
output      [45:0]      ov_descriptor_p0;
input                   i_descriptor_ack_p0;
output                  o_descriptor_wr_p1;
output      [45:0]      ov_descriptor_p1;
input                   i_descriptor_ack_p1;
output                  o_descriptor_wr_p2;
output      [45:0]      ov_descriptor_p2;
input                   i_descriptor_ack_p2;
output                  o_descriptor_wr_p3;
output      [45:0]      ov_descriptor_p3;
input                   i_descriptor_ack_p3;
output                  o_descriptor_wr_p4;
output      [45:0]      ov_descriptor_p4;
input                   i_descriptor_ack_p4;

//user data output
output      [133:0]     ov_pkt_p0;
output                  o_pkt_wr_p0;
output      [15:0]      ov_pkt_bufadd_p0;
input                   i_pkt_ack_p0; 
output      [133:0]     ov_pkt_p1;
output                  o_pkt_wr_p1;
output      [15:0]      ov_pkt_bufadd_p1;
input                   i_pkt_ack_p1; 
output      [133:0]     ov_pkt_p2;
output                  o_pkt_wr_p2;
output      [15:0]      ov_pkt_bufadd_p2;
input                   i_pkt_ack_p2; 
output      [133:0]     ov_pkt_p3;
output                  o_pkt_wr_p3;
output      [15:0]      ov_pkt_bufadd_p3;
input                   i_pkt_ack_p3; 
output      [133:0]     ov_pkt_p4;
output                  o_pkt_wr_p4;
output      [15:0]      ov_pkt_bufadd_p4;
input                   i_pkt_ack_p4; 

input       [8:0]       iv_free_bufid_fifo_rdusedw;
input       [8:0]       iv_be_threshold_value;
input       [8:0]       iv_rc_threshold_value;
input       [8:0]       iv_map_req_threshold_value;

output                  o_port0_inpkt_pulse;            
output                  o_port0_discard_pkt_pulse;      
output                  o_port1_inpkt_pulse;            
output                  o_port1_discard_pkt_pulse;      
output                  o_port2_inpkt_pulse;            
output                  o_port2_discard_pkt_pulse;      
output                  o_port3_inpkt_pulse;            
output                  o_port3_discard_pkt_pulse;      
output                  o_port4_inpkt_pulse;            
output                  o_port4_discard_pkt_pulse;      

output                  o_fifo_underflow_pulse_p0;
output                  o_fifo_overflow_pulse_p0; 
output                  o_fifo_underflow_pulse_p1;
output                  o_fifo_overflow_pulse_p1; 
output                  o_fifo_underflow_pulse_p2;
output                  o_fifo_overflow_pulse_p2; 
output                  o_fifo_underflow_pulse_p3;
output                  o_fifo_overflow_pulse_p3; 
output                  o_fifo_underflow_pulse_p4;
output                  o_fifo_overflow_pulse_p4; 

output     [1:0]        ov_gmii_read_state_p0;          
output                  o_gmii_fifo_full_p0;            
output                  o_gmii_fifo_empty_p0;           
output     [3:0]        ov_descriptor_extract_state_p0; 
output     [1:0]        ov_descriptor_send_state_p0;    
output     [1:0]        ov_data_splice_state_p0;        
output     [1:0]        ov_input_buf_interface_state_p0;
       
output     [1:0]        ov_gmii_read_state_p1;          
output                  o_gmii_fifo_full_p1;            
output                  o_gmii_fifo_empty_p1;           
output     [3:0]        ov_descriptor_extract_state_p1; 
output     [1:0]        ov_descriptor_send_state_p1;    
output     [1:0]        ov_data_splice_state_p1;        
output     [1:0]        ov_input_buf_interface_state_p1;
       
output     [1:0]        ov_gmii_read_state_p2;          
output                  o_gmii_fifo_full_p2;            
output                  o_gmii_fifo_empty_p2;           
output     [3:0]        ov_descriptor_extract_state_p2; 
output     [1:0]        ov_descriptor_send_state_p2;    
output     [1:0]        ov_data_splice_state_p2;        
output     [1:0]        ov_input_buf_interface_state_p2;
       
output     [1:0]        ov_gmii_read_state_p3;          
output                  o_gmii_fifo_full_p3;            
output                  o_gmii_fifo_empty_p3;           
output     [3:0]        ov_descriptor_extract_state_p3; 
output     [1:0]        ov_descriptor_send_state_p3;    
output     [1:0]        ov_data_splice_state_p3;        
output     [1:0]        ov_input_buf_interface_state_p3;
         
output     [1:0]        ov_gmii_read_state_p4;          
output                  o_gmii_fifo_full_p4;            
output                  o_gmii_fifo_empty_p4;           
output     [3:0]        ov_descriptor_extract_state_p4; 
output     [1:0]        ov_descriptor_send_state_p4;    
output     [1:0]        ov_data_splice_state_p4;        
output     [1:0]        ov_input_buf_interface_state_p4;


network_input_process #(.inport(4'b0000)) network_input_process_inst0
    (
        .clk_sys(clk_sys),
        .reset_n(reset_n),
        
        .i_gmii_rst_n(i_gmii_rst_n_p0),

        .clk_gmii_rx(clk_gmii_rx_p0),
        .i_gmii_dv(i_gmii_dv_p0),
        .iv_gmii_rxd(iv_gmii_rxd_p0),
        .i_gmii_er(i_gmii_er_p0),
        
        .timer_rst(timer_rst),
        .port_type(port_type[0]),
        .cfg_finish(cfg_finish),
        
        .i_pkt_bufid_wr(i_pkt_bufid_wr_p0),
        .iv_pkt_bufid(iv_pkt_bufid_p0),
        .o_pkt_bufid_ack(o_pkt_bufid_ack_p0),

        .o_descriptor_wr(o_descriptor_wr_p0),
        .ov_descriptor(ov_descriptor_p0),
        .i_descriptor_ack(i_descriptor_ack_p0),

        .ov_pkt(ov_pkt_p0),
        .o_pkt_wr(o_pkt_wr_p0),
        .ov_pkt_bufadd(ov_pkt_bufadd_p0),
        .i_pkt_ack(i_pkt_ack_p0),
        
        .iv_free_bufid_fifo_rdusedw(iv_free_bufid_fifo_rdusedw),
        .iv_be_threshold_value(iv_be_threshold_value),
        .iv_rc_threshold_value(iv_rc_threshold_value),
        .iv_map_req_threshold_value(iv_map_req_threshold_value),
        
        .o_inpkt_pulse(o_port0_inpkt_pulse),              
        .o_discard_pkt_pulse(o_port0_discard_pkt_pulse),
        .o_fifo_underflow_pulse(o_fifo_underflow_pulse_p0),
        .o_fifo_overflow_pulse(o_fifo_overflow_pulse_p0),
   
        .ov_gmii_read_state(ov_gmii_read_state_p0),          
        .o_gmii_fifo_full(o_gmii_fifo_full_p0),            
        .o_gmii_fifo_empty(o_gmii_fifo_empty_p0),           
        .ov_descriptor_extract_state(ov_descriptor_extract_state_p0), 
        .ov_descriptor_send_state(ov_descriptor_send_state_p0),    
        .ov_data_splice_state(ov_data_splice_state_p0),        
        .ov_input_buf_interface_state(ov_input_buf_interface_state_p0)  
    );
    
network_input_process #(.inport(4'b0001)) network_input_process_inst1
    (
        .clk_sys(clk_sys),
        .reset_n(reset_n),
        
        .i_gmii_rst_n(i_gmii_rst_n_p1),

        .clk_gmii_rx(clk_gmii_rx_p1),
        .i_gmii_dv(i_gmii_dv_p1),
        .iv_gmii_rxd(iv_gmii_rxd_p1),
        .i_gmii_er(i_gmii_er_p1),
        
        .timer_rst(timer_rst),
        .port_type(port_type[1]),
        .cfg_finish(cfg_finish),        
        
        .i_pkt_bufid_wr(i_pkt_bufid_wr_p1),
        .iv_pkt_bufid(iv_pkt_bufid_p1),
        .o_pkt_bufid_ack(o_pkt_bufid_ack_p1),

        .o_descriptor_wr(o_descriptor_wr_p1),
        .ov_descriptor(ov_descriptor_p1),
        .i_descriptor_ack(i_descriptor_ack_p1),

        .ov_pkt(ov_pkt_p1),
        .o_pkt_wr(o_pkt_wr_p1),
        .ov_pkt_bufadd(ov_pkt_bufadd_p1),
        .i_pkt_ack(i_pkt_ack_p1),
        
        .iv_free_bufid_fifo_rdusedw(iv_free_bufid_fifo_rdusedw),
        .iv_be_threshold_value(iv_be_threshold_value),
        .iv_rc_threshold_value(iv_rc_threshold_value),
        .iv_map_req_threshold_value(iv_map_req_threshold_value),
        
        .o_inpkt_pulse(o_port1_inpkt_pulse),              
        .o_discard_pkt_pulse(o_port1_discard_pkt_pulse),
        .o_fifo_underflow_pulse(o_fifo_underflow_pulse_p1),
        .o_fifo_overflow_pulse(o_fifo_overflow_pulse_p1),        
      
        .ov_gmii_read_state(ov_gmii_read_state_p1),          
        .o_gmii_fifo_full(o_gmii_fifo_full_p1),            
        .o_gmii_fifo_empty(o_gmii_fifo_empty_p1),           
        .ov_descriptor_extract_state(ov_descriptor_extract_state_p1), 
        .ov_descriptor_send_state(ov_descriptor_send_state_p1),    
        .ov_data_splice_state(ov_data_splice_state_p1),        
        .ov_input_buf_interface_state(ov_input_buf_interface_state_p1) 
    );

network_input_process #(.inport(4'b0010)) network_input_process_inst2
    (
        .clk_sys(clk_sys),
        .reset_n(reset_n),
        
        .i_gmii_rst_n(i_gmii_rst_n_p2),

        .clk_gmii_rx(clk_gmii_rx_p2),
        .i_gmii_dv(i_gmii_dv_p2),
        .iv_gmii_rxd(iv_gmii_rxd_p2),
        .i_gmii_er(i_gmii_er_p2),
        
        .timer_rst(timer_rst),
        .port_type(port_type[2]),
        .cfg_finish(cfg_finish),        
        
        .i_pkt_bufid_wr(i_pkt_bufid_wr_p2),
        .iv_pkt_bufid(iv_pkt_bufid_p2),
        .o_pkt_bufid_ack(o_pkt_bufid_ack_p2),

        .o_descriptor_wr(o_descriptor_wr_p2),
        .ov_descriptor(ov_descriptor_p2),
        .i_descriptor_ack(i_descriptor_ack_p2),

        .ov_pkt(ov_pkt_p2),
        .o_pkt_wr(o_pkt_wr_p2),
        .ov_pkt_bufadd(ov_pkt_bufadd_p2),
        .i_pkt_ack(i_pkt_ack_p2),
        
        .iv_free_bufid_fifo_rdusedw(iv_free_bufid_fifo_rdusedw),
        .iv_be_threshold_value(iv_be_threshold_value),
        .iv_rc_threshold_value(iv_rc_threshold_value),
        .iv_map_req_threshold_value(iv_map_req_threshold_value),
        
        .o_inpkt_pulse(o_port2_inpkt_pulse),              
        .o_discard_pkt_pulse(o_port2_discard_pkt_pulse),
        .o_fifo_underflow_pulse(o_fifo_underflow_pulse_p2),
        .o_fifo_overflow_pulse(o_fifo_overflow_pulse_p2),
        
        .ov_gmii_read_state(ov_gmii_read_state_p2),          
        .o_gmii_fifo_full(o_gmii_fifo_full_p2),            
        .o_gmii_fifo_empty(o_gmii_fifo_empty_p2),           
        .ov_descriptor_extract_state(ov_descriptor_extract_state_p2), 
        .ov_descriptor_send_state(ov_descriptor_send_state_p2),    
        .ov_data_splice_state(ov_data_splice_state_p2),        
        .ov_input_buf_interface_state(ov_input_buf_interface_state_p2) 
    );  
    
 network_input_process #(.inport(4'b0011)) network_input_process_inst3
     (
        .clk_sys(clk_sys),
        .reset_n(reset_n),
        
        .i_gmii_rst_n(i_gmii_rst_n_p3),

        .clk_gmii_rx(clk_gmii_rx_p3),
        .i_gmii_dv(i_gmii_dv_p3),
        .iv_gmii_rxd(iv_gmii_rxd_p3),
        .i_gmii_er(i_gmii_er_p3),
        
        .timer_rst(timer_rst),
        .port_type(port_type[3]),
        .cfg_finish(cfg_finish),
        
        .i_pkt_bufid_wr(i_pkt_bufid_wr_p3),
        .iv_pkt_bufid(iv_pkt_bufid_p3),
        .o_pkt_bufid_ack(o_pkt_bufid_ack_p3),

        .o_descriptor_wr(o_descriptor_wr_p3),
        .ov_descriptor(ov_descriptor_p3),
        .i_descriptor_ack(i_descriptor_ack_p3),

        .ov_pkt(ov_pkt_p3),
        .o_pkt_wr(o_pkt_wr_p3),
        .ov_pkt_bufadd(ov_pkt_bufadd_p3),
        .i_pkt_ack(i_pkt_ack_p3),
        
        .iv_free_bufid_fifo_rdusedw(iv_free_bufid_fifo_rdusedw),
        .iv_be_threshold_value(iv_be_threshold_value),
        .iv_rc_threshold_value(iv_rc_threshold_value),
        .iv_map_req_threshold_value(iv_map_req_threshold_value),
        
        .o_inpkt_pulse(o_port3_inpkt_pulse),              
        .o_discard_pkt_pulse(o_port3_discard_pkt_pulse),
        .o_fifo_underflow_pulse(o_fifo_underflow_pulse_p3),
        .o_fifo_overflow_pulse(o_fifo_overflow_pulse_p3),        
      
        .ov_gmii_read_state(ov_gmii_read_state_p3),          
        .o_gmii_fifo_full(o_gmii_fifo_full_p3),            
        .o_gmii_fifo_empty(o_gmii_fifo_empty_p3),           
        .ov_descriptor_extract_state(ov_descriptor_extract_state_p3), 
        .ov_descriptor_send_state(ov_descriptor_send_state_p3),    
        .ov_data_splice_state(ov_data_splice_state_p3),        
        .ov_input_buf_interface_state(ov_input_buf_interface_state_p3) 
     );

 network_input_process #(.inport(4'b0100)) network_input_process_inst4
     (
         .clk_sys(clk_sys),
         .reset_n(reset_n),
         
         .i_gmii_rst_n(i_gmii_rst_n_p4),

         .clk_gmii_rx(clk_gmii_rx_p4),
         .i_gmii_dv(i_gmii_dv_p4),
         .iv_gmii_rxd(iv_gmii_rxd_p4),
         .i_gmii_er(i_gmii_er_p4),
        
         .timer_rst(timer_rst),
         .port_type(1'b0),//(port_type[4]),
         .cfg_finish(cfg_finish),
        
         .i_pkt_bufid_wr(i_pkt_bufid_wr_p4),
         .iv_pkt_bufid(iv_pkt_bufid_p4),
         .o_pkt_bufid_ack(o_pkt_bufid_ack_p4),

         .o_descriptor_wr(o_descriptor_wr_p4),
         .ov_descriptor(ov_descriptor_p4),
         .i_descriptor_ack(i_descriptor_ack_p4),

         .ov_pkt(ov_pkt_p4),
         .o_pkt_wr(o_pkt_wr_p4),
         .ov_pkt_bufadd(ov_pkt_bufadd_p4),
         .i_pkt_ack(i_pkt_ack_p4),
        
         .iv_free_bufid_fifo_rdusedw(iv_free_bufid_fifo_rdusedw),
         .iv_be_threshold_value(iv_be_threshold_value),
         .iv_rc_threshold_value(iv_rc_threshold_value),
         .iv_map_req_threshold_value(iv_map_req_threshold_value),
        
         .o_inpkt_pulse(o_port4_inpkt_pulse),              
         .o_discard_pkt_pulse(o_port4_discard_pkt_pulse),
        .o_fifo_underflow_pulse(o_fifo_underflow_pulse_p4),
        .o_fifo_overflow_pulse(o_fifo_overflow_pulse_p4),
        
         .ov_gmii_read_state(ov_gmii_read_state_p4),          
         .o_gmii_fifo_full(o_gmii_fifo_full_p4),            
         .o_gmii_fifo_empty(o_gmii_fifo_empty_p4),           
         .ov_descriptor_extract_state(ov_descriptor_extract_state_p4), 
         .ov_descriptor_send_state(ov_descriptor_send_state_p4),    
         .ov_data_splice_state(ov_data_splice_state_p4),        
         .ov_input_buf_interface_state(ov_input_buf_interface_state_p4) 
     );

endmodule