
module fifo_w9d16_respectclock_aclr_showahead (
	data,
	wrreq,
	rdreq,
	wrclk,
	rdclk,
	aclr,
	q,
	rdusedw,
	wrusedw,
	rdfull,
	rdempty,
	wrfull,
	wrempty);	

	input	[8:0]	data;
	input		wrreq;
	input		rdreq;
	input		wrclk;
	input		rdclk;
	input		aclr;
	output	[8:0]	q;
	output	[3:0]	rdusedw;
	output	[3:0]	wrusedw;
	output		rdfull;
	output		rdempty;
	output		wrfull;
	output		wrempty;
endmodule
