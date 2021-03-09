// Copyright (C) 1953-2020 NUDT
// Verilog module name - gmii_write 
// Version: GWR_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         GMII interface write
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module gmii_write
(
        clk_gmii_rx,
        reset_n,

        i_gmii_dv,
        iv_gmii_rxd,
        i_gmii_er,     

        ov_data,
        o_data_wr,
        i_data_full,
        o_gmii_er,
        o_fifo_overflow_pulse
);

// I/O
// clk & rst
input                   reset_n;
// GMII input
input                   clk_gmii_rx;
input                   i_gmii_dv;
input       [7:0]       iv_gmii_rxd;
input                   i_gmii_er;
// fifo wr
output  reg [8:0]       ov_data;
output  reg             o_data_wr;
input                   i_data_full;
output                  o_gmii_er;
output  reg             o_fifo_overflow_pulse;
assign o_gmii_er = i_gmii_er;
reg [1:0]       gmii_write_state;
// internal reg&wire
reg                     reg_gmii_dv;//register gmii dv
reg         [7:0]       reg_gmii_rxd;//register gmii rx data
reg                     start_flag;//flag of frame head  
wire                    last_flag;//flag of frame end 
localparam  start_s     = 2'b00,
            trans_s     = 2'b01,
            full_error_s= 2'b10;
//Gemac_rx_register
always @(posedge clk_gmii_rx) begin
        reg_gmii_dv     <= i_gmii_dv;
        reg_gmii_rxd    <= iv_gmii_rxd;
    end
//end signal judgment
assign last_flag = (reg_gmii_dv)&&(~i_gmii_dv);
//Gemac_rx_ctrl_state  
always@(posedge clk_gmii_rx or negedge reset_n)
    if(!reset_n) begin
        ov_data             <= 9'b0;
        o_data_wr           <= 1'b0;
        start_flag          <= 1'b0;
        o_fifo_overflow_pulse <= 1'b0;
        gmii_write_state        <= start_s;
        end
    else begin
        case(gmii_write_state)
            start_s:begin
                if(i_gmii_dv == 1'b1)begin//to ouput after 1 cycle delay,judge frame's head once more and make sure pkt is not empty.               
                    ov_data             <= 9'b0;
                    o_data_wr           <= 1'b0;                    
                    start_flag          <= 1'b1; 
                    o_fifo_overflow_pulse <= 1'b0;                    
                    gmii_write_state        <= trans_s;
                end
                else begin
                    start_flag          <= 1'b0;                    
                    gmii_write_state        <= start_s;                    
                    if(i_data_full == 1'b1)begin//when the last cycle of front pkt output,fifo is full.
                        o_fifo_overflow_pulse <= 1'b1;
                        ov_data             <= {1'b1,8'b0};
                        o_data_wr           <= 1'b1;                    
                    end
                    else begin
                        o_fifo_overflow_pulse <= 1'b0;
                        ov_data             <= 9'b0;
                        o_data_wr           <= 1'b0;                     
                    end                     
                end
            end
            trans_s:begin
                start_flag          <= 1'b0;//release flag of frame head that can live 1 cycle.
                if(i_data_full == 1'b0)begin//when fifo is not full,data can be writed into fifo
                    ov_data[7:0]        <= reg_gmii_rxd;
                    o_data_wr           <= reg_gmii_dv;
                    o_fifo_overflow_pulse <= 1'b0;
                    if(start_flag == 1'b1 && last_flag == 1'b0)begin
                        ov_data[8]          <= 1'b1;
                        gmii_write_state        <= trans_s;                 
                    end
                    else if(last_flag == 1'b1) begin
                        ov_data[8]          <= 1'b1;
                        gmii_write_state        <= start_s;
                    end
                    else begin
                        ov_data[8]          <= 1'b0;
                        gmii_write_state        <= trans_s;
                    end
                end         
                else begin                  //when fifo is full,data can not be writed into fifo
                    o_fifo_overflow_pulse <= 1'b1;                
                    if(last_flag == 1'b1)begin
                        ov_data             <= {1'b1,reg_gmii_rxd};
                        o_data_wr           <= 1'b1;
                        gmii_write_state    <= start_s;
                    end
                    else begin
                        ov_data             <= {1'b0,reg_gmii_rxd};
                        o_data_wr           <= 1'b1;
                        gmii_write_state    <= full_error_s;                    
                    end
                end
            end
            full_error_s:begin
                start_flag          <= 1'b0;
                o_fifo_overflow_pulse <= 1'b0;
                if(i_gmii_dv == 1'b1)begin                  
                    ov_data         <= {1'b0,reg_gmii_rxd};
                    o_data_wr       <= 1'b1;
                    gmii_write_state<= full_error_s;
                end
                else begin//when fifo is full,write last flag to fifo.
                    ov_data             <= {1'b1,reg_gmii_rxd};
                    o_data_wr           <= 1'b1;                
                    gmii_write_state        <= start_s;
                end                                     
            end
            default:begin
                ov_data             <= 9'b0;
                o_data_wr           <= 1'b0;
                start_flag          <= 1'b0;
                o_fifo_overflow_pulse <= 1'b0;
                gmii_write_state        <= start_s;             
                end
            endcase
        end
endmodule