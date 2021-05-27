
module fifo_w12d4_commonclock_sclr_showahead (
	data,
	wrreq,
	rdreq,
	clock,
	sclr,
	q,
	usedw,
	full,
	empty);	

	input	[11:0]	data;
	input		wrreq;
	input		rdreq;
	input		clock;
	input		sclr;
	output	[11:0]	q;
	output	[1:0]	usedw;
	output		full;
	output		empty;
endmodule
