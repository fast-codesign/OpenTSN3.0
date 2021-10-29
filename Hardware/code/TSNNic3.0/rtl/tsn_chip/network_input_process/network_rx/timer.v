// Copyright (C) 1953-2020 NUDT
// Verilog module name - timer 
// Version: timer_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         time counter
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module timer
    (
        clk_sys,
        reset_n,
        timer_rst,
        timer     
    );

// I/O
// clk & rst
input                   clk_sys;
input                   reset_n;
input                   timer_rst;
// output
output  reg [18:0]      timer;
// internal reg&wire for inport fifo
always@(posedge clk_sys or negedge reset_n)
    if(!reset_n) begin
        timer       <= 19'b0;
        end
    else begin
        if(timer_rst)begin
            timer       <= 19'b0;
            end
        else if(timer == 19'd499999) begin
            timer       <= 19'b0;
            end
        else begin
            timer       <= timer + 1'b1;
            end
        end

endmodule