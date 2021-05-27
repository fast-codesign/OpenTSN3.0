
module ram_sdport_w128d64 (
	data,
	wraddress,
	rdaddress,
	wren,
	clock,
	rden,
	q);	

	input	[127:0]	data;
	input	[5:0]	wraddress;
	input	[5:0]	rdaddress;
	input		wren;
	input		clock;
	input		rden;
	output	[127:0]	q;
endmodule
