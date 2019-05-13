library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.Constants.all;


entity arithmaticUnitIntegration is 
    port(
        clk:                            in std_logic;
        issue:                          in std_logic;
        reset:                          in std_logic;
        setFlags:                       in std_logic;
        robFlags:                       in std_logic_vector(2 downto 0);
        instruction:                    in std_logic_vector(41 downto 0);
        lastExcutedAluDestName:         inout std_logic_vector(2 downto 0) := (others => '0');
        lastExcutedAluDestNameValue:    inout std_logic_vector(15 downto 0) := (others => '0');
        lastExcutedMemDestName:         in std_logic_vector(2 downto 0);
        lastExcutedMemDestNameValue:    in std_logic_vector(15 downto 0);
        validAlu:                       inout std_logic := '0';
        validMem:                       in std_logic;
        flags:                          out std_logic_vector(2 downto 0);
        full:                           out std_logic
    );
end entity;

architecture rtl of arithmaticUnitIntegration is
    signal aluOp:           std_logic_vector(4 downto 0);
    signal op1:             std_logic_vector(15 downto 0);
    signal op2:             std_logic_vector(15 downto 0);
    signal flagsEnable:     std_logic;
    signal inFlags:         std_logic_vector(2 downto 0);
    signal outFlags:        std_logic_vector(2 downto 0);
    signal currentFlags:    std_logic_vector(2 downto 0);

    signal tempLastExcutedAluDestNameValue: std_logic_vector(15 downto 0);
    begin
        reservationStations: entity work.aluReservationStations
            generic map (n => 16)
            port map (
                clk                         => clk,
                issue                       => issue,
                reset                       => reset,
                validAlu                    => validAlu,
                validMem                    => validMem,
                opcode                      => instruction(41 downto 37),
                tag1                        => instruction(36 downto 21),
                tag2                        => instruction(19 downto 4),
                valid1                      => instruction(20),
                valid2                      => instruction(3),
                issueDestName               => instruction(2 downto 0),
                lastExcutedAluDestName      => lastExcutedAluDestName,
                lastExcutedAluDestNameValue => lastExcutedAluDestNameValue,
                lastExcutedMemDestName      => lastExcutedMemDestName,
                lastExcutedMemDestNameValue => lastExcutedMemDestNameValue,
                aluOp                       => aluOp,
                op1                         => op1,
                op2                         => op2,
                full                        => full,
                valid                       => validAlu
            );

        alu: entity work.alu
            generic map (n => 16)
            port map (
                s           => aluOp,
                a           => op1,
                b           => op2,
                cin         => '0',
                f           => tempLastExcutedAluDestNameValue,
                cout        => currentFlags(2),
                negative    => currentFlags(1),
                zero        => currentFlags(0)
            );

        flagsRegister: entity work.mRegister
			generic map (n => 3)
			port map (
				input	=> inFlags,
				enable	=> flagsEnable,
				clk		=> clk,
				reset	=> reset,
				output	=> outFlags
			);

        flagsEnable <= '1' when validAlu = '1' or setFlags = '1' else  '0';
        inFlags <= robFlags when setFlags = '1' else
            outFlags when aluOp = MOV_ALU_CODE else
            outFlags(2) & currentFlags(1 downto 0) when (validAlu = '1' and  (aluOp = NOT_ALU_CODE or aluOp = AND_ALU_CODE or aluOp = OR_ALU_CODE)) else
            currentFlags when (validAlu = '1' and (not (aluOp = NOT_ALU_CODE or aluOp = AND_ALU_CODE or aluOp = OR_ALU_CODE))) else "000";
        flags(2) <= outFlags(2) when (validAlu = '0' or aluOp = NOT_ALU_CODE or aluOp = AND_ALU_CODE or aluOp = OR_ALU_CODE or aluOp = MOV_ALU_CODE) else currentFlags(2);
        flags(1 downto 0) <= currentFlags(1 downto 0) when (validAlu = '1' and aluOp /= MOV_ALU_CODE) else outFlags(1 downto 0);
        lastExcutedAluDestNameValue <= tempLastExcutedAluDestNameValue when validAlu = '1';

        process (clk, setFlags, validAlu, aluOp)
        begin
            if(clk'event and clk = '1' and setFlags = '1') then
            inFlags <= robFlags;
            elsif (aluOp = MOV_ALU_CODE) then
             inFlags <= outFlags;
            elsif ((validAlu = '1' and  (aluOp = NOT_ALU_CODE or aluOp = AND_ALU_CODE or aluOp = OR_ALU_CODE)) ) then
             inFlags <= outFlags(2) & currentFlags(1 downto 0);
            elsif ((validAlu = '1' and (not (aluOp = NOT_ALU_CODE or aluOp = AND_ALU_CODE or aluOp = OR_ALU_CODE))) ) then
             inFlags <= currentFlags; 
            else 
            inFlags <="000";

            end if;
        end process;
end rtl;
