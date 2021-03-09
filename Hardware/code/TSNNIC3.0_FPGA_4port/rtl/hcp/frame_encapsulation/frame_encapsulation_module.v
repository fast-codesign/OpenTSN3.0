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

module frame_encapsulation_module
(
       i_clk,
       i_rst_n,
       
       iv_dmac,
       iv_smac,
       
       i_timer_rst,
       iv_syned_global_time,
       
       iv_data,
       iv_descriptor,
	   i_data_wr,
	   
	   ov_data,
	   o_data_wr   
);

// I/O
// clk & rst
input                  i_clk;
input                  i_rst_n;  
// dmac and smac of tsmp frame from controller
input      [47:0]      iv_dmac;
input      [47:0]      iv_smac;

input                  i_timer_rst;
input      [47:0]      iv_syned_global_time;
// pkt input
input	   [8:0]	   iv_data;
input      [34:0]      iv_descriptor;
input	         	   i_data_wr;
// pkt output
output reg [8:0]	   ov_data;
output reg	           o_data_wr;

reg    [143:0]         rv_data;
reg    [7:0]           rv_subtype;
reg    [15:0]          rv_report_type;

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

reg    [3:0]  fem_state;
reg    [3:0]  rv_cycle_cnt;
reg    [6:0]  rv_ptp_cycle_cnt;
reg    [63:0] rv_transparent_clock;
reg    [47:0] rv_global_clock;
localparam  IDLE_S = 4'd0,
            DISC_ETH_HEADER_S = 4'd1,
            TRANS_TSMP_HEAD_S = 4'd2,
            TRANS_ONE_CYCLE_S = 4'd3,
            TRANS_REC_DATA_S = 4'd4,
            TRANS_REPORT_DATA_S = 4'd5,
            TRANS_REPORT_TYPE_S = 4'd6,
            PTP_PROCESS_S = 4'd7,
            TRANS_GLOBAL_TIME_S = 4'd8;             
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        ov_data <= 9'b0;
		o_data_wr <= 1'b0;
        rv_cycle_cnt <= 4'b0;
        rv_ptp_cycle_cnt <= 7'b0;
        rv_subtype <= 8'b0;
        rv_report_type <= 16'b0;
        rv_transparent_clock <= 64'b0;
        rv_global_clock <= 48'b0;
		fem_state <= IDLE_S;
    end
    else begin
		case(fem_state)
			IDLE_S:begin
                rv_report_type <= 16'b0;
                rv_ptp_cycle_cnt <= 7'b0;
                rv_transparent_clock <= 64'b0;
				if((i_data_wr == 1'b1) && (iv_data[8] == 1'b1))begin
                    rv_cycle_cnt <= 4'b1;
                    if(iv_descriptor[15:0] == 16'h0806)begin
                        rv_subtype <= 8'h00;
                        ov_data <= {1'b1,iv_smac[47:40]};
		                o_data_wr <= 1'b1;
                        fem_state <= TRANS_TSMP_HEAD_S;
                    end
                    else if(iv_descriptor[15:0] == 16'h1662)begin
                        rv_subtype <= 8'h01;
                        ov_data <= {1'b1,iv_smac[47:40]};
		                o_data_wr <= 1'b0;
                        fem_state <= DISC_ETH_HEADER_S;
                    end
                    else if(iv_descriptor[15:0] == 16'h98f7)begin
                        rv_subtype <= 8'h05;
                        ov_data <= {1'b1,iv_smac[47:40]};
		                o_data_wr <= 1'b1;
                        fem_state <= TRANS_TSMP_HEAD_S;
                    end
                    else begin
                        ov_data <= {1'b1,iv_smac[47:40]};
		                o_data_wr <= 1'b1;
                        rv_subtype <= 8'h0f;
                        fem_state <= TRANS_TSMP_HEAD_S;
                    end                    
                end
                else begin
                    rv_cycle_cnt <= 4'b0;
                    ov_data <= 9'b0;
		            o_data_wr <= 1'b0;
                    rv_subtype <= 8'h00;
                    fem_state <= IDLE_S;                
                end
            end
            DISC_ETH_HEADER_S:begin
                rv_cycle_cnt <= rv_cycle_cnt + 1'b1;
                if(rv_cycle_cnt == 4'b0)begin
                    o_data_wr <= 1'b1;
                    fem_state <= TRANS_TSMP_HEAD_S;    
                end
                else begin
                    o_data_wr <= 1'b0;
                    fem_state <= DISC_ETH_HEADER_S;    
                end
                
                if(rv_cycle_cnt == 4'd14)begin
                    rv_report_type <= {iv_data[7:0],8'b0};
                end
                else if(rv_cycle_cnt == 4'd15)begin
                    rv_report_type <= {rv_report_type[15:8],iv_data[7:0]};
                end
                else begin
                    rv_report_type <= rv_report_type;
                end
            end
            TRANS_TSMP_HEAD_S:begin
                rv_cycle_cnt <= rv_cycle_cnt + 1'b1;
                o_data_wr <= 1'b1;
                case(rv_cycle_cnt)
                    4'd1:begin
                        ov_data <= {1'b0,iv_smac[39:32]};
                    end
                    4'd2:begin
                        ov_data <= {1'b0,iv_smac[31:24]};
                    end
                    4'd3:begin
                        ov_data <= {1'b0,rv_subtype};
                    end 
                    4'd4:begin
                        ov_data <= {1'b0,iv_smac[15:8]};
                    end
                    4'd5:begin
                        ov_data <= {1'b0,iv_smac[7:0]};
                    end
                    4'd6:begin
                        ov_data <= {1'b0,iv_dmac[47:40]};
                    end
                    4'd7:begin
                        ov_data <= {1'b0,iv_dmac[39:32]};
                    end
                    4'd8:begin
                        ov_data <= {1'b0,iv_dmac[31:24]};
                    end
                    4'd9:begin
                        ov_data <= {1'b0,iv_dmac[23:16]};
                    end 
                    4'd10:begin
                        ov_data <= {1'b0,iv_dmac[15:8]};
                    end
                    4'd11:begin
                        ov_data <= {1'b0,iv_dmac[7:0]};
                    end
                    4'd12:begin
                        ov_data <= {1'b0,8'hff};
                    end
                    4'd13:begin
                        ov_data <= {1'b0,8'h01};
                    end
                    4'd14:begin
                        ov_data <= {1'b0,rv_subtype};
                    end
                    4'd15:begin
                        ov_data <= {1'b0,8'h00};
                        fem_state <= TRANS_ONE_CYCLE_S;
                    end
                    default:begin
                        ov_data <= ov_data;
                    end
                endcase                    					             
			end
            TRANS_ONE_CYCLE_S:begin
                ov_data <= {1'b0,rv_data[142:135]};
                if(iv_descriptor[15:0] == 16'h1662)begin
                    fem_state <= TRANS_REPORT_DATA_S;
                end
                else if(iv_descriptor[15:0] == 16'h98f7)begin
                    rv_ptp_cycle_cnt <= 7'd1;
                    fem_state <= PTP_PROCESS_S;
                end
                else begin
                    fem_state <= TRANS_REC_DATA_S;   
                end              
            end
            PTP_PROCESS_S:begin
                if((rv_ptp_cycle_cnt >= 7'd6) && (rv_ptp_cycle_cnt <= 7'd13))begin
                    rv_transparent_clock <= {rv_transparent_clock[55:0],iv_data[7:0]};
                end
                else if(rv_ptp_cycle_cnt == 7'd21)begin
                    rv_global_clock <= iv_syned_global_time;
                    if(rv_timer > iv_descriptor[34:16])begin
                        rv_transparent_clock <= rv_transparent_clock + rv_timer - iv_descriptor[34:16];
                    end
                    else begin//+4ms
                        rv_transparent_clock <= rv_transparent_clock + rv_timer + 19'd500000 - iv_descriptor[34:16];
                    end 
                end
                else begin
                    rv_transparent_clock <= rv_transparent_clock;
                end
                
                
                rv_ptp_cycle_cnt <= rv_ptp_cycle_cnt + 1'd1;
                case(rv_ptp_cycle_cnt)
                    7'd22:begin
                        ov_data <= {1'b0,rv_transparent_clock[63:56]};
                    end
                    7'd23:begin
                        ov_data <= {1'b0,rv_transparent_clock[55:48]};
                    end
                    7'd24:begin
                        ov_data <= {1'b0,rv_transparent_clock[47:40]};
                    end
                    7'd25:begin
                        ov_data <= {1'b0,rv_transparent_clock[39:32]};
                    end 
                    7'd26:begin
                        ov_data <= {1'b0,rv_transparent_clock[31:24]};
                    end
                    7'd27:begin
                        ov_data <= {1'b0,rv_transparent_clock[23:16]};
                    end 
                    7'd28:begin
                        ov_data <= {1'b0,rv_transparent_clock[15:8]};
                    end
                    7'd29:begin
                        ov_data <= {1'b0,rv_transparent_clock[7:0]};
                    end
                    7'd58:begin
                        ov_data <= {1'b0,rv_global_clock[47:40]};
                    end
                    7'd59:begin
                        ov_data <= {1'b0,rv_global_clock[39:32]};
                    end 
                    7'd60:begin
                        ov_data <= {1'b0,rv_global_clock[31:24]};
                    end 
                    7'd61:begin
                        ov_data <= {1'b0,rv_global_clock[23:16]};
                    end 
                    7'd62:begin
                        ov_data <= {1'b0,rv_global_clock[15:8]};
                    end 
                    7'd63:begin
                        ov_data <= {1'b1,rv_global_clock[7:0]};
                        fem_state <= IDLE_S;     
                    end                         
                    default:begin
                        ov_data <= {1'b0,rv_data[142:135]};
                    end
                endcase                                                     
            end           
            TRANS_REC_DATA_S:begin
                if(rv_data[143] == 1'b1)begin//last cycle
                    ov_data <= {1'b1,rv_data[142:135]};
                    fem_state <= IDLE_S;                   
                end
                else begin
                    ov_data <= {1'b0,rv_data[142:135]};
                    fem_state <= TRANS_REC_DATA_S;  
                end                
            end
            TRANS_REPORT_DATA_S:begin
                if(rv_data[143] == 1'b1)begin//last cycle
                    ov_data <= {1'b0,rv_data[142:135]};
                    rv_cycle_cnt <= 4'b0;
                    fem_state <= TRANS_REPORT_TYPE_S;                   
                end
                else begin
                    ov_data <= {1'b0,rv_data[142:135]};
                    fem_state <= TRANS_REPORT_DATA_S;  
                end            
            end
            TRANS_REPORT_TYPE_S:begin
                rv_cycle_cnt <= rv_cycle_cnt + 1'b1;
                if(rv_cycle_cnt == 4'd0)begin
                    ov_data <= {1'b0,rv_report_type[15:8]};
                    fem_state <= TRANS_REPORT_TYPE_S;                    
                end
                else if(rv_cycle_cnt == 4'd1)begin
                    ov_data <= {1'b1,rv_report_type[7:0]};
                    fem_state <= IDLE_S;	                    
                end
                else begin
                    ov_data <= 9'b0; 
                    fem_state <= IDLE_S;                    
                end                
            end
			default:begin
                ov_data <= 9'b0;
                o_data_wr <= 1'b0;
                fem_state <= IDLE_S;	
			end
		endcase
   end
end	
endmodule