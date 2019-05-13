library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

--decoding circuit reads from the RF while the ROB writes to it
--the decoding circuit writes the tag of the ROB
--for write we have three modes
--the ROB changes the tag of at max 2 registers at a time in normal case
--in case of jump (or call or any branching) we need to chane any given number of registers' tags
--also the state changes two at max and one when commiting
entity registerFile is
    generic ( n : integer := 16);
    port (
        dataIn:                 in          std_logic_vector(n-1 downto 0) := (others => '0'); 
        firstDataOut:           out         std_logic_vector(n-1 downto 0) := (others => '0');
        secondDataOut:          out         std_logic_vector(n-1 downto 0) := (others => '0');
        clk:                    in      	std_logic := '1'; 
        reset:                  in          std_logic := '0';
        firstReadRegister:      in          std_logic_vector(2 downto 0);
        secondReadRegister:     in          std_logic_vector(2 downto 0);
        writeRegister:          in          std_logic_vector(2 downto 0);
        writeEnable:            in          std_logic := '0'
    );
end entity registerFile;

architecture rtl of RegisterFile is

    type rType is array(0 to 7) of std_logic_vector(n-1 downto 0);
    signal q:       rType := (others => (others => '0'));

begin
       
    firstDataOut <= q(to_integer(unsigned(firstReadRegister)));
    secondDataOut <= q(to_integer(unsigned(secondReadRegister)));

    process (clk,reset)
    begin
        if (reset = '1') then 
            q <= (others => (others => '0'));
        elsif (clk'event and clk = '1') then

            if(writeEnable = '1') then 
                q(to_integer(unsigned(writeRegister))) <= dataIn;
            end if;

        end if;
    end process;
    
    
end architecture rtl;