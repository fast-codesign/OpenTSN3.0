// Copyright (C) 1953-2020 NUDT
// Verilog module name - HCP
// Version: HCP_V1.0
// Created:
//         by - peng jintao 
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         hardware control point
///////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

module hcp
(
        i_clk,
        i_rst_n,
       
        ov_wr_command,
        o_wr_command_wr, 
       
        ov_rd_command,
        o_rd_command_wr,        
        iv_rd_command_ack,        
       
	    i_gmii_rxclk,
	    i_gmii_dv,
	    iv_gmii_rxd,
	    i_gmii_er,    
       
	    ov_gmii_txd,
	    o_gmii_tx_en,
	    o_gmii_tx_er,
	    o_gmii_tx_clk,


        o_timer_rst_gts2others,
        ov_time_slot,
        o_time_slot_switch,
        o_s_pulse        
);

// I/O
// clk & rst
input               i_clk;
input               i_rst_n; 

output  [203:0]	    ov_wr_command;
output  	        o_wr_command_wr;

output  [203:0]	    ov_rd_command;
output    	        o_rd_command_wr;
input   [203:0]	    iv_rd_command_ack;

input				i_gmii_rxclk;
input	  		    i_gmii_dv;
input	[7:0]	 	iv_gmii_rxd;
input			    i_gmii_er;

output  [7:0] 	  	ov_gmii_txd;
output      		o_gmii_tx_en;
output      		o_gmii_tx_er;
output      	    o_gmii_tx_clk;

output              o_s_pulse;
output  [9:0]       ov_time_slot;
output              o_time_slot_switch;   

wire                w_gmii_rst_n;

wire                w_gmii_dv_gad2nrx;
wire                w_gmii_er_gad2nrx;
wire    [7:0]       wv_gmii_rxd_gad2nrx;

wire                w_gmii_tx_en_ntx2gad;
wire                w_gmii_tx_er_ntx2gad;
wire    [7:0]       wv_gmii_txd_ntx2gad ;


wire    [8:0]       wv_data_dcm2dmux ;
wire                w_data_wr_dcm2dmux ;
wire    [34:0]      wv_descriptor;
                
wire    [8:0]       wv_data_dmux2ddm ;
wire    [34:0]      wv_descriptor_dmux2ddm;
wire                w_data_wr_dmux2ddm ;
wire    [8:0]       wv_data_dmux2fem ;
wire    [34:0]      wv_descriptor_dmux2fem;
wire                w_data_wr_dmux2fem ;
wire    [47:0]      wv_dmac_ddm2fem ;
wire    [47:0]      wv_smac_ddm2fem ;

wire    [8:0]       wv_data_ddm2mux ;
wire                w_data_wr_ddm2mux ;

wire    [8:0]       wv_data_fem2mux ;
wire                w_data_wr_fem2mux ;

wire    [8:0]       wv_data_nrx2dcm ;
wire                w_data_wr_nrx2dcm ;
                    
wire    [8:0]       wv_data_mux2ntx ;
wire                w_data_wr_mux2ntx ;

output              o_timer_rst_gts2others;

wire    [18:0]      wv_ts_rec;
//csm
wire    [8:0]       wv_nmac_data_ddm2csm;
wire                w_nmac_data_wr_ddm2csm;
wire    [48:0]      wv_time_offset_csm2gts;   
wire                w_time_offset_wr_csm2gts; 
wire    [11:0]      wv_report_period_csm2gts;   
wire    [23:0]      wv_offset_period_csm2gts; 
wire    [1:0]       wv_cfg_finish_csm2others;  
wire    [7:0]       wv_port_type_csm2others; 
wire    [47:0]      wv_syned_global_time_gts2tsc ; 
wire    [7:0]       wv_nmac_data_csm2dcm;
wire                w_nmac_data_last_csm2dcm;
wire                w_namc_report_req_csm2dcm;
wire                w_nmac_report_ack_csm2dcm;
wire    [10:0]      wv_slot_len_csm2others;

wire    [10:0]      wv_table_period; 

reset_sync gmii_reset_sync(
.i_clk                 (i_gmii_rxclk),
.i_rst_n               (i_rst_n),      
.o_rst_n_sync          (w_gmii_rst_n)   
);

signal_sync p0_gmii_sync(
.i_clk                 (i_gmii_rxclk),
.i_rst_n               (w_gmii_rst_n),         
.i_signal_async        (),
.o_signal_sync         ()   
);



gmii_adapter_hcp gmii_adapter_hcp_inst(
.gmii_rxclk            (i_gmii_rxclk),
.gmii_txclk            (i_gmii_rxclk),
       
.rst_n                 (w_gmii_rst_n),      
.port_type             (wv_port_type_csm2others[4]),
       
.gmii_rx_dv            (i_gmii_dv),
.gmii_rx_er            (i_gmii_er),
.gmii_rxd              (iv_gmii_rxd),

.gmii_rx_dv_adp2tsnchip(w_gmii_dv_gad2nrx),
.gmii_rx_er_adp2tsnchip(w_gmii_er_gad2nrx),
.gmii_rxd_adp2tsnchip  (wv_gmii_rxd_gad2nrx),

.gmii_tx_en_tsnchip2adp(w_gmii_tx_en_ntx2gad),
.gmii_tx_er_tsnchip2adp(w_gmii_tx_er_ntx2gad),
.gmii_txd_tsnchip2adp  (wv_gmii_txd_ntx2gad ),

.gmii_tx_en            (o_gmii_tx_en),
.gmii_tx_er            (o_gmii_tx_er),
.gmii_txd              (ov_gmii_txd)

);

network_rx_hcp network_rx_hcp_inst(

.clk_sys               (i_clk),
.reset_n               (i_rst_n),
.i_gmii_rst_n          (w_gmii_rst_n),

.port_type             (wv_port_type_csm2others[4]),
.cfg_finish            (wv_cfg_finish_csm2others),
            
.clk_gmii_rx           (i_gmii_rxclk),
.i_gmii_dv             (w_gmii_dv_gad2nrx),
.iv_gmii_rxd           (wv_gmii_rxd_gad2nrx),
.i_gmii_er             (w_gmii_er_gad2nrx),
            
.timer_rst             (o_timer_rst_gts2others), 

.ov_data               (wv_data_nrx2dcm ),
.o_data_wr             (w_data_wr_nrx2dcm ),
.ov_rec_ts             (wv_ts_rec ),        

.o_pkt_valid_pulse     ( ),
.gmii_fifo_rdfull      ( ),
.gmii_fifo_empty       ( ),
.gmii_read_hcp_state   ( ),

.o_fifo_overflow_pulse ( ),
.o_fifo_underflow_pulse( )
);


network_tx_hcp network_tx_hcp_inst(

.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),
.i_gmii_clk            (i_gmii_rxclk),
.i_gmii_rst_n          (w_gmii_rst_n),
           
.iv_pkt_data           (wv_data_mux2ntx),
.i_pkt_data_wr         (w_data_wr_mux2ntx),
           
.ov_gmii_txd           (wv_gmii_txd_ntx2gad),
.o_gmii_tx_en          (w_gmii_tx_en_ntx2gad),
.o_gmii_tx_er          (w_gmii_tx_er_ntx2gad),
.o_gmii_tx_clk         ( ), 
           
.i_timer_rst           (o_timer_rst_gts2others),
.ov_opc_state          ( ),

.o_fifo_overflow_pulse ( ),
.ov_debug_ts_cnt       ( )
);

hcp_frame_parse hcp_frame_parse_inst(

.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),

.iv_data               (wv_data_nrx2dcm),
.iv_ts_rec             (wv_ts_rec),
.i_data_wr             (w_data_wr_nrx2dcm),
       
.iv_data_csm           (wv_nmac_data_csm2dcm),
.i_data_csm_last       (w_nmac_data_last_csm2dcm),
.i_report_en           (w_namc_report_req_csm2dcm),
.o_report_en_ack       (w_nmac_report_ack_csm2dcm),

.ov_data               (wv_data_dcm2dmux),
.o_data_wr             (w_data_wr_dcm2dmux), 

.ov_descriptor         (wv_descriptor),
.ov_dcm_state          ( )
);

dmux dmux_inst(
.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),

.iv_cfg_finish         (wv_cfg_finish_csm2others),
    
.iv_data               (wv_data_dcm2dmux),
.i_data_wr             (w_data_wr_dcm2dmux),
.iv_descriptor         (wv_descriptor),

.ov_data_ddm           (wv_data_dmux2ddm),
.ov_descriptor_ddm     (wv_descriptor_dmux2ddm),
.o_data_wr_ddm         (w_data_wr_dmux2ddm),
    
.ov_data_fem           (wv_data_dmux2fem),
.ov_descriptor_fem     (wv_descriptor_dmux2fem),
.o_data_wr_fem         (w_data_wr_dmux2fem)
);

mux mux_inst(
.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),

.iv_data_fem           (wv_data_fem2mux),
.i_data_wr_fem         (w_data_wr_fem2mux),
           
.iv_data_ddm           (wv_data_ddm2mux),
.i_data_wr_ddm         (w_data_wr_ddm2mux),
           
.ov_data               (wv_data_mux2ntx),
.o_data_wr             (w_data_wr_mux2ntx)
);

global_time_sync global_time_sync_inst(
.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),
       
.iv_time_offset        (wv_time_offset_csm2gts),
.i_time_offset_wr      (w_time_offset_wr_csm2gts),
.iv_offset_period      (wv_offset_period_csm2gts),
               
.pluse_s               (o_s_pulse),              
.iv_cfg_finish         (wv_cfg_finish_csm2others),
.iv_report_period      (wv_report_period_csm2gts),
           
.ov_syned_time         (wv_syned_global_time_gts2tsc),
.o_timer_reset_pluse   (o_timer_rst_gts2others)

);

decapsulation_dispatch_module decapsulation_dispatch_module_inst(

.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),

.i_timer_rst           (o_timer_rst_gts2others),
.iv_syned_global_time  (wv_syned_global_time_gts2tsc),
       
.iv_data               (wv_data_dmux2ddm),
.iv_descriptor         (wv_descriptor_dmux2ddm),
.i_data_wr             (w_data_wr_dmux2ddm),
	    
.ov_data2csm           (wv_nmac_data_ddm2csm),
.o_data2csm_wr         (w_nmac_data_wr_ddm2csm),

.ov_data2mux           (wv_data_ddm2mux),
.o_data2mux_wr         (w_data_wr_ddm2mux),

.ov_dmac               (wv_dmac_ddm2fem),
.ov_smac               (wv_smac_ddm2fem)
);

frame_encapsulation_module frame_encapsulation_module_inst(

.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),
                   
.iv_dmac               (wv_dmac_ddm2fem),
.iv_smac               (wv_smac_ddm2fem),

.i_timer_rst           (o_timer_rst_gts2others),
.iv_syned_global_time  (wv_syned_global_time_gts2tsc),
       
.iv_data               (wv_data_dmux2fem),
.i_data_wr             (w_data_wr_dmux2fem),
.iv_descriptor         (wv_descriptor_dmux2fem),
	   
.ov_data               (wv_data_fem2mux),
.o_data_wr             (w_data_wr_fem2mux)   
);
time_slot_calculation time_slot_calculation_inst(
.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),
       
.iv_syned_global_time  (wv_syned_global_time_gts2tsc),
.iv_time_slot_length   (wv_slot_len_csm2others),
       
.iv_table_period       (wv_table_period),
       
.ov_time_slot          (ov_time_slot ),
.o_time_slot_switch    (o_time_slot_switch )       
);


configure_state_manage configure_state_manage_inst(
.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),

.iv_nmac_data          (wv_nmac_data_ddm2csm),
.i_nmac_data_wr        (w_nmac_data_wr_ddm2csm),
       
.ov_wr_command         (ov_wr_command),
.o_wr_command_wr       (o_wr_command_wr),       
       
.ov_rd_command         (ov_rd_command),
.o_rd_command_wr       (o_rd_command_wr),
.iv_rd_command_ack     (iv_rd_command_ack),      

.ov_time_offset        (wv_time_offset_csm2gts),
.o_time_offset_wr      (w_time_offset_wr_csm2gts),
.ov_cfg_finish         (wv_cfg_finish_csm2others),
.ov_port_type          (wv_port_type_csm2others),
.ov_slot_len           (wv_slot_len_csm2others),
.ov_inject_slot_period (wv_table_period),
.ov_submit_slot_period (),
.o_qbv_or_qch          (),
.ov_report_period      (wv_report_period_csm2gts),
.ov_offset_period      (wv_offset_period_csm2gts),
.ov_rc_regulation_value(),
.ov_be_regulation_value(),
.ov_unmap_regulation_value    (),
       
.i_host_inpkt_pulse           (1'b0),
.i_host_discard_pkt_pulse     (1'b0),
.i_port0_inpkt_pulse          (1'b0),
.i_port0_discard_pkt_pulse    (1'b0),
.i_port1_inpkt_pulse          (1'b0),
.i_port1_discard_pkt_pulse    (1'b0),
.i_port2_inpkt_pulse          (1'b0),
.i_port2_discard_pkt_pulse    (1'b0),
.i_port3_inpkt_pulse          (1'b0),
.i_port3_discard_pkt_pulse    (1'b0),
       
.i_host_outpkt_pulse          (1'b0),
.i_host_in_queue_discard_pulse(1'b0),
.i_port0_outpkt_pulse         (1'b0),
.i_port1_outpkt_pulse         (1'b0),
.i_port2_outpkt_pulse         (1'b0),
.i_port3_outpkt_pulse         (1'b0),

.ov_nmac_data                 (wv_nmac_data_csm2dcm),
.o_nmac_data_last             (w_nmac_data_last_csm2dcm),
.o_namc_report_req            (w_namc_report_req_csm2dcm),
.i_nmac_report_ack            (w_nmac_report_ack_csm2dcm),
.i_report_pulse               (o_s_pulse)
 /*      
.i_ts_inj_underflow_error_pulse(),
.i_ts_inj_overflow_error_pulse(),
.i_ts_sub_underflow_error_pulse(),
.i_ts_sub_overflow_error_pulse(),
       
.iv_pdi_state(),
.iv_prp_state(),
.iv_tom_state(),
.iv_pkt_state(),
.iv_transmission_state(),
.iv_descriptor_state(),
.iv_tim_state(),
.iv_ism_state(),
       
.iv_hos_state(),
.iv_hoi_state(),
.iv_pkt_read_state(),
.iv_tsm_state(),
.iv_bufid_state(),
.iv_smm_state(),
       
.iv_tdm_state(),
       
.iv_osc_state_p0(),
.iv_prc_state_p0(),
.iv_opc_state_p0(),
.iv_gmii_read_state_p0(),
.i_gmii_fifo_full_p0(),
.i_gmii_fifo_empty_p0(),
.iv_descriptor_extract_state_p0(),
.iv_descriptor_send_state_p0(),
.iv_data_splice_state_p0(),
.iv_input_buf_interface_state_p0(),
       
.iv_osc_state_p1(),
.iv_prc_state_p1(),
.iv_opc_state_p1(),
.iv_gmii_read_state_p1(),
.i_gmii_fifo_full_p1(),
.i_gmii_fifo_empty_p1(),
.iv_descriptor_extract_state_p1(),
.iv_descriptor_send_state_p1(),
.iv_data_splice_state_p1(),
.iv_input_buf_interface_state_p1(),
       
.iv_osc_state_p2(),
.iv_prc_state_p2(),
.iv_opc_state_p2(),
.iv_gmii_read_state_p2(),
.i_gmii_fifo_full_p2(),
.i_gmii_fifo_empty_p2(),
.iv_descriptor_extract_state_p2(),
.iv_descriptor_send_state_p2(),
.iv_data_splice_state_p2(),
.iv_input_buf_interface_state_p2(),
       
.iv_osc_state_p3(),
.iv_prc_state_p3(),
.iv_opc_state_p3(),
.iv_gmii_read_state_p3(),
.i_gmii_fifo_full_p3(),
.i_gmii_fifo_empty_p3(),
.iv_descriptor_extract_state_p3(),
.iv_descriptor_send_state_p3(),
.iv_data_splice_state_p3(),
.iv_input_buf_interface_state_p3(),
       
.iv_pkt_write_state(),
.iv_pcb_pkt_read_state(),
.iv_address_write_state(),
.iv_address_read_state(),
.iv_free_buf_fifo_rdusedw(),
       
.ov_tss_ram_addr(),
.ov_tss_ram_wdata(),
.o_tss_ram_wr(),
.iv_tss_ram_rdata(),
.o_tss_ram_rd(),
       
.ov_tis_ram_addr(),
.ov_tis_ram_wdata(),
.o_tis_ram_wr(),
.iv_tis_ram_rdata(),
.o_tis_ram_rd(),
       
.ov_flt_ram_addr(),
.ov_flt_ram_wdata(),
.o_flt_ram_wr(),
.iv_flt_ram_rdata(),
.o_flt_ram_rd(),
       
.ov_qgc0_ram_addr(),
.ov_qgc0_ram_wdata(),
.o_qgc0_ram_wr(),
.iv_qgc0_ram_rdata(),
.o_qgc0_ram_rd(),
       
.ov_qgc1_ram_addr(),
.ov_qgc1_ram_wdata(),
.o_qgc1_ram_wr(),
.iv_qgc1_ram_rdata(),
.o_qgc1_ram_rd(),
       
.ov_qgc2_ram_addr(),
.ov_qgc2_ram_wdata(),
.o_qgc2_ram_wr(),
.iv_qgc2_ram_rdata(),
.o_qgc2_ram_rd(),
       
.ov_qgc3_ram_addr(),
.ov_qgc3_ram_wdata(),
.o_qgc3_ram_wr(),
.iv_qgc3_ram_rdata(),
.o_qgc3_ram_rd(),
       
.ov_qgc4_ram_addr(),
.ov_qgc4_ram_wdata(),
.o_qgc4_ram_wr(),
.iv_qgc4_ram_rdata(),
.o_qgc4_ram_rd(),
       
.ov_qgc5_ram_addr(),
.ov_qgc5_ram_wdata(),
.o_qgc5_ram_wr(),
.iv_qgc5_ram_rdata(),
.o_qgc5_ram_rd(),
       
.ov_qgc6_ram_addr(),
.ov_qgc6_ram_wdata(),
.o_qgc6_ram_wr(),
.iv_qgc6_ram_rdata(),
.o_qgc6_ram_rd(),
       
.ov_qgc7_ram_addr(),
.ov_qgc7_ram_wdata(),
.o_qgc7_ram_wr(),
.iv_qgc7_ram_rdata(),
.o_qgc7_ram_rd()    
*/
);

endmodule 