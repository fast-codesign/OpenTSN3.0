// Copyright (C) 1953-2020 NUDT
// Verilog module name - frame_receive_control
// Version: frame_receive_control_V1.0
// Created:
//         by - peng jintao 
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         -only forward tsmp frame when the network is in configuration;
//         -forward all frames after configuration of network is finished;
//         -put 8B metadata of PTP frame into end frame.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module pkt_read(
		i_clk,
		i_rst_n,
        
		iv_pkt_data,
		o_pkt_data_rd,
		i_pkt_data_empty,
        
        iv_time_length,
		o_time_length_rd,
		i_time_length_fifo_empty,

		ov_data,
        ov_relative_time,
		o_data_wr    
);

// I/O
// clk & rst
input					i_clk;
input					i_rst_n;
// fifo read
output	reg				o_pkt_data_rd;
input		[133:0]		iv_pkt_data;
input					i_pkt_data_empty;

input					i_time_length_fifo_empty;
output	reg				o_time_length_rd;
input		[30:0]		iv_time_length;
// data output
output	reg	[133:0]     ov_data;
output  reg [18:0]      ov_relative_time;
output	reg		      	o_data_wr;
//***************************************************
//          	frame receive control 
//***************************************************
// internal reg&wire
reg	        [1:0]      	frc_state;
localparam	IDLE_S = 2'd0,
            TRANS_MD0_S = 2'd1,
            TRANS_DATA_S = 2'd2;
always@(posedge i_clk or negedge i_rst_n)begin
	if(!i_rst_n) begin
		o_pkt_data_rd <= 1'b0;
		ov_data <= 134'b0;
        ov_relative_time <= 19'b0;
        o_data_wr <= 1'b0;
		o_time_length_rd <= 1'b0;

		frc_state <= IDLE_S;
	end
	else begin
		case(frc_state)
			IDLE_S:begin
                ov_data <= 134'b0;
                ov_relative_time <= 19'b0;
                o_data_wr <= 1'b0;
				if(i_time_length_fifo_empty == 1'b0)begin
                    o_time_length_rd <= 1'b1;
                    o_pkt_data_rd <= 1'b1;                
                    frc_state <= TRANS_MD0_S;	                            
				end
                else begin                         
                    o_pkt_data_rd <= 1'b0; 
                    o_time_length_rd <= 1'b0;                    
                    frc_state <= IDLE_S;
                end
			end
			TRANS_MD0_S:begin
			    o_time_length_rd <= 1'b0;
                o_pkt_data_rd <= 1'b1;
                
                ov_data[133:108] <= iv_pkt_data[133:108];
                ov_data[107:96] <= iv_time_length[11:0];
                ov_data[95:0] <= iv_pkt_data[95:0];
                ov_relative_time <= iv_time_length[30:12];
				o_data_wr <= 1'b1;				

			    frc_state <= TRANS_DATA_S;
			end
            TRANS_DATA_S:begin
			    o_time_length_rd <= 1'b0;
				o_data_wr <= 1'b1;				
				if(iv_pkt_data[133:132] == 2'b10) begin
                    o_pkt_data_rd <= 1'b0;
                    ov_data <= iv_pkt_data; 
                    frc_state <= IDLE_S;                    
				end
				else begin
                    ov_data <= iv_pkt_data;
                    o_pkt_data_rd <= 1'b1;
					frc_state <= TRANS_DATA_S;
				end
			end          
            default:begin
			    o_time_length_rd <= 1'b0;
                o_pkt_data_rd <= 1'b0;
                ov_data <= 134'b0;
				o_data_wr <= 1'b0;                
                frc_state <= IDLE_S;                
            end
		endcase
	end
end	
endmodule