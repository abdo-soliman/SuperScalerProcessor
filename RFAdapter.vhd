library IEEE;
use IEEE.std_logic_1164.all;

entity RFAdapter is
	generic (n: integer := 16);
	port(	inputROB:		in 			std_logic_vector(n-1 downto 0);
			inputMEM:		in 			std_logic_vector(n-1 downto 0);
			inputPort:		in 			std_logic_vector(n-1 downto 0);
			inputPortEnable:in 			std_logic;
			isPop:			in 			std_logic;
			output: 		out std_logic_vector(n-1 downto 0) := (others => '0')) ;
end entity RFAdapter;

architecture rtl of RFAdapter is
begin
	
	output <= inputPort when inputPortEnable = '1'
		else  inputMEM  when isPop = '1'
		else  inputROB;

end architecture rtl;
