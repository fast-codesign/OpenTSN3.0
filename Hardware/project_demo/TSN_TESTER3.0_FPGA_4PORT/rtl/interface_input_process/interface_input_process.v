// Copyright (C) 1953-2020 NUDT
// Verilog module name - HRI 
// Version: HRI_V1.0
// Created:
//         by - peng jintao 
//         at - 06.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         receive pkt from host
//             - top module
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module interface_input_process
(
		i_clk,
		i_rst_n,
        i_gmii_rst_n, 
        
        i_timer_rst,
        iv_syned_global_time,

		clk_gmii_rx,
		i_gmii_dv,
		iv_gmii_rxd,
		i_gmii_er,	   

		ov_data,
        ov_relative_time,
		o_data_wr,
        o_fifo_overflow_pulse,
        o_fifo_underflow_pulse
);

// I/O
// clk & rst
input                  	i_clk;
input                  	i_rst_n;
input                   i_gmii_rst_n;

//timer reset pusle
input                   i_timer_rst;
input       [47:0]      iv_syned_global_time;
//GMII input
input					clk_gmii_rx;
input					i_gmii_dv;
input		[7:0]		iv_gmii_rxd;
input					i_gmii_er;
//data output
output		[133:0]     ov_data;
output      [18:0]      ov_relative_time;
output			      	o_data_wr;
//fifo overflow/underflow
output	                o_fifo_overflow_pulse;
output	                o_fifo_underflow_pulse;
// internal wire
wire		[8:0]		data_gwr2fifo;
wire					data_wr_gwr2fifo;
wire					data_full_fifo2gwr;
wire		[8:0]		data_fifo2grd;
wire					data_rd_grd2fifo;
wire					data_empty_fifo2grd;

wire        [18:0]      wv_relative_time_timer2grd;
//grd-iwt
wire        [18:0]      wv_relative_time_grd2iwt;
wire        [47:0]      wv_global_time_grd2iwt;

wire		[8:0]		data_grd2iwt;
wire					data_wr_grd2iwt;
//iwt-fifo
wire        [133:0]     wv_data_iwt2fifo;
wire                    w_data_wr_iwt2fifo;     
wire        [30:0]      wv_time_length_iwt2fifo;
wire                    w_time_length_wr_iwt2fifo;

wire        [30:0]      wv_time_length_fifo2frc;
wire                    w_time_length_fifo_rd_frc2fifo;
wire                    w_time_length_fifo_empty_fifo2frc;
//fifo-frc
wire		[133:0]		data_fifo2frc;
wire					data_rd_frc2fifo;
wire					data_empty_fifo2frc;
gmii_write gmii_write_inst
(
.clk_gmii_rx(clk_gmii_rx),
.reset_n(i_gmii_rst_n),

.i_gmii_dv(i_gmii_dv),
.iv_gmii_rxd(iv_gmii_rxd),
.i_gmii_er(i_gmii_er),

.ov_data(data_gwr2fifo),
.o_data_wr(data_wr_gwr2fifo),
.i_data_full(data_full_fifo2gwr),
.o_gmii_er(),
.o_fifo_overflow_pulse(o_fifo_overflow_pulse)
);

fifo_w9d16_respectclock_aclr_showahead  asynfifo_9_16_inst
(
.data    (data_gwr2fifo),    //  fifo_input.datain
.wrreq   (data_wr_gwr2fifo),   //            .wrreq
.rdreq   (data_rd_grd2fifo),   //            .rdreq
.wrclk   (clk_gmii_rx),   //            .wrclk
.rdclk   (i_clk),   //            .rdclk
.aclr    (~i_rst_n),    //            .aclr
.q       (data_fifo2grd),       // fifo_output.dataout
.rdusedw (), //            .rdusedw
.wrusedw (), //            .wrusedw
.rdfull  (),  //            .rdfull
.rdempty (data_empty_fifo2grd), //            .rdempty
.wrfull  (data_full_fifo2gwr),  //            .wrfull
.wrempty ()  //            .wrempty
);	

gmii_read gmii_read_inst
(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_relative_time(wv_relative_time_timer2grd),
.iv_syned_global_time(iv_syned_global_time),
.ov_relative_time(wv_relative_time_grd2iwt),
.ov_global_time(wv_global_time_grd2iwt),

.iv_data(data_fifo2grd),
.o_data_rd(data_rd_grd2fifo),
.i_data_empty(data_empty_fifo2grd),
.ov_data(data_grd2iwt),
.o_data_wr(data_wr_grd2iwt),
.o_fifo_underflow_pulse(o_fifo_underflow_pulse)
);

timer timer_inst
(
.clk_sys(i_clk),
.reset_n(i_rst_n),
.timer_rst(i_timer_rst),
.timer(wv_relative_time_timer2grd)
);

input_width_transform input_width_transform_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_data(data_grd2iwt),
.i_data_wr(data_wr_grd2iwt),
.iv_relative_time(wv_relative_time_grd2iwt),
.iv_global_time(wv_global_time_grd2iwt),

.ov_data(wv_data_iwt2fifo),
.o_data_wr(w_data_wr_iwt2fifo),

.ov_time_length(wv_time_length_iwt2fifo),
.o_time_length_wr(w_time_length_wr_iwt2fifo)
);

fifo_w134d128_commonclock_sclr_showahead pkt_fifo_inst(
.data(wv_data_iwt2fifo),  //  fifo_input.datain
.wrreq(w_data_wr_iwt2fifo), //            .wrreq
.rdreq(data_rd_frc2fifo), //            .rdreq
.sclr(!i_rst_n),
.clock(i_clk), //            .clk
.q(data_fifo2frc),     // fifo_output.dataout
.usedw(), //            .usedw
.full(),  //            .full
.empty(data_empty_fifo2frc)  //            .empty
);

fifo_w31d4_commonclock_sclr_showahead cache_time_length_inst(
.data(wv_time_length_iwt2fifo),  //  fifo_input.datain
.wrreq(w_time_length_wr_iwt2fifo), //            .wrreq
.rdreq(w_time_length_fifo_rd_frc2fifo), //            .rdreq
.sclr(!i_rst_n),
.clock(i_clk), //            .clk
.q(wv_time_length_fifo2frc),     // fifo_output.dataout
.usedw(), //            .usedw
.full(),  //            .full
.empty(w_time_length_fifo_empty_fifo2frc)  //            .empty
);
pkt_read pkt_read_inst(
.i_clk(i_clk),
.i_rst_n(i_rst_n),

.iv_pkt_data(data_fifo2frc),
.o_pkt_data_rd(data_rd_frc2fifo),
.i_pkt_data_empty(data_empty_fifo2frc),

.iv_time_length(wv_time_length_fifo2frc),
.o_time_length_rd(w_time_length_fifo_rd_frc2fifo),
.i_time_length_fifo_empty(w_time_length_fifo_empty_fifo2frc),

.ov_data(ov_data),
.ov_relative_time(ov_relative_time),
.o_data_wr(o_data_wr)
);
endmodule