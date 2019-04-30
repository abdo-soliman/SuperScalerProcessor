library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity ReservationStation is
	generic (n: integer := 16);
	port(
		ROBName:    inout std_logic_vector(3 downto 0);
		destName:   in std_logic_vector(3 downto 0);
		value:		in std_logic_vector(n-1 downto 0);
		opCode:		inout std_logic_vector(4 downto 0);
		src1Tag:	in std_logic_vector(15 downto 0);
		src1value:  out std_logic_vector(15 downto 0) := (others =>'Z');
		src1Valid:	in std_logic := '0';
		src2Tag:	in std_logic_vector(15 downto 0);
		src2value:  out std_logic_vector(15 downto 0):= (others =>'Z');
		src2Valid:	in std_logic := '0';
		inEnables:	in std_logic_vector(4 downto 0);
		ready:		out std_logic := '0';
		outEnables: in std_logic :='0';
		clk:		in std_logic;
		reset:		in std_logic
	);
end entity ReservationStation;

architecture rtl of ReservationStation is
	signal srcRegTagInput1:		std_logic_vector(n-1 downto 0) := (others => '0');
	-- signal srcRegTagEnable1:	std_logic := '0';
	signal srcRegTagReset1:		std_logic := '0';
	signal srcRegTagOutput1:	std_logic_vector(n-1 downto 0) := (others => '0');

	signal srcRegTagInput2:		std_logic_vector(n-1 downto 0) := (others => '0');
	-- signal srcRegTagEnable2:	std_logic := '0';
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

	signal opCodeRegInput:	std_logic_vector(4 downto 0) := (others => '0');
	signal opCodeRegEnable:	std_logic := '0';
	signal opCodeRegReset:	std_logic := '0';
	signal opCodeRegOutput:	std_logic_vector(4 downto 0) := (others => '0');

	begin
		process(clk)
		begin
			if ready = '0' then
			-- check if value of source 1 calculated 
			if (destName = src1Tag) then
				srcRegValidInput1 <= '1';
				srcRegValidEnable1 <= '1';
				srcRegValidReset1 <= '0';
				srcRegTagInput1 <= value ;
			-- check if value of source 2 calculated 
			else if (destName = src2Tag) then
				srcRegValidInput2 <= '1';
				srcRegValidEnable2 <= '1';
				srcRegValidReset2 <= '0';
				srcRegTagInput2 <= value ;
			-- create new one with its values 
			end if;
			if (enables(5) = '1') then
				opCodeRegEnable <= '1';
				opCodeRegReset <= '0';
				opCodeRegInput <= opCode;
			end if;
			if (enables(4) = '1') then
				srcRegTagEnable1 <= '1';
				srcRegTagReset1 <= '0';
				srcRegTagInput1 <= tag1;
			end if;
			if (enables(3) = '1') then
				srcRegTagEnable2 <= '1';
				srcRegTagReset2 <= '0';
				srcRegTagInput2 <= tag2;
			end if;
			if (enables(2) = '1') then
				srcRegValidInput1 <= src1Valid;
				srcRegValidEnable1 <= '1';
				srcRegValidReset1 <= '0';
			end if;
			if (enables(1) ='1') then
				srcRegValidInput2 <= src2Valid;
				srcRegValidEnable2 <= '1';
				srcRegValidReset2 <= '0';
			end if;
			if (enables(0) = '1') then
				busyRegInput <= '1';
				busyRegEnable <= '1';
				busyRegReset <= '0';
			elsif (enables(0) = '0') then 
				busyRegInput <= '0';
				busyRegEnable <= '1';
				busyRegReset <= '0';
			end if;
			ready = srcRegValidOutput1 and srcRegValidOutput2
			if (outEnable = '1') then   
				-- check value of ROBNAME 
				src1Value <= srcRegTagOutput1;
				src2Value <= srcRegTagOutput2;
				opCode <= opCodeRegOutput;
			end if;
		end process;
			
		srcRegTag1: entity work.mRegister
			generic map (n => n)
			port map (
				input	=> srcRegTagInput1,
				enable	=> srcRegValidOutput1,
				clk		=> clk,
				reset	=> srcRegTagReset1,
				output	=> srcRegTagOutput1
			);

		srcRegTag2: entity work.mRegister
			generic map (n => n)
			port map (
				input	=> srcRegTagInput2,
				enable	=> srcRegValidOutput2,
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

		opCodeReg: entity work.mRegister
		generic map (n => 5)
		port map (
			input	=> opCodeRegInput,
			enable	=> opCodeRegEnable,
			clk		=> clk,
			reset	=> opCodeRegReset,
			output	=> opCodeRegOutput
		);
	


end architecture rtl;

	
