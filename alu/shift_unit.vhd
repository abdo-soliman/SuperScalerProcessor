library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity shift_unit is
    generic (n: integer := 8);
    port (
        s:      in std_logic;
        a:      in std_logic_vector(n-1 downto 0);
        i:      in std_logic_vector(n-1 downto 0);
        f:      out std_logic_vector(n-1 downto 0);
        cout:   out std_logic
    );
end shift_unit;

architecture behavioral of shift_unit is
    begin
        process(s, a, i)
        variable offset:    integer;
        variable size:      integer;
        begin
            offset := to_integer(unsigned(i));
            size := n - 1;
            if (offset = n) then
                f <= (others => '0');
                if (s = '0') then
                    cout <= a(0);
                else
                    cout <= a(n-1);
                end if;
            elsif (offset > n) then
                f <= (others => '0');
                cout <= '0';
            else
                if (offset > 0) then
                    if (s = '0') then
                        f(offset-1 downto 0) <= (others => '0');
                        f(size downto offset) <= a(size-offset downto 0);
                        cout <= a(n - offset);
                    else
                        f(size downto n-offset) <= (others => '0');
                        f(size-offset downto 0) <= a(size downto offset);
                        cout <= a(offset-1);
                    end if;
                else
                    f <= a;
                    cout <= '0';
                end if;
            end if;
        end process;
end behavioral;