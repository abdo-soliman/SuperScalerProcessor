library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.Constants.all;


entity memUnitIntegration is 
    port(
        clk:                            in std_logic;
        issue:                          in std_logic;
        reset:                          in std_logic;
        robStoreIssue:                  in std_logic;
        robPushIssue:                   in std_logic;
        robPopIssue:                    in std_logic;
        robTag:                         in std_logic_vector(2 downto 0);
        robAddress:                     in std_logic_vector(15 downto 0);
        robValue:                       in std_logic_vector(15 downto 0);
        instruction:                    in std_logic_vector(28 downto 0);
        lastExcutedAluDestName:         in std_logic_vector(2 downto 0);
        lastExcutedAluDestNameValue:    in std_logic_vector(15 downto 0);
        lastExcutedMemDestName:         inout std_logic_vector(2 downto 0);
        lastExcutedMemDestNameValue:    in std_logic_vector(15 downto 0);
        destTag:                        inout std_logic_vector(2 downto 0);
        validAlu:                       in std_logic;
        validMem:                       inout std_logic;
        dataOut:                        out std_logic_vector(15 downto 0);
        full:                           out std_logic
    );
end entity;

architecture rtl of memUnitIntegration is
    signal mode:                std_logic_vector(1 downto 0) := (others => '0');
    signal address:             std_logic_vector(15 downto 0) := (others => '0');
    signal enableLoadOut:       std_logic := '1';
    signal tempDestTag:         std_logic_vector(2 downto 0) := "ZZZ";
    signal tempDataIn:          std_logic_vector(15 downto 0) := (others => '0');
    signal validLoadBuffers:    std_logic := '0';
    signal tempValidMem:        std_logic := '0';

    begin
        loadBuffers: entity work.memReservationStations
            generic map (n => 16)
            port map (
                clk                         => clk,
                issue                       => issue,
                reset                       => reset,
                outEnable                   => enableLoadOut,
                validAlu                    => validAlu,
                validMem                    => validMem,
                opcode                      => instruction(28 downto 24),
                waitingTag                  => instruction(23 downto 21),
                tag2                        => instruction(19 downto 4),
                waitingDone                 => instruction(20),
                valid2                      => instruction(3),
                issueDestName               => instruction(2 downto 0),
                lastExcutedAluDestName      => lastExcutedAluDestName,
                lastExcutedAluDestNameValue => lastExcutedAluDestNameValue,
                lastExcutedMemDestName      => lastExcutedMemDestName,
                lastExcutedMemDestNameValue => lastExcutedMemDestNameValue,
                address                     => address,
                full                        => full,
                valid                       => validLoadBuffers
            );

        memoryUnit: entity work.MemoryUnit
            port map (
                clk     => clk,
                enable  => '1',
                mode    => mode,
                tag     => tempDestTag,
                valid   => tempValidMem,
                address => address,
                dataIn  => tempDataIn,
                dataOut => dataOut
            );

        process (clk, robStoreIssue, robPushIssue, robPopIssue)
        begin
            if (clk'event and clk = '1') then
                enableLoadOut <= '0';
                tempDestTag <= robTag;
                address <= robAddress;
                tempDataIn <= robValue;
                if (robStoreIssue = '1') then
                    mode <= "01";
                    tempValidMem <= '1';
                elsif (robPushIssue = '1') then
                    mode <= "10";
                    tempValidMem <= '1';
                elsif (robPopIssue = '1') then
                    mode <= "11";
                    tempValidMem <= '1';
                else
                    mode <= "00";
                    enableLoadOut <= '1';
                    tempValidMem <= validLoadBuffers;
                    tempDestTag <= lastExcutedMemDestName;
                end if;
            end if;
        end process;
        validMem <= tempValidMem;
end rtl;
