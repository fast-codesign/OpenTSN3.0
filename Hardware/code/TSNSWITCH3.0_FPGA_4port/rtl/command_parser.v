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
        //ov_timer_rst,
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
        
        i_port0_outpkt_pulse,        
        ov_nop0_ram_addr,    
        ov_nop0_ram_wdata,   
        o_nop0_ram_wr,       
        iv_nop0_ram_rdata,   
        o_nop0_ram_rd,       

        i_port1_outpkt_pulse,
        ov_nop1_ram_addr,    
        ov_nop1_ram_wdata,   
        o_nop1_ram_wr,       
        iv_nop1_ram_rdata,   
        o_nop1_ram_rd,       		
        
        i_port2_outpkt_pulse,
        ov_nop2_ram_addr,    
        ov_nop2_ram_wdata,   
        o_nop2_ram_wr,       
        iv_nop2_ram_rdata,   
        o_nop2_ram_rd,         		
        
        i_port3_outpkt_pulse,
        ov_nop3_ram_addr,    
        ov_nop3_ram_wdata,   
        o_nop3_ram_wr,       
        iv_nop3_ram_rdata,   
        o_nop3_ram_rd,        		
        
        i_port4_outpkt_pulse,
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
//output  reg             ov_timer_rst;
output  reg [7:0]       ov_port_type;
output  reg [1:0]       ov_cfg_finish;
		    
            //flt       
output  reg [13:0]      ov_flt_ram_addr; 
output  reg [8:0]       ov_flt_ram_wdata;
output  reg             o_flt_ram_wr;    
input      [8:0]        iv_flt_ram_rdata;
output  reg             o_flt_ram_rd;   

            //nop
output reg              o_qbv_or_qch;
            
input                   i_port0_outpkt_pulse;
output reg [9:0]        ov_nop0_ram_addr;    
output reg [7:0]        ov_nop0_ram_wdata;   
output reg              o_nop0_ram_wr;       
input      [7:0]        iv_nop0_ram_rdata;   
output reg              o_nop0_ram_rd;         
            
input                   i_port1_outpkt_pulse;
output reg [9:0]        ov_nop1_ram_addr;    
output reg [7:0]        ov_nop1_ram_wdata;   
output reg              o_nop1_ram_wr;       
input      [7:0]        iv_nop1_ram_rdata;   
output reg              o_nop1_ram_rd;         		
            
input                   i_port2_outpkt_pulse;
output reg [9:0]        ov_nop2_ram_addr;    
output reg [7:0]        ov_nop2_ram_wdata;   
output reg              o_nop2_ram_wr;       
input      [7:0]        iv_nop2_ram_rdata;   
output reg              o_nop2_ram_rd;        		
            
input                   i_port3_outpkt_pulse;
output reg [9:0]        ov_nop3_ram_addr;    
output reg [7:0]        ov_nop3_ram_wdata;   
output reg              o_nop3_ram_wr;       
input      [7:0]        iv_nop3_ram_rdata;   
output reg              o_nop3_ram_rd;       		
            
input                   i_port4_outpkt_pulse;
output reg [9:0]        ov_nop4_ram_addr;    
output reg [7:0]        ov_nop4_ram_wdata;   
output reg              o_nop4_ram_wr;       
input      [7:0]        iv_nop4_ram_rdata;   
output reg              o_nop4_ram_rd;        		

always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
		ov_cfg_finish    <= 2'b0;
        ov_port_type     <= 8'hff;
        o_qbv_or_qch     <= 1'b0;
        ov_be_threshold_value        <=  8'b0;
        ov_rc_threshold_value        <=  8'b0;
        ov_map_req_threshold_value   <=  8'b0;      
        ov_nop0_ram_addr  <= 10'b0;
        ov_nop0_ram_wdata <= 8'b0;
        o_nop0_ram_wr     <= 1'b0;
        ov_nop1_ram_addr  <= 10'b0;
        ov_nop1_ram_wdata <= 8'b0;
        o_nop1_ram_wr     <= 1'b0;        
        ov_nop2_ram_addr  <= 10'b0;
        ov_nop2_ram_wdata <= 8'b0;
        o_nop2_ram_wr     <= 1'b0;        
        ov_nop3_ram_addr  <= 10'b0;
        ov_nop3_ram_wdata <= 8'b0;
        o_nop3_ram_wr     <= 1'b0;        
        ov_nop4_ram_addr  <= 10'b0;
        ov_nop4_ram_wdata <= 8'b0;
        o_nop4_ram_wr     <= 1'b0;       
        ov_flt_ram_addr <= 14'b0; 
        ov_flt_ram_wdata<= 9'b0;
        o_flt_ram_wr <= 1'b0; 
	end
    else begin
        if(i_wr_command_wr == 1'b1)begin//command write enable
            if(iv_wr_command[187:184]==4'b0001)begin//command type of write
                case(iv_wr_command[195:188])
                    8'h0:begin //reg cfg
                        case(iv_wr_command[183:152])//reg addr
                            32'h3:ov_cfg_finish <= iv_wr_command[1:0];
                            32'h4:ov_port_type  <= iv_wr_command[7:0];
                            32'h5:o_qbv_or_qch  <= iv_wr_command[0];
                            32'hc:ov_be_threshold_value        <= iv_wr_command[8:0];
                            32'hd:ov_rc_threshold_value        <= iv_wr_command[8:0];
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
                        ov_nop0_ram_addr  <= iv_wr_command[161:152];
                        ov_nop0_ram_wdata <= iv_wr_command[7:0];
                        o_nop0_ram_wr     <= 1'b1;
                    end
                    8'h4:begin //port 1 qgc
                        ov_nop1_ram_addr  <= iv_wr_command[161:152];
                        ov_nop1_ram_wdata <= iv_wr_command[7:0];
                        o_nop1_ram_wr     <= 1'b1;
                    end
                    8'h5:begin //port 2 qgc
                        ov_nop2_ram_addr  <= iv_wr_command[161:152];
                        ov_nop2_ram_wdata <= iv_wr_command[7:0];
                        o_nop2_ram_wr     <= 1'b1;
                    end                           
                    8'h6:begin //port 3 qgc
                        ov_nop3_ram_addr  <= iv_wr_command[161:152];
                        ov_nop3_ram_wdata <= iv_wr_command[7:0];
                        o_nop3_ram_wr     <= 1'b1;
                    end                           
                    8'h7:begin //port 4 qgc
                        ov_nop4_ram_addr  <= iv_wr_command[161:152];
                        ov_nop4_ram_wdata <= iv_wr_command[7:0];
                        o_nop4_ram_wr     <= 1'b1;
                    end                           
                    8'hc:begin //flt cfg
                        ov_flt_ram_addr <= iv_wr_command[165:152];
                        ov_flt_ram_wdata<= iv_wr_command[8:0];
                        o_flt_ram_wr <= 1'b1;
                    end     
                    default:begin 
                        ov_cfg_finish    <= ov_cfg_finish ;
                        ov_port_type     <= ov_port_type  ;
                        o_qbv_or_qch     <= o_qbv_or_qch  ;
                        ov_be_threshold_value        <=  ov_be_threshold_value      ;
                        ov_rc_threshold_value        <=  ov_rc_threshold_value      ;
                        ov_map_req_threshold_value   <=  ov_map_req_threshold_value ;
                        
                        ov_nop0_ram_addr  <= 10'b0;
                        ov_nop0_ram_wdata <= 8'b0;
                        o_nop0_ram_wr     <= 1'b0;
                        ov_nop1_ram_addr  <= 10'b0;
                        ov_nop1_ram_wdata <= 8'b0;
                        o_nop1_ram_wr     <= 1'b0;          
                        ov_nop2_ram_addr  <= 10'b0;
                        ov_nop2_ram_wdata <= 8'b0;
                        o_nop2_ram_wr     <= 1'b0;          
                        ov_nop3_ram_addr  <= 10'b0;
                        ov_nop3_ram_wdata <= 8'b0;
                        o_nop3_ram_wr     <= 1'b0;          
                        ov_nop4_ram_addr  <= 10'b0;
                        ov_nop4_ram_wdata <= 8'b0;
                        o_nop4_ram_wr     <= 1'b0;   
                        ov_flt_ram_addr <= 14'b0; 
                        ov_flt_ram_wdata<= 9'b0;
                        o_flt_ram_wr <= 1'b0; 
                    end    
                endcase
            end
            else begin
                ov_cfg_finish    <= ov_cfg_finish;
                ov_port_type     <= ov_port_type ;
                o_qbv_or_qch     <= o_qbv_or_qch ;
                ov_be_threshold_value        <=  ov_be_threshold_value      ;
                ov_rc_threshold_value        <=  ov_rc_threshold_value      ;
                ov_map_req_threshold_value   <=  ov_map_req_threshold_value ;
                
                ov_nop0_ram_addr  <= 10'b0;
                ov_nop0_ram_wdata <= 8'b0;
                o_nop0_ram_wr     <= 1'b0;
                ov_nop1_ram_addr  <= 10'b0;
                ov_nop1_ram_wdata <= 8'b0;
                o_nop1_ram_wr     <= 1'b0;          
                ov_nop2_ram_addr  <= 10'b0;
                ov_nop2_ram_wdata <= 8'b0;
                o_nop2_ram_wr     <= 1'b0;          
                ov_nop3_ram_addr  <= 10'b0;
                ov_nop3_ram_wdata <= 8'b0;
                o_nop3_ram_wr     <= 1'b0;          
                ov_nop4_ram_addr  <= 10'b0;
                ov_nop4_ram_wdata <= 8'b0;
                o_nop4_ram_wr     <= 1'b0;   
                ov_flt_ram_addr <= 14'b0; 
                ov_flt_ram_wdata<= 9'b0;
                o_flt_ram_wr <= 1'b0; 
            end    
        end    
        else begin
            ov_cfg_finish    <= ov_cfg_finish;
            ov_port_type     <= ov_port_type ;
            o_qbv_or_qch     <= o_qbv_or_qch ;
            ov_be_threshold_value        <=  ov_be_threshold_value     ;
            ov_rc_threshold_value        <=  ov_rc_threshold_value     ;
            ov_map_req_threshold_value   <=  ov_map_req_threshold_value;
            
            ov_nop0_ram_addr  <= 10'b0;
            ov_nop0_ram_wdata <= 8'b0;
            o_nop0_ram_wr     <= 1'b0;
            ov_nop1_ram_addr  <= 10'b0;
            ov_nop1_ram_wdata <= 8'b0;
            o_nop1_ram_wr     <= 1'b0;         
            ov_nop2_ram_addr  <= 10'b0;
            ov_nop2_ram_wdata <= 8'b0;
            o_nop2_ram_wr     <= 1'b0;         
            ov_nop3_ram_addr  <= 10'b0;
            ov_nop3_ram_wdata <= 8'b0;
            o_nop3_ram_wr     <= 1'b0;         
            ov_nop4_ram_addr  <= 10'b0;
            ov_nop4_ram_wdata <= 8'b0;
            o_nop4_ram_wr     <= 1'b0;   
            ov_flt_ram_addr <= 14'b0; 
            ov_flt_ram_wdata<= 9'b0;
            o_flt_ram_wr <= 1'b0; 

        end                          
    end        
end            
            
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        o_flt_ram_rd <= 1'b0;
        o_nop0_ram_rd  <= 1'b0;
        o_nop1_ram_rd  <= 1'b0;        
        o_nop2_ram_rd  <= 1'b0;        
        o_nop3_ram_rd  <= 1'b0;
        o_nop4_ram_rd  <= 1'b0;        
	    ov_rd_command_ack   <= 204'b0; 
    end
    else begin        
        if(i_rd_command_wr == 1'b1)begin//command read enable
            if(iv_rd_command[187:184]==4'b0010)begin//command type of read
                case(iv_rd_command[195:188])
                    8'h3:begin //port 0 qgc
                        o_nop0_ram_rd  <= 1'b1;
                        ov_rd_command_ack <={8'h0,8'h3,4'h6,32'h0,144'h0,iv_nop0_ram_rdata};
                    end         
                    8'h4:begin //port 1 qgc
                        o_nop1_ram_rd  <= 1'b1; 
                        ov_rd_command_ack <={8'h0,8'h3,4'h6,32'h0,144'h0,iv_nop1_ram_rdata};
                    end  
                    8'h5:begin //port 2 qgc
                        o_nop2_ram_rd  <= 1'b1; 
                        ov_rd_command_ack <={8'h0,8'h3,4'h6,32'h0,144'h0,iv_nop2_ram_rdata};
                    end         
                    8'h6:begin //port 3 qgc
                        o_nop3_ram_rd  <= 1'b1; 
                        ov_rd_command_ack <={8'h0,8'h3,4'h6,32'h0,144'h0,iv_nop3_ram_rdata};
                    end   
                    8'h7:begin //port 4 qgc
                        o_nop4_ram_rd  <= 1'b1; 
                        ov_rd_command_ack <={8'h0,8'h3,4'h6,32'h0,144'h0,iv_nop4_ram_rdata};
                    end    
                    8'hc:begin //flt
                        o_flt_ram_rd  <= 1'b1; 
                        ov_rd_command_ack <={8'h0,8'h3,4'h6,32'h0,143'h0,iv_flt_ram_rdata};
                    end                        
                    default:begin 
                        o_nop0_ram_rd  <= 1'b0;
                        o_nop1_ram_rd  <= 1'b0;
                        o_nop2_ram_rd  <= 1'b0;
                        o_nop3_ram_rd  <= 1'b0;
                        o_nop4_ram_rd  <= 1'b0;
                        o_flt_ram_rd   <= 1'b0; 
                        ov_rd_command_ack <=204'b0;
                    end
                endcase
            end
            else begin
                o_nop0_ram_rd  <= 1'b0;
                o_nop1_ram_rd  <= 1'b0;
                o_nop2_ram_rd  <= 1'b0;
                o_nop3_ram_rd  <= 1'b0;
                o_nop4_ram_rd  <= 1'b0;
                o_flt_ram_rd  <= 1'b0; 
                ov_rd_command_ack <=204'b0;
            end
        end
        else begin
            o_nop0_ram_rd  <= 1'b0;
            o_nop1_ram_rd  <= 1'b0;
            o_nop2_ram_rd  <= 1'b0;
            o_nop3_ram_rd  <= 1'b0;
            o_nop4_ram_rd  <= 1'b0;
            o_flt_ram_rd  <= 1'b0; 
            ov_rd_command_ack <=204'b0;

        end
	end
end	

endmodule