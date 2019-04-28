library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity DataRam is
	port(
		clk:				in std_logic;
		readWriteEnable:	in std_logic;
		address:			in  std_logic_vector(6 downto 0);
		dataIn:				in std_logic_vector(15 downto 0);
		dataOut:			out std_logic_vector(15 downto 0)
	);
end entity DataRam;

architecture rtl of DataRam is
	type ram_type is array(0 to 65535) of std_logic_vector(15 downto 0);
	signal ram : ram_type := (others => (others => '0'));
	
	begin
		process(clk) is
			begin
				if clk'event and clk = '1' then  
					if readWriteEnable = '1' then
						ram(to_integer(unsigned(address))) <= dataIn;
					else
						dataOut <= ram(to_integer(unsigned(address)));
					end if;
				end if;
		end process;
end rtl;
