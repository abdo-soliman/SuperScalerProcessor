library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

--length n and width m

entity InstructionQueue is
    generic ( length: integer := 16;
    		 width: integer  := 45
    		 );
    port (
        instruction:  in      	std_logic_vector(width-1 downto 0) := (others => '0');
        aluTAG:	in      std_logic_vector(3 downto 0);
        --Some other inputs

       	---------------------------------------------------------------------
        reset:  in      	std_logic := '0';
        clk:    in      	std_logic := '0';
        ROBFull:	out 	std_logic := '0';
        output: out     	std_logic_vector(widthByTwo-1 downto 0) := (others => '0')
    );
end entity InstructionQueue;

architecture rtl of InstructionQueue is
	type qType is array(0 to length-1) of std_logic_vector(width-1 downto 0);
    signal q 	: qType := (others => (others => '0'));
    signal head	: std_logic_vector(3 downto 0) := (others => '0');
    signal tail	: std_logic_vector(3 downto 0) := (others => '0');
    signal ROBFullSignal: std_logic :='0';
    
	
	
begin
    output <= q(0);
    ROBFullSignal <= '1' when tail = head
    				else '0';
    ROBFull <= ROBFullSignal;
    process(clk)
    begin
       if (clk'event and clk = '0') then
       		--read from decoding circuit
       		if (ROBFullSignal = '0') then



       			q(tail) <= (others => '0')--some ciruit
       		end if;

       elsif (clk'event and clk = '1') then
       		--some thing to be done

       end if;
    end process;
    
    
end architecture rtl;


