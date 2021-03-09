// Copyright (C) 1953-2020 NUDT
// Verilog module name - gmii_adapter_top 
// Version: GAD_TOP_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//        top of gmii_adapter
//               
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module gmii_adapter_top
(
    i_gmii_rxclk_p0,
    i_gmii_rxclk_p1,
    i_gmii_rxclk_p2,
    i_gmii_rxclk_p3,
    i_gmii_rxclk_p4,

    i_gmii_rst_n_p0,
    i_gmii_rst_n_p1,
    i_gmii_rst_n_p2,
    i_gmii_rst_n_p3,
    i_gmii_rst_n_p4,


    i_port0_type_sync_tsnchip2adp,
    i_port1_type_sync_tsnchip2adp,
    i_port2_type_sync_tsnchip2adp,
    i_port3_type_sync_tsnchip2adp,
    i_port4_type_sync_tsnchip2adp,


//port0    
    i_gmii_dv_p0,
    i_gmii_er_p0,
    iv_gmii_rxd_p0,
    o_gmii_tx_en_p0,
    o_gmii_tx_er_p0,
    ov_gmii_txd_p0,
    
    i_gmii_tx_en_p0_tsnchip2adp,
    i_gmii_tx_er_p0_tsnchip2adp,
    iv_gmii_txd_p0_tsnchip2adp,
    o_gmii_dv_p0_adp2tsnchip,
    o_gmii_er_p0_adp2tsnchip,
    ov_gmii_rxd_p0_adp2tsnchip,
    
//port1    
    i_gmii_dv_p1,
    i_gmii_er_p1,
    iv_gmii_rxd_p1,
    o_gmii_tx_en_p1,
    o_gmii_tx_er_p1,
    ov_gmii_txd_p1,
        
    i_gmii_tx_en_p1_tsnchip2adp,
    i_gmii_tx_er_p1_tsnchip2adp,
    iv_gmii_txd_p1_tsnchip2adp,
    o_gmii_dv_p1_adp2tsnchip,
    o_gmii_er_p1_adp2tsnchip,
    ov_gmii_rxd_p1_adp2tsnchip,

//port2   
    i_gmii_dv_p2,
    i_gmii_er_p2,
    iv_gmii_rxd_p2,
    o_gmii_tx_en_p2,
    o_gmii_tx_er_p2,
    ov_gmii_txd_p2,
        
    i_gmii_tx_en_p2_tsnchip2adp,
    i_gmii_tx_er_p2_tsnchip2adp,
    iv_gmii_txd_p2_tsnchip2adp,
    o_gmii_dv_p2_adp2tsnchip,
    o_gmii_er_p2_adp2tsnchip,
    ov_gmii_rxd_p2_adp2tsnchip,
 
//port3   
    i_gmii_dv_p3,
    i_gmii_er_p3,
    iv_gmii_rxd_p3,
    o_gmii_tx_en_p3,
    o_gmii_tx_er_p3,
    ov_gmii_txd_p3,
        
    i_gmii_tx_en_p3_tsnchip2adp,
    i_gmii_tx_er_p3_tsnchip2adp,
    iv_gmii_txd_p3_tsnchip2adp,
    o_gmii_dv_p3_adp2tsnchip,
    o_gmii_er_p3_adp2tsnchip,
    ov_gmii_rxd_p3_adp2tsnchip,

//port4   
    i_gmii_dv_p4,
    i_gmii_er_p4,
    iv_gmii_rxd_p4,
    o_gmii_tx_en_p4,
    o_gmii_tx_er_p4,
    ov_gmii_txd_p4,
        
    i_gmii_tx_en_p4_tsnchip2adp,
    i_gmii_tx_er_p4_tsnchip2adp,
    iv_gmii_txd_p4_tsnchip2adp,
    o_gmii_dv_p4_adp2tsnchip,
    o_gmii_er_p4_adp2tsnchip,
    ov_gmii_rxd_p4_adp2tsnchip
);

//I/O
input                   i_gmii_rxclk_p0;
input                   i_gmii_rxclk_p1;
input                   i_gmii_rxclk_p2;
input                   i_gmii_rxclk_p3;
input                   i_gmii_rxclk_p4;

input                   i_gmii_rst_n_p0;
input                   i_gmii_rst_n_p1;
input                   i_gmii_rst_n_p2;
input                   i_gmii_rst_n_p3;
input                   i_gmii_rst_n_p4;

input                   i_port0_type_sync_tsnchip2adp;
input                   i_port1_type_sync_tsnchip2adp;
input                   i_port2_type_sync_tsnchip2adp;
input                   i_port3_type_sync_tsnchip2adp;
input                   i_port4_type_sync_tsnchip2adp;
                                                     
//port0    
input                   i_gmii_dv_p0;
input                   i_gmii_er_p0;
input      [7:0]        iv_gmii_rxd_p0;
output                  o_gmii_tx_en_p0;
output                  o_gmii_tx_er_p0;
output     [7:0]        ov_gmii_txd_p0;
    
input                   i_gmii_tx_en_p0_tsnchip2adp;
input                   i_gmii_tx_er_p0_tsnchip2adp;
input      [7:0]        iv_gmii_txd_p0_tsnchip2adp;
output                  o_gmii_dv_p0_adp2tsnchip;
output                  o_gmii_er_p0_adp2tsnchip;
output     [7:0]        ov_gmii_rxd_p0_adp2tsnchip;
    
//port1    
input                   i_gmii_dv_p1;
input                   i_gmii_er_p1;
input      [7:0]        iv_gmii_rxd_p1;
output                  o_gmii_tx_en_p1;
output                  o_gmii_tx_er_p1;
output     [7:0]        ov_gmii_txd_p1;
        
input                   i_gmii_tx_en_p1_tsnchip2adp;
input                   i_gmii_tx_er_p1_tsnchip2adp;
input      [7:0]        iv_gmii_txd_p1_tsnchip2adp;
output                  o_gmii_dv_p1_adp2tsnchip;
output                  o_gmii_er_p1_adp2tsnchip;
output     [7:0]        ov_gmii_rxd_p1_adp2tsnchip;

//port2   
input                   i_gmii_dv_p2;
input                   i_gmii_er_p2;
input      [7:0]        iv_gmii_rxd_p2;
output                  o_gmii_tx_en_p2;
output                  o_gmii_tx_er_p2;
output     [7:0]        ov_gmii_txd_p2;
        
input                   i_gmii_tx_en_p2_tsnchip2adp;
input                   i_gmii_tx_er_p2_tsnchip2adp;
input      [7:0]        iv_gmii_txd_p2_tsnchip2adp;
output                  o_gmii_dv_p2_adp2tsnchip;
output                  o_gmii_er_p2_adp2tsnchip;
output     [7:0]        ov_gmii_rxd_p2_adp2tsnchip;
 
//port3   
input                   i_gmii_dv_p3;
input                   i_gmii_er_p3;
input      [7:0]        iv_gmii_rxd_p3;
output                  o_gmii_tx_en_p3;
output                  o_gmii_tx_er_p3;
output     [7:0]        ov_gmii_txd_p3;
        
input                   i_gmii_tx_en_p3_tsnchip2adp;
input                   i_gmii_tx_er_p3_tsnchip2adp;
input      [7:0]        iv_gmii_txd_p3_tsnchip2adp;
output                  o_gmii_dv_p3_adp2tsnchip;
output                  o_gmii_er_p3_adp2tsnchip;
output     [7:0]        ov_gmii_rxd_p3_adp2tsnchip;

//port4   
input                   i_gmii_dv_p4;
input                   i_gmii_er_p4;
input      [7:0]        iv_gmii_rxd_p4;
output                  o_gmii_tx_en_p4;
output                  o_gmii_tx_er_p4;
output     [7:0]        ov_gmii_txd_p4;
        
input                   i_gmii_tx_en_p4_tsnchip2adp;
input                   i_gmii_tx_er_p4_tsnchip2adp;
input      [7:0]        iv_gmii_txd_p4_tsnchip2adp;
output                  o_gmii_dv_p4_adp2tsnchip;
output                  o_gmii_er_p4_adp2tsnchip;
output     [7:0]        ov_gmii_rxd_p4_adp2tsnchip;


gmii_adapter gmii_adapter_p0(

.gmii_rxclk(i_gmii_rxclk_p0),
.gmii_txclk(i_gmii_rxclk_p0),

.rst_n(i_gmii_rst_n_p0),

.port_type(i_port0_type_sync_tsnchip2adp),

.gmii_rx_dv(i_gmii_dv_p0),
.gmii_rx_er(i_gmii_er_p0),
.gmii_rxd  (iv_gmii_rxd_p0),

.gmii_rx_dv_adp2tsnchip(o_gmii_dv_p0_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(o_gmii_er_p0_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (ov_gmii_rxd_p0_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p0),
.gmii_tx_er(o_gmii_tx_er_p0),
.gmii_txd  (ov_gmii_txd_p0),

.gmii_tx_en_tsnchip2adp(i_gmii_tx_en_p0_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(i_gmii_tx_er_p0_tsnchip2adp),
.gmii_txd_tsnchip2adp  (iv_gmii_txd_p0_tsnchip2adp)

);

gmii_adapter gmii_adapter_p1(

.gmii_rxclk(i_gmii_rxclk_p1),
.gmii_txclk(i_gmii_rxclk_p1),

.rst_n(i_gmii_rst_n_p1),

.port_type(i_port1_type_sync_tsnchip2adp),

.gmii_rx_dv(i_gmii_dv_p1),
.gmii_rx_er(i_gmii_er_p1),
.gmii_rxd  (iv_gmii_rxd_p1),

.gmii_rx_dv_adp2tsnchip(o_gmii_dv_p1_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(o_gmii_er_p1_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (ov_gmii_rxd_p1_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p1),
.gmii_tx_er(o_gmii_tx_er_p1),
.gmii_txd  (ov_gmii_txd_p1),

.gmii_tx_en_tsnchip2adp(i_gmii_tx_en_p1_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(i_gmii_tx_er_p1_tsnchip2adp),
.gmii_txd_tsnchip2adp  (iv_gmii_txd_p1_tsnchip2adp)

);

gmii_adapter gmii_adapter_p2(

.gmii_rxclk(i_gmii_rxclk_p2),
.gmii_txclk(i_gmii_rxclk_p2),

.rst_n(i_gmii_rst_n_p2),

.port_type(i_port2_type_sync_tsnchip2adp),

.gmii_rx_dv(i_gmii_dv_p2),
.gmii_rx_er(i_gmii_er_p2),
.gmii_rxd  (iv_gmii_rxd_p2),

.gmii_rx_dv_adp2tsnchip(o_gmii_dv_p2_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(o_gmii_er_p2_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (ov_gmii_rxd_p2_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p2),
.gmii_tx_er(o_gmii_tx_er_p2),
.gmii_txd  (ov_gmii_txd_p2),

.gmii_tx_en_tsnchip2adp(i_gmii_tx_en_p2_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(i_gmii_tx_er_p2_tsnchip2adp),
.gmii_txd_tsnchip2adp  (iv_gmii_txd_p2_tsnchip2adp)

);

gmii_adapter gmii_adapter_p3(

.gmii_rxclk(i_gmii_rxclk_p3),
.gmii_txclk(i_gmii_rxclk_p3),

.rst_n(i_gmii_rst_n_p3),

.port_type(i_port3_type_sync_tsnchip2adp),

.gmii_rx_dv(i_gmii_dv_p3),
.gmii_rx_er(i_gmii_er_p3),
.gmii_rxd  (iv_gmii_rxd_p3),

.gmii_rx_dv_adp2tsnchip(o_gmii_dv_p3_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(o_gmii_er_p3_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (ov_gmii_rxd_p3_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p3),
.gmii_tx_er(o_gmii_tx_er_p3),
.gmii_txd  (ov_gmii_txd_p3),

.gmii_tx_en_tsnchip2adp(i_gmii_tx_en_p3_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(i_gmii_tx_er_p3_tsnchip2adp),
.gmii_txd_tsnchip2adp  (iv_gmii_txd_p3_tsnchip2adp)

);

gmii_adapter gmii_adapter_p4(

.gmii_rxclk(i_gmii_rxclk_p4),
.gmii_txclk(i_gmii_rxclk_p4),

.rst_n(i_gmii_rst_n_p4),

.port_type(i_port4_type_sync_tsnchip2adp),

.gmii_rx_dv(i_gmii_dv_p4),
.gmii_rx_er(i_gmii_er_p4),
.gmii_rxd  (iv_gmii_rxd_p4),

.gmii_rx_dv_adp2tsnchip(o_gmii_dv_p4_adp2tsnchip),
.gmii_rx_er_adp2tsnchip(o_gmii_er_p4_adp2tsnchip),
.gmii_rxd_adp2tsnchip  (ov_gmii_rxd_p4_adp2tsnchip),


.gmii_tx_en(o_gmii_tx_en_p4),
.gmii_tx_er(o_gmii_tx_er_p4),
.gmii_txd  (ov_gmii_txd_p4),

.gmii_tx_en_tsnchip2adp(i_gmii_tx_en_p4_tsnchip2adp),
.gmii_tx_er_tsnchip2adp(i_gmii_tx_er_p4_tsnchip2adp),
.gmii_txd_tsnchip2adp  (iv_gmii_txd_p4_tsnchip2adp)

);

endmodule