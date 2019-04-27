library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;


entity PCController is
	generic (n:	integer := 16);
	port (
		currentPC:			in std_logic_vector(n-1 downto 0) := (others => '0');
		JMPnewPC:			in std_logic_vector(n-1 downto 0) := (others => '0');
		JMPWrite:			in std_logic 					  := '0';
		queueFull:			in std_logic 					  := '0';
		newPC:				out std_logic_vector(n-1 downto 0) := (others => '0');
		memRead:			out std_logic 					  := '0'
	);
end entity PCController;


architecture rtl of PCController is
	signal incrementedPC:		std_logic_vector(n-1 downto 0) := (others => '0');
begin
	
	pcI: entity work.PCIncrementer
		generic map (n => 16)
		port map (
			input => currentPC,
			output => incrementedPC
		);

	memRead <= not queueFull;

	newPC <= JMPnewPC when JMPWrite = '1'
		else currentPC when queueFull = '1'
		else incrementedPC;

end architecture rtl;
