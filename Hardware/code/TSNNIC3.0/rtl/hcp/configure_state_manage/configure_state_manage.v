// Copyright (C) 1953-2020 NUDT
// Verilog module name - configure_state_manage
// Version: CSM_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//        configure&state manage,process and build nmac pkt
//               
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module configure_state_manage
(
       i_clk,
       i_rst_n,

       iv_nmac_data,
       i_nmac_data_wr,
       
       ov_wr_command,
       o_wr_command_wr,       
       
       ov_rd_command,
       o_rd_command_wr,
       iv_rd_command_ack,      

       ov_time_offset,
       o_time_offset_wr,
       ov_cfg_finish,
       ov_port_type,
       ov_slot_len,
       ov_inject_slot_period,
       ov_submit_slot_period,
       o_qbv_or_qch,
       ov_report_period,
       ov_offset_period,
       ov_rc_regulation_value,
       ov_be_regulation_value,
       ov_unmap_regulation_value,

       i_host_inpkt_pulse,
       i_host_discard_pkt_pulse,
       i_port0_inpkt_pulse,
       i_port0_discard_pkt_pulse,
       i_port1_inpkt_pulse,
       i_port1_discard_pkt_pulse,
       i_port2_inpkt_pulse,
       i_port2_discard_pkt_pulse,
       i_port3_inpkt_pulse,
       i_port3_discard_pkt_pulse,

       i_host_outpkt_pulse,
       i_host_in_queue_discard_pulse,
       i_port0_outpkt_pulse,
       i_port1_outpkt_pulse,
       i_port2_outpkt_pulse,
       i_port3_outpkt_pulse,

       ov_nmac_data,
       o_nmac_data_last,
       o_namc_report_req,
       i_nmac_report_ack,
       i_report_pulse,
       
       i_ts_inj_underflow_error_pulse,
       i_ts_inj_overflow_error_pulse,
       i_ts_sub_underflow_error_pulse,
       i_ts_sub_overflow_error_pulse,
       
       iv_pdi_state,
       iv_prp_state,
       iv_tom_state,
       iv_pkt_state,
       iv_transmission_state,
       iv_descriptor_state,
       iv_tim_state,
       iv_ism_state,
       
       iv_hos_state,
       iv_hoi_state,
       iv_pkt_read_state,
       iv_tsm_state,
       iv_bufid_state,
       iv_smm_state,
       
       iv_tdm_state,
       
       iv_osc_state_p0,
       iv_prc_state_p0,
       iv_opc_state_p0,
       iv_gmii_read_state_p0,
       i_gmii_fifo_full_p0,
       i_gmii_fifo_empty_p0,
       iv_descriptor_extract_state_p0,
       iv_descriptor_send_state_p0,
       iv_data_splice_state_p0,
       iv_input_buf_interface_state_p0,
       
       iv_osc_state_p1,
       iv_prc_state_p1,
       iv_opc_state_p1,
       iv_gmii_read_state_p1,
       i_gmii_fifo_full_p1,
       i_gmii_fifo_empty_p1,
       iv_descriptor_extract_state_p1,
       iv_descriptor_send_state_p1,
       iv_data_splice_state_p1,
       iv_input_buf_interface_state_p1,
       
       iv_osc_state_p2,
       iv_prc_state_p2,
       iv_opc_state_p2,
       iv_gmii_read_state_p2,
       i_gmii_fifo_full_p2,
       i_gmii_fifo_empty_p2,
       iv_descriptor_extract_state_p2,
       iv_descriptor_send_state_p2,
       iv_data_splice_state_p2,
       iv_input_buf_interface_state_p2,
       
       iv_osc_state_p3,
       iv_prc_state_p3,
       iv_opc_state_p3,
       iv_gmii_read_state_p3,
       i_gmii_fifo_full_p3,
       i_gmii_fifo_empty_p3,
       iv_descriptor_extract_state_p3,
       iv_descriptor_send_state_p3,
       iv_data_splice_state_p3,
       iv_input_buf_interface_state_p3,
       
       iv_pkt_write_state,
       iv_pcb_pkt_read_state,
       iv_address_write_state,
       iv_address_read_state,
       iv_free_buf_fifo_rdusedw,
       
       ov_tss_ram_addr,
       ov_tss_ram_wdata,
       o_tss_ram_wr,
       iv_tss_ram_rdata,
       o_tss_ram_rd,
       
       ov_tis_ram_addr,
       ov_tis_ram_wdata,
       o_tis_ram_wr,
       iv_tis_ram_rdata,
       o_tis_ram_rd,
       
       ov_flt_ram_addr,
       ov_flt_ram_wdata,
       o_flt_ram_wr,
       iv_flt_ram_rdata,
       o_flt_ram_rd,
       
       ov_qgc0_ram_addr,
       ov_qgc0_ram_wdata,
       o_qgc0_ram_wr,
       iv_qgc0_ram_rdata,
       o_qgc0_ram_rd,
       
       ov_qgc1_ram_addr,
       ov_qgc1_ram_wdata,
       o_qgc1_ram_wr,
       iv_qgc1_ram_rdata,
       o_qgc1_ram_rd,
       
       ov_qgc2_ram_addr,
       ov_qgc2_ram_wdata,
       o_qgc2_ram_wr,
       iv_qgc2_ram_rdata,
       o_qgc2_ram_rd,
       
       ov_qgc3_ram_addr,
       ov_qgc3_ram_wdata,
       o_qgc3_ram_wr,
       iv_qgc3_ram_rdata,
       o_qgc3_ram_rd,
       
       ov_qgc4_ram_addr,
       ov_qgc4_ram_wdata,
       o_qgc4_ram_wr,
       iv_qgc4_ram_rdata,
       o_qgc4_ram_rd,
       
       ov_qgc5_ram_addr,
       ov_qgc5_ram_wdata,
       o_qgc5_ram_wr,
       iv_qgc5_ram_rdata,
       o_qgc5_ram_rd,
       
       ov_qgc6_ram_addr,
       ov_qgc6_ram_wdata,
       o_qgc6_ram_wr,
       iv_qgc6_ram_rdata,
       o_qgc6_ram_rd,
       
       ov_qgc7_ram_addr,
       ov_qgc7_ram_wdata,
       o_qgc7_ram_wr,
       iv_qgc7_ram_rdata,
       o_qgc7_ram_rd    
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;

input     [8:0]        iv_nmac_data;
input                  i_nmac_data_wr;

output    [203:0]	   ov_wr_command;
output  	           o_wr_command_wr;

output    [203:0]	   ov_rd_command;
output    	           o_rd_command_wr;
input     [203:0]	   iv_rd_command_ack;

output    [48:0]       ov_time_offset;
output                 o_time_offset_wr;
output    [1:0]        ov_cfg_finish;
output    [7:0]        ov_port_type;
output    [10:0]       ov_slot_len;
output    [10:0]       ov_inject_slot_period;
output    [10:0]       ov_submit_slot_period;
output                 o_qbv_or_qch;
output    [11:0]       ov_report_period;

output    [23:0]       ov_offset_period;

output     [8:0]       ov_rc_regulation_value;
output     [8:0]       ov_be_regulation_value;
output     [8:0]       ov_unmap_regulation_value;

       
input                  i_host_inpkt_pulse;
input                  i_host_discard_pkt_pulse;
input                  i_port0_inpkt_pulse;
input                  i_port0_discard_pkt_pulse;
input                  i_port1_inpkt_pulse;
input                  i_port1_discard_pkt_pulse;
input                  i_port2_inpkt_pulse;
input                  i_port2_discard_pkt_pulse;
input                  i_port3_inpkt_pulse;
input                  i_port3_discard_pkt_pulse;

       
input                  i_host_outpkt_pulse;
input                  i_host_in_queue_discard_pulse;
input                  i_port0_outpkt_pulse;
input                  i_port1_outpkt_pulse;
input                  i_port2_outpkt_pulse;
input                  i_port3_outpkt_pulse;

       
output    [7:0]        ov_nmac_data;
output                 o_nmac_data_last;
output                 o_namc_report_req;
input                  i_nmac_report_ack;
input                  i_report_pulse;
       
input                  i_ts_inj_underflow_error_pulse;
input                  i_ts_inj_overflow_error_pulse;
input                  i_ts_sub_underflow_error_pulse;
input                  i_ts_sub_overflow_error_pulse;

input     [2:0]        iv_pkt_state;
input     [2:0]        iv_transmission_state;
input     [2:0]        iv_pdi_state;
input     [1:0]        iv_prp_state;
input     [2:0]        iv_descriptor_state;
input     [2:0]        iv_tim_state;
input     [1:0]        iv_tom_state;
input     [2:0]        iv_ism_state;
input     [1:0]        iv_hos_state;
input     [3:0]        iv_hoi_state;
input     [2:0]        iv_pkt_read_state;
input     [2:0]        iv_tsm_state;
input     [1:0]        iv_bufid_state;
input     [2:0]        iv_smm_state;
input     [3:0]        iv_tdm_state;


input     [1:0]        iv_osc_state_p0;
input     [1:0]        iv_prc_state_p0;
input     [1:0]        iv_gmii_read_state_p0;
input     [2:0]        iv_opc_state_p0;
input                  i_gmii_fifo_full_p0;
input                  i_gmii_fifo_empty_p0;
input     [3:0]        iv_descriptor_extract_state_p0;
input     [1:0]        iv_descriptor_send_state_p0;
input     [1:0]        iv_data_splice_state_p0;
input     [1:0]        iv_input_buf_interface_state_p0;

input     [1:0]        iv_osc_state_p1;
input     [1:0]        iv_prc_state_p1;
input     [1:0]        iv_gmii_read_state_p1;
input     [2:0]        iv_opc_state_p1;
input                  i_gmii_fifo_full_p1;
input                  i_gmii_fifo_empty_p1;
input     [3:0]        iv_descriptor_extract_state_p1;
input     [1:0]        iv_descriptor_send_state_p1;
input     [1:0]        iv_data_splice_state_p1;
input     [1:0]        iv_input_buf_interface_state_p1;

input     [1:0]        iv_osc_state_p2;
input     [1:0]        iv_prc_state_p2;
input     [1:0]        iv_gmii_read_state_p2;
input     [2:0]        iv_opc_state_p2;
input                  i_gmii_fifo_full_p2;
input                  i_gmii_fifo_empty_p2;
input     [3:0]        iv_descriptor_extract_state_p2;
input     [1:0]        iv_descriptor_send_state_p2;
input     [1:0]        iv_data_splice_state_p2;
input     [1:0]        iv_input_buf_interface_state_p2;

input     [1:0]        iv_osc_state_p3;
input     [1:0]        iv_prc_state_p3;
input     [1:0]        iv_gmii_read_state_p3;
input     [2:0]        iv_opc_state_p3;
input                  i_gmii_fifo_full_p3;
input                  i_gmii_fifo_empty_p3;
input     [3:0]        iv_descriptor_extract_state_p3;
input     [1:0]        iv_descriptor_send_state_p3;
input     [1:0]        iv_data_splice_state_p3;
input     [1:0]        iv_input_buf_interface_state_p3;





input     [3:0]        iv_pkt_write_state;
input     [3:0]        iv_pcb_pkt_read_state;
input     [3:0]        iv_address_write_state;
input     [3:0]        iv_address_read_state;
input     [8:0]        iv_free_buf_fifo_rdusedw;
       
output    [9:0]        ov_tss_ram_addr;
output    [15:0]       ov_tss_ram_wdata;
output                 o_tss_ram_wr;
input     [15:0]       iv_tss_ram_rdata;
output                 o_tss_ram_rd;
       
output    [9:0]        ov_tis_ram_addr;
output    [15:0]       ov_tis_ram_wdata;
output                 o_tis_ram_wr;
input     [15:0]       iv_tis_ram_rdata;
output                 o_tis_ram_rd;
       
output    [13:0]       ov_flt_ram_addr;
output    [8:0]        ov_flt_ram_wdata;
output                 o_flt_ram_wr;
input     [8:0]        iv_flt_ram_rdata;
output                 o_flt_ram_rd;
       
output    [9:0]        ov_qgc0_ram_addr;
output    [7:0]        ov_qgc0_ram_wdata;
output                 o_qgc0_ram_wr;
input     [7:0]        iv_qgc0_ram_rdata;
output                 o_qgc0_ram_rd;
              
output    [9:0]        ov_qgc1_ram_addr;
output    [7:0]        ov_qgc1_ram_wdata;
output                 o_qgc1_ram_wr;
input     [7:0]        iv_qgc1_ram_rdata;
output                 o_qgc1_ram_rd;
              
output    [9:0]        ov_qgc2_ram_addr;
output    [7:0]        ov_qgc2_ram_wdata;
output                 o_qgc2_ram_wr;
input     [7:0]        iv_qgc2_ram_rdata;
output                 o_qgc2_ram_rd;
              
output    [9:0]        ov_qgc3_ram_addr;
output    [7:0]        ov_qgc3_ram_wdata;
output                 o_qgc3_ram_wr;
input     [7:0]        iv_qgc3_ram_rdata;
output                 o_qgc3_ram_rd;

output    [9:0]        ov_qgc4_ram_addr;
output    [7:0]        ov_qgc4_ram_wdata;
output                 o_qgc4_ram_wr;
input     [7:0]        iv_qgc4_ram_rdata;
output                 o_qgc4_ram_rd;

output    [9:0]        ov_qgc5_ram_addr;
output    [7:0]        ov_qgc5_ram_wdata;
output                 o_qgc5_ram_wr;
input     [7:0]        iv_qgc5_ram_rdata;
output                 o_qgc5_ram_rd;

output    [9:0]        ov_qgc6_ram_addr;
output    [7:0]        ov_qgc6_ram_wdata;
output                 o_qgc6_ram_wr;
input     [7:0]        iv_qgc6_ram_rdata;
output                 o_qgc6_ram_rd;

output    [9:0]        ov_qgc7_ram_addr;
output    [7:0]        ov_qgc7_ram_wdata;
output                 o_qgc7_ram_wr;
input     [7:0]        iv_qgc7_ram_rdata;
output                 o_qgc7_ram_rd; 

wire      [15:0]       wv_report_type;
wire                   w_report_en;

wire      [15:0]       wdata; 
wire      [15:0]       waddr;
wire      [10:0]       wr;
wire      [15:0]       rdata; 
wire      [15:0]       raddr;
wire      [10:0]       rd; 

wire      [151:0]      wv_mapping_wdata;
wire      [4:0]        wv_mapping_waddr;
wire                   w_mapping_wr;
wire      [151:0]      wv_mapping_rdata;
wire      [4:0]        wv_mapping_raddr;
wire                   w_mapping_rd;
                       
wire      [61:0]       wv_inverse_mapping_wdata;
wire      [7:0]        wv_inverse_mapping_waddr;
wire                   w_inverse_mapping_wr;
wire      [61:0]       wv_inverse_mapping_rdata;
wire      [7:0]        wv_inverse_mapping_raddr;
wire                   w_inverse_mapping_rd;

wire      [15:0]       wv_host_inpkt_cnt;
wire      [15:0]       wv_host_in_queue_discard_cnt;
wire      [15:0]       wv_host_discard_pkt_cnt;
wire      [15:0]       wv_port0_inpkt_cnt;
wire      [15:0]       wv_port0_discard_pkt_cnt;
wire      [15:0]       wv_port1_inpkt_cnt;
wire      [15:0]       wv_port1_discard_pkt_cnt;
wire      [15:0]       wv_port2_inpkt_cnt;
wire      [15:0]       wv_port2_discard_pkt_cnt;
wire      [15:0]       wv_port3_inpkt_cnt;
wire      [15:0]       wv_port3_discard_pkt_cnt;
wire      [15:0]       wv_port4_inpkt_cnt;
wire      [15:0]       wv_port4_discard_pkt_cnt;
wire      [15:0]       wv_port5_inpkt_cnt;
wire      [15:0]       wv_port5_discard_pkt_cnt;
wire      [15:0]       wv_port6_inpkt_cnt;
wire      [15:0]       wv_port6_discard_pkt_cnt;
wire      [15:0]       wv_port7_inpkt_cnt;
wire      [15:0]       wv_port7_discard_pkt_cnt;

wire      [15:0]       wv_host_outpkt_cnt;
wire      [15:0]       wv_port0_outpkt_cnt;
wire      [15:0]       wv_port1_outpkt_cnt;
wire      [15:0]       wv_port2_outpkt_cnt;
wire      [15:0]       wv_port3_outpkt_cnt;
wire      [15:0]       wv_port4_outpkt_cnt;
wire      [15:0]       wv_port5_outpkt_cnt;
wire      [15:0]       wv_port6_outpkt_cnt;
wire      [15:0]       wv_port7_outpkt_cnt; 

wire      [15:0]       wv_nmac_receive_cnt;
wire      [15:0]       wv_nmac_report_cnt;

wire      [15:0]       wv_ts_inj_underflow_error_cnt;
wire      [15:0]       wv_ts_inj_overflow_error_cnt; 
wire      [15:0]       wv_ts_sub_underflow_error_cnt;
wire      [15:0]       wv_ts_sub_overflow_error_cnt; 

wire                   w_statistic_rst; 
wire      [47:0]       wv_nmac_dmac;
wire      [47:0]       wv_nmac_smac;

wire                   w_nmac_receive_pulse;
wire                   w_nmac_report_pulse;

nmac_parse_module nmac_parse_module_inst(
.i_clk                      (i_clk),
.i_rst_n                    (i_rst_n),
                            
.iv_nmac_data               (iv_nmac_data),
.i_nmac_data_wr             (i_nmac_data_wr),

.ov_wr_command              (ov_wr_command),
.o_wr_command_wr            (o_wr_command_wr),           
                            
.ov_time_offset             (ov_time_offset),
.o_time_offset_wr           (o_time_offset_wr),
.ov_cfg_finish              (ov_cfg_finish),
.ov_port_type               (ov_port_type),
.ov_slot_len                (ov_slot_len),
.o_qbv_or_qch               (o_qbv_or_qch),
.ov_inject_slot_period      (ov_inject_slot_period),
.ov_submit_slot_period      (ov_submit_slot_period),
.ov_report_period           (ov_report_period),
.ov_offset_period           (ov_offset_period),
.ov_report_type             (wv_report_type),
.o_report_en                (w_report_en),

.ov_rc_regulation_value     (ov_rc_regulation_value),
.ov_be_regulation_value     (ov_be_regulation_value),
.ov_unmap_regulation_value  (ov_unmap_regulation_value),

.o_nmac_receive_pulse       (w_nmac_receive_pulse),       

.ov_nmac_dmac               (wv_nmac_dmac),
.ov_nmac_smac               (wv_nmac_smac),
                            
.ov_wdata                   (wdata),
.ov_waddr                   (waddr),
.ov_wr                      (wr),
       
.ov_mapping_wdata           (wv_mapping_wdata),
.ov_mapping_waddr           (wv_mapping_waddr),
.o_mapping_wr               (w_mapping_wr    ),

.ov_inverse_mapping_wdata   (wv_inverse_mapping_wdata),
.ov_inverse_mapping_waddr   (wv_inverse_mapping_waddr),
.o_inverse_mapping_wr       (w_inverse_mapping_wr    )
);

nmac_report_module nmac_report_module_inst(
.i_clk                              (i_clk),
.i_rst_n                            (i_rst_n),

.iv_nmac_dmac                       (wv_nmac_dmac),
.iv_nmac_smac                       (wv_nmac_smac),

.o_nmac_report_pulse                (w_nmac_report_pulse),   

.ov_rd_command                      (ov_rd_command),
.o_rd_command_wr                    (o_rd_command_wr), 
.iv_rd_command_ack                  (iv_rd_command_ack),  
       
.iv_host_inpkt_cnt                  (wv_host_inpkt_cnt),
.iv_host_discard_pkt_cnt            (wv_host_discard_pkt_cnt),
.iv_port0_inpkt_cnt                 (wv_port0_inpkt_cnt),
.iv_port0_discard_pkt_cnt           (wv_port0_discard_pkt_cnt),
.iv_port1_inpkt_cnt                 (wv_port1_inpkt_cnt),
.iv_port1_discard_pkt_cnt           (wv_port1_discard_pkt_cnt),
.iv_port2_inpkt_cnt                 (wv_port2_inpkt_cnt),
.iv_port2_discard_pkt_cnt           (wv_port2_discard_pkt_cnt),
.iv_port3_inpkt_cnt                 (wv_port3_inpkt_cnt),
.iv_port3_discard_pkt_cnt           (wv_port3_discard_pkt_cnt),
.iv_port4_inpkt_cnt                 (wv_port4_inpkt_cnt),
.iv_port4_discard_pkt_cnt           (wv_port4_discard_pkt_cnt),
.iv_port5_inpkt_cnt                 (wv_port5_inpkt_cnt),
.iv_port5_discard_pkt_cnt           (wv_port5_discard_pkt_cnt),
.iv_port6_inpkt_cnt                 (wv_port6_inpkt_cnt),
.iv_port6_discard_pkt_cnt           (wv_port6_discard_pkt_cnt),
.iv_port7_inpkt_cnt                 (wv_port7_inpkt_cnt),
.iv_port7_discard_pkt_cnt           (wv_port7_discard_pkt_cnt),
                                     
.iv_host_outpkt_cnt                 (wv_host_outpkt_cnt),
.iv_host_in_queue_discard_cnt       (wv_host_in_queue_discard_cnt),
.iv_port0_outpkt_cnt                (wv_port0_outpkt_cnt),
.iv_port1_outpkt_cnt                (wv_port1_outpkt_cnt),
.iv_port2_outpkt_cnt                (wv_port2_outpkt_cnt),
.iv_port3_outpkt_cnt                (wv_port3_outpkt_cnt),
.iv_port4_outpkt_cnt                (wv_port4_outpkt_cnt),
.iv_port5_outpkt_cnt                (wv_port5_outpkt_cnt),
.iv_port6_outpkt_cnt                (wv_port6_outpkt_cnt),
.iv_port7_outpkt_cnt                (wv_port7_outpkt_cnt),
                                  
.iv_nmac_receive_cnt                (wv_nmac_receive_cnt),
.iv_nmac_report_cnt                 (wv_nmac_report_cnt),

.iv_ts_inj_underflow_error_cnt      (wv_ts_inj_underflow_error_cnt),
.iv_ts_inj_overflow_error_cnt       (wv_ts_inj_overflow_error_cnt),
.iv_ts_sub_underflow_error_cnt      (wv_ts_sub_underflow_error_cnt),
.iv_ts_sub_overflow_error_cnt       (wv_ts_sub_overflow_error_cnt),

.o_statistic_rst                    (w_statistic_rst),
                                  
.ov_nmac_data                       (ov_nmac_data),
.o_nmac_data_last                   (o_nmac_data_last),
.o_namc_report_req                  (o_namc_report_req),
.i_nmac_report_ack                  (i_nmac_report_ack),
.i_report_pulse                     (i_report_pulse),

.iv_pdi_state                       (iv_pdi_state),
.iv_prp_state                       (iv_prp_state),
.iv_tom_state                       (iv_tom_state),
.iv_pkt_state                       (iv_pkt_state),
.iv_transmission_state              (iv_transmission_state),
.iv_descriptor_state                (iv_descriptor_state),
.iv_tim_state                       (iv_tim_state),
.iv_ism_state                       (iv_ism_state),

.iv_hos_state                       (iv_hos_state),
.iv_hoi_state                       (iv_hoi_state),
.iv_pkt_read_state                  (iv_pkt_read_state),
.iv_tsm_state                       (iv_tsm_state),
.iv_bufid_state                     (iv_bufid_state),
.iv_smm_state                       (iv_smm_state),

.iv_tdm_state                       (iv_tdm_state),

.iv_osc_state_p0                    (iv_osc_state_p0),
.iv_prc_state_p0                    (iv_prc_state_p0),
.iv_opc_state_p0                    (iv_opc_state_p0),
.iv_gmii_read_state_p0              (iv_gmii_read_state_p0),
.i_gmii_fifo_full_p0                (i_gmii_fifo_full_p0),
.i_gmii_fifo_empty_p0               (i_gmii_fifo_empty_p0),
.iv_descriptor_extract_state_p0     (iv_descriptor_extract_state_p0),
.iv_descriptor_send_state_p0        (iv_descriptor_send_state_p0),
.iv_data_splice_state_p0            (iv_data_splice_state_p0),
.iv_input_buf_interface_state_p0    (iv_input_buf_interface_state_p0),

.iv_osc_state_p1                    (iv_osc_state_p1),
.iv_prc_state_p1                    (iv_prc_state_p1),
.iv_opc_state_p1                    (iv_opc_state_p1),
.iv_gmii_read_state_p1              (iv_gmii_read_state_p1),
.i_gmii_fifo_full_p1                (i_gmii_fifo_full_p1),
.i_gmii_fifo_empty_p1               (i_gmii_fifo_empty_p1),
.iv_descriptor_extract_state_p1     (iv_descriptor_extract_state_p1),
.iv_descriptor_send_state_p1        (iv_descriptor_send_state_p1),
.iv_data_splice_state_p1            (iv_data_splice_state_p1),
.iv_input_buf_interface_state_p1    (iv_input_buf_interface_state_p1),

.iv_osc_state_p2                    (iv_osc_state_p2),
.iv_prc_state_p2                    (iv_prc_state_p2),
.iv_opc_state_p2                    (iv_opc_state_p2),
.iv_gmii_read_state_p2              (iv_gmii_read_state_p2),
.i_gmii_fifo_full_p2                (i_gmii_fifo_full_p2),
.i_gmii_fifo_empty_p2               (i_gmii_fifo_empty_p2),
.iv_descriptor_extract_state_p2     (iv_descriptor_extract_state_p2),
.iv_descriptor_send_state_p2        (iv_descriptor_send_state_p2),
.iv_data_splice_state_p2            (iv_data_splice_state_p2),
.iv_input_buf_interface_state_p2    (iv_input_buf_interface_state_p2),

.iv_osc_state_p3                    (iv_osc_state_p3),
.iv_prc_state_p3                    (iv_prc_state_p3),
.iv_opc_state_p3                    (iv_opc_state_p3),
.iv_gmii_read_state_p3              (iv_gmii_read_state_p3),
.i_gmii_fifo_full_p3                (i_gmii_fifo_full_p3),
.i_gmii_fifo_empty_p3               (i_gmii_fifo_empty_p3),
.iv_descriptor_extract_state_p3     (iv_descriptor_extract_state_p3),
.iv_descriptor_send_state_p3        (iv_descriptor_send_state_p3),
.iv_data_splice_state_p3            (iv_data_splice_state_p3),
.iv_input_buf_interface_state_p3    (iv_input_buf_interface_state_p3),

.iv_osc_state_p4                    (iv_osc_state_p4),
.iv_prc_state_p4                    (iv_prc_state_p4),
.iv_opc_state_p4                    (iv_opc_state_p4),
.iv_gmii_read_state_p4              (iv_gmii_read_state_p4),
.i_gmii_fifo_full_p4                (i_gmii_fifo_full_p4),
.i_gmii_fifo_empty_p4               (i_gmii_fifo_empty_p4),
.iv_descriptor_extract_state_p4     (iv_descriptor_extract_state_p4),
.iv_descriptor_send_state_p4        (iv_descriptor_send_state_p4),
.iv_data_splice_state_p4            (iv_data_splice_state_p4),
.iv_input_buf_interface_state_p4    (iv_input_buf_interface_state_p4),

.iv_osc_state_p5                    (iv_osc_state_p5),
.iv_prc_state_p5                    (iv_prc_state_p5),
.iv_opc_state_p5                    (iv_opc_state_p5),
.iv_gmii_read_state_p5              (iv_gmii_read_state_p5),
.i_gmii_fifo_full_p5                (i_gmii_fifo_full_p5),
.i_gmii_fifo_empty_p5               (i_gmii_fifo_empty_p5),
.iv_descriptor_extract_state_p5     (iv_descriptor_extract_state_p5),
.iv_descriptor_send_state_p5        (iv_descriptor_send_state_p5),
.iv_data_splice_state_p5            (iv_data_splice_state_p5),
.iv_input_buf_interface_state_p5    (iv_input_buf_interface_state_p5),

.iv_osc_state_p6                    (iv_osc_state_p6),
.iv_prc_state_p6                    (iv_prc_state_p6),
.iv_opc_state_p6                    (iv_opc_state_p6),
.iv_gmii_read_state_p6              (iv_gmii_read_state_p6),
.i_gmii_fifo_full_p6                (i_gmii_fifo_full_p6),
.i_gmii_fifo_empty_p6               (i_gmii_fifo_empty_p6),
.iv_descriptor_extract_state_p6     (iv_descriptor_extract_state_p6),
.iv_descriptor_send_state_p6        (iv_descriptor_send_state_p6),
.iv_data_splice_state_p6            (iv_data_splice_state_p6),
.iv_input_buf_interface_state_p6    (iv_input_buf_interface_state_p6),

.iv_osc_state_p7                    (iv_osc_state_p7),
.iv_prc_state_p7                    (iv_prc_state_p7),
.iv_opc_state_p7                    (iv_opc_state_p7),
.iv_gmii_read_state_p7              (iv_gmii_read_state_p7),
.i_gmii_fifo_full_p7                (i_gmii_fifo_full_p7),
.i_gmii_fifo_empty_p7               (i_gmii_fifo_empty_p7),
.iv_descriptor_extract_state_p7     (iv_descriptor_extract_state_p7),
.iv_descriptor_send_state_p7        (iv_descriptor_send_state_p7),
.iv_data_splice_state_p7            (iv_data_splice_state_p7),
.iv_input_buf_interface_state_p7    (iv_input_buf_interface_state_p7),

.iv_pkt_write_state                 (iv_pkt_write_state),
.iv_pcb_pkt_read_state              (iv_pcb_pkt_read_state),
.iv_address_write_state             (iv_address_write_state),
.iv_address_read_state              (iv_address_read_state),
.iv_free_buf_fifo_rdusedw           (iv_free_buf_fifo_rdusedw),
                                   
.iv_time_offset                     (ov_time_offset),
.iv_cfg_finish                      (ov_cfg_finish),
.iv_port_type                       (ov_port_type),
.iv_slot_len                        (ov_slot_len),
.iv_inject_slot_period              (ov_inject_slot_period),
.iv_submit_slot_period              (ov_submit_slot_period),
.i_qbv_or_qch                       (o_qbv_or_qch),
.iv_report_period                   (ov_report_period),
.iv_report_type                     (wv_report_type),
.i_report_en                        (w_report_en),
.iv_offset_period                   (ov_offset_period),
.iv_rc_regulation_value             (ov_rc_regulation_value),
.iv_be_regulation_value             (ov_be_regulation_value),
.iv_unmap_regulation_value          (ov_unmap_regulation_value),
                                  
.iv_rdata                           (rdata),
.ov_raddr                           (raddr),
.ov_rd                              (rd)
);

statistic_module statistic_module_inst(
.i_clk                              (i_clk),
.i_rst_n                            (i_rst_n),
                                    
.i_host_inpkt_pulse                 (i_host_inpkt_pulse         ),
.i_host_discard_pkt_pulse           (i_host_discard_pkt_pulse   ),
.i_port0_inpkt_pulse                (i_port0_inpkt_pulse        ),
.i_port0_discard_pkt_pulse          (i_port0_discard_pkt_pulse  ),
.i_port1_inpkt_pulse                (i_port1_inpkt_pulse        ),
.i_port1_discard_pkt_pulse          (i_port1_discard_pkt_pulse  ),
.i_port2_inpkt_pulse                (i_port2_inpkt_pulse        ),
.i_port2_discard_pkt_pulse          (i_port2_discard_pkt_pulse  ),
.i_port3_inpkt_pulse                (i_port3_inpkt_pulse        ),
.i_port3_discard_pkt_pulse          (i_port3_discard_pkt_pulse  ),
.i_port4_inpkt_pulse                (i_port4_inpkt_pulse        ),
.i_port4_discard_pkt_pulse          (i_port4_discard_pkt_pulse  ),
.i_port5_inpkt_pulse                (i_port5_inpkt_pulse        ),
.i_port5_discard_pkt_pulse          (i_port5_discard_pkt_pulse  ),
.i_port6_inpkt_pulse                (i_port6_inpkt_pulse        ),
.i_port6_discard_pkt_pulse          (i_port6_discard_pkt_pulse  ),
.i_port7_inpkt_pulse                (i_port7_inpkt_pulse        ),
.i_port7_discard_pkt_pulse          (i_port7_discard_pkt_pulse  ),
                                                                
.i_host_outpkt_pulse                (i_host_outpkt_pulse        ),
.i_host_in_queue_discard_pulse      (i_host_in_queue_discard_pulse),
.i_port0_outpkt_pulse               (i_port0_outpkt_pulse       ),
.i_port1_outpkt_pulse               (i_port1_outpkt_pulse       ),
.i_port2_outpkt_pulse               (i_port2_outpkt_pulse       ),
.i_port3_outpkt_pulse               (i_port3_outpkt_pulse       ),
.i_port4_outpkt_pulse               (i_port4_outpkt_pulse       ),
.i_port5_outpkt_pulse               (i_port5_outpkt_pulse       ),
.i_port6_outpkt_pulse               (i_port6_outpkt_pulse       ),
.i_port7_outpkt_pulse               (i_port7_outpkt_pulse       ),
                                    
.i_nmac_receive_pulse               (w_nmac_receive_pulse       ),
.i_nmac_report_pulse                (w_nmac_report_pulse        ),

.i_ts_inj_underflow_error_pulse     (i_ts_inj_underflow_error_pulse     ),
.i_ts_inj_overflow_error_pulse      (i_ts_inj_overflow_error_pulse      ),
.i_ts_sub_underflow_error_pulse     (i_ts_sub_underflow_error_pulse     ),
.i_ts_sub_overflow_error_pulse      (i_ts_sub_overflow_error_pulse      ),

.i_statistic_rst                    (w_statistic_rst),
                                    
.ov_host_inpkt_cnt                  (wv_host_inpkt_cnt),
.ov_host_in_queue_discard_cnt       (wv_host_in_queue_discard_cnt),
.ov_host_discard_pkt_cnt            (wv_host_discard_pkt_cnt),
.ov_port0_inpkt_cnt                 (wv_port0_inpkt_cnt),
.ov_port0_discard_pkt_cnt           (wv_port0_discard_pkt_cnt),
.ov_port1_inpkt_cnt                 (wv_port1_inpkt_cnt),
.ov_port1_discard_pkt_cnt           (wv_port1_discard_pkt_cnt),
.ov_port2_inpkt_cnt                 (wv_port2_inpkt_cnt),
.ov_port2_discard_pkt_cnt           (wv_port2_discard_pkt_cnt),
.ov_port3_inpkt_cnt                 (wv_port3_inpkt_cnt),
.ov_port3_discard_pkt_cnt           (wv_port3_discard_pkt_cnt),
.ov_port4_inpkt_cnt                 (wv_port4_inpkt_cnt),
.ov_port4_discard_pkt_cnt           (wv_port4_discard_pkt_cnt),
.ov_port5_inpkt_cnt                 (wv_port5_inpkt_cnt),
.ov_port5_discard_pkt_cnt           (wv_port5_discard_pkt_cnt),
.ov_port6_inpkt_cnt                 (wv_port6_inpkt_cnt),
.ov_port6_discard_pkt_cnt           (wv_port6_discard_pkt_cnt),
.ov_port7_inpkt_cnt                 (wv_port7_inpkt_cnt),
.ov_port7_discard_pkt_cnt           (wv_port7_discard_pkt_cnt),
                                     
.ov_host_outpkt_cnt                 (wv_host_outpkt_cnt),
.ov_port0_outpkt_cnt                (wv_port0_outpkt_cnt),
.ov_port1_outpkt_cnt                (wv_port1_outpkt_cnt),
.ov_port2_outpkt_cnt                (wv_port2_outpkt_cnt),
.ov_port3_outpkt_cnt                (wv_port3_outpkt_cnt),
.ov_port4_outpkt_cnt                (wv_port4_outpkt_cnt),
.ov_port5_outpkt_cnt                (wv_port5_outpkt_cnt),
.ov_port6_outpkt_cnt                (wv_port6_outpkt_cnt),
.ov_port7_outpkt_cnt                (wv_port7_outpkt_cnt),
.ov_nmac_receive_cnt                (wv_nmac_receive_cnt),
.ov_nmac_report_cnt                 (wv_nmac_report_cnt ),

.ov_ts_inj_underflow_error_cnt      (wv_ts_inj_underflow_error_cnt      ),
.ov_ts_inj_overflow_error_cnt       (wv_ts_inj_overflow_error_cnt       ),
.ov_ts_sub_underflow_error_cnt      (wv_ts_sub_underflow_error_cnt      ),
.ov_ts_sub_overflow_error_cnt       (wv_ts_sub_overflow_error_cnt       )
);

ram_interface_handle ram_interface_handle_inst(
.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),
                     
.iv_wdata              (wdata), 
.iv_waddr              (waddr),
.iv_wr                 (wr),                        
.ov_rdata              (rdata),
.iv_raddr              (raddr),
.iv_rd                 (rd),

.iv_mapping_wdata        (wv_mapping_wdata),
.iv_mapping_waddr        (wv_mapping_waddr),
.i_mapping_wr            (w_mapping_wr    ),
.ov_mapping_rdata        (wv_mapping_rdata),
.iv_mapping_raddr        (wv_mapping_raddr),
.i_mapping_rd            (w_mapping_rd    ),

.iv_inverse_mapping_wdata(wv_inverse_mapping_wdata),
.iv_inverse_mapping_waddr(wv_inverse_mapping_waddr),
.i_inverse_mapping_wr    (w_inverse_mapping_wr    ),
.ov_inverse_mapping_rdata(wv_inverse_mapping_rdata),
.iv_inverse_mapping_raddr(wv_inverse_mapping_raddr),
.i_inverse_mapping_rd    (w_inverse_mapping_rd    ),

.ov_tss_ram_addr       (ov_tss_ram_addr),
.ov_tss_ram_wdata      (ov_tss_ram_wdata),
.o_tss_ram_wr          (o_tss_ram_wr),
.iv_tss_ram_rdata      (iv_tss_ram_rdata),
.o_tss_ram_rd          (o_tss_ram_rd),
                        
.ov_tis_ram_addr       (ov_tis_ram_addr),
.ov_tis_ram_wdata      (ov_tis_ram_wdata),
.o_tis_ram_wr          (o_tis_ram_wr),
.iv_tis_ram_rdata      (iv_tis_ram_rdata),
.o_tis_ram_rd          (o_tis_ram_rd),
                        
.ov_flt_ram_addr       (ov_flt_ram_addr),
.ov_flt_ram_wdata      (ov_flt_ram_wdata),
.o_flt_ram_wr          (o_flt_ram_wr),
.iv_flt_ram_rdata      (iv_flt_ram_rdata),
.o_flt_ram_rd          (o_flt_ram_rd),
                        
.ov_qgc0_ram_addr      (ov_qgc0_ram_addr),
.ov_qgc0_ram_wdata     (ov_qgc0_ram_wdata),
.o_qgc0_ram_wr         (o_qgc0_ram_wr),
.iv_qgc0_ram_rdata     (iv_qgc0_ram_rdata),
.o_qgc0_ram_rd         (o_qgc0_ram_rd),
                        
.ov_qgc1_ram_addr      (ov_qgc1_ram_addr),
.ov_qgc1_ram_wdata     (ov_qgc1_ram_wdata),
.o_qgc1_ram_wr         (o_qgc1_ram_wr),
.iv_qgc1_ram_rdata     (iv_qgc1_ram_rdata),
.o_qgc1_ram_rd         (o_qgc1_ram_rd),
                        
.ov_qgc2_ram_addr      (ov_qgc2_ram_addr),
.ov_qgc2_ram_wdata     (ov_qgc2_ram_wdata),
.o_qgc2_ram_wr         (o_qgc2_ram_wr),
.iv_qgc2_ram_rdata     (iv_qgc2_ram_rdata),
.o_qgc2_ram_rd         (o_qgc2_ram_rd),
                        
.ov_qgc3_ram_addr      (ov_qgc3_ram_addr),
.ov_qgc3_ram_wdata     (ov_qgc3_ram_wdata),
.o_qgc3_ram_wr         (o_qgc3_ram_wr),
.iv_qgc3_ram_rdata     (iv_qgc3_ram_rdata),
.o_qgc3_ram_rd         (o_qgc3_ram_rd),
                        
.ov_qgc4_ram_addr      (ov_qgc4_ram_addr),
.ov_qgc4_ram_wdata     (ov_qgc4_ram_wdata),
.o_qgc4_ram_wr         (o_qgc4_ram_wr),
.iv_qgc4_ram_rdata     (iv_qgc4_ram_rdata),
.o_qgc4_ram_rd         (o_qgc4_ram_rd),
                        
.ov_qgc5_ram_addr      (ov_qgc5_ram_addr),
.ov_qgc5_ram_wdata     (ov_qgc5_ram_wdata),
.o_qgc5_ram_wr         (o_qgc5_ram_wr),
.iv_qgc5_ram_rdata     (iv_qgc5_ram_rdata),
.o_qgc5_ram_rd         (o_qgc5_ram_rd),
                        
.ov_qgc6_ram_addr      (ov_qgc6_ram_addr),
.ov_qgc6_ram_wdata     (ov_qgc6_ram_wdata),
.o_qgc6_ram_wr         (o_qgc6_ram_wr),
.iv_qgc6_ram_rdata     (iv_qgc6_ram_rdata),
.o_qgc6_ram_rd         (o_qgc6_ram_rd),
                        
.ov_qgc7_ram_addr      (ov_qgc7_ram_addr),
.ov_qgc7_ram_wdata     (ov_qgc7_ram_wdata),
.o_qgc7_ram_wr         (o_qgc7_ram_wr),
.iv_qgc7_ram_rdata     (iv_qgc7_ram_rdata),
.o_qgc7_ram_rd         (o_qgc7_ram_rd)
);

endmodule

  

