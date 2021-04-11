// Copyright (C) 1953-2020 NUDT
// Verilog module name - frame_parser
// Version: FPA_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         Frame Phase 
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module frame_parser #(parameter inport = 4'b0000,from_hcp_or_scp = 2'b01)//{scp,hcp}
    (
        clk_sys,
        reset_n,
       
        iv_data,
        i_data_wr,
        iv_rec_ts,
        port_type,      
        i_pkt_bufid_wr,
        iv_pkt_bufid,
        o_pkt_bufid_ack,
        
        ov_pkt,
        o_pkt_wr,
        o_pkt_bufid_wr,
        ov_pkt_bufid,
        o_descriptor_wr_to_host,
        o_descriptor_wr_to_hcp,
        o_descriptor_wr_to_network,
        ov_descriptor,
        o_inverse_map_lookup_flag,
        i_descriptor_ack,
        
        //for discarding pkt while the fifo_used_findows is over the threshold 
        free_bufid_fifo_rdusedw,
        be_threshold_value1,
        rc_threshold_value2,
        map_req_threshold_value3,

        
        o_pkt_discard_pulse,
        descriptor_extract_state,
        descriptor_send_state,
        data_splice_state,
        ov_debug_cnt
    );

// I/O
// clk & rst
input                   clk_sys;
input                   reset_n;
//input
input       [8:0]       iv_data;
input                   i_data_wr;
input       [18:0]      iv_rec_ts;
input                   port_type;
input                   i_pkt_bufid_wr;
input       [8:0]       iv_pkt_bufid;
output                  o_pkt_bufid_ack;

//temp ov_descriptor and ov_pkt for discarding pkt while the fifo_used_findows is over the threshold 
input       [8:0]       free_bufid_fifo_rdusedw;
input       [8:0]       be_threshold_value1;
input       [8:0]       rc_threshold_value2;
input       [8:0]       map_req_threshold_value3;

//output
output                  o_pkt_wr;
output      [133:0]     ov_pkt;
output                  o_pkt_bufid_wr;
output      [8:0]       ov_pkt_bufid;
output                  o_descriptor_wr_to_host;
output                  o_descriptor_wr_to_hcp;
output                  o_descriptor_wr_to_network;
output      [56:0]      ov_descriptor;
output                  o_inverse_map_lookup_flag;
input                   i_descriptor_ack; 

//state
output                  o_pkt_discard_pulse;
output     [3:0]        descriptor_extract_state;
output     [1:0]        descriptor_send_state;
output     [1:0]        data_splice_state;  

//internal wire
wire        [8:0]       data_dee2das;
wire                    data_wr_dee2das;
wire                    descriptor_valid_dat2des;
wire        [56:0]      descriptor_dat2des;
wire        [15:0]      wv_eth_type_dat2des;

descriptor_extract  #(.inport(inport)) descriptor_extract_inst
    (
        .clk_sys(clk_sys),
        .reset_n(reset_n),
       
        .iv_data(iv_data),
        .i_data_wr(i_data_wr),
        .iv_rec_ts(iv_rec_ts),
        
        .free_bufid_fifo_rdusedw(free_bufid_fifo_rdusedw),
        .be_threshold_value1(be_threshold_value1),
        .rc_threshold_value2(rc_threshold_value2),
        .map_req_threshold_value3(map_req_threshold_value3),
        .port_type(port_type),
        .o_pkt_discard_pulse(o_pkt_discard_pulse),
        
        .ov_data(data_dee2das),
        .o_data_wr(data_wr_dee2das),
        .o_descriptor_valid(descriptor_valid_dat2des),
        .ov_descriptor(descriptor_dat2des),
        .ov_eth_type(wv_eth_type_dat2des),
        .descriptor_extract_state(descriptor_extract_state)
    );  
    
descriptor_send #(.from_hcp_or_scp(from_hcp_or_scp)) descriptor_send_inst
    (
        .clk_sys(clk_sys),
        .reset_n(reset_n),
        .i_pkt_bufid_wr(i_pkt_bufid_wr),
        .iv_pkt_bufid(iv_pkt_bufid),
        .i_descriptor_valid(descriptor_valid_dat2des),
        .iv_descriptor(descriptor_dat2des),
        .iv_eth_type(wv_eth_type_dat2des),        
        .o_pkt_bufid_ack(o_pkt_bufid_ack),  
        .o_pkt_bufid_wr(o_pkt_bufid_wr),
        .ov_pkt_bufid(ov_pkt_bufid),
        .o_descriptor_wr_to_host(o_descriptor_wr_to_host),
        .o_descriptor_wr_to_hcp(o_descriptor_wr_to_hcp),
        .o_descriptor_wr_to_network(o_descriptor_wr_to_network),        
        .ov_descriptor(ov_descriptor),
        .o_inverse_map_lookup_flag(o_inverse_map_lookup_flag),
        .i_descriptor_ack(i_descriptor_ack),

        .descriptor_send_state(descriptor_send_state)
    );

data_splice data_splice_inst
    (
        .clk_sys(clk_sys),
        .reset_n(reset_n),
        .i_data_wr(data_wr_dee2das),
        .iv_data(data_dee2das),
        .o_pkt_wr(o_pkt_wr),
        .ov_pkt(ov_pkt),
        .data_splice_state(data_splice_state)
    ); 
output reg [15:0] ov_debug_cnt;  
always @(posedge clk_sys or negedge reset_n) begin
    if(!reset_n) begin
        ov_debug_cnt <= 16'b0;
    end
    else begin
        if(o_pkt_bufid_ack)begin
            ov_debug_cnt <= ov_debug_cnt + 1'b1;
        end
        else begin
            ov_debug_cnt <= ov_debug_cnt;
        end
    end
end	    
endmodule