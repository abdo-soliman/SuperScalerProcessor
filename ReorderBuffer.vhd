library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

--length n and width m

entity ReorderBuffer is
    generic ( length: integer := 16;
    		 width: integer  := 16  --I changed this from 45 @Ahmed
    		 );
    port (
        instruction:	in      	std_logic_vector(width-1 downto 0) := (others => '0');
        --aluTAG:	in      std_logic_vector(3 downto 0);  --I commented this @Ahmed
        --Some other inputs

       	---------------------------------------------------------------------
        reset:			in      	std_logic := '0';
        clk:			in      	std_logic := '0';
        ROBFull:		out 		std_logic := '0';
        ROBEmpty:		out 		std_logic := '0';
        output: 		out     	std_logic_vector(width-1 downto 0) := (others => '0')
    );
end entity ReorderBuffer;

architecture rtl of ReorderBuffer is
	type qType is array(0 to length-1) of std_logic_vector(width-1 downto 0);
    signal q:	 					qType := (others => (others => '0'));
    signal readPointer: 			std_logic_vector(3 downto 0) := (others => '0');
    signal readPointerRotated:		std_logic := '0';
    signal writePointer: 			std_logic_vector(3 downto 0) := (others => '0');
    signal writePointerRotated:		std_logic := '0';
    signal ROBFullSignal: 			std_logic := '0';
    signal ROBEmptySignal: 			std_logic := '1';
    
	
	
begin
    output <= q(to_integer(unsigned(readPointer)));
    --ROBFullSignal <= '1' when tail = head
    --				else '0';
    ROBFull <= ROBFullSignal;

    process(clk,reset)
    begin
    	if(reset = '1') then
    		q <= (others => (others => '0'));
    		readPointer <= (others => '0');
    		ReadPointerRotated <= '0';
    		writePointer <= (others => '0');
    		writePointerRotated <= '0';
    		ROBFullSignal <= '0';
    		ROBEmptySignal <= '1';

       	elsif (clk'event and clk = '1') then
       		--read from decoding circuit
       		if (ROBFullSignal = '0') then
       			q(to_integer(unsigned(writePointer))) <= instruction;
       			writePointer <= writePointer + 1;

       			if (writePointer = length-1) then
       				writePointerRotated <= not writePointerRotated;
       			end if;

       			if (writePointer + 1 = readPointer) then
       				ROBFullSignal <= '1';
       			else
       				ROBFullSignal <= '0';
       			end if;

       		end if;

       --elsif (clk'event and clk = '1') then
       		--some thing to be done

      	end if;
    end process;
    
    
end architecture rtl;


