// Copyright (C) 1953-2020 NUDT
// Verilog module name - forward_lookup_table 
// Version: FLT_V1.0
// Created:
//         by - fenglin 
//         at - 10.2020
////////////////////////////////////////////////////////////////////////////
// Description:
//         use RAM to cahce the forward table
//         parse ctrl data,and compelet the configuration of the lookup table 
//         time division multiplexing for receive descriptor come from network port and host port
//         determine whether a table lookup is required
//         extract flow_id from descriptor,and complete the table
//         forward based on the result of the lookup table
///////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module forward_lookup_table
(
       i_clk,
       i_rst_n,
              
       iv_descriptor_p0,
       i_descriptor_wr_p0,
       o_descriptor_ack_p0,
       
       iv_descriptor_p1,
       i_descriptor_wr_p1,
       o_descriptor_ack_p1,
       
       iv_descriptor_p2,
       i_descriptor_wr_p2,
       o_descriptor_ack_p2,
       
       iv_descriptor_p3,
       i_descriptor_wr_p3,
       o_descriptor_ack_p3,
       
       iv_descriptor_p4,
       i_descriptor_wr_p4,
       o_descriptor_ack_p4,     

       ov_pkt_bufid_p0,
       ov_pkt_type_p0,
       o_pkt_bufid_wr_p0,
       
       ov_pkt_bufid_p1,
       ov_pkt_type_p1,
       o_pkt_bufid_wr_p1,
       
       ov_pkt_bufid_p2,
       ov_pkt_type_p2,
       o_pkt_bufid_wr_p2,
       
       ov_pkt_bufid_p3,
       ov_pkt_type_p3,
       o_pkt_bufid_wr_p3,
       
       ov_pkt_bufid_p4,
       ov_pkt_type_p4,
       o_pkt_bufid_wr_p4,
              
       ov_pkt_bufid,
       o_pkt_bufid_wr,
       ov_pkt_bufid_cnt,
       
       ov_tdm_state,
       
       iv_flt_ram_addr, 
       iv_flt_ram_wdata,
       i_flt_ram_wr,    
       ov_flt_ram_rdata,
       i_flt_ram_rd    
);

// I/O
// clk & rst
input                  i_clk;                   //125Mhz
input                  i_rst_n;
// descriptor from p0
input      [45:0]      iv_descriptor_p0;
input                  i_descriptor_wr_p0;
output                 o_descriptor_ack_p0;
// descriptor from p1      
input      [45:0]      iv_descriptor_p1;
input                  i_descriptor_wr_p1;
output                 o_descriptor_ack_p1;
// descriptor from p2      
input      [45:0]      iv_descriptor_p2;
input                  i_descriptor_wr_p2;
output                 o_descriptor_ack_p2;
// descriptor from p3      
input      [45:0]      iv_descriptor_p3;
input                  i_descriptor_wr_p3;
output                 o_descriptor_ack_p3;
// descriptor from p4      
input      [45:0]      iv_descriptor_p4;
input                  i_descriptor_wr_p4;
output                 o_descriptor_ack_p4;

// pkt_bufid and pkt_type to p0
output     [8:0]       ov_pkt_bufid_p0;
output     [2:0]       ov_pkt_type_p0;
output                 o_pkt_bufid_wr_p0;
// pkt_bufid and pkt_type to p1   
output     [8:0]       ov_pkt_bufid_p1;
output     [2:0]       ov_pkt_type_p1;
output                 o_pkt_bufid_wr_p1;
// pkt_bufid and pkt_type to p2    
output     [8:0]       ov_pkt_bufid_p2;
output     [2:0]       ov_pkt_type_p2;
output                 o_pkt_bufid_wr_p2;
// pkt_bufid and pkt_type to p3    
output     [8:0]       ov_pkt_bufid_p3;
output     [2:0]       ov_pkt_type_p3;
output                 o_pkt_bufid_wr_p3;
// pkt_bufid and pkt_type to p4    
output     [8:0]       ov_pkt_bufid_p4;
output     [2:0]       ov_pkt_type_p4;
output                 o_pkt_bufid_wr_p4;

//forward cnt to pkt_centralize_bufm_memory
output     [8:0]       ov_pkt_bufid;
output                 o_pkt_bufid_wr;
output     [3:0]       ov_pkt_bufid_cnt;

output     [3:0]       ov_tdm_state;

//lookup table RAM
input      [13:0]      iv_flt_ram_addr;
input      [8:0]       iv_flt_ram_wdata;
input                  i_flt_ram_wr;    
output     [8:0]       ov_flt_ram_rdata;
input                  i_flt_ram_rd;  

// time_division_multiplexing to lookup_table
wire      [45:0]       wv_descriptor_tdm2lut;
wire                   w_descriptor_wr_tdm2lut;
 
// LUT to forward
wire      [8:0]        wv_outport_lut2fw;
wire                   w_outport_wr_lut2fw;
wire      [8:0]        wv_pkt_bufid_lut2fw;
wire      [2:0]        wv_pkt_type_lut2fw;
wire      [3:0]        wv_inport_lut2fw;
wire      [4:0]        wv_submit_addr_lut2fw;
wire                   w_pkt_bufid_wr_lut2fw;
// RAM form/to lookup_table/forward
wire      [8:0]        wv_ram_rdata_b;
wire      [13:0]       wv_ram_raddr_b;
wire                   w_ram_rd_b;

wire      [45:0]       wv_descriptor_p0;           
wire                   w_descriptor_wr_p0;         
wire                   w_descriptor_ack_p0;        
                        
wire      [45:0]       wv_descriptor_p1;           
wire                   w_descriptor_wr_p1;         
wire                   w_descriptor_ack_p1;        
                       
wire      [45:0]       wv_descriptor_p2;           
wire                   w_descriptor_wr_p2;         
wire                   w_descriptor_ack_p2;        

wire      [45:0]       wv_descriptor_p3;           
wire                   w_descriptor_wr_p3;         
wire                   w_descriptor_ack_p3;        

wire      [45:0]       wv_descriptor_p4;           
wire                   w_descriptor_wr_p4;         
wire                   w_descriptor_ack_p4;        



descriptor_delay_manage #(.delay_cycle(4'd9)) descriptor_delay_manage_p0_inst
(                              
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
                                
.iv_descriptor                  (iv_descriptor_p0),
.i_descriptor_wr                (i_descriptor_wr_p0),
.o_descriptor_ack               (o_descriptor_ack_p0),
                                
.ov_descriptor                  (wv_descriptor_p0),
.o_descriptor_wr                (w_descriptor_wr_p0),
.i_descriptor_ack               (w_descriptor_ack_p0)
);
                                
descriptor_delay_manage #(.delay_cycle(4'd9)) descriptor_delay_manage_p1_inst
(                              
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
                                
.iv_descriptor                  (iv_descriptor_p1),
.i_descriptor_wr                (i_descriptor_wr_p1),
.o_descriptor_ack               (o_descriptor_ack_p1),
                                
.ov_descriptor                  (wv_descriptor_p1),
.o_descriptor_wr                (w_descriptor_wr_p1),
.i_descriptor_ack               (w_descriptor_ack_p1)
);

descriptor_delay_manage #(.delay_cycle(4'd9)) descriptor_delay_manage_p2_inst
(                              
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
                                
.iv_descriptor                  (iv_descriptor_p2),
.i_descriptor_wr                (i_descriptor_wr_p2),
.o_descriptor_ack               (o_descriptor_ack_p2),
                                
.ov_descriptor                  (wv_descriptor_p2),
.o_descriptor_wr                (w_descriptor_wr_p2),
.i_descriptor_ack               (w_descriptor_ack_p2)
);

descriptor_delay_manage #(.delay_cycle(4'd9)) descriptor_delay_manage_p3_inst
(                              
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
                                
.iv_descriptor                  (iv_descriptor_p3),
.i_descriptor_wr                (i_descriptor_wr_p3),
.o_descriptor_ack               (o_descriptor_ack_p3),
                                
.ov_descriptor                  (wv_descriptor_p3),
.o_descriptor_wr                (w_descriptor_wr_p3),
.i_descriptor_ack               (w_descriptor_ack_p3)
);

descriptor_delay_manage #(.delay_cycle(4'd9)) descriptor_delay_manage_p4_inst
(                              
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
                                
.iv_descriptor                  (iv_descriptor_p4),
.i_descriptor_wr                (i_descriptor_wr_p4),
.o_descriptor_ack               (o_descriptor_ack_p4),
                                
.ov_descriptor                  (wv_descriptor_p4),
.o_descriptor_wr                (w_descriptor_wr_p4),
.i_descriptor_ack               (w_descriptor_ack_p4)
);

time_division_multiplexing time_division_multiplexing_inst(
.i_clk                          (i_clk                      ),
.i_rst_n                        (i_rst_n                    ),
                                                           
.iv_descriptor_p0               (wv_descriptor_p0           ),
.i_descriptor_wr_p0             (w_descriptor_wr_p0         ),
.o_descriptor_ack_p0            (w_descriptor_ack_p0        ),
                                                         
.iv_descriptor_p1               (wv_descriptor_p1           ),
.i_descriptor_wr_p1             (w_descriptor_wr_p1         ),
.o_descriptor_ack_p1            (w_descriptor_ack_p1        ),
                                                        
.iv_descriptor_p2               (wv_descriptor_p2           ),
.i_descriptor_wr_p2             (w_descriptor_wr_p2         ),
.o_descriptor_ack_p2            (w_descriptor_ack_p2        ),
                                
.iv_descriptor_p3               (wv_descriptor_p3           ),
.i_descriptor_wr_p3             (w_descriptor_wr_p3         ),
.o_descriptor_ack_p3            (w_descriptor_ack_p3        ),
                                
.iv_descriptor_p4               (wv_descriptor_p4           ),
.i_descriptor_wr_p4             (w_descriptor_wr_p4         ),
.o_descriptor_ack_p4            (w_descriptor_ack_p4        ),                               

.ov_tdm_state                   (ov_tdm_state               ),

.ov_descriptor                  (wv_descriptor_tdm2lut      ),
.o_descriptor_wr                (w_descriptor_wr_tdm2lut    )
);

lookup_table lookup_table_inst(                           
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
                               
.iv_descriptor                  (wv_descriptor_tdm2lut),
.i_descriptor_wr                (w_descriptor_wr_tdm2lut),
                               
.ov_ram_raddr                   (wv_ram_raddr_b),
.o_ram_rd                       (w_ram_rd_b),
                               
.ov_outport                     (wv_outport_lut2fw),
.o_outport_wr                   (w_outport_wr_lut2fw),
.ov_pkt_bufid                   (wv_pkt_bufid_lut2fw),
.ov_pkt_type                    (wv_pkt_type_lut2fw),
.ov_submit_addr                 (wv_submit_addr_lut2fw),
.ov_inport                      (wv_inport_lut2fw),            
.o_pkt_bufid_wr                 (w_pkt_bufid_wr_lut2fw)
);

forward forward_inst(
.i_clk                          (i_clk),
.i_rst_n                        (i_rst_n),
                              
.iv_outport                     (wv_outport_lut2fw),
.i_outport_wr                   (w_outport_wr_lut2fw),
.iv_pkt_bufid                   (wv_pkt_bufid_lut2fw),
.iv_pkt_type                    (wv_pkt_type_lut2fw),
.iv_submit_addr                 (wv_submit_addr_lut2fw),
.iv_inport                      (wv_inport_lut2fw),                 
.i_pkt_bufid_wr                 (w_pkt_bufid_wr_lut2fw),
                              
.ov_pkt_bufid_p0                (ov_pkt_bufid_p0     ),
.ov_pkt_type_p0                 (ov_pkt_type_p0      ),
.o_pkt_bufid_wr_p0              (o_pkt_bufid_wr_p0   ), 
                                                    
.ov_pkt_bufid_p1                (ov_pkt_bufid_p1     ),
.ov_pkt_type_p1                 (ov_pkt_type_p1      ),
.o_pkt_bufid_wr_p1              (o_pkt_bufid_wr_p1   ),
 
.ov_pkt_bufid_p2                (ov_pkt_bufid_p2     ),
.ov_pkt_type_p2                 (ov_pkt_type_p2      ),
.o_pkt_bufid_wr_p2              (o_pkt_bufid_wr_p2   ),

.ov_pkt_bufid_p3                (ov_pkt_bufid_p3     ),
.ov_pkt_type_p3                 (ov_pkt_type_p3      ),
.o_pkt_bufid_wr_p3              (o_pkt_bufid_wr_p3   ),

.ov_pkt_bufid_host                (ov_pkt_bufid_p4     ),/////
.ov_pkt_type_host                 (ov_pkt_type_p4      ),
.o_pkt_bufid_wr_host              (o_pkt_bufid_wr_p4   ),
                           
.iv_ram_rdata                   (wv_ram_rdata_b      ),
    
.ov_pkt_bufid                   (ov_pkt_bufid        ),
.o_pkt_bufid_wr                 (o_pkt_bufid_wr      ),
.ov_pkt_bufid_cnt               (ov_pkt_bufid_cnt    )
);

suhddpsram16384x9_s suhddpsram16384x9_s_inst(
.aclr                          (!i_rst_n),
                              
.address_a                     (iv_flt_ram_addr),
.address_b                     (wv_ram_raddr_b),
                             
.clock                         (i_clk),
                             
.data_a                        (iv_flt_ram_wdata),
.data_b                        (9'h0),
                              
.rden_a                        (i_flt_ram_rd),
.rden_b                        (w_ram_rd_b),
                             
.wren_a                        (i_flt_ram_wr),
.wren_b                        (1'b0),
                              
.q_a                           (ov_flt_ram_rdata),
.q_b                           (wv_ram_rdata_b)
);
endmodule