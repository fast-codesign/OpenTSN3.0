// Copyright (C) 1953-2020 NUDT
// Verilog module name - frame_encapsulation_module
// Version: frame_encapsulation_module_V1.0
// Created:
//         by - peng jintao
//         at - 2021.01
////////////////////////////////////////////////////////////////////////////
// Description:
//         - encapsulate ARP request frame、PTP frame、NMAC report frame to tsmp frame;
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module output_control_hcp
(
       i_clk,
       i_rst_n,
       
       iv_data,
       i_data_wr,
       
       i_timer_rst,
	   
	   ov_data,
	   o_data_wr   
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  

input                  i_timer_rst;
// pkt input
input	   [8:0]	   iv_data;
input	         	   i_data_wr;
// pkt output
output reg [7:0]	   ov_data;
output reg	           o_data_wr;

reg    [143:0]         rv_data;

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

always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        rv_data <= 144'b0;
    end
    else begin
        rv_data <= {rv_data[135:0],iv_data};
    end
end

reg    [3:0]  output_state;
reg           r_ptp_enable;
reg    [4:0]  rv_cycle_cnt;
reg    [18:0] rv_transmit_time;
reg    [63:0] rv_transparent_clock;
localparam  IDLE_S = 4'd0,
            TRANS_PREAMBLE_SFD_S = 4'd1,
            JUDGE_PTP_S = 4'd2,
            UPDATE_TC_S = 4'd3,
            TRANS_PTP_S = 4'd4,
            TRANS_NOT_PTP_S = 4'd5;             
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data <= 8'b0;
		o_data_wr <= 1'b0;
        rv_cycle_cnt <= 5'b0;
        r_ptp_enable <= 1'b0;
        rv_transmit_time <= 19'b0;
        rv_transparent_clock <= 64'b0;
		output_state <= IDLE_S;
    end
    else begin
		case(output_state)
			IDLE_S:begin
                rv_transparent_clock <= 64'b0;
                r_ptp_enable <= 1'b0;
                rv_transmit_time <= 19'b0;
				if((i_data_wr == 1'b1) && (iv_data[8] == 1'b1))begin
                    rv_cycle_cnt <= 5'b1;
                    ov_data <= 8'h55;
		            o_data_wr <= 1'b1;
                    output_state <= TRANS_PREAMBLE_SFD_S;                  
                end
                else begin
                    rv_cycle_cnt <= 5'b0;
                    ov_data <= 8'b0;
		            o_data_wr <= 1'b0;
                    output_state <= IDLE_S;                
                end
            end
            TRANS_PREAMBLE_SFD_S:begin
                rv_cycle_cnt <= rv_cycle_cnt + 1'b1;
                o_data_wr <= 1'b1;
                case(rv_cycle_cnt)
                    5'd1:begin
                        ov_data <= 8'h55;
                    end
                    5'd2:begin
                        ov_data <= 8'h55;
                    end
                    5'd3:begin
                        ov_data <= 8'h55;
                        rv_transmit_time[18:16] <= iv_data[2:0];
                    end 
                    5'd4:begin
                        ov_data <= 8'h55;
                        rv_transmit_time[15:8] <= iv_data[7:0];
                    end
                    5'd5:begin
                        ov_data <= 8'h55;
                        rv_transmit_time[7:0] <= iv_data[7:0];
                    end
                    5'd6:begin
                        ov_data <= 8'h55;
                    end
                    5'd7:begin
                        ov_data <= 8'hd5;
                        output_state <= JUDGE_PTP_S;   
                    end
                    default:begin
                        ov_data <= ov_data;
                    end
                endcase                    					             
			end
            JUDGE_PTP_S:begin
                ov_data <= rv_data[70:63];
                o_data_wr <= 1'b1;
                if(rv_data[71] == 1'b1)begin
                    rv_cycle_cnt <= 5'd1;
                end
                else begin
                    if(rv_cycle_cnt == 5'd4)begin
                        if(iv_data[7:0] == 8'h98)begin
                            rv_cycle_cnt <= rv_cycle_cnt + 1'b1;
                            output_state <= JUDGE_PTP_S;  
                        end
                        else begin
                            rv_cycle_cnt <= rv_cycle_cnt;
                            output_state <= TRANS_NOT_PTP_S;
                        end
                    end
                    else if(rv_cycle_cnt == 5'd5)begin
                        if(iv_data[7:0] == 8'hf7)begin
                            r_ptp_enable <= 1'b1;
                            rv_cycle_cnt <= 5'b0;
                            output_state <= UPDATE_TC_S;  
                        end
                        else begin
                            r_ptp_enable <= 1'b0;
                            rv_cycle_cnt <= 5'b0;
                            output_state <= TRANS_NOT_PTP_S;  
                        end                    
                    end
                    else begin
                        rv_cycle_cnt <= rv_cycle_cnt + 1'b1;
                        output_state <= JUDGE_PTP_S;                     
                    end
                end
            end
            UPDATE_TC_S:begin
                rv_cycle_cnt <= rv_cycle_cnt + 1'b1;
                if((rv_cycle_cnt >= 5'd8) && (rv_cycle_cnt <= 5'd14))begin
                    ov_data <= rv_data[70:63];
                    o_data_wr <= 1'b1;
                    rv_transparent_clock <= {rv_transparent_clock[55:0],iv_data[7:0]};
                end
                else if(rv_cycle_cnt == 5'd15)begin
                    ov_data <= rv_data[70:63];
                    o_data_wr <= 1'b1;
                    if(rv_timer > rv_transmit_time)begin
                        rv_transparent_clock <= {rv_transparent_clock[55:0],iv_data[7:0]} + rv_timer - rv_transmit_time;
                    end
                    else begin//+4ms
                        rv_transparent_clock <= {rv_transparent_clock[55:0],iv_data[7:0]} + rv_timer + 19'd500000 - rv_transmit_time;
                    end                  
                end
                else if((rv_cycle_cnt >= 5'd16) && (rv_cycle_cnt <= 5'd23))begin
                    case(rv_cycle_cnt)
                        5'd16:begin
                            ov_data <= rv_transparent_clock[63:56];
                        end
                        5'd17:begin
                            ov_data <= rv_transparent_clock[55:48];
                        end
                        5'd18:begin
                            ov_data <= rv_transparent_clock[47:40];
                        end
                        5'd19:begin
                            ov_data <= rv_transparent_clock[39:32];
                        end 
                        5'd20:begin
                            ov_data <= rv_transparent_clock[31:24];
                        end
                        5'd21:begin
                            ov_data <= rv_transparent_clock[23:16];
                        end 
                        5'd22:begin
                            ov_data <= rv_transparent_clock[15:8];
                        end
                        5'd23:begin
                            ov_data <= rv_transparent_clock[7:0];
                            output_state <= TRANS_PTP_S;   
                        end
                        default:begin
                            ov_data <= ov_data;
                        end
                    endcase                                       
                end
                else begin
                    ov_data <= rv_data[70:63];
                    o_data_wr <= 1'b1;
                end
            end
            TRANS_PTP_S:begin
                ov_data <= rv_data[70:63];
                o_data_wr <= 1'b1;
                if(rv_data[71] == 1'b1)begin
                    output_state <= IDLE_S;   
                end
                else begin
                    output_state <= TRANS_NOT_PTP_S;   
                end             
            end  
            TRANS_NOT_PTP_S:begin
                ov_data <= rv_data[70:63];
                o_data_wr <= 1'b1;
                if(rv_data[71] == 1'b1)begin
                    output_state <= IDLE_S;   
                end
                else begin
                    output_state <= TRANS_NOT_PTP_S;   
                end       
            end
			default:begin
                ov_data <= 8'b0;
                o_data_wr <= 1'b0;
                output_state <= IDLE_S;	
			end
		endcase
   end
end	
endmodule