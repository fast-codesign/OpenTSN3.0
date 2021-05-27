
module ram_sdport_w128d32 (
	data,
	wraddress,
	rdaddress,
	wren,
	clock,
	rden,
	q);	

	input	[127:0]	data;
	input	[4:0]	wraddress;
	input	[4:0]	rdaddress;
	input		wren;
	input		clock;
	input		rden;
	output	[127:0]	q;
endmodule
