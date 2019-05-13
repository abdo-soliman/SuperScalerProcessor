library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


entity PCIncrementer is
	generic (n:	integer := 16);
	port (
		input:		in std_logic_vector(n-1 downto 0) := (others => '0');
		output:		out std_logic_vector(n-1 downto 0) := (others => '0')
	);
end entity PCIncrementer;


architecture rtl of PCIncrementer is
	--signal q: 	std_logic_vector(n-1 downto 0) := (others => '0');
begin
	output <= input + 2;
end architecture rtl;