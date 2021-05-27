// Copyright (C) 1953-2020 NUDT
// Verilog module name - TRW
// Version: TRW_V1.0
// Created:
//         by - jintao peng
//         at - 06.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         cache pkt with two regs and discard pkt if not get new bufid.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module input_width_transform
(
        i_clk,
        i_rst_n,
        
        iv_data,
	    i_data_wr,
        iv_relative_time,
        iv_global_time,
	   
	    ov_data,
	    o_data_wr,

        ov_time_length,
        o_time_length_wr
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// pkt input
input	   [8:0]	   iv_data;
input	         	   i_data_wr;
input      [18:0]      iv_relative_time;
input      [47:0]      iv_global_time;
//pkt output
output reg [133:0]     ov_data;
output reg             o_data_wr;

output reg [30:0]      ov_time_length;
output reg             o_time_length_wr;
//***************************************************
//               delay 2 cycles
//***************************************************
reg   [8:0] rv_data_delay1;
reg         r_data_delay1_wr;
reg   [8:0] rv_data_delay2;
reg         r_data_delay2_wr;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        rv_data_delay1 <= 9'b0;
		r_data_delay1_wr <= 1'b0; 
		rv_data_delay2 <= 9'b0;
        r_data_delay2_wr <= 1'b0;
    end
    else begin
        rv_data_delay1 <= iv_data;
		r_data_delay1_wr <= i_data_wr; 
		rv_data_delay2 <= rv_data_delay1;
        r_data_delay2_wr <= r_data_delay1_wr;    
    end
end
//***************************************************
//               cache pkt 
//***************************************************
// internal reg&wire for state machine
reg [11:0]  rv_pkt_len;
reg [3:0]   rv_pkt_cnt;
reg         r_first_cycle_flag;
reg [2:0]   pkt_state;
localparam  IDLE_S = 3'd0,
            TRANS_MD1_S = 3'd1,
            WRITE_REG_S = 3'd2;
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data <= 134'b0;
		o_data_wr <= 1'b0; 
        ov_time_length <= 31'b0;
        o_time_length_wr <= 1'b0;
        rv_pkt_len <= 12'b0;
        r_first_cycle_flag <= 1'b0;
		rv_pkt_cnt <= 4'b0;
		pkt_state <= IDLE_S;
    end
    else begin
		case(pkt_state)
			IDLE_S:begin         
                r_first_cycle_flag <= 1'b0;
                rv_pkt_cnt <= 4'b0;
                o_time_length_wr <= 1'b0;
				if(i_data_wr == 1'b1 && iv_data[8] == 1'b1)begin //first byte
                    ov_data <= {2'b01,4'b0000,80'b0,iv_global_time};//transmit metadata0
                    o_data_wr <= 1'b1;
                    ov_time_length[30:12] <= iv_relative_time; 
                    ov_time_length[11:0] <= 12'b0; 
                    rv_pkt_len <= 12'd16;                    
                    pkt_state <= TRANS_MD1_S;  				
				end
				else begin
                    ov_data <= 134'b0;
                    o_data_wr <= 1'b0;
                    ov_time_length <= 31'b0;
                    rv_pkt_len <= 12'd0;                     
                    pkt_state <= IDLE_S;					
				end
			end
			TRANS_MD1_S:begin
                ov_data <= {2'b11,4'b0000,128'b0};
                o_data_wr <= 1'b1;
                rv_pkt_len <= 12'd32; 
                r_first_cycle_flag <= 1'b1;
                pkt_state <= WRITE_REG_S;					
			end             
            WRITE_REG_S:begin
                ov_time_length[30:12] <= ov_time_length[30:12]; 
                ov_time_length[11:0] <= rv_pkt_len+1'b1;            
				if(r_data_delay2_wr == 1'b1)begin 
				    rv_pkt_cnt <= rv_pkt_cnt + 4'd1;
                    rv_pkt_len <= rv_pkt_len + 1'b1; 
				end
				else begin
					rv_pkt_cnt <= rv_pkt_cnt;
                    rv_pkt_len <= rv_pkt_len;
				end
                case(rv_pkt_cnt)
					4'd0:begin
						if(r_first_cycle_flag)begin
							ov_data[133:132] <= 2'b11;
							ov_data[131:128] <= 4'b0000;
							ov_data[127:120] <= rv_data_delay2[7:0];	
                            o_data_wr <= 1'b0;
                            r_first_cycle_flag <= 1'b0;
						    pkt_state <= WRITE_REG_S;	                        
                        end
                        else if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b1111;
							ov_data[127:120] <= rv_data_delay2[7:0];
							ov_data[119:0] <= 120'b0;
							o_data_wr <= 1'b1;
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
                        else begin
							ov_data[133:132] <= 2'b11;
							ov_data[131:128] <= 4'b0000;
							ov_data[127:120] <= rv_data_delay2[7:0];	
                            o_data_wr <= 1'b0;
						    pkt_state <= WRITE_REG_S;	
						end
                    end	
					4'd1:begin
						if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b1110;
							ov_data[119:112] <= rv_data_delay2[7:0];
							ov_data[111:0] <= 112'b0;
							o_data_wr <= 1'b1;
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
						else begin
							ov_data[119:112] <= rv_data_delay2[7:0];	
                            o_data_wr <= 1'b0;
						    pkt_state <= WRITE_REG_S;	
						end
                    end											
					4'd2:begin
						if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b1101;
							ov_data[111:104] <= rv_data_delay2[7:0];
							ov_data[103:0] <= 104'b0;
							o_data_wr <= 1'b1;
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
						else begin
							ov_data[111:104] <= rv_data_delay2[7:0];	
                            o_data_wr <= 1'b0;
						    pkt_state <= WRITE_REG_S;	
						end
                    end			
					4'd3:begin
						if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b1100;
							ov_data[103:96] <= rv_data_delay2[7:0];
							ov_data[95:0] <= 96'b0;
							o_data_wr <= 1'b1;
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
						else begin
							ov_data[103:96] <= rv_data_delay2[7:0];
                            o_data_wr <= 1'b0;                            
						    pkt_state <= WRITE_REG_S;	
						end
                    end	
					4'd4:begin
						if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b1011;
							ov_data[95:88] <= rv_data_delay2[7:0];
							ov_data[87:0] <= 88'b0;
							o_data_wr <= 1'b1;
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
						else begin
							ov_data[95:88] <= rv_data_delay2[7:0];	
                            o_data_wr <= 1'b0;
						    pkt_state <= WRITE_REG_S;	
						end
                    end		
					4'd5:begin
						if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b1010;
							ov_data[87:80] <= rv_data_delay2[7:0];
							ov_data[79:0] <= 80'b0;
							o_data_wr <= 1'b1;
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
						else begin
							ov_data[87:80] <= rv_data_delay2[7:0];	
                            o_data_wr <= 1'b0;
						    pkt_state <= WRITE_REG_S;	
						end
                    end		
					4'd6:begin
						if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b1001;
							ov_data[79:72] <= rv_data_delay2[7:0];
							ov_data[71:0] <= 72'b0;
							o_data_wr <= 1'b1;
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
						else begin
							ov_data[79:72] <= rv_data_delay2[7:0];	
                            o_data_wr <= 1'b0;
						    pkt_state <= WRITE_REG_S;	
						end
                    end		
					4'd7:begin
						if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b1000;
							ov_data[71:64] <= rv_data_delay2[7:0];
							ov_data[63:0] <= 64'b0;
							o_data_wr <= 1'b1;
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
						else begin
							ov_data[71:64] <= rv_data_delay2[7:0];	
                            o_data_wr <= 1'b0;
						    pkt_state <= WRITE_REG_S;	
						end
                    end	
					4'd8:begin
						if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b0111;
							ov_data[63:56] <= rv_data_delay2[7:0];
							ov_data[55:0] <= 56'b0;
							o_data_wr <= 1'b1;
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
						else begin
							ov_data[63:56] <= rv_data_delay2[7:0];	
                            o_data_wr <= 1'b0;
						    pkt_state <= WRITE_REG_S;	
						end
                    end		
					4'd9:begin
						if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b0110;
							ov_data[55:48] <= rv_data_delay2[7:0];
							ov_data[47:0] <= 48'b0;
							o_data_wr <= 1'b1;
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
						else begin
							ov_data[55:48] <= rv_data_delay2[7:0];	
                            o_data_wr <= 1'b0;
						    pkt_state <= WRITE_REG_S;	
						end
                    end		
					4'd10:begin
						if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b0101;
							ov_data[47:40] <= rv_data_delay2[7:0];
							ov_data[39:0] <= 40'b0;
							o_data_wr <= 1'b1;
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
						else begin
							ov_data[47:40] <= rv_data_delay2[7:0];	
                            o_data_wr <= 1'b0;
						    pkt_state <= WRITE_REG_S;	
						end
                    end		
					4'd11:begin
						if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b0100;
							ov_data[39:32] <= rv_data_delay2[7:0];
							ov_data[31:0] <= 32'b0;
							o_data_wr <= 1'b1;
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
						else begin
							ov_data[39:32] <= rv_data_delay2[7:0];	
                            o_data_wr <= 1'b0;
						    pkt_state <= WRITE_REG_S;	
						end
                    end		
					4'd12:begin
						if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b0011;
							ov_data[31:24] <= rv_data_delay2[7:0];
							ov_data[23:0] <= 24'b0;
							o_data_wr <= 1'b1;
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
						else begin
							ov_data[31:24] <= rv_data_delay2[7:0];	
                            o_data_wr <= 1'b0;
						    pkt_state <= WRITE_REG_S;	
						end
                    end		
					4'd13:begin
						if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b0010;
							ov_data[23:16] <= rv_data_delay2[7:0];
							ov_data[15:0] <= 16'b0;
							o_data_wr <= 1'b1;
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
						else begin
							ov_data[23:16] <= rv_data_delay2[7:0];	
                            o_data_wr <= 1'b0;
						    pkt_state <= WRITE_REG_S;	
						end
                    end		
					4'd14:begin
						if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b0001;
							ov_data[15:8] <= rv_data_delay2[7:0];
							ov_data[7:0] <= 8'b0;
							o_data_wr <= 1'b1;
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
						else begin
							ov_data[15:8] <= rv_data_delay2[7:0];	
                            o_data_wr <= 1'b0;
						    pkt_state <= WRITE_REG_S;	
						end
                    end	
					4'd15:begin
					    o_data_wr <= 1'b1;
						if(r_data_delay2_wr == 1'b1 && rv_data_delay2[8] == 1'b1)begin //last cycle
							ov_data[133:132] <= 2'b10;
							ov_data[131:128] <= 4'b0000;
							ov_data[7:0] <= rv_data_delay2[7:0];
                            o_time_length_wr <= 1'b1;
							pkt_state <= IDLE_S;	
						end
						else begin					
							ov_data[7:0] <= rv_data_delay2[7:0];	
						    pkt_state <= WRITE_REG_S;	
						end
                    end						
				endcase
            end
			default:begin
				pkt_state <= IDLE_S;
			end
		endcase
	end
end	 
endmodule 