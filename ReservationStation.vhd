library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity ReservationStation is 
	port(
		tagName  :    		inout std_logic_vector(3 downto 0);
		opCode   :		in std_logic_vector(4 downto 0);
		src1Tag  :		inout std_logic_vector(15 downto 0);
		src1Valid:		inout std_logic := '0';
		src2Tag  :		inout std_logic_vector(15 downto 0);
		src2Valid:		inout std_logic := '0';
		ready    :		out std_logic := '0';
		busy:			inout std_logic := '0'
	);
end entity ReservationStation;

architecture rtl of ReservationStation is 
	begin 

		ready <= src1Valid and src2Valid;

end architecture rtl;

	
