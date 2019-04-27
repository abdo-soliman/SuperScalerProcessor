library ieee;
use ieee.std_logic_1164.all;

entity arithmetic_unit is
    generic (n : natural := 8);
    port (
        s:      in std_logic_vector(2 downto 0);
        a:      in std_logic_vector(n-1 downto 0);
        b:      in std_logic_vector(n-1 downto 0);
        cin:    in std_logic;
        f:      out std_logic_vector(n-1 downto 0);
        cout:   out std_logic
    );
end arithmetic_unit;

architecture behavioral of arithmetic_unit is
    component adder is
        generic (n : natural);
        port (
            A : in std_logic_vector(n-1 downto 0);
            B : in std_logic_vector(n-1 downto 0);
            Cin : in std_logic;
            Sum : out std_logic_vector(n-1 downto 0);
            Cout : out std_logic
        );
    end component adder;
    signal tempCin: std_logic;
    signal tempB:   std_logic_vector(n-1 downto 0);

    begin
        adder_inst : adder
            generic map (n => n)
            port map (
                A => a,
                B => tempB,
                Cin => tempCin,
                Sum => f,
                Cout => cout
            );

        process(A, B, cin, s)
        begin
            if (s = "000") then
                tempB <= (others => '0');
                tempCin <= '0';
            elsif (s = "001") then
                tempB <= not B;
                tempCin <= '1';
            elsif (s = "010") then
                tempB <= (others => '1');
                tempCin <= '0';
            elsif (s = "011") then
                tempB <= (others => '0');
                tempCin <= '1';
            else
                tempB <= B;
                tempCin <= cin;
            end if;
        end process;
end behavioral;