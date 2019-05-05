library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.Constants.all;

entity decodingCircuit is
    port (
        clk:                in std_logic;
        robFull:            in std_logic;
        aluRsFull:          in std_logic;
        memRsFull:          in std_logic;
        instruction:        in std_logic_vector(15 downto 0);
        lastStore:          in std_logic_vector(2 downto 0);
        lastStoreValid:     in std_logic;
        src1state:          in std_logic_vector(1 downto 0);
        src1tag:            in std_logic_vector(2 downto 0);
        rsDestName:         in std_logic_vector(2 downto 0);
        regSrc1value:       in std_logic_vector(15 downto 0);
        robSrc1value:       in std_logic_vector(15 downto 0);
        src2state:          in std_logic_vector(1 downto 0);
        src2tag:            in std_logic_vector(2 downto 0);
        regSrc2value:       in std_logic_vector(15 downto 0);
        robSrc2value:       in std_logic_vector(15 downto 0);
        rsAluValid:         out std_logic := '0';
        rsAluInstruction:   out std_logic_vector(41 downto 0);
        rsMemValid:         out std_logic := '0';
        rsMemInstruction:   out std_logic_vector(28 downto 0);
        robValid:           out std_logic := '0';
        robInstruction:     out std_logic_vector(48 downto 0) := (others => '0');
        outSrc1:            out std_logic_vector(2 downto 0);
        outSrc2:            out std_logic_vector(2 downto 0)
    );
end entity decodingCircuit;

architecture rtl of decodingCircuit is
    signal opcode:          std_logic_vector(4 downto 0) := (others => '0');
    signal opcodeType:      std_logic_vector(1 downto 0) := (others => '0');
    signal src1:            std_logic_vector(2 downto 0) := (others => '0');
    signal src2:            std_logic_vector(2 downto 0) := (others => '0');
    signal stall:           std_logic := '0';
    signal sigValueSrc1:    std_logic_vector(15 downto 0) := (others => '0');
    signal sigValidSrc1:    std_logic := '0';
    signal sigValueSrc2:    std_logic_vector(15 downto 0) := (others => '0');
    signal sigValidSrc2:    std_logic := '0';
    signal sigDestTag:      std_logic_vector(2 downto 0) := (others => '0');

    begin
        
        process(
            clk,
            robFull,
            aluRsFull,
            memRsFull,
            instruction,
            lastStore,
            lastStoreValid,
            src1state,
            src1tag,
            rsDestName,
            regSrc1value,
            robSrc1value,
            src2state,
            src2tag,
            regSrc2value,
            robSrc2value
        )
        variable valueSrc1:   std_logic_vector(15 downto 0);
        variable validSrc1:   std_logic := '0';
        variable valueSrc2:   std_logic_vector(15 downto 0);
        variable validSrc2:   std_logic := '0';
        variable destTag:     std_logic_vector(2 downto 0);

        begin
            robValid <= '0';
            rsAluValid <= '0';
            rsMemValid <= '0';

            valueSrc1 := (others => '0');
            validSrc1 := '0';
            valueSrc2 := (others => '0');
            validSrc2 := '0';
            destTag := (others => '0');

            if (stall = '0') then
                opcode <= instruction(15 downto 11);
                opcodeType <= instruction(15 downto 14);
                src1 <= instruction (10 downto 8);
                src2 <= instruction (7 downto 5);
                robInstruction(47 downto 43) <= opcode;
                robInstruction(48) <= '1';
                robInstruction(6 downto 1) <= "000000";
                destTag := src1;
                
                if (src1state = "00") then
                    valueSrc1 := regSrc1value;
                    validSrc1 := '1';
                elsif (src1state = "01") then
                    valueSrc1(15 downto 13) := src1tag;
                    valueSrc1(12 downto 0) := (others => '0');
                    validSrc1 := '0';
                elsif (src1state = "10") then
                    valueSrc1 := robSrc1value;
                    validSrc1 := '1';
                end if;

                if (src2state = "00") then
                    valueSrc2 := regSrc2value;
                    validSrc2 := '1';
                elsif (src2state = "01") then
                    valueSrc2(15 downto 13) := src2tag;
                    valueSrc2(12 downto 0) := (others => '0');
                    validSrc2 := '0';
                elsif (src2state = "10") then
                    valueSrc2 := robSrc2value;
                    validSrc2 := '1';
                end if;

                if (opcodeType = "00") then
                    if (opcode /= NOP_OPCODE and opcode /= IN_OPCODE and opcode /= OUT_OPCODE) then
                        rsAluValid <= '1';
                    end if;
                    validSrc2 := '0';
                    valueSrc2 := (others => '0');
                    robValid <= '1';    -- 00 instruction never stall
                    if (opcode = NOP_OPCODE) then
                        valueSrc1 := (others => '0');
                        validSrc1 := '0';
                        valueSrc2 := (others => '0');
                        validSrc2 := '0';
                        destTag := (others => '0');
                        robInstruction(1 downto 0) <= (others => '1'); --set done bit
                    elsif (opcode = IN_OPCODE) then --remember adding value at decode stage
                        valueSrc1 := (others => '0');
                        validSrc1 := '0';
                    end if;
                elsif (opcodeType = "01") then
                    if (opcode = SHR_OPCODE or opcode = SHL_OPCODE) then
                        stall <= '1';
                    else
                        rsAluValid <= '1';
                        robValid <= '1';    -- only SHR and SHL stall
                    end if;
                elsif (opcodeType = "10") then
                    if (opcode /= STD_OPCODE) then
                        validSrc2 := '0';
                        valueSrc2 := (others => '0');
                    end if;

                    if (opcode = LDD_OPCODE) then
                        rsMemValid <= '1';
                        if (lastStoreValid = '1') then
                            validSrc1 := '0';
                            valueSrc1(2 downto 0) := lastStore;
                            valueSrc1(15 downto 3) := (others => '0');
                        else
                            validSrc1 := '1';
                            valueSrc1 := (others => '0');
                        end if;
                    end if;

                    if (opcode /= LDM_OPCODE) then
                        robValid <= '1';    -- only LDM Stalls
                    end if;

                    if (opcode = POP_OPCODE) then
                        validSrc1 := '0';
                        valueSrc1 := (others => '0');
                    elsif (opcode = LDD_OPCODE) then
                        validSrc1 := '0';
                        valueSrc1 := (others => '0');
                    elsif (opcode = LDM_OPCODE) then
                        stall <= '1';
                    end if;
                elsif (opcodeType = "11") then
                    robValid <= '1';    -- 11 isntructions never stall
                    if (opcode = RET_OPCODE or opcode = RTI_OPCODE) then
                        valueSrc1 := (others => '0');
                        validSrc1 := '0';
                        valueSrc2 := (others => '0');
                        validSrc2 := '0';
                        destTag := (others => '0');
                        robInstruction(6 downto 1) <= (others => '0');
                    else
                        if (src1state = "00") then
                            valueSrc2 := regSrc1value;
                            validSrc2 := '1';
                        elsif (src1state = "01") then
                            valueSrc2(15 downto 13) := src1tag;
                            valueSrc2(12 downto 0) := (others => '0');
                            validSrc2 := '0';
                        elsif (src1state = "10") then
                            valueSrc2 := robSrc1value;
                            validSrc2 := '1';
                        end if;

                        -- robInstruction(42 downto 26) <= (others => '0');
                        valueSrc1 := (others => '0');
                        validSrc1 := '0';
                    end if;
                end if;
            elsif (stall = '1') then
                stall <= '0';
                rsAluValid <= '1';
                robValid <= '1';    -- stalled instructions are now valid

                -- set varaibles with values set in last cycle in display signals
                valueSrc1 := sigValueSrc1;
                validSrc1 := sigValidSrc1;
                destTag := sigDestTag;

                if (opcode = SHR_OPCODE or opcode = SHL_OPCODE) then
                    -- if (src1state = "00") then
                    --     valueSrc1 := regSrc1value;
                    --     validSrc1 := '1';
                    -- elsif (src1state = "01") then
                    --     valueSrc1(15 downto 13) := src1tag;
                    --     valueSrc1(12 downto 0) := (others => '0');
                    --     validSrc1 := '0';
                    -- elsif (src1state = "10") then
                    --     valueSrc1 := robSrc1value;
                    --     validSrc1 := '1';
                    -- end if;
                    valueSrc2 := instruction;
                    validSrc2 := '1';
                elsif (opcode = LDM_OPCODE) then
                    valueSrc2 := instruction;
                    validSrc2 := '1';
                end if;
            end if;

            robInstruction(42 downto 27) <= valueSrc1;
            robInstruction(26) <= validSrc1;
            robInstruction(25 downto 10) <= valueSrc2;
            robInstruction(0) <= validSrc2;
            robInstruction(9 downto 7) <= destTag;

            rsAluInstruction(2 downto 0) <= rsDestName;
            rsAluInstruction(3) <= validSrc2;
            rsAluInstruction(19 downto 4) <= valueSrc2;
            rsAluInstruction(20) <= validSrc1;
            rsAluInstruction(36 downto 21) <= valueSrc1;
            rsAluInstruction(41 downto 37) <= opcode;

            rsMemInstruction(2 downto 0) <= rsDestName;
            rsMemInstruction(3) <= validSrc2;
            rsMemInstruction(19 downto 4) <= valueSrc2;
            rsMemInstruction(20) <= validSrc1;
            rsMemInstruction(23 downto 21) <= valueSrc1(2 downto 0);
            rsMemInstruction(28 downto 24) <= opcode;

            sigValueSrc1 <= valueSrc1;
            sigValidSrc1 <= validSrc1;
            sigValueSrc2 <= valueSrc2;
            sigValidSrc2 <= validSrc2;
            sigDestTag   <= destTag;
        end process;
end rtl;
