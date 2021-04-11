// Copyright (C) 1953-2020 NUDT
// Verilog module name - host_input_queue 
// Version: HIQ_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         control bufid of pkt transmitted to host to input queue
//             - write bufid of ts packet to ram of TIM; 
//             - write bufid of not ts packet to queue.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module network_input_queue
(
       i_clk,
       i_rst_n,
       
       iv_tsntag_host,
       iv_bufid_host,
       i_descriptor_wr_host,
       o_descriptor_ack_host,
       
       iv_tsntag_network,
       iv_bufid_network,
       i_descriptor_wr_network,
       o_descriptor_ack_network,
       
       ov_fifo_wdata,
       o_fifo_wr
);
// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
//tsntag & bufid input from host_port
input          [47:0]  iv_tsntag_host;
input          [8:0]   iv_bufid_host;
input                  i_descriptor_wr_host;
output reg             o_descriptor_ack_host;
//tsntag & bufid input from hcp_port
input          [47:0]  iv_tsntag_network;
input          [8:0]   iv_bufid_network;
input                  i_descriptor_wr_network;
output reg             o_descriptor_ack_network;
//tsntag & bufid output
output reg     [56:0]  ov_fifo_wdata;
output reg             o_fifo_wr;
//***************************************************
//          control bufid to input queue 
//***************************************************
reg            [3:0]   niq_state;
localparam  IDLE_S = 4'd0,
            HOST_REQUEST_PAUSE_S = 4'd1,
            NETWORK_REQUEST_PAUSE_S = 4'd2;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_descriptor_ack_host <= 1'b0;
        o_descriptor_ack_network <= 1'b0;      
        
        ov_fifo_wdata <= 57'b0;
        o_fifo_wr <= 1'b0;
        niq_state <= IDLE_S;
    end
    else begin
        case(niq_state)
            IDLE_S:begin
                if(i_descriptor_wr_host == 1'b1)begin
                    o_descriptor_ack_host <= 1'b1;
                    ov_fifo_wdata <= {iv_tsntag_host,iv_bufid_host};
                    o_fifo_wr <= 1'b1;
                    
                    o_descriptor_ack_network <= 1'b0;
                    niq_state <= HOST_REQUEST_PAUSE_S;                    
                end
                else if(i_descriptor_wr_network == 1'b1)begin
                    o_descriptor_ack_network <= 1'b1; 
                    ov_fifo_wdata <= {iv_tsntag_network,iv_bufid_network};
                    o_fifo_wr <= 1'b1; 

                    o_descriptor_ack_host <= 1'b0; 
                    niq_state <= NETWORK_REQUEST_PAUSE_S;                       
                end
                else begin
                    o_descriptor_ack_host <= 1'b0;
                    o_descriptor_ack_network <= 1'b0;      
                    
                    ov_fifo_wdata <= 57'b0;
                    o_fifo_wr <= 1'b0;
                    niq_state <= IDLE_S;
                end
            end
            HOST_REQUEST_PAUSE_S:begin
                o_descriptor_ack_host <= 1'b0;
                ov_fifo_wdata <= 57'b0;
                o_fifo_wr <= 1'b0; 
                o_descriptor_ack_network <= 1'b0;                
                if(i_descriptor_wr_host == 1'b0)begin
                    niq_state <= IDLE_S;
                end
                else begin
                    niq_state <= HOST_REQUEST_PAUSE_S;
                end
            end
            NETWORK_REQUEST_PAUSE_S:begin
                o_descriptor_ack_host <= 1'b0;
                ov_fifo_wdata <= 57'b0;
                o_fifo_wr <= 1'b0; 
                o_descriptor_ack_network <= 1'b0;                
                if(i_descriptor_wr_network == 1'b0)begin
                    niq_state <= IDLE_S;
                end
                else begin
                    niq_state <= NETWORK_REQUEST_PAUSE_S;
                end
            end
            default:begin
                o_descriptor_ack_host <= 1'b0;
                ov_fifo_wdata <= 57'b0;
                o_fifo_wr <= 1'b0; 
                o_descriptor_ack_network <= 1'b0; 
                niq_state <= IDLE_S;                
            end
        endcase            
    end
end 
endmodule