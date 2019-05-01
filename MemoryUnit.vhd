library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.Constants.all;


entity MemoryUnit is 
    port(
        clk:            in std_logic;
        enable:         in std_logic;
        mode:           in std_logic_vector(1 downto 0);
        address:        in std_logic_vector(15 downto 0);
        dataIn:         in std_logic_vector(15 downto 0);
        dataOut:        out std_logic_vector(15 downto 0)
    );
end entity;

architecture rtl of MemoryUnit is
    signal readWriteEnable: std_logic := '0';
    signal currentAddress:  std_logic_vector(15 downto 0) := (others => '0');
    signal sp:              std_logic_vector(15 downto 0) := SP_START;
    signal invClk:  std_logic := not clk;

    begin
        ram: entity work.DataRam
        port map (
            clk             => invClk,
            readWriteEnable => readWriteEnable,
            address         => currentAddress,
            dataIn          => dataIn,
            dataOut         => dataOut
        );

        process (clk, mode, enable)
        begin
            invClk <= not clk;
            if (clk'event and clk = '0' and enable = '1') then
                if (mode = "00") then   -- load
                    readWriteEnable <= '0';
                    currentAddress <= address;
                elsif (mode = "01") then    -- store
                    readWriteEnable <= '1';
                    currentAddress <= address;
                elsif (mode = "10") then    -- push
                    readWriteEnable <= '1';
                    currentAddress <= sp;
                    sp <= sp - 1;
                elsif (mode = "11") then    -- pop
                    readWriteEnable <= '0';
                    currentAddress <= sp + 1;
                    sp <= sp + 1;
                end if;
            end if;
        end process;
end rtl;