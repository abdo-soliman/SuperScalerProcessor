library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity InstructionRam is
	port(
		--clk :			in std_logic;
		address :		in  std_logic_vector(15 downto 0);
		dataOut :		OUT std_logic_vector(31 downto 0));
end entity InstructionRam;

architecture rtl of InstructionRam is

	TYPE ram_type is array(0 to 65535) of std_logic_vector(15 downto 0);
	SIGNAL ram : ram_type := (others => (others => '0'));
	
	begin
		--process(clk) is
		--	begin
		--		if clk'event and clk = '1' then  
		--			if writeEnable = '1' then
		--				ram(to_integer(unsigned(address))) <= dataIn;
		--			end if;
		--		end if;
		--end process;
		dataOut <= ram(to_integer(unsigned(address))) & ram(to_integer(unsigned(address+1)));
end rtl;
