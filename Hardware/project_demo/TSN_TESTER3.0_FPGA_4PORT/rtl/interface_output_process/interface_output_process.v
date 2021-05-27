// Copyright (C) 1953-2020 NUDT
// Verilog module name - interface_output_process 
// Version: interface_output_process_V1.0
// Created:
//         by - jintao peng
//         at - 08.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//          
//             - top module
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module interface_output_process
(
		i_clk,
		i_rst_n,
        
        i_gmii_clk,
        i_gmii_rst_n, 

        i_timer_rst,
        iv_syned_global_time,
        iv_data,
	    i_data_wr,
        ov_fifo_usedw,        

	    ov_gmii_txd,
	    o_gmii_tx_en,
	    o_gmii_tx_er,
	    o_gmii_tx_clk,

        o_fifo_overflow_pulse,
        o_fifo_underflow_pulse 
);

// I/O
// clk & rst
input                  	i_clk;
input                  	i_rst_n;
input                   i_gmii_clk;
input                   i_gmii_rst_n;

input                   i_timer_rst;
input       [47:0]      iv_syned_global_time;
//data output
input		[133:0]     iv_data;
input			      	i_data_wr;
output      [6:0]       ov_fifo_usedw;
// send pkt data from gmii	   
output      [7:0]       ov_gmii_txd;
output                  o_gmii_tx_en;
output                  o_gmii_tx_er;
output                  o_gmii_tx_clk;
//pulse output
output                  o_fifo_overflow_pulse;
output                  o_fifo_underflow_pulse;

//fifo-owt
wire        [133:0]     wv_pkt_data_fifo2owt;
wire                    w_pkt_data_empty_fifo2owt;
wire                    w_pkt_data_rd_owt2fifo;
//owt-ccd
wire        [7:0]       wv_pkt_data;
wire                    w_pkt_data_wr;

fifo_w134d128_commonclock_sclr_showahead fifo_134_128_inst(
.data(iv_data),  //  fifo_input.datain
.wrreq(i_data_wr), //            .wrreq
.rdreq(w_pkt_data_rd_owt2fifo), //            .rdreq
.sclr(!i_rst_n),
.clock(i_clk), //            .clk
.q(wv_pkt_data_fifo2owt),     // fifo_output.dataout
.usedw(ov_fifo_usedw), //            .usedw
.full(),  //            .full
.empty(w_pkt_data_empty_fifo2owt)  //            .empty
);
output_width_transform output_width_transform_inst
(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_syned_global_time(iv_syned_global_time),
.i_timer_rst(i_timer_rst),  
.iv_pkt_data(wv_pkt_data_fifo2owt),
.o_pkt_data_rd(w_pkt_data_rd_owt2fifo),
.i_pkt_data_empty(w_pkt_data_empty_fifo2owt),

.ov_data(wv_pkt_data),
.o_data_wr(w_pkt_data_wr)   
);

clock_domain_cross clock_domain_cross_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.i_gmii_clk(i_gmii_clk),
.i_gmii_rst_n(i_gmii_rst_n),
      
.iv_pkt_data(wv_pkt_data),
.i_pkt_data_wr(w_pkt_data_wr),

.o_fifo_overflow_pulse(o_fifo_overflow_pulse),
.o_fifo_underflow_pulse(o_fifo_underflow_pulse),

.ov_gmii_txd(ov_gmii_txd),
.o_gmii_tx_en(o_gmii_tx_en),
.o_gmii_tx_er(o_gmii_tx_er),
.o_gmii_tx_clk(o_gmii_tx_clk) 
);
endmodule