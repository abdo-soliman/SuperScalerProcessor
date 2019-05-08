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
    signal invClk:  std_logic;

    begin

        ram: entity work.DataRam
        port map (
            clk             => invClk,
            readWriteEnable => readWriteEnable,
            address         => currentAddress,
            dataIn          => dataIn,
            dataOut         => dataOut
        );

        currentAddress <= address when mode(1) = '0' else sp when mode = "11" else sp;
        invClk <= not clk;
        
        process (clk, mode, address, enable)
        begin

            if (enable = '1') then
                if (mode = "00") then   -- load
                    if (clk /= '0') then
                        readWriteEnable <= '0';
                        -- currentAddress <= address;
                    end if;
                elsif (mode = "11") then    -- pop
                    if (clk = '0') then
                        report "Hahaha";
                        readWriteEnable <= '0';
                        -- currentAddress <= sp + 1;
                        sp <= sp + 1;
                    end if;
                elsif (clk'event and clk = '0') then
                    if (mode = "01") then    -- store
                        readWriteEnable <= '1';
                        -- currentAddress <= address;
                    elsif (mode = "10") then    -- push
                        readWriteEnable <= '1';
                        -- currentAddress <= sp;
                        sp <= sp - 1;
                    end if;
                end if;
            end if;
        end process;
end rtl;
