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

module mux
(
        i_clk,
        i_rst_n,
       
        iv_data_fem,
	    i_data_wr_fem,
        
        iv_data_ddm,
	    i_data_wr_ddm,
	    
        ov_data,
        o_data_wr
);

// I/O
// clk & rst
input                   i_clk;
input                   i_rst_n;  
// pkt input from fem
input	   [8:0]	    iv_data_fem;
input	         	    i_data_wr_fem;
// pkt input from ddm
input	   [8:0]	    iv_data_ddm;
input	         	    i_data_wr_ddm;
// pkt output to mux
output reg [8:0]	    ov_data;
output reg	            o_data_wr;
//***************************************************
//               mux 2to1
//***************************************************
// internal reg&wire for state machine

always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data <= 9'b0;
		o_data_wr <= 1'b0;
    end
    else begin
        if(i_data_wr_fem == 1'b1)begin                   
            ov_data   <= iv_data_fem;
	        o_data_wr <= i_data_wr_fem;
        end
        else if(i_data_wr_ddm == 1'b1)begin                   
            ov_data <= iv_data_ddm;
	        o_data_wr <= i_data_wr_ddm;
        end
        else begin
            ov_data <= 9'b0;
            o_data_wr <= 1'b0; 
        end
    end
end

endmodule