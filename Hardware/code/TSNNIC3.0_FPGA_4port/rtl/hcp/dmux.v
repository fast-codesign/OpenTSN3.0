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
    
    iv_cfg_finish,
    
    iv_data,
	i_data_wr,
    iv_descriptor,

	ov_data_ddm,
    ov_descriptor_ddm,
	o_data_wr_ddm,
    
	ov_data_fem,
    ov_descriptor_fem,
	o_data_wr_fem
);

// I/O
// clk & rst
input                   i_clk;
input                   i_rst_n; 

input      [1:0]        iv_cfg_finish; 
// pkt input
input	   [8:0]	    iv_data;
input	         	    i_data_wr;
input      [34:0]       iv_descriptor;
// pkt output to DDM
output reg [8:0]	    ov_data_ddm;
output reg [34:0]       ov_descriptor_ddm;
output reg	            o_data_wr_ddm;
// pkt output to FEM
output reg [8:0]	    ov_data_fem;
output reg [34:0]       ov_descriptor_fem;
output reg	            o_data_wr_fem;

//***************************************************
//                dmux 1to2
//***************************************************
// internal reg&wire for state machine
reg  [2:0]    dmux_state;
localparam    IDLE_S = 3'd0,
              TRANS_TO_DDM_S  = 3'd1,
              TRANS_TO_FEM_S  = 3'd2,
              DISC_DATA_S = 3'd3;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data_fem <= 9'b0;
        ov_descriptor_fem <= 35'b0;
		o_data_wr_fem <= 1'b0;
		
        ov_data_ddm <= 9'b0;
        ov_descriptor_ddm <= 35'b0;
		o_data_wr_ddm <= 1'b0;
        dmux_state <= IDLE_S;
    end
    else begin
        case(dmux_state)
            IDLE_S:begin
		        if((i_data_wr == 1'b1) && (iv_data[8] == 1'b1))begin////first cycle
                    if(iv_descriptor[15:0] == 16'hff01)begin////tsmp frame 
                        if(iv_cfg_finish >= 2'd1)begin                    
                            ov_data_fem <= 9'b0;
                            ov_descriptor_fem <= 35'b0;
                            o_data_wr_fem <= 1'b0;
                            ov_data_ddm <= iv_data;
                            ov_descriptor_ddm <= iv_descriptor;
                            o_data_wr_ddm <= i_data_wr;
                            dmux_state <= TRANS_TO_DDM_S;
                        end
                        else begin
                            ov_data_fem <= 9'b0;
                            ov_descriptor_fem <= 35'b0;
		                    o_data_wr_fem <= 1'b0;
		                    
                            ov_data_ddm <= 9'b0;
                            ov_descriptor_ddm <= 35'b0;
		                    o_data_wr_ddm <= 1'b0;
                            dmux_state <= DISC_DATA_S;                        
                        end
                    end
                    else begin
                        if(iv_cfg_finish >= 2'd2)begin                    
                            ov_data_fem <= iv_data;
                            ov_descriptor_fem <= iv_descriptor;
                            o_data_wr_fem <= i_data_wr;
                            ov_data_ddm <= 9'b0;
                            ov_descriptor_ddm <= 35'b0;
                            o_data_wr_ddm <= 1'b0;
                            dmux_state <= TRANS_TO_FEM_S;
                        end
                        else begin
                            ov_data_fem <= 9'b0;
                            ov_descriptor_fem <= 35'b0;
		                    o_data_wr_fem <= 1'b0;
		                    
                            ov_data_ddm <= 9'b0;
                            ov_descriptor_ddm <= 35'b0;
		                    o_data_wr_ddm <= 1'b0;
                            dmux_state <= DISC_DATA_S;                        
                        end
                    end                    
                end
                else begin
                    ov_data_fem <= 9'b0;
                    ov_descriptor_fem <= 35'b0;
                    o_data_wr_fem <= 1'b0;
                    ov_data_ddm <= 9'b0;
                    ov_descriptor_ddm <= 35'b0;
                    o_data_wr_ddm <= 1'b0;
                    dmux_state <= IDLE_S;       
                end
            end
            TRANS_TO_FEM_S:begin
                ov_data_fem <= iv_data;
                ov_descriptor_fem <= iv_descriptor;
                o_data_wr_fem <= i_data_wr;
                ov_data_ddm <= 9'b0;
                ov_descriptor_ddm <= 35'b0;
                o_data_wr_ddm <= 1'b0;
                if((i_data_wr == 1'b1) && (iv_data[8] == 1'b1))begin////last cycle
                    dmux_state <= IDLE_S;
                end
                else begin
                    dmux_state <= TRANS_TO_FEM_S;
                end
            end
            TRANS_TO_DDM_S:begin
                ov_data_fem <= 9'b0;
                ov_descriptor_fem <= 35'b0;
                o_data_wr_fem <= 1'b0;
                ov_data_ddm <= iv_data;
                ov_descriptor_ddm <= iv_descriptor;
                o_data_wr_ddm <= i_data_wr;
                if((i_data_wr == 1'b1) && (iv_data[8] == 1'b1))begin////last cycle
                    dmux_state <= IDLE_S;
                end
                else begin
                    dmux_state <= TRANS_TO_DDM_S;
                end
            end
            DISC_DATA_S:begin
                ov_data_fem <= 9'b0;
                ov_descriptor_fem <= 35'b0;
                o_data_wr_fem <= 1'b0;
                
                ov_data_ddm <= 9'b0;
                ov_descriptor_ddm <= 35'b0;
                o_data_wr_ddm <= 1'b0;
                if((i_data_wr == 1'b1) && (iv_data[8] == 1'b1))begin////last cycle
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