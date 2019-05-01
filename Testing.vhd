library IEEE;
use IEEE.std_logic_1164.all;

entity Testing is
	generic (n: integer := 16);
	port(	clk:	in std_logic := '0';
			reset:	in std_logic := '0';
			output: out std_logic_vector(n-1 downto 0) := (others => '0')) ;
end entity Testing;

architecture rtl of Testing is
	signal q:		std_logic_vector(n-1 downto 0) := (others => '0');

	procedure inputParser(signal    entry:          inout       std_logic_vector(n-1 downto 0))is
    begin
                entry(0) <= '1';
    end inputParser;

    procedure inputParser2(signal    entry:          inout       std_logic_vector(n-1 downto 0))is
    begin
                entry(0) <= '0';
    end inputParser2;

    function checker return boolean is
    begin
        return true;
    end checker;

begin
	process(clk)
	begin
		if (clk'event and clk = '0') then
			if (checker) then

				report("Hello ma lady");
			end if;
			
		end if;
	end process;

	process(clk)
	begin
		if (clk'event and clk = '1') then
			inputParser(q);
			
			
		end if;
	end process;


end architecture rtl;
