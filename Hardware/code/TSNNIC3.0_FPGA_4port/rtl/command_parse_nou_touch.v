// Copyright (C) 1953-2020 NUDT
// Verilog module name - hcp_configuration_management
// Version: hcp_configuration_management_V1.0
// Created:
//         by - peng jintao 
//         at - 11.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         - decapsulate TSMP frame to ARP ack frame、PTP frame、NMAC configuration frame;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module command_parse
(
        i_clk,
        i_rst_n,
       
        iv_wr_command,
	    i_wr_command_wr,
        
        iv_rd_command,
        i_rd_command_wr,
        ov_rd_ack_command,
        
        ov_cfg_finish,
        ov_unmap_regulation_value,
        ov_rc_regulation_value,
        ov_be_regulation_value,

        ov_map_ram_wdata,
        o_map_ram_wr,
        ov_map_ram_addr,
        iv_map_ram_rdata,
        o_map_ram_rd,

        ov_regroup_ram_wdata,
        o_regroup_ram_wr,
        ov_regroup_ram_addr,
        iv_regroup_ram_rdata,
        o_regroup_ram_rd    
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// pkt input
input	   [203:0]	   iv_wr_command;
input	         	   i_wr_command_wr;

input      [203:0]     iv_rd_command;
input                  i_rd_command_wr;
output reg             ov_rd_ack_command;

output reg [1:0]       ov_cfg_finish;
output reg [8:0]       ov_rc_regulation_value;
output reg [8:0]       ov_be_regulation_value;
output reg [8:0]       ov_unmap_regulation_value;
// 5tuple mapping table
output reg [151:0]     ov_map_ram_wdata;
output reg             o_map_ram_wr;
output reg [4:0]       ov_map_ram_addr;
input      [151:0]     iv_map_ram_rdata;
output reg             o_map_ram_rd;
// regroup mapping table
output reg [61:0]      ov_regroup_ram_wdata;
output reg             o_regroup_ram_wr;
output reg [7:0]       ov_regroup_ram_addr;
input      [61:0]      iv_regroup_ram_rdata;
output reg             o_regroup_ram_rd;
//***************************************************
//               write command process
//***************************************************
reg [7:0]       rv_regroup_ram_waddr;
reg [4:0]       rv_map_ram_waddr;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_cfg_finish <= 2'b0; 
        ov_rc_regulation_value <= 9'b0;
        ov_be_regulation_value <= 9'b0;
        ov_unmap_regulation_value <= 9'b0;
        
        ov_map_ram_wdata <= 152'b0;
        rv_map_ram_waddr <= 5'b0;
        o_map_ram_wr <= 1'b0;
        ov_regroup_ram_wdata <= 62'b0;
        rv_regroup_ram_waddr <= 8'b0;
        o_regroup_ram_wr <= 1'b0;       
    end
    else begin      
        if((i_wr_command_wr == 1'b1) && (iv_wr_command[187:184] == 4'b0001))begin//command for write          
            if(iv_wr_command[195:188] == 8'h0)begin//config configure_state_manage
                case(iv_wr_command[183:152])
                    32'h3:ov_cfg_finish <= iv_wr_command[1:0];
                    32'hc:ov_rc_regulation_value <= iv_wr_command[8:0];
                    32'hd:ov_be_regulation_value <= iv_wr_command[8:0];
                    32'he:ov_unmap_regulation_value <= iv_wr_command[8:0];
                    default:begin
                        ov_cfg_finish <= ov_cfg_finish;
                        ov_rc_regulation_value <= ov_rc_regulation_value;
                        ov_be_regulation_value <= ov_be_regulation_value;
                        ov_unmap_regulation_value <= ov_unmap_regulation_value;
                    end
                endcase
            end
            else if(iv_wr_command[195:188] == 8'hd)begin//config packet_map_dispatch module    
                ov_regroup_ram_wdata <= 62'b0;
                rv_regroup_ram_waddr <= 8'b0;
                o_regroup_ram_wr <= 1'b0;                         
                if(iv_wr_command[183:152] <= 32'h1f)begin
                    ov_map_ram_wdata <= iv_wr_command[151:0];
                    rv_map_ram_waddr <= iv_wr_command[156:152];
                    o_map_ram_wr <= 1'b1;                            
                end
                else begin
                    ov_map_ram_wdata <= 152'b0;
                    rv_map_ram_waddr <= 5'b0;
                    o_map_ram_wr <= 1'b0;
                end
            end
            else if(iv_wr_command[195:188] == 8'he)begin//config frame_inverse_mapping module
                ov_map_ram_wdata <= 152'b0;
                rv_map_ram_waddr <= 5'b0;
                o_map_ram_wr <= 1'b0;
                if(iv_wr_command[183:152] <= 32'hff)begin
                    ov_regroup_ram_wdata <= iv_wr_command[61:0];
                    rv_regroup_ram_waddr <= iv_wr_command[159:152];
                    o_regroup_ram_wr <= 1'b1;                                        
                end
                else begin
                    ov_regroup_ram_wdata <= 62'b0;
                    rv_regroup_ram_waddr <= 8'b0;
                    o_regroup_ram_wr <= 1'b0; 
                end
            end
            else begin
                ov_map_ram_wdata <= 152'b0;
                rv_map_ram_waddr <= 5'b0;
                o_map_ram_wr <= 1'b0;

                ov_regroup_ram_wdata <= 62'b0;
                rv_regroup_ram_waddr <= 8'b0;
                o_regroup_ram_wr <= 1'b0;                         
            end                    
        end
        else begin          
            ov_map_ram_wdata <= 152'b0;
            rv_map_ram_waddr <= 5'b0;
            o_map_ram_wr <= 1'b0;

            ov_regroup_ram_wdata <= 62'b0;
            rv_regroup_ram_waddr <= 8'b0;
            o_regroup_ram_wr <= 1'b0;         
        end
    end
end
//***************************************************
//               read command process
//***************************************************
reg      [31:0]      rv_read_flag;
reg      [7:0]       rv_regroup_ram_raddr;
reg      [4:0]       rv_map_ram_raddr;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        rv_read_flag <= 32'b0;
        
        rv_map_ram_raddr <= 5'b0;
        o_map_ram_rd <= 1'b0;

        rv_regroup_ram_raddr <= 8'b0;
        o_regroup_ram_rd <= 1'b0;
    end
    else begin      
        if((i_rd_command_wr == 1'b1) && (iv_rd_command[187:184] == 4'b0010))begin//command for read             
            if(iv_rd_command[195:188] == 8'h0)begin//read configure_state_manage 
                o_map_ram_rd <= 1'b0; 
                o_regroup_ram_rd <= 1'b0; 
                case(iv_rd_command[183:152])
                    32'h3:begin
                        rv_read_flag <= {31'b0,1'b1};                                 
                    end
                    32'hc:begin
                        rv_read_flag <= {30'b0,1'b1,1'b0};                                  
                    end 
                    32'hd:begin
                        rv_read_flag <= {29'b0,1'b1,2'b0};                                 
                    end 
                    32'he:begin
                        rv_read_flag <= {28'b0,1'b1,3'b0};                                 
                    end                               
                    default:begin
                        rv_read_flag <= 32'b0;
                    end
                endcase                    
            end
            else if(iv_rd_command[195:188] == 8'hd)begin//read packet_map_dispatch module  
                o_regroup_ram_rd <= 1'b0; 
                if(iv_rd_command[183:152] <= 32'h1f)begin//read mapping table
                    rv_map_ram_raddr <= iv_rd_command[156:152];
                    o_map_ram_rd <= 1'b1; 
                    rv_read_flag <= {15'b0,1'b1,16'b0};                                                       
                end
                else begin
                    rv_map_ram_raddr <= 5'b0;
                    o_map_ram_rd <= 1'b0;
                    rv_read_flag <= 32'b0;                              
                end
            end
            else if(iv_rd_command[195:188] == 8'he)begin//read packet_map_dispatch module  
                o_map_ram_rd <= 1'b0;
                if(iv_rd_command[183:152] <= 32'hff)begin
                    rv_regroup_ram_raddr <= iv_rd_command[159:152];
                    o_regroup_ram_rd <= 1'b1; 
                    rv_read_flag <= {14'b0,1'b1,1'b0,16'b0};                                                              
                end
                else begin
                    rv_regroup_ram_raddr <= 8'b0;
                    o_regroup_ram_rd <= 1'b0; 
                    rv_read_flag <= 32'b0;
                end
            end					
	    end	
        else begin
            rv_read_flag <= 32'b0;
            
            rv_map_ram_raddr <= 5'b0;
            o_map_ram_rd <= 1'b0;

            rv_regroup_ram_raddr <= 8'b0;
            o_regroup_ram_rd <= 1'b0;             
        end
    end
end
//***************************************************
//               delay control
//***************************************************
reg     [31:0]        rv_read_flag_delay0;
reg     [31:0]        rv_read_flag_delay1;

reg     [204:0]       rv_command_delay0;
reg     [204:0]       rv_command_delay1;
reg     [204:0]       rv_command_delay2;
always @(posedge i_clk or negedge i_rst_n) begin // read ram have two cycle delay
    if(!i_rst_n)begin
        rv_read_flag_delay0 <= 32'h0;
        rv_read_flag_delay1 <= 32'h0;
        
        rv_command_delay0 <= 204'b0;
        rv_command_delay1 <= 204'b0;
        rv_command_delay2 <= 204'b0;
    end
    else begin
        rv_read_flag_delay0 <= rv_read_flag;
        rv_read_flag_delay1 <= rv_read_flag_delay0;
        
        rv_command_delay0   <= iv_rd_command;
        rv_command_delay1   <= rv_command_delay0;
        rv_command_delay2   <= rv_command_delay1;
    end
end

always @(posedge i_clk or negedge i_rst_n) begin // read ram have two cycle delay
    if(!i_rst_n)begin
        ov_rd_ack_command <= 204'b0;
    end
    else begin
        if(|rv_read_flag_delay1 == 1'b1)begin      
            case(rv_read_flag_delay1)
                32'h0000_0001:begin
                    ov_rd_ack_command[203:188] <= rv_command_delay2[203:188];
                    ov_rd_ack_command[187:184] <= 4'b0110;//type:read ack
                    ov_rd_ack_command[183:152] <= rv_command_delay2[183:152];//addr  
                    ov_rd_ack_command[151:0] <= {150'b0,ov_cfg_finish};
                end
                32'h0000_0002:begin
                    ov_rd_ack_command[203:188] <= rv_command_delay2[203:188];
                    ov_rd_ack_command[187:184] <= 4'b0110;//type:read ack
                    ov_rd_ack_command[183:152] <= rv_command_delay2[183:152];//addr             
                    ov_rd_ack_command[151:0] <= {143'b0,ov_rc_regulation_value};
                end
                32'h0000_0004:begin
                    ov_rd_ack_command[203:188] <= rv_command_delay2[203:188];
                    ov_rd_ack_command[187:184] <= 4'b0110;//type:read ack
                    ov_rd_ack_command[183:152] <= rv_command_delay2[183:152];//addr                 
                    ov_rd_ack_command[151:0] <= {143'b0,ov_be_regulation_value};
                end
                32'h0000_0008:begin
                    ov_rd_ack_command[203:188] <= rv_command_delay2[203:188];
                    ov_rd_ack_command[187:184] <= 4'b0110;//type:read ack
                    ov_rd_ack_command[183:152] <= rv_command_delay2[183:152];//addr                 
                    ov_rd_ack_command[151:0] <= {143'b0,ov_unmap_regulation_value};
                end
                32'h0001_0000:begin
                    ov_rd_ack_command[203:188] <= rv_command_delay2[203:188];
                    ov_rd_ack_command[187:184] <= 4'b0110;//type:read ack
                    ov_rd_ack_command[183:152] <= rv_command_delay2[183:152];//addr                  
                    ov_rd_ack_command[151:0] <= {143'b0,iv_map_ram_rdata};
                end 
                32'h0002_0000:begin
                    ov_rd_ack_command[203:188] <= rv_command_delay2[203:188];
                    ov_rd_ack_command[187:184] <= 4'b0110;//type:read ack
                    ov_rd_ack_command[183:152] <= rv_command_delay2[183:152];//addr                 
                    ov_rd_ack_command[151:0] <= {143'b0,iv_regroup_ram_rdata};
                end
                default:begin
                    ov_rd_ack_command[203:0] <= 204'b0;
                end 
            endcase
        end            
        else begin
            ov_rd_ack_command <= 204'b0;
        end
    end
end
endmodule