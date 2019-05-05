library IEEE;
use IEEE.std_logic_1164.all;

entity TestingKbeer is
	generic (n: integer := 16);
	port(	clk:	in std_logic := '0');
end entity TestingKbeer;

architecture rtl of TestingKbeer is
	
	signal r:		std_logic_vector(n-1 downto 0) := (others => '0');
	signal q:		std_logic_vector(n-1 downto 0) := (others => '0');
begin

	habd: entity work.Testing
	port map (
		clk => clk,
		reset => '0',
		output => q
	);

	process(clk)
	begin
		if (clk'event and clk = '1') then
			r <= q;
		end if;
	end process;


end architecture rtl;
