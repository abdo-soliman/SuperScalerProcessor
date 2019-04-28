library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity aluReservationStations is
    generic (n: integer := 16);
    port (
        mode:       in std_logic;
        opcode:     in std_logic_vector(4 downto 0);
        tag1:       in std_logic_vector(n-1 downto 0);
        tag2:       in std_logic_vector(n-1 downto 0);
        valid1:     in std_logic;
        valid2:     in std_logic;
        value:      in std_logic_vector(n-1 downto 0);
        ROBName:   in std_logic_vector(3 downto 0);
        clk:        in std_logic
    );
end entity aluReservationStations;

architecture mixed of aluReservationStations is
    signal enables: std_logic_vector(11 downto 0);
    signal busies:  std_logic_vector(11 downto 0);
    signal readies: std_logic_vector(11 downto 0);
    signal resets:  std_logic_vector(11 downto 0);
    signal aluOp:   std_logic_vector(4 downto 0);
    
    begin
        genRs:
            for i in 0 to 12 generate
            rsx: entity work.ReservationStation
            generic map (n => n)
            port map (
                opCode      => aluOp,
                ROBName    => ROBName,
                value       => value,
                src1Tag     => tag1,
                src1value   => ay_hari,
                src1Valid   => valid1,
                src2Tag     => tag2,
                src2Valid   => valid2,
                enables     => 
                ready       => readies(i),
                busy        => busies(i),
                clk         => clk,
                reset       => resets(i)
            );
        end generate genRs;
        process (clk, mode)
        begin
            if (mode = '0') then

            else
                
            end if;
        end process;
end architecture mixed;
