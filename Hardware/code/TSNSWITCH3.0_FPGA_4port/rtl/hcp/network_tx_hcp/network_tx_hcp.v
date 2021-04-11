// Copyright (C) 1953-2020 NUDT
// Verilog module name - network_tx_hcp 
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

module network_tx_hcp
(
       i_clk,
       i_rst_n,
       
       i_gmii_clk,
       i_gmii_rst_n,
                     
       iv_pkt_data,
       i_pkt_data_wr,
       
       ov_gmii_txd,
       o_gmii_tx_en,
       o_gmii_tx_er,
       o_gmii_tx_clk,
       
       i_timer_rst,
       
       ov_opc_state,

       o_fifo_overflow_pulse,
	   ov_debug_ts_cnt,
);

// I/O
// clk & rst
input                  i_clk;                   //125Mhz
input                  i_rst_n;

input                  i_gmii_clk;                   
input                  i_gmii_rst_n;


input      [8:0]       iv_pkt_data;    
input                  i_pkt_data_wr;
// send pkt data from gmii     
output     [7:0]       ov_gmii_txd;
output                 o_gmii_tx_en;
output                 o_gmii_tx_er;
output                 o_gmii_tx_clk;
// local timer rst signal
input                  i_timer_rst;  

output                 o_fifo_overflow_pulse;
              
output    [2:0]        ov_opc_state; 

// read requst signal and send data finish signal  
wire                   w_pkt_rd_req;
wire                   w_pkt_tx_finish; 

wire      [7:0]        wv_pkt_data_opc2cfs;
wire                   w_pkt_data_wr_opc2cfs;   

output_control_hcp output_control_hcp_inst(
.i_clk                 (i_clk),
.i_rst_n               (i_rst_n),
                      
.iv_data           (iv_pkt_data),
.i_data_wr         (i_pkt_data_wr),
 
.ov_data           (wv_pkt_data_opc2cfs),
.o_data_wr         (w_pkt_data_wr_opc2cfs),

.i_timer_rst           (i_timer_rst)
);

cross_clock_domain_hcp cross_clock_domain_hcp_inst(
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
output reg [15:0] ov_debug_ts_cnt; 

always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_debug_ts_cnt <= 16'b0;
    end
    else begin
        if(i_pkt_data_wr && (iv_pkt_data[8] == 1'b1) && (iv_pkt_data[7:5] <= 3'h2))begin
            ov_debug_ts_cnt <= ov_debug_ts_cnt + 1'b1;
        end
        else begin
            ov_debug_ts_cnt <= ov_debug_ts_cnt;
        end
    end
end	

endmodule