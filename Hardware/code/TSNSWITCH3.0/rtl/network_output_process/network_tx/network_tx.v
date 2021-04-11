// Copyright (C) 1953-2020 NUDT
// Verilog module name - network_tx 
// Version: NTX_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         receive pkt_bufid,and convert it into read address
//         read pkt data from pkt_centralize_bufm_memory on the basis of read address
//         parse pkt,and calculates and updatas the transparent clock for PTP
//         send pkt data from gmii
//         one network interface have one network_tx 
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module network_tx
(
       i_clk,
       i_rst_n,
       
       i_gmii_clk,
       i_gmii_rst_n,
              
       iv_pkt_bufid,
       i_pkt_bufid_wr,
       o_pkt_bufid_ack,
       
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
       
       ov_prc_state,
       ov_opc_state,
       
       o_outpkt_pulse,
       o_fifo_overflow_pulse
);

// I/O
// clk & rst
input                  i_clk;                   //125Mhz
input                  i_rst_n;

input                  i_gmii_clk;              //125Mhz
input                  i_gmii_rst_n;
// pkt_bufid from network_output_schedule                 
input      [8:0]       iv_pkt_bufid;            //the id of pkt cached in the bufm_memory   
input                  i_pkt_bufid_wr;          
output                 o_pkt_bufid_ack;
// pkt_bufid to pkt_centralize_bufm_memory in order to release pkt_bufid
output     [8:0]       ov_pkt_bufid;
output                 o_pkt_bufid_wr;
input                  i_pkt_bufid_ack; 
// read address to pkt_centralize_bufm_memory in order to read pkt data       
output     [15:0]      ov_pkt_raddr;
output                 o_pkt_rd;
input                  i_pkt_raddr_ack;
// receive pkt data from pkt_centralize_bufm_memory 
input      [133:0]     iv_pkt_data;
input                  i_pkt_data_wr;
// send pkt data from gmii     
output     [7:0]       ov_gmii_txd;
output                 o_gmii_tx_en;
output                 o_gmii_tx_er;
output                 o_gmii_tx_clk;
// local timer rst signal
input                  i_timer_rst;  
output                 o_outpkt_pulse;

output                 o_fifo_overflow_pulse;

output    [1:0]        ov_prc_state;                 
output    [2:0]        ov_opc_state; 

// read requst signal and send data finish signal  
wire                   w_pkt_rd_req;
wire                   w_pkt_tx_finish; 

wire      [7:0]        wv_pkt_data_opc2cfs;
wire                   w_pkt_data_wr_opc2cfs;   

assign o_outpkt_pulse = i_pkt_bufid_ack;
pkt_read_control pkt_read_control_inst(
.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),
                       
.iv_pkt_bufid          (iv_pkt_bufid),
.i_pkt_bufid_wr        (i_pkt_bufid_wr),
.o_pkt_bufid_ack       (o_pkt_bufid_ack),
                       
.ov_pkt_bufid          (ov_pkt_bufid),
.o_pkt_bufid_wr        (o_pkt_bufid_wr),
.i_pkt_bufid_ack       (i_pkt_bufid_ack),
                       
.ov_pkt_raddr          (ov_pkt_raddr),
.o_pkt_rd              (o_pkt_rd),
.i_pkt_raddr_ack       (i_pkt_raddr_ack),
                       
.i_pkt_rd_req          (w_pkt_rd_req),
.i_pkt_tx_finish       (w_pkt_tx_finish),

.ov_prc_state          (ov_prc_state)
);

output_control output_control_inst(
.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),
                      
.iv_pkt_data           (iv_pkt_data),
.i_pkt_data_wr         (i_pkt_data_wr),
                       
.o_pkt_rd_req          (w_pkt_rd_req),
.o_pkt_tx_finish       (w_pkt_tx_finish),
 
.ov_pkt_data           (wv_pkt_data_opc2cfs),
.o_pkt_data_wr         (w_pkt_data_wr_opc2cfs),
    
.ov_opc_state          (ov_opc_state),
.i_timer_rst           (i_timer_rst)
);

cross_clock_domain cross_clock_domain_inst(
.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),
                       
.i_gmii_clk            (i_gmii_clk),
.i_gmii_rst_n          (i_gmii_rst_n),
                       
.iv_pkt_data           (wv_pkt_data_opc2cfs),
.i_pkt_data_wr         (w_pkt_data_wr_opc2cfs),

.o_fifo_overflow_pulse (o_fifo_overflow_pulse),
                       
.ov_gmii_txd           (ov_gmii_txd),
.o_gmii_tx_en          (o_gmii_tx_en),
.o_gmii_tx_er          (o_gmii_tx_er),
.o_gmii_tx_clk         (o_gmii_tx_clk)
);

endmodule