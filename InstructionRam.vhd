library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity InstructionRam is
	port(
		readEnable:     in std_logic := '0';
		clk:			in std_logic;
		reset:			in std_logic := '0';
		address :		in  std_logic_vector(15 downto 0) := (others => '0');
		dataOut :		OUT std_logic_vector(31 downto 0) := (others => '0'));

end entity InstructionRam;

architecture rtl of InstructionRam is

	TYPE ram_type is array(0 to 65535) of std_logic_vector(15 downto 0);
	SIGNAL ram : ram_type := (others => (others => '0'));
	signal sgn : unsigned(15 downto 0);
	begin
		sgn <= unsigned(address);
		process(clk,address,reset) is
			begin
				if(reset = '1') then
					dataOut <= ram(0) & ram(0);
				elsif clk'event and clk = '1' then  
					if readEnable = '1' then
						dataOut <= ram(to_integer(sgn)) & ram(to_integer(sgn+1));
					end if;
				end if;
		end process;
		
end rtl;
