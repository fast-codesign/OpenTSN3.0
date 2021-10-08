// Copyright (C) 1953-2020 NUDT
// Verilog module name - host_output_interface 
// Version: HOI_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         output process of host interface.
//             - receive pkt,and transmit pkt to PHY;
//             - record timestamp for PTP packet;
//             - add preamble of frame and start-of-frame delimiter before transmitting pkt;
//             - control interframe gap that is 12 cycles.
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module network_output_interface
(
       i_clk,
       i_rst_n,

       iv_pkt_descriptor,
       i_pkt_descriptor_wr,
              
       iv_pkt_data,
       i_pkt_data_wr,
       
       o_pkt_rd_req,
       o_pkt_last_cycle_rx,
       
       o_pkt_cnt_pulse,
       
       ov_data,
       o_data_wr,
       
       iv_syned_global_time,
       i_timer_rst,
       
       hoi_state       
);

// I/O
// clk & rst
input                  i_clk;   
input                  i_rst_n;

input      [60:0]      iv_pkt_descriptor;              
input                  i_pkt_descriptor_wr; 
// receive pkt from PCB  
input      [133:0]     iv_pkt_data;
input                  i_pkt_data_wr;
// reset signal of local timer 
input                  i_timer_rst;  
// synchronized global time 
input      [47:0]      iv_syned_global_time;
// request of reading pkt
output                 o_pkt_rd_req;
// finish of tramsmission of pkt
output reg             o_pkt_last_cycle_rx;

output reg             o_pkt_cnt_pulse;
// transmit pkt to phy     
output reg [7:0]       ov_data;
output reg             o_data_wr;
//***************************************************
//               cache tsntag 
//***************************************************
reg      [47:0] rv_tsntag;
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        rv_tsntag <= 48'b0;
    end
    else begin  
        if(i_pkt_descriptor_wr)begin
            rv_tsntag <= iv_pkt_descriptor[60:13];
        end
        else begin
            rv_tsntag <= rv_tsntag;
        end
    end
end
//***************************************************
//                 cache pkt 
//***************************************************
//use two registers cache pkt
reg        [133:0]     rv_data1;
reg                    r_data1_write_flag;
reg                    r_data1_empty;
reg        [133:0]     rv_data2;
reg                    r_data2_write_flag;
reg                    r_data2_empty;
assign o_pkt_rd_req = r_data1_empty || r_data2_empty;
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        rv_data1 <= 134'b0;
        r_data1_write_flag <= 1'b0;
        rv_data2 <= 134'b0;
        r_data2_write_flag <= 1'b0;
    end
    else begin
        if(i_pkt_data_wr == 1'b1)begin
            if(iv_pkt_data[133:132] == 2'b01)begin//replace DMAC with tsntag
                if(r_data1_empty == 1'b1)begin
                    r_data1_write_flag <= 1'b1;
                    if(iv_pkt_data[31:16] == 16'h0800)begin
                        rv_data1 <= {iv_pkt_data[133:128],rv_tsntag,iv_pkt_data[79:32],16'h1800,iv_pkt_data[15:0]};
                    end
                    else begin
                        rv_data1 <= {iv_pkt_data[133:128],rv_tsntag,iv_pkt_data[79:0]};                  
                    end
                end
                else if(r_data2_empty == 1'b1)begin
                    r_data2_write_flag <= 1'b1;
                    if(iv_pkt_data[31:16] == 16'h0800)begin
                        rv_data2 <= {iv_pkt_data[133:128],rv_tsntag,iv_pkt_data[79:32],16'h1800,iv_pkt_data[15:0]};
                    end
                    else begin
                        rv_data2 <= {iv_pkt_data[133:128],rv_tsntag,iv_pkt_data[79:0]};                  
                    end                    
                end
                else begin
                    r_data1_write_flag <= 1'b0; 
                    r_data2_write_flag <= 1'b0;             
                end
            end
            else begin
                if(r_data1_empty == 1'b1)begin
                    rv_data1 <= iv_pkt_data;
                    r_data1_write_flag <= 1'b1;
                end
                else if(r_data2_empty == 1'b1)begin
                    rv_data2 <= iv_pkt_data;
                    r_data2_write_flag <= 1'b1;         
                end
                else begin
                    r_data1_write_flag <= 1'b0; 
                    r_data2_write_flag <= 1'b0;             
                end            
            end
        end
        else begin 
            r_data1_write_flag <= 1'b0; 
            r_data2_write_flag <= 1'b0; 
        end 
    end
end
//***************************************************
//         receive the last cycle of pkt 
//***************************************************
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        o_pkt_last_cycle_rx <= 1'b0;
    end
    else begin  
        if((iv_pkt_data[133:132] == 2'b10)&&(i_pkt_data_wr == 1'b1))begin
            o_pkt_last_cycle_rx <= 1'b1;
        end
        else begin
            o_pkt_last_cycle_rx <= 1'b0;
        end
    end
end

//***************************************************
//                 transmit pkt 
//***************************************************
reg        [18:0]       rv_timer;  //used to record transmission timestamp of interface for PTP packet.

reg                     r_data1_read_flag;
reg                     r_data2_read_flag;
reg        [1:0]        r_tran_reg;

reg        [10:0]       rv_send_pkt_cnt;
reg        [3:0]        rv_trans_pkt_cnt;
reg        [3:0]        rv_interframe_gap_cnt;
reg                     r_is_ptp;
reg        [18:0]       rv_receive_timestamp;
reg        [63:0]       rv_transparent_timestamp;
reg        [47:0]       rv_global_timestamp;
output reg         [3:0]        hoi_state;
localparam  IDLE_S = 4'd0,
            TRANS_PREAMBLE_SFD_S = 4'd1,
            TRANS_MD_S = 4'd2,
            PTP_TRANSMIT_S = 4'd3,
            UPDATE_TRANSPARENT_TIME_S = 4'd4,
            TRANS_DATA1_S = 4'd5,
            TRANS_DATA2_S = 4'd6,
            TRANS_INTERFRAME_GAP_S = 4'd7;
always @(posedge i_clk or negedge i_rst_n) begin
    if(i_rst_n == 1'b0)begin
        ov_data <= 8'b0;
        o_data_wr <= 1'b0;
        r_is_ptp <= 1'b0;
        rv_trans_pkt_cnt <= 4'd0;
        rv_send_pkt_cnt <= 11'd0;
        r_data1_read_flag <= 1'b0;  
        r_data2_read_flag <= 1'b0;          
        rv_interframe_gap_cnt <= 4'd0;
        rv_receive_timestamp <= 19'b0;
        rv_transparent_timestamp <= 64'b0;
        rv_global_timestamp <= 48'b0;
        o_pkt_cnt_pulse <= 1'b0;
        r_tran_reg <=2'b0;
        hoi_state <= IDLE_S;
    end
    else begin
        case(hoi_state)
            IDLE_S:begin
                rv_trans_pkt_cnt <= 4'd0;
                rv_interframe_gap_cnt <= 4'd0;
                if((r_data1_empty == 1'b0) && (rv_data1[133:132] == 2'b01))begin
                    ov_data <= 8'h55;    //first byte of frame preamble
                    o_data_wr <= 1'b1;
                    rv_send_pkt_cnt <= 11'd1;
                    o_pkt_cnt_pulse <= 1'b1;                        
                    hoi_state <= TRANS_PREAMBLE_SFD_S;
                    r_tran_reg <=2'd1;
                    if((rv_data1[31:16] == 16'h98f7) && ((rv_data1[11:8] == 4'h1)||(rv_data1[11:8] == 4'h3)||(rv_data1[11:8] == 4'h4)))begin
                        r_is_ptp <= 1'b1;
                    end
                    else begin
                        r_is_ptp <= 1'b0;
                    end
                end
                else if((r_data2_empty == 1'b0) && (rv_data2[133:132] == 2'b01))begin
                    ov_data <= 8'h55;    //first byte of frame preamble
                    o_data_wr <= 1'b1;
                    rv_send_pkt_cnt <= 11'd1; 
                    o_pkt_cnt_pulse <= 1'b1;                        
                    hoi_state <= TRANS_PREAMBLE_SFD_S;
                    r_tran_reg <=2'd2;
                    if(rv_data2[31:16] == 16'h98f7 && ((rv_data2[11:8] == 4'h1)||(rv_data2[11:8] == 4'h3)||(rv_data2[11:8] == 4'h4)))begin
                        r_is_ptp <= 1'b1;
                    end
                    else begin
                        r_is_ptp <= 1'b0;
                    end
                end
                else begin
                    ov_data <= 8'h0;
                    o_data_wr <= 1'b0;
                    rv_send_pkt_cnt <= 11'd0;  
                    o_pkt_cnt_pulse <= 1'b0;                        
                    hoi_state <= IDLE_S;
                end
            end
            TRANS_PREAMBLE_SFD_S:begin//generate 7B 0x55 & 1B 0xD5
                o_pkt_cnt_pulse <= 1'b0;
                rv_send_pkt_cnt <= rv_send_pkt_cnt + 11'd1;
                if(rv_send_pkt_cnt <= 11'd6)begin
                    ov_data <= 8'h55;
                    o_data_wr <= 1'b1;
                    hoi_state <= TRANS_PREAMBLE_SFD_S;
                end
                else begin
                    ov_data <= 8'hd5;
                    o_data_wr <= 1'b1;
                    if(r_is_ptp == 1'b1)begin
                        hoi_state <= PTP_TRANSMIT_S;
                    end
                    else begin
                        if(r_tran_reg == 2'd1)begin
                            hoi_state <= TRANS_DATA1_S;
                        end
                        else begin
                            hoi_state <= TRANS_DATA2_S;
                        end
                    end
                end
            end
            PTP_TRANSMIT_S:begin//data1
                rv_trans_pkt_cnt <= rv_trans_pkt_cnt + 4'd1;
                rv_receive_timestamp <= rv_data1[98:80];
                case(rv_trans_pkt_cnt)
                    4'h0:ov_data <= rv_data1[127:120];
                    4'h1:ov_data <= rv_data1[119:112];
                    4'h2:ov_data <= rv_data1[111:104];                        
                    4'h3:ov_data <= rv_data1[103:96];  
                    4'h4:ov_data <= rv_data1[95:88];                
                    4'h5:ov_data <= rv_data1[87:80];
                    4'h6:ov_data <= rv_data1[79:72];
                    4'h7:ov_data <= rv_data1[71:64];
                    4'h8:ov_data <= rv_data1[63:56];
                    4'h9:ov_data <= rv_data1[55:48];
                    4'ha:ov_data <= rv_data1[47:40];
                    4'hb:ov_data <= rv_data1[39:32];
                    4'hc:ov_data <= rv_data1[31:24];                    
                    4'hd:ov_data <= rv_data1[23:16];
                    4'he:ov_data <= rv_data1[15:8]; 
                    4'hf:begin
                        ov_data <= rv_data1[7:0];
                        r_data1_read_flag <= 1'b1;  
                        hoi_state <= UPDATE_TRANSPARENT_TIME_S;
                    end                        
                endcase
            end
            UPDATE_TRANSPARENT_TIME_S:begin//data2
                r_data1_read_flag <= 1'b0;  
                rv_trans_pkt_cnt <= rv_trans_pkt_cnt + 4'd1;
                case(rv_trans_pkt_cnt)
                    4'h0:ov_data <= rv_data2[127:120];
                    4'h1:ov_data <= rv_data2[119:112];
                    4'h2:ov_data <= rv_data2[111:104];
                    4'h3:ov_data <= rv_data2[103:96];
                    4'h4:ov_data <= rv_data2[95:88];                      
                    4'h5:ov_data <= rv_data2[87:80];
                    4'h6:ov_data <= rv_transparent_timestamp[63:56];
                    4'h7:ov_data <= rv_transparent_timestamp[55:48];
                    4'h8:ov_data <= rv_transparent_timestamp[47:40];
                    4'h9:ov_data <= rv_transparent_timestamp[39:32];
                    4'ha:ov_data <= rv_transparent_timestamp[31:24];
                    4'hb:ov_data <= rv_transparent_timestamp[23:16];
                    4'hc:ov_data <= rv_transparent_timestamp[15:8];                 
                    4'hd:ov_data <= rv_transparent_timestamp[7:0];
                    4'he:ov_data <= rv_data2[15:8]; 
                    4'hf:begin
                        ov_data <= rv_data2[7:0];
                        r_data2_read_flag <= 1'b1;  
                        hoi_state <= TRANS_DATA1_S;
                    end                   
                endcase
                if(rv_trans_pkt_cnt == 4'h5)begin
                    if(rv_timer > rv_receive_timestamp)begin
                        rv_transparent_timestamp <= rv_data2[79:16] + rv_timer - rv_receive_timestamp;
                    end
                    else begin//+4ms
                        rv_transparent_timestamp <= rv_data2[79:16] + rv_timer + 19'd500000 - rv_receive_timestamp;
                    end 
                end
                else begin
                    rv_transparent_timestamp <= rv_transparent_timestamp;
                end 
            end             
            TRANS_DATA1_S:begin 
                rv_trans_pkt_cnt <= rv_trans_pkt_cnt + 4'd1;
                case(rv_trans_pkt_cnt)
                    4'h0:ov_data <= rv_data1[127:120];
                    4'h1:ov_data <= rv_data1[119:112];
                    4'h2:ov_data <= rv_data1[111:104];
                    4'h3:ov_data <= rv_data1[103:96];
                    4'h4:ov_data <= rv_data1[95:88];                    
                    4'h5:ov_data <= rv_data1[87:80];
                    4'h6:ov_data <= rv_data1[79:72];
                    4'h7:ov_data <= rv_data1[71:64];
                    4'h8:ov_data <= rv_data1[63:56];
                    4'h9:ov_data <= rv_data1[55:48];
                    4'ha:ov_data <= rv_data1[47:40];
                    4'hb:ov_data <= rv_data1[39:32];
                    4'hc:ov_data <= rv_data1[31:24];                    
                    4'hd:ov_data <= rv_data1[23:16];
                    4'he:ov_data <= rv_data1[15:8]; 
                    4'hf:ov_data <= rv_data1[7:0];                      
                endcase
                if(rv_data1[133:132]==2'b10)begin
                    if(rv_data1[131:128] + rv_trans_pkt_cnt == 4'hf)begin
                        hoi_state <= TRANS_INTERFRAME_GAP_S;
                        r_data1_read_flag <= 1'b1;  
                        r_data2_read_flag <= 1'b0;
                    end
                    else begin
                        r_data1_read_flag <= 1'b0;  
                        r_data2_read_flag <= 1'b0;                  
                        hoi_state <= TRANS_DATA1_S;
                    end
                end
                else begin
                    if(rv_trans_pkt_cnt == 4'hf)begin
                        r_data1_read_flag <= 1'b1;  
                        r_data2_read_flag <= 1'b0;  
                        hoi_state <= TRANS_DATA2_S;
                    end
                    else begin
                        r_data1_read_flag <= 1'b0;  
                        r_data2_read_flag <= 1'b0;  
                        hoi_state <= TRANS_DATA1_S;
                    end
                end
            end         
            TRANS_DATA2_S:begin 
                rv_trans_pkt_cnt <= rv_trans_pkt_cnt + 4'd1;
                case(rv_trans_pkt_cnt)
                    4'h0:ov_data <= rv_data2[127:120];
                    4'h1:ov_data <= rv_data2[119:112];
                    4'h2:ov_data <= rv_data2[111:104];
                    4'h3:ov_data <= rv_data2[103:96];
                    4'h4:ov_data <= rv_data2[95:88];                    
                    4'h5:ov_data <= rv_data2[87:80];
                    4'h6:ov_data <= rv_data2[79:72];
                    4'h7:ov_data <= rv_data2[71:64];
                    4'h8:ov_data <= rv_data2[63:56];
                    4'h9:ov_data <= rv_data2[55:48];
                    4'ha:ov_data <= rv_data2[47:40];
                    4'hb:ov_data <= rv_data2[39:32];
                    4'hc:ov_data <= rv_data2[31:24];                    
                    4'hd:ov_data <= rv_data2[23:16];
                    4'he:ov_data <= rv_data2[15:8]; 
                    4'hf:ov_data <= rv_data2[7:0];              
                endcase 
                if(rv_data2[133:132]==2'b10)begin
                    if(rv_data2[131:128] + rv_trans_pkt_cnt == 4'hf)begin
                        r_data1_read_flag <= 1'b0;  
                        r_data2_read_flag <= 1'b1;  
                        hoi_state <= TRANS_INTERFRAME_GAP_S;
                    end
                    else begin
                        r_data1_read_flag <= 1'b0;  
                        r_data2_read_flag <= 1'b0;
                        hoi_state <= TRANS_DATA2_S;
                    end
                end
                else begin
                    if(rv_trans_pkt_cnt == 4'hf)begin
                        r_data1_read_flag <= 1'b0;  
                        r_data2_read_flag <= 1'b1;
                        hoi_state <= TRANS_DATA1_S;
                    end
                    else begin
                        r_data1_read_flag <= 1'b0;  
                        r_data2_read_flag <= 1'b0;
                        hoi_state <= TRANS_DATA2_S;
                    end
                end
            end      
            TRANS_INTERFRAME_GAP_S:begin//transmit interframe gap(12 bytes) + 4B CRC
                r_data1_read_flag <= 1'b0;  
                r_data2_read_flag <= 1'b0;
                o_data_wr   <= 1'b0;
                rv_interframe_gap_cnt <= rv_interframe_gap_cnt + 4'd1;
                if(rv_interframe_gap_cnt <= 4'd14)begin
                    hoi_state <= TRANS_INTERFRAME_GAP_S;
                end
                else begin
                    hoi_state <= IDLE_S;
                end
            end         
            default:begin
                o_pkt_cnt_pulse <= 1'b0;
                o_data_wr <= 1'b0;
                r_data1_read_flag <= 1'b0;  
                r_data2_read_flag <= 1'b0;              
                r_is_ptp <= 1'b0;
                rv_trans_pkt_cnt <= 4'h0;
                rv_interframe_gap_cnt <= 4'd0;
                hoi_state <= IDLE_S;
            end
        endcase
    end
end
//***************************************************
//       judge whether reg1 & reg2 is empty 
//***************************************************
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        r_data1_empty <= 1'b1; 
        r_data2_empty <= 1'b1;      
    end
    else begin
        if(r_data1_write_flag == 1'b1 && r_data1_read_flag == 1'b1)begin
            r_data1_empty <= r_data1_empty;
        end
        else if(r_data1_write_flag == 1'b1 && r_data1_read_flag == 1'b0)begin
            r_data1_empty <= 1'b0;
        end 
        else if(r_data1_write_flag == 1'b0 && r_data1_read_flag == 1'b1)begin
            r_data1_empty <= 1'b1;
        end         
        else if(r_data1_write_flag == 1'b0 && r_data1_read_flag == 1'b0)begin
            r_data1_empty <= r_data1_empty;
        end 
        
        if(r_data2_write_flag == 1'b1 && r_data2_read_flag == 1'b1)begin
            r_data2_empty <= r_data2_empty;
        end
        else if(r_data2_write_flag == 1'b1 && r_data2_read_flag == 1'b0)begin
            r_data2_empty <= 1'b0;
        end 
        else if(r_data2_write_flag == 1'b0 && r_data2_read_flag == 1'b1)begin
            r_data2_empty <= 1'b1;
        end         
        else if(r_data2_write_flag == 1'b0 && r_data2_read_flag == 1'b0)begin
            r_data2_empty <= r_data2_empty;
        end         
    end
end 
//***************************************************
//                 timer 
//***************************************************
always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n)begin
        rv_timer <= 19'd0;
    end
    else begin  
        if(i_timer_rst == 1'b1)begin
            rv_timer <= 19'd0;
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
endmodule