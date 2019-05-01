library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.Constants.all;

entity aluReservationStations is
    generic (n: integer := 16);
    port (
        clk:                      in std_logic;
        issue:                    in std_logic;
        opcode:                   in std_logic_vector(4 downto 0) := "01100";
        tag1:                     in std_logic_vector(n-1 downto 0);
        tag2:                     in std_logic_vector(n-1 downto 0);
        valid1:                   in std_logic;
        valid2:                   in std_logic;
        issueDestName:            in std_logic_vector(3 downto 0);
        lastExcutedDestName:      inout std_logic_vector(3 downto 0);
        lastExcutedDestNameValue: in std_logic_vector(n-1 downto 0);
        aluOp:                    out std_logic_vector(4 downto 0);
        op1:                      out std_logic_vector(n-1 downto 0);
        op2:                      out std_logic_vector(n-1 downto 0);
        full:                     out std_logic
    );
end entity aluReservationStations;

architecture mixed of aluReservationStations is
    signal enablesTag1:     std_logic_vector(11 downto 0) := (others => '0');
    signal enablesTag2:     std_logic_vector(11 downto 0) := (others => '0');
    signal enablesValid1:   std_logic_vector(11 downto 0) := (others => '0');
    signal enablesValid2:   std_logic_vector(11 downto 0) := (others => '0');
    signal enablesOpcode:   std_logic_vector(11 downto 0) := (others => '0');
    signal enablesDestName: std_logic_vector(11 downto 0) := (others => '0');
    signal outEnables:      std_logic_vector(11 downto 0) := (others => '0');
    signal busies:          std_logic_vector(11 downto 0) := (others => '0');
    signal readies:         std_logic_vector(11 downto 0) := (others => '1');
    signal resets:          std_logic_vector(11 downto 0) := (others => '0');

    signal tempAluOp:   std_logic_vector(4 downto 0);
    signal tempValid1:  std_logic_vector(0 downto 0);
    signal tempValid2:  std_logic_vector(0 downto 0);

    signal invClk: std_logic := not clk;
    
    begin
        tempValid1(0) <= valid1;
        tempValid2(0) <= valid2;
        full <= '1' when busies = "111111111111" else '0';

        genRs:
            for i in 0 to 11 generate
            rsx: entity work.ReservationStation
            generic map (n => n)
            port map (
                clk                         => clk,
                invClk                      => invClk,
                reset                       => resets(i),
                lastExcutedDestName         => lastExcutedDestName,
                lastExcutedDestNameValue    => lastExcutedDestNameValue,
                destName                    => issueDestName,
                inOpCode                    => tempAluOp,
                src1Tag                     => tag1,
                src2Tag                     => tag2,
                src1Valid                   => tempValid1,
                src2Valid                   => tempValid2,
                inEnables(6)                => enablesDestName(i),
                inEnables(5)                => enablesOpcode(i),
                inEnables(4)                => enablesTag1(i),
                inEnables(3)                => enablesTag2(i),
                inEnables(2)                => enablesValid1(i),
                inEnables(1)                => enablesValid2(i),
                inEnables(0)                => busies(i),
                outEnable                   => outEnables(i),
                ready                       => readies(i),
                outOpcode                   => aluOp,
                src1value                   => op1,
                src2value                   => op2,
                outDestName                 => lastExcutedDestName
            );
        end generate genRs;

        process (clk, issue)
        variable found1: integer;
        variable found2: integer;
        begin
            found1 := 0;
            found2 := 0;

            invClk <= not clk;
            if (issue = '1') then
                if (opcode = MOV_OPCODE) then
                    tempAluOp <= MOV_ALU_CODE;
                elsif (opcode = SUB_OPCODE) then
                    tempAluOp <= SUB_ALU_CODE;
                elsif (opcode = DEC_OPCODE) then
                    tempAluOp <= DEC_ALU_CODE;
                elsif (opcode = INC_OPCODE) then
                    tempAluOp <= INC_ALU_CODE;
                elsif (opcode = ADD_OPCODE) then
                    tempAluOp <= ADD_ALU_CODE;
                elsif (opcode = AND_OPCODE) then
                    tempAluOp <= AND_ALU_CODE;
                elsif (opcode = OR_OPCODE) then
                    tempAluOp <= OR_ALU_CODE;
                elsif (opcode = NOT_OPCODE) then
                    tempAluOp <= NOT_ALU_CODE;
                elsif (opcode = SHL_OPCODE) then
                    tempAluOp <= SHL_ALU_CODE;
                elsif (opcode = SHR_OPCODE) then
                    tempAluOp <= SHR_ALU_CODE;
                else
                    tempAluOp <= "11111";
                end if;

                if (clk'event and clk = '0') then
                    enablesDestName <= (others => '0');
                    enablesOpcode   <= (others => '0');
                    enablesTag1     <= (others => '0');
                    enablesValid1   <= (others => '0');
                    enablesTag2     <= (others => '0');
                    enablesValid2   <= (others => '0');
                end if;
                
                if (clk'event and clk = '1' and issue = '1') then
                    for i in 0 to 11 loop
                        if (found1 = 0) then
                            if (busies(i) = '0') then
                                enablesDestName(i) <= '1';
                                enablesOpcode(i) <= '1';
                                enablesTag1(i) <= '1';
                                enablesValid1(i) <= valid1;
                                enablesTag2(i) <= '1';
                                enablesValid2(i) <= valid2;
                                busies(i) <= '1';
                                found1 := 1;
                            end if;
                        end if;
                    end loop;
                end if;
            end if;

            if (clk'event and clk = '0') then
                for i in 0 to 11 loop
                    if (found2 = 0) then
                        if (readies(i) = '1') then
                            outEnables(i) <= '1';
                            busies(i) <= '0';
                            found2 := 1;
                        else
                            outEnables(i) <= '0';
                        end if;
                    end if;
                end loop;
            end if;

            found1 := 0;
            found2 := 0;
        end process;
end architecture mixed;
