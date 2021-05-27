
module fifo_w134d128_commonclock_sclr_showahead (
	data,
	wrreq,
	rdreq,
	clock,
	sclr,
	q,
	usedw,
	full,
	empty);	

	input	[133:0]	data;
	input		wrreq;
	input		rdreq;
	input		clock;
	input		sclr;
	output	[133:0]	q;
	output	[6:0]	usedw;
	output		full;
	output		empty;
endmodule
