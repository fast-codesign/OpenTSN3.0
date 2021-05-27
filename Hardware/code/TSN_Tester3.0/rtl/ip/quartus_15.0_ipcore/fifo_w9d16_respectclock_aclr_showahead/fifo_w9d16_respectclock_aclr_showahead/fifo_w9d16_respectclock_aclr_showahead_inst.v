	fifo_w9d16_respectclock_aclr_showahead u0 (
		.data    (<connected-to-data>),    //  fifo_input.datain
		.wrreq   (<connected-to-wrreq>),   //            .wrreq
		.rdreq   (<connected-to-rdreq>),   //            .rdreq(ack)
		.wrclk   (<connected-to-wrclk>),   //            .wrclk
		.rdclk   (<connected-to-rdclk>),   //            .rdclk
		.aclr    (<connected-to-aclr>),    //            .aclr
		.q       (<connected-to-q>),       // fifo_output.dataout
		.rdusedw (<connected-to-rdusedw>), //            .rdusedw
		.wrusedw (<connected-to-wrusedw>), //            .wrusedw
		.rdfull  (<connected-to-rdfull>),  //            .rdfull
		.rdempty (<connected-to-rdempty>), //            .rdempty
		.wrfull  (<connected-to-wrfull>),  //            .wrfull
		.wrempty (<connected-to-wrempty>)  //            .wrempty
	);

