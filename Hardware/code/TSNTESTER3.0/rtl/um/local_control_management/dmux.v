// Copyright (C) 1953-2020 NUDT
// Verilog module name - dmux
// Version: dmux_V1.0
// Created:
//         by - peng jintao
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         - dispatch ARP request frame、PTP frame、NMAC report frame to frame encapsulation module;
//         - dispatch TSMP frame to frame decapsulation module;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module dmux
(
    i_clk,
    i_rst_n,
    
    iv_data,
    iv_relative_time,
    i_data_wr,

    ov_relative_time,
    
	ov_data,
    o_data_csm_wr,
	o_data_npm_wr,
    o_data_fem_wr,
    o_data_fdm_wr
);

// I/O
// clk & rst
input                   i_clk;
input                   i_rst_n; 
// pkt input
input	   [133:0]	    iv_data;
input	   [18:0]       iv_relative_time;
input                   i_data_wr;

output reg [133:0]	    ov_data;

output reg	            o_data_csm_wr;
output reg	            o_data_npm_wr;
output reg	            o_data_fem_wr;
output reg	            o_data_fdm_wr;

output reg [18:0]       ov_relative_time;
//***************************************************
//                delay 2 cycle
//***************************************************
reg [133:0]	    rv_data1;
reg     	    r_data1_wr;
reg [133:0]	    rv_data2;
reg     	    r_data2_wr;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        rv_data1 <= 134'b0;
		r_data1_wr <= 1'b0;
        rv_data2 <= 134'b0;
		r_data2_wr <= 1'b0;
    end
    else begin
        rv_data1 <= iv_data;
		r_data1_wr <= i_data_wr;
        rv_data2 <= rv_data1;
		r_data2_wr <= r_data1_wr;    
    end
end
//***************************************************
//                dmux 1to2
//***************************************************
// internal reg&wire for state machine
reg  [2:0]    dmux_state;
localparam    IDLE_S = 3'd0,
              TRANS_TO_CSM_S  = 3'd1,
              TRANS_TO_NPM_S  = 3'd2,
              TRANS_TO_FEM_S  = 3'd3,
              TRANS_TO_FDM_S  = 3'd4,
              DISC_DATA_S = 3'd5;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data <= 134'b0;
        
		o_data_csm_wr <= 1'b0;
		o_data_npm_wr <= 1'b0;
		o_data_fem_wr <= 1'b0;
		o_data_fdm_wr <= 1'b0;        
        
        ov_relative_time <= 19'b0;
        dmux_state <= IDLE_S;
    end
    else begin
        case(dmux_state)
            IDLE_S:begin
                ov_data <= rv_data2;
		        if((r_data2_wr == 1'b1) && (rv_data2[133:132] == 2'b01))begin////first cycle
                    if((iv_data[31:16] == 16'hff01) && ((iv_data[15:12] == 4'h1)||(iv_data[15:12] == 4'h2)))begin////tsmp frame 
                        o_data_csm_wr <= r_data2_wr;
                        ov_relative_time <= 19'b0;
                        o_data_npm_wr <= 1'b0;
                        o_data_fem_wr <= 1'b0;
                        o_data_fdm_wr <= 1'b0;   
                        dmux_state <= TRANS_TO_CSM_S;
                    end
                    else if((iv_data[31:16] == 16'hff01) && (iv_data[15:8] == 8'h2))begin////tsmp frame 
                        o_data_csm_wr <= 1'b0;
                        ov_relative_time <= 19'b0;
                        o_data_npm_wr <= r_data2_wr;
                        o_data_fem_wr <= 1'b0;
                        o_data_fdm_wr <= 1'b0;  
                        dmux_state <= TRANS_TO_NPM_S;
                    end                    
                    else if(iv_data[31:16] == 16'h98f7)begin                  
                        o_data_csm_wr <= 1'b0;
                        ov_relative_time <= iv_relative_time;
                        o_data_npm_wr <= 1'b0;
                        o_data_fem_wr <= r_data2_wr;
                        o_data_fdm_wr <= 1'b0;  
                        dmux_state <= TRANS_TO_FEM_S;
                    end
                    else if((iv_data[31:16] == 16'hff01) && (iv_data[15:8] == 8'h05))begin
                        o_data_csm_wr <= 1'b0;
                        ov_relative_time <= 19'b0;
                        o_data_npm_wr <= 1'b0;
                        o_data_fem_wr <= 1'b0;
                        o_data_fdm_wr <= r_data2_wr;  
                        dmux_state <= TRANS_TO_FDM_S;                    
                    end
                    else begin
                        o_data_csm_wr <= 1'b0;
                        ov_relative_time <= 19'b0;
                        o_data_npm_wr <= 1'b0;
                        o_data_fem_wr <= 1'b0;
                        o_data_fdm_wr <= 1'b0;  
                        dmux_state <= DISC_DATA_S;                     
                    end                    
                end
                else begin
                    o_data_csm_wr <= 1'b0;
                    ov_relative_time <= 19'b0;
                    o_data_npm_wr <= 1'b0;
                    o_data_fem_wr <= 1'b0;
                    o_data_fdm_wr <= 1'b0;  
                    dmux_state <= IDLE_S;    
                end
            end
            TRANS_TO_CSM_S:begin
                ov_data <= rv_data2;
                o_data_csm_wr <= r_data2_wr;
                ov_relative_time <= 19'b0;
                o_data_npm_wr <= 1'b0;
                o_data_fem_wr <= 1'b0;
                o_data_fdm_wr <= 1'b0;  
                if((r_data2_wr == 1'b1) && (rv_data2[133:132] == 2'b10))begin////last cycle
                    dmux_state <= IDLE_S;
                end
                else begin
                    dmux_state <= TRANS_TO_CSM_S;
                end
            end
            TRANS_TO_NPM_S:begin
                ov_data <= rv_data2;
                o_data_csm_wr <= 1'b0;
                ov_relative_time <= 19'b0;
                o_data_npm_wr <= r_data2_wr;
                o_data_fem_wr <= 1'b0;
                o_data_fdm_wr <= 1'b0;  
                if((r_data2_wr == 1'b1) && (rv_data2[133:132] == 2'b10))begin////last cycle
                    dmux_state <= IDLE_S;
                end
                else begin
                    dmux_state <= TRANS_TO_NPM_S;
                end
            end
            TRANS_TO_FEM_S:begin
                ov_data <= rv_data2;
                o_data_csm_wr <= 1'b0;
                ov_relative_time <= ov_relative_time;
                o_data_npm_wr <= 1'b0;
                o_data_fem_wr <= r_data2_wr;
                o_data_fdm_wr <= 1'b0;  
                if((r_data2_wr == 1'b1) && (rv_data2[133:132] == 2'b10))begin////last cycle
                    dmux_state <= IDLE_S;
                end
                else begin
                    dmux_state <= TRANS_TO_FEM_S;
                end
            end 
            TRANS_TO_FDM_S:begin
                ov_data <= rv_data2;
                o_data_csm_wr <= 1'b0;
                ov_relative_time <= ov_relative_time;
                o_data_npm_wr <= 1'b0;
                o_data_fem_wr <= 1'b0;
                o_data_fdm_wr <= r_data2_wr;  
                if((r_data2_wr == 1'b1) && (rv_data2[133:132] == 2'b10))begin////last cycle
                    dmux_state <= IDLE_S;
                end
                else begin
                    dmux_state <= TRANS_TO_FDM_S;
                end
            end                         
            DISC_DATA_S:begin
                o_data_csm_wr <= 1'b0;
                ov_relative_time <= 19'b0;
                o_data_npm_wr <= 1'b0;
                o_data_fem_wr <= 1'b0;
                o_data_fdm_wr <= 1'b0;  
                if((r_data2_wr == 1'b1) && (rv_data2[133:132] == 2'b10))begin////last cycle
                    dmux_state <= IDLE_S;
                end
                else begin
                    dmux_state <= DISC_DATA_S;
                end
            end
            default:begin
                dmux_state <= IDLE_S;
            end
        endcase                    
    end
end	
endmodule