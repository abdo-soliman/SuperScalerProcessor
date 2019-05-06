library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.Constants.all;


entity arithmaticUnitIntegration is 
    port(
        clk:                            in std_logic;
        issue:                          in std_logic;
        reset:                          in std_logic;
        instruction:                    in std_logic_vector(41 downto 0);
        lastExcutedAluDestName:         inout std_logic_vector(2 downto 0);
        lastExcutedAluDestNameValue:    inout std_logic_vector(15 downto 0);
        lastExcutedMemDestName:         in std_logic_vector(2 downto 0);
        lastExcutedMemDestNameValue:    in std_logic_vector(15 downto 0);
        destTag:                        inout std_logic_vector(2 downto 0);
        validAlu:                       inout std_logic;
        validMem:                       in std_logic;
        dataOut:                        out std_logic_vector(15 downto 0);
        full:                           out std_logic
    );
end entity;

architecture rtl of arithmaticUnitIntegration is
    signal aluOp:       std_logic_vector(4 downto 0);
    signal op1:         std_logic_vector(15 downto 0);
    signal op2:         std_logic_vector(15 downto 0);
    signal zero:        std_logic;
    signal negative:    std_logic;
    signal carry:       std_logic;

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
                opcode                      => instruction( downto ),
                tag1                        => instruction( downto ),
                tag2                        => instruction( downto ),
                valid1                      => instruction( downto ),
                valid2                      => instruction( downto ),
                issueDestName               => instruction( downto ),
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
            port map (
                s:          => aluOp,
                a:          => op1,
                b:          => op2,
                cin:        => '0',
                f:          => tempLastExcutedAluDestNameValue,
                cout:       => carry,
                zero:       => zero,
                negative    => negative
            );

        flagsRegister: entity work.mRegister
			generic map (n => 3)
			port map (
				input	=> zero & negative & carry,
				enable	=> srcRegTagEnable1,
				clk		=> clk,
				reset	=> reset,
				output	=> srcRegTagOutput1
			);

        lastExcutedAluDestNameValue <= tempLastExcutedAluDestNameValue when validAlu = '1';
end rtl;
