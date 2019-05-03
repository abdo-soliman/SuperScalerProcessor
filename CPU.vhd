library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity CPU is
	port (
		clk: in 				std_logic 		:= '0';
		reset: in 				std_logic 		:= '0'
	);
end entity CPU;



architecture rtl of CPU is
	signal pcControllerOut:		std_logic_vector(15 downto 0);
	signal pcEnable:			std_logic := '1';
	signal pcOut:				std_logic_vector(15 downto 0);
	signal ROBnewPC:			std_logic_vector(15 downto 0) := "0000000001001000";
	signal ROBwritePC:			std_logic := '0';
	signal queueFull:			std_logic := '0';
	signal memRead:				std_logic := '0';
	signal ROBEnableQueue:		std_logic := '1';
	signal ROBFull:				std_logic := '0';
	signal ROBEmpty:			std_logic := '0';
	signal instQueueOut:		std_logic_vector(15 downto 0) := (others => '0');


	--For testing
	signal ramOut:				std_logic_vector(31 downto 0);
	signal ROBOut:				std_logic_vector(15 downto 0);

	signal instQueueReset:		std_logic := '0';
	signal RFAdapterOut:			std_logic_vector(15 downto 0) := (others => '0');
	signal registerFileOut:		std_logic_vector(15 downto 0) := (others => '0'); 
	signal readRegister:			std_logic_vector(2 downto 0)  := (others => '0');
	signal destRegisterOut:			std_logic_vector(2 downto 0)  := (others => '0');
	signal ROBWriteRegisterEnable: 	std_logic := '0';
begin
	
	ROBEnableQueue <= not ROBFull;

	instQueueReset <= reset or ROBwritePC;
	
	pc: entity work.mRegister
	generic map(n => 16)
	port map (
		input => pcControllerOut,
		enable => pcEnable,
		clk => clk,
		reset => reset, --reset pc
		output => pcOut
	);

	IR:	entity work.mRegister
	generic map(n => 16)
	port map (
		input => pcControllerOut,
		enable => pcEnable,
		clk => clk,
		reset => reset, --reset pc
		output => pcOut
	);

	pcCont:	entity work.PCController
	port map (
		currentPC => pcOut,
		JMPnewPC => ROBnewPC,
		JMPWrite => ROBwritePC,
		queueFull => queueFull,
		newPC	 => pcControllerOut,
		memRead => memRead
	);

	insRam:	entity work.InstructionRam
	port map (
		address => pcOut,
		dataOut => ramOut,
		readEnable => '1',
		clk => clk
	);

	instQueue: entity work.InstructionQueue
	port map (
        input => ramOut,      	
        enable => ROBEnableQueue,
        reset => instQueueReset,
        clk => clk,
        queueFull => queueFull,
        output => instQueueOut
    );


 --   adapter: entity work.RFAdapter
 --   port map(
 --   	inputROB => outputValueSignal,
 --   	inputMEM => memOut, --comes from data memory
 --   	inputPort => portValue, --comes from the port
 --   	inputPortEnable => portWriteEnableOut, -- comes from ROB
 --   	isPop => isPopOut,
 --   	output => RFAdapterOut --to be input to the register file
 --   );

 --   regFile: entit work.registerFile
 --   port map (
 --   	dataIn => RFAdapterOutF,
 --   	dataOut => registerFileOut,
 --   	clk => clk,
 --   	reset => reset,
 --   	readRegister => readRegister, --comes from decoding circuit
 --   	writeRegister => destRegisterOut, -- comes from ROB or from adapter not sure
 --   	writeEnable => ROBWriteRegisterEnable
 --   );

 --   rob: entity work.ReorderBuffer
	--port map(
 --       clk => clk,
 --       pcWriteOut => ROBwritePC,
 --       pcValueOut => ROBnewPC
 --   );
		
	
end architecture rtl;