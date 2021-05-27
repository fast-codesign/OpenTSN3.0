
module ram_sdport_separaterwclock_rdaclr_w8d16 (
	data,
	wraddress,
	rdaddress,
	wren,
	wrclock,
	rdclock,
	rden,
	rd_aclr,
	q);	

	input	[7:0]	data;
	input	[3:0]	wraddress;
	input	[3:0]	rdaddress;
	input		wren;
	input		wrclock;
	input		rdclock;
	input		rden;
	input		rd_aclr;
	output	[7:0]	q;
endmodule
