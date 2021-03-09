// Copyright (C) 1953-2020 NUDT
// Verilog module name - pkt_descriptor_generation
// Version: PDG_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         generate descriptor of packet.
//             - write descriptor of TS packet to ram;
//             - transmit descriptor of not TS packet to FLT to look up table.
///////////////////////////////////////////////////////////////////////////


module lookup_map_table
(
        i_clk,
        i_rst_n,
       
        iv_5tuple_data,
        i_5tuple_data_wr,
       
        iv_dmac,
        iv_bufid,
        i_ip_flag,
        i_tcp_or_udp_flag,
       
        o_fmt_ram_rd,
        ov_fmt_ram_raddr,
        iv_fmt_ram_rdata,
        
        ov_tsntag,
        ov_bufid,
        o_descriptor_wr,
        i_descriptor_ack
);
// I/O
// clk & rst  
input               i_clk;
input               i_rst_n;
//5tuple & dmac input
input       [103:0] iv_5tuple_data;
input               i_5tuple_data_wr;

input       [47:0]  iv_dmac;
input       [8:0]   iv_bufid; 
input               i_ip_flag; 
input               i_tcp_or_udp_flag; 
//read ram
output reg          o_fmt_ram_rd;
output reg  [4:0]   ov_fmt_ram_raddr;
input       [130:0] iv_fmt_ram_rdata;
//tsntag & bufid output 
output reg  [47:0]  ov_tsntag;
output reg  [8:0]   ov_bufid;
output reg          o_descriptor_wr;
input               i_descriptor_ack;
//***************************************************
//          extract five tuple from pkt 
//***************************************************
// internal reg&wire for state machine 
reg         [3:0]   rv_cycle_cnt; 
reg         [103:0] rv_5tuple_data;
reg         [47:0]  rv_dmac;

reg         [3:0]   lmt_state;
localparam  IDLE_S = 4'd0,
            WAIT_FIRST_S = 4'd1,
            WAIT_SECOND_S = 4'd2,
            LOOKUP_TABLE_S = 4'd3,
            WAIT_TRANSMIT_S = 4'd4,
            WAIT_ACK_S = 4'd5;
always @(posedge i_clk or negedge i_rst_n)begin
    if(!i_rst_n)begin
        ov_fmt_ram_raddr <= 5'd0;
        o_fmt_ram_rd <= 1'b0;

        ov_tsntag <= 48'b0;
        ov_bufid <= 9'b0;
        o_descriptor_wr <= 1'b0;
     
        rv_5tuple_data <= 104'd0;
        rv_dmac <= 48'b0;
        rv_cycle_cnt <= 4'b0;
        lmt_state <= IDLE_S;
    end
    else begin
        case(lmt_state)
            IDLE_S:begin
                rv_cycle_cnt <= 4'b0;
                if(i_5tuple_data_wr == 1'b1)begin
                    if(i_tcp_or_udp_flag ==1'b1)begin//TCP or UDP
                        ov_fmt_ram_raddr <= 5'd0;
                        o_fmt_ram_rd <= 1'b1;
                        
                        rv_5tuple_data <= iv_5tuple_data;
                        rv_dmac <= iv_dmac;
                        
                        ov_tsntag <= 48'b0;
                        ov_bufid <= iv_bufid;
                        o_descriptor_wr <= 1'b0;
                        
                        lmt_state <= WAIT_FIRST_S;
                    end
                    else begin//not TCP neither UDP
                        ov_fmt_ram_raddr <=5'd0;
                        o_fmt_ram_rd <=1'b0;

                        ov_tsntag <= iv_dmac;
                        ov_bufid <= iv_bufid;
                        o_descriptor_wr <= 1'b0;
                        
                        rv_5tuple_data <= 104'd0;
                        rv_dmac <= 48'b0;
                        
                        lmt_state <= WAIT_TRANSMIT_S;
                    end
                end
                else begin
                    ov_fmt_ram_raddr <=5'd0;
                    o_fmt_ram_rd <=1'b0;

                    ov_tsntag <= 48'b0;
                    ov_bufid <= 9'b0;
                    o_descriptor_wr <= 1'b0;
                    
                    rv_5tuple_data <= 104'd0;
                    rv_dmac <= 48'b0;
                    
                    lmt_state <= IDLE_S;                
                end
            end
            WAIT_FIRST_S:begin//get data of reading ram after 2 cycles. 
                o_fmt_ram_rd <= 1'b1;
                ov_fmt_ram_raddr <= ov_fmt_ram_raddr + 1'b1;
                lmt_state <= WAIT_SECOND_S;
			end
			WAIT_SECOND_S:begin 
                o_fmt_ram_rd <= 1'b1;
                ov_fmt_ram_raddr <= ov_fmt_ram_raddr + 1'b1;
                lmt_state <= LOOKUP_TABLE_S;
			end
			LOOKUP_TABLE_S:begin
				if(iv_fmt_ram_rdata != 131'b0)begin//table entry is valid
					if(iv_fmt_ram_rdata[130:27] == rv_5tuple_data)begin//match entry
						o_fmt_ram_rd <= 1'b0;
						ov_fmt_ram_raddr <= 5'b0;
						
                        ov_tsntag <= {iv_fmt_ram_rdata[26:10], 21'b0, iv_fmt_ram_rdata[9:0]};
                        o_descriptor_wr <= 1'b0;
                        
						lmt_state <= WAIT_TRANSMIT_S;	                    
					end
					else begin//not match entry
						if(ov_fmt_ram_raddr == 5'h01)begin//not match all entries.
							o_fmt_ram_rd <= 1'b0;
							ov_fmt_ram_raddr <= 5'b0;
                            
                            ov_tsntag <= rv_dmac;
                            o_descriptor_wr <= 1'b1;
                            
							lmt_state <= WAIT_ACK_S;                          
						end
						else begin
							o_fmt_ram_rd <= 1'b1;
							ov_fmt_ram_raddr <= ov_fmt_ram_raddr + 1'b1;
							
                            ov_tsntag <= 48'b0;
                            o_descriptor_wr <= 1'b0;
							lmt_state <= LOOKUP_TABLE_S;                      
						end        
					end
                end
                else begin//table entry is invalid
					o_fmt_ram_rd <= 1'b0;
					ov_fmt_ram_raddr <= 8'b0;
					
                    ov_tsntag <= rv_dmac;
                    o_descriptor_wr <= 1'b0;
					lmt_state <= WAIT_TRANSMIT_S;  
                end				
			end
            WAIT_TRANSMIT_S:begin
                if(rv_cycle_cnt == 4'hf)begin
                    o_descriptor_wr <= 1'b1;
                    lmt_state <= WAIT_ACK_S; 
                end
                else begin
                    rv_cycle_cnt <= rv_cycle_cnt + 1'b1;
                    lmt_state <= WAIT_TRANSMIT_S; 
                end                             
            end
            WAIT_ACK_S:begin
                if(i_descriptor_ack)begin
                    ov_tsntag <= 48'b0;
                    ov_bufid <= 9'b0;
                    o_descriptor_wr <= 1'b0;
                    lmt_state <= IDLE_S;                      
                end
                else begin
                    lmt_state <= WAIT_ACK_S;   
                end
            end
            default:begin
                ov_fmt_ram_raddr <= 5'd0;
                o_fmt_ram_rd <= 1'b0;

                ov_tsntag <= 48'b0;
                ov_bufid <= 9'b0;
                o_descriptor_wr <= 1'b0;
             
                rv_5tuple_data <= 104'd0;
                rv_dmac <= 48'b0;
                
                lmt_state <= IDLE_S;            
            end
        endcase
    end
end
endmodule           