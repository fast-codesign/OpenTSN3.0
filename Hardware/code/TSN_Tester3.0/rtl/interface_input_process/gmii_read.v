// Copyright (C) 1953-2020 NUDT
// Verilog module name - gmii_read
// Version: gmii_read_V1.0
// Created:
//         by - jintao peng
//         at - 06.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         Read data from fifo and record timestamp for PTP packet.
//             
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module gmii_read
(
		i_clk,
		i_rst_n,

        iv_relative_time,
        iv_syned_global_time,
        ov_relative_time,
        ov_global_time,
        
		iv_data,
		o_data_rd,
		i_data_empty,	

		ov_data,
		o_data_wr,
        
        o_fifo_underflow_pulse     
);

// I/O
// clk & rst
input					i_clk;
input					i_rst_n;

input       [18:0]      iv_relative_time;
input       [47:0]      iv_syned_global_time;
output  reg [18:0]      ov_relative_time;
output  reg [47:0]      ov_global_time;
// fifo read
output	reg				o_data_rd;
input		[8:0]		iv_data;
input					i_data_empty;
// data output
output	reg	[8:0]      	ov_data;
output	reg		      	o_data_wr;

output	reg             o_fifo_underflow_pulse;
// internal reg&wire
reg         [1:0]       delay_cycle;
reg	        [2:0]       grd_state;
localparam	IDLE_S 		  = 3'd0,
            DELAY_S       = 3'd1,
            FIRST_CYCLE_S = 3'd2,
            TRANS_S    	  = 3'd4,
            RDEMPTY_ERROR_S= 3'd5;
//***************************************************
//          	record timestamp 
//***************************************************
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n) begin
		o_data_rd <= 1'b0;
        delay_cycle <= 2'b0;      
        
		ov_data	<= 9'b0;
		o_data_wr <= 1'b0;
        o_fifo_underflow_pulse <= 1'b0;
        ov_relative_time <= 19'b0;        
        ov_global_time <= 48'b0;
        
		grd_state		 <= IDLE_S;
	end
	else begin
		case(grd_state)
			IDLE_S:begin
				ov_data <= 9'b0;
                o_data_wr <= 1'b0;
                delay_cycle <= 2'h0; 
                o_fifo_underflow_pulse <= 1'b0;
				if(i_data_empty == 1'b0)begin 
                    o_data_rd <= 1'b0;
                    ov_relative_time <= iv_relative_time;
                    ov_global_time <= iv_syned_global_time;
                    grd_state <= DELAY_S;                  
				end
                else begin	
                    o_data_rd <= 1'b0;
                    ov_relative_time <= 19'b0;                    
                    ov_global_time <= 48'b0;                    
                    grd_state <= IDLE_S;
                end
			end
            DELAY_S:begin
            	ov_data <= 9'b0;
				o_data_wr <= 1'b0;
                o_fifo_underflow_pulse <= 1'b0;
                if(delay_cycle == 2'h1)begin//delay 1 cycle
                    o_data_rd <= 1'b1;
                    delay_cycle <= 2'h0;
                    grd_state <= FIRST_CYCLE_S;
                end
                /*else if(delay_cycle == 2'h1)begin
                    o_data_rd <= 1'b1;
                    delay_cycle <= delay_cycle + 1'b1;
                    grd_state <= DELAY_S;
                end*/
                else begin
                    o_data_rd <= 1'b0;
                    delay_cycle <= delay_cycle + 1'b1;
                    grd_state <= DELAY_S;                    
                end
            end
			FIRST_CYCLE_S:begin          
                o_fifo_underflow_pulse <= 1'b0;
				if(iv_data[8] == 1'b1 && i_data_empty == 1'b0) begin
                    ov_data <= iv_data;
                    o_data_wr <= 1'b1; 
                    o_data_rd <= 1'b1;
                    grd_state <= TRANS_S;                           
				end
				else begin
					ov_data	<= 9'b0;
					o_data_wr <= 1'b0;
					o_data_rd <= 1'b0;					
					grd_state <= IDLE_S;
				end
			end
			TRANS_S:begin
				if(iv_data[8] == 1'b0 && i_data_empty == 1'b0) begin
					ov_data <= iv_data;
                    o_data_wr <= 1'b1;			
					o_data_rd <= 1'b1;
                    o_fifo_underflow_pulse <= 1'b0;
					grd_state <= TRANS_S;
                end	
				else if(iv_data[8] == 1'b1) begin
					ov_data	<= iv_data;
					o_data_wr <= 1'b1;
					o_data_rd <= 1'b0;
                    o_fifo_underflow_pulse <= 1'b0;					
					grd_state <= IDLE_S;
				end
				else if(i_data_empty == 1'b1)begin
					ov_data	<= {1'b1,8'b0};
					o_data_wr <= 1'b1;
					o_data_rd <= 1'b1;
                    o_fifo_underflow_pulse <= 1'b1;
					grd_state <= RDEMPTY_ERROR_S;
				end                
				else begin
					ov_data	<= 9'b0;
					o_data_wr <= 1'b0;
					o_data_rd <= 1'b0;
                    o_fifo_underflow_pulse <= 1'b0;
					grd_state <= IDLE_S;
				end
			end
            RDEMPTY_ERROR_S:begin
            	ov_data	<= 9'b0;
			    o_data_wr <= 1'b0;
                o_fifo_underflow_pulse <= 1'b0;
                if(iv_data[8] == 1'b1)begin
					o_data_rd <= 1'b0;					
					grd_state <= IDLE_S;
				end
				else begin
					o_data_rd <= 1'b1;
					grd_state <= RDEMPTY_ERROR_S;
				end             
            end
            default:begin
                ov_data <= 9'b0;
				o_data_wr <= 1'b0;
                o_data_rd <= 1'b0;
                o_fifo_underflow_pulse <= 1'b0; 
                grd_state <= IDLE_S;                
            end
		endcase
	end
end	
endmodule