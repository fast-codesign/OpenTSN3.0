// Copyright (C) 1953-2020 NUDT
// Verilog module name - statistic_module
// Version: STM_V1.0
// Created:
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         statistic pkt count from host or network port
///////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module statistic_module
(
       i_clk,
       i_rst_n,

       i_host_inpkt_pulse,
       i_host_discard_pkt_pulse,
       i_port0_inpkt_pulse,
       i_port0_discard_pkt_pulse,
       i_port1_inpkt_pulse,
       i_port1_discard_pkt_pulse,
       i_port2_inpkt_pulse,
       i_port2_discard_pkt_pulse,
       i_port3_inpkt_pulse,
       i_port3_discard_pkt_pulse,
       i_port4_inpkt_pulse,
       i_port4_discard_pkt_pulse,
       i_port5_inpkt_pulse,
       i_port5_discard_pkt_pulse,
       i_port6_inpkt_pulse,
       i_port6_discard_pkt_pulse,
       i_port7_inpkt_pulse,
       i_port7_discard_pkt_pulse,
       
       i_host_outpkt_pulse,
       i_host_in_queue_discard_pulse,
       i_port0_outpkt_pulse,
       i_port1_outpkt_pulse,
       i_port2_outpkt_pulse,
       i_port3_outpkt_pulse,
       i_port4_outpkt_pulse,
       i_port5_outpkt_pulse,
       i_port6_outpkt_pulse,
       i_port7_outpkt_pulse,
       i_nmac_receive_pulse,
       i_nmac_report_pulse,
       
       i_ts_inj_underflow_error_pulse,
       i_ts_inj_overflow_error_pulse ,
       i_ts_sub_underflow_error_pulse,
       i_ts_sub_overflow_error_pulse ,
       
       i_statistic_rst,
       
       ov_host_inpkt_cnt,
       ov_host_discard_pkt_cnt,
       ov_port0_inpkt_cnt,
       ov_port0_discard_pkt_cnt,
       ov_port1_inpkt_cnt,
       ov_port1_discard_pkt_cnt,
       ov_port2_inpkt_cnt,
       ov_port2_discard_pkt_cnt,
       ov_port3_inpkt_cnt,
       ov_port3_discard_pkt_cnt,
       ov_port4_inpkt_cnt,
       ov_port4_discard_pkt_cnt,
       ov_port5_inpkt_cnt,
       ov_port5_discard_pkt_cnt,
       ov_port6_inpkt_cnt,
       ov_port6_discard_pkt_cnt,
       ov_port7_inpkt_cnt,
       ov_port7_discard_pkt_cnt,
       
       ov_host_outpkt_cnt,
       ov_host_in_queue_discard_cnt,       
       ov_port0_outpkt_cnt,
       ov_port1_outpkt_cnt,
       ov_port2_outpkt_cnt,
       ov_port3_outpkt_cnt,
       ov_port4_outpkt_cnt,
       ov_port5_outpkt_cnt,
       ov_port6_outpkt_cnt,
       ov_port7_outpkt_cnt,
       ov_nmac_receive_cnt,
       ov_nmac_report_cnt,
       
       ov_ts_inj_underflow_error_cnt,
       ov_ts_inj_overflow_error_cnt ,
       ov_ts_sub_underflow_error_cnt,
       ov_ts_sub_overflow_error_cnt 
       
);


// I/O
// i_clk & rst
input                  i_clk;
input                  i_rst_n;

// pkt count pulse     
input                  i_host_inpkt_pulse;
input                  i_host_discard_pkt_pulse;
input                  i_port0_inpkt_pulse;
input                  i_port0_discard_pkt_pulse;
input                  i_port1_inpkt_pulse;
input                  i_port1_discard_pkt_pulse;
input                  i_port2_inpkt_pulse;
input                  i_port2_discard_pkt_pulse;
input                  i_port3_inpkt_pulse;
input                  i_port3_discard_pkt_pulse;
input                  i_port4_inpkt_pulse;
input                  i_port4_discard_pkt_pulse;
input                  i_port5_inpkt_pulse;
input                  i_port5_discard_pkt_pulse;
input                  i_port6_inpkt_pulse;
input                  i_port6_discard_pkt_pulse;
input                  i_port7_inpkt_pulse;
input                  i_port7_discard_pkt_pulse;
       
input                  i_host_outpkt_pulse;
input                  i_host_in_queue_discard_pulse;
input                  i_port0_outpkt_pulse;
input                  i_port1_outpkt_pulse;
input                  i_port2_outpkt_pulse;
input                  i_port3_outpkt_pulse;
input                  i_port4_outpkt_pulse;
input                  i_port5_outpkt_pulse;
input                  i_port6_outpkt_pulse;
input                  i_port7_outpkt_pulse;
input                  i_nmac_receive_pulse;
input                  i_nmac_report_pulse;

input                  i_ts_inj_underflow_error_pulse;
input                  i_ts_inj_overflow_error_pulse ;
input                  i_ts_sub_underflow_error_pulse;
input                  i_ts_sub_overflow_error_pulse ;

input                  i_statistic_rst;

// pkt Statistic
output reg[15:0]       ov_host_inpkt_cnt;
output reg[15:0]       ov_host_discard_pkt_cnt;
output reg[15:0]       ov_port0_inpkt_cnt;
output reg[15:0]       ov_port0_discard_pkt_cnt;
output reg[15:0]       ov_port1_inpkt_cnt;
output reg[15:0]       ov_port1_discard_pkt_cnt;
output reg[15:0]       ov_port2_inpkt_cnt;
output reg[15:0]       ov_port2_discard_pkt_cnt;
output reg[15:0]       ov_port3_inpkt_cnt;
output reg[15:0]       ov_port3_discard_pkt_cnt;
output reg[15:0]       ov_port4_inpkt_cnt;
output reg[15:0]       ov_port4_discard_pkt_cnt;
output reg[15:0]       ov_port5_inpkt_cnt;
output reg[15:0]       ov_port5_discard_pkt_cnt;
output reg[15:0]       ov_port6_inpkt_cnt;
output reg[15:0]       ov_port6_discard_pkt_cnt;
output reg[15:0]       ov_port7_inpkt_cnt;
output reg[15:0]       ov_port7_discard_pkt_cnt;
           
output reg[15:0]       ov_host_outpkt_cnt;
output reg[15:0]       ov_host_in_queue_discard_cnt;
output reg[15:0]       ov_port0_outpkt_cnt;
output reg[15:0]       ov_port1_outpkt_cnt;
output reg[15:0]       ov_port2_outpkt_cnt;
output reg[15:0]       ov_port3_outpkt_cnt;
output reg[15:0]       ov_port4_outpkt_cnt;
output reg[15:0]       ov_port5_outpkt_cnt;
output reg[15:0]       ov_port6_outpkt_cnt;
output reg[15:0]       ov_port7_outpkt_cnt;
output reg[15:0]       ov_nmac_receive_cnt;
output reg[15:0]       ov_nmac_report_cnt;

output reg[15:0]       ov_ts_inj_underflow_error_cnt;
output reg[15:0]       ov_ts_inj_overflow_error_cnt ;
output reg[15:0]       ov_ts_sub_underflow_error_cnt;
output reg[15:0]       ov_ts_sub_overflow_error_cnt ;

//internel pkt statistic
reg       [15:0]       rv_host_inpkt_cnt;
reg       [15:0]       rv_host_discard_pkt_cnt;
reg       [15:0]       rv_port0_inpkt_cnt;
reg       [15:0]       rv_port0_discard_pkt_cnt;
reg       [15:0]       rv_port1_inpkt_cnt;
reg       [15:0]       rv_port1_discard_pkt_cnt;
reg       [15:0]       rv_port2_inpkt_cnt;
reg       [15:0]       rv_port2_discard_pkt_cnt;
reg       [15:0]       rv_port3_inpkt_cnt;
reg       [15:0]       rv_port3_discard_pkt_cnt;
reg       [15:0]       rv_port4_inpkt_cnt;
reg       [15:0]       rv_port4_discard_pkt_cnt;
reg       [15:0]       rv_port5_inpkt_cnt;
reg       [15:0]       rv_port5_discard_pkt_cnt;
reg       [15:0]       rv_port6_inpkt_cnt;
reg       [15:0]       rv_port6_discard_pkt_cnt;
reg       [15:0]       rv_port7_inpkt_cnt;
reg       [15:0]       rv_port7_discard_pkt_cnt;

reg       [15:0]       rv_host_outpkt_cnt;
reg       [15:0]       rv_host_in_queue_discard_cnt;
reg       [15:0]       rv_port0_outpkt_cnt;
reg       [15:0]       rv_port1_outpkt_cnt;
reg       [15:0]       rv_port2_outpkt_cnt;
reg       [15:0]       rv_port3_outpkt_cnt;
reg       [15:0]       rv_port4_outpkt_cnt;
reg       [15:0]       rv_port5_outpkt_cnt;
reg       [15:0]       rv_port6_outpkt_cnt;
reg       [15:0]       rv_port7_outpkt_cnt;
reg       [15:0]       rv_nmac_receive_cnt;
reg       [15:0]       rv_nmac_report_cnt;

reg       [15:0]       rv_ts_inj_underflow_error_cnt;
reg       [15:0]       rv_ts_inj_overflow_error_cnt ;
reg       [15:0]       rv_ts_sub_underflow_error_cnt;
reg       [15:0]       rv_ts_sub_overflow_error_cnt ;


always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        rv_host_inpkt_cnt         <= 16'h0;
        rv_host_in_queue_discard_cnt <= 16'h0;
        rv_host_discard_pkt_cnt   <= 16'h0;
        rv_port0_inpkt_cnt        <= 16'h0;
        rv_port0_discard_pkt_cnt  <= 16'h0;
        rv_port1_inpkt_cnt        <= 16'h0;
        rv_port1_discard_pkt_cnt  <= 16'h0;
        rv_port2_inpkt_cnt        <= 16'h0;
        rv_port2_discard_pkt_cnt  <= 16'h0;
        rv_port3_inpkt_cnt        <= 16'h0;
        rv_port3_discard_pkt_cnt  <= 16'h0;
        rv_port4_inpkt_cnt        <= 16'h0;
        rv_port4_discard_pkt_cnt  <= 16'h0;
        rv_port5_inpkt_cnt        <= 16'h0;
        rv_port5_discard_pkt_cnt  <= 16'h0;
        rv_port6_inpkt_cnt        <= 16'h0;
        rv_port6_discard_pkt_cnt  <= 16'h0;
        rv_port7_inpkt_cnt        <= 16'h0;
        rv_port7_discard_pkt_cnt  <= 16'h0;
                                
        rv_host_outpkt_cnt        <= 16'h0;
        rv_port0_outpkt_cnt       <= 16'h0;
        rv_port1_outpkt_cnt       <= 16'h0;
        rv_port2_outpkt_cnt       <= 16'h0;
        rv_port3_outpkt_cnt       <= 16'h0;
        rv_port4_outpkt_cnt       <= 16'h0;
        rv_port5_outpkt_cnt       <= 16'h0;
        rv_port6_outpkt_cnt       <= 16'h0;
        rv_port7_outpkt_cnt       <= 16'h0;
        rv_nmac_receive_cnt       <= 16'h0;
        rv_nmac_report_cnt        <= 16'h0;
        
        rv_ts_inj_underflow_error_cnt <= 16'h0;
        rv_ts_inj_overflow_error_cnt  <= 16'h0;
        rv_ts_sub_underflow_error_cnt <= 16'h0;
        rv_ts_sub_overflow_error_cnt  <= 16'h0;
        
        ov_host_inpkt_cnt         <= 16'h0;
        ov_host_in_queue_discard_cnt <= 16'h0;
        ov_host_discard_pkt_cnt   <= 16'h0;
        ov_port0_inpkt_cnt        <= 16'h0;
        ov_port0_discard_pkt_cnt  <= 16'h0;
        ov_port1_inpkt_cnt        <= 16'h0;
        ov_port1_discard_pkt_cnt  <= 16'h0;
        ov_port2_inpkt_cnt        <= 16'h0;
        ov_port2_discard_pkt_cnt  <= 16'h0;
        ov_port3_inpkt_cnt        <= 16'h0;
        ov_port3_discard_pkt_cnt  <= 16'h0;
        ov_port4_inpkt_cnt        <= 16'h0;
        ov_port4_discard_pkt_cnt  <= 16'h0;
        ov_port5_inpkt_cnt        <= 16'h0;
        ov_port5_discard_pkt_cnt  <= 16'h0;
        ov_port6_inpkt_cnt        <= 16'h0;
        ov_port6_discard_pkt_cnt  <= 16'h0;
        ov_port7_inpkt_cnt        <= 16'h0;
        ov_port7_discard_pkt_cnt  <= 16'h0;
                                  
        ov_host_outpkt_cnt        <= 16'h0;
        ov_port0_outpkt_cnt       <= 16'h0;
        ov_port1_outpkt_cnt       <= 16'h0;
        ov_port2_outpkt_cnt       <= 16'h0;
        ov_port3_outpkt_cnt       <= 16'h0;
        ov_port4_outpkt_cnt       <= 16'h0;
        ov_port5_outpkt_cnt       <= 16'h0;
        ov_port6_outpkt_cnt       <= 16'h0;
        ov_port7_outpkt_cnt       <= 16'h0;
        ov_nmac_receive_cnt       <= 16'h0;
        ov_nmac_report_cnt        <= 16'h0;
        
        ov_ts_inj_underflow_error_cnt <= 16'h0;
        ov_ts_inj_overflow_error_cnt  <= 16'h0;
        ov_ts_sub_underflow_error_cnt <= 16'h0;
        ov_ts_sub_overflow_error_cnt  <= 16'h0;
        
    end
    else begin
        if(i_statistic_rst == 1'b1)begin//reset all count 
            ov_host_inpkt_cnt         <= rv_host_inpkt_cnt;
            ov_host_in_queue_discard_cnt <= rv_host_in_queue_discard_cnt;
            ov_host_discard_pkt_cnt   <= rv_host_discard_pkt_cnt ;
            ov_port0_inpkt_cnt        <= rv_port0_inpkt_cnt      ;
            ov_port0_discard_pkt_cnt  <= rv_port0_discard_pkt_cnt;
            ov_port1_inpkt_cnt        <= rv_port1_inpkt_cnt      ;
            ov_port1_discard_pkt_cnt  <= rv_port1_discard_pkt_cnt;
            ov_port2_inpkt_cnt        <= rv_port2_inpkt_cnt      ;
            ov_port2_discard_pkt_cnt  <= rv_port2_discard_pkt_cnt;
            ov_port3_inpkt_cnt        <= rv_port3_inpkt_cnt      ;
            ov_port3_discard_pkt_cnt  <= rv_port3_discard_pkt_cnt;
            ov_port4_inpkt_cnt        <= rv_port4_inpkt_cnt      ;
            ov_port4_discard_pkt_cnt  <= rv_port4_discard_pkt_cnt;
            ov_port5_inpkt_cnt        <= rv_port5_inpkt_cnt      ;
            ov_port5_discard_pkt_cnt  <= rv_port5_discard_pkt_cnt;
            ov_port6_inpkt_cnt        <= rv_port6_inpkt_cnt      ;
            ov_port6_discard_pkt_cnt  <= rv_port6_discard_pkt_cnt;
            ov_port7_inpkt_cnt        <= rv_port7_inpkt_cnt      ;
            ov_port7_discard_pkt_cnt  <= rv_port7_discard_pkt_cnt;
                                   
            ov_host_outpkt_cnt        <= rv_host_outpkt_cnt;
            ov_port0_outpkt_cnt       <= rv_port0_outpkt_cnt;
            ov_port1_outpkt_cnt       <= rv_port1_outpkt_cnt;
            ov_port2_outpkt_cnt       <= rv_port2_outpkt_cnt;
            ov_port3_outpkt_cnt       <= rv_port3_outpkt_cnt;
            ov_port4_outpkt_cnt       <= rv_port4_outpkt_cnt;
            ov_port5_outpkt_cnt       <= rv_port5_outpkt_cnt;
            ov_port6_outpkt_cnt       <= rv_port6_outpkt_cnt;
            ov_port7_outpkt_cnt       <= rv_port7_outpkt_cnt;
            ov_nmac_receive_cnt       <= rv_nmac_receive_cnt;
            ov_nmac_report_cnt        <= rv_nmac_report_cnt;
            
            ov_ts_inj_underflow_error_cnt <= rv_ts_inj_underflow_error_cnt;
            ov_ts_inj_overflow_error_cnt  <= rv_ts_inj_overflow_error_cnt ;
            ov_ts_sub_underflow_error_cnt <= rv_ts_sub_underflow_error_cnt;
            ov_ts_sub_overflow_error_cnt  <= rv_ts_sub_overflow_error_cnt ;
            
            if(i_host_inpkt_pulse == 1'b1)begin
                rv_host_inpkt_cnt   <= 16'h1;
            end
            else begin
                rv_host_inpkt_cnt   <= 16'h0;
            end
            
            if(i_host_discard_pkt_pulse == 1'b1)begin
                rv_host_discard_pkt_cnt   <= 16'h1;
            end                              
            else begin                       
                rv_host_discard_pkt_cnt   <= 16'h0;
            end
            
            if(i_port0_inpkt_pulse == 1'b1)begin
                rv_port0_inpkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_port0_inpkt_cnt   <= 16'h0;
            end
            
            if(i_port0_discard_pkt_pulse == 1'b1)begin
                rv_port0_discard_pkt_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_port0_discard_pkt_cnt   <= 16'h0;
            end
            
            if(i_port1_inpkt_pulse == 1'b1)begin
                rv_port1_inpkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_port1_inpkt_cnt   <= 16'h0;
            end
            
            if(i_port1_discard_pkt_pulse == 1'b1)begin
                rv_port1_discard_pkt_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_port1_discard_pkt_cnt   <= 16'h0;
            end
            
            if(i_port2_inpkt_pulse == 1'b1)begin
                rv_port2_inpkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_port2_inpkt_cnt   <= 16'h0;
            end
            
            if(i_port2_discard_pkt_pulse == 1'b1)begin
                rv_port2_discard_pkt_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_port2_discard_pkt_cnt   <= 16'h0;
            end
            
            if(i_port3_inpkt_pulse == 1'b1)begin
                rv_port3_inpkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_port3_inpkt_cnt   <= 16'h0;
            end
            
            if(i_port3_discard_pkt_pulse == 1'b1)begin
                rv_port3_discard_pkt_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_port3_discard_pkt_cnt   <= 16'h0;
            end
            
            if(i_port4_inpkt_pulse == 1'b1)begin
                rv_port4_inpkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_port4_inpkt_cnt   <= 16'h0;
            end
            
            if(i_port4_discard_pkt_pulse == 1'b1)begin
                rv_port4_discard_pkt_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_port4_discard_pkt_cnt   <= 16'h0;
            end
            
            if(i_port5_inpkt_pulse == 1'b1)begin
                rv_port5_inpkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_port5_inpkt_cnt   <= 16'h0;
            end
            
            if(i_port5_discard_pkt_pulse == 1'b1)begin
                rv_port5_discard_pkt_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_port5_discard_pkt_cnt   <= 16'h0;
            end
            
            if(i_port6_inpkt_pulse == 1'b1)begin
                rv_port6_inpkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_port6_inpkt_cnt   <= 16'h0;
            end
            
            if(i_port6_discard_pkt_pulse == 1'b1)begin
                rv_port6_discard_pkt_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_port6_discard_pkt_cnt   <= 16'h0;
            end
            
            if(i_port7_inpkt_pulse == 1'b1)begin
                rv_port7_inpkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_port7_inpkt_cnt   <= 16'h0;
            end
            
            if(i_port7_discard_pkt_pulse == 1'b1)begin
                rv_port7_discard_pkt_cnt   <= 16'h1;
            end                               
            else begin                        
                rv_port7_discard_pkt_cnt   <= 16'h0;
            end
            
            if(i_host_outpkt_pulse == 1'b1)begin
                rv_host_outpkt_cnt   <= 16'h1;
            end                         
            else begin                  
                rv_host_outpkt_cnt   <= 16'h0;
            end
            
            if(i_host_in_queue_discard_pulse == 1'b1)begin
                rv_host_in_queue_discard_cnt   <= 16'h1;
            end                                   
            else begin                            
                rv_host_in_queue_discard_cnt   <= 16'h0;
            end 

            if(i_port0_outpkt_pulse == 1'b1)begin
                rv_port0_outpkt_cnt   <= 16'h1;
            end                          
            else begin                   
                rv_port0_outpkt_cnt   <= 16'h0;
            end
            
            if(i_port1_outpkt_pulse == 1'b1)begin
                rv_port1_outpkt_cnt   <= 16'h1;
            end                          
            else begin                   
                rv_port1_outpkt_cnt   <= 16'h0;
            end
            
            if(i_port2_outpkt_pulse == 1'b1)begin
                rv_port2_outpkt_cnt   <= 16'h1;
            end                          
            else begin                   
                rv_port2_outpkt_cnt   <= 16'h0;
            end
            
            if(i_port3_outpkt_pulse == 1'b1)begin
                rv_port3_outpkt_cnt   <= 16'h1;
            end                          
            else begin                   
                rv_port3_outpkt_cnt   <= 16'h0;
            end
            
            if(i_port4_outpkt_pulse == 1'b1)begin
                rv_port4_outpkt_cnt   <= 16'h1;
            end                          
            else begin                   
                rv_port4_outpkt_cnt   <= 16'h0;
            end
            
            if(i_port5_outpkt_pulse == 1'b1)begin
                rv_port5_outpkt_cnt   <= 16'h1;
            end                          
            else begin                   
                rv_port5_outpkt_cnt   <= 16'h0;
            end
            
            if(i_port6_outpkt_pulse == 1'b1)begin
                rv_port6_outpkt_cnt   <= 16'h1;
            end                          
            else begin                   
                rv_port6_outpkt_cnt   <= 16'h0;
            end
            
            if(i_port7_outpkt_pulse == 1'b1)begin
                rv_port7_outpkt_cnt   <= 16'h1;
            end                          
            else begin                   
                rv_port7_outpkt_cnt   <= 16'h0;
            end
            
            if(i_nmac_receive_pulse == 1'b1)begin
                rv_nmac_receive_cnt   <= 16'h1;
            end                          
            else begin                   
                rv_nmac_receive_cnt   <= 16'h0;
            end
            
            if(i_nmac_report_pulse == 1'b1)begin
                rv_nmac_report_cnt    <= 16'h1;
            end                          
            else begin                   
                rv_nmac_report_cnt    <= 16'h0;
            end
            
            if(i_ts_inj_underflow_error_pulse == 1'b1)begin
                rv_ts_inj_underflow_error_cnt    <= 16'h1;
            end                                     
            else begin                              
                rv_ts_inj_underflow_error_cnt    <= 16'h0;
            end
            
            if(i_ts_inj_overflow_error_pulse == 1'b1)begin
                rv_ts_inj_overflow_error_cnt    <= 16'h1;
            end                                    
            else begin                             
                rv_ts_inj_overflow_error_cnt    <= 16'h0;
            end
            
            if(i_ts_sub_underflow_error_pulse == 1'b1)begin
                rv_ts_sub_underflow_error_cnt    <= 16'h1;
            end                                     
            else begin                              
                rv_ts_sub_underflow_error_cnt    <= 16'h0;
            end
            
            if(i_ts_sub_overflow_error_pulse == 1'b1)begin
                rv_ts_sub_overflow_error_cnt    <= 16'h1;
            end                                    
            else begin                             
                rv_ts_sub_overflow_error_cnt    <= 16'h0;
            end
        end
        else begin//add count base on pulse
            if(i_host_inpkt_pulse == 1'b1)begin
                rv_host_inpkt_cnt   <= rv_host_inpkt_cnt + 16'h1;
            end
            else begin
                rv_host_inpkt_cnt   <= rv_host_inpkt_cnt;
            end
            
            if(i_host_discard_pkt_pulse == 1'b1)begin
                rv_host_discard_pkt_cnt   <= rv_host_discard_pkt_cnt + 16'h1;
            end
            else begin
                rv_host_discard_pkt_cnt   <= rv_host_discard_pkt_cnt;
            end
            
            if(i_port0_inpkt_pulse == 1'b1)begin
                rv_port0_inpkt_cnt   <= rv_port0_inpkt_cnt + 16'h1;
            end
            else begin
                rv_port0_inpkt_cnt   <= rv_port0_inpkt_cnt;
            end
            
            if(i_port0_discard_pkt_pulse == 1'b1)begin
                rv_port0_discard_pkt_cnt   <= rv_port0_discard_pkt_cnt + 16'h1;
            end
            else begin
                rv_port0_discard_pkt_cnt   <= rv_port0_discard_pkt_cnt;
            end
            
            if(i_port1_inpkt_pulse == 1'b1)begin
                rv_port1_inpkt_cnt   <= rv_port1_inpkt_cnt + 16'h1;
            end
            else begin
                rv_port1_inpkt_cnt   <= rv_port1_inpkt_cnt;
            end
            
            if(i_port1_discard_pkt_pulse == 1'b1)begin
                rv_port1_discard_pkt_cnt   <= rv_port1_discard_pkt_cnt + 16'h1;
            end
            else begin
                rv_port1_discard_pkt_cnt   <= rv_port1_discard_pkt_cnt;
            end
            
            if(i_port2_inpkt_pulse == 1'b1)begin
                rv_port2_inpkt_cnt   <= rv_port2_inpkt_cnt + 16'h1;
            end
            else begin
                rv_port2_inpkt_cnt   <= rv_port2_inpkt_cnt;
            end
            
            if(i_port2_discard_pkt_pulse == 1'b1)begin
                rv_port2_discard_pkt_cnt   <= rv_port2_discard_pkt_cnt + 16'h1;
            end
            else begin
                rv_port2_discard_pkt_cnt   <= rv_port2_discard_pkt_cnt;
            end
            
            if(i_port3_inpkt_pulse == 1'b1)begin
                rv_port3_inpkt_cnt   <= rv_port3_inpkt_cnt + 16'h1;
            end
            else begin
                rv_port3_inpkt_cnt   <= rv_port3_inpkt_cnt;
            end
            
            if(i_port3_discard_pkt_pulse == 1'b1)begin
                rv_port3_discard_pkt_cnt   <= rv_port3_discard_pkt_cnt + 16'h1;
            end
            else begin
                rv_port3_discard_pkt_cnt   <= rv_port3_discard_pkt_cnt;
            end
            
            if(i_port4_inpkt_pulse == 1'b1)begin
                rv_port4_inpkt_cnt   <= rv_port4_inpkt_cnt + 16'h1;
            end
            else begin
                rv_port4_inpkt_cnt   <= rv_port4_inpkt_cnt;
            end
            
            if(i_port4_discard_pkt_pulse == 1'b1)begin
                rv_port4_discard_pkt_cnt   <= rv_port4_discard_pkt_cnt + 16'h1;
            end
            else begin
                rv_port4_discard_pkt_cnt   <= rv_port4_discard_pkt_cnt;
            end
            
            if(i_port5_inpkt_pulse == 1'b1)begin
                rv_port5_inpkt_cnt   <= rv_port5_inpkt_cnt + 16'h1;
            end
            else begin
                rv_port5_inpkt_cnt   <= rv_port5_inpkt_cnt;
            end
            
            if(i_port5_discard_pkt_pulse == 1'b1)begin
                rv_port5_discard_pkt_cnt   <= rv_port5_discard_pkt_cnt + 16'h1;
            end
            else begin
                rv_port5_discard_pkt_cnt   <= rv_port5_discard_pkt_cnt;
            end
            
            if(i_port6_inpkt_pulse == 1'b1)begin
                rv_port6_inpkt_cnt   <= rv_port6_inpkt_cnt + 16'h1;
            end
            else begin
                rv_port6_inpkt_cnt   <= rv_port6_inpkt_cnt;
            end
            
            if(i_port6_discard_pkt_pulse == 1'b1)begin
                rv_port6_discard_pkt_cnt   <= rv_port6_discard_pkt_cnt + 16'h1;
            end
            else begin
                rv_port6_discard_pkt_cnt   <= rv_port6_discard_pkt_cnt;
            end
            
            if(i_port7_inpkt_pulse == 1'b1)begin
                rv_port7_inpkt_cnt   <= rv_port7_inpkt_cnt + 16'h1;
            end
            else begin
                rv_port7_inpkt_cnt   <= rv_port7_inpkt_cnt;
            end
            
            if(i_port7_discard_pkt_pulse == 1'b1)begin
                rv_port7_discard_pkt_cnt   <= rv_port7_discard_pkt_cnt + 16'h1;
            end
            else begin
                rv_port7_discard_pkt_cnt   <= rv_port7_discard_pkt_cnt;
            end
            
            if(i_host_outpkt_pulse == 1'b1)begin
                rv_host_outpkt_cnt   <= rv_host_outpkt_cnt + 16'h1;
            end
            else begin
                rv_host_outpkt_cnt   <= rv_host_outpkt_cnt;
            end
            
            if(i_host_in_queue_discard_pulse == 1'b1)begin
                rv_host_in_queue_discard_cnt   <= rv_host_in_queue_discard_cnt + 16'h1;
            end
            else begin
                rv_host_in_queue_discard_cnt   <= rv_host_in_queue_discard_cnt;
            end 

            if(i_port0_outpkt_pulse == 1'b1)begin
                rv_port0_outpkt_cnt   <= rv_port0_outpkt_cnt + 16'h1;
            end
            else begin
                rv_port0_outpkt_cnt   <= rv_port0_outpkt_cnt;
            end
            
            if(i_port1_outpkt_pulse == 1'b1)begin
                rv_port1_outpkt_cnt   <= rv_port1_outpkt_cnt + 16'h1;
            end
            else begin
                rv_port1_outpkt_cnt   <= rv_port1_outpkt_cnt;
            end
            
            if(i_port2_outpkt_pulse == 1'b1)begin
                rv_port2_outpkt_cnt   <= rv_port2_outpkt_cnt + 16'h1;
            end
            else begin
                rv_port2_outpkt_cnt   <= rv_port2_outpkt_cnt;
            end
            
            if(i_port3_outpkt_pulse == 1'b1)begin
                rv_port3_outpkt_cnt   <= rv_port3_outpkt_cnt + 16'h1;
            end
            else begin
                rv_port3_outpkt_cnt   <= rv_port3_outpkt_cnt;
            end
            
            if(i_port4_outpkt_pulse == 1'b1)begin
                rv_port4_outpkt_cnt   <= rv_port4_outpkt_cnt + 16'h1;
            end
            else begin
                rv_port4_outpkt_cnt   <= rv_port4_outpkt_cnt;
            end
            
            if(i_port5_outpkt_pulse == 1'b1)begin
                rv_port5_outpkt_cnt   <= rv_port5_outpkt_cnt + 16'h1;
            end
            else begin
                rv_port5_outpkt_cnt   <= rv_port5_outpkt_cnt;
            end
            
            if(i_port6_outpkt_pulse == 1'b1)begin
                rv_port6_outpkt_cnt   <= rv_port6_outpkt_cnt + 16'h1;
            end
            else begin
                rv_port6_outpkt_cnt   <= rv_port6_outpkt_cnt;
            end
            
            if(i_port7_outpkt_pulse == 1'b1)begin
                rv_port7_outpkt_cnt   <= rv_port7_outpkt_cnt + 16'h1;
            end
            else begin
                rv_port7_outpkt_cnt   <= rv_port7_outpkt_cnt;
            end
            
            if(i_nmac_receive_pulse == 1'b1)begin
                rv_nmac_receive_cnt   <= rv_nmac_receive_cnt + 16'h1;
            end
            else begin
                rv_nmac_receive_cnt   <= rv_nmac_receive_cnt;
            end
            
            if(i_nmac_report_pulse == 1'b1)begin
                rv_nmac_report_cnt    <= rv_nmac_report_cnt + 16'h1;
            end
            else begin
                rv_nmac_report_cnt    <= rv_nmac_report_cnt;
            end
            
            if(i_ts_inj_underflow_error_pulse == 1'b1)begin
                rv_ts_inj_underflow_error_cnt    <= rv_ts_inj_underflow_error_cnt + 16'h1;
            end
            else begin
                rv_ts_inj_underflow_error_cnt    <= rv_ts_inj_underflow_error_cnt;
            end
            
            if(i_ts_inj_overflow_error_pulse == 1'b1)begin
                rv_ts_inj_overflow_error_cnt    <= rv_ts_inj_overflow_error_cnt + 16'h1;
            end
            else begin
                rv_ts_inj_overflow_error_cnt    <= rv_ts_inj_overflow_error_cnt;
            end
            
            if(i_ts_sub_underflow_error_pulse == 1'b1)begin
                rv_ts_sub_underflow_error_cnt    <= rv_ts_sub_underflow_error_cnt + 16'h1;
            end
            else begin
                rv_ts_sub_underflow_error_cnt    <= rv_ts_sub_underflow_error_cnt;
            end
            
            if(i_ts_sub_overflow_error_pulse == 1'b1)begin
                rv_ts_sub_overflow_error_cnt    <= rv_ts_sub_overflow_error_cnt + 16'h1;
            end
            else begin
                rv_ts_sub_overflow_error_cnt    <= rv_ts_sub_overflow_error_cnt;
            end
        end
    end
end

endmodule

