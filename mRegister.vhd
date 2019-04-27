library IEEE;
use IEEE.std_logic_1164.all;

entity mRegister is
	generic (n: integer := 16);
	port(	input : 			in std_logic_vector(n-1 downto 0);
			enable,clk,reset :	in std_logic := '0';
			output :			out std_logic_vector(n-1 downto 0));
end entity mRegister;

architecture rtl of mRegister is
begin
	process(clk,reset,enable)
	begin

		if(reset = '1') then
			output <= (others => '0');
		elsif (clk'event and clk = '1') then
			if (enable = '1') then
				output <= input;
			end if;
		end if;
	end process;


end architecture rtl;
