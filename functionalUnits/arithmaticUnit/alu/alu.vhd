library ieee;
use ieee.std_logic_1164.all;

entity alu is
    generic (n : natural := 8);
    port (
        s:          in std_logic_vector(4 downto 0);
        a:          in std_logic_vector(n-1 downto 0);
        b:          in std_logic_vector(n-1 downto 0);
        cin:        in std_logic;
        f:          out std_logic_vector(n-1 downto 0);
        cout:       out std_logic;
        zero:       out std_logic;
        negative:   out std_logic;
        carry:      out std_logic
    );
end alu;

architecture structural of alu is
    component arithmetic_unit is
        generic (n : natural);
        port (
            s:      in std_logic_vector(2 downto 0);
            a:      in std_logic_vector(n-1 downto 0);
            b:      in std_logic_vector(n-1 downto 0);
            cin:    in std_logic;
            f:      out std_logic_vector(n-1 downto 0);
            cout:   out std_logic
        );
    end component arithmetic_unit;

    component logic_unit is
        generic (n : natural);
        port (
            s: in std_logic_vector(1 downto 0);
            a: in std_logic_vector(n-1 downto 0);
            b: in std_logic_vector(n-1 downto 0);
            f: out std_logic_vector(n-1 downto 0)
        );
    end component logic_unit;

    component shift_unit is
        generic (n : natural);
        port (
            s:      in std_logic;
            a:      in std_logic_vector(n-1 downto 0);
            i:      in std_logic_vector(n-1 downto 0);
            f:      out std_logic_vector(n-1 downto 0);
            cout:   out std_logic
        );
    end component shift_unit;
    
    signal auF, luF, suF, tempF : std_logic_vector(n-1 downto 0);
    signal auCout, suCout, tempCout : std_logic;

    begin
        au_inst : arithmetic_unit
        generic map (n => n)
        port map (
            s       => s(2 downto 0),
            a       => a,
            b       => b,
            cin     => cin,
            f       => auF,
            cout    => auCout
        );

        lu_inst : logic_unit
        generic map (n => n)
        port map (
            s => s(1 downto 0),
            a => a,
            b => b,
            f => luF
        );

        su_inst : shift_unit
        generic map (n => n)
        port map (
            s       => s(0),
            a       => a,
            i       => b,
            f       => suF,
            cout    => suCout
        );

        tempF <= auF when s(4 downto 3) = "00" else
            luF when s(4 downto 3) = "01" else
            suF;
        f <= tempF;

        tempCout <= '1' when s = "00101" else
            '0' when s = "00110" else
            auCout when s(4 downto 3) = "00" else
            '0' when s(4 downto 3) = "01" else
            suCout;

        carry <= tempCout;
        cout <= tempCout;

        zero <= '1' when (tempF = (n-1 downto 0 => '0')) else '0';
        negative <= tempF(n-1);
end structural;