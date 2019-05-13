LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY Decoder IS
	PORT (
        en: in  std_logic;
        selection: in std_logic_vector(2 downto 0);
        output: out std_logic_vector(7 downto 0)
        );
END ENTITY Decoder;


Architecture Behavioral of Decoder is
begin
output(0) <= en and not(selection(1)) and not(selection(0)) and not (selection(2));
output(1) <= en and not(selection(1)) and selection(0) and not (selection(2));
output(2) <= en and selection(1) and not(selection(0)) and not (selection(2));
output(3) <= en and selection(1) and selection(0) and not (selection(2));

output(4) <= en and not(selection(1)) and not(selection(0)) and selection(2);
output(5) <= en and not(selection(1)) and selection(0) and selection(2);
output(6) <= en and  selection(1) and not(selection(0)) and selection(2);
output(7) <= en and  selection(1) and selection(0) and selection(2);


end Architecture;

