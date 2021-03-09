// Copyright (C) 1953-2020 NUDT
// Verilog module name - dcm
// Version: dcm_V1.0
// Created:
//         by - peng jintao
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         - dispatch ARP request frame、PTP frame、NMAC report frame to frame encapsulation module;
//         - dispatch TSMP frame to frame decapsulation module;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module hcp_frame_parse
(
    i_clk,
    i_rst_n,
       
    iv_data,
    iv_ts_rec,
	i_data_wr,
    
    iv_data_csm,
    i_data_csm_last,
    i_report_en,
    o_report_en_ack,
      
	ov_data,
    ov_descriptor,
	o_data_wr,
    ov_dcm_state    
);

// I/O
// clk & rst
input                   i_clk;
input                   i_rst_n;  
// pkt input
input	   [8:0]	    iv_data;
input      [18:0]       iv_ts_rec;
input	         	    i_data_wr;
// state pkt input
input      [7:0]        iv_data_csm;
input	         	    i_data_csm_last;

input	         	    i_report_en;
output reg	            o_report_en_ack;
// pkt output to dcm
output reg [8:0]	    ov_data;
output reg [34:0]       ov_descriptor;
output reg	            o_data_wr;
//***************************************************
//                  fifo write
//***************************************************
// internal reg&wire for state machine
reg                  r_descriptor_fifo_wr;
reg  [34:0]          rv_descriptor_fifo_wdata;
reg  [3:0]           rv_cycle_cnt;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        r_descriptor_fifo_wr    <= 1'b0;
        rv_descriptor_fifo_wdata <= 35'b0;        
        rv_cycle_cnt <= 4'b0;       
    end
    else begin
        if(i_data_wr == 1'b1)begin
            if(rv_cycle_cnt == 4'd15)begin
                rv_cycle_cnt <= rv_cycle_cnt; 
            end
            else begin
                rv_cycle_cnt <= rv_cycle_cnt + 1'b1; 
            end
        end
        else begin
            rv_cycle_cnt <= 4'b0; 
        end
        
        if((i_data_wr == 1'b1) && (rv_cycle_cnt == 4'd0))begin
            rv_descriptor_fifo_wdata[34:16] <= iv_ts_rec;
            r_descriptor_fifo_wr    <= 1'b0;            
        end
        else if(rv_cycle_cnt == 4'd12)begin
            rv_descriptor_fifo_wdata[15:0] <= {iv_data[7:0],8'b0};
            r_descriptor_fifo_wr    <= 1'b0;            
        end
        else if(rv_cycle_cnt == 4'd13)begin
            rv_descriptor_fifo_wdata[15:0] <= {rv_descriptor_fifo_wdata[15:8],iv_data[7:0]};
            r_descriptor_fifo_wr    <= 1'b1;            
        end
        else begin
            rv_descriptor_fifo_wdata <= rv_descriptor_fifo_wdata;
            r_descriptor_fifo_wr    <= 1'b0;
        end
            
    end
end
//***************************************************
//               pkt dispatch 
//***************************************************
// internal reg&wire for state machine
reg                  r_descriptor_fifo_rden;
wire  [34:0]         wv_descriptor_fifo_rdata;
wire                 w_descriptor_fifo_empty;

reg                  r_data_fifo_rden;
wire                 w_data_fifo_empty;
wire  [8:0]          wv_data_fifo_rdata;

reg  [11:0]          rv_byte_cnt;
reg  [4:0]           rv_csm_cnt;
reg  [5:0]           rv_delay_cnt;

output reg  [2:0]    ov_dcm_state;
localparam           IDLE_S = 3'd0,
                     TRANS_RECEIVE_FIRST_CYCLE_S  = 3'd1,
                     TRANS_RECEIVE_FRAME_S  = 3'd2,
                     TRANS_REPORT_FIRST_CYCLE_S = 3'd3,
                     TRANS_REPORT_FRAME_S    = 3'd4,
                     TRANS_DELAY_CYCLE_S    = 3'd5;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data             <= 9'b0;
        ov_descriptor       <= 35'b0;          
        o_data_wr           <= 1'b0;
        
        r_descriptor_fifo_rden <= 1'b0;
        r_data_fifo_rden    <= 1'b0;
        
        o_report_en_ack     <= 1'b0;
        rv_byte_cnt         <= 12'b0;
        rv_csm_cnt          <= 5'b0;
        rv_delay_cnt        <= 6'b0;
        ov_dcm_state        <= IDLE_S;
    end
    else begin
        case(ov_dcm_state)
            IDLE_S:begin
                ov_data             <= 9'b0;
                ov_descriptor       <= 35'b0;          
                o_data_wr           <= 1'b0;
                rv_delay_cnt        <= 6'b0;
                if((!w_descriptor_fifo_empty)&&(i_report_en ==1'b0))begin
                    r_data_fifo_rden <= 1'b1;
                    r_descriptor_fifo_rden <= 1'b1;
                    o_report_en_ack <= 1'b0;
                    ov_dcm_state <= TRANS_RECEIVE_FIRST_CYCLE_S;
                end
                else if (w_descriptor_fifo_empty && i_report_en)begin
                    r_data_fifo_rden <= 1'b0;
                    r_descriptor_fifo_rden <= 1'b0;
                    o_report_en_ack <= 1'b1;
                    
                    ov_dcm_state        <= TRANS_REPORT_FIRST_CYCLE_S;
                end
                else if ((!w_descriptor_fifo_empty) && (i_report_en))begin
                    r_data_fifo_rden <= 1'b0;
                    r_descriptor_fifo_rden <= 1'b0;
                    o_report_en_ack <= 1'b1;
                    
                    ov_dcm_state        <= TRANS_REPORT_FIRST_CYCLE_S;
                end                
                else begin
                    r_data_fifo_rden <= 1'b0;
                    r_descriptor_fifo_rden <= 1'b0;
                    o_report_en_ack <= 1'b0;
                    
                    ov_dcm_state <= IDLE_S;
                end
            end
		    TRANS_RECEIVE_FIRST_CYCLE_S:begin
                r_data_fifo_rden <= 1'b1;
                r_descriptor_fifo_rden <= 1'b0;
                o_report_en_ack <= 1'b0;

                ov_data             <= wv_data_fifo_rdata;
                ov_descriptor       <= wv_descriptor_fifo_rdata;          
                o_data_wr           <= 1'b1;                    
                ov_dcm_state        <= TRANS_RECEIVE_FRAME_S;
            end 
            TRANS_RECEIVE_FRAME_S:begin
                ov_data             <= wv_data_fifo_rdata;
                ov_descriptor       <= ov_descriptor;          
                o_data_wr           <= 1'b1;   
                if(wv_data_fifo_rdata[8] == 1'b1)begin
                    r_data_fifo_rden <= 1'b0;
                    ov_dcm_state <= TRANS_DELAY_CYCLE_S;
                end
                else begin
                    ov_dcm_state <= TRANS_RECEIVE_FRAME_S;
                end
            end
		    TRANS_REPORT_FIRST_CYCLE_S:begin
                o_report_en_ack <= 1'b0;
                r_data_fifo_rden <= 1'b0;
                r_descriptor_fifo_rden <= 1'b0;
                if(rv_delay_cnt == 6'b1)begin
                    ov_data <= {1'b1,iv_data_csm};
                    ov_descriptor <= {19'h0,16'h1662};          
                    o_data_wr  <= 1'b1;                    
                    ov_dcm_state <= TRANS_REPORT_FRAME_S;  
                end
                else begin
                    rv_delay_cnt <= rv_delay_cnt + 1'b1;
                end
            end             
		    TRANS_REPORT_FRAME_S:begin
                o_report_en_ack <= 1'b0;
                r_data_fifo_rden <= 1'b0;
                r_descriptor_fifo_rden <= 1'b0;

                ov_descriptor <= ov_descriptor;          
                o_data_wr  <= 1'b1;                   
                if(i_data_csm_last)begin
                    ov_data <= {1'b1,iv_data_csm};
                    r_data_fifo_rden <= 1'b0;
                    ov_dcm_state <= TRANS_DELAY_CYCLE_S; 
                end
                else begin
                    ov_data <= {1'b0,iv_data_csm};
                    ov_dcm_state <= TRANS_REPORT_FRAME_S; 
                end                
            end            
            TRANS_DELAY_CYCLE_S:begin
                ov_data   <= 9'b0;
                ov_descriptor <= 35'b0;      
                o_data_wr <= 1'b0;
                
                r_data_fifo_rden <= 1'b0;
                if(rv_delay_cnt<40)begin
                    rv_delay_cnt <= rv_delay_cnt +1'b1;
                    ov_dcm_state <= TRANS_DELAY_CYCLE_S;
                end
                else begin
                    rv_delay_cnt <= 6'b0;
                    ov_dcm_state <= IDLE_S;
                end
            end
			default:begin
                o_report_en_ack <= 1'b0;
                r_data_fifo_rden <= 1'b0;
                r_descriptor_fifo_rden <= 1'b0;            
            
                ov_data   <= 9'b0;
                ov_descriptor <= 35'b0;  
                o_data_wr <= 1'b0;
                ov_dcm_state <= IDLE_S;	
			end
		endcase
   end
end	

dcm_fifo9x256 dcm_fifo9x256_inst(
    .data  (iv_data), 
    .wrreq (i_data_wr),
    .rdreq (r_data_fifo_rden),
    .clock (i_clk),
    .aclr  (!i_rst_n), 
    .q     (wv_data_fifo_rdata),    
    .usedw (),
    .full  (), 
    .empty (w_data_fifo_empty) 
);
fifo_35x4 descriptor_cache_inst(
    .data  (rv_descriptor_fifo_wdata), 
    .wrreq (r_descriptor_fifo_wr),
    .rdreq (r_descriptor_fifo_rden),
    .clock (i_clk),
    .aclr  (!i_rst_n), 
    .q     (wv_descriptor_fifo_rdata),    
    .usedw (),
    .full  (), 
    .empty (w_descriptor_fifo_empty) 
);

endmodule