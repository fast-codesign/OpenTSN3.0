	component fifo_w134d128_commonclock_sclr_showahead is
		port (
			data  : in  std_logic_vector(133 downto 0) := (others => 'X'); -- datain
			wrreq : in  std_logic                      := 'X';             -- wrreq
			rdreq : in  std_logic                      := 'X';             -- rdreq(ack)
			clock : in  std_logic                      := 'X';             -- clk
			sclr  : in  std_logic                      := 'X';             -- sclr
			q     : out std_logic_vector(133 downto 0);                    -- dataout
			usedw : out std_logic_vector(6 downto 0);                      -- usedw
			full  : out std_logic;                                         -- full
			empty : out std_logic                                          -- empty
		);
	end component fifo_w134d128_commonclock_sclr_showahead;

	u0 : component fifo_w134d128_commonclock_sclr_showahead
		port map (
			data  => CONNECTED_TO_data,  --  fifo_input.datain
			wrreq => CONNECTED_TO_wrreq, --            .wrreq
			rdreq => CONNECTED_TO_rdreq, --            .rdreq(ack)
			clock => CONNECTED_TO_clock, --            .clk
			sclr  => CONNECTED_TO_sclr,  --            .sclr
			q     => CONNECTED_TO_q,     -- fifo_output.dataout
			usedw => CONNECTED_TO_usedw, --            .usedw
			full  => CONNECTED_TO_full,  --            .full
			empty => CONNECTED_TO_empty  --            .empty
		);

