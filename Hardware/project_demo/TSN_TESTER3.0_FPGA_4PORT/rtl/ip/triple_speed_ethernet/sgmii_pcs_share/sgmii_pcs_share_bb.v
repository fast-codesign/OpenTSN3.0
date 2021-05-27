
module sgmii_pcs_share (
	clk,
	reset,
	reg_data_out,
	reg_rd,
	reg_data_in,
	reg_wr,
	reg_busy,
	reg_addr,
	rx_afull_clk,
	rx_afull_data,
	rx_afull_valid,
	rx_afull_channel,
	mac_rx_clk_0,
	mac_tx_clk_0,
	data_rx_data_0,
	data_rx_eop_0,
	data_rx_error_0,
	data_rx_ready_0,
	data_rx_sop_0,
	data_rx_valid_0,
	data_tx_data_0,
	data_tx_eop_0,
	data_tx_error_0,
	data_tx_ready_0,
	data_tx_sop_0,
	data_tx_valid_0,
	pkt_class_data_0,
	pkt_class_valid_0,
	magic_wakeup_0,
	magic_sleep_n_0,
	tx_crc_fwd_0,
	ref_clk,
	led_crs_0,
	led_link_0,
	led_panel_link_0,
	led_col_0,
	led_an_0,
	led_char_err_0,
	led_disp_err_0,
	rx_recovclkout_0,
	mac_rx_clk_1,
	mac_tx_clk_1,
	data_rx_data_1,
	data_rx_eop_1,
	data_rx_error_1,
	data_rx_ready_1,
	data_rx_sop_1,
	data_rx_valid_1,
	data_tx_data_1,
	data_tx_eop_1,
	data_tx_error_1,
	data_tx_ready_1,
	data_tx_sop_1,
	data_tx_valid_1,
	pkt_class_data_1,
	pkt_class_valid_1,
	magic_wakeup_1,
	magic_sleep_n_1,
	tx_crc_fwd_1,
	mac_rx_clk_2,
	mac_tx_clk_2,
	data_rx_data_2,
	data_rx_eop_2,
	data_rx_error_2,
	data_rx_ready_2,
	data_rx_sop_2,
	data_rx_valid_2,
	data_tx_data_2,
	data_tx_eop_2,
	data_tx_error_2,
	data_tx_ready_2,
	data_tx_sop_2,
	data_tx_valid_2,
	pkt_class_data_2,
	pkt_class_valid_2,
	magic_wakeup_2,
	magic_sleep_n_2,
	tx_crc_fwd_2,
	mac_rx_clk_3,
	mac_tx_clk_3,
	data_rx_data_3,
	data_rx_eop_3,
	data_rx_error_3,
	data_rx_ready_3,
	data_rx_sop_3,
	data_rx_valid_3,
	data_tx_data_3,
	data_tx_eop_3,
	data_tx_error_3,
	data_tx_ready_3,
	data_tx_sop_3,
	data_tx_valid_3,
	pkt_class_data_3,
	pkt_class_valid_3,
	magic_wakeup_3,
	magic_sleep_n_3,
	tx_crc_fwd_3,
	led_crs_1,
	led_link_1,
	led_panel_link_1,
	led_col_1,
	led_an_1,
	led_char_err_1,
	led_disp_err_1,
	rx_recovclkout_1,
	led_crs_2,
	led_link_2,
	led_panel_link_2,
	led_col_2,
	led_an_2,
	led_char_err_2,
	led_disp_err_2,
	rx_recovclkout_2,
	led_crs_3,
	led_link_3,
	led_panel_link_3,
	led_col_3,
	led_an_3,
	led_char_err_3,
	led_disp_err_3,
	rx_recovclkout_3,
	rxp_0,
	txp_0,
	rxp_1,
	txp_1,
	rxp_2,
	txp_2,
	rxp_3,
	txp_3);	

	input		clk;
	input		reset;
	output	[31:0]	reg_data_out;
	input		reg_rd;
	input	[31:0]	reg_data_in;
	input		reg_wr;
	output		reg_busy;
	input	[9:0]	reg_addr;
	input		rx_afull_clk;
	input	[1:0]	rx_afull_data;
	input		rx_afull_valid;
	input	[1:0]	rx_afull_channel;
	output		mac_rx_clk_0;
	output		mac_tx_clk_0;
	output	[7:0]	data_rx_data_0;
	output		data_rx_eop_0;
	output	[4:0]	data_rx_error_0;
	input		data_rx_ready_0;
	output		data_rx_sop_0;
	output		data_rx_valid_0;
	input	[7:0]	data_tx_data_0;
	input		data_tx_eop_0;
	input		data_tx_error_0;
	output		data_tx_ready_0;
	input		data_tx_sop_0;
	input		data_tx_valid_0;
	output	[4:0]	pkt_class_data_0;
	output		pkt_class_valid_0;
	output		magic_wakeup_0;
	input		magic_sleep_n_0;
	input		tx_crc_fwd_0;
	input		ref_clk;
	output		led_crs_0;
	output		led_link_0;
	output		led_panel_link_0;
	output		led_col_0;
	output		led_an_0;
	output		led_char_err_0;
	output		led_disp_err_0;
	output		rx_recovclkout_0;
	output		mac_rx_clk_1;
	output		mac_tx_clk_1;
	output	[7:0]	data_rx_data_1;
	output		data_rx_eop_1;
	output	[4:0]	data_rx_error_1;
	input		data_rx_ready_1;
	output		data_rx_sop_1;
	output		data_rx_valid_1;
	input	[7:0]	data_tx_data_1;
	input		data_tx_eop_1;
	input		data_tx_error_1;
	output		data_tx_ready_1;
	input		data_tx_sop_1;
	input		data_tx_valid_1;
	output	[4:0]	pkt_class_data_1;
	output		pkt_class_valid_1;
	output		magic_wakeup_1;
	input		magic_sleep_n_1;
	input		tx_crc_fwd_1;
	output		mac_rx_clk_2;
	output		mac_tx_clk_2;
	output	[7:0]	data_rx_data_2;
	output		data_rx_eop_2;
	output	[4:0]	data_rx_error_2;
	input		data_rx_ready_2;
	output		data_rx_sop_2;
	output		data_rx_valid_2;
	input	[7:0]	data_tx_data_2;
	input		data_tx_eop_2;
	input		data_tx_error_2;
	output		data_tx_ready_2;
	input		data_tx_sop_2;
	input		data_tx_valid_2;
	output	[4:0]	pkt_class_data_2;
	output		pkt_class_valid_2;
	output		magic_wakeup_2;
	input		magic_sleep_n_2;
	input		tx_crc_fwd_2;
	output		mac_rx_clk_3;
	output		mac_tx_clk_3;
	output	[7:0]	data_rx_data_3;
	output		data_rx_eop_3;
	output	[4:0]	data_rx_error_3;
	input		data_rx_ready_3;
	output		data_rx_sop_3;
	output		data_rx_valid_3;
	input	[7:0]	data_tx_data_3;
	input		data_tx_eop_3;
	input		data_tx_error_3;
	output		data_tx_ready_3;
	input		data_tx_sop_3;
	input		data_tx_valid_3;
	output	[4:0]	pkt_class_data_3;
	output		pkt_class_valid_3;
	output		magic_wakeup_3;
	input		magic_sleep_n_3;
	input		tx_crc_fwd_3;
	output		led_crs_1;
	output		led_link_1;
	output		led_panel_link_1;
	output		led_col_1;
	output		led_an_1;
	output		led_char_err_1;
	output		led_disp_err_1;
	output		rx_recovclkout_1;
	output		led_crs_2;
	output		led_link_2;
	output		led_panel_link_2;
	output		led_col_2;
	output		led_an_2;
	output		led_char_err_2;
	output		led_disp_err_2;
	output		rx_recovclkout_2;
	output		led_crs_3;
	output		led_link_3;
	output		led_panel_link_3;
	output		led_col_3;
	output		led_an_3;
	output		led_char_err_3;
	output		led_disp_err_3;
	output		rx_recovclkout_3;
	input		rxp_0;
	output		txp_0;
	input		rxp_1;
	output		txp_1;
	input		rxp_2;
	output		txp_2;
	input		rxp_3;
	output		txp_3;
endmodule
