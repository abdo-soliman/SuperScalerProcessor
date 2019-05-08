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
        isRet:                          in std_logic;
        robTag:                         in std_logic_vector(2 downto 0);
        robAddress:                     in std_logic_vector(15 downto 0);
        robValue:                       in std_logic_vector(15 downto 0);
        instruction:                    in std_logic_vector(28 downto 0);
        lastExcutedAluDestName:         in std_logic_vector(2 downto 0);
        lastExcutedAluDestNameValue:    in std_logic_vector(15 downto 0);
        lastExcutedMemDestName:         inout std_logic_vector(2 downto 0);
        lastExcutedMemDestNameValue:    inout std_logic_vector(15 downto 0);
        validAlu:                       in std_logic;
        validMem:                       inout std_logic := '0';
        validMemRob:                    out std_logic := '0';
        full:                           out std_logic
    );
end entity;

architecture rtl of memUnitIntegration is
    signal mode:                std_logic_vector(1 downto 0) := (others => '0');
    signal addressLoad:         std_logic_vector(15 downto 0) := (others => '0');
    signal address:             std_logic_vector(15 downto 0) := (others => '0');
    signal enableLoadOut:       std_logic := '1';
    -- signal tempDestTag:         std_logic_vector(2 downto 0) := "ZZZ";
    signal tempDataIn:          std_logic_vector(15 downto 0) := (others => '0');
    signal validLoadBuffers:    std_logic := '0';

    signal tempLastExcutedMemDestNameIn: std_logic_vector(2 downto 0) := (others => '0');
    signal tempLastExcutedMemDestNameOut: std_logic_vector(2 downto 0) := (others => '0');
    signal notYet:  std_logic := '1';
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
                -- lastExcutedMemDestName      => tempLastExcutedMemDestName,
                lastExcutedMemDestNameIn    => tempLastExcutedMemDestNameIn,
                lastExcutedMemDestNameOut   => tempLastExcutedMemDestNameOut,
                lastExcutedMemDestNameValue => lastExcutedMemDestNameValue,
                address                     => addressLoad,
                full                        => full,
                valid                       => validLoadBuffers
            );

        memoryUnit: entity work.MemoryUnit
            port map (
                clk     => clk,
                enable  => '1',
                mode    => mode,
                address => address,
                dataIn  => tempDataIn,
                dataOut => lastExcutedMemDestNameValue
            );
        
        notYet <= '0' when (notYet = '0' or validAlu = '1' or robStoreIssue = '1' or robPushIssue = '1' or robPopIssue = '1') else '1';
        tempLastExcutedMemDestNameIn <= robTag when (robStoreIssue = '1' or robPushIssue = '1' or robPopIssue = '1')
            else tempLastExcutedMemDestNameOut;
        -- tempLastExcutedMemDestName <= robTag when (robStoreIssue = '1' or robPushIssue = '1' or robPopIssue = '1');
        lastExcutedMemDestName <= (others => '0') when notYet = '1' else
            robTag when (robStoreIssue = '1' or robPushIssue = '1' or robPopIssue = '1') else
            tempLastExcutedMemDestNameOut when validLoadBuffers = '1';

        -- tempDestTag <= robTag when (robStoreIssue = '1' or robPushIssue = '1' or robPopIssue = '1') else
        --     instruction(2 downto 0) when issue = '1' else lastExcutedMemDestName;

        address <= robAddress when (robStoreIssue = '1' or robPushIssue = '1' or robPopIssue = '1') else addressLoad;

        validMem <= '1' when (robStoreIssue = '1' or robPushIssue = '1' or robPopIssue = '1') else validLoadBuffers;
        validMemRob <= '0' when (isRet = '1' and robPopIssue = '1') else
            '1' when (robPopIssue = '1') else
            '0' when (robStoreIssue = '1' or robPushIssue = '1') else validLoadBuffers;

        tempDataIn <= robValue when (robStoreIssue = '1' or robPushIssue = '1' or robPopIssue = '1') else (others => '0');
        
        mode <= "01" when (robStoreIssue = '1') else "10" when (robPushIssue = '1') else "11" when (robPopIssue = '1') else "00";
        enableLoadOut <= '0' when (robStoreIssue = '1' or robPushIssue = '1' or robPopIssue = '1') else '1';
end rtl;
