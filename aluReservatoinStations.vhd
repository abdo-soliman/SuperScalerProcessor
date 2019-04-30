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
        destName:   inout std_logic_vector(3 downto 0);
        clk:        in std_logic
        op1:        out std_logic_vector(n-1 downto 0);
        op2:        out std_logic_vector(n-1 downto 0);
        aluOp:      out std_logic_vector(4 downto 0);
        full:       out std_logic
    );
end entity aluReservationStations;

architecture mixed of aluReservationStations is
    signal enablesTag1: std_logic_vector(11 downto 0) := (others => '0');
    signal enablesTag2: std_logic_vector(11 downto 0) := (others => '0');
    signal enablesValid1: std_logic_vector(11 downto 0) := (others => '0');
    signal enablesValid2: std_logic_vector(11 downto 0) := (others => '0');
    signal enablesOpcode: std_logic_vector(11 downto 0) := (others => '0');
    signal outEnables: std_logic_vector(11 downto 0) := (others => '0');
    signal busies:  std_logic_vector(11 downto 0) := (others => '0');
    signal readies: std_logic_vector(11 downto 0) := (others => '1');
    signal resets:  std_logic_vector(11 downto 0) := (others => '0');
    signal tempAluOp:   std_logic_vector(4 downto 0);
    
    begin
        genRs:
            for i in 0 to 11 generate
            rsx: entity work.ReservationStation
            generic map (n => n)
            port map (
                ROBName     => ROBName,
                destName    => destName,
                value       => value,
                opCode      => aluOp,
                src1Tag     => tag1,
                src1Valid   => valid1,
                src2Tag     => tag2,
                src2Valid   => valid2,
                inEnables   => enablesOpcode(i), enablesTag1(i) + enablesTag2(i) + enablesValid1(i) + enablesValid2(i) + busies(i),
                outEnable   => outEnables(i),
                ready       => readies(i),
                clk         => clk,
                reset       => resets(i)
            );
        end generate genRs;
        full <= '1' when busies = "111111111111" else '0';

        process (clk, mode)
        variable found: integer;
        begin
            found := 0;
            if (mode = '0') then
                if (opcode = MOV_OPCODE) then
                    aluOp <= MOV_ALU_CODE;
                elsif (opcode = SUB_OPCODE) then
                    aluOp <= SUB_ALU_CODE;
                elsif (opcode = DEC_OPCODE) then
                    aluOp <= DEC_ALU_CODE;
                elsif (opcode = INC_OPCODE) then
                    aluOp <= INC_ALU_CODE;
                elsif (opcode = ADD_OPCODE) then
                    aluOp <= ADD_ALU_CODE;
                elsif (opcode = AND_OPCODE) then
                    aluOp <= AND_ALU_CODE;
                elsif (opcode = OR_OPCODE) then
                    aluOp <= OR_ALU_CODE;
                elsif (opcode = NOT_OPCODE) then
                    aluOp <= NOT_ALU_CODE;
                elsif (opcode = SHL_OPCODE) then
                    aluOp <= SHL_ALU_CODE;
                elsif (opcode = SHR_OPCODE) then
                    aluOp <= SHR_ALU_CODE;
                end if;

                for i in 0 to 11 loop
                    if (found = 0) then
                        if (busies(i) = '0') then
                            enablesOpcode(i) <= '1';
                            enablesTag1(i) <= '1';
                            enablesValid1(i) <= valid1;
                            enablesTag2(i) <= '1';
                            enablesValid2(i) <= valid2;
                            busies(i) <= '1';
                            found = 1;
                        end if;
                    end if;
                end loop;
                found = 0;
            end if;
        end process;

        process (clk)
        variable found: integer;
        begin
            found := 0;
            for i in 0 to 11 loop
                if (found = 0) then
                    if (readies(i) = '1') then
                        outEnables(i) <= '1';
                        busies(i) <= '0';
                        found = 1;
                    end if;
                end if;
            end loop;
            found = 1;
        end process;
end architecture mixed;
