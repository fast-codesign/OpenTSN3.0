// Copyright (C) 1953-2020 NUDT
// Verilog module name - tsn_chip 
// Version: tsn_chip_V1.0
// Created:
//         by - bo.chen 
//         at - 07.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//		  top of tsn_chip of FPGA
//				 
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module time_sensitive_end
(
        i_clk,
        i_rst_n,
        
        i_gmii_rst_n_p0,     
        i_gmii_rst_n_p1,          
        i_gmii_rst_n_host, 
        
        ov_gmii_txd_p0,
        o_gmii_tx_en_p0,
        o_gmii_tx_er_p0,
        o_gmii_tx_clk_p0,
        
        ov_gmii_txd_p1,
        o_gmii_tx_en_p1,
        o_gmii_tx_er_p1,
        o_gmii_tx_clk_p1,

        i_gmii_rxclk_p0,
        i_gmii_dv_p0,
        iv_gmii_rxd_p0,
        i_gmii_er_p0,
        
        i_gmii_rxclk_p1,
        i_gmii_dv_p1,
        iv_gmii_rxd_p1,
        i_gmii_er_p1,
        
        //hrp
        i_gmii_rxclk_host,
        i_gmii_dv_host,
        iv_gmii_rxd_host,
        i_gmii_er_host,
        
        //htp
        ov_gmii_txd_host,
        o_gmii_tx_en_host,
        o_gmii_tx_er_host,
        o_gmii_tx_clk_host,

        iv_wr_command,
	    i_wr_command_wr,        

        iv_rd_command,
        i_rd_command_wr,        
        ov_rd_command_ack, 
        
        i_timer_rst,
        o_init_led,
        o_fifo_overflow_pulse_host_rx, 
        o_fifo_underflow_pulse_host_rx,
        o_fifo_underflow_pulse_p0_rx,
        o_fifo_overflow_pulse_p0_rx, 
        o_fifo_underflow_pulse_p1_rx,
        o_fifo_overflow_pulse_p1_rx, 
        
        o_fifo_overflow_pulse_host_tx,
        o_fifo_overflow_pulse_p0_tx,
        o_fifo_overflow_pulse_p1_tx
   
);

//I/O
input                  i_clk;                   //125Mhz
input                  i_rst_n;

input                  i_gmii_rst_n_p0;  
input                  i_gmii_rst_n_p1;    
input                  i_gmii_rst_n_host;
// network output
output     [7:0]       ov_gmii_txd_p0;
output                 o_gmii_tx_en_p0;
output                 o_gmii_tx_er_p0;
output                 o_gmii_tx_clk_p0;

output     [7:0]       ov_gmii_txd_p1;
output                 o_gmii_tx_en_p1;
output                 o_gmii_tx_er_p1;
output                 o_gmii_tx_clk_p1;    
//network input
input                   i_gmii_rxclk_p0;
input                   i_gmii_dv_p0;
input      [7:0]        iv_gmii_rxd_p0;
input                   i_gmii_er_p0;

input                   i_gmii_rxclk_p1;
input                   i_gmii_dv_p1;
input      [7:0]        iv_gmii_rxd_p1;
input                   i_gmii_er_p1;
// host output
output     [7:0]       ov_gmii_txd_host;
output                 o_gmii_tx_en_host;
output                 o_gmii_tx_er_host;
output                 o_gmii_tx_clk_host;
//host input
input                   i_gmii_rxclk_host;
input                   i_gmii_dv_host;
input      [7:0]        iv_gmii_rxd_host;
input                   i_gmii_er_host;
//command
input	   [203:0]	    iv_wr_command;
input	         	    i_wr_command_wr;
//output     [203:0]      ov_command;
//output                  o_command_wr;

input      [203:0]	    iv_rd_command;
input    	            i_rd_command_wr;
output     [203:0]	    ov_rd_command_ack;

input                   i_timer_rst;
output    reg           o_init_led;

output                  o_fifo_overflow_pulse_host_rx;
output                  o_fifo_underflow_pulse_host_rx;
output                  o_fifo_underflow_pulse_p0_rx;
output                  o_fifo_overflow_pulse_p0_rx; 
output                  o_fifo_underflow_pulse_p1_rx;
output                  o_fifo_overflow_pulse_p1_rx; 

output                  o_fifo_overflow_pulse_host_tx;
output                  o_fifo_overflow_pulse_p0_tx;
output                  o_fifo_overflow_pulse_p1_tx;
//*******************************
//              hrp
//*******************************
wire       [9:0]        wv_time_slot_hrp2others;
wire                    w_time_slot_switch_hrp2others;

wire       [8:0]        wv_bufid_pcb2hrp;
wire                    w_bufid_wr_pcb2hrp;
wire                    w_bufid_ack_hrp2pcb;

wire       [133:0]      wv_pkt_data_hrp2pcb;
wire                    w_pkt_data_wr_hrp2pcb;
wire       [15:0]       wv_pkt_addr_hrp2pcb;//11->15
wire                    w_pkt_ack_pcb2hrp;

wire       [45:0]       wv_ts_descriptor_hrp2flt;
wire                    w_ts_descriptor_wr_hrp2flt;
wire                    w_ts_descriptor_ack_flt2hrp;

wire       [45:0]       wv_nts_descriptor_hrp2flt;
wire                    w_nts_descriptor_wr_hrp2flt;
wire                    w_nts_descriptor_ack_flt2hrp;
//tsntag & bufid output for not ip frame
wire       [47:0]       wv_nip_tsntag_hrp2hcp;
wire       [8:0]        wv_nip_bufid_hrp2hcp;
wire                    w_nip_descriptor_wr_hrp2hcp;
wire                    w_nip_descriptor_ack_hcp2hrp;
//tsntag & bufid output for ip frame 
wire       [47:0]       wv_ip_tsntag_hrp2scp;
wire       [8:0]        wv_ip_bufid_hrp2scp;
wire                    w_ip_descriptor_wr_hrp2scp;
wire                    w_ip_descriptor_ack_scp2hrp;
//*******************************
//              nip
//*******************************
//port0
wire       [8:0]        wv_bufid_pcb2nip_0;
wire                    w_bufid_wr_pcb2nip_0;
wire                    w_bufid_ack_hrp2nip_0;

wire                    w_descriptor_wr_p0tohost; 
wire                    w_descriptor_wr_p0tonetwork;
wire       [56:0]       wv_descriptor_p0;
wire                    w_descriptor_ack_hosttop0;
wire                    w_descriptor_ack_networktop0;

wire                    w_descriptor_wr_p1tohost; 
wire                    w_descriptor_wr_p1tohcp;
wire       [56:0]       wv_descriptor_p1;
wire                    w_descriptor_ack_hosttop1;   
wire                    w_descriptor_ack_hcptop1;

wire       [133:0]      wv_pkt_data_pcb2nip_0;
wire                    w_pkt_data_wr_pcb2nip_0;
wire       [15:0]       wv_pkt_addr_pcb2nip_0;
wire                    w_pkt_ack_pcb2nip_0;

//port1
wire       [8:0]        wv_bufid_pcb2nip_1;
wire                    w_bufid_wr_pcb2nip_1;
wire                    w_bufid_ack_hrp2nip_1;

wire       [45:0]       wv_descriptor_pcb2nip_1;
wire                    w_descriptor_wr_pcb2nip_1;
wire                    w_descriptor_ack_pcb2nip_1;

wire       [133:0]      wv_pkt_data_pcb2nip_1;
wire                    w_pkt_data_wr_pcb2nip_1;
wire       [15:0]       wv_pkt_addr_pcb2nip_1;
wire                    w_pkt_ack_pcb2nip_1;
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

//host port
wire       [8:0]        wv_pkt_bufid_flt2ntp;
wire       [2:0]        wv_pkt_type_flt2ntp;
wire       [4:0]        wv_submit_addr_flt2ntp;
wire       [3:0]        wv_inport_flt2ntp;
wire                    w_pkt_bufid_wr_flt2ntp;
//*******************************
//            htp
//*******************************
wire       [8:0]        wv_pkt_bufid_htp2pcb;    
wire                    w_pkt_bufid_wr_htp2pcb;  
wire                    w_pkt_bufid_ack_pcb2htp; 

wire       [15:0]       wv_pkt_raddr_htp2pcb;    //11->15  
wire                    w_pkt_rd_htp2pcb;       
wire                    w_pkt_raddr_ack_pcb2htp;

wire       [133:0]      wv_pkt_data_pcb2htp;  
wire                    w_pkt_data_wr_pcb2htp;
//*******************************
//             nop
//*******************************
//port0
wire       [8:0]        wv_pkt_bufid_nop2pcb_0;    
wire                    w_pkt_bufid_wr_nop2pcb_0;  
wire                    w_pkt_bufid_ack_pcb2nop_0; 

wire       [15:0]       wv_pkt_raddr_nop2pcb_0; //11->15  
wire                    w_pkt_rd_nop2pcb_0;       
wire                    w_pkt_raddr_ack_pcb2nop_0;

wire       [133:0]      wv_pkt_data_pcb2nop_0;  
wire                    w_pkt_data_wr_pcb2nop_0;

//port1
wire       [8:0]        wv_pkt_bufid_nop2pcb_1;    
wire                    w_pkt_bufid_wr_nop2pcb_1;  
wire                    w_pkt_bufid_ack_pcb2nop_1; 

wire       [15:0]       wv_pkt_raddr_nop2pcb_1;    //11->15  
wire                    w_pkt_rd_nop2pcb_1;       
wire                    w_pkt_raddr_ack_pcb2nop_1;

wire       [133:0]      wv_pkt_data_pcb2nop_1;  
wire                    w_pkt_data_wr_pcb2nop_1;
//*******************************
//             csm
//*******************************
wire       [48:0]       wv_time_offset_csm2gts;   
wire                    w_time_offset_wr_csm2gts; 
wire       [23:0]       wv_offset_period_csm2gts; 
wire       [1:0]        wv_cfg_finish_csm2others;      
wire       [10:0]       wv_slot_len_csm2others;      
wire       [10:0]       wv_inject_slot_period_us_csm2hrp;  
wire       [10:0]       wv_submit_slot_period_us_csm2htp;    
wire                    w_qbv_or_qch_csm2nop;     
wire       [11:0]       wv_report_period_ms_csm2gts; 

wire                    w_host_inpkt_pulse_hrp2csm;        
wire                    w_host_discard_pkt_pulse_hrp2csm;  
wire                    w_port0_inpkt_pulse_nip2csm;       
wire                    w_port0_discard_pkt_pulse_nip2csm; 
wire                    w_port1_inpkt_pulse_nip2csm;       
wire                    w_port1_discard_pkt_pulse_nip2csm; 
wire                    w_port2_inpkt_pulse_nip2csm;       
wire                    w_port2_discard_pkt_pulse_nip2csm; 
wire                    w_port3_inpkt_pulse_nip2csm;       
wire                    w_port3_discard_pkt_pulse_nip2csm; 
wire                    w_port4_inpkt_pulse_nip2csm;       
wire                    w_port4_discard_pkt_pulse_nip2csm; 
wire                    w_port5_inpkt_pulse_nip2csm;       
wire                    w_port5_discard_pkt_pulse_nip2csm; 
wire                    w_port6_inpkt_pulse_nip2csm;       
wire                    w_port6_discard_pkt_pulse_nip2csm; 
wire                    w_port7_inpkt_pulse_nip2csm;       
wire                    w_port7_discard_pkt_pulse_nip2csm; 
                        
wire                    w_host_outpkt_pulse_htp2csm;       
wire                    w_host_in_queue_discard_pulse_htp2csm;
wire                    w_port0_outpkt_pulse_nop2csm;      
wire                    w_port1_outpkt_pulse_nop2csm;      
wire                    w_port2_outpkt_pulse_nop2csm;      
wire                    w_port3_outpkt_pulse_nop2csm;     
wire                    w_port4_outpkt_pulse_nop2csm;      
wire                    w_port5_outpkt_pulse_nop2csm;      
wire                    w_port6_outpkt_pulse_nop2csm;      
wire                    w_port7_outpkt_pulse_nop2csm;      

wire       [9:0]        wv_tss_ram_addr;   
wire       [15:0]       wv_tss_ram_wdata;  
wire                    w_tss_ram_wr;      
wire       [15:0]       wv_tss_ram_rdata;  
wire                    w_tss_ram_rd;      
                  
wire       [9:0]        wv_tis_ram_addr;   
wire       [15:0]       wv_tis_ram_wdata;  
wire                    w_tis_ram_wr;      
wire       [15:0]       wv_tis_ram_rdata;  
wire                    w_tis_ram_rd;      
//map table
wire       [4:0]        wv_fmt_ram_addr_cpa2hrp;
wire                    w_fmt_ram_wr_cpa2hrp;
wire       [151:0]      wv_fmt_ram_wdata_cpa2hrp;
wire       [151:0]      wv_fmt_ram_rdata_hrp2cpa;
wire                    w_fmt_ram_rd_cpa2hrp;
//ram write - porta 
wire       [61:0]	    wv_regroup_ram_wdata;
wire       	            w_regroup_ram_wr;
wire       [7:0]	    wv_regroup_ram_addr;
wire       [61:0]       wv_regroup_ram_rdata;
wire                    w_regroup_ram_rd;

wire                    w_ts_inj_underflow_error_pulse_hrp2csm;
wire                    w_ts_inj_overflow_error_pulse_hrp2csm; 
wire                    w_ts_sub_underflow_error_pulse_htp2csm;
wire                    w_ts_sub_overflow_error_pulse_htp2csm; 
   
wire       [1:0]        wv_prp_state_hrp2csm;    
wire       [2:0]        wv_pdi_state_hrp2csm;     
wire       [1:0]        wv_tom_state_hrp2csm;          
wire       [2:0]        wv_pkt_state_hrp2csm;          
wire       [2:0]        wv_transmission_state_hrp2csm; 
wire       [2:0]        wv_descriptor_state_hrp2csm;   
wire       [2:0]        wv_tim_state_hrp2csm;          
wire       [2:0]        wv_ism_state_hrp2csm;    
wire       [1:0]        wv_hos_state_htp2csm;          
wire       [3:0]        wv_hoi_state_htp2csm;          
wire       [2:0]        wv_pkt_read_state_htp2csm;  
wire       [1:0]        wv_bufid_state_htp2csm;   
wire       [2:0]        wv_tsm_state_htp2csm;          
wire       [2:0]        wv_ssm_state_htp2csm;   
            
wire       [3:0]        wv_tdm_state_flt2csm;                 

//port0
wire       [1:0]        wv_osc_state_p0_nop2csm;                 
wire       [1:0]        wv_prc_state_p0_nop2csm;                 
wire       [2:0]        wv_opc_state_p0_nop2csm; 
     
wire       [1:0]        wv_gmii_read_state_p0_nip2csm;           
wire                    w_gmii_fifo_full_p0_nip2csm;             
wire                    w_gmii_fifo_empty_p0_nip2csm;            
wire       [3:0]        wv_descriptor_extract_state_p0_nip2csm;  
wire       [1:0]        wv_descriptor_send_state_p0_nip2csm;     
wire       [1:0]        wv_data_splice_state_p0_nip2csm;         
wire       [1:0]        wv_input_buf_interface_state_p0_nip2csm; 

//port1
wire       [1:0]        wv_osc_state_p1_nop2csm;                 
wire       [1:0]        wv_prc_state_p1_nop2csm;                 
wire       [2:0]        wv_opc_state_p1_nop2csm; 
      
wire       [1:0]        wv_gmii_read_state_p1_nip2csm;           
wire                    w_gmii_fifo_full_p1_nip2csm;             
wire                    w_gmii_fifo_empty_p1_nip2csm;            
wire       [3:0]        wv_descriptor_extract_state_p1_nip2csm;  
wire       [1:0]        wv_descriptor_send_state_p1_nip2csm;     
wire       [1:0]        wv_data_splice_state_p1_nip2csm;         
wire       [1:0]        wv_input_buf_interface_state_p1_nip2csm; 

wire       [3:0]        wv_pkt_write_state_pcb2csm;      
wire       [3:0]        wv_pcb_pkt_read_state_pcb2csm;   
wire       [3:0]        wv_address_write_state_pcb2csm;  
wire       [3:0]        wv_address_read_state_pcb2csm;   

wire       [8:0]        wv_free_bufid_fifo_rdusedw;
wire       [8:0]        wv_rc_regulation_value;
wire       [8:0]        wv_be_regulation_value;
wire       [8:0]        wv_map_req_regulation_value;
wire       [7:0]        wv_port_type;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_init_led <= 1'h0;
    end
    else begin
        if(wv_cfg_finish_csm2others == 2'd1)begin
            o_init_led <= 1'h1;
        end
        else if(wv_cfg_finish_csm2others > 2'd1)begin
            o_init_led <= 1'h0;
        end
        else begin
            o_init_led <= 1'h0;
        end
    end
end 
//adp2tsnchip 
wire					w_gmii_dv_p0_adp2tsnchip;
wire		[7:0]		wv_gmii_rxd_p0_adp2tsnchip;
wire					w_gmii_er_p0_adp2tsnchip;

wire					w_gmii_dv_p1_adp2tsnchip;
wire		[7:0]		wv_gmii_rxd_p1_adp2tsnchip;
wire					w_gmii_er_p1_adp2tsnchip;

wire	  				w_gmii_dv_host_adp2tsnchip;
wire		[7:0]	 	wv_gmii_rxd_host_adp2tsnchip;
wire					w_gmii_er_host_adp2tsnchip;

//tsnchip2adp
wire      [7:0] 	   wv_gmii_txd_p0_tsnchip2adp;
wire      		 	   w_gmii_tx_en_p0_tsnchip2adp;
wire      		 	   w_gmii_tx_er_p0_tsnchip2adp;

wire      [7:0] 	   wv_gmii_txd_p1_tsnchip2adp;
wire      		 	   w_gmii_tx_en_p1_tsnchip2adp;
wire      		 	   w_gmii_tx_er_p1_tsnchip2adp;

wire      [7:0] 	   wv_gmii_txd_host_tsnchip2adp;
wire      		 	   w_gmii_tx_en_host_tsnchip2adp;
wire      		 	   w_gmii_tx_er_host_tsnchip2adp;                       
gmii_adapter gmii_adapter_p0(
.gmii_rxclk(i_gmii_rxclk_p0),
.gmii_txclk(o_gmii_tx_clk_p0),

.rst_n(i_gmii_rst_n_p0),

.port_type(1'b0),

.gmii_rx_dv(i_gmii_dv_p0),
.gmii_rx_er(i_gmii_er_p0),
.gmii_rxd  (iv_gmii_rxd_p0),

.gmii_rx_dv_adp2tsnchip(w_gmii_dv_p0_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(w_gmii_er_p0_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (wv_gmii_rxd_p0_adp2tsnchip),

.gmii_tx_en(o_gmii_tx_en_p0),
.gmii_tx_er(o_gmii_tx_er_p0),
.gmii_txd  (ov_gmii_txd_p0),

.gmii_tx_en_tsnchip2adp(w_gmii_tx_en_p0_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(w_gmii_tx_er_p0_tsnchip2adp),
.gmii_txd_tsnchip2adp  (wv_gmii_txd_p0_tsnchip2adp)

/* .pin_rxd(pin_rxd_p0),
.pin_txd(pin_txd_p0) */
);

gmii_adapter gmii_adapter_p1(
.gmii_rxclk(i_gmii_rxclk_p1),
.gmii_txclk(o_gmii_tx_clk_p1),

.rst_n(i_gmii_rst_n_p1),

.port_type(1'b0),

.gmii_rx_dv(i_gmii_dv_p1),
.gmii_rx_er(i_gmii_er_p1),
.gmii_rxd  (iv_gmii_rxd_p1),

.gmii_rx_dv_adp2tsnchip(w_gmii_dv_p1_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(w_gmii_er_p1_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (wv_gmii_rxd_p1_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p1),
.gmii_tx_er(o_gmii_tx_er_p1),
.gmii_txd  (ov_gmii_txd_p1),

.gmii_tx_en_tsnchip2adp(w_gmii_tx_en_p1_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(w_gmii_tx_er_p1_tsnchip2adp),
.gmii_txd_tsnchip2adp  (wv_gmii_txd_p1_tsnchip2adp)
/* .pin_rxd(pin_rxd_p1),
.pin_txd(pin_txd_p1) */
);

gmii_adapter gmii_adapter_host(
.gmii_rxclk(i_gmii_rxclk_host),
.gmii_txclk(o_gmii_tx_clk_host),

.rst_n(i_gmii_rst_n_host),

.port_type(1'b1),

.gmii_rx_dv(i_gmii_dv_host),
.gmii_rx_er(i_gmii_er_host),
.gmii_rxd  (iv_gmii_rxd_host),

.gmii_rx_dv_adp2tsnchip(w_gmii_dv_host_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(w_gmii_er_host_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (wv_gmii_rxd_host_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_host),
.gmii_tx_er(o_gmii_tx_er_host),
.gmii_txd  (ov_gmii_txd_host),

.gmii_tx_en_tsnchip2adp(w_gmii_tx_en_host_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(w_gmii_tx_er_host_tsnchip2adp),
.gmii_txd_tsnchip2adp  (wv_gmii_txd_host_tsnchip2adp)
); 
  
host_receive_process host_receive_process_inst(
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
.i_gmii_rst_n_host              (i_gmii_rst_n_host),
            
.i_gmii_rx_clk                  (i_gmii_rxclk_host),
.i_gmii_rx_dv                   (w_gmii_dv_host_adp2tsnchip),
.iv_gmii_rxd                    (wv_gmii_rxd_host_adp2tsnchip),
.i_gmii_rx_er                   (w_gmii_er_host_adp2tsnchip),

.iv_cfg_finish                  (wv_cfg_finish_csm2others),
.i_timer_rst                    (i_timer_rst),
.iv_syned_global_time           (48'b0),          
.iv_time_slot_length            (wv_slot_len_csm2others),
.iv_time_slot_period            (wv_inject_slot_period_us_csm2hrp),         
.ov_time_slot                   (wv_time_slot_hrp2others),
.o_time_slot_switch             (w_time_slot_switch_hrp2others),
            
.iv_bufid                       (wv_bufid_pcb2hrp),
.i_bufid_wr                     (w_bufid_wr_pcb2hrp),
.o_bufid_ack                    (w_bufid_ack_hrp2pcb),
            
.ov_wdata                       (wv_pkt_data_hrp2pcb),
.o_data_wr                      (w_pkt_data_wr_hrp2pcb),
.ov_data_waddr                  (wv_pkt_addr_hrp2pcb),
.i_wdata_ack                    (w_pkt_ack_pcb2hrp),

.iv_fmt_ram_addr                (wv_fmt_ram_addr_cpa2hrp),
.i_fmt_ram_wr                   (w_fmt_ram_wr_cpa2hrp),
.iv_fmt_ram_wdata               (wv_fmt_ram_wdata_cpa2hrp),
.ov_fmt_ram_rdata               (wv_fmt_ram_rdata_hrp2cpa),
.i_fmt_ram_rd                   (w_fmt_ram_rd_cpa2hrp), 

.ov_nip_tsntag                  (wv_nip_tsntag_hrp2hcp),
.ov_nip_bufid                   (wv_nip_bufid_hrp2hcp),
.o_nip_descriptor_wr            (w_nip_descriptor_wr_hrp2hcp),
.i_nip_descriptor_ack           (w_nip_descriptor_ack_hcp2hrp),

.ov_ip_tsntag                   (wv_ip_tsntag_hrp2scp),
.ov_ip_bufid                    (wv_ip_bufid_hrp2scp),
.o_ip_descriptor_wr             (w_ip_descriptor_wr_hrp2scp),
.i_ip_descriptor_ack            (w_ip_descriptor_ack_scp2hrp),   
        
.ov_ts_descriptor               (wv_ts_descriptor_hrp2flt),
.o_ts_descriptor_wr             (w_ts_descriptor_wr_hrp2flt),
.i_ts_descriptor_ack            (w_ts_descriptor_ack_flt2hrp),
                                    
.ov_nts_descriptor              (wv_nts_descriptor_hrp2flt),
.o_nts_descriptor_wr            (w_nts_descriptor_wr_hrp2flt),
.i_nts_descriptor_ack           (w_nts_descriptor_ack_flt2hrp),
   
.o_pkt_cnt_pulse                (w_host_inpkt_pulse_hrp2csm),
.o_pkt_discard_cnt_pulse        (w_host_discard_pkt_pulse_hrp2csm),
 
.o_ts_underflow_error_pulse     (w_ts_inj_underflow_error_pulse_hrp2csm),
.o_ts_overflow_error_pulse      (w_ts_inj_overflow_error_pulse_hrp2csm),
 
.iv_free_bufid_fifo_rdusedw     (wv_free_bufid_fifo_rdusedw),
.iv_map_req_threshold_value     (wv_map_req_regulation_value),

.pdi_state                      (wv_pdi_state_hrp2csm),
.prp_state                      (wv_prp_state_hrp2csm),
.tom_state                      (wv_tom_state_hrp2csm),
.pkt_state                      (wv_pkt_state_hrp2csm),
.transmission_state             (wv_transmission_state_hrp2csm),
.descriptor_state               (wv_descriptor_state_hrp2csm),
.tim_state                      (wv_tim_state_hrp2csm),
.ism_state                      (wv_ism_state_hrp2csm),

.iv_injection_slot_table_addr   (wv_tis_ram_addr),
.iv_injection_slot_table_wdata  (wv_tis_ram_wdata),
.i_injection_slot_table_wr      (w_tis_ram_wr),
.ov_injection_slot_table_rdata  (wv_tis_ram_rdata),
.i_injection_slot_table_rd      (w_tis_ram_rd),

.o_fifo_overflow_pulse          (o_fifo_overflow_pulse_host_rx), 
.o_fifo_underflow_pulse         (o_fifo_underflow_pulse_host_rx)    
);

network_input_process_top network_input_top_inst(
.clk_sys                            (i_clk),
.reset_n                            (i_rst_n),          
.i_gmii_rst_n_p0                    (i_gmii_rst_n_p0),
.i_gmii_rst_n_p1                    (i_gmii_rst_n_p1),
                               
.clk_gmii_rx_p0                     (i_gmii_rxclk_p0),
.i_gmii_dv_p0                       (w_gmii_dv_p0_adp2tsnchip),
.iv_gmii_rxd_p0                     (wv_gmii_rxd_p0_adp2tsnchip),
.i_gmii_er_p0                       (w_gmii_er_p0_adp2tsnchip),
            
.clk_gmii_rx_p1                     (i_gmii_rxclk_p1),
.i_gmii_dv_p1                       (w_gmii_dv_p1_adp2tsnchip),
.iv_gmii_rxd_p1                     (wv_gmii_rxd_p1_adp2tsnchip),
.i_gmii_er_p1                       (w_gmii_er_p1_adp2tsnchip),
            
.timer_rst                          (i_timer_rst),
.port_type                          (wv_port_type),
.cfg_finish                         (wv_cfg_finish_csm2others),

.iv_pkt_bufid_p0                    (wv_bufid_pcb2nip_0),            
.i_pkt_bufid_wr_p0                  (w_bufid_wr_pcb2nip_0),
.o_pkt_bufid_ack_p0                 (w_bufid_ack_hrp2nip_0),

.iv_pkt_bufid_p1                    (wv_bufid_pcb2nip_1),
.i_pkt_bufid_wr_p1                  (w_bufid_wr_pcb2nip_1),                   
.o_pkt_bufid_ack_p1                 (w_bufid_ack_hrp2nip_1),

.o_descriptor_wr_p0tohost           (w_descriptor_wr_p0tohost), 
.o_descriptor_wr_p0tonetwork        (w_descriptor_wr_p0tonetwork),
.ov_descriptor_p0                   (wv_descriptor_p0),
.i_descriptor_ack_hosttop0          (w_descriptor_ack_hosttop0),
.i_descriptor_ack_networktop0       (w_descriptor_ack_networktop0),
            
.o_descriptor_wr_p1tohost           (w_descriptor_wr_p1tohost), 
.o_descriptor_wr_p1tohcp            (w_descriptor_wr_p1tohcp),
.ov_descriptor_p1                   (wv_descriptor_p1),
.i_descriptor_ack_hosttop1          (w_descriptor_ack_hosttop1),               
.i_descriptor_ack_hcptop1           (w_descriptor_ack_hcptop1),

.ov_pkt_p0                          (wv_pkt_data_pcb2nip_0),
.o_pkt_wr_p0                        (w_pkt_data_wr_pcb2nip_0),
.ov_pkt_bufadd_p0                   (wv_pkt_addr_pcb2nip_0),
.i_pkt_ack_p0                       (w_pkt_ack_pcb2nip_0),
            
.ov_pkt_p1                          (wv_pkt_data_pcb2nip_1),
.o_pkt_wr_p1                        (w_pkt_data_wr_pcb2nip_1),
.ov_pkt_bufadd_p1                   (wv_pkt_addr_pcb2nip_1),
.i_pkt_ack_p1                       (w_pkt_ack_pcb2nip_1),

.iv_free_bufid_fifo_rdusedw         (wv_free_bufid_fifo_rdusedw),
.iv_be_threshold_value              (wv_be_regulation_value),
.iv_rc_threshold_value              (wv_rc_regulation_value),
.iv_map_req_threshold_value         (wv_map_req_regulation_value), 

.o_port0_inpkt_pulse                (w_port0_inpkt_pulse_nip2csm),
.o_port0_discard_pkt_pulse          (w_port0_discard_pkt_pulse_nip2csm),
.o_port1_inpkt_pulse                (w_port1_inpkt_pulse_nip2csm),
.o_port1_discard_pkt_pulse          (w_port1_discard_pkt_pulse_nip2csm),

.o_fifo_underflow_pulse_p0          (o_fifo_underflow_pulse_p0_rx),
.o_fifo_overflow_pulse_p0           (o_fifo_overflow_pulse_p0_rx ),
.o_fifo_underflow_pulse_p1          (o_fifo_underflow_pulse_p1_rx),
.o_fifo_overflow_pulse_p1           (o_fifo_overflow_pulse_p1_rx ),

.ov_gmii_read_state_p0              (wv_gmii_read_state_p0_nip2csm),
.o_gmii_fifo_full_p0                (w_gmii_fifo_full_p0_nip2csm),
.o_gmii_fifo_empty_p0               (w_gmii_fifo_empty_p0_nip2csm),
.ov_descriptor_extract_state_p0     (wv_descriptor_extract_state_p0_nip2csm),
.ov_descriptor_send_state_p0        (wv_descriptor_send_state_p0_nip2csm),
.ov_data_splice_state_p0            (wv_data_splice_state_p0_nip2csm),
.ov_input_buf_interface_state_p0    (wv_input_buf_interface_state_p0_nip2csm),

.ov_gmii_read_state_p1              (wv_gmii_read_state_p1_nip2csm),
.o_gmii_fifo_full_p1                (w_gmii_fifo_full_p1_nip2csm),
.o_gmii_fifo_empty_p1               (w_gmii_fifo_empty_p1_nip2csm),
.ov_descriptor_extract_state_p1     (wv_descriptor_extract_state_p1_nip2csm),
.ov_descriptor_send_state_p1        (wv_descriptor_send_state_p1_nip2csm),
.ov_data_splice_state_p1            (wv_data_splice_state_p1_nip2csm),
.ov_input_buf_interface_state_p1    (wv_input_buf_interface_state_p1_nip2csm)
);
reg       [8:0]        rv_pkt_bufid;    
reg                    r_pkt_bufid_wr;  
reg       [3:0]        rv_pkt_bufid_cnt;
always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n) begin
        rv_pkt_bufid <= 9'b0;
		r_pkt_bufid_wr <= 1'b0;
		rv_pkt_bufid_cnt <= 4'b0;
    end
    else begin
	    if(w_bufid_ack_hrp2nip_0 == 1'b1)begin
            rv_pkt_bufid <= wv_bufid_pcb2nip_0;
            r_pkt_bufid_wr <= 1'b1;
            rv_pkt_bufid_cnt <= 4'h1;
		end
        else if(w_bufid_ack_hrp2nip_1 == 1'b1)begin
            rv_pkt_bufid <= wv_bufid_pcb2nip_1;
            r_pkt_bufid_wr <= 1'b1;
            rv_pkt_bufid_cnt <= 4'h1;
        end
        else if(w_bufid_ack_hrp2pcb == 1'b1)begin
            rv_pkt_bufid <= wv_bufid_pcb2hrp;
            r_pkt_bufid_wr <= 1'b1;
            rv_pkt_bufid_cnt <= 4'h1;
        end 
        else begin
            rv_pkt_bufid <= 9'b0;
            r_pkt_bufid_wr <= 1'b0;
            rv_pkt_bufid_cnt <= 4'h0;
        end        
    end
end
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
                         
.iv_pkt_p2               (134'b0),//(wv_pkt_data_pcb2nip_2),
.i_pkt_wr_p2             (1'b0),//(w_pkt_data_wr_pcb2nip_2),
.iv_pkt_wr_bufadd_p2     (16'b0),//(wv_pkt_addr_pcb2nip_2),
.o_pkt_wr_ack_p2         (),//(w_pkt_ack_pcb2nip_2),

.iv_pkt_p3               (134'b0),//(wv_pkt_data_pcb2nip_3),
.i_pkt_wr_p3             (1'b0),//(w_pkt_data_wr_pcb2nip_3),
.iv_pkt_wr_bufadd_p3     (16'b0),//(wv_pkt_addr_pcb2nip_3),
.o_pkt_wr_ack_p3         (),//(w_pkt_ack_pcb2nip_3), 

.iv_pkt_p8               (wv_pkt_data_hrp2pcb),
.i_pkt_wr_p8             (w_pkt_data_wr_hrp2pcb),
.iv_pkt_wr_bufadd_p8     (wv_pkt_addr_hrp2pcb),  
.o_pkt_wr_ack_p8         (w_pkt_ack_pcb2hrp),

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

.iv_pkt_rd_bufadd_p2     (16'b0),//(wv_pkt_raddr_nop2pcb_2),
.i_pkt_rd_p2             (1'b0),//(w_pkt_rd_nop2pcb_2),
.o_pkt_rd_ack_p2         (),//(w_pkt_raddr_ack_pcb2nop_2),
.ov_pkt_p2               (),//(wv_pkt_data_pcb2nop_2),   
.o_pkt_wr_p2             (),//(w_pkt_data_wr_pcb2nop_2),

.iv_pkt_rd_bufadd_p3     (16'b0),//(wv_pkt_raddr_nop2pcb_3),
.i_pkt_rd_p3             (1'b0),//(w_pkt_rd_nop2pcb_3),
.o_pkt_rd_ack_p3         (),//(w_pkt_raddr_ack_pcb2nop_3),
.ov_pkt_p3               (),//(wv_pkt_data_pcb2nop_3),   
.o_pkt_wr_p3             (),//(w_pkt_data_wr_pcb2nop_3),

.iv_pkt_rd_bufadd_p8     (wv_pkt_raddr_htp2pcb),
.i_pkt_rd_p8             (w_pkt_rd_htp2pcb),
.o_pkt_rd_ack_p8         (w_pkt_raddr_ack_pcb2htp),
.ov_pkt_p8               (wv_pkt_data_pcb2htp), 
.o_pkt_wr_p8             (w_pkt_data_wr_pcb2htp),

.ov_pkt_bufid_p0         (wv_bufid_pcb2nip_0),
.o_pkt_bufid_wr_p0       (w_bufid_wr_pcb2nip_0),
.i_pkt_bufid_ack_p0      (w_bufid_ack_hrp2nip_0),
                         
.ov_pkt_bufid_p1         (wv_bufid_pcb2nip_1),
.o_pkt_bufid_wr_p1       (w_bufid_wr_pcb2nip_1),
.i_pkt_bufid_ack_p1      (w_bufid_ack_hrp2nip_1),
                         
.ov_pkt_bufid_p2         (),//(wv_bufid_pcb2nip_2),
.o_pkt_bufid_wr_p2       (),//(w_bufid_wr_pcb2nip_2),
.i_pkt_bufid_ack_p2      (1'b0),//(w_bufid_ack_hrp2nip_2),
                 
.ov_pkt_bufid_p3         (),//(wv_bufid_pcb2nip_3),
.o_pkt_bufid_wr_p3       (),//(w_bufid_wr_pcb2nip_3),
.i_pkt_bufid_ack_p3      (1'b0),//(w_bufid_ack_hrp2nip_3),

.ov_pkt_bufid_p8         (wv_bufid_pcb2hrp),
.o_pkt_bufid_wr_p8       (w_bufid_wr_pcb2hrp),
.i_pkt_bufid_ack_p8      (w_bufid_ack_hrp2pcb),

.i_pkt_bufid_wr_flt      (r_pkt_bufid_wr),//(w_pkt_bufid_wr_flt2pcb),
.iv_pkt_bufid_flt        (rv_pkt_bufid),//(wv_pkt_bufid_flt2pcb),
.iv_pkt_bufid_cnt_flt    (rv_pkt_bufid_cnt),//(wv_pkt_bufid_cnt_flt2pcb),

.iv_pkt_bufid_p0         (wv_pkt_bufid_nop2pcb_0),
.i_pkt_bufid_wr_p0       (w_pkt_bufid_wr_nop2pcb_0),
.o_pkt_bufid_ack_p0      (w_pkt_bufid_ack_pcb2nop_0),

.iv_pkt_bufid_p1         (wv_pkt_bufid_nop2pcb_1),
.i_pkt_bufid_wr_p1       (w_pkt_bufid_wr_nop2pcb_1),
.o_pkt_bufid_ack_p1      (w_pkt_bufid_ack_pcb2nop_1),

.iv_pkt_bufid_p2         (9'b0),//(wv_pkt_bufid_nop2pcb_2),
.i_pkt_bufid_wr_p2       (1'b0),//(w_pkt_bufid_wr_nop2pcb_2),
.o_pkt_bufid_ack_p2      (),//(w_pkt_bufid_ack_pcb2nop_2),
             
.iv_pkt_bufid_p3         (9'b0),//(wv_pkt_bufid_nop2pcb_3),
.i_pkt_bufid_wr_p3       (1'b0),//(w_pkt_bufid_wr_nop2pcb_3),
.o_pkt_bufid_ack_p3      (),//(w_pkt_bufid_ack_pcb2nop_3),

.iv_pkt_bufid_p8         (wv_pkt_bufid_htp2pcb),
.i_pkt_bufid_wr_p8       (w_pkt_bufid_wr_htp2pcb),
.o_pkt_bufid_ack_p8      (w_pkt_bufid_ack_pcb2htp),

.ov_pkt_write_state      (wv_pkt_write_state_pcb2csm),
.ov_pcb_pkt_read_state   (wv_pcb_pkt_read_state_pcb2csm),
.ov_address_write_state  (wv_address_write_state_pcb2csm),
.ov_address_read_state   (wv_address_read_state_pcb2csm),
.ov_free_buf_fifo_rdusedw(wv_free_bufid_fifo_rdusedw),

.bufid_state             (),
.bufid_overflow_cnt      (),
.bufid_underflow_cnt     ()	
);

host_transmit_process host_transmit_process_inst(
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
            
.i_host_gmii_tx_clk             (i_gmii_rxclk_host),
.i_gmii_rst_n_host              (i_gmii_rst_n_host),
            
.iv_tsntag_hcp                  (wv_descriptor_p0[56:9]),
.iv_bufid_hcp                   (wv_descriptor_p0[8:0]),
.i_descriptor_wr_hcp            (w_descriptor_wr_p0tohost),
.o_descriptor_ack_hcp           (w_descriptor_ack_hosttop0),

.iv_tsntag_network              (wv_descriptor_p1[56:9]),
.iv_bufid_network               (wv_descriptor_p1[8:0]),
.i_descriptor_wr_network        (w_descriptor_wr_p1tohost),
.o_descriptor_ack_network       (w_descriptor_ack_hosttop1),
           
.iv_cfg_finish                  (wv_cfg_finish_csm2others),
 
.iv_regroup_ram_wdata           (wv_regroup_ram_wdata),
.i_regroup_ram_wr               (w_regroup_ram_wr),
.iv_regroup_ram_addr            (wv_regroup_ram_addr),
.ov_regroup_ram_rdata           (wv_regroup_ram_rdata),
.i_regroup_ram_rd               (w_regroup_ram_rd),
 
.ov_pkt_bufid                   (wv_pkt_bufid_htp2pcb),
.o_pkt_bufid_wr                 (w_pkt_bufid_wr_htp2pcb),
.i_pkt_bufid_ack                (w_pkt_bufid_ack_pcb2htp),
            
.ov_pkt_raddr                   (wv_pkt_raddr_htp2pcb),
.o_pkt_rd                       (w_pkt_rd_htp2pcb),
.i_pkt_raddr_ack                (w_pkt_raddr_ack_pcb2htp),
            
.iv_pkt_data                    (wv_pkt_data_pcb2htp),
.i_pkt_data_wr                  (w_pkt_data_wr_pcb2htp),
             
.ov_gmii_txd                    (wv_gmii_txd_host_tsnchip2adp),
.o_gmii_tx_en                   (w_gmii_tx_en_host_tsnchip2adp),
.o_gmii_tx_er                   (w_gmii_tx_er_host_tsnchip2adp),
.o_gmii_tx_clk                  (o_gmii_tx_clk_host),
    
.iv_syned_global_time           (48'b0),
.i_timer_rst                    (i_timer_rst),
.iv_time_slot_length            (wv_slot_len_csm2others),
.iv_submit_slot_table_period    (wv_submit_slot_period_us_csm2htp),
    
.o_ts_underflow_error_pulse     (w_ts_sub_underflow_error_pulse_htp2csm),
.o_ts_overflow_error_pulse      (w_ts_sub_overflow_error_pulse_htp2csm),

.hos_state                      (wv_hos_state_htp2csm),
.hoi_state                      (wv_hoi_state_htp2csm),
.bufid_state                    (wv_bufid_state_htp2csm),
.pkt_read_state                 (wv_pkt_read_state_htp2csm),
.tsm_state                      (wv_tsm_state_htp2csm),
.ssm_state                      (wv_ssm_state_htp2csm),

.o_pkt_cnt_pulse                (w_host_outpkt_pulse_htp2csm),
.o_host_inqueue_discard_pulse   (w_host_in_queue_discard_pulse_htp2csm),
.o_fifo_overflow_pulse          (o_fifo_overflow_pulse_host_tx), 
 
.iv_submit_slot_table_addr      (wv_tss_ram_addr),
.iv_submit_slot_table_wdata     (wv_tss_ram_wdata),
.i_submit_slot_table_wr         (w_tss_ram_wr),
.ov_submit_slot_table_rdata     (wv_tss_ram_rdata),
.i_submit_slot_table_rd         (w_tss_ram_rd)
);

network_output_process network_output_process_inst(
.i_clk                      (i_clk),
.i_rst_n                    (i_rst_n),
                            
.i_gmii_clk_p0              (i_gmii_rxclk_p0),
.i_gmii_clk_p1              (i_gmii_rxclk_p1),
.i_gmii_rst_n_p0            (i_gmii_rst_n_p0),
.i_gmii_rst_n_p1            (i_gmii_rst_n_p1),
                            
.i_timer_rst_p0             (i_timer_rst),
.i_timer_rst_p1             (i_timer_rst),
//port 0 connect with hcp
.iv_tsntag_host2p0          (wv_nip_tsntag_hrp2hcp),
.iv_bufid_host2p0           (wv_nip_bufid_hrp2hcp),
.i_descriptor_wr_host2p0    (w_nip_descriptor_wr_hrp2hcp),
.o_descriptor_ack_p02host   (w_nip_descriptor_ack_hcp2hrp),

.iv_tsntag_network2p0       (wv_descriptor_p1[56:9]),
.iv_bufid_network2p0        (wv_descriptor_p1[8:0]),
.i_descriptor_wr_network2p0 (w_descriptor_wr_p1tohcp),
.o_descriptor_ack_p02network(w_descriptor_ack_hcptop1),  

.ov_pkt_bufid_p0            (wv_pkt_bufid_nop2pcb_0),
.o_pkt_bufid_wr_p0          (w_pkt_bufid_wr_nop2pcb_0),
.i_pkt_bufid_ack_p0         (w_pkt_bufid_ack_pcb2nop_0),
                            
.ov_pkt_raddr_p0            (wv_pkt_raddr_nop2pcb_0),
.o_pkt_rd_p0                (w_pkt_rd_nop2pcb_0),
.i_pkt_raddr_ack_p0         (w_pkt_raddr_ack_pcb2nop_0),
                            
.iv_pkt_data_p0             (wv_pkt_data_pcb2nop_0),
.i_pkt_data_wr_p0           (w_pkt_data_wr_pcb2nop_0),
                            
.ov_gmii_txd_p0             (wv_gmii_txd_p0_tsnchip2adp),
.o_gmii_tx_en_p0            (w_gmii_tx_en_p0_tsnchip2adp),
.o_gmii_tx_er_p0            (w_gmii_tx_er_p0_tsnchip2adp),
.o_gmii_tx_clk_p0           (o_gmii_tx_clk_p0),
 
.o_port0_outpkt_pulse       (w_port0_outpkt_pulse_nop2csm),
.o_fifo_overflow_pulse_p0   (o_fifo_overflow_pulse_p0_tx),
//port 1 connect with scp
.iv_tsntag_host2p1          (wv_ip_tsntag_hrp2scp),
.iv_bufid_host2p1           (wv_ip_bufid_hrp2scp),
.i_descriptor_wr_host2p1    (w_ip_descriptor_wr_hrp2scp),
.o_descriptor_ack_p12host   (w_ip_descriptor_ack_scp2hrp),

.iv_tsntag_network2p1       (wv_descriptor_p0[56:9]),
.iv_bufid_network2p1        (wv_descriptor_p0[8:0]),
.i_descriptor_wr_network2p1 (w_descriptor_wr_p0tonetwork),
.o_descriptor_ack_p12network(w_descriptor_ack_networktop0), 

.ov_pkt_bufid_p1            (wv_pkt_bufid_nop2pcb_1),
.o_pkt_bufid_wr_p1          (w_pkt_bufid_wr_nop2pcb_1),
.i_pkt_bufid_ack_p1         (w_pkt_bufid_ack_pcb2nop_1),
                            
.ov_pkt_raddr_p1            (wv_pkt_raddr_nop2pcb_1),
.o_pkt_rd_p1                (w_pkt_rd_nop2pcb_1),
.i_pkt_raddr_ack_p1         (w_pkt_raddr_ack_pcb2nop_1),
                            
.iv_pkt_data_p1             (wv_pkt_data_pcb2nop_1),
.i_pkt_data_wr_p1           (w_pkt_data_wr_pcb2nop_1),
                            
.ov_gmii_txd_p1             (wv_gmii_txd_p1_tsnchip2adp),
.o_gmii_tx_en_p1            (w_gmii_tx_en_p1_tsnchip2adp),
.o_gmii_tx_er_p1            (w_gmii_tx_er_p1_tsnchip2adp),
.o_gmii_tx_clk_p1           (o_gmii_tx_clk_p1),
                            
.o_port1_outpkt_pulse       (w_port1_outpkt_pulse_nop2csm),
.o_fifo_overflow_pulse_p1   (o_fifo_overflow_pulse_p1_tx)
);
command_parse command_parse_inst(
.i_clk                        (i_clk),
.i_rst_n                      (i_rst_n),

//.iv_command                   (iv_wr_command),
//.i_command_wr                 (i_wr_command_wr),                             
.iv_wr_command                (iv_wr_command),
.i_wr_command_wr              (i_wr_command_wr),

//.ov_command                (),
//.o_command_wr              (),
.iv_rd_command                (iv_rd_command),
.i_rd_command_wr              (i_rd_command_wr),        
.ov_rd_ack_command            (ov_rd_command_ack), 
                              
.ov_cfg_finish                (wv_cfg_finish_csm2others),
.ov_rc_regulation_value       (wv_rc_regulation_value),
.ov_be_regulation_value       (wv_be_regulation_value),
.ov_unmap_regulation_value    (wv_map_req_regulation_value),
.ov_port_type                 (wv_port_type),

.ov_map_ram_wdata             (wv_fmt_ram_wdata_cpa2hrp),
.o_map_ram_wr                 (w_fmt_ram_wr_cpa2hrp),
.ov_map_ram_addr              (wv_fmt_ram_addr_cpa2hrp),
.iv_map_ram_rdata             (wv_fmt_ram_rdata_hrp2cpa),
.o_map_ram_rd                 (w_fmt_ram_rd_cpa2hrp),

.ov_regroup_ram_wdata         (wv_regroup_ram_wdata),
.o_regroup_ram_wr             (w_regroup_ram_wr),
.ov_regroup_ram_addr          (wv_regroup_ram_addr),
.iv_regroup_ram_rdata         (wv_regroup_ram_rdata),
.o_regroup_ram_rd             (w_regroup_ram_rd) 
);
endmodule


