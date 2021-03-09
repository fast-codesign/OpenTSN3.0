module tsnnic_top(
       i_clk,
	   
	   i_hard_rst_n,
	   i_button_rst_n,
	   i_et_resetc_rst_n,  
            
	   //hrp
	   i_gmii_rxclk_host,
	   i_gmii_dv_host,
	   iv_gmii_rxd_host,
	   i_gmii_er_host,	   
	   //htp
	   ov_gmii_txd_host, 
	   o_gmii_tx_en_host,
	   o_gmii_tx_er_host,
	   o_gmii_tx_clk_host,

	   i_gmii_rxclk_p1,
	   i_gmii_dv_p1,
	   iv_gmii_rxd_p1,
	   i_gmii_er_p1,            
	   ov_gmii_txd_p1,
	   o_gmii_tx_en_p1,
	   o_gmii_tx_er_p1,
	   o_gmii_tx_clk_p1,
       
       o_init_led,
       pluse_s
);
input                   i_clk;					//125Mhz

input                   i_hard_rst_n;
input                   i_button_rst_n;
input                   i_et_resetc_rst_n;

output      		 	pluse_s;
output      		 	o_init_led;

input					i_gmii_rxclk_p1;
input					i_gmii_dv_p1;
input		[7:0]		iv_gmii_rxd_p1;
input					i_gmii_er_p1;
output      [7:0] 	  	ov_gmii_txd_p1;
output      		 	o_gmii_tx_en_p1;
output      		 	o_gmii_tx_er_p1;
output      		 	o_gmii_tx_clk_p1;

input					i_gmii_rxclk_host;
input	  				i_gmii_dv_host;
input		[7:0]	 	iv_gmii_rxd_host;
input					i_gmii_er_host;
output      [7:0] 	  	ov_gmii_txd_host;
output      		 	o_gmii_tx_en_host;
output      		 	o_gmii_tx_er_host;
output      		 	o_gmii_tx_clk_host;

wire                    w_timer_rst_gts2others;

wire        [203:0]  	wv_wr_command;
wire        	        w_wr_command_wr; 
            
wire        [203:0]	    wv_rd_command;
wire          	        w_rd_command_wr;
wire        [203:0]	    wv_rd_command_ack;
                        
wire        [7:0]	    w_gmii_data_ecp2hcp;
wire          	        w_gmii_data_en_ecp2hcp;
wire              	    w_gmii_data_er_ecp2hcp;
wire                    w_gmii_data_clk_ecp2hcp;
            
wire        [7:0]	    w_gmii_data_hcp2ecp;
wire          	        w_gmii_data_en_hcp2ecp;
wire              	    w_gmii_data_er_hcp2ecp;
wire                    w_gmii_data_clk_hcp2ecp;
//reset sync
wire				    w_core_rst_n;
wire				    w_gmii_rst_n_p0;
wire				    w_gmii_rst_n_host;
wire				    w_rst_n;
assign w_rst_n = i_hard_rst_n & i_button_rst_n & i_et_resetc_rst_n;

reg        [31:0]       rv_tsn_chip_version/*synthesis noprune*/;
always @(posedge i_clk or negedge w_core_rst_n) begin
    if(!w_core_rst_n) begin
        rv_tsn_chip_version <= 32'h0;
    end
    else begin
        rv_tsn_chip_version <= rv_tsn_chip_version;
    end
end
reset_sync core_reset_sync(
.i_clk(i_clk),
.i_rst_n(w_rst_n),

.o_rst_n_sync(w_core_rst_n)   
);
reset_sync gmii_p0_reset_sync(
.i_clk(i_clk),
.i_rst_n(w_rst_n),

.o_rst_n_sync(w_gmii_rst_n_p0)   
);
reset_sync gmii_p1_reset_sync(
.i_clk(i_clk),
.i_rst_n(w_rst_n),

.o_rst_n_sync(w_gmii_rst_n_p1)   
);
reset_sync gmii_host_reset_sync(
.i_clk(i_gmii_rxclk_host),
.i_rst_n(w_rst_n),

.o_rst_n_sync(w_gmii_rst_n_host)   
);
time_sensitive_end time_sensitive_end_tb(
.i_clk(i_clk),
.i_rst_n(w_core_rst_n),

.i_gmii_rst_n_p0(w_gmii_rst_n_p0),     
.i_gmii_rst_n_p1(w_gmii_rst_n_p1),          
.i_gmii_rst_n_host(w_gmii_rst_n_host), 

.i_gmii_rxclk_p0(i_clk),
.i_gmii_dv_p0(w_gmii_data_en_hcp2ecp),
.iv_gmii_rxd_p0(w_gmii_data_hcp2ecp),
.i_gmii_er_p0(w_gmii_data_er_hcp2ecp),

.ov_gmii_txd_p0(w_gmii_data_ecp2hcp),
.o_gmii_tx_en_p0(w_gmii_data_en_ecp2hcp),
.o_gmii_tx_er_p0(w_gmii_data_er_ecp2hcp),
.o_gmii_tx_clk_p0(w_gmii_data_clk_ecp2hcp),

.ov_gmii_txd_p1(ov_gmii_txd_p1),
.o_gmii_tx_en_p1(o_gmii_tx_en_p1),
.o_gmii_tx_er_p1(o_gmii_tx_er_p1),
.o_gmii_tx_clk_p1(o_gmii_tx_clk_p1),

.i_gmii_rxclk_p1(i_gmii_rxclk_p1),
.i_gmii_dv_p1(i_gmii_dv_p1),
.iv_gmii_rxd_p1(iv_gmii_rxd_p1),
.i_gmii_er_p1(i_gmii_er_p1),

//hrp
.i_gmii_rxclk_host(i_gmii_rxclk_host),
.i_gmii_dv_host(i_gmii_dv_host),
.iv_gmii_rxd_host(iv_gmii_rxd_host),
.i_gmii_er_host(i_gmii_er_host),
//htp
.ov_gmii_txd_host(ov_gmii_txd_host),
.o_gmii_tx_en_host(o_gmii_tx_en_host),
.o_gmii_tx_er_host(o_gmii_tx_er_host),
.o_gmii_tx_clk_host(o_gmii_tx_clk_host),

.iv_wr_command(wv_wr_command),
.i_wr_command_wr(w_wr_command_wr),        

.iv_rd_command(wv_rd_command),
.i_rd_command_wr(w_rd_command_wr),        
.ov_rd_command_ack(wv_rd_command_ack), 

.i_timer_rst(w_timer_rst_gts2others),
.o_init_led(o_init_led),
.o_fifo_overflow_pulse_host_rx(), 
.o_fifo_underflow_pulse_host_rx(),
.o_fifo_underflow_pulse_p0_rx(),
.o_fifo_overflow_pulse_p0_rx(), 
.o_fifo_underflow_pulse_p1_rx(),
.o_fifo_overflow_pulse_p1_rx(), 

.o_fifo_overflow_pulse_host_tx(),
.o_fifo_overflow_pulse_p0_tx(),
.o_fifo_overflow_pulse_p1_tx() 
);
hcp hcp_inst(
.i_clk(i_clk),
.i_rst_n(w_core_rst_n),

.o_timer_rst_gts2others(w_timer_rst_gts2others),
.ov_time_slot(),
.o_time_slot_switch(),

.ov_wr_command(wv_wr_command),
.o_wr_command_wr(w_wr_command_wr), 

.ov_rd_command(wv_rd_command),
.o_rd_command_wr(w_rd_command_wr),        
.iv_rd_command_ack(1'b0),        

.i_gmii_rxclk(w_gmii_data_clk_ecp2hcp),
.i_gmii_dv(w_gmii_data_en_ecp2hcp),
.iv_gmii_rxd(w_gmii_data_ecp2hcp),
.i_gmii_er(w_gmii_data_er_ecp2hcp),       

.ov_gmii_txd(w_gmii_data_hcp2ecp),
.o_gmii_tx_en(w_gmii_data_en_hcp2ecp),
.o_gmii_tx_er(w_gmii_data_er_hcp2ecp),
.o_gmii_tx_clk(w_gmii_data_clk_hcp2ecp),

.o_s_pulse(o_s_pulse)         
);
endmodule
