library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

--length n and width m

entity InstructionQueue is
    generic ( 	length: integer := 8;
    		 	width: integer  := 32;
    		 	widthByTwo: integer := 16);
    port (
        input:  		in      	std_logic_vector(width-1 downto 0) := (others => '0');
        enable: 		in      	std_logic := '1'; --if ROB full don't enable
        reset:  		in      	std_logic := '0';
        clk:    		in      	std_logic := '0';
        queueFull:		out 		std_logic := '0';
        numberOfElementes:  out     std_logic_vector(3 downto 0) := (others => '0');
        output: 		out     	std_logic_vector(widthByTwo-1 downto 0) := (others => '0')
    );
end entity InstructionQueue;

architecture rtl of InstructionQueue is
	type qType is array(0 to length-1) of std_logic_vector(widthByTwo-1 downto 0);
    signal q 	: qType := (others => (others => '0'));
    signal tail	: std_logic_vector(3 downto 0) := (others => '0');
    signal queueFullSignal: std_logic :='0';
    
	
	
begin
    output <= q(0);
    --queueFullSignal <= '1' when (tail = "1000" or tail = "0111")
    				--else '0';
    queueFull <= '0' when ((queueFullSignal = '0') or ((enable = '1') and (tail = "0111")))
    		else '1';

    numberOfElementes <= tail;
    process(clk,reset)
    begin
        if (reset = '1') then
        	q <= (others => (others => '0'));
        	tail <= (others=> '0');
        elsif (clk'event and clk = '1') then --shift and output to ROB, ROB reads in negative edge
        	if(enable = '1') then
        		q(length-1) <= (others => '0');
	        	--Shifting
	        	for i in length-2 downto 0 loop
	        		q(i) <= q(i + 1);
	        	end loop;

	        	if (tail /= "0000") then
	        		tail <= tail - 1;
	        		if (tail = "0111") then
	        			queueFullSignal <= '0';
	        		end if;
	        	end if;
       		end if;	
    	elsif (clk'event and clk = '0') then 
        	if(queueFullSignal = '0') then 
	        	q(to_integer(unsigned(tail))) <= input(31 downto 16);
	        	q(to_integer(unsigned(tail+1))) <= input(15 downto 0);
	        	tail <= tail + 2;
	        	if (tail = "0110" or tail = "0101") then
	        		queueFullSignal <= '1';
	        	else
	        		queueFullSignal <= '0';
	        	end if;
    		end if;	
        end if;
    end process;
    
    
end architecture rtl;


