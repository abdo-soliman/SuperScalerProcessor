library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

--decoding circuit reads from the RF while the ROB writes to it
--the decoding circuit writes the tag of the ROB
--for write we have three modes
--the ROB changes the tag of at max 2 registers at a time in normal case
--in case of jump (or call or any branching) we need to chane any given number of registers' tags
--also the state changes two at max and one when commiting
entity registerFile is
    generic ( m : integer := 16);
    port (
        regValueIn:    in             std_logic_vector(m downto 0) := (others => '0'); --coming from ROB(commit stage)
        destRegNumber: in           std_logic_vector(2 downto 0) := (others => '0');
        enableWrite:   in      	    std_logic := '1'; --enable write maybe
        enableRead:    in           std_logic := '0';
        reset:         in      	    std_logic := '0'; --set all regs to zeros
        clk:           in      	    std_logic := '0';
        state:         out     	    std_logic_vector(1 downto 0) := (others => '0');--state of the requested register by the decoding circuit
        regVlaueOut:   out            std_logic_vector(m downto 0) := (others => '0');--value of the reqested register by the decoding circuit
        tagValueOut:   out            std_logic_vector(3 downto 0) := (others => '0');--tag if the state is in flight or ready
        srcRegNumber:  in           std_logic_vector(2 downto 0) := (others => '0')
    );
end entity registerFile;

architecture rtl of RegisterFile is
    signal regWriteEnable: std_logic_vector(7 downto 0);
    signal reg0          : std_logic_vector(m downto 0);
    signal reg1          : std_logic_vector(m downto 0);
    signal reg2          : std_logic_vector(m downto 0);
    signal reg3          : std_logic_vector(m downto 0);
    signal reg4          : std_logic_vector(m downto 0);
    signal reg5          : std_logic_vector(m downto 0);
    signal reg6          : std_logic_vector(m downto 0);
    signal reg7          : std_logic_vector(m downto 0);
begin
    decoder: entity work.Decoder
    port map(
        en => enableWrite,
        selection => destRegNumber,
        output => regWriteEnable
    );

    R0: entity work.mRegister
    port map(
        input => regValueIn,
        output => reg0,
        enable => regWriteEnable(0),
        clk => clk,
        reset => reset
    );

    R1: entity work.mRegister
    port map(
        input => regValueIn,
        output => reg1,
        enable => regWriteEnable(1),
        clk => clk,
        reset => reset
    );

    R2: entity work.mRegister
    port map(
        input => regValueIn,
        output => reg2,
        enable => regWriteEnable(2),
        clk => clk,
        reset => reset
    );

    R3: entity work.mRegister
    port map(
        input => regValueIn,
        output => reg3,
        enable => regWriteEnable(3),
        clk => clk,
        reset => reset
    );

    R4: entity work.mRegister
    port map(
        input => regValueIn,
        output => reg0,
        enable => regWriteEnable(4),
        clk => clk,
        reset => reset
    );

    R5: entity work.mRegister
    port map(
        input => regValueIn,
        output => reg0,
        enable => regWriteEnable(5),
        clk => clk,
        reset => reset
    );

    R6: entity work.mRegister
    port map(
        input => regValueIn,
        output => reg6,
        enable => regWriteEnable(6),
        clk => clk,
        reset => reset
    );

    R7: entity work.mRegister
    port map(
        input => regValueIn,
        output => reg7,
        enable => regWriteEnable(7),
        clk => clk,
        reset => reset
    );



    -- for i in 0 to 8 generate
    --     reg: entity work.mRegister port map(
    --         input => regValueIn,
    --         output => 
    --         );
    
    
end architecture rtl;