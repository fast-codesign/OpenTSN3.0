// Copyright (C) 1953-2020 NUDT
// Verilog module name - queue_gate_control 
// Version: QGC_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         use RAM to cahce the gate control list
//         time slot are calculated according to the global clock
//         read the gate control vector according to the time slot 
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module queue_gate_control
(
       i_clk,
       i_rst_n,
       
       iv_ram_addr, 
       iv_ram_wdata,
       i_ram_wr,    
       ov_ram_rdata,
       i_ram_rd,    

       i_qbv_or_qch,
       iv_time_slot,
       i_time_slot_switch,  
       
       ov_in_gate_ctrl_vector,
       ov_out_gate_ctrl_vector
);

// I/O
// clk & rst
input                  i_clk;                   //125Mhz
input                  i_rst_n;

input     [9:0]        iv_ram_addr; 
input     [7:0]        iv_ram_wdata;
input                  i_ram_wr;    
output    [7:0]        ov_ram_rdata;
input                  i_ram_rd;   
 
input                  i_qbv_or_qch;
input      [9:0]       iv_time_slot; 
input                  i_time_slot_switch; 


// gate control vector to network_input_queueand network_output_schedule
output     [1:0]       ov_in_gate_ctrl_vector; 
output     [7:0]       ov_out_gate_ctrl_vector; 

// out_RAM form/to gate_control
wire       [7:0]       wv_ram_rdata_b;
wire       [9:0]       wv_ram_raddr_b;
wire                   w_ram_rd_b;  
gate_control gate_control_inst(           
.i_clk                  (i_clk),
.i_rst_n                (i_rst_n),
                      
.ov_in_gate_ctrl_vector (ov_in_gate_ctrl_vector),
.ov_out_gate_ctrl_vector(ov_out_gate_ctrl_vector),
 
.iv_ram_rdata           (wv_ram_rdata_b),
.ov_ram_raddr           (wv_ram_raddr_b),
.o_ram_rd               (w_ram_rd_b),
    
.i_qbv_or_qch           (i_qbv_or_qch),
.iv_time_slot           (iv_time_slot),
.i_time_slot_switch     (i_time_slot_switch)
);

suhddpsram1024x8_rq out_ram_inst(
.aclr                  (!i_rst_n),
                     
.address_a             (iv_ram_addr),
.address_b             (wv_ram_raddr_b),
                      
.clock                 (i_clk),
                       
.data_a                (iv_ram_wdata),
.data_b                (8'h0),
                      
.rden_a                (i_ram_rd),
.rden_b                (w_ram_rd_b),
                     
.wren_a                (i_ram_wr),
.wren_b                (1'b0),
                       
.q_a                   (ov_ram_rdata),
.q_b                   (wv_ram_rdata_b)
);
endmodule