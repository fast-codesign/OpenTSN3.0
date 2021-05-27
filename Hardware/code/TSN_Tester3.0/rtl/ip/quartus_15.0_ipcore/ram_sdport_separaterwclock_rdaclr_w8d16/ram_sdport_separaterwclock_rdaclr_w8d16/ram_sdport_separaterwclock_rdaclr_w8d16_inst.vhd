	component ram_sdport_separaterwclock_rdaclr_w8d16 is
		port (
			data      : in  std_logic_vector(7 downto 0) := (others => 'X'); -- datain
			wraddress : in  std_logic_vector(3 downto 0) := (others => 'X'); -- wraddress
			rdaddress : in  std_logic_vector(3 downto 0) := (others => 'X'); -- rdaddress
			wren      : in  std_logic                    := 'X';             -- wren
			wrclock   : in  std_logic                    := 'X';             -- wrclock
			rdclock   : in  std_logic                    := 'X';             -- rdclock
			rden      : in  std_logic                    := 'X';             -- rden
			rd_aclr   : in  std_logic                    := 'X';             -- rd_aclr
			q         : out std_logic_vector(7 downto 0)                     -- dataout
		);
	end component ram_sdport_separaterwclock_rdaclr_w8d16;

	u0 : component ram_sdport_separaterwclock_rdaclr_w8d16
		port map (
			data      => CONNECTED_TO_data,      --  ram_input.datain
			wraddress => CONNECTED_TO_wraddress, --           .wraddress
			rdaddress => CONNECTED_TO_rdaddress, --           .rdaddress
			wren      => CONNECTED_TO_wren,      --           .wren
			wrclock   => CONNECTED_TO_wrclock,   --           .wrclock
			rdclock   => CONNECTED_TO_rdclock,   --           .rdclock
			rden      => CONNECTED_TO_rden,      --           .rden
			rd_aclr   => CONNECTED_TO_rd_aclr,   --           .rd_aclr
			q         => CONNECTED_TO_q          -- ram_output.dataout
		);

