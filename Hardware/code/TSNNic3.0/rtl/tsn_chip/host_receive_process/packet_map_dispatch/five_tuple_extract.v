// Copyright (C) 1953-2020 NUDT
// Verilog module name - pkt_descriptor_generation
// Version: PDG_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         generate descriptor of packet.
//             - write descriptor of TS packet to ram;
//             - transmit descriptor of not TS packet to FLT to look up table.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module five_tuple_extract
(
        i_clk,
        i_rst_n,
       
        iv_data,
        i_data_wr,
        i_data_ack,
        iv_bufid,
       
        ov_5tuple_data,
        o_5tuple_data_wr,
       
        ov_dmac,
        ov_bufid,
        o_ip_flag,  
        o_tcp_or_udp_flag,

        ov_tsntag,
        o_descriptor_wr,
        i_descriptor_ack       
);  
// I/O
// clk & rst  
input                i_clk;
input                i_rst_n;
//pkt input
input        [133:0] iv_data;
input                i_data_wr;
input                i_data_ack;
input        [8:0]   iv_bufid;
//five tuple
output reg   [103:0] ov_5tuple_data;
output reg           o_5tuple_data_wr;
//dmac
output reg   [47:0]  ov_dmac;
output reg   [8:0]   ov_bufid;
output reg           o_ip_flag;
output reg           o_tcp_or_udp_flag;
//tsntag & bufid output for not ip frame
output reg   [47:0]  ov_tsntag;
output reg           o_descriptor_wr;
input                i_descriptor_ack;
//***************************************************
//          extract five tuple from pkt 
//***************************************************
// internal reg&wire for state machine
reg         [3:0]   rv_cycle_cnt; 
reg         [3:0]   fte_state;
localparam  IDLE_S = 4'd0,
            JUDGE_TCP_UDP_S = 4'd1,
            GET_5TUPLE_S = 4'd2,
            WAIT_TRANSMIT_S = 4'd3,
            WAIT_ACK_S = 4'd4;            
always @(posedge i_clk or negedge i_rst_n)begin 
    if(!i_rst_n)begin        
        ov_5tuple_data <= 104'b0;
        o_5tuple_data_wr <= 1'b0;

        ov_dmac <= 48'b0;
        ov_bufid <= 9'b0;
        o_ip_flag <= 1'b0;
        o_tcp_or_udp_flag <= 1'b0;
        
        rv_cycle_cnt <= 4'b0;
        fte_state <=IDLE_S;
    end
    else begin
        case(fte_state)
            IDLE_S:begin
                ov_5tuple_data <= 104'b0;
                o_tcp_or_udp_flag <= 1'b0;
                
                rv_cycle_cnt <= 4'b0;
                if((iv_data[133:132] ==2'b01) && (i_data_wr ==1'b1) && (i_data_ack == 1'b1))begin
                    ov_bufid <= iv_bufid;
                    if(iv_data[31:16] == 16'h0800)begin
                        ov_dmac <= iv_data[127:80];
                        o_ip_flag <= 1'b1;
                        o_5tuple_data_wr <= 1'b0;
                        
                        ov_tsntag <= 48'b0;
                        o_descriptor_wr <= 1'b0;
                        fte_state <= JUDGE_TCP_UDP_S;
                    end
                    else begin
                        ov_dmac <= 48'b0;
                        o_ip_flag <= 1'b0;//not ip pkt
                        o_5tuple_data_wr <= 1'b0;
                        
                        ov_tsntag <= iv_data[127:80];
                        o_descriptor_wr <= 1'b0;
                        fte_state <= WAIT_TRANSMIT_S;
                    end
                end
                else begin
                    ov_dmac <= 48'b0;
                    ov_bufid <= 9'b0;
                    o_ip_flag <= 1'b0;
                    o_5tuple_data_wr <= 1'b0; 

                    ov_tsntag <= 48'b0;
                    o_descriptor_wr <= 1'b0;                    
                    fte_state <= IDLE_S;
                end
            end
            JUDGE_TCP_UDP_S:begin
                if((iv_data[133:132] ==2'b11) && (i_data_wr ==1'b1) && (i_data_ack == 1'b1))begin
                    if((iv_data[71:64] ==8'd6) ||(iv_data[71:64] ==8'd17))begin//TCP or UDP 
                        o_tcp_or_udp_flag <= 1'b1;  //TCP or UDP pkt
                        
                        ov_5tuple_data[103:96] <= iv_data[71:64]; //protocal
                        ov_5tuple_data[95:64] <= iv_data[47:16];  //src ip
                        ov_5tuple_data[63:48] <= iv_data[15:0];   //dst ip 
                        o_5tuple_data_wr <=1'b0;
                        
                        fte_state <= GET_5TUPLE_S;
                    end
                    else begin// not TCP neither UDP
                        o_tcp_or_udp_flag <= 1'b0;
                        ov_5tuple_data <= 104'b0;                    
                        o_5tuple_data_wr <= 1'b1;
                        
                        fte_state <= IDLE_S;
                    end
                end
                else begin
                    fte_state <= JUDGE_TCP_UDP_S;                
                end
            end
            GET_5TUPLE_S:begin
                if((iv_data[133:132] ==2'b11) && (i_data_wr ==1'b1) && (i_data_ack == 1'b1))begin   
                    ov_5tuple_data[47:0] <= iv_data[127:80]; //dst ip,src port,dst port
                    o_5tuple_data_wr <= 1'b1;
                    fte_state <= IDLE_S;
                end
                else begin
                    fte_state <= GET_5TUPLE_S;
                end    
            end
            WAIT_TRANSMIT_S:begin
                if(rv_cycle_cnt == 4'hf)begin
                    o_descriptor_wr <= 1'b1;
                    fte_state <= WAIT_ACK_S; 
                end
                else begin
                    rv_cycle_cnt <= rv_cycle_cnt + 1'b1;
                    fte_state <= WAIT_TRANSMIT_S; 
                end                
            end            
            WAIT_ACK_S:begin
                if(i_descriptor_ack)begin
                    ov_tsntag <= 48'b0;
                    o_descriptor_wr <= 1'b0;
                    ov_bufid <= 9'b0;
                    fte_state <= IDLE_S; 
                end
                else begin
                    fte_state <= WAIT_ACK_S; 
                end                
            end
            default:begin
                fte_state <=IDLE_S;
            end
        endcase
    end
end
endmodule