library ieee;
use ieee.std_logic_1164.all;

entity logic_unit is
    generic (n : natural := 16);
    port (
        s:  in std_logic_vector(1 downto 0);
        a:  in std_logic_vector(n-1 downto 0);
        b:  in std_logic_vector(n-1 downto 0);
        f:  out std_logic_vector(n-1 downto 0)
    );
end logic_unit;

architecture dataflow of logic_unit is
    begin
        f <= a and b when s = "00" else
            a or b when s = "01" else
            not a;
end dataflow;