// Copyright (C) 1953-2021 NUDT
// Verilog module name - TSSwitch 
// Version: TSSwitch_V1.0
// Created:
//         by - fenglin 
//         at - 1.2021
////////////////////////////////////////////////////////////////////////////
// Description:
//        top of TSSwitch
//               
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module TSSwitch
(
       i_clk,
       i_rst_n,
       
       ov_gmii_txd_p0,
       o_gmii_tx_en_p0,
       o_gmii_tx_er_p0,
       o_gmii_tx_clk_p0,

       ov_gmii_txd_p1,
       o_gmii_tx_en_p1,
       o_gmii_tx_er_p1,
       o_gmii_tx_clk_p1,
       
       ov_gmii_txd_p2,
       o_gmii_tx_en_p2,
       o_gmii_tx_er_p2,
       o_gmii_tx_clk_p2,
       
       ov_gmii_txd_p3,
       o_gmii_tx_en_p3,
       o_gmii_tx_er_p3,
       o_gmii_tx_clk_p3,
       
       ov_gmii_txd_p4,
       o_gmii_tx_en_p4,
       o_gmii_tx_er_p4,
       o_gmii_tx_clk_p4,
       
       //Network input top module
       i_gmii_rxclk_p0,
       i_gmii_dv_p0,
       iv_gmii_rxd_p0,
       i_gmii_er_p0,
       
       i_gmii_rxclk_p1,
       i_gmii_dv_p1,
       iv_gmii_rxd_p1,
       i_gmii_er_p1,
       
       i_gmii_rxclk_p2,
       i_gmii_dv_p2,
       iv_gmii_rxd_p2,
       i_gmii_er_p2,
       
       i_gmii_rxclk_p3,
       i_gmii_dv_p3,
       iv_gmii_rxd_p3,
       i_gmii_er_p3,
       
       i_gmii_rxclk_p4,
       i_gmii_dv_p4,
       iv_gmii_rxd_p4,
       i_gmii_er_p4,

       i_gmii_rst_n_p0,     
       i_gmii_rst_n_p1,     
       i_gmii_rst_n_p2,     
       i_gmii_rst_n_p3,     
       i_gmii_rst_n_p4,     

       iv_wr_command ,   
       i_wr_command_wr,  
       iv_rd_command  ,  
       i_rd_command_wr,  
       ov_rd_command_ack,
       
       i_timer_rst_gts2others,
       i_time_slot_switch,
       iv_time_slot,
       
       port_type_tsnchip2adp,
       //o_init_led,
       pluse_s,

       o_fifo_underflow_pulse_p0_rx,
       o_fifo_overflow_pulse_p0_rx, 
       o_fifo_underflow_pulse_p1_rx,
       o_fifo_overflow_pulse_p1_rx, 
       o_fifo_underflow_pulse_p2_rx,
       o_fifo_overflow_pulse_p2_rx, 
       o_fifo_underflow_pulse_p3_rx,
       o_fifo_overflow_pulse_p3_rx, 
       o_fifo_underflow_pulse_p4_rx,
       o_fifo_overflow_pulse_p4_rx, 

       o_fifo_overflow_pulse_p0_tx,
       o_fifo_overflow_pulse_p1_tx,
       o_fifo_overflow_pulse_p2_tx,
       o_fifo_overflow_pulse_p3_tx,
       o_fifo_overflow_pulse_p4_tx
);

//I/O
input                  i_clk;                   //125Mhz
input                  i_rst_n;

input                  i_gmii_rst_n_p0;  
input                  i_gmii_rst_n_p1;  
input                  i_gmii_rst_n_p2;  
input                  i_gmii_rst_n_p3;  
input                  i_gmii_rst_n_p4;  

// network output
output     [7:0]       ov_gmii_txd_p0;
output                 o_gmii_tx_en_p0;
output                 o_gmii_tx_er_p0;
output                 o_gmii_tx_clk_p0;

output     [7:0]       ov_gmii_txd_p1;
output                 o_gmii_tx_en_p1;
output                 o_gmii_tx_er_p1;
output                 o_gmii_tx_clk_p1;    

output     [7:0]       ov_gmii_txd_p2;
output                 o_gmii_tx_en_p2;
output                 o_gmii_tx_er_p2;
output                 o_gmii_tx_clk_p2;    

output     [7:0]       ov_gmii_txd_p3;
output                 o_gmii_tx_en_p3;
output                 o_gmii_tx_er_p3;
output                 o_gmii_tx_clk_p3;

output     [7:0]       ov_gmii_txd_p4;
output                 o_gmii_tx_en_p4;
output                 o_gmii_tx_er_p4;
output                 o_gmii_tx_clk_p4;


//network input
input                   i_gmii_rxclk_p0;
input                   i_gmii_dv_p0;
input      [7:0]        iv_gmii_rxd_p0;
input                   i_gmii_er_p0;

input                   i_gmii_rxclk_p1;
input                   i_gmii_dv_p1;
input      [7:0]        iv_gmii_rxd_p1;
input                   i_gmii_er_p1;

input                   i_gmii_rxclk_p2;
input                   i_gmii_dv_p2;
input      [7:0]        iv_gmii_rxd_p2;
input                   i_gmii_er_p2;

input                   i_gmii_rxclk_p3;
input                   i_gmii_dv_p3;
input      [7:0]        iv_gmii_rxd_p3;
input                   i_gmii_er_p3;

input                   i_gmii_rxclk_p4;
input                   i_gmii_dv_p4;
input      [7:0]        iv_gmii_rxd_p4;
input                   i_gmii_er_p4;

input       [203:0]     iv_wr_command     ;
input                   i_wr_command_wr   ;
input       [203:0]     iv_rd_command     ; 
input                   i_rd_command_wr   ;
output      [203:0]     ov_rd_command_ack ;


output                  pluse_s;
output     [7:0]        port_type_tsnchip2adp;

output                  o_fifo_underflow_pulse_p0_rx;
output                  o_fifo_overflow_pulse_p0_rx; 
output                  o_fifo_underflow_pulse_p1_rx;
output                  o_fifo_overflow_pulse_p1_rx; 
output                  o_fifo_underflow_pulse_p2_rx;
output                  o_fifo_overflow_pulse_p2_rx; 
output                  o_fifo_underflow_pulse_p3_rx;
output                  o_fifo_overflow_pulse_p3_rx; 
output                  o_fifo_underflow_pulse_p4_rx;
output                  o_fifo_overflow_pulse_p4_rx; 

output                  o_fifo_overflow_pulse_p0_tx;
output                  o_fifo_overflow_pulse_p1_tx;
output                  o_fifo_overflow_pulse_p2_tx;
output                  o_fifo_overflow_pulse_p3_tx;
output                  o_fifo_overflow_pulse_p4_tx;

input                   i_timer_rst_gts2others;
input                   i_time_slot_switch;
input    [9:0]          iv_time_slot;

//wire 

//*******************************
//              nip
//*******************************
//port0
wire       [8:0]        wv_bufid_pcb2nip_0;		
wire                    w_bufid_wr_pcb2nip_0;	
wire                    w_bufid_ack_nip2pcb_0;	

wire       [45:0]       wv_descriptor_nip2flt_0;   
wire                    w_descriptor_wr_nip2flt_0; 
wire                    w_descriptor_ack_flt2nip_0;

wire       [133:0]      wv_pkt_data_pcb2nip_0;		
wire                    w_pkt_data_wr_pcb2nip_0;	
wire       [15:0]       wv_pkt_addr_pcb2nip_0;		
wire                    w_pkt_ack_pcb2nip_0;		

//port1
wire       [8:0]        wv_bufid_pcb2nip_1;
wire                    w_bufid_wr_pcb2nip_1;
wire                    w_bufid_ack_nip2pcb_1;

wire       [45:0]       wv_descriptor_nip2flt_1;
wire                    w_descriptor_wr_nip2flt_1;
wire                    w_descriptor_ack_flt2nip_1;

wire       [133:0]      wv_pkt_data_pcb2nip_1;
wire                    w_pkt_data_wr_pcb2nip_1;
wire       [15:0]       wv_pkt_addr_pcb2nip_1;
wire                    w_pkt_ack_pcb2nip_1;

//port2
wire       [8:0]        wv_bufid_pcb2nip_2;
wire                    w_bufid_wr_pcb2nip_2;
wire                    w_bufid_ack_nip2pcb_2;

wire       [45:0]       wv_descriptor_nip2flt_2;
wire                    w_descriptor_wr_nip2flt_2;
wire                    w_descriptor_ack_flt2nip_2;

wire       [133:0]      wv_pkt_data_pcb2nip_2;
wire                    w_pkt_data_wr_pcb2nip_2;
wire       [15:0]       wv_pkt_addr_pcb2nip_2;
wire                    w_pkt_ack_pcb2nip_2;

//port3
wire       [8:0]        wv_bufid_pcb2nip_3;
wire                    w_bufid_wr_pcb2nip_3;
wire                    w_bufid_ack_nip2pcb_3;

wire       [45:0]       wv_descriptor_nip2flt_3;
wire                    w_descriptor_wr_nip2flt_3;
wire                    w_descriptor_ack_flt2nip_3;

wire       [133:0]      wv_pkt_data_pcb2nip_3;
wire                    w_pkt_data_wr_pcb2nip_3;
wire       [15:0]       wv_pkt_addr_pcb2nip_3;
wire                    w_pkt_ack_pcb2nip_3;

//port4
wire       [8:0]        wv_bufid_pcb2nip_4;
wire                    w_bufid_wr_pcb2nip_4;
wire                    w_bufid_ack_nip2pcb_4;

wire       [45:0]       wv_descriptor_nip2flt_4;
wire                    w_descriptor_wr_nip2flt_4;
wire                    w_descriptor_ack_flt2nip_4;

wire       [133:0]      wv_pkt_data_pcb2nip_4;
wire                    w_pkt_data_wr_pcb2nip_4;
wire       [15:0]       wv_pkt_addr_pcb2nip_4;
wire                    w_pkt_ack_pcb2nip_4;


//*******************************
//              flt
//*******************************
wire       [8:0]        wv_pkt_bufid_flt2pcb;    
wire                    w_pkt_bufid_wr_flt2pcb;  
wire       [3:0]        wv_pkt_bufid_cnt_flt2pcb;
//port0
wire       [8:0]        wv_pkt_bufid_flt2nop_0;
wire       [2:0]        wv_pkt_type_flt2nop_0;
wire                    w_pkt_bufid_wr_flt2nop_0;

//port1
wire       [8:0]        wv_pkt_bufid_flt2nop_1;
wire       [2:0]        wv_pkt_type_flt2nop_1;
wire                    w_pkt_bufid_wr_flt2nop_1;

//port2
wire       [8:0]        wv_pkt_bufid_flt2nop_2;
wire       [2:0]        wv_pkt_type_flt2nop_2;
wire                    w_pkt_bufid_wr_flt2nop_2;

//port3
wire       [8:0]        wv_pkt_bufid_flt2nop_3;
wire       [2:0]        wv_pkt_type_flt2nop_3;
wire                    w_pkt_bufid_wr_flt2nop_3;

//port4
wire       [8:0]        wv_pkt_bufid_flt2nop_4;
wire       [2:0]        wv_pkt_type_flt2nop_4;
wire                    w_pkt_bufid_wr_flt2nop_4;

//*******************************
//             nop
//*******************************
//port0
wire       [8:0]        wv_pkt_bufid_nop2pcb_0;    
wire                    w_pkt_bufid_wr_nop2pcb_0;  
wire                    w_pkt_bufid_ack_pcb2nop_0; 

wire       [15:0]       wv_pkt_raddr_nop2pcb_0;  
wire                    w_pkt_rd_nop2pcb_0;       
wire                    w_pkt_raddr_ack_pcb2nop_0;

wire       [133:0]      wv_pkt_data_pcb2nop_0;  
wire                    w_pkt_data_wr_pcb2nop_0;

//port1
wire       [8:0]        wv_pkt_bufid_nop2pcb_1;    
wire                    w_pkt_bufid_wr_nop2pcb_1;  
wire                    w_pkt_bufid_ack_pcb2nop_1; 

wire       [15:0]       wv_pkt_raddr_nop2pcb_1;      
wire                    w_pkt_rd_nop2pcb_1;       
wire                    w_pkt_raddr_ack_pcb2nop_1;

wire       [133:0]      wv_pkt_data_pcb2nop_1;  
wire                    w_pkt_data_wr_pcb2nop_1;

//port2
wire       [8:0]        wv_pkt_bufid_nop2pcb_2;    
wire                    w_pkt_bufid_wr_nop2pcb_2;  
wire                    w_pkt_bufid_ack_pcb2nop_2; 

wire       [15:0]       wv_pkt_raddr_nop2pcb_2;     
wire                    w_pkt_rd_nop2pcb_2;       
wire                    w_pkt_raddr_ack_pcb2nop_2;

wire       [133:0]      wv_pkt_data_pcb2nop_2;  
wire                    w_pkt_data_wr_pcb2nop_2;

//port3
wire       [8:0]        wv_pkt_bufid_nop2pcb_3;    
wire                    w_pkt_bufid_wr_nop2pcb_3;  
wire                    w_pkt_bufid_ack_pcb2nop_3; 

wire       [15:0]       wv_pkt_raddr_nop2pcb_3;     
wire                    w_pkt_rd_nop2pcb_3;       
wire                    w_pkt_raddr_ack_pcb2nop_3;

wire       [133:0]      wv_pkt_data_pcb2nop_3;  
wire                    w_pkt_data_wr_pcb2nop_3;

//port4
wire       [8:0]        wv_pkt_bufid_nop2pcb_4;    
wire                    w_pkt_bufid_wr_nop2pcb_4;  
wire                    w_pkt_bufid_ack_pcb2nop_4; 

wire       [15:0]       wv_pkt_raddr_nop2pcb_4;    
wire                    w_pkt_rd_nop2pcb_4;       
wire                    w_pkt_raddr_ack_pcb2nop_4;

wire       [133:0]      wv_pkt_data_pcb2nop_4;  
wire                    w_pkt_data_wr_pcb2nop_4;

//*******************************
//             CPA
//*******************************


wire       [1:0]        wv_cfg_finish_cpa2others;    
wire                    w_qbv_or_qch_cpa2nop;  

wire                    w_port0_outpkt_pulse_nop2cpa;       
wire                    w_port1_outpkt_pulse_nop2cpa;       
wire                    w_port2_outpkt_pulse_nop2cpa;       
wire                    w_port3_outpkt_pulse_nop2cpa;       
wire                    w_port4_outpkt_pulse_nop2cpa;       


wire       [13:0]       wv_flt_ram_addr;         
wire       [8:0]        wv_flt_ram_wdata;        
wire                    w_flt_ram_wr;            
wire       [8:0]        wv_flt_ram_rdata;        
wire                    w_flt_ram_rd;            
                        
wire       [9:0]        wv_qgc0_ram_addr;        
wire       [7:0]        wv_qgc0_ram_wdata;       
wire                    w_qgc0_ram_wr;           
wire       [7:0]        wv_qgc0_ram_rdata;       
wire                    w_qgc0_ram_rd;           
                                                 
wire       [9:0]        wv_qgc1_ram_addr;        
wire       [7:0]        wv_qgc1_ram_wdata;       
wire                    w_qgc1_ram_wr;           
wire       [7:0]        wv_qgc1_ram_rdata;       
wire                    w_qgc1_ram_rd;           
                                                 
wire       [9:0]        wv_qgc2_ram_addr;        
wire       [7:0]        wv_qgc2_ram_wdata;       
wire                    w_qgc2_ram_wr;           
wire       [7:0]        wv_qgc2_ram_rdata;       
wire                    w_qgc2_ram_rd;           
                                                 
wire       [9:0]        wv_qgc3_ram_addr;        
wire       [7:0]        wv_qgc3_ram_wdata;       
wire                    w_qgc3_ram_wr;           
wire       [7:0]        wv_qgc3_ram_rdata;       
wire                    w_qgc3_ram_rd;           
                                                 
wire       [9:0]        wv_qgc4_ram_addr;        
wire       [7:0]        wv_qgc4_ram_wdata;       
wire                    w_qgc4_ram_wr;           
wire       [7:0]        wv_qgc4_ram_rdata;       
wire                    w_qgc4_ram_rd;                                                          //
                      

//port0
     
wire       [1:0]        wv_gmii_read_state_p0_nip2cpa;           
wire                    w_gmii_fifo_full_p0_nip2cpa;             
wire                    w_gmii_fifo_empty_p0_nip2cpa;            
wire       [3:0]        wv_descriptor_extract_state_p0_nip2cpa;  
wire       [1:0]        wv_descriptor_send_state_p0_nip2cpa;     
wire       [1:0]        wv_data_splice_state_p0_nip2cpa;         
wire       [1:0]        wv_input_buf_interface_state_p0_nip2cpa; 

//port1
      
wire       [1:0]        wv_gmii_read_state_p1_nip2cpa;           
wire                    w_gmii_fifo_full_p1_nip2cpa;             
wire                    w_gmii_fifo_empty_p1_nip2cpa;            
wire       [3:0]        wv_descriptor_extract_state_p1_nip2cpa;  
wire       [1:0]        wv_descriptor_send_state_p1_nip2cpa;     
wire       [1:0]        wv_data_splice_state_p1_nip2cpa;         
wire       [1:0]        wv_input_buf_interface_state_p1_nip2cpa; 

//port2
     
wire       [1:0]        wv_gmii_read_state_p2_nip2cpa;           
wire                    w_gmii_fifo_full_p2_nip2cpa;             
wire                    w_gmii_fifo_empty_p2_nip2cpa;            
wire       [3:0]        wv_descriptor_extract_state_p2_nip2cpa;  
wire       [1:0]        wv_descriptor_send_state_p2_nip2cpa;     
wire       [1:0]        wv_data_splice_state_p2_nip2cpa;         
wire       [1:0]        wv_input_buf_interface_state_p2_nip2cpa; 

//port3
      
wire       [1:0]        wv_gmii_read_state_p3_nip2cpa;           
wire                    w_gmii_fifo_full_p3_nip2cpa;             
wire                    w_gmii_fifo_empty_p3_nip2cpa;            
wire       [3:0]        wv_descriptor_extract_state_p3_nip2cpa;  
wire       [1:0]        wv_descriptor_send_state_p3_nip2cpa;     
wire       [1:0]        wv_data_splice_state_p3_nip2cpa;         
wire       [1:0]        wv_input_buf_interface_state_p3_nip2cpa; 

//port4
     
wire       [1:0]        wv_gmii_read_state_p4_nip2cpa;           
wire                    w_gmii_fifo_full_p4_nip2cpa;             
wire                    w_gmii_fifo_empty_p4_nip2cpa;            
wire       [3:0]        wv_descriptor_extract_state_p4_nip2cpa;  
wire       [1:0]        wv_descriptor_send_state_p4_nip2cpa;     
wire       [1:0]        wv_data_splice_state_p4_nip2cpa;         
wire       [1:0]        wv_input_buf_interface_state_p4_nip2cpa; 

wire       [3:0]        wv_pkt_write_state_pcb2cpa;      
wire       [3:0]        wv_pcb_pkt_read_state_pcb2cpa;   
wire       [3:0]        wv_address_write_state_pcb2cpa;  
wire       [3:0]        wv_address_read_state_pcb2cpa;   
wire       [8:0]        wv_free_buf_fifo_rdusedw_pcb2cpa;

wire     [8:0]          wv_rc_regulation_value;   
wire     [8:0]          wv_be_regulation_value;   
wire     [8:0]          wv_unmap_regulation_value;



network_input_process_top network_input_top_inst(
.clk_sys                            (i_clk),
.reset_n                            (i_rst_n),

.iv_free_bufid_fifo_rdusedw         (wv_free_buf_fifo_rdusedw_pcb2cpa),
.iv_be_threshold_value              (wv_be_regulation_value),	
.iv_rc_threshold_value              (wv_rc_regulation_value),	
.iv_map_req_threshold_value         (wv_unmap_regulation_value),
            
.i_gmii_rst_n_p0                    (i_gmii_rst_n_p0),
.i_gmii_rst_n_p1                    (i_gmii_rst_n_p1),
.i_gmii_rst_n_p2                    (i_gmii_rst_n_p2),
.i_gmii_rst_n_p3                    (i_gmii_rst_n_p3),
.i_gmii_rst_n_p4                    (i_gmii_rst_n_p4),
                                
.clk_gmii_rx_p0                     (i_gmii_rxclk_p0),
.i_gmii_dv_p0                       (i_gmii_dv_p0),
.iv_gmii_rxd_p0                     (iv_gmii_rxd_p0),
.i_gmii_er_p0                       (i_gmii_er_p0),
            
.clk_gmii_rx_p1                     (i_gmii_rxclk_p1),
.i_gmii_dv_p1                       (i_gmii_dv_p1),
.iv_gmii_rxd_p1                     (iv_gmii_rxd_p1),
.i_gmii_er_p1                       (i_gmii_er_p1),
            
.clk_gmii_rx_p2                     (i_gmii_rxclk_p2),
.i_gmii_dv_p2                       (i_gmii_dv_p2),
.iv_gmii_rxd_p2                     (iv_gmii_rxd_p2),
.i_gmii_er_p2                       (i_gmii_er_p2),
            
.clk_gmii_rx_p3                     (i_gmii_rxclk_p3),
.i_gmii_dv_p3                       (i_gmii_dv_p3),
.iv_gmii_rxd_p3                     (iv_gmii_rxd_p3),
.i_gmii_er_p3                       (i_gmii_er_p3),
            
.clk_gmii_rx_p4                     (i_gmii_rxclk_p4),
.i_gmii_dv_p4                       (i_gmii_dv_p4),
.iv_gmii_rxd_p4                     (iv_gmii_rxd_p4),
.i_gmii_er_p4                       (i_gmii_er_p4),
            
.timer_rst                          (i_timer_rst_gts2others),//glb module
.port_type                          (port_type_tsnchip2adp),//cpa
.cfg_finish                         (wv_cfg_finish_cpa2others),

.iv_pkt_bufid_p0                    (wv_bufid_pcb2nip_0),            
.i_pkt_bufid_wr_p0                  (w_bufid_wr_pcb2nip_0),
.o_pkt_bufid_ack_p0                 (w_bufid_ack_nip2pcb_0),

.iv_pkt_bufid_p1                    (wv_bufid_pcb2nip_1),
.i_pkt_bufid_wr_p1                  (w_bufid_wr_pcb2nip_1),                   
.o_pkt_bufid_ack_p1                 (w_bufid_ack_nip2pcb_1),
            
.iv_pkt_bufid_p2                    (wv_bufid_pcb2nip_2),            
.i_pkt_bufid_wr_p2                  (w_bufid_wr_pcb2nip_2),
.o_pkt_bufid_ack_p2                 (w_bufid_ack_nip2pcb_2),
            
.iv_pkt_bufid_p3                    (wv_bufid_pcb2nip_3),    
.i_pkt_bufid_wr_p3                  (w_bufid_wr_pcb2nip_3),
.o_pkt_bufid_ack_p3                 (w_bufid_ack_nip2pcb_3),
            
.iv_pkt_bufid_p4                    (wv_bufid_pcb2nip_4),    
.i_pkt_bufid_wr_p4                  (w_bufid_wr_pcb2nip_4),
.o_pkt_bufid_ack_p4                 (w_bufid_ack_nip2pcb_4),
            
 
.ov_descriptor_p0                   (wv_descriptor_nip2flt_0), 
.o_descriptor_wr_p0                 (w_descriptor_wr_nip2flt_0),
.i_descriptor_ack_p0                (w_descriptor_ack_flt2nip_0),
            
.ov_descriptor_p1                   (wv_descriptor_nip2flt_1), 
.o_descriptor_wr_p1                 (w_descriptor_wr_nip2flt_1),
.i_descriptor_ack_p1                (w_descriptor_ack_flt2nip_1),
            
.ov_descriptor_p2                   (wv_descriptor_nip2flt_2), 
.o_descriptor_wr_p2                 (w_descriptor_wr_nip2flt_2),
.i_descriptor_ack_p2                (w_descriptor_ack_flt2nip_2),
            
.ov_descriptor_p3                   (wv_descriptor_nip2flt_3), 
.o_descriptor_wr_p3                 (w_descriptor_wr_nip2flt_3),
.i_descriptor_ack_p3                (w_descriptor_ack_flt2nip_3),
                
.ov_descriptor_p4                   (wv_descriptor_nip2flt_4), 
.o_descriptor_wr_p4                 (w_descriptor_wr_nip2flt_4),
.i_descriptor_ack_p4                (w_descriptor_ack_flt2nip_4),               
            
.ov_pkt_p0                          (wv_pkt_data_pcb2nip_0),
.o_pkt_wr_p0                        (w_pkt_data_wr_pcb2nip_0),
.ov_pkt_bufadd_p0                   (wv_pkt_addr_pcb2nip_0),
.i_pkt_ack_p0                       (w_pkt_ack_pcb2nip_0),
            
.ov_pkt_p1                          (wv_pkt_data_pcb2nip_1),
.o_pkt_wr_p1                        (w_pkt_data_wr_pcb2nip_1),
.ov_pkt_bufadd_p1                   (wv_pkt_addr_pcb2nip_1),
.i_pkt_ack_p1                       (w_pkt_ack_pcb2nip_1),
            
.ov_pkt_p2                          (wv_pkt_data_pcb2nip_2),
.o_pkt_wr_p2                        (w_pkt_data_wr_pcb2nip_2),
.ov_pkt_bufadd_p2                   (wv_pkt_addr_pcb2nip_2),
.i_pkt_ack_p2                       (w_pkt_ack_pcb2nip_2),
            
.ov_pkt_p3                          (wv_pkt_data_pcb2nip_3),
.o_pkt_wr_p3                        (w_pkt_data_wr_pcb2nip_3),
.ov_pkt_bufadd_p3                   (wv_pkt_addr_pcb2nip_3),
.i_pkt_ack_p3                       (w_pkt_ack_pcb2nip_3),
            
.ov_pkt_p4                          (wv_pkt_data_pcb2nip_4),
.o_pkt_wr_p4                        (w_pkt_data_wr_pcb2nip_4),
.ov_pkt_bufadd_p4                   (wv_pkt_addr_pcb2nip_4),
.i_pkt_ack_p4                       (w_pkt_ack_pcb2nip_4),
                                            
.o_port0_inpkt_pulse                (),      
.o_port0_discard_pkt_pulse          (),
.o_port1_inpkt_pulse                (),      
.o_port1_discard_pkt_pulse          (),
.o_port2_inpkt_pulse                (),      
.o_port2_discard_pkt_pulse          (),
.o_port3_inpkt_pulse                (),      
.o_port3_discard_pkt_pulse          (),
.o_port4_inpkt_pulse                (),      
.o_port4_discard_pkt_pulse          (),

.o_fifo_underflow_pulse_p0          (o_fifo_underflow_pulse_p0_rx),
.o_fifo_overflow_pulse_p0           (o_fifo_overflow_pulse_p0_rx ),
.o_fifo_underflow_pulse_p1          (o_fifo_underflow_pulse_p1_rx),
.o_fifo_overflow_pulse_p1           (o_fifo_overflow_pulse_p1_rx ),
.o_fifo_underflow_pulse_p2          (o_fifo_underflow_pulse_p2_rx),
.o_fifo_overflow_pulse_p2           (o_fifo_overflow_pulse_p2_rx ),
.o_fifo_underflow_pulse_p3          (o_fifo_underflow_pulse_p3_rx),
.o_fifo_overflow_pulse_p3           (o_fifo_overflow_pulse_p3_rx ),
.o_fifo_underflow_pulse_p4          (o_fifo_underflow_pulse_p4_rx),
.o_fifo_overflow_pulse_p4           (o_fifo_overflow_pulse_p4_rx ),


.ov_gmii_read_state_p0              (),               
.o_gmii_fifo_full_p0                (),                 
.o_gmii_fifo_empty_p0               (),                
.ov_descriptor_extract_state_p0     (),      
.ov_descriptor_send_state_p0        (),         
.ov_data_splice_state_p0            (),             
.ov_input_buf_interface_state_p0    (),     

.ov_gmii_read_state_p1              (),               
.o_gmii_fifo_full_p1                (),                 
.o_gmii_fifo_empty_p1               (),                
.ov_descriptor_extract_state_p1     (),      
.ov_descriptor_send_state_p1        (),         
.ov_data_splice_state_p1            (),             
.ov_input_buf_interface_state_p1    (),     

.ov_gmii_read_state_p2              (),               
.o_gmii_fifo_full_p2                (),                 
.o_gmii_fifo_empty_p2               (),                
.ov_descriptor_extract_state_p2     (),      
.ov_descriptor_send_state_p2        (),         
.ov_data_splice_state_p2            (),             
.ov_input_buf_interface_state_p2    (),     

.ov_gmii_read_state_p3              (),               
.o_gmii_fifo_full_p3                (),                 
.o_gmii_fifo_empty_p3               (),                
.ov_descriptor_extract_state_p3     (),      
.ov_descriptor_send_state_p3        (),         
.ov_data_splice_state_p3            (),             
.ov_input_buf_interface_state_p3    (),     
 
.ov_gmii_read_state_p4              (),               
.o_gmii_fifo_full_p4                (),                 
.o_gmii_fifo_empty_p4               (),                
.ov_descriptor_extract_state_p4     (),      
.ov_descriptor_send_state_p4        (),         
.ov_data_splice_state_p4            (),             
.ov_input_buf_interface_state_p4    ()      

);


forward_lookup_table forward_lookup_table_inst(
.i_clk                      (i_clk),
.i_rst_n                    (i_rst_n),
    
.iv_descriptor_p0           (wv_descriptor_nip2flt_0),
.i_descriptor_wr_p0         (w_descriptor_wr_nip2flt_0),
.o_descriptor_ack_p0        (w_descriptor_ack_flt2nip_0),
                            
.iv_descriptor_p1           (wv_descriptor_nip2flt_1),
.i_descriptor_wr_p1         (w_descriptor_wr_nip2flt_1),
.o_descriptor_ack_p1        (w_descriptor_ack_flt2nip_1),
                            
.iv_descriptor_p2           (wv_descriptor_nip2flt_2),
.i_descriptor_wr_p2         (w_descriptor_wr_nip2flt_2),
.o_descriptor_ack_p2        (w_descriptor_ack_flt2nip_2),
    
.iv_descriptor_p3           (wv_descriptor_nip2flt_3),
.i_descriptor_wr_p3         (w_descriptor_wr_nip2flt_3),
.o_descriptor_ack_p3        (w_descriptor_ack_flt2nip_3),
    
.iv_descriptor_p4           (wv_descriptor_nip2flt_4),
.i_descriptor_wr_p4         (w_descriptor_wr_nip2flt_4),
.o_descriptor_ack_p4        (w_descriptor_ack_flt2nip_4),
    
 
.ov_pkt_bufid_p0            (wv_pkt_bufid_flt2nop_0),
.ov_pkt_type_p0             (wv_pkt_type_flt2nop_0),
.o_pkt_bufid_wr_p0          (w_pkt_bufid_wr_flt2nop_0),
    
.ov_pkt_bufid_p1            (wv_pkt_bufid_flt2nop_1),
.ov_pkt_type_p1             (wv_pkt_type_flt2nop_1),
.o_pkt_bufid_wr_p1          (w_pkt_bufid_wr_flt2nop_1),
    
.ov_pkt_bufid_p2            (wv_pkt_bufid_flt2nop_2),
.ov_pkt_type_p2             (wv_pkt_type_flt2nop_2),
.o_pkt_bufid_wr_p2          (w_pkt_bufid_wr_flt2nop_2),
    
.ov_pkt_bufid_p3            (wv_pkt_bufid_flt2nop_3),
.ov_pkt_type_p3             (wv_pkt_type_flt2nop_3),
.o_pkt_bufid_wr_p3          (w_pkt_bufid_wr_flt2nop_3),
    
.ov_pkt_bufid_p4            (wv_pkt_bufid_flt2nop_4),
.ov_pkt_type_p4             (wv_pkt_type_flt2nop_4),
.o_pkt_bufid_wr_p4          (w_pkt_bufid_wr_flt2nop_4),
        
.ov_pkt_bufid               (wv_pkt_bufid_flt2pcb),
.o_pkt_bufid_wr             (w_pkt_bufid_wr_flt2pcb),
.ov_pkt_bufid_cnt           (wv_pkt_bufid_cnt_flt2pcb),

.ov_tdm_state               (),

.iv_flt_ram_addr            (wv_flt_ram_addr),   
.iv_flt_ram_wdata           (wv_flt_ram_wdata),  
.i_flt_ram_wr               (w_flt_ram_wr),      
.ov_flt_ram_rdata           (wv_flt_ram_rdata),  
.i_flt_ram_rd               (w_flt_ram_rd)       
);

pkt_centralized_buffer pkt_centralized_buffer_inst(
.clk_sys                 (i_clk),
.reset_n                 (i_rst_n), 
    
.iv_pkt_p0               (wv_pkt_data_pcb2nip_0),
.i_pkt_wr_p0             (w_pkt_data_wr_pcb2nip_0),
.iv_pkt_wr_bufadd_p0     (wv_pkt_addr_pcb2nip_0),
.o_pkt_wr_ack_p0         (w_pkt_ack_pcb2nip_0),
                         
.iv_pkt_p1               (wv_pkt_data_pcb2nip_1),
.i_pkt_wr_p1             (w_pkt_data_wr_pcb2nip_1),
.iv_pkt_wr_bufadd_p1     (wv_pkt_addr_pcb2nip_1),
.o_pkt_wr_ack_p1         (w_pkt_ack_pcb2nip_1),
                         
.iv_pkt_p2               (wv_pkt_data_pcb2nip_2),
.i_pkt_wr_p2             (w_pkt_data_wr_pcb2nip_2),
.iv_pkt_wr_bufadd_p2     (wv_pkt_addr_pcb2nip_2),
.o_pkt_wr_ack_p2         (w_pkt_ack_pcb2nip_2),

.iv_pkt_p3               (wv_pkt_data_pcb2nip_3),
.i_pkt_wr_p3             (w_pkt_data_wr_pcb2nip_3),
.iv_pkt_wr_bufadd_p3     (wv_pkt_addr_pcb2nip_3),
.o_pkt_wr_ack_p3         (w_pkt_ack_pcb2nip_3), 

.iv_pkt_p4               (wv_pkt_data_pcb2nip_4),
.i_pkt_wr_p4             (w_pkt_data_wr_pcb2nip_4),
.iv_pkt_wr_bufadd_p4     (wv_pkt_addr_pcb2nip_4),
.o_pkt_wr_ack_p4         (w_pkt_ack_pcb2nip_4), 

.iv_pkt_rd_bufadd_p0     (wv_pkt_raddr_nop2pcb_0),
.i_pkt_rd_p0             (w_pkt_rd_nop2pcb_0),
.o_pkt_rd_ack_p0         (w_pkt_raddr_ack_pcb2nop_0),
.ov_pkt_p0               (wv_pkt_data_pcb2nop_0),
.o_pkt_wr_p0             (w_pkt_data_wr_pcb2nop_0),
                         
.iv_pkt_rd_bufadd_p1     (wv_pkt_raddr_nop2pcb_1),
.i_pkt_rd_p1             (w_pkt_rd_nop2pcb_1),
.o_pkt_rd_ack_p1         (w_pkt_raddr_ack_pcb2nop_1),
.ov_pkt_p1               (wv_pkt_data_pcb2nop_1),   
.o_pkt_wr_p1             (w_pkt_data_wr_pcb2nop_1),

.iv_pkt_rd_bufadd_p2     (wv_pkt_raddr_nop2pcb_2),
.i_pkt_rd_p2             (w_pkt_rd_nop2pcb_2),
.o_pkt_rd_ack_p2         (w_pkt_raddr_ack_pcb2nop_2),
.ov_pkt_p2               (wv_pkt_data_pcb2nop_2),   
.o_pkt_wr_p2             (w_pkt_data_wr_pcb2nop_2),

.iv_pkt_rd_bufadd_p3     (wv_pkt_raddr_nop2pcb_3),
.i_pkt_rd_p3             (w_pkt_rd_nop2pcb_3),
.o_pkt_rd_ack_p3         (w_pkt_raddr_ack_pcb2nop_3),
.ov_pkt_p3               (wv_pkt_data_pcb2nop_3),   
.o_pkt_wr_p3             (w_pkt_data_wr_pcb2nop_3),

.iv_pkt_rd_bufadd_p4     (wv_pkt_raddr_nop2pcb_4),
.i_pkt_rd_p4             (w_pkt_rd_nop2pcb_4),
.o_pkt_rd_ack_p4         (w_pkt_raddr_ack_pcb2nop_4),
.ov_pkt_p4               (wv_pkt_data_pcb2nop_4),   
.o_pkt_wr_p4             (w_pkt_data_wr_pcb2nop_4),

.ov_pkt_bufid_p0         (wv_bufid_pcb2nip_0),
.o_pkt_bufid_wr_p0       (w_bufid_wr_pcb2nip_0),
.i_pkt_bufid_ack_p0      (w_bufid_ack_nip2pcb_0),
                         
.ov_pkt_bufid_p1         (wv_bufid_pcb2nip_1),
.o_pkt_bufid_wr_p1       (w_bufid_wr_pcb2nip_1),
.i_pkt_bufid_ack_p1      (w_bufid_ack_nip2pcb_1),
                         
.ov_pkt_bufid_p2         (wv_bufid_pcb2nip_2),
.o_pkt_bufid_wr_p2       (w_bufid_wr_pcb2nip_2),
.i_pkt_bufid_ack_p2      (w_bufid_ack_nip2pcb_2),

.ov_pkt_bufid_p3         (wv_bufid_pcb2nip_3),
.o_pkt_bufid_wr_p3       (w_bufid_wr_pcb2nip_3),
.i_pkt_bufid_ack_p3      (w_bufid_ack_nip2pcb_3),

.ov_pkt_bufid_p4         (wv_bufid_pcb2nip_4),
.o_pkt_bufid_wr_p4       (w_bufid_wr_pcb2nip_4),
.i_pkt_bufid_ack_p4      (w_bufid_ack_nip2pcb_4),

.i_pkt_bufid_wr_flt      (w_pkt_bufid_wr_flt2pcb),
.iv_pkt_bufid_flt        (wv_pkt_bufid_flt2pcb),
.iv_pkt_bufid_cnt_flt    (wv_pkt_bufid_cnt_flt2pcb),

.iv_pkt_bufid_p0         (wv_pkt_bufid_nop2pcb_0),
.i_pkt_bufid_wr_p0       (w_pkt_bufid_wr_nop2pcb_0),
.o_pkt_bufid_ack_p0      (w_pkt_bufid_ack_pcb2nop_0),

.iv_pkt_bufid_p1         (wv_pkt_bufid_nop2pcb_1),
.i_pkt_bufid_wr_p1       (w_pkt_bufid_wr_nop2pcb_1),
.o_pkt_bufid_ack_p1      (w_pkt_bufid_ack_pcb2nop_1),

.iv_pkt_bufid_p2         (wv_pkt_bufid_nop2pcb_2),
.i_pkt_bufid_wr_p2       (w_pkt_bufid_wr_nop2pcb_2),
.o_pkt_bufid_ack_p2      (w_pkt_bufid_ack_pcb2nop_2),

.iv_pkt_bufid_p3         (wv_pkt_bufid_nop2pcb_3),
.i_pkt_bufid_wr_p3       (w_pkt_bufid_wr_nop2pcb_3),
.o_pkt_bufid_ack_p3      (w_pkt_bufid_ack_pcb2nop_3),

.iv_pkt_bufid_p4         (wv_pkt_bufid_nop2pcb_4),
.i_pkt_bufid_wr_p4       (w_pkt_bufid_wr_nop2pcb_4),
.o_pkt_bufid_ack_p4      (w_pkt_bufid_ack_pcb2nop_4),

.ov_pkt_write_state      (),             
.ov_pcb_pkt_read_state   (),          
.ov_address_write_state  (),         
.ov_address_read_state   (),          
.ov_free_buf_fifo_rdusedw(wv_free_buf_fifo_rdusedw_pcb2cpa)        
);


network_output_process network_output_process_inst(
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                        
.i_gmii_clk_p0          (i_gmii_rxclk_p0),
.i_gmii_clk_p1          (i_gmii_rxclk_p1),
.i_gmii_clk_p2          (i_gmii_rxclk_p2),
.i_gmii_clk_p3          (i_gmii_rxclk_p3),
.i_gmii_clk_p4          (i_gmii_rxclk_p4),

.i_gmii_rst_n_p0        (i_gmii_rst_n_p0),
.i_gmii_rst_n_p1        (i_gmii_rst_n_p1),
.i_gmii_rst_n_p2        (i_gmii_rst_n_p2),
.i_gmii_rst_n_p3        (i_gmii_rst_n_p3),
.i_gmii_rst_n_p4        (i_gmii_rst_n_p4),

.i_qbv_or_qch           (w_qbv_or_qch_cpa2nop),
.iv_time_slot           (iv_time_slot),
.i_time_slot_switch     (i_time_slot_switch),

.i_timer_rst_p0         (i_timer_rst_gts2others),//glb module
.i_timer_rst_p1         (i_timer_rst_gts2others),
.i_timer_rst_p2         (i_timer_rst_gts2others),
.i_timer_rst_p3         (i_timer_rst_gts2others),
.i_timer_rst_p4         (i_timer_rst_gts2others),

//port 0
.iv_pkt_bufid_p0        (wv_pkt_bufid_flt2nop_0),
.iv_pkt_type_p0         (wv_pkt_type_flt2nop_0),
.i_pkt_bufid_wr_p0      (w_pkt_bufid_wr_flt2nop_0),

.ov_pkt_bufid_p0        (wv_pkt_bufid_nop2pcb_0),
.o_pkt_bufid_wr_p0      (w_pkt_bufid_wr_nop2pcb_0),
.i_pkt_bufid_ack_p0     (w_pkt_bufid_ack_pcb2nop_0),

.ov_pkt_raddr_p0        (wv_pkt_raddr_nop2pcb_0),
.o_pkt_rd_p0            (w_pkt_rd_nop2pcb_0),
.i_pkt_raddr_ack_p0     (w_pkt_raddr_ack_pcb2nop_0),

.iv_pkt_data_p0         (wv_pkt_data_pcb2nop_0),
.i_pkt_data_wr_p0       (w_pkt_data_wr_pcb2nop_0),

.ov_gmii_txd_p0         (ov_gmii_txd_p0),
.o_gmii_tx_en_p0        (o_gmii_tx_en_p0),
.o_gmii_tx_er_p0        (o_gmii_tx_er_p0),
.o_gmii_tx_clk_p0       (o_gmii_tx_clk_p0),

.o_port0_outpkt_pulse   (w_port0_outpkt_pulse_nop2cpa),

.iv_nop0_ram_addr       (wv_qgc0_ram_addr),   
.iv_nop0_ram_wdata      (wv_qgc0_ram_wdata),  
.i_nop0_ram_wr          (w_qgc0_ram_wr),      
.ov_nop0_ram_rdata      (wv_qgc0_ram_rdata),  
.i_nop0_ram_rd          (w_qgc0_ram_rd),      

.ov_osc_state_p0        (),
.ov_prc_state_p0        (),
.ov_opc_state_p0        (),

//port 1
.iv_pkt_bufid_p1        (wv_pkt_bufid_flt2nop_1),
.iv_pkt_type_p1         (wv_pkt_type_flt2nop_1),
.i_pkt_bufid_wr_p1      (w_pkt_bufid_wr_flt2nop_1),

.ov_pkt_bufid_p1        (wv_pkt_bufid_nop2pcb_1),
.o_pkt_bufid_wr_p1      (w_pkt_bufid_wr_nop2pcb_1),
.i_pkt_bufid_ack_p1     (w_pkt_bufid_ack_pcb2nop_1),

.ov_pkt_raddr_p1        (wv_pkt_raddr_nop2pcb_1),
.o_pkt_rd_p1            (w_pkt_rd_nop2pcb_1),
.i_pkt_raddr_ack_p1     (w_pkt_raddr_ack_pcb2nop_1),

.iv_pkt_data_p1         (wv_pkt_data_pcb2nop_1),
.i_pkt_data_wr_p1       (w_pkt_data_wr_pcb2nop_1),

.ov_gmii_txd_p1         (ov_gmii_txd_p1),
.o_gmii_tx_en_p1        (o_gmii_tx_en_p1),
.o_gmii_tx_er_p1        (o_gmii_tx_er_p1),
.o_gmii_tx_clk_p1       (o_gmii_tx_clk_p1),

.o_port1_outpkt_pulse   (w_port1_outpkt_pulse_nop2cpa),

.iv_nop1_ram_addr       (wv_qgc1_ram_addr),         
.iv_nop1_ram_wdata      (wv_qgc1_ram_wdata),        
.i_nop1_ram_wr          (w_qgc1_ram_wr),            
.ov_nop1_ram_rdata      (wv_qgc1_ram_rdata),        
.i_nop1_ram_rd          (w_qgc1_ram_rd),            

.ov_osc_state_p1        (),
.ov_prc_state_p1        (),
.ov_opc_state_p1        (),

//port 2
.iv_pkt_bufid_p2        (wv_pkt_bufid_flt2nop_2),
.iv_pkt_type_p2         (wv_pkt_type_flt2nop_2),
.i_pkt_bufid_wr_p2      (w_pkt_bufid_wr_flt2nop_2),

.ov_pkt_bufid_p2        (wv_pkt_bufid_nop2pcb_2),
.o_pkt_bufid_wr_p2      (w_pkt_bufid_wr_nop2pcb_2),
.i_pkt_bufid_ack_p2     (w_pkt_bufid_ack_pcb2nop_2),

.ov_pkt_raddr_p2        (wv_pkt_raddr_nop2pcb_2),
.o_pkt_rd_p2            (w_pkt_rd_nop2pcb_2),
.i_pkt_raddr_ack_p2     (w_pkt_raddr_ack_pcb2nop_2),

.iv_pkt_data_p2         (wv_pkt_data_pcb2nop_2),
.i_pkt_data_wr_p2       (w_pkt_data_wr_pcb2nop_2),

.ov_gmii_txd_p2         (ov_gmii_txd_p2),
.o_gmii_tx_en_p2        (o_gmii_tx_en_p2),
.o_gmii_tx_er_p2        (o_gmii_tx_er_p2),
.o_gmii_tx_clk_p2       (o_gmii_tx_clk_p2),

.o_port2_outpkt_pulse   (w_port2_outpkt_pulse_nop2cpa),

.ov_osc_state_p2        (),
.ov_prc_state_p2        (),
.ov_opc_state_p2        (),

.iv_nop2_ram_addr       (wv_qgc2_ram_addr),       
.iv_nop2_ram_wdata      (wv_qgc2_ram_wdata),      
.i_nop2_ram_wr          (w_qgc2_ram_wr),          
.ov_nop2_ram_rdata      (wv_qgc2_ram_rdata),      
.i_nop2_ram_rd          (w_qgc2_ram_rd),          
//port 3
.iv_pkt_bufid_p3        (wv_pkt_bufid_flt2nop_3),
.iv_pkt_type_p3         (wv_pkt_type_flt2nop_3),
.i_pkt_bufid_wr_p3      (w_pkt_bufid_wr_flt2nop_3),
                        
.ov_pkt_bufid_p3        (wv_pkt_bufid_nop2pcb_3),
.o_pkt_bufid_wr_p3      (w_pkt_bufid_wr_nop2pcb_3),
.i_pkt_bufid_ack_p3     (w_pkt_bufid_ack_pcb2nop_3),
                        
.ov_pkt_raddr_p3        (wv_pkt_raddr_nop2pcb_3),
.o_pkt_rd_p3            (w_pkt_rd_nop2pcb_3),
.i_pkt_raddr_ack_p3     (w_pkt_raddr_ack_pcb2nop_3),
                        
.iv_pkt_data_p3         (wv_pkt_data_pcb2nop_3),
.i_pkt_data_wr_p3       (w_pkt_data_wr_pcb2nop_3),
                        
.o_port3_outpkt_pulse   (w_port3_outpkt_pulse_nop2cpa),
                        
.ov_gmii_txd_p3         (ov_gmii_txd_p3),
.o_gmii_tx_en_p3        (o_gmii_tx_en_p3),
.o_gmii_tx_er_p3        (o_gmii_tx_er_p3),
.o_gmii_tx_clk_p3       (o_gmii_tx_clk_p3),
                        
.iv_nop3_ram_addr       (wv_qgc3_ram_addr),        
.iv_nop3_ram_wdata      (wv_qgc3_ram_wdata),       
.i_nop3_ram_wr          (w_qgc3_ram_wr),           
.ov_nop3_ram_rdata      (wv_qgc3_ram_rdata),       
.i_nop3_ram_rd          (w_qgc3_ram_rd),           
                        
.ov_osc_state_p3        (),
.ov_prc_state_p3        (),
.ov_opc_state_p3        (),
//port 4
.iv_pkt_bufid_p4        (wv_pkt_bufid_flt2nop_4),
.iv_pkt_type_p4         (wv_pkt_type_flt2nop_4),
.i_pkt_bufid_wr_p4      (w_pkt_bufid_wr_flt2nop_4),
                        
.ov_pkt_bufid_p4        (wv_pkt_bufid_nop2pcb_4),
.o_pkt_bufid_wr_p4      (w_pkt_bufid_wr_nop2pcb_4),
.i_pkt_bufid_ack_p4     (w_pkt_bufid_ack_pcb2nop_4),
                        
.ov_pkt_raddr_p4        (wv_pkt_raddr_nop2pcb_4),
.o_pkt_rd_p4            (w_pkt_rd_nop2pcb_4),
.i_pkt_raddr_ack_p4     (w_pkt_raddr_ack_pcb2nop_4),
                        
.iv_pkt_data_p4         (wv_pkt_data_pcb2nop_4),
.i_pkt_data_wr_p4       (w_pkt_data_wr_pcb2nop_4),
                        
.ov_gmii_txd_p4         (ov_gmii_txd_p4),
.o_gmii_tx_en_p4        (o_gmii_tx_en_p4),
.o_gmii_tx_er_p4        (o_gmii_tx_er_p4),
.o_gmii_tx_clk_p4       (o_gmii_tx_clk_p4),
                        
.o_port4_outpkt_pulse   (w_port4_outpkt_pulse_nop2cpa),
                        
.iv_nop4_ram_addr       (wv_qgc4_ram_addr),   
.iv_nop4_ram_wdata      (wv_qgc4_ram_wdata),  
.i_nop4_ram_wr          (w_qgc4_ram_wr),      
.ov_nop4_ram_rdata      (wv_qgc4_ram_rdata),  
.i_nop4_ram_rd          (w_qgc4_ram_rd),      
                        
.ov_osc_state_p4        (),
.ov_prc_state_p4        (),
.ov_opc_state_p4        (),


.o_fifo_overflow_pulse_p0(o_fifo_overflow_pulse_p0_tx),    
.o_fifo_overflow_pulse_p1(o_fifo_overflow_pulse_p1_tx),    
.o_fifo_overflow_pulse_p2(o_fifo_overflow_pulse_p2_tx),    
.o_fifo_overflow_pulse_p3(o_fifo_overflow_pulse_p3_tx),    
.o_fifo_overflow_pulse_p4(o_fifo_overflow_pulse_p4_tx)
);

command_parser command_parser_inst(
 .i_clk		(i_clk),
 .i_rst_n	(i_rst_n),
 
 .iv_wr_command    (iv_wr_command    ), 
 .i_wr_command_wr  (i_wr_command_wr  ),
 .iv_rd_command    (iv_rd_command    ),
 .i_rd_command_wr  (i_rd_command_wr  ),
 .ov_rd_command_ack(ov_rd_command_ack),

 //nip 
 .ov_be_threshold_value			 (wv_be_regulation_value),
 .ov_rc_threshold_value			 (wv_rc_regulation_value),
 .ov_map_req_threshold_value	 (wv_unmap_regulation_value),

 .ov_port_type					 (port_type_tsnchip2adp),
 .ov_cfg_finish					 (wv_cfg_finish_cpa2others),
	                             
 //flt
 .ov_flt_ram_addr                (wv_flt_ram_addr),
 .ov_flt_ram_wdata               (wv_flt_ram_wdata),
 .o_flt_ram_wr                   (w_flt_ram_wr),
 .iv_flt_ram_rdata               (wv_flt_ram_rdata),
 .o_flt_ram_rd                   (w_flt_ram_rd),
 //nop
 .o_qbv_or_qch                   (w_qbv_or_qch_cpa2nop),
//.ov_time_slot                   (wv_time_slot_cpa2nop),
 
 .i_port0_outpkt_pulse           (w_port0_outpkt_pulse_nop2cpa),
 .ov_nop0_ram_addr               (wv_qgc0_ram_addr),
 .ov_nop0_ram_wdata              (wv_qgc0_ram_wdata),
 .o_nop0_ram_wr                  (w_qgc0_ram_wr),
 .iv_nop0_ram_rdata              (wv_qgc0_ram_rdata),
 .o_nop0_ram_rd                  (w_qgc0_ram_rd),

 .i_port1_outpkt_pulse           (w_port1_outpkt_pulse_nop2cpa),
 .ov_nop1_ram_addr               (wv_qgc1_ram_addr),
 .ov_nop1_ram_wdata              (wv_qgc1_ram_wdata),
 .o_nop1_ram_wr                  (w_qgc1_ram_wr),
 .iv_nop1_ram_rdata              (wv_qgc1_ram_rdata),
 .o_nop1_ram_rd                  (w_qgc1_ram_rd),

 .i_port2_outpkt_pulse           (w_port2_outpkt_pulse_nop2cpa),
 .ov_nop2_ram_addr               (wv_qgc2_ram_addr),
 .ov_nop2_ram_wdata              (wv_qgc2_ram_wdata),
 .o_nop2_ram_wr                  (w_qgc2_ram_wr),
 .iv_nop2_ram_rdata              (wv_qgc2_ram_rdata),
 .o_nop2_ram_rd                  (w_qgc2_ram_rd),

 .i_port3_outpkt_pulse           (w_port3_outpkt_pulse_nop2cpa),
 .ov_nop3_ram_addr               (wv_qgc3_ram_addr),
 .ov_nop3_ram_wdata              (wv_qgc3_ram_wdata),
 .o_nop3_ram_wr                  (w_qgc3_ram_wr),
 .iv_nop3_ram_rdata              (wv_qgc3_ram_rdata),
 .o_nop3_ram_rd                  (w_qgc3_ram_rd),
 
 .i_port4_outpkt_pulse           (w_port4_outpkt_pulse_nop2cpa),
 .ov_nop4_ram_addr               (wv_qgc4_ram_addr),
 .ov_nop4_ram_wdata              (wv_qgc4_ram_wdata),
 .o_nop4_ram_wr                  (w_qgc4_ram_wr),
 .iv_nop4_ram_rdata              (wv_qgc4_ram_rdata),
 .o_nop4_ram_rd                  (w_qgc4_ram_rd)


);
endmodule


