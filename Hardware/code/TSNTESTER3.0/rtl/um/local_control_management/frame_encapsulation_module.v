// Copyright (C) 1953-2020 NUDT
// Verilog module name - frame_encapsulation_module
// Version: frame_encapsulation_module_V1.0
// Created:
//         by - peng jintao
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         - encapsulate ARP request frame、PTP frame、NMAC report frame to tsmp frame;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module frame_encapsulation_module
(
       i_clk,
       i_rst_n,
       
       iv_dmac,
       iv_smac,
       
       i_timer_rst,
       iv_syned_global_time,
        
       iv_data,
       iv_relative_time,       
	   i_data_wr,
	   
	   ov_data,
	   o_data_wr   
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// dmac and smac of tsmp frame from controller
input      [47:0]      iv_dmac;
input      [47:0]      iv_smac;

input                  i_timer_rst;
input      [47:0]      iv_syned_global_time;
// pkt input
input	   [133:0]	   iv_data;
input	   [18:0]      iv_relative_time;
input	         	   i_data_wr;
// pkt output to FEM
output reg [133:0]	   ov_data;
output reg	           o_data_wr;
//***************************************************
//                   timer
//***************************************************
reg    [18:0]          rv_timer;
always@(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n) begin
        rv_timer    <= 19'b0;
    end
    else begin
        if(i_timer_rst == 1'b1)begin
            rv_timer <= 19'b0;
        end
        else begin
            if(rv_timer == 19'd499999) begin //4ms
                rv_timer <= 19'b0;
            end
            else begin
                rv_timer <= rv_timer + 1'b1;
            end            
        end
    end
end
//***************************************************
//               delay 1 cycle
//***************************************************
reg    [133:0] rv_data1;
reg            r_data1_wr;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        rv_data1 <= 134'b0;
		r_data1_wr <= 1'b0;    
    end
    else begin
        rv_data1 <= iv_data;
		r_data1_wr <= i_data_wr;
    end
end
//***************************************************
//               encapsulating frame
//***************************************************
reg      [47:0]      rv_syned_global_time;
reg      [63:0]      rv_transparent_clock;
reg      [2:0]       fem_state;
localparam  IDLE_S = 3'd0,
            TRANS_MD1_S = 3'd1,
            TRANS_TSMP_HEAD_S = 3'd2,
            CALCU_TC_S = 3'd3,
            UPDATE_TC_S = 3'd4,
            TRANS_PTP_S = 3'd5;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data <= 134'b0;
		o_data_wr <= 1'b0;
        rv_syned_global_time <= 48'b0;
        rv_transparent_clock <= 64'b0;
		fem_state <= IDLE_S;
    end
    else begin
		case(fem_state)
			IDLE_S:begin
                rv_syned_global_time <= 48'b0;
                rv_transparent_clock <= 64'b0;
				if((i_data_wr == 1'b1) && (iv_data[133:132] == 2'b01))begin//first cycle;output metadata.
                    ov_data <= {iv_data[133:127],1'b1,iv_data[125:0]};
                    o_data_wr <= i_data_wr;
                    fem_state <= TRANS_MD1_S;
                end
				else begin
                    ov_data <= 134'b0;
                    o_data_wr <= 1'b0;
					fem_state <= IDLE_S;					
				end
			end
			TRANS_MD1_S:begin
                ov_data <= iv_data;
                o_data_wr <= i_data_wr;
                fem_state <= TRANS_TSMP_HEAD_S;
			end            
            TRANS_TSMP_HEAD_S:begin 
                o_data_wr <= 1'b1;
                ov_data[133:128] <= 6'b110000;
                ov_data[127:80] <= {iv_smac[47:24],8'h05,iv_smac[15:0]};//exchange the dmac and smac of  tsmp frame from controller;iv_smac[23:16] is revised to store subtype to recognize conveniently.                                
                ov_data[79:32] <= iv_dmac;
                ov_data[31:16] <= 16'hff01;//len/type
                ov_data[15:8] <= 8'h05; 
                ov_data[7:0] <= {4'h0,4'h0}; 
                fem_state <= CALCU_TC_S; 
            end
            CALCU_TC_S:begin 
                ov_data <= rv_data1;
                o_data_wr <= r_data1_wr;

                rv_syned_global_time <= iv_syned_global_time;
                if(rv_timer > iv_relative_time)begin
                    rv_transparent_clock <= iv_data[79:16] + rv_timer - iv_relative_time;
                end
                else begin//+4ms
                    rv_transparent_clock <= iv_data[79:16] + rv_timer + 19'd500000 - iv_relative_time;
                end 

                fem_state <= UPDATE_TC_S;	
            end
            UPDATE_TC_S:begin 
                ov_data <= {rv_data1[133:80],rv_transparent_clock,rv_data1[15:0]};
                o_data_wr <= r_data1_wr;

                fem_state <= TRANS_PTP_S;	
            end            
            TRANS_PTP_S:begin 
                if(r_data1_wr == 1'b1 && rv_data1[133:132] == 2'b10)begin//last cycle
                    ov_data <= {rv_data1[133:48],rv_syned_global_time};
                    o_data_wr <= r_data1_wr;
                    fem_state <= IDLE_S;
                end
				else begin//middle cycle  
					ov_data <= rv_data1;
                    o_data_wr <= r_data1_wr;
                    fem_state <= TRANS_PTP_S;	
				end
            end           
			default:begin
                ov_data <= 134'b0;
                o_data_wr <= 1'b0;
                fem_state <= IDLE_S;	
			end
		endcase
   end
end	
endmodule