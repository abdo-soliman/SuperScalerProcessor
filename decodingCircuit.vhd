library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.Constants.all;

entity decodingCircuit is
    port (
        clk:            in std_logic;
        robFull:        in std_logic;
        aluRsFull:      in std_logic;
        memRsFull:      in std_logic; 
        instruction:    in std_logic_vector(15 downto 0);
        src1state:      in std_logic_vector(1 downto 0);
        src1tag:        in std_logic_vector(3 downto 0);
        regSrc1value:   in std_logic_vector(15 downto 0);
        robSrc1value:   in std_logic_vector(15 downto 0);
        src2state:      in std_logic_vector(1 downto 0);
        src2tag:        in std_logic_vector(3 downto 0);
        regSrc2value:   in std_logic_vector(15 downto 0);
        robSrc2value:   in std_logic_vector(15 downto 0);
        rsInstruction:  out std_logic_vector(43 downto 0);
        robInstruction: out std_logic_vector(48 downto 0) := (others => '0');
        outSrc1:        out std_logic_vector(2 downto 0);
        outSrc2:        out std_logic_vector(2 downto 0)
    );
end entity decodingCircuit;

architecture rtl of decodingCircuit is
    signal opcode:              std_logic_vector(4 downto 0) := (others => '0');
    signal opcodeType:          std_logic_vector(1 downto 0) := (others => '0');
    signal src1:                std_logic_vector(2 downto 0) := (others => '0');
    signal src2:                std_logic_vector(2 downto 0) := (others => '0');
    signal stall:       std_logic := '0';

    begin
        process (clk)
        variable TempRobInstruction:  std_logic_vector(48 downto 0);
        begin
            TempRobInstruction := (others => '0');

            if (stall = '0') then
                opcode <= instruction(15 downto 11);
                opcodeType <= instruction(15 downto 14);
                src1 <= instruction (10 downto 8);
                src2 <= instruction (7 downto 5);
                robInstruction(47 downto 43) <= opcode;
                robInstruction(6 downto 0) <= "0000001";
                robInstruction(9 downto 7) <= src1;
                
                if (src1state = "00") then
                    robInstruction(42 downto 27) <= regSrc1value;
                    robInstruction(26) <= '1';
                elsif (src1state = "01") then
                    robInstruction(42 downto 40) <= src1tag;
                    robInstruction(39 downto 27) <= (others => '0');
                    robInstruction(26) <= '0';
                elsif (src1state = "10") then
                    robInstruction(42 downto 27) <= robSrc1value;
                    robInstruction(26) <= '1';
                end if;

                if (src2state = "00") then
                    robInstruction(25 downto 10) <= regSrc2value;
                    robInstruction(48) <= '1';
                elsif (src2state = "01") then
                    robInstruction(25 downto 23) <= src2tag;
                    robInstruction(22 downto 10) <= (others => '0');
                    robInstruction(48) <= '0';
                elsif (src2state = "10") then
                    robInstruction(25 downto 10) <= robSrc2value;
                    robInstruction(48) <= '1';
                end if;

                if (opcodeType = "00") then
                    robInstruction(48) <= '0';
                    robInstruction(25 downto 10) <= (others => '0');
                    if (opcode = NOP_OPCODE) then
                        robInstruction(48 downto 2) <= (others => '0');
                        robInstruction(1 downto 0) <= (others => '1');
                    elsif (opcode = IN_OPCODE) then
                        robInstruction(42 downto 27) <= (others => '0');
                        robInstruction(26) <= '0';
                    end if;
                elsif (opcodeType = "01") then
                    if (opcode = SHR_OPCODE or opcode = SHL_OPCODE) then
                        stall <= '1';
                    end if;
                elsif (opcodeType = "10") then
                    robInstruction(48) <= '0';
                    robInstruction(25 downto 10) <= (others => '0');
                    if (opcode = POP_OPCODE) then
                        robInstruction(26) <= '0';
                        robInstruction(42 downto 27) <= (others => '0');
                    elsif (opcode = LDD_OPCODE) then
                        robInstruction(26) <= '0';
                        robInstruction(42 downto 27) <= (others => '0');
                    elsif (opcode = LDM_OPCODE) then
                        stall <= '1';
                    end if;
                elsif (opcodeType = "11") then
                    if (opcode = RET_OPCODE or opcode = RTI_OPCODE) then
                        robInstruction(48 downto 1) <= (others => '0');
                    else
                        if (src1state = "00") then
                            robInstruction(25 downto 10) <= regSrc1value;
                            robInstruction(48) <= '1';
                        elsif (src1state = "01") then
                            robInstruction(25 downto 23) <= src1tag;
                            robInstruction(22 downto 10) <= (others => '0');
                            robInstruction(48) <= '0';
                        elsif (src1state = "10") then
                            robInstruction(25 downto 10) <= robSrc1value;
                            robInstruction(48) <= '1';
                        end if;

                        robInstruction(42 downto 26) <= (others => '0');
                    end if;
                end if;
            elsif (stall = '1') then
                stall <= '0';
                if (opcode = SHR_OPCODE or opcode = SHL_OPCODE) then
                    if (src1state = "00") then
                        robInstruction(42 downto 27) <= regSrc1value;
                        robInstruction(26) <= '1';
                    elsif (src1state = "01") then
                        robInstruction(42 downto 40) <= src1tag;
                        robInstruction(39 downto 27) <= (others => '0');
                        robInstruction(26) <= '0';
                    elsif (src1state = "10") then
                        robInstruction(42 downto 27) <= robSrc1value;
                        robInstruction(26) <= '1';
                    end if;
                    -- pass to rs
                elsif (opcode = LDM_OPCODE) then
                    robInstruction(25 downto 10) <= instruction;
                    robInstruction(48) <= '1';
                end if;
            end if;
        end process;
end rtl;
