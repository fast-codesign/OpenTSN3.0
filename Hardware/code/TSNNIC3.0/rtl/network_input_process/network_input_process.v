// Copyright (C) 1953-2020 NUDT
// Verilog module name - network_input_process  
// Version: NIP_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         Network input process
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module network_input_process #(parameter inport = 4'b0000,from_hcp_or_scp = 2'b01)//{scp,hcp}
    (
        clk_sys,
        reset_n,
        i_gmii_rst_n,

        clk_gmii_rx,
        i_gmii_dv,
        iv_gmii_rxd,
        i_gmii_er,
        
        timer_rst,
        port_type,
        cfg_finish,
        
        i_pkt_bufid_wr,
        iv_pkt_bufid,
        o_pkt_bufid_ack,

        o_descriptor_wr_to_host,
        o_descriptor_wr_to_hcp,
        o_descriptor_wr_to_network,
        ov_descriptor,
        o_inverse_map_lookup_flag,
        i_descriptor_ack,

        ov_pkt,
        o_pkt_wr,
        ov_pkt_bufadd,
        i_pkt_ack,
        
        iv_free_bufid_fifo_rdusedw,
        iv_be_threshold_value,
        iv_rc_threshold_value,
        iv_map_req_threshold_value,
        
        o_inpkt_pulse,          
        o_discard_pkt_pulse,
        o_fifo_underflow_pulse,
        o_fifo_overflow_pulse,
     
        ov_gmii_read_state,        
        o_gmii_fifo_full,           
        o_gmii_fifo_empty,
        ov_descriptor_extract_state,
        ov_descriptor_send_state,   
        ov_data_splice_state,        
        ov_input_buf_interface_state
    );

// I/O
// clk & rst
input                   clk_sys;
input                   reset_n;
input                   i_gmii_rst_n;

//GMII RX input
input                   clk_gmii_rx;
input                   i_gmii_dv;
input       [7:0]       iv_gmii_rxd;
input                   i_gmii_er;
//timer reset pusle
input                   timer_rst;
//configuration
input                   port_type;  //0:network interface,input mapped pkt; 1:terminal interface,input standard pkt.
input       [1:0]       cfg_finish; //00:receive NMAC pkt;01:receive NMAC/PTP pkt;10:receive all pkt.
//pkt bufid input
input                   i_pkt_bufid_wr;
input       [8:0]       iv_pkt_bufid;
output                  o_pkt_bufid_ack;
//descriptor output
output                  o_descriptor_wr_to_host;
output                  o_descriptor_wr_to_hcp;
output                  o_descriptor_wr_to_network;
output      [56:0]      ov_descriptor;
output                  o_inverse_map_lookup_flag;
input                   i_descriptor_ack;
//user data output
output      [133:0]     ov_pkt;
output                  o_pkt_wr;
output      [15:0]      ov_pkt_bufadd;
input                   i_pkt_ack;  

input       [8:0]       iv_free_bufid_fifo_rdusedw;
input       [8:0]       iv_be_threshold_value;
input       [8:0]       iv_rc_threshold_value;
input       [8:0]       iv_map_req_threshold_value;

output                  o_inpkt_pulse;         
output                  o_discard_pkt_pulse;
output                  o_fifo_underflow_pulse;
output                  o_fifo_overflow_pulse;
                        
output     [1:0]        ov_gmii_read_state;       
output                  o_gmii_fifo_full;           
output                  o_gmii_fifo_empty;
output     [3:0]        ov_descriptor_extract_state;
output     [1:0]        ov_descriptor_send_state;   
output     [1:0]        ov_data_splice_state;        
output     [1:0]        ov_input_buf_interface_state;

// internal wire
wire        [8:0]       data_nrx2fpa;
wire                    data_wr_nrx2fpa;
wire        [18:0]      ts_nrx2fpa;
wire        [133:0]     pkt_fpa2ibi;
wire                    pkt_wr_fpa2ibi;
wire        [8:0]       pkt_bufid_fpa2ibi;
wire                    pkt_bufid_wr_fpa2ibi;

network_rx network_rx_inst
    (
        .clk_sys(clk_sys),
        .reset_n(reset_n),
        .i_gmii_rst_n(i_gmii_rst_n),

        .port_type(port_type),
        .cfg_finish(cfg_finish),
        
        .clk_gmii_rx(clk_gmii_rx),
        .i_gmii_dv(i_gmii_dv),
        .iv_gmii_rxd(iv_gmii_rxd),
        .i_gmii_er(i_gmii_er),     
        .timer_rst(timer_rst),

        .ov_data(data_nrx2fpa),
        .o_data_wr(data_wr_nrx2fpa),
        .ov_rec_ts(ts_nrx2fpa),
        
        .o_pkt_valid_pulse(o_inpkt_pulse),
        .gmii_fifo_rdfull(o_gmii_fifo_full),
        .gmii_fifo_empty(o_gmii_fifo_empty),
        .gmii_read_state(ov_gmii_read_state),
        .o_fifo_overflow_pulse(o_fifo_overflow_pulse),
        .o_fifo_underflow_pulse(o_fifo_underflow_pulse)
    );

frame_parser #(.inport(inport),.from_hcp_or_scp(from_hcp_or_scp)) frame_parser_inst
    (
        .clk_sys(clk_sys),
        .reset_n(reset_n),
       
        .iv_data(data_nrx2fpa),
        .i_data_wr(data_wr_nrx2fpa),
        .iv_rec_ts(ts_nrx2fpa),
        .port_type(port_type),      
        .i_pkt_bufid_wr(i_pkt_bufid_wr),
        .iv_pkt_bufid(iv_pkt_bufid),
        .o_pkt_bufid_ack(o_pkt_bufid_ack),
        
        .ov_pkt(pkt_fpa2ibi),
        .o_pkt_wr(pkt_wr_fpa2ibi),

        .o_pkt_bufid_wr(pkt_bufid_wr_fpa2ibi),
        .ov_pkt_bufid(pkt_bufid_fpa2ibi),
        .o_descriptor_wr_to_host(o_descriptor_wr_to_host),
        .o_descriptor_wr_to_hcp(o_descriptor_wr_to_hcp),
        .o_descriptor_wr_to_network(o_descriptor_wr_to_network),          
        .ov_descriptor(ov_descriptor),
        .o_inverse_map_lookup_flag(o_inverse_map_lookup_flag),
        .i_descriptor_ack(i_descriptor_ack),
        
        .free_bufid_fifo_rdusedw(iv_free_bufid_fifo_rdusedw),
        .be_threshold_value1(iv_be_threshold_value),
        .rc_threshold_value2(iv_rc_threshold_value),
        .map_req_threshold_value3(iv_map_req_threshold_value),
        
        .o_pkt_discard_pulse(o_discard_pkt_pulse),
        .descriptor_extract_state(ov_descriptor_extract_state),
        .descriptor_send_state(ov_descriptor_send_state),  
        .data_splice_state(ov_data_splice_state),
        .ov_debug_cnt()        
    );

input_buffer_interface  input_buffer_interface_inst
    (
        .clk_sys(clk_sys),
        .reset_n(reset_n),
        .i_pkt_wr(pkt_wr_fpa2ibi),
        .iv_pkt(pkt_fpa2ibi),

        .i_pkt_bufid_wr(pkt_bufid_wr_fpa2ibi),
        .iv_pkt_bufid(pkt_bufid_fpa2ibi),
        .ov_pkt(ov_pkt),
        .o_pkt_wr(o_pkt_wr),
        .ov_pkt_bufadd(ov_pkt_bufadd),
        .i_pkt_ack(i_pkt_ack),
        .input_buf_interface_state(ov_input_buf_interface_state)
    );
endmodule