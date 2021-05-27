// Copyright (C) 1953-2020 NUDT
// Verilog module name - time_slot_calculation 
// Version: TSC_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         calculation of time slot 
//             - calculate time slot according to syned global time and time slot length.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module tester_3_0_top
(
       i_core_clk,
       i_rst_n,

	   i_gmii_rxclk_p0,
	   i_gmii_rxdv_p0,
	   iv_gmii_rxd_p0,
	   i_gmii_rxer_p0,            
	   ov_gmii_txd_p0,
	   o_gmii_txen_p0,
	   o_gmii_txer_p0,
	   o_gmii_txclk_p0,  
       
	   i_gmii_rxclk_p1,
	   i_gmii_rxdv_p1,
	   iv_gmii_rxd_p1,
	   i_gmii_rxer_p1,            
	   ov_gmii_txd_p1,
	   o_gmii_txen_p1,
	   o_gmii_txer_p1,
	   o_gmii_txclk_p1,  
       
	   i_gmii_rxclk_p2,
	   i_gmii_rxdv_p2,
	   iv_gmii_rxd_p2,
	   i_gmii_rxer_p2,            
	   ov_gmii_txd_p2,
	   o_gmii_txen_p2,
	   o_gmii_txer_p2,
	   o_gmii_txclk_p2,         
              
	   i_gmii_rxclk_p3,
	   i_gmii_rxdv_p3,
	   iv_gmii_rxd_p3,
	   i_gmii_rxer_p3,            
	   ov_gmii_txd_p3,
	   o_gmii_txen_p3,
	   o_gmii_txer_p3,
	   o_gmii_txclk_p3,

       o_s_pulse       
);

input  	            i_core_clk;
input  	            i_rst_n;

input  	            i_gmii_rxclk_p0;
input  	            i_gmii_rxdv_p0;
input  	   [7:0]    iv_gmii_rxd_p0;
input  	            i_gmii_rxer_p0;            
output     [7:0]    ov_gmii_txd_p0;
output    	        o_gmii_txen_p0;
output    	        o_gmii_txer_p0;
output    	        o_gmii_txclk_p0; 

input  	            i_gmii_rxclk_p1;
input  	            i_gmii_rxdv_p1;
input  	   [7:0]    iv_gmii_rxd_p1;
input  	            i_gmii_rxer_p1;            
output     [7:0]    ov_gmii_txd_p1;
output    	        o_gmii_txen_p1;
output    	        o_gmii_txer_p1;
output    	        o_gmii_txclk_p1; 

input  	            i_gmii_rxclk_p2;
input  	            i_gmii_rxdv_p2;
input  	   [7:0]    iv_gmii_rxd_p2;
input  	            i_gmii_rxer_p2;            
output     [7:0]    ov_gmii_txd_p2;
output    	        o_gmii_txen_p2;
output    	        o_gmii_txer_p2;
output   	        o_gmii_txclk_p2; 

input  	            i_gmii_rxclk_p3;
input  	            i_gmii_rxdv_p3;
input  	   [7:0]    iv_gmii_rxd_p3;
input  	            i_gmii_rxer_p3;            
output     [7:0]    ov_gmii_txd_p3;
output    	        o_gmii_txen_p3;
output    	        o_gmii_txer_p3;
output    	        o_gmii_txclk_p3; 

output              o_s_pulse;
//adp2tsnchip 
wire				w_gmii_dv_p0_adp2tsnchip;
wire	[7:0]		wv_gmii_rxd_p0_adp2tsnchip;
wire				w_gmii_er_p0_adp2tsnchip;

wire				w_gmii_dv_p1_adp2tsnchip;
wire	[7:0]		wv_gmii_rxd_p1_adp2tsnchip;
wire				w_gmii_er_p1_adp2tsnchip;

wire				w_gmii_dv_p2_adp2tsnchip;
wire	[7:0]		wv_gmii_rxd_p2_adp2tsnchip;
wire				w_gmii_er_p2_adp2tsnchip;

wire				w_gmii_dv_p3_adp2tsnchip;
wire	[7:0]		wv_gmii_rxd_p3_adp2tsnchip;
wire				w_gmii_er_p3_adp2tsnchip;

//tsnchip2adp
wire    [7:0] 	    wv_gmii_txd_p0_tsnchip2adp;
wire    		 	w_gmii_tx_en_p0_tsnchip2adp;
wire    		 	w_gmii_tx_er_p0_tsnchip2adp;
        
wire    [7:0] 	    wv_gmii_txd_p1_tsnchip2adp;
wire    		 	w_gmii_tx_en_p1_tsnchip2adp;
wire    		 	w_gmii_tx_er_p1_tsnchip2adp;
        
wire    [7:0] 	    wv_gmii_txd_p2_tsnchip2adp;
wire    		 	w_gmii_tx_en_p2_tsnchip2adp;
wire    		 	w_gmii_tx_er_p2_tsnchip2adp;

wire    [7:0] 	    wv_gmii_txd_p3_tsnchip2adp;
wire    		 	w_gmii_tx_en_p3_tsnchip2adp;
wire    		 	w_gmii_tx_er_p3_tsnchip2adp;
//po_rx to um
wire    [133:0]     wv_data_iip02um;
wire    [18:0]      wv_relative_time_iip02um;
wire			    w_data_wr_iip02um;
wire	            w_fifo_overflow_pulse_iip02um;
wire	            w_fifo_underflow_pulse_iip02um;
//p1_rx to um
wire    [133:0]     wv_data_iip12um;
wire    [18:0]      wv_relative_time_iip12um;
wire			    w_data_wr_iip12um;
wire	            w_fifo_overflow_pulse_iip12um;
wire	            w_fifo_underflow_pulse_iip12um;
//p2_rx to um
wire    [133:0]     wv_data_iip22um;
wire    [18:0]      wv_relative_time_iip22um;
wire			    w_data_wr_iip22um;
wire	            w_fifo_overflow_pulse_iip22um;
wire	            w_fifo_underflow_pulse_iip22um;
//p3_rx to um
wire    [133:0]     wv_data_iip32um;
wire    [18:0]      wv_relative_time_iip32um;
wire			    w_data_wr_iip32um;
wire	            w_fifo_overflow_pulse_iip32um;
wire	            w_fifo_underflow_pulse_iip32um;
//um to p0/p1/p2/p3 rx
wire                w_timer_rst;
wire    [47:0]      wv_syned_global_time;
//um to port
wire    	[133:0]   wv_data_um2p0;
wire    		      w_data_um2p0_wr;
wire        [6:0]     wv_fifo_usedw_p02um;

wire    	[133:0]   wv_data_um2p1;
wire    		      w_data_um2p1_wr;
wire        [6:0]     wv_fifo_usedw_p12um;

wire    	[133:0]   wv_data_um2p2;
wire    		      w_data_um2p2_wr;
wire        [6:0]     wv_fifo_usedw_p22um;

wire    	[133:0]   wv_data_um2p3;
wire    		      w_data_um2p3_wr;
wire        [6:0]     wv_fifo_usedw_p32um;

assign o_gmii_txclk_p0 = i_gmii_rxclk_p0;
assign o_gmii_txclk_p1 = i_gmii_rxclk_p1;
assign o_gmii_txclk_p2 = i_gmii_rxclk_p2;
assign o_gmii_txclk_p3 = i_gmii_rxclk_p3;

wire                  w_core_rst_n;
wire                  w_gmii_rst_n_p0;
wire                  w_gmii_rst_n_p1;
wire                  w_gmii_rst_n_p2;
wire                  w_gmii_rst_n_p3;
reset_sync core_reset_sync(
.i_clk(i_core_clk),
.i_rst_n(i_rst_n),

.o_rst_n_sync(w_core_rst_n)   
);

reset_sync gmii_p0_reset_sync(
.i_clk(i_gmii_rxclk_p0),
.i_rst_n(i_rst_n),

.o_rst_n_sync(w_gmii_rst_n_p0)   
);

reset_sync gmii_p1_reset_sync(
.i_clk(i_gmii_rxclk_p1),
.i_rst_n(i_rst_n),

.o_rst_n_sync(w_gmii_rst_n_p1)   
);

reset_sync gmii_p2_reset_sync(
.i_clk(i_gmii_rxclk_p2),
.i_rst_n(i_rst_n),

.o_rst_n_sync(w_gmii_rst_n_p2)   
);

reset_sync gmii_p3_reset_sync(
.i_clk(i_gmii_rxclk_p3),
.i_rst_n(i_rst_n),

.o_rst_n_sync(w_gmii_rst_n_p3)   
);

gmii_adapter gmii_adapter_p0_inst(
.gmii_rxclk(i_gmii_rxclk_p0),
.gmii_txclk(i_gmii_rxclk_p0),

.rst_n(w_gmii_rst_n_p0),    
.port_type(1'b1),

.gmii_rx_dv(i_gmii_rxdv_p0),
.gmii_rx_er(i_gmii_rxer_p0),
.gmii_rxd(iv_gmii_rxd_p0),

.gmii_rx_dv_adp2tsnchip(w_gmii_dv_p0_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(w_gmii_er_p0_adp2tsnchip),
.gmii_rxd_adp2tsnchip(wv_gmii_rxd_p0_adp2tsnchip),

.gmii_tx_en(o_gmii_txen_p0),
.gmii_tx_er(o_gmii_txer_p0),
.gmii_txd(ov_gmii_txd_p0),

.gmii_tx_en_tsnchip2adp(w_gmii_tx_en_p0_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(w_gmii_tx_er_p0_tsnchip2adp),
.gmii_txd_tsnchip2adp(wv_gmii_txd_p0_tsnchip2adp)
);

gmii_adapter gmii_adapter_p1_inst(
.gmii_rxclk(i_gmii_rxclk_p1),
.gmii_txclk(i_gmii_rxclk_p1),

.rst_n(w_gmii_rst_n_p1),    
.port_type(1'b1),

.gmii_rx_dv(i_gmii_rxdv_p1),
.gmii_rx_er(i_gmii_rxer_p1),
.gmii_rxd(iv_gmii_rxd_p1),

.gmii_rx_dv_adp2tsnchip(w_gmii_dv_p1_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(w_gmii_er_p1_adp2tsnchip),
.gmii_rxd_adp2tsnchip(wv_gmii_rxd_p1_adp2tsnchip),

.gmii_tx_en(o_gmii_txen_p1),
.gmii_tx_er(o_gmii_txer_p1),
.gmii_txd(ov_gmii_txd_p1),

.gmii_tx_en_tsnchip2adp(w_gmii_tx_en_p1_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(w_gmii_tx_er_p1_tsnchip2adp),
.gmii_txd_tsnchip2adp(wv_gmii_txd_p1_tsnchip2adp)
);

gmii_adapter gmii_adapter_p2_inst(
.gmii_rxclk(i_gmii_rxclk_p2),
.gmii_txclk(i_gmii_rxclk_p2),

.rst_n(w_gmii_rst_n_p2),    
.port_type(1'b1),

.gmii_rx_dv(i_gmii_rxdv_p2),
.gmii_rx_er(i_gmii_rxer_p2),
.gmii_rxd(iv_gmii_rxd_p2),

.gmii_rx_dv_adp2tsnchip(w_gmii_dv_p2_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(w_gmii_er_p2_adp2tsnchip),
.gmii_rxd_adp2tsnchip(wv_gmii_rxd_p2_adp2tsnchip),

.gmii_tx_en(o_gmii_txen_p2),
.gmii_tx_er(o_gmii_txer_p2),
.gmii_txd(ov_gmii_txd_p2),

.gmii_tx_en_tsnchip2adp(w_gmii_tx_en_p2_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(w_gmii_tx_er_p2_tsnchip2adp),
.gmii_txd_tsnchip2adp(wv_gmii_txd_p2_tsnchip2adp)
);

gmii_adapter gmii_adapter_p3_inst(
.gmii_rxclk(i_gmii_rxclk_p3),
.gmii_txclk(i_gmii_rxclk_p3),

.rst_n(w_gmii_rst_n_p3),    
.port_type(1'b1),

.gmii_rx_dv(i_gmii_rxdv_p3),
.gmii_rx_er(i_gmii_rxer_p3),
.gmii_rxd(iv_gmii_rxd_p3),

.gmii_rx_dv_adp2tsnchip(w_gmii_dv_p3_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(w_gmii_er_p3_adp2tsnchip),
.gmii_rxd_adp2tsnchip(wv_gmii_rxd_p3_adp2tsnchip),

.gmii_tx_en(o_gmii_txen_p3),
.gmii_tx_er(o_gmii_txer_p3),
.gmii_txd(ov_gmii_txd_p3),

.gmii_tx_en_tsnchip2adp(w_gmii_tx_en_p3_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(w_gmii_tx_er_p3_tsnchip2adp),
.gmii_txd_tsnchip2adp(wv_gmii_txd_p3_tsnchip2adp)
);

interface_input_process interface_input_process_p0_inst(
.i_clk(i_core_clk),
.i_rst_n(w_core_rst_n),
.i_gmii_rst_n(w_gmii_rst_n_p0), 

.i_timer_rst(w_timer_rst),
.iv_syned_global_time(wv_syned_global_time),

.clk_gmii_rx(i_gmii_rxclk_p0),
.i_gmii_dv(w_gmii_dv_p0_adp2tsnchip),
.iv_gmii_rxd(wv_gmii_rxd_p0_adp2tsnchip),
.i_gmii_er(w_gmii_er_p0_adp2tsnchip),	   

.ov_data(wv_data_iip02um),
.ov_relative_time(wv_relative_time_iip02um),
.o_data_wr(w_data_wr_iip02um),
.o_fifo_overflow_pulse(w_fifo_overflow_pulse_iip02um),
.o_fifo_underflow_pulse(w_fifo_underflow_pulse_iip02um)
);
interface_input_process interface_input_process_p1_inst(
.i_clk(i_core_clk),
.i_rst_n(w_core_rst_n),
.i_gmii_rst_n(w_gmii_rst_n_p1), 

.i_timer_rst(w_timer_rst),
.iv_syned_global_time(wv_syned_global_time),

.clk_gmii_rx(i_gmii_rxclk_p1),
.i_gmii_dv(w_gmii_dv_p1_adp2tsnchip),
.iv_gmii_rxd(wv_gmii_rxd_p1_adp2tsnchip),
.i_gmii_er(w_gmii_er_p1_adp2tsnchip),	   

.ov_data(wv_data_iip12um),
.ov_relative_time(wv_relative_time_iip12um),
.o_data_wr(w_data_wr_iip12um),
.o_fifo_overflow_pulse(w_fifo_overflow_pulse_iip12um),
.o_fifo_underflow_pulse(w_fifo_underflow_pulse_iip12um)
);
interface_input_process interface_input_process_p2_inst(
.i_clk(i_core_clk),
.i_rst_n(w_core_rst_n),
.i_gmii_rst_n(w_gmii_rst_n_p2), 

.i_timer_rst(w_timer_rst),
.iv_syned_global_time(wv_syned_global_time),

.clk_gmii_rx(i_gmii_rxclk_p2),
.i_gmii_dv(w_gmii_dv_p2_adp2tsnchip),
.iv_gmii_rxd(wv_gmii_rxd_p2_adp2tsnchip),
.i_gmii_er(w_gmii_er_p2_adp2tsnchip),	   

.ov_data(wv_data_iip22um),
.ov_relative_time(wv_relative_time_iip22um),
.o_data_wr(w_data_wr_iip22um),
.o_fifo_overflow_pulse(w_fifo_overflow_pulse_iip22um),
.o_fifo_underflow_pulse(w_fifo_underflow_pulse_iip22um)
);
interface_input_process interface_input_process_p3_inst(
.i_clk(i_core_clk),
.i_rst_n(w_core_rst_n),
.i_gmii_rst_n(w_gmii_rst_n_p3), 

.i_timer_rst(w_timer_rst),
.iv_syned_global_time(wv_syned_global_time),

.clk_gmii_rx(i_gmii_rxclk_p3),
.i_gmii_dv(w_gmii_dv_p3_adp2tsnchip),
.iv_gmii_rxd(wv_gmii_rxd_p3_adp2tsnchip),
.i_gmii_er(w_gmii_er_p3_adp2tsnchip),	   

.ov_data(wv_data_iip32um),
.ov_relative_time(wv_relative_time_iip32um),
.o_data_wr(w_data_wr_iip32um),
.o_fifo_overflow_pulse(w_fifo_overflow_pulse_iip32um),
.o_fifo_underflow_pulse(w_fifo_underflow_pulse_iip32um)
);
um um_inst(
.clk(i_core_clk),
.rst_n(w_core_rst_n), 

.ov_dmac(),
.ov_smac(), 
.o_time_slot_switch(),
.ov_time_slot(), 
.o_timer_rst(w_timer_rst),
.ov_syned_global_time(wv_syned_global_time),
.o_s_pulse(o_s_pulse),
// port02um
.iv_data_wr_p0(w_data_wr_iip02um),
.iv_data_p0(wv_data_iip02um),
.iv_relative_time_p0(wv_relative_time_iip02um),

.ov_data_p0(wv_data_um2p0),
.o_data_wr_p0(w_data_um2p0_wr),
.iv_fifo_usedw_p0(wv_fifo_usedw_p02um),     
// port12um
.iv_data_wr_p1(w_data_wr_iip12um),
.iv_data_p1(wv_data_iip12um),
.iv_relative_time_p1(wv_relative_time_iip12um),

.ov_data_p1(wv_data_um2p1),
.o_data_wr_p1(w_data_um2p1_wr),
.iv_fifo_usedw_p1(wv_fifo_usedw_p12um),    
// port22um
.iv_data_wr_p2(w_data_wr_iip22um),
.iv_data_p2(wv_data_iip22um),
.iv_relative_time_p2(wv_relative_time_iip22um),

.ov_data_p2(wv_data_um2p2),
.o_data_wr_p2(w_data_um2p2_wr),
.iv_fifo_usedw_p2(wv_fifo_usedw_p22um),   
// port32um
.iv_data_wr_p3(w_data_wr_iip32um),
.iv_data_p3(wv_data_iip32um),
.iv_relative_time_p3(wv_relative_time_iip32um),

.ov_data_p3(wv_data_um2p3),
.o_data_wr_p3(w_data_um2p3_wr),
.iv_fifo_usedw_p3(wv_fifo_usedw_p32um)
);
interface_output_process interface_output_process_p0_inst
(
.i_clk(i_core_clk),
.i_rst_n(w_core_rst_n),

.i_gmii_clk(i_gmii_rxclk_p0),
.i_gmii_rst_n(w_gmii_rst_n_p0), 

.i_timer_rst(w_timer_rst),
.iv_syned_global_time(wv_syned_global_time),
.iv_data(wv_data_um2p0),
.i_data_wr(w_data_um2p0_wr),
.ov_fifo_usedw(wv_fifo_usedw_p02um),        

.ov_gmii_txd(wv_gmii_txd_p0_tsnchip2adp),
.o_gmii_tx_en(w_gmii_tx_en_p0_tsnchip2adp),
.o_gmii_tx_er(w_gmii_tx_er_p0_tsnchip2adp),
.o_gmii_tx_clk(),

.o_fifo_overflow_pulse(),
.o_fifo_underflow_pulse() 
);

interface_output_process interface_output_process_p1_inst
(
.i_clk(i_core_clk),
.i_rst_n(w_core_rst_n),

.i_gmii_clk(i_gmii_rxclk_p1),
.i_gmii_rst_n(w_gmii_rst_n_p1), 

.i_timer_rst(w_timer_rst),
.iv_syned_global_time(wv_syned_global_time),
.iv_data(wv_data_um2p1),
.i_data_wr(w_data_um2p1_wr),
.ov_fifo_usedw(wv_fifo_usedw_p12um),        

.ov_gmii_txd(wv_gmii_txd_p1_tsnchip2adp),
.o_gmii_tx_en(w_gmii_tx_en_p1_tsnchip2adp),
.o_gmii_tx_er(w_gmii_tx_er_p1_tsnchip2adp),
.o_gmii_tx_clk(),

.o_fifo_overflow_pulse(),
.o_fifo_underflow_pulse() 
);

interface_output_process interface_output_process_p2_inst
(
.i_clk(i_core_clk),
.i_rst_n(w_core_rst_n),

.i_gmii_clk(i_gmii_rxclk_p2),
.i_gmii_rst_n(w_gmii_rst_n_p2), 

.i_timer_rst(w_timer_rst),
.iv_syned_global_time(wv_syned_global_time),
.iv_data(wv_data_um2p2),
.i_data_wr(w_data_um2p2_wr),
.ov_fifo_usedw(wv_fifo_usedw_p22um),        

.ov_gmii_txd(wv_gmii_txd_p2_tsnchip2adp),
.o_gmii_tx_en(w_gmii_tx_en_p2_tsnchip2adp),
.o_gmii_tx_er(w_gmii_tx_er_p2_tsnchip2adp),
.o_gmii_tx_clk(),

.o_fifo_overflow_pulse(),
.o_fifo_underflow_pulse() 
);

interface_output_process interface_output_process_p3_inst
(
.i_clk(i_core_clk),
.i_rst_n(w_core_rst_n),

.i_gmii_clk(i_gmii_rxclk_p3),
.i_gmii_rst_n(w_gmii_rst_n_p3), 

.i_timer_rst(w_timer_rst),
.iv_syned_global_time(wv_syned_global_time),
.iv_data(wv_data_um2p3),
.i_data_wr(w_data_um2p3_wr),
.ov_fifo_usedw(wv_fifo_usedw_p32um),        

.ov_gmii_txd(wv_gmii_txd_p3_tsnchip2adp),
.o_gmii_tx_en(w_gmii_tx_en_p3_tsnchip2adp),
.o_gmii_tx_er(w_gmii_tx_er_p3_tsnchip2adp),
.o_gmii_tx_clk(),

.o_fifo_overflow_pulse(),
.o_fifo_underflow_pulse() 
);
endmodule