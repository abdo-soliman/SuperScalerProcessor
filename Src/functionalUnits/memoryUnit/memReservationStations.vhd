library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.Constants.all;

entity memReservationStations is
    generic (n: integer := 16);
    port (
        clk:                            in std_logic;
        issue:                          in std_logic;
        reset:                          in std_logic;
        outEnable:                      in std_logic;
        validAlu:                       in std_logic;
        validMem:                       in std_logic;
        opcode:                         in std_logic_vector(4 downto 0) := "10010";
        waitingTag:                     in std_logic_vector(2 downto 0);
        tag2:                           in std_logic_vector(n-1 downto 0);
        waitingDone:                    in std_logic;
        valid2:                         in std_logic;
        issueDestName:                  in std_logic_vector(2 downto 0);
        lastExcutedAluDestName:         in std_logic_vector(2 downto 0);
        lastExcutedAluDestNameValue:    in std_logic_vector(n-1 downto 0);
        lastExcutedMemDestNameIn:       in std_logic_vector(2 downto 0);
        lastExcutedMemDestNameOut:      out std_logic_vector(2 downto 0);
        lastExcutedMemDestNameValue:    in std_logic_vector(n-1 downto 0);
        address:                        out std_logic_vector(n-1 downto 0);
        full:                           out std_logic;
        valid:                          out std_logic
    );
end entity memReservationStations;

architecture mixed of memReservationStations is
    signal tag1:            std_logic_vector(n-1 downto 0) := (others => '0');
    signal enablesTag1:     std_logic_vector(7 downto 0) := (others => '0');
    signal enablesTag2:     std_logic_vector(7 downto 0) := (others => '0');
    signal enablesValid1:   std_logic_vector(7 downto 0) := (others => '0');
    signal enablesValid2:   std_logic_vector(7 downto 0) := (others => '0');
    signal enablesOpcode:   std_logic_vector(7 downto 0) := (others => '0');
    signal enablesDestName: std_logic_vector(7 downto 0) := (others => '0');
    signal outEnables:      std_logic_vector(7 downto 0) := (others => '0');
    signal busies:          std_logic_vector(7 downto 0) := (others => '0');
    signal busiesIn:        std_logic_vector(7 downto 0) := (others => '0');
    signal readies:         std_logic_vector(7 downto 0) := (others => '1');
    signal resets:          std_logic_vector(7 downto 0) := (others => '0');

    signal tempValid1:  std_logic_vector(0 downto 0);
    signal tempValid2:  std_logic_vector(0 downto 0);

    signal invClk: std_logic;
    signal issuedLastCycle: std_logic := '0';

    signal tempLastExcutedMemDestName: std_logic_vector(2 downto 0) := (others => '0');
    signal tempAddress: std_logic_vector(n-1 downto 0) := (others => '0');
    
    signal notYet: std_logic := '1';

    begin
        invClk <= not clk;
        tempValid1(0) <= waitingDone;
        tempValid2(0) <= valid2;
        tag1(2 downto 0) <= waitingTag;
        full <= '1' when busies = "11111111" else '0';

        genRs:
            for i in 0 to 7 generate
            rsx: entity work.ReservationStation
            generic map (n => n)
            port map (
                clk                         => clk,
                invClk                      => invClk,
                reset                       => resets(i),
                validAlu                    => validAlu,
                validMem                    => validMem,
                lastExcutedAluDestName      => lastExcutedAluDestName,
                lastExcutedAluDestNameValue => lastExcutedAluDestNameValue,
                lastExcutedMemDestName      => lastExcutedMemDestNameIn,
                lastExcutedMemDestNameValue => lastExcutedMemDestNameValue,
                destName                    => issueDestName,
                inOpCode                    => "00000",
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
                inEnables(0)                => busiesIn(i),
                outEnable                   => outEnables(i),
                ready                       => readies(i),
                src2value                   => tempAddress,
                -- outDestName                 => lastExcutedMemDestName
                outDestName                 => tempLastExcutedMemDestName
            );
        end generate genRs;

        notYet <= '0' when (notYet = '0' or outEnables /= "00000000000") else '1';
        lastExcutedMemDestNameOut <= (others => '0') when notYet = '1' else
            tempLastExcutedMemDestName when outEnables /= "00000000000";
        address <= (others => '0') when notYet = '1' else
            tempAddress when outEnables /= "00000000000";
        valid <= '1' when outEnables /= "00000000000" else '0';

        invClk <= not clk;
        process (clk, issue, reset, outEnable)
        variable found1: integer;
        variable found2: integer;
        begin
            found1 := 0;
            found2 := 0;

            resets <= (others => '0');

            if (clk'event and clk = '0' and issuedLastCycle = '1') then
                issuedLastCycle <= '0';
                enablesDestName <= (others => '0');
                enablesOpcode   <= (others => '0');
                enablesTag1     <= (others => '0');
                enablesValid1   <= (others => '0');
                enablesTag2     <= (others => '0');
                enablesValid2   <= (others => '0');
                busiesIn        <= (others => '0');
            end if;
            
            if (reset = '1') then
                resets <= (others => '1');
            elsif (issue = '1' and clk'event and clk = '1') then
                tag1(2 downto 0) <= waitingTag;
                
                for i in 0 to 7 loop
                    if (found1 = 0) then
                        if (busies(i) = '0') then
                            enablesDestName(i) <= '1';
                            enablesOpcode(i) <= '1';
                            enablesTag1(i) <= '1';
                            enablesValid1(i) <= waitingDone;
                            enablesTag2(i) <= '1';
                            enablesValid2(i) <= valid2;
                            busies(i) <= '1';
                            busiesIn(i) <= '1';
                            found1 := 1;
                        end if;
                    end if;
                end loop;
                if (found1 = 1) then
                    issuedLastCycle <= '1';
                end if;
            end if;

            if (reset /= '1' and outEnable = '1') then
                if (clk'event and clk = '0') then
                    for i in 0 to 7 loop
                        if (found2 = 0) then
                            if (readies(i) = '1') then
                                outEnables(i) <= '1';
                                -- valid <= '1';
                                busies(i) <= '0';
                                found2 := 1;
                            else
                                outEnables(i) <= '0';
                                -- valid <= '0';
                            end if;
                        end if;
                        if (readies(i) /= '1') then
                            outEnables(i) <= '0';
                        end if;
                    end loop;
                end if;
            end if;

            found1 := 0;
            found2 := 0;
        end process;
end architecture mixed;
