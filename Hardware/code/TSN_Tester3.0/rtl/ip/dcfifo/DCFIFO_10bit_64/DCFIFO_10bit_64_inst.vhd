	component DCFIFO_10bit_64 is
		port (
			data  : in  std_logic_vector(9 downto 0) := (others => 'X'); -- datain
			wrreq : in  std_logic                    := 'X';             -- wrreq
			rdreq : in  std_logic                    := 'X';             -- rdreq
			wrclk : in  std_logic                    := 'X';             -- wrclk
			rdclk : in  std_logic                    := 'X';             -- rdclk
			aclr  : in  std_logic                    := 'X';             -- aclr
			q     : out std_logic_vector(9 downto 0)                     -- dataout
		);
	end component DCFIFO_10bit_64;

	u0 : component DCFIFO_10bit_64
		port map (
			data  => CONNECTED_TO_data,  --  fifo_input.datain
			wrreq => CONNECTED_TO_wrreq, --            .wrreq
			rdreq => CONNECTED_TO_rdreq, --            .rdreq
			wrclk => CONNECTED_TO_wrclk, --            .wrclk
			rdclk => CONNECTED_TO_rdclk, --            .rdclk
			aclr  => CONNECTED_TO_aclr,  --            .aclr
			q     => CONNECTED_TO_q      -- fifo_output.dataout
		);

