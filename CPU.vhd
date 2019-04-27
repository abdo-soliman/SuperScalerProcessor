library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity CPU is
	port (
		clk: in 				std_logic 		:= '0';
		reset: in 				std_logic 		:= '0'
	);
end entity CPU;



architecture rtl of CPU is
	signal pcControllerOut:		std_logic_vector(15 downto 0);
	signal pcEnable:		std_logic := '1';
	signal pcOut:			std_logic_vector(15 downto 0);
	signal ROBnewPC:		std_logic_vector(15 downto 0) := std_logic_vector(50);
	signal ROBwritePC:		std_logic := '0';
	signal queueFull:		std_logic := '0';
	signal memRead:			std_logic := '0';


	--For testing
	signal ramOut:			std_logic_vector(31 downto 0);

begin
	
	pc:	work.mRegister
	generic map(n => 16)
	port map (
		input => pcControllerOut,
		enable => pcEnable,
		clk => clk,
		reset => reset, --reset pc
		output => pcOut
	);

	IR:	work.mRegister
	generic map(n => 16)
	port map (
		input => pcControllerOut,
		enable => pcEnable,
		clk => clk,
		reset => reset, --reset pc
		output => pcOut
	);

	pcCont:	work.PCController
	generic map (
		currentPC => pcOut,
		JMPnewPC => ROBnewPC,
		JMPWrite => ROBwritePC,
		queueFull => queueFull,
		newPC	 => pcControllerOut,
		memRead => memRead
	)

	insRam:	work.
end architecture rtl;