library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity ReservationStation is
	generic (n: integer := 16);
	port(
		ROBName:    out std_logic_vector(3 downto 0);
		destName:   in std_logic_vector(3 downto 0);
		opCode:		in std_logic_vector(4 downto 0);
		src1Tag:	inout std_logic_vector(15 downto 0);
		src1Valid:	inout std_logic := '0';
		src2Tag:	inout std_logic_vector(15 downto 0);
		src2Valid:	inout std_logic := '0';
		enables:	in std_logic_vector(4 downto 0);
		ready:		out std_logic := '1;
		busy:		inout std_logic := '0';
		clk:		in std_logic;
		reset:		in std_logic
	);
end entity ReservationStation;

architecture rtl of ReservationStation is
	signal srcRegTagInput1:		std_logic_vector(n-1 downto 0) := (others => '0');
	signal srcRegTagEnable1:	std_logic := '0';
	signal srcRegTagReset1:		std_logic := '0';
	signal srcRegTagOutput1:	std_logic_vector(n-1 downto 0) := (others => '0');

	signal srcRegTagInput2:		std_logic_vector(n-1 downto 0) := (others => '0');
	signal srcRegTagEnable2:	std_logic := '0';
	signal srcRegTagReset2:		std_logic := '0';
	signal srcRegTagOutput2:	std_logic_vector(n-1 downto 0) := (others => '0');

	signal srcRegValidInput1:	std_logic_vector(0 downto 0) := (others => '0');
	signal srcRegValidEnable1:	std_logic := '0';
	signal srcRegValidReset1:	std_logic := '0';
	signal srcRegValidOutput1:	std_logic_vector(0 downto 0) := (others => '0');

	signal srcRegValidInput2:	std_logic_vector(0 downto 0) := (others => '0');
	signal srcRegValidEnable2:	std_logic := '0';
	signal srcRegValidReset2:	std_logic := '0';
	signal srcRegValidOutput2:	std_logic_vector(0 downto 0) := (others => '0');

	signal busyRegInput:	std_logic_vector(0 downto 0) := (others => '0');
	signal busyRegEnable:	std_logic := '0';
	signal busyRegReset:	std_logic := '0';
	signal busyRegOutput:	std_logic_vector(0 downto 0) := (others => '0');

	begin
		srcRegTag1: entity work.mRegister
			generic map (n => n)
			port map (
				input	=> srcRegTagInput1,
				enable	=> srcRegTagEnable1,
				clk		=> clk,
				reset	=> srcRegTagReset1,
				output	=> srcRegTagOutput1
			);

		srcRegTag2: entity work.mRegister
			generic map (n => n)
			port map (
				input	=> srcRegTagInput2,
				enable	=> srcRegTagEnable2,
				clk		=> clk,
				reset	=> srcRegTagReset2,
				output	=> srcRegTagOutput2
			);

		srcRegValid1: entity work.mRegister
			generic map (n => 1)
			port map (
				input	=> srcRegValidInput1,
				enable	=> srcRegValidEnable1,
				clk		=> clk,
				reset	=> srcRegValidReset1,
				output	=> srcRegValidOutput1
			);

		srcRegValid2: entity work.mRegister
			generic map (n => 1)
			port map (
				input	=> srcRegValidInput2,
				enable	=> srcRegValidEnable2,
				clk		=> clk,
				reset	=> srcRegValidReset2,
				output	=> srcRegValidOutput2
			);
		
		busyReg: entity work.mRegister
			generic map (n => 1)
			port map (
				input	=> busyRegInput,
				enable	=> busyRegEnable,
				clk		=> clk,
				reset	=> busyRegReset,
				output	=> busyRegOutput
			);
		
		ready <= src1Valid and src2Valid;

		process(clk, reset)
		begin

		end process;

end architecture rtl;

	
