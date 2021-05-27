	ram_sdport_w128d32 u0 (
		.data      (<connected-to-data>),      //  ram_input.datain
		.wraddress (<connected-to-wraddress>), //           .wraddress
		.rdaddress (<connected-to-rdaddress>), //           .rdaddress
		.wren      (<connected-to-wren>),      //           .wren
		.clock     (<connected-to-clock>),     //           .clock
		.rden      (<connected-to-rden>),      //           .rden
		.q         (<connected-to-q>)          // ram_output.dataout
	);

