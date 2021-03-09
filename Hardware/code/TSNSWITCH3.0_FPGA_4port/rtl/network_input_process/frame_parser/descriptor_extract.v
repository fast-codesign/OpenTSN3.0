// Copyright (C) 1953-2020 NUDT
// Verilog module name - descriptor_extract
// Version: DEE_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         descriptor extract
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module descriptor_extract #(parameter inport = 4'b0000)
(
        clk_sys,
        reset_n,
       
        iv_data,
        i_data_wr,
        iv_rec_ts,
        port_type,
        free_bufid_fifo_rdusedw,
        be_threshold_value1,
        rc_threshold_value2,
        map_req_threshold_value3,
        o_pkt_discard_pulse,
        
        ov_data,
        o_data_wr,
        o_descriptor_valid,
        ov_descriptor,
        
        descriptor_extract_state
    );
// I/O
// clk & rst
input                   clk_sys;
input                   reset_n;
//input
input       [8:0]       iv_data;
input                   i_data_wr;
input       [18:0]      iv_rec_ts;
input                   port_type;
input       [8:0]       free_bufid_fifo_rdusedw;
input       [8:0]       be_threshold_value1;
input       [8:0]       rc_threshold_value2;
input       [8:0]       map_req_threshold_value3;
output  reg             o_pkt_discard_pulse;
//output
output  reg [8:0]       ov_data;
output  reg             o_data_wr;
output  reg             o_descriptor_valid;
output  reg [45:0]      ov_descriptor;

output  reg [3:0]       descriptor_extract_state;
//internal wire
reg [2:0]   byte_cnt; 
reg     [18:0]  reg_rec_ts;

localparam  IDLE_S              = 4'b0000,
            MAPPED_SENCOND_S    = 4'b0001,
            MAPPED_THIRD_S      = 4'b0010,
            MAPPED_FOURTH_S     = 4'b0011,
            MAPPED_FIFTH_S      = 4'b0100,
            MAPPED_SIXTH_S      = 4'b0101,
            MAPPED_OTHER_S      = 4'b0110,
            TRAN_STANDARD_S     = 4'b0111,
            DISC_S              = 4'b1000;
always@(posedge clk_sys or negedge reset_n)
    if(!reset_n) begin
        ov_data             <= 9'b0;
        o_data_wr           <= 1'b0;
        o_descriptor_valid  <= 1'b0;
        ov_descriptor       <= 46'b0;
        byte_cnt            <= 3'b0;
        reg_rec_ts          <= 19'b0;
        o_pkt_discard_pulse             <= 1'b0;
        descriptor_extract_state        <= IDLE_S;
        end
    else begin
        case(descriptor_extract_state)
            IDLE_S:begin
                if((i_data_wr == 1'b1 && iv_data[8] == 1'b1))begin//head
                    ov_data             <= iv_data;
                    ov_descriptor[35:33]<= iv_data[7:5];//flow_type
                    ov_descriptor[32:28]<= iv_data[4:0];//flow_id[13:9]
                    o_descriptor_valid  <= 1'b0;
                    reg_rec_ts          <= iv_rec_ts;
                    if(port_type == 1'b1)begin//handle unmapped pkt
                        if((free_bufid_fifo_rdusedw <=  map_req_threshold_value3) || (free_bufid_fifo_rdusedw == 9'h0)) begin
                        //discard pkt when bufid under threshold or bufid is used up
                            o_data_wr                       <= 1'h0;
                            o_pkt_discard_pulse             <= 1'b1;
                            descriptor_extract_state        <= DISC_S;
                            end 
                        else begin
                            o_data_wr           <= 1'h1;
                            byte_cnt            <= 3'b1;
                            o_pkt_discard_pulse             <= 1'b0;
                            descriptor_extract_state        <= TRAN_STANDARD_S;
                            end
                        end
                    else begin
                        case(iv_data[7:5])
                            3'd3:begin//RC
                                if((free_bufid_fifo_rdusedw <=  rc_threshold_value2) || (free_bufid_fifo_rdusedw == 9'h0))begin
                                //discard pkt when bufid under threshold or bufid is used up
                                    o_data_wr                   <= 1'h0;
                                    o_pkt_discard_pulse         <= 1'b1;
                                    descriptor_extract_state    <= DISC_S;
                                end
                                else begin
                                    o_data_wr                   <= 1'h1;
                                    o_pkt_discard_pulse         <= 1'b0;
                                    descriptor_extract_state    <= MAPPED_SENCOND_S;
                                end
                            end
                            
                            3'd6:begin//BE
                                if((free_bufid_fifo_rdusedw <=  rc_threshold_value2) || (free_bufid_fifo_rdusedw    <=  be_threshold_value1) || (free_bufid_fifo_rdusedw == 9'h0))begin
                                //discard pkt when bufid under threshold or bufid is used up
                                    o_data_wr                   <= 1'h0;
                                    o_pkt_discard_pulse         <= 1'b1;
                                    descriptor_extract_state    <= DISC_S;
                                end
                                else begin
                                    o_data_wr                   <= 1'h1;
                                    o_pkt_discard_pulse         <= 1'b0;
                                    descriptor_extract_state    <= MAPPED_SENCOND_S;
                                end
                            end
                            
                            default:begin
                                if(free_bufid_fifo_rdusedw == 9'h0)begin
                                    o_data_wr                   <= 1'h0;
                                    o_pkt_discard_pulse         <= 1'b1;
                                    descriptor_extract_state    <= DISC_S;
                                end
                                else begin
                                    o_data_wr                   <= 1'h1;
                                    o_pkt_discard_pulse         <= 1'b0;
                                    descriptor_extract_state    <= MAPPED_SENCOND_S;
                                end
                            end
                        endcase
                        end
                    end
                else begin
                    ov_descriptor       <= 46'b0;
                    ov_data             <= 9'b0;
                    o_data_wr           <= 1'b0;
                    reg_rec_ts          <= 19'b0;
                    o_pkt_discard_pulse             <= 1'b0;
                    descriptor_extract_state        <= IDLE_S;
                    end
                end
            TRAN_STANDARD_S:begin           //standard ethernet type
                ov_data         <= iv_data;
                o_data_wr       <= i_data_wr;
                //state judge
                if(i_data_wr == 1'b1 && iv_data[8] ==  1'b1)begin//tail
                    descriptor_extract_state    <= IDLE_S;
                    end
                else if(i_data_wr == 1'b1 && iv_data[8] ==  1'b0)begin//middle
                    descriptor_extract_state    <= TRAN_STANDARD_S;
                    end
                else begin//invalid
                    descriptor_extract_state    <= IDLE_S;
                    end
                //send descriptor
                if(byte_cnt < 3'd5) begin
                    byte_cnt                <= byte_cnt + 3'b1; 
                    ov_descriptor           <= 46'b0;                   
                    o_descriptor_valid      <= 1'b0;
                    end
                else if(byte_cnt == 3'd5)begin      //when sixth cycle,send descriptor
                    ov_descriptor[45:41]    <= 5'b0;            //inject_addr/submit_addr
                    ov_descriptor[40]       <= 1'b0;            //frag_last
                    ov_descriptor[39:36]    <= inport;          //inport
                    ov_descriptor[35:33]    <= 3'b111;          //flow_type
                    ov_descriptor[32:19]    <= 14'b0;           //flow_id
                    ov_descriptor[18]       <= 1'b0;            //Lookup disable
                    ov_descriptor[17:9]     <= 9'b100000000;    //Outport(host interface of ASIC 9'b100000000)
                    ov_descriptor[8:0]      <= 9'b0;            //pkt_bufid,reserve
                    o_descriptor_valid      <= 1'b1;
                    byte_cnt                <= byte_cnt + 3'b1;                     
                    end
                else begin
                    ov_descriptor           <= 46'b0;                   
                    o_descriptor_valid      <= 1'b0;                    
                    byte_cnt                <= byte_cnt;
                    end
                end
            MAPPED_SENCOND_S:begin          //mapped ethernet type
                ov_data                 <= iv_data;
                o_data_wr               <= i_data_wr;
                if(i_data_wr == 1'b1 && iv_data[8] == 1'b0) begin   //middle
                    ov_descriptor[27:20]    <= iv_data[7:0];        //flow_id[8:1]
                    descriptor_extract_state            <= MAPPED_THIRD_S;
                    end
                else begin
                    ov_descriptor           <= 46'b0;
                    descriptor_extract_state            <= IDLE_S;
                    end
                end
            MAPPED_THIRD_S:begin
                ov_data             <= iv_data;
                o_data_wr           <= i_data_wr;
                if(i_data_wr == 1'b1 && iv_data[8] == 1'b0) begin   //middle
                    ov_descriptor[19]       <= iv_data[7];          //flow_id[0]
                    descriptor_extract_state            <= MAPPED_FOURTH_S;
                    end
                else begin
                    ov_descriptor           <= 46'b0;
                    descriptor_extract_state            <= IDLE_S;
                    end
                end
            MAPPED_FOURTH_S:begin
                o_data_wr           <= i_data_wr;
                if(i_data_wr == 1'b1 && iv_data[8] == 1'b0) begin   //middle
                    if(ov_descriptor[35:33] == 3'b100)begin         // PTP pkt
                        ov_data[8:3]            <= iv_data[8:3];
                        ov_data[2:0]            <= reg_rec_ts[18:16];
                        end
                    else begin
                        ov_data                 <= iv_data;
                        end
                    descriptor_extract_state            <= MAPPED_FIFTH_S;
                    end
                else begin
                    ov_data                 <= 9'b0;
                    descriptor_extract_state            <= IDLE_S;
                    end
                end
            MAPPED_FIFTH_S:begin
                o_data_wr           <= i_data_wr;
                if(i_data_wr == 1'b1 && iv_data[8] == 1'b0) begin   //middle
                    if(ov_descriptor[35:33] == 3'b100)begin         // PTP pkt
                        ov_data[8]              <= iv_data[8];
                        ov_data[7:0]            <= reg_rec_ts[15:8];
                        end
                    else begin
                        ov_data                 <= iv_data;
                        ov_descriptor[45]       <= iv_data[6];      //frag_last
                        end
                    descriptor_extract_state            <= MAPPED_SIXTH_S;
                    end
                else begin
                    ov_data                 <= 9'b0;
                    ov_descriptor           <= 46'b0;
                    descriptor_extract_state            <= IDLE_S;
                    end
                end
            MAPPED_SIXTH_S:begin
                o_data_wr           <= i_data_wr;
                if(i_data_wr == 1'b1 && iv_data[8] == 1'b0) begin   //middle
                    if(ov_descriptor[35:33] == 3'b100)begin         // PTP pkt
                        ov_data[8]              <= iv_data[8];
                        ov_data[7:0]            <= reg_rec_ts[7:0];
                        ov_descriptor[45:41]    <= 5'b0;                //inject_addr/submit_addr
                        ov_descriptor[40]       <= 1'b0;                //frag_last
                        ov_descriptor[39:36]    <= inport;              //inport
                        ov_descriptor[35:33]    <= ov_descriptor[35:33];//flow_type
                        ov_descriptor[32:19]    <= ov_descriptor[32:19];//flow_id
                        ov_descriptor[18]       <= 1'b1;                //Lookup enable
                        ov_descriptor[17:9]     <= 9'b0;                //Outport
                        ov_descriptor[8:0]      <= 9'b0;                //pkt_bufid,reserve
                        o_descriptor_valid      <= 1'b1;            
                        end
                    else begin
                        ov_data                 <= iv_data;
                        ov_descriptor[45:41]    <= iv_data[4:0];        //inject_addr/submit_addr
                        ov_descriptor[40]       <= ov_descriptor[40];   //frag_last
                        ov_descriptor[39:36]    <= inport;              //inport
                        ov_descriptor[35:33]    <= ov_descriptor[35:33];//flow_type
                        ov_descriptor[32:19]    <= ov_descriptor[32:19];//flow_id
                        ov_descriptor[18]       <= 1'b1;                //Lookup enable
                        ov_descriptor[17:9]     <= 9'b0;                //Outport
                        ov_descriptor[8:0]      <= 9'b0;                //pkt_bufid,reserve
                        o_descriptor_valid      <= 1'b1;
                        end
                    descriptor_extract_state            <= MAPPED_OTHER_S;
                    end
                else begin
                    ov_data                 <= 9'b0;                
                    ov_descriptor           <= 46'b0;
                    o_descriptor_valid      <= 1'b0;
                    descriptor_extract_state            <= IDLE_S;
                    end
                end
            MAPPED_OTHER_S:begin
                ov_data             <= iv_data;
                o_data_wr           <= i_data_wr;
                ov_descriptor       <= 46'b0;
                o_descriptor_valid  <= 1'b0;
                if(i_data_wr == 1'b1 && iv_data[8] == 1'b1) begin//tail
                    descriptor_extract_state            <= IDLE_S;
                    end
                else if(i_data_wr == 1'b1 && iv_data[8] == 1'b0)begin//middle
                    descriptor_extract_state            <= MAPPED_OTHER_S;
                    end
                else begin
                    descriptor_extract_state            <= IDLE_S;
                    end
                end
                
            DISC_S:begin
                ov_data                         <= 9'h0;
                o_data_wr                       <= 1'h0;
                ov_descriptor                   <= 46'b0;
                o_descriptor_valid              <= 1'b0;
                o_pkt_discard_pulse             <= 1'b0;
                if(i_data_wr == 1'b1 && iv_data[8] == 1'b1)begin
                    descriptor_extract_state        <= IDLE_S;
                end
                else begin
                    descriptor_extract_state        <= DISC_S;
                end
            end

            default:begin
                ov_data             <= 9'b0;
                o_data_wr           <= 1'b0;
                o_descriptor_valid  <= 1'b0;
                ov_descriptor       <= 46'b0;
                byte_cnt            <= 3'b0;
                reg_rec_ts          <= 19'b0;
                descriptor_extract_state        <= IDLE_S;
                end
            endcase
        end
    
endmodule