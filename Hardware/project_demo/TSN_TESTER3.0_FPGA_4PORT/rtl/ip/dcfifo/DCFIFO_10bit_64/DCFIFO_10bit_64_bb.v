
module DCFIFO_10bit_64 (
	data,
	wrreq,
	rdreq,
	wrclk,
	rdclk,
	aclr,
	q);	

	input	[9:0]	data;
	input		wrreq;
	input		rdreq;
	input		wrclk;
	input		rdclk;
	input		aclr;
	output	[9:0]	q;
endmodule
