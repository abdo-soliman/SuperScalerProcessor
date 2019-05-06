library IEEE;
use IEEE.std_logic_1164.all;

entity TestingKbeer is
	generic (n: integer := 16);
	port(	clk:	in std_logic := '0');
end entity TestingKbeer;

architecture rtl of TestingKbeer is
	
	signal r:		std_logic_vector(n-1 downto 0) := (others => '0');
	signal q:		std_logic_vector(n-1 downto 0) := (others => '0');
	signal temp:		std_logic_vector(n-1 downto 0) := (others => '0');
	signal mm:			integer := 0;
	signal written:	std_logic := '0';
begin

	habd: entity work.Testing
	port map (
		clk => clk,
		reset => '0',
		output => q,
		written => written
	);

	process(clk,written)
	begin
		if (written'event and written = '1') then 
			report "Slamo 3leeko";
			temp <= q;
			report integer'image(mm);
		end if;
		if (clk'event and clk = '0') then
			report "Faddal";
			r <= q;
		end if;
		if (clk'event and clk = '1') then
			report "plz don't";
			mm <= 5;
		end if;
	end process;


end architecture rtl;
