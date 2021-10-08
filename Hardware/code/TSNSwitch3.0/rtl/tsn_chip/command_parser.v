// Copyright (C) 1953-2021 NUDT
// Verilog module name - command_parser
// Version: FPA_V1.0
// Created:
//         by - fenglin 
//         at - 1.2021
////////////////////////////////////////////////////////////////////////////
// Description:
//         Command Phase 
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module command_parser
    (
        i_clk,
        i_rst_n,
        
        iv_wr_command,   
        i_wr_command_wr,     
        ov_rd_command_ack,           
        i_rd_command_wr,
        iv_rd_command,
        
        //nip 
        ov_be_threshold_value,
        ov_rc_threshold_value,
        ov_map_req_threshold_value,
        ov_port_type,
        ov_cfg_finish,
        
        //flt
        ov_flt_ram_addr, 
        ov_flt_ram_wdata,
        o_flt_ram_wr,    
        iv_flt_ram_rdata,
        o_flt_ram_rd,   
        //nop
        o_qbv_or_qch,
             
        ov_nop0_ram_addr,    
        ov_nop0_ram_wdata,   
        o_nop0_ram_wr,       
        iv_nop0_ram_rdata,   
        o_nop0_ram_rd,       

        ov_nop1_ram_addr,    
        ov_nop1_ram_wdata,   
        o_nop1_ram_wr,       
        iv_nop1_ram_rdata,   
        o_nop1_ram_rd,       		
        
        ov_nop2_ram_addr,    
        ov_nop2_ram_wdata,   
        o_nop2_ram_wr,       
        iv_nop2_ram_rdata,   
        o_nop2_ram_rd,         		

        ov_nop3_ram_addr,    
        ov_nop3_ram_wdata,   
        o_nop3_ram_wr,       
        iv_nop3_ram_rdata,   
        o_nop3_ram_rd,        		

        ov_nop4_ram_addr,    
        ov_nop4_ram_wdata,   
        o_nop4_ram_wr,       
        iv_nop4_ram_rdata,   
        o_nop4_ram_rd	
		  
    );

// I/O
// clk & rst
input                   i_clk;
input                   i_rst_n;
           
input       [203:0]     iv_wr_command;   
input                   i_wr_command_wr; 
output  reg [203:0]     ov_rd_command_ack;
input                   i_rd_command_wr;
input       [203:0]     iv_rd_command;   
           
 //nip     
output  reg [8:0]       ov_be_threshold_value;
output  reg [8:0]       ov_rc_threshold_value;
output  reg [8:0]       ov_map_req_threshold_value;
//
output  reg [7:0]       ov_port_type;
output  reg [1:0]       ov_cfg_finish;
		    
            //flt       
output      [13:0]      ov_flt_ram_addr; 
output  reg [8:0]       ov_flt_ram_wdata;
output                  o_flt_ram_wr;    
input      [8:0]        iv_flt_ram_rdata;
output                  o_flt_ram_rd;   

            //nop
output reg              o_qbv_or_qch;

output     [9:0]        ov_nop0_ram_addr;    
output reg [7:0]        ov_nop0_ram_wdata;   
output                  o_nop0_ram_wr;       
input      [7:0]        iv_nop0_ram_rdata;   
output                  o_nop0_ram_rd;         
            
output     [9:0]        ov_nop1_ram_addr;    
output reg [7:0]        ov_nop1_ram_wdata;   
output                  o_nop1_ram_wr;       
input      [7:0]        iv_nop1_ram_rdata;   
output                  o_nop1_ram_rd;         		
            
output     [9:0]        ov_nop2_ram_addr;    
output reg [7:0]        ov_nop2_ram_wdata;   
output                  o_nop2_ram_wr;       
input      [7:0]        iv_nop2_ram_rdata;   
output                  o_nop2_ram_rd;        		
            
output     [9:0]        ov_nop3_ram_addr;    
output reg [7:0]        ov_nop3_ram_wdata;   
output                  o_nop3_ram_wr;       
input      [7:0]        iv_nop3_ram_rdata;   
output                  o_nop3_ram_rd;       		
            
output     [9:0]        ov_nop4_ram_addr;    
output reg [7:0]        ov_nop4_ram_wdata;   
output                  o_nop4_ram_wr;       
input      [7:0]        iv_nop4_ram_rdata;   
output                  o_nop4_ram_rd;        		

//***************************************************
//               write command process
//***************************************************
reg             r_qgc0_ram_wr;
reg [9:0]       rv_qgc0_ram_waddr;
reg             r_qgc1_ram_wr;
reg [9:0]       rv_qgc1_ram_waddr;
reg             r_qgc2_ram_wr;
reg [9:0]       rv_qgc2_ram_waddr;
reg             r_qgc3_ram_wr;
reg [9:0]       rv_qgc3_ram_waddr;
reg             r_qgc4_ram_wr;
reg [9:0]       rv_qgc4_ram_waddr;

reg             r_flt_ram_wr;
reg [13:0]      rv_flt_ram_waddr;

always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
		ov_cfg_finish     <= 2'b0;
        ov_port_type      <= 8'hff;
        o_qbv_or_qch      <= 1'b0;
        ov_be_threshold_value      <=  8'b0;
        ov_rc_threshold_value      <=  8'b0;
        ov_map_req_threshold_value <=  8'b0;      
        ov_nop0_ram_wdata <= 8'b0;
        ov_nop1_ram_wdata <= 8'b0;
        ov_nop2_ram_wdata <= 8'b0;
        ov_nop3_ram_wdata <= 8'b0;
        ov_nop4_ram_wdata <= 8'b0;
        ov_flt_ram_wdata<= 9'b0;
        
        r_qgc0_ram_wr<= 1'b0;
        rv_qgc0_ram_waddr<= 10'b0;
        r_qgc1_ram_wr<= 1'b0;
        rv_qgc1_ram_waddr<= 10'b0;
        r_qgc2_ram_wr<= 1'b0;
        rv_qgc2_ram_waddr<= 10'b0;
        r_qgc3_ram_wr<= 1'b0;
        rv_qgc3_ram_waddr<= 10'b0;
        r_qgc4_ram_wr<= 1'b0;
        rv_qgc4_ram_waddr<= 10'b0;
        r_flt_ram_wr<= 1'b0;
        rv_flt_ram_waddr<= 14'b0;
         
	end
    else begin
        if((i_wr_command_wr == 1'b1)&&(iv_wr_command[187:184]==4'b0001))begin//command write enable
            case(iv_wr_command[195:188])
                8'h0:begin //reg cfg
                    case(iv_wr_command[183:152])//reg addr
                        32'h3:ov_cfg_finish <= iv_wr_command[1:0];
                        32'h4:ov_port_type  <= iv_wr_command[7:0];
                        32'h5:o_qbv_or_qch  <= iv_wr_command[0];
                        32'hc:ov_rc_threshold_value        <= iv_wr_command[8:0];
                        32'hd:ov_be_threshold_value        <= iv_wr_command[8:0];
                        32'he:ov_map_req_threshold_value   <= iv_wr_command[8:0];
                        default:begin
                               ov_cfg_finish <= ov_cfg_finish ;
                               ov_port_type  <= ov_port_type  ;
                               o_qbv_or_qch  <= o_qbv_or_qch  ;
                               ov_be_threshold_value        <=ov_be_threshold_value     ;
                               ov_rc_threshold_value        <=ov_rc_threshold_value     ;
                               ov_map_req_threshold_value   <=ov_map_req_threshold_value;
                        end
                    endcase
                end
                8'h3:begin //port 0 qgc
                    ov_nop0_ram_wdata <= iv_wr_command[7:0];
                    rv_qgc0_ram_waddr <= iv_wr_command[161:152];
                    r_qgc0_ram_wr     <= 1'b1; 
                    
                end
                8'h4:begin //port 1 qgc
                    ov_nop1_ram_wdata <= iv_wr_command[7:0];
                    rv_qgc1_ram_waddr <= iv_wr_command[161:152];
                    r_qgc1_ram_wr     <= 1'b1;                     
                end
                8'h5:begin //port 2 qgc
                    ov_nop2_ram_wdata <= iv_wr_command[7:0];
                    rv_qgc2_ram_waddr <= iv_wr_command[161:152];
                    r_qgc2_ram_wr     <= 1'b1;                                         
                end                           
                8'h6:begin //port 3 qgc
                    ov_nop3_ram_wdata <= iv_wr_command[7:0];
                    rv_qgc3_ram_waddr <= iv_wr_command[161:152];
                    r_qgc3_ram_wr     <= 1'b1;                     
                end                           
                8'h7:begin //port 4 qgc
                    ov_nop4_ram_wdata <= iv_wr_command[7:0];
                    rv_qgc4_ram_waddr <= iv_wr_command[161:152];
                    r_qgc4_ram_wr     <= 1'b1;                                                         
                end                       
                8'hc:begin //flt cfg
                    ov_flt_ram_wdata<= iv_wr_command[8:0];
                    rv_flt_ram_waddr <= iv_wr_command[165:152];
                    r_flt_ram_wr     <= 1'b1;                     
                end     
                default:begin 
                    ov_cfg_finish    <= ov_cfg_finish ;
                    ov_port_type     <= ov_port_type  ;
                    o_qbv_or_qch     <= o_qbv_or_qch  ;
                    ov_be_threshold_value        <=  ov_be_threshold_value      ;
                    ov_rc_threshold_value        <=  ov_rc_threshold_value      ;
                    ov_map_req_threshold_value   <=  ov_map_req_threshold_value ;
                    
                    ov_nop0_ram_wdata <= 8'b0;
                    ov_nop1_ram_wdata <= 8'b0;
                    ov_nop2_ram_wdata <= 8'b0;
                    ov_nop3_ram_wdata <= 8'b0;
                    ov_nop4_ram_wdata <= 8'b0;
                    ov_flt_ram_wdata<= 9'b0;
                    r_qgc0_ram_wr<= 1'b0;
                    rv_qgc0_ram_waddr<= 10'b0;
                    r_qgc1_ram_wr<= 1'b0;
                    rv_qgc1_ram_waddr<= 10'b0;
                    r_qgc2_ram_wr<= 1'b0;
                    rv_qgc2_ram_waddr<= 10'b0;
                    r_qgc3_ram_wr<= 1'b0;
                    rv_qgc3_ram_waddr<= 10'b0;
                    r_qgc4_ram_wr<= 1'b0;
                    rv_qgc4_ram_waddr<= 10'b0;
                    r_flt_ram_wr<= 1'b0;
                    rv_flt_ram_waddr<= 14'b0;

                end    
            endcase
        end
        else begin
            ov_cfg_finish    <= ov_cfg_finish;
            ov_port_type     <= ov_port_type ;
            o_qbv_or_qch     <= o_qbv_or_qch ;
            ov_be_threshold_value        <=  ov_be_threshold_value     ;
            ov_rc_threshold_value        <=  ov_rc_threshold_value     ;
            ov_map_req_threshold_value   <=  ov_map_req_threshold_value;
            
            ov_nop0_ram_wdata <= 8'b0;
            ov_nop1_ram_wdata <= 8'b0;
            ov_nop2_ram_wdata <= 8'b0;
            ov_nop3_ram_wdata <= 8'b0;
            ov_nop4_ram_wdata <= 8'b0;
            ov_flt_ram_wdata<= 9'b0;

            r_qgc0_ram_wr<= 1'b0;
            rv_qgc0_ram_waddr<= 10'b0;
            r_qgc1_ram_wr<= 1'b0;
            rv_qgc1_ram_waddr<= 10'b0;
            r_qgc2_ram_wr<= 1'b0;
            rv_qgc2_ram_waddr<= 10'b0;
            r_qgc3_ram_wr<= 1'b0;
            rv_qgc3_ram_waddr<= 10'b0;
            r_qgc4_ram_wr<= 1'b0;
            rv_qgc4_ram_waddr<= 10'b0;
            r_flt_ram_wr<= 1'b0;
            rv_flt_ram_waddr<= 14'b0;
        end                          
    end        
end            
//***************************************************
//               read command process
//***************************************************
reg                  r_cfg_finish_rd;
reg                  r_port_type_rd;
reg                  r_qbv_or_qch_rd;
reg                  r_rc_threshold_rd;
reg                  r_be_threshold_rd;
reg                  r_unmap_threshold_rd;

reg                  r_nop0_ram_rd;
reg      [9:0]       rv_nop0_ram_raddr;
reg                  r_nop1_ram_rd;
reg      [9:0]       rv_nop1_ram_raddr;
reg                  r_nop2_ram_rd;
reg      [9:0]       rv_nop2_ram_raddr;
reg                  r_nop3_ram_rd;
reg      [9:0]       rv_nop3_ram_raddr;
reg                  r_nop4_ram_rd;
reg      [9:0]       rv_nop4_ram_raddr;
reg                  r_flt_ram_rd;
reg      [13:0]      rv_flt_ram_raddr;
            
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        r_cfg_finish_rd <= 1'b0;
        r_port_type_rd <= 1'b0;
        r_qbv_or_qch_rd <= 1'b0;
        r_rc_threshold_rd <= 1'b0;
        r_be_threshold_rd <= 1'b0;
        r_unmap_threshold_rd <= 1'b0;   
        
        r_nop0_ram_rd <= 1'b0;
        rv_nop0_ram_raddr  <= 10'b0;
        r_nop1_ram_rd <= 1'b0;
        rv_nop1_ram_raddr  <= 10'b0;
        r_nop2_ram_rd <= 1'b0;
        rv_nop2_ram_raddr  <= 10'b0;
        r_nop3_ram_rd <= 1'b0;
        rv_nop3_ram_raddr  <= 10'b0;        
        r_nop4_ram_rd <= 1'b0;
        rv_nop4_ram_raddr  <= 10'b0;
 
        r_flt_ram_rd <= 1'b0;
        rv_flt_ram_raddr  <= 14'b0;        
    end
    else begin        
        if((i_rd_command_wr == 1'b1) && (iv_rd_command[187:184] == 4'b0010))begin//command read enable
            if(iv_rd_command[195:188]==8'h0)begin
                r_flt_ram_rd <= 1'b0;
                r_nop0_ram_rd <= 1'b0;
                r_nop1_ram_rd <= 1'b0;
                r_nop2_ram_rd <= 1'b0;
                r_nop3_ram_rd <= 1'b0;
                r_nop4_ram_rd <= 1'b0;
                case(iv_rd_command[183:152])
                    32'h3:begin
                        r_cfg_finish_rd <= 1'b1;
                        r_port_type_rd <= 1'b0;
                        r_qbv_or_qch_rd <= 1'b0;
                        r_rc_threshold_rd <= 1'b0;
                        r_be_threshold_rd <= 1'b0;
                        r_unmap_threshold_rd <= 1'b0;                               
                    end
                    32'h4:begin
                        r_cfg_finish_rd <= 1'b0;
                        r_port_type_rd <= 1'b1;
                        r_qbv_or_qch_rd <= 1'b0;
                        r_rc_threshold_rd <= 1'b0;
                        r_be_threshold_rd <= 1'b0;
                        r_unmap_threshold_rd <= 1'b0;                               
                    end    
                    32'h5:begin
                        r_cfg_finish_rd <= 1'b0;
                        r_port_type_rd <= 1'b0;
                        r_qbv_or_qch_rd <= 1'b1;
                        r_rc_threshold_rd <= 1'b0;
                        r_be_threshold_rd <= 1'b0;
                        r_unmap_threshold_rd <= 1'b0;                               
                    end                        
                    32'hc:begin
                        r_cfg_finish_rd <= 1'b0;
                        r_port_type_rd <= 1'b0;
                        r_qbv_or_qch_rd <= 1'b0;
                        r_rc_threshold_rd   <= 1'b1;
                        r_be_threshold_rd <= 1'b0;
                        r_unmap_threshold_rd <= 1'b0;                                 
                    end 
                    32'hd:begin
                        r_cfg_finish_rd <= 1'b0;
                        r_port_type_rd <= 1'b0;
                        r_qbv_or_qch_rd <= 1'b0;
                        r_rc_threshold_rd <= 1'b0;
                        r_be_threshold_rd <= 1'b1;
                        r_unmap_threshold_rd <= 1'b0;                               
                    end 
                    32'he:begin
                        r_cfg_finish_rd <= 1'b0;
                        r_port_type_rd <= 1'b0;
                        r_qbv_or_qch_rd <= 1'b0;
                        r_rc_threshold_rd <= 1'b0;
                        r_be_threshold_rd <= 1'b0;
                        r_unmap_threshold_rd <= 1'b1;                               
                    end                               
                    default:begin
                        r_cfg_finish_rd <= 1'b0;
                        r_port_type_rd <= 1'b0;
                        r_qbv_or_qch_rd <= 1'b0;
                        r_rc_threshold_rd <= 1'b0;
                        r_be_threshold_rd <= 1'b0;
                        r_unmap_threshold_rd <= 1'b0;   
                    end 
                endcase    
            end
            else if(iv_rd_command[195:188] == 8'h3)begin
                r_flt_ram_rd <= 1'b0;
                r_nop1_ram_rd <= 1'b0;
                r_nop2_ram_rd <= 1'b0;
                r_nop3_ram_rd <= 1'b0;
                r_nop4_ram_rd <= 1'b0;
                r_cfg_finish_rd <= 1'b0;
                r_port_type_rd <= 1'b0;
                r_qbv_or_qch_rd <= 1'b0;
                r_rc_threshold_rd <= 1'b0;
                r_be_threshold_rd <= 1'b0;
                r_unmap_threshold_rd <= 1'b0; 
                if(iv_rd_command[183:152] <= 32'h3ff)begin//read qgc0 table
                    rv_nop0_ram_raddr  <= iv_rd_command[161:152];
                    r_nop0_ram_rd <= 1'b1;
                end
                else begin
                    rv_nop0_ram_raddr <= 10'b0;
                    r_nop0_ram_rd <= 1'b0;                           
                end 
            end    
            else if(iv_rd_command[195:188] == 8'h4)begin
                r_flt_ram_rd <= 1'b0;
                r_nop0_ram_rd <= 1'b0;
                r_nop2_ram_rd <= 1'b0;
                r_nop3_ram_rd <= 1'b0;
                r_nop4_ram_rd <= 1'b0;
                r_cfg_finish_rd <= 1'b0;
                r_port_type_rd <= 1'b0;
                r_qbv_or_qch_rd <= 1'b0;
                r_rc_threshold_rd <= 1'b0;
                r_be_threshold_rd <= 1'b0;
                r_unmap_threshold_rd <= 1'b0; 
                if(iv_rd_command[183:152] <= 32'h3ff)begin//read qgc1 table
                    rv_nop1_ram_raddr  <= iv_rd_command[161:152];
                    r_nop1_ram_rd <= 1'b1;
                end
                else begin
                    rv_nop1_ram_raddr <= 10'b0;
                    r_nop1_ram_rd <= 1'b0;                           
                end 
            end   
            else if(iv_rd_command[195:188] == 8'h5)begin
                r_flt_ram_rd <= 1'b0;
                r_nop0_ram_rd <= 1'b0;
                r_nop1_ram_rd <= 1'b0;
                r_nop3_ram_rd <= 1'b0;
                r_nop4_ram_rd <= 1'b0;
                r_cfg_finish_rd <= 1'b0;
                r_port_type_rd <= 1'b0;
                r_qbv_or_qch_rd <= 1'b0;
                r_rc_threshold_rd <= 1'b0;
                r_be_threshold_rd <= 1'b0;
                r_unmap_threshold_rd <= 1'b0; 
                if(iv_rd_command[183:152] <= 32'h3ff)begin//read qgc2 table
                    rv_nop2_ram_raddr  <= iv_rd_command[161:152];
                    r_nop2_ram_rd <= 1'b1;
                end
                else begin
                    rv_nop2_ram_raddr <= 10'b0;
                    r_nop2_ram_rd <= 1'b0;                           
                end 
            end                    
            else if(iv_rd_command[195:188] == 8'h6)begin
                r_flt_ram_rd <= 1'b0;
                r_nop0_ram_rd <= 1'b0;
                r_nop1_ram_rd <= 1'b0;
                r_nop2_ram_rd <= 1'b0;
                r_nop4_ram_rd <= 1'b0;
                r_cfg_finish_rd <= 1'b0;
                r_port_type_rd <= 1'b0;
                r_qbv_or_qch_rd <= 1'b0;
                r_rc_threshold_rd <= 1'b0;
                r_be_threshold_rd <= 1'b0;
                r_unmap_threshold_rd <= 1'b0; 
                if(iv_rd_command[183:152] <= 32'h3ff)begin//read qgc3 table
                    rv_nop3_ram_raddr  <= iv_rd_command[161:152];
                    r_nop3_ram_rd <= 1'b1;
                end
                else begin
                    rv_nop3_ram_raddr <= 10'b0;
                    r_nop3_ram_rd <= 1'b0;                           
                end 
            end   
            else if(iv_rd_command[195:188] == 8'h7)begin
                r_flt_ram_rd <= 1'b0;
                r_nop0_ram_rd <= 1'b0;
                r_nop1_ram_rd <= 1'b0;
                r_nop2_ram_rd <= 1'b0;
                r_nop3_ram_rd <= 1'b0;
                r_cfg_finish_rd <= 1'b0;
                r_port_type_rd <= 1'b0;
                r_qbv_or_qch_rd <= 1'b0;
                r_rc_threshold_rd <= 1'b0;
                r_be_threshold_rd <= 1'b0;
                r_unmap_threshold_rd <= 1'b0; 
                if(iv_rd_command[183:152] <= 32'h3ff)begin//read qgc4 table
                    rv_nop4_ram_raddr  <= iv_rd_command[161:152];
                    r_nop4_ram_rd <= 1'b1;
                end
                else begin
                    rv_nop4_ram_raddr <= 10'b0;
                    r_nop4_ram_rd <= 1'b0;                           
                end 
            end 
            else if(iv_rd_command[195:188] == 8'hc)begin
                r_nop0_ram_rd <= 1'b0;
                r_nop1_ram_rd <= 1'b0;
                r_nop2_ram_rd <= 1'b0;
                r_nop3_ram_rd <= 1'b0;
                r_nop4_ram_rd <= 1'b0;                   
                r_cfg_finish_rd <= 1'b0;
                r_port_type_rd <= 1'b0;
                r_qbv_or_qch_rd <= 1'b0;
                r_rc_threshold_rd <= 1'b0;
                r_be_threshold_rd <= 1'b0;
                r_unmap_threshold_rd <= 1'b0; 
                if(iv_rd_command[183:152] <= 32'h3fff)begin//read flt table
                    rv_flt_ram_raddr  <= iv_rd_command[165:152];
                    r_flt_ram_rd <= 1'b1;
                end
                else begin
                    rv_flt_ram_raddr <= 14'b0;
                    r_flt_ram_rd <= 1'b0;                           
                end 
            end   
            else begin
                r_nop0_ram_rd <= 1'b0;
                rv_nop0_ram_raddr  <= 10'b0;
                r_nop1_ram_rd <= 1'b0;
                rv_nop1_ram_raddr  <= 10'b0;
                r_nop2_ram_rd <= 1'b0;
                rv_nop2_ram_raddr  <= 10'b0;
                r_nop3_ram_rd <= 1'b0;
                rv_nop3_ram_raddr  <= 10'b0;  
                r_nop4_ram_rd <= 1'b0;  
                rv_nop4_ram_raddr  <= 10'b0;
                r_flt_ram_rd <= 1'b0;
                rv_flt_ram_raddr  <= 14'b0;   
                r_cfg_finish_rd <= 1'b0;
                r_port_type_rd <= 1'b0;
                r_qbv_or_qch_rd <= 1'b0;
                r_rc_threshold_rd <= 1'b0;
                r_be_threshold_rd <= 1'b0;
                r_unmap_threshold_rd <= 1'b0;                   
            end
        end
        else begin
            r_nop0_ram_rd <= 1'b0;
            rv_nop0_ram_raddr  <= 10'b0;
            r_nop1_ram_rd <= 1'b0;
            rv_nop1_ram_raddr  <= 10'b0;
            r_nop2_ram_rd <= 1'b0;
            rv_nop2_ram_raddr  <= 10'b0;
            r_nop3_ram_rd <= 1'b0;
            rv_nop3_ram_raddr  <= 10'b0;  
            r_nop4_ram_rd <= 1'b0;  
            rv_nop4_ram_raddr  <= 10'b0;
            r_flt_ram_rd <= 1'b0;
            rv_flt_ram_raddr  <= 14'b0;   
            r_cfg_finish_rd <= 1'b0;
            r_port_type_rd <= 1'b0;
            r_qbv_or_qch_rd <= 1'b0;
            r_rc_threshold_rd <= 1'b0;
            r_be_threshold_rd <= 1'b0;
            r_unmap_threshold_rd <= 1'b0;
        end
	end
end	

//***************************************************
//      judge whether read and write conflict
//***************************************************
assign   o_nop0_ram_wr = r_qgc0_ram_wr;
assign   o_nop0_ram_rd = r_qgc0_ram_wr?1'b0:r_nop0_ram_rd;
assign   ov_nop0_ram_addr = r_qgc0_ram_wr?rv_qgc0_ram_waddr:rv_nop0_ram_raddr;

assign   o_nop1_ram_wr = r_qgc1_ram_wr;
assign   o_nop1_ram_rd = r_qgc1_ram_wr?1'b0:r_nop1_ram_rd;
assign   ov_nop1_ram_addr = r_qgc1_ram_wr?rv_qgc1_ram_waddr:rv_nop1_ram_raddr;

assign   o_nop2_ram_wr = r_qgc2_ram_wr;
assign   o_nop2_ram_rd = r_qgc2_ram_wr?1'b0:r_nop2_ram_rd;
assign   ov_nop2_ram_addr = r_qgc2_ram_wr?rv_qgc2_ram_waddr:rv_nop2_ram_raddr;

assign   o_nop3_ram_wr = r_qgc3_ram_wr;
assign   o_nop3_ram_rd = r_qgc3_ram_wr?1'b0:r_nop3_ram_rd;
assign   ov_nop3_ram_addr = r_qgc3_ram_wr?rv_qgc3_ram_waddr:rv_nop3_ram_raddr;

assign   o_nop4_ram_wr = r_qgc4_ram_wr;
assign   o_nop4_ram_rd = r_qgc4_ram_wr?1'b0:r_nop4_ram_rd;
assign   ov_nop4_ram_addr = r_qgc4_ram_wr?rv_qgc4_ram_waddr:rv_nop4_ram_raddr;

assign   o_flt_ram_wr = r_flt_ram_wr;
assign   o_flt_ram_rd = r_flt_ram_wr?1'b0:r_flt_ram_rd;
assign   ov_flt_ram_addr = r_flt_ram_wr?rv_flt_ram_waddr:rv_flt_ram_raddr;

reg      [31:0]      rv_read_flag;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        rv_read_flag <= 32'b0;     
    end
    else begin
        //judge whether read or write qgc0 table conflict.     
        if((r_qgc0_ram_wr == 1'b1) && (r_nop0_ram_rd == 1'b1))begin//read and write conflict               
            rv_read_flag[16] <= 1'b0;
        end
        else if((r_qgc0_ram_wr == 1'b0) && (r_nop0_ram_rd == 1'b1))begin//read only   
            rv_read_flag[16] <= 1'b1;					
	    end	
        else begin
            rv_read_flag[16] <= 1'b0;           
        end
        //judge whether read or write qgc1 table conflict.  
        if((r_qgc1_ram_wr == 1'b1) && (r_nop1_ram_rd == 1'b1))begin//read and write conflict         
            rv_read_flag[17] <= 1'b0;
        end
        else if((r_qgc1_ram_wr == 1'b0) && (r_nop1_ram_rd == 1'b1))begin//read only   
            rv_read_flag[17] <= 1'b1;					
	    end	
        else begin
            rv_read_flag[17] <= 1'b0;           
        end
        //judge whether read or write qgc2 table conflict.     
        if((r_qgc2_ram_wr == 1'b1) && (r_nop2_ram_rd == 1'b1))begin//read and write conflict               
            rv_read_flag[18] <= 1'b0;
        end
        else if((r_qgc2_ram_wr == 1'b0) && (r_nop2_ram_rd == 1'b1))begin//read only   
            rv_read_flag[18] <= 1'b1;					
	    end	
        else begin
            rv_read_flag[18] <= 1'b0;           
        end
        //judge whether read or write qgc3 table conflict.  
        if((r_qgc3_ram_wr == 1'b1) && (r_nop3_ram_rd == 1'b1))begin//read and write conflict         
            rv_read_flag[19] <= 1'b0;
        end
        else if((r_qgc3_ram_wr == 1'b0) && (r_nop3_ram_rd == 1'b1))begin//read only   
            rv_read_flag[19] <= 1'b1;					
	    end	
        else begin
            rv_read_flag[19] <= 1'b0;           
        end        
        //judge whether read or write qgc4 table conflict.     
        if((r_qgc4_ram_wr == 1'b1) && (r_nop4_ram_rd == 1'b1))begin//read and write conflict               
            rv_read_flag[20] <= 1'b0;
        end
        else if((r_qgc4_ram_wr == 1'b0) && (r_nop4_ram_rd == 1'b1))begin//read only   
            rv_read_flag[20] <= 1'b1;					
	    end	
        else begin
            rv_read_flag[20] <= 1'b0;           
        end   
        //judge whether read or write flt table conflict.  
        if((r_flt_ram_wr == 1'b1) && (r_flt_ram_rd == 1'b1))begin//read and write conflict         
            rv_read_flag[24] <= 1'b0;
        end
        else if((r_flt_ram_wr == 1'b0) && (r_flt_ram_rd == 1'b1))begin//read only   
            rv_read_flag[24] <= 1'b1;					
	    end	
        else begin
            rv_read_flag[24] <= 1'b0;           
        end           
        //judge cfg_finish.  
        if(r_cfg_finish_rd == 1'b1)begin      
            rv_read_flag[3] <= 1'b1;
        end
        else begin
            rv_read_flag[3] <= 1'b0;           
        end 
        //judge port_type.  
        if(r_port_type_rd == 1'b1)begin      
            rv_read_flag[4] <= 1'b1;
        end
        else begin
            rv_read_flag[4] <= 1'b0;           
        end 
        //qbv_or_qch
        if(r_qbv_or_qch_rd == 1'b1)begin      
            rv_read_flag[5] <= 1'b1;
        end
        else begin
            rv_read_flag[5] <= 1'b0;           
        end         
        //judge rc_threshold.  
        if(r_rc_threshold_rd == 1'b1)begin      
            rv_read_flag[12] <= 1'b1;
        end
        else begin
            rv_read_flag[12] <= 1'b0;           
        end
        //judge be_threshold.  
        if(r_be_threshold_rd == 1'b1)begin      
            rv_read_flag[13] <= 1'b1;
        end
        else begin
            rv_read_flag[13] <= 1'b0;           
        end
        //judge unmap_threshold.  
        if(r_unmap_threshold_rd == 1'b1)begin      
            rv_read_flag[14] <= 1'b1;
        end
        else begin
            rv_read_flag[14] <= 1'b0;           
        end          
    end
end 
//***************************************************
//               delay control
//***************************************************
reg     [31:0]        rv_read_flag_delay0;

reg     [203:0]       rv_command_delay0;
reg     [203:0]       rv_command_delay1;
reg     [203:0]       rv_command_delay2;
always @(posedge i_clk or negedge i_rst_n) begin // read ram have two cycle delay
    if(!i_rst_n)begin
        rv_read_flag_delay0 <= 32'h0;
        
        rv_command_delay0 <= 204'b0;
        rv_command_delay1 <= 204'b0;
        rv_command_delay2 <= 204'b0;
    end
    else begin
        rv_read_flag_delay0 <= rv_read_flag;
        
        rv_command_delay0   <= iv_rd_command;
        rv_command_delay1   <= rv_command_delay0;
        rv_command_delay2   <= rv_command_delay1;
    end
end

always @(posedge i_clk or negedge i_rst_n) begin // read ram have two cycle delay
    if(!i_rst_n)begin
        ov_rd_command_ack <= 204'b0;
    end
    else begin
        if(|rv_read_flag_delay0 == 1'b1)begin      
            case(rv_read_flag_delay0)
                32'h0000_0008:begin
                    ov_rd_command_ack[203:188] <= rv_command_delay2[203:188];
                    ov_rd_command_ack[187:184] <= 4'b0110;//type:read ack
                    ov_rd_command_ack[183:152] <= rv_command_delay2[183:152];//addr  
                    ov_rd_command_ack[151:0] <= {150'b0,ov_cfg_finish};
                end
                32'h0000_0010:begin
                    ov_rd_command_ack[203:188] <= rv_command_delay2[203:188];
                    ov_rd_command_ack[187:184] <= 4'b0110;//type:read ack
                    ov_rd_command_ack[183:152] <= rv_command_delay2[183:152];//addr  
                    ov_rd_command_ack[151:0] <= {144'b0,ov_port_type};
                end     
                32'h0000_0020:begin
                    ov_rd_command_ack[203:188] <= rv_command_delay2[203:188];
                    ov_rd_command_ack[187:184] <= 4'b0110;//type:read ack
                    ov_rd_command_ack[183:152] <= rv_command_delay2[183:152];//addr  
                    ov_rd_command_ack[151:0] <= {141'b0,o_qbv_or_qch};
                end                   
                32'h0000_1000:begin
                    ov_rd_command_ack[203:188] <= rv_command_delay2[203:188];
                    ov_rd_command_ack[187:184] <= 4'b0110;//type:read ack
                    ov_rd_command_ack[183:152] <= rv_command_delay2[183:152];//addr             
                    ov_rd_command_ack[151:0] <= {143'b0,ov_rc_threshold_value};
                end
                32'h0000_2000:begin
                    ov_rd_command_ack[203:188] <= rv_command_delay2[203:188];
                    ov_rd_command_ack[187:184] <= 4'b0110;//type:read ack
                    ov_rd_command_ack[183:152] <= rv_command_delay2[183:152];//addr                 
                    ov_rd_command_ack[151:0] <= {143'b0,ov_be_threshold_value};
                end
                32'h0000_4000:begin
                    ov_rd_command_ack[203:188] <= rv_command_delay2[203:188];
                    ov_rd_command_ack[187:184] <= 4'b0110;//type:read ack
                    ov_rd_command_ack[183:152] <= rv_command_delay2[183:152];//addr                 
                    ov_rd_command_ack[151:0] <= {143'b0,ov_map_req_threshold_value};
                end
                32'h0001_0000:begin
                    ov_rd_command_ack[203:188] <= rv_command_delay2[203:188];
                    ov_rd_command_ack[187:184] <= 4'b0110;//type:read ack
                    ov_rd_command_ack[183:152] <= rv_command_delay2[183:152];//addr                  
                    ov_rd_command_ack[151:0] <= {143'b0,iv_nop0_ram_rdata};
                end 
                32'h0002_0000:begin
                    ov_rd_command_ack[203:188] <= rv_command_delay2[203:188];
                    ov_rd_command_ack[187:184] <= 4'b0110;//type:read ack
                    ov_rd_command_ack[183:152] <= rv_command_delay2[183:152];//addr                 
                    ov_rd_command_ack[151:0] <= {143'b0,iv_nop1_ram_rdata};
                end
                32'h0004_0000:begin
                    ov_rd_command_ack[203:188] <= rv_command_delay2[203:188];
                    ov_rd_command_ack[187:184] <= 4'b0110;//type:read ack
                    ov_rd_command_ack[183:152] <= rv_command_delay2[183:152];//addr                 
                    ov_rd_command_ack[151:0] <= {143'b0,iv_nop2_ram_rdata};
                end 
                32'h0008_0000:begin
                    ov_rd_command_ack[203:188] <= rv_command_delay2[203:188];
                    ov_rd_command_ack[187:184] <= 4'b0110;//type:read ack
                    ov_rd_command_ack[183:152] <= rv_command_delay2[183:152];//addr                 
                    ov_rd_command_ack[151:0] <= {143'b0,iv_nop3_ram_rdata};
                end 
                32'h0010_0000:begin
                    ov_rd_command_ack[203:188] <= rv_command_delay2[203:188];
                    ov_rd_command_ack[187:184] <= 4'b0110;//type:read ack
                    ov_rd_command_ack[183:152] <= rv_command_delay2[183:152];//addr                 
                    ov_rd_command_ack[151:0] <= {143'b0,iv_nop4_ram_rdata};
                end 
                32'h0100_0000:begin
                    ov_rd_command_ack[203:188] <= rv_command_delay2[203:188];
                    ov_rd_command_ack[187:184] <= 4'b0110;//type:read ack
                    ov_rd_command_ack[183:152] <= rv_command_delay2[183:152];//addr                 
                    ov_rd_command_ack[151:0] <= {142'b0,iv_flt_ram_rdata};
                end                 
                default:begin
                    ov_rd_command_ack[203:0] <= 204'b0;
                end 
            endcase
        end            
        else begin
            ov_rd_command_ack <= ov_rd_command_ack;
        end
    end
end

   
endmodule