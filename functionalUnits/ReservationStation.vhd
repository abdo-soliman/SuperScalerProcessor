library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity ReservationStation is
	generic (n: integer := 16);
	port(
		clk:							in std_logic;
		invClk:							in std_logic;
		reset:							in std_logic;
		validAlu:						in std_logic;
		validMem:						in std_logic;
		lastExcutedAluDestName:			in std_logic_vector(2 downto 0);
		lastExcutedAluDestNameValue:	in std_logic_vector(n-1 downto 0);
		lastExcutedMemDestName:			in std_logic_vector(2 downto 0);
		lastExcutedMemDestNameValue:	in std_logic_vector(n-1 downto 0);
		destName:						in std_logic_vector(2 downto 0);
		inOpCode:						in std_logic_vector(4 downto 0);
		src1Tag:						in std_logic_vector(15 downto 0);
		src2Tag:						in std_logic_vector(15 downto 0);
		src1Valid:						in std_logic_vector(0 downto 0);
		src2Valid:						in std_logic_vector(0 downto 0);
		inEnables:						in std_logic_vector(6 downto 0);
		outEnable:						in std_logic := '0';
		ready:							out std_logic := '0';
		outOpcode:						out std_logic_vector(4 downto 0) := (others => 'Z');
		src1value:						out std_logic_vector(15 downto 0) := (others => 'Z');
		src2value:						out std_logic_vector(15 downto 0):= (others => 'Z');
		outDestName:					out std_logic_vector(2 downto 0) := (others => 'Z')
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

	signal opCodeRegInput:	std_logic_vector(4 downto 0) := (others => '0');
	signal opCodeRegEnable:	std_logic := '0';
	signal opCodeRegReset:	std_logic := '0';
	signal opCodeRegOutput:	std_logic_vector(4 downto 0) := (others => '0');

	signal destNameRegInput:	std_logic_vector(2 downto 0) := (others => '0');
	signal destNameRegEnable:	std_logic := '0';
	signal destNameRegReset:	std_logic := '0';
	signal destNameRegOutput:	std_logic_vector(2 downto 0) := (others => '0');

	begin
		process(clk, validAlu, validMem, outEnable)
		variable changedSrc1FromBus: std_logic;
		variable changedSrc2FromBus: std_logic;
		begin
			changedSrc1FromBus := '0';
			changedSrc2FromBus := '0';

			if reset = '1' then
				srcRegTagReset1 <= '1';
				srcRegTagReset2 <= '1';
				srcRegValidReset1 <= '1';
				srcRegValidReset2 <= '1';
				busyRegReset <= '1';
				opCodeRegReset <= '1';
				destNameRegReset <= '1';
			else
				srcRegTagReset1 <= '0';
				srcRegTagReset2 <= '0';
				srcRegValidReset1 <= '0';
				srcRegValidReset2 <= '0';
				busyRegReset <= '0';
				opCodeRegReset <= '0';
				destNameRegReset <= '0';

				if (inEnables(0) = '1') then
					if (validAlu = '1' and src1Valid = "0" and lastExcutedAluDestName = src1Tag(2 downto 0)) then
						report "enables(0) and src1";
						srcRegValidInput1 <= "1";
						srcRegValidEnable1 <= '1';
						srcRegValidReset1 <= '0';
						srcRegTagEnable1 <= '1';
						srcRegTagInput1 <= lastExcutedAluDestNameValue;
						changedSrc1FromBus := '1';
					end if;
					if (validAlu = '1' and src2Valid = "0" and lastExcutedAluDestName = src2Tag(2 downto 0)) then
						report "enables(0) and src2";
						srcRegValidInput2 <= "1";
						srcRegValidEnable2 <= '1';
						srcRegValidReset2 <= '0';
						srcRegTagEnable2 <= '1';
						srcRegTagInput2 <= lastExcutedAluDestNameValue;
						changedSrc2FromBus := '1';
					end if;
					if (validMem = '1' and src1Valid = "0" and lastExcutedMemDestName = src1Tag(2 downto 0)) then
						srcRegValidInput1 <= "1";
						srcRegValidEnable1 <= '1';
						srcRegValidReset1 <= '0';
						srcRegTagEnable1 <= '1';
						srcRegTagInput1 <= lastExcutedMemDestNameValue;
						changedSrc1FromBus := '1';
					end if;
					if (validMem = '1' and src2Valid = "0" and lastExcutedMemDestName = src2Tag(2 downto 0)) then
						srcRegValidInput2 <= "1";
						srcRegValidEnable2 <= '1';
						srcRegValidReset2 <= '0';
						srcRegTagEnable2 <= '1';
						srcRegTagInput2 <= lastExcutedMemDestNameValue;
						changedSrc2FromBus := '1';
					end if;
				end if;
				
				if (busyRegOutput = "1") then
					if (validAlu = '1' and srcRegValidOutput1 = "0" and lastExcutedAluDestName = srcRegTagOutput1(2 downto 0)) then
						report "busyRegOutput and src1";
						srcRegValidInput1 <= "1";
						srcRegValidEnable1 <= '1';
						srcRegValidReset1 <= '0';
						srcRegTagEnable1 <= '1';
						srcRegTagInput1 <= lastExcutedAluDestNameValue;
						changedSrc1FromBus := '1';
					end if;
					if (validAlu = '1'  and srcRegValidOutput2 = "0" and lastExcutedAluDestName = srcRegTagOutput2(2 downto 0)) then
						report "busyRegOutput and src2";
						srcRegValidInput2 <= "1";
						srcRegValidEnable2 <= '1';
						srcRegValidReset2 <= '0';
						srcRegTagEnable2 <= '1';
						srcRegTagInput2 <= lastExcutedAluDestNameValue;
						changedSrc2FromBus := '1';
					end if;
					if (validMem = '1' and srcRegValidOutput1 = "0" and lastExcutedMemDestName = srcRegTagOutput1(2 downto 0)) then
						srcRegValidInput1 <= "1";
						srcRegValidEnable1 <= '1';
						srcRegValidReset1 <= '0';
						srcRegTagEnable1 <= '1';
						srcRegTagInput1 <= lastExcutedMemDestNameValue;
						changedSrc1FromBus := '1';
					end if;
					if (validMem = '1'  and srcRegValidOutput2 = "0" and lastExcutedMemDestName = srcRegTagOutput2(2 downto 0)) then
						srcRegValidInput2 <= "1";
						srcRegValidEnable2 <= '1';
						srcRegValidReset2 <= '0';
						srcRegTagEnable2 <= '1';
						srcRegTagInput2 <= lastExcutedMemDestNameValue;
						changedSrc2FromBus := '1';
					end if;
				end if;

				if (inEnables(6) = '1') then
					destNameRegEnable <= '1';
					destNameRegReset <= '0';
					destNameRegInput <= destName;
				end if;

				if (inEnables(5) = '1') then
					opCodeRegEnable <= '1';
					opCodeRegReset <= '0';
					opCodeRegInput <= inOpCode;
				end if;

				if (changedSrc1FromBus = '0') then
					if (inEnables(4) = '1') then
						srcRegTagEnable1 <= '1';
						srcRegTagReset1 <= '0';
						srcRegTagInput1 <= src1Tag;
					end if;
					if (inEnables(2) = '1') then
						srcRegValidEnable1 <= '1';
						srcRegValidReset1 <= '0';
						srcRegValidInput1 <= src1Valid;
					end if;
				end if;

				if (changedSrc2FromBus = '0') then
					if (inEnables(3) = '1') then
						srcRegTagEnable2 <= '1';
						srcRegTagReset2 <= '0';
						srcRegTagInput2 <= src2Tag;
					end if;
					if (inEnables(1) ='1') then
						srcRegValidEnable2 <= '1';
						srcRegValidReset2 <= '0';
						srcRegValidInput2 <= src2Valid;
					end if;
				end if;

				if (inEnables(0) = '1') then
					busyRegReset <= '0';
					busyRegEnable <= '1';
					busyRegInput <= "1";
				end if;

				ready <= srcRegValidOutput1(0) and srcRegValidOutput2(0);
				if (outEnable'event and outEnable = '1') then
					srcRegValidEnable1 <= '1';
					srcRegValidInput1 <= "0";
					srcRegValidEnable2 <= '1';
					srcRegValidInput2 <= "0";

					busyRegReset <= '0';
					busyRegEnable <= '1';
					busyRegInput <= "0";

					src1value <= srcRegTagOutput1;
					src2value <= srcRegTagOutput2;
					outOpCode <= opCodeRegOutput;
					outDestName <= destNameRegOutput;
				elsif (outEnable'event and outEnable = '0') then
					src1value <= (others => 'Z');
					src2value <= (others => 'Z');
					outOpCode <= (others => 'Z');
					outDestName <= (others => 'Z');
				end if;

				if (outEnable'event or outEnable = '1') then
					ready <= '0';
				end if;
			end if;

			changedSrc1FromBus := '0';
			changedSrc2FromBus := '0';
		end process;
			
		srcRegTag1: entity work.mRegister
			generic map (n => n)
			port map (
				input	=> srcRegTagInput1,
				enable	=> srcRegTagEnable1,
				clk		=> invClk,
				reset	=> srcRegTagReset1,
				output	=> srcRegTagOutput1
			);

		srcRegTag2: entity work.mRegister
			generic map (n => n)
			port map (
				input	=> srcRegTagInput2,
				enable	=> srcRegTagEnable2,
				clk		=> invClk,
				reset	=> srcRegTagReset2,
				output	=> srcRegTagOutput2
			);

		srcRegValid1: entity work.mRegister
			generic map (n => 1)
			port map (
				input	=> srcRegValidInput1,
				enable	=> srcRegValidEnable1,
				clk		=> invClk,
				reset	=> srcRegValidReset1,
				output	=> srcRegValidOutput1
			);

		srcRegValid2: entity work.mRegister
			generic map (n => 1)
			port map (
				input	=> srcRegValidInput2,
				enable	=> srcRegValidEnable2,
				clk		=> invClk,
				reset	=> srcRegValidReset2,
				output	=> srcRegValidOutput2
			);
		
		busyReg: entity work.mRegister
			generic map (n => 1)
			port map (
				input	=> busyRegInput,
				enable	=> busyRegEnable,
				clk		=> invClk,
				reset	=> busyRegReset,
				output	=> busyRegOutput
			);

		opCodeReg: entity work.mRegister
		generic map (n => 5)
		port map (
			input	=> opCodeRegInput,
			enable	=> opCodeRegEnable,
			clk		=> invClk,
			reset	=> opCodeRegReset,
			output	=> opCodeRegOutput
		);

		destNameReg: entity work.mRegister
		generic map (n => 3)
		port map (
			input	=> destNameRegInput,
			enable	=> destNameRegEnable,
			clk		=> invClk,
			reset	=> destNameRegReset,
			output	=> destNameRegOutput
		);
end architecture rtl;
