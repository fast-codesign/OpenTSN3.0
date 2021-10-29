// Copyright (C) 1953-2020 NUDT
// Verilog module name - gmii_read
// Version: GRD_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         GMII interface Read
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module gmii_read
(
        clk_sys,
        reset_n,

        port_type,
        cfg_finish,
        
        iv_data,
        o_data_rd,
        i_data_empty,
        timer,     

        ov_data,
        o_data_wr,
        ov_rec_ts,

        o_pkt_valid_pulse,
        report_gmii_read_state,
        o_fifo_underflow_pulse
);

// I/O
// clk & rst
input                   clk_sys;
input                   reset_n;
//configuration
input                   port_type;
input       [1:0]       cfg_finish;
// fifo read
output  reg             o_data_rd;
input       [8:0]       iv_data;
input                   i_data_empty;
//timer
input       [18:0]      timer;
// data output
output  reg [8:0]       ov_data;
output  reg             o_data_wr;
output  reg [18:0]      ov_rec_ts;

output  reg             o_pkt_valid_pulse;// receiced pkt's count pulse signal
output  reg             o_fifo_underflow_pulse;
reg         [1:0]       delay_cycle;
output      [1:0]       report_gmii_read_state;
reg         [2:0]       gmii_read_state;
assign report_gmii_read_state = gmii_read_state[1:0];
// internal reg&wire
localparam  idle_s      = 3'd0,
            head_s      = 3'd1,
            tran_s      = 3'd2,
            discard_s   = 3'd3,
            rdempty_error_s = 3'd4;
            
always@(posedge clk_sys or negedge reset_n)
    if(!reset_n) begin
        ov_data         <= 9'b0;
        o_data_wr       <= 1'b0;
        ov_rec_ts       <= 19'b0;
        o_data_rd       <= 1'b0;
        delay_cycle     <= 2'b0;
        o_pkt_valid_pulse   <= 1'b0;
        o_fifo_underflow_pulse <= 1'b0;
        gmii_read_state <= idle_s;
        end
    else begin
        case(gmii_read_state)
            idle_s:begin
                ov_data             <= 9'b0;
                o_data_wr           <= 1'b0;
                o_pkt_valid_pulse   <= 1'b0;
                o_fifo_underflow_pulse <= 1'b0;
                if(i_data_empty == 1'b0)begin
                    if(delay_cycle == 2'h3)begin 
                        o_data_rd <= 1'b1;
                        delay_cycle <= 2'h0;
                        gmii_read_state <= head_s;
                    end
                    else if(delay_cycle == 2'h2)begin
                        o_data_rd <= 1'b1;//FIFO in show head mode
                        delay_cycle <= delay_cycle + 1'b1;
                        gmii_read_state <= idle_s;
                    end
                    else begin
                        o_data_rd           <= 1'b0;
                        delay_cycle <= delay_cycle + 1'b1;
                        gmii_read_state <= idle_s;
                    end                    
                    end
                else begin
                    o_data_rd       <= 1'b0;    
                    delay_cycle     <= 2'h0;                    
                    gmii_read_state <= idle_s;
                    end
                end
            head_s:begin
                o_fifo_underflow_pulse <= 1'b0;
                if(iv_data[8] == 1'b1 && i_data_empty == 1'b0) begin//judge frame head,and make sure pkt body is not empty.
                    if(port_type == 1'b1 && (cfg_finish == 2'b01 || cfg_finish == 2'b10 || cfg_finish == 2'b11))begin//port_type:1 input standard pkt. cfg_finish:00 discard all pkt; 01,10,11 passthrough all pkt.
                        ov_data             <= iv_data;
                        o_data_wr           <= 1'b1;
                        ov_rec_ts           <= timer;
                        o_data_rd           <= 1'b1;
                        gmii_read_state     <= tran_s;
                        end
                    else if(port_type == 1'b0 && cfg_finish == 2'b01 && iv_data[7:5] == 3'b101)begin//port_type:0 input mapped pkt;cfg_finish:01 only passthrough NMAC pkt.
                        ov_data             <= iv_data;
                        o_data_wr           <= 1'b1;
                        ov_rec_ts           <= timer;
                        o_data_rd           <= 1'b1;
                        gmii_read_state     <= tran_s;
                        end
                    else if(port_type == 1'b0 && cfg_finish == 2'b10 && ((iv_data[7:5] != 3'b000) && (iv_data[7:5] != 3'b001) && (iv_data[7:5] != 3'b010)))begin//port_type:0 input mapped pkt;cfg_finish:10 only passthrough not TS pkt.
                        ov_data             <= iv_data;
                        o_data_wr           <= 1'b1;
                        ov_rec_ts           <= timer;
                        o_data_rd           <= 1'b1;
                        gmii_read_state     <= tran_s;
                        end
                    else if(port_type == 1'b0 && cfg_finish == 2'b11)begin//port_type:0 input mapped pkt;cfg_finish:11 passthrough all pkt.
                        ov_data             <= iv_data;
                        o_data_wr           <= 1'b1;
                        ov_rec_ts           <= timer;
                        o_data_rd           <= 1'b1;
                        gmii_read_state     <= tran_s;
                        end
                    else begin
                        ov_data             <= 9'b0;
                        o_data_wr           <= 1'b0;
                        ov_rec_ts           <= 19'b0;
                        o_data_rd           <= 1'b1;
                        gmii_read_state     <= discard_s;
                        end
                    end
                else begin
                    ov_rec_ts           <= 19'b0;
                    ov_data             <= 9'b0;
                    o_data_wr           <= 1'b0;
                    o_data_rd           <= 1'b0;                    
                    gmii_read_state     <= idle_s;
                    end
                end
            tran_s:begin
                ov_rec_ts           <= 19'b0;
                if(iv_data[8] == 1'b0 && i_data_empty == 1'b0) begin//middle
                    ov_data             <= iv_data;
                    o_data_wr           <= 1'b1;                    
                    o_data_rd           <= 1'b1;
                    gmii_read_state     <= tran_s;
                    end
                else if(iv_data[8] == 1'b1) begin//tail
                    ov_data             <= iv_data;
                    o_pkt_valid_pulse   <= 1'b1;
                    o_data_wr           <= 1'b1;
                    o_data_rd           <= 1'b0;                    
                    gmii_read_state     <= idle_s;
                    end
                else if(i_data_empty == 1'b1)begin
                    ov_data             <= {1'b1,8'b0};
                    o_data_wr           <= 1'b1;
                    o_data_rd           <= 1'b1;
                    o_fifo_underflow_pulse <= 1'b1;
                    gmii_read_state     <= rdempty_error_s;
                    end                    
                else begin
                    ov_data             <= 9'b0;
                    o_data_wr           <= 1'b0;
                    o_data_rd           <= 1'b0;
                    gmii_read_state     <= idle_s;
                    end
                end
            discard_s:begin
                if(iv_data[8] == 1'b1) begin//tail
                    ov_data             <= 9'b0;
                    o_data_wr           <= 1'b0;
                    o_data_rd           <= 1'b0;                    
                    gmii_read_state     <= idle_s;
                    end
                else begin
                    ov_data             <= 9'b0;
                    o_data_wr           <= 1'b0;
                    o_data_rd           <= 1'b1;
                    gmii_read_state     <= discard_s;
                    end             
                end
            rdempty_error_s:begin
                ov_data <= 9'b0;
                o_data_wr <= 1'b0;
                o_fifo_underflow_pulse <= 1'b0;
                if(iv_data[8] == 1'b1)begin
                    o_data_rd <= 1'b0;                  
                    gmii_read_state <= idle_s;
                end
                else begin
                    o_data_rd <= 1'b1;
                    gmii_read_state <= rdempty_error_s;
                end             
            end
            default:begin
                ov_data             <= 9'b0;
                o_data_wr           <= 1'b0;
                ov_rec_ts           <= 19'b0;
                o_data_rd           <= 1'b0;
                gmii_read_state     <= idle_s;              
                end
            endcase
        end
        
endmodule