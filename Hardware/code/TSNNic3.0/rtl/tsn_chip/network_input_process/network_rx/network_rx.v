// Copyright (C) 1953-2020 NUDT
// Verilog module name - network_rx 
// Version: NRX_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         Network receive interface
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module network_rx
(
        clk_sys,
        reset_n,
        i_gmii_rst_n,

        port_type,
        cfg_finish,
        
        clk_gmii_rx,
        i_gmii_dv,
        iv_gmii_rxd,
        i_gmii_er,     
        timer_rst,

        ov_data,
        o_data_wr,
        ov_rec_ts,  
        
        o_pkt_valid_pulse,
        gmii_fifo_rdfull,
        gmii_fifo_empty,
        gmii_read_state,

        o_fifo_overflow_pulse,
        o_fifo_underflow_pulse        
);

// I/O
// clk & rst
input                   clk_sys;
input                   reset_n;
input                   i_gmii_rst_n;
//configuration
input                   port_type;  //0:input mapped pkt; 1:input standard pkt.
input       [1:0]       cfg_finish; //00:receive NMAC pkt;01:receive NMAC/PTP pkt;10:receive all pkt.
//GMII input
input                   clk_gmii_rx;
input                   i_gmii_dv;
input       [7:0]       iv_gmii_rxd;
input                   i_gmii_er;
//timer reset pusle
input                   timer_rst;
//user data output
output      [8:0]       ov_data;
output                  o_data_wr;
output      [18:0]      ov_rec_ts;

//state
output                  o_pkt_valid_pulse;
output                  gmii_fifo_rdfull;
output                  gmii_fifo_empty;
output      [1:0]       gmii_read_state;

output                  o_fifo_overflow_pulse;
output                  o_fifo_underflow_pulse;
// internal wire
wire        [8:0]       data_gwr2fifo;
wire                    data_wr_gwr2fifo;
wire        [8:0]       data_fifo2grd;
wire                    data_rd_grd2fifo;
wire        [18:0]      timer;
wire                    gmii_fifo_full;

gmii_write gmii_write_inst
    (
        .clk_gmii_rx(clk_gmii_rx),
        .reset_n(i_gmii_rst_n),
       
        .i_gmii_dv(i_gmii_dv),
        .iv_gmii_rxd(iv_gmii_rxd),
        .i_gmii_er(i_gmii_er),
        
        .ov_data(data_gwr2fifo),
        .o_data_wr(data_wr_gwr2fifo),
        .i_data_full(gmii_fifo_full),
        .o_gmii_er(),
        .o_fifo_overflow_pulse(o_fifo_overflow_pulse)
    );
    
gmii_read gmii_read_inst
    (
        .clk_sys(clk_sys),
        .reset_n(reset_n),
 
        .port_type(port_type),
        .cfg_finish(cfg_finish),
        
        .iv_data(data_fifo2grd),
        .o_data_rd(data_rd_grd2fifo),
        .i_data_empty(gmii_fifo_empty),
        .timer(timer),
        
        .ov_data(ov_data),
        .o_data_wr(o_data_wr),
        .ov_rec_ts(ov_rec_ts),
        .o_pkt_valid_pulse(o_pkt_valid_pulse),
        .report_gmii_read_state(gmii_read_state),
        .o_fifo_underflow_pulse(o_fifo_underflow_pulse)
    );
    
ASFIFO_9_16  ASFIFO_9_16_inst
    (        
    .wr_aclr(~i_gmii_rst_n),          //Reset the all signal
    .rd_aclr(~reset_n),
    .data(data_gwr2fifo),             //The Inport of data 
    .rdreq(data_rd_grd2fifo),         //active-high
    .wrclk(clk_gmii_rx),              //ASYNC WriteClk(), SYNC use wrclk
    .rdclk(clk_sys),                  //ASYNC WriteClk(), SYNC use wrclk  
    .wrreq(data_wr_gwr2fifo),         //active-high
    .q(data_fifo2grd),                //The output of data
    .wrfull(gmii_fifo_full),          //Write domain full 
    .wralfull(),                      //Write domain almost-full
    .wrempty(),                       //Write domain empty
    .wralempty(),                     //Write domain almost-full  
    .rdfull(gmii_fifo_rdfull),        //Read domain full
    .rdalfull(),                      //Read domain almost-full   
    .rdempty(gmii_fifo_empty),        //Read domain empty
    .rdalempty(),                     //Read domain almost-empty
    .wrusedw(),                       //Write-usedword
    .rdusedw()          
    );

timer timer_inst
    (
        .clk_sys(clk_sys),
        .reset_n(reset_n),
        .timer_rst(timer_rst),
        .timer(timer)
    );
endmodule