// Copyright (C) 1953-2020 NUDT
// Verilog module name - frame_decapsulation_module
// Version: frame_decapsulation_module_V1.0
// Created:
//         by - peng jintao 
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         - decapsulate TSMP frame to ARP ack frame、PTP frame、NMAC configuration frame;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module frame_decapsulation_module
(
        i_clk,
        i_rst_n,
       
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

input                  i_timer_rst;
input      [47:0]      iv_syned_global_time;
// pkt input
input	   [133:0]	   iv_data;
input      [18:0]      iv_relative_time;
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
//               decapsulating frame
//***************************************************
// internal reg&wire for state machine
reg      [133:0]       rv_data;
reg                    r_data_wr;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        rv_data <= 134'b0;
		r_data_wr <= 1'b0;
    end
    else begin
        rv_data <= iv_data;
		r_data_wr <= i_data_wr;    
    end
end
//***************************************************
//               decapsulating frame
//***************************************************
// internal reg&wire for state machine
reg      [47:0]      rv_transmit_global_time;
reg      [1:0]       fdm_state;
localparam  IDLE_S = 2'd0,
            TRANS_MD1_S = 2'd1,
            TRANS_DATA_S = 2'd2;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data <= 134'b0;
		o_data_wr <= 1'b0;
        rv_transmit_global_time <= 48'b0;
		fdm_state <= IDLE_S;
    end
    else begin
		case(fdm_state)
			IDLE_S:begin
                rv_transmit_global_time <= 48'b0;            
				if((r_data_wr == 1'b1) && (rv_data[133:132] == 2'b01))begin//first cycle;discard the cycle and output metadata                    
                    ov_data <= {rv_data[133:127],1'b1,rv_data[125:0]};
                    o_data_wr <= r_data_wr;  
                    fdm_state <= TRANS_MD1_S;                    
                end
				else begin
                    ov_data <= 134'b0;
		            o_data_wr <= 1'b0;
					fdm_state <= IDLE_S;					
				end
			end
            TRANS_MD1_S:begin
                ov_data <= {rv_data[133:19],rv_timer};
                o_data_wr <= r_data_wr;
                rv_transmit_global_time <= iv_syned_global_time;
                fdm_state <= TRANS_DATA_S;              
            end         
            TRANS_DATA_S:begin 
                o_data_wr <= i_data_wr;
                if((i_data_wr == 1'b1) && (iv_data[133:132] == 2'b10))begin
                    ov_data <= {iv_data[133:96],rv_transmit_global_time,iv_data[47:0]};
                    fdm_state <= IDLE_S;   
                end
                else begin
                    ov_data <= iv_data;
                    fdm_state <= TRANS_DATA_S;  
                end                 
            end           
			default:begin
                ov_data <= 134'b0;
                o_data_wr <= 1'b0;
                rv_transmit_global_time <= 48'b0;   
                fdm_state <= IDLE_S;	
			end
		endcase
   end
end	
endmodule