library IEEE;
use IEEE.std_logic_1164.all;

entity Counter is
	generic (n: integer := 16);
	port(	input:	in std_logic_vector(n-1 downto 0);
			enable:	in std_logic := '0';
			clk:	in std_logic := '0';
			reset:	in std_logic := '0';
			output: out std_logic_vector(n-1 downto 0) := (others => '0')) ;
end entity Counter;

architecture rtl of Counter is
begin
	process(clk,reset,enable)
	begin

		if(reset = '1') then
			output <= (others => '0');
		elsif (clk'event and clk = '1') then
			if (enable = '1') then
				output <= (output + 1);
			end if;
		end if;
	end process;


end architecture rtl;
