library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity CPU is
	port (
		clk: in 				std_logic 		:= '0';
		reset: in 				std_logic 		:= '0';
		inputPort: in 			std_logic_vector(15 downto 0) := (others => '0'); 			
		outputPort: out 		std_logic_vector(15 downto 0) := (others => '0'); 			
		interrupt:	in 			std_logic 		:= '0';
		inputPortReady: 	out std_logic := '0'
	);
end entity CPU;



architecture rtl of CPU is
	signal pcControllerOut:		std_logic_vector(15 downto 0);
	signal pcEnable:			std_logic := '1';
	signal pcOut:				std_logic_vector(15 downto 0);
	signal memRead:				std_logic := '0';

	signal ROBnewPC:			std_logic_vector(15 downto 0) := (others => '0');
	signal ROBwritePC:			std_logic := '0';
	signal ROBOutputValue:		std_logic_vector(15 downto 0) := (others => '0'); --data to be written in RF
	signal ROBOutputAddress:		std_logic_vector(15 downto 0) := (others => '0'); --data to be written in RF
	signal ROBmemWriteEnable: 	std_logic := '0';
	signal ROBportWriteEnable: 	std_logic := '0';
	signal ROBportReadEnable: 	std_logic := '0';
	signal ROBisPush:			std_logic := '0';
	signal ROBisPop:			std_logic := '0';
	signal ROBisRet:			std_logic := '0';
	signal ROBwriteRegisterEnable: 	std_logic := '0';
	signal ROBfirstReadRegister:		std_logic_vector(2 downto 0) := (others => '0');
	signal ROBsecondReadRegister:		std_logic_vector(2 downto 0) := (others => '0');
	signal ROBdestRegister:		std_logic_vector(2 downto 0) := (others => '0');


	signal queueFull:			std_logic := '0';
	signal ROBEnableQueue:		std_logic := '1';
	signal ROBFull:				std_logic := '0';
	signal ROBEmpty:			std_logic := '0';

	signal instQueueOut:		std_logic_vector(31 downto 0) := (others => '0');
	signal instQueueMode:		std_logic := '0';
	signal instQueueWritten:	std_logic := '0';
	signal instQueueNumberOfElements: std_logic_vector(3 downto 0);

	signal overWrittenPC:		std_logic_vector(15 downto 0) := (others => '0');
	--------for memoryunit--------------------------------------------------------------------
	signal loadBuffersFull:		std_logic := '0';
	signal issueLoadBuffers:	std_logic := '0';
	--For testing --------------------------------------------------------------
	signal ramOut:				std_logic_vector(31 downto 0) := (others => '0');

	signal ROBsetFlags:			std_logic := '0';
	signal ROBOutToRS:			std_logic_vector(48 downto 0) := (others => '0'); --length may be changed @Ahmed
	signal ROBtagToMem:		std_logic_vector(2 downto 0)  :=  (others => '0');
	signal loadBuffersInstructionIn:		std_logic_vector(28 downto 0) :=  (others => '0');
	----------------------------------------------------------------------------
	signal flush:		std_logic := '0';

	signal RFAdapterOut:			std_logic_vector(15 downto 0) := (others => '0');
	signal firstRegisterFileOut:		std_logic_vector(15 downto 0) := (others => '0'); 
	signal secondRegisterFileOut:		std_logic_vector(15 downto 0) := (others => '0'); 

	signal dataMEMout:				std_logic_vector(15 downto 0) := (others => '0');
	signal dataMEMtag:				std_logic_vector(2 downto 0) := (others => '0');
	signal dataMEMtagValid:			std_logic := '0';
	signal dataMEMinternalValid:	std_logic := '0'; --don't ever use it in ROB

	signal ALUinstructionIn:		std_logic_vector(41 downto 0) := (others => '0');
	signal ALUissue:				std_logic := '0';
	signal ALUout:					std_logic_vector(15 downto 0) := (others => '0');
	signal ALUtag:					std_logic_vector(2 downto 0) := (others => '0');
	signal ALUtagValid:				std_logic := '0';
	signal ALUfull:					std_logic := '0';

	signal flags:					std_logic_vector(2 downto 0) := (others => '0');
	signal ROBflagsOut:				std_logic_vector(2 downto 0) := (others => '0');


begin
	
	inputPortReady <= ROBportReadEnable;

	flush <= reset or ROBwritePC;
	
	overWrittenPC <= dataMEMout when ROBisPop = '1'
			else ROBnewPC;

	outputPort <= ROBOutputValue when ROBportWriteEnable = '1'
				else (others => 'Z');

	pc: entity work.mRegister
	generic map(n => 16)
	port map (
		input => pcControllerOut,
		enable => pcEnable,
		clk => clk,
		reset => '0', --reset pc
		output => pcOut
	);

	pcCont:	entity work.PCController
	port map (
		currentPC => pcOut,
		JMPnewPC => overWrittenPC,
		JMPWrite => ROBwritePC,
		queueFull => queueFull,
		reset => reset,
		instMemOut => ramOut(15 downto 0),
		newPC	 => pcControllerOut,
		memRead => memRead
	);

	insRam:	entity work.InstructionRam
	port map (
		address => pcOut,
		dataOut => ramOut,
		reset => reset,
		readEnable => '1',
		clk => clk
	);

	instQueue: entity work.InstructionQueue
	port map (
        input => ramOut,      	
        enable => ROBEnableQueue,
        mode => instQueueMode,
        reset => flush,
        clk => clk,
        written => instQueueWritten,
        queueFull => queueFull,
        numberOfElementes => instQueueNumberOfElements,
        output => instQueueOut
    );


    adapter: entity work.RFAdapter
    port map(
    	inputROB => ROBOutputValue,
    	inputMEM => dataMEMout, --comes from data memory
    	inputPort => inputPort, --comes from the port
    	inputPortEnable => ROBportReadEnable, -- comes from ROB
    	isPop => ROBisPop,
    	output => RFAdapterOut --to be input to the register file
    );

    regFile: entity work.registerFile
    port map (
    	dataIn => RFAdapterOut,
    	firstDataOut => firstRegisterFileOut,
    	secondDataOut => secondRegisterFileOut,
    	clk => clk,
    	reset => reset,
    	firstReadRegister => ROBfirstReadRegister, --comes from decoding circuit
    	secondReadRegister => ROBsecondReadRegister, --comes from decoding circuit
    	writeRegister => ROBdestRegister, -- comes from ROB or from adapter not sure
    	writeEnable => ROBwriteRegisterEnable
    );

    dataRam: entity work.memUnitIntegration
    port map (
    	clk => clk,
    	issue => issueLoadBuffers,--signal from Rob,
    	reset => flush, --note we will use it to flush(or with pcWriteEnable)
    	robStoreIssue => ROBmemWriteEnable, --mesh fih is store
    	robPushIssue => ROBisPush, --not sure if the right signal
    	robPopIssue => ROBisPop, --not sure bardo
    	isRet => ROBisRet,
    	robTag => ROBtagToMem, --will be output of decoding
    	robAddress => ROBOutputAddress, --some signal from ROB
    	robValue => ROBOutputValue,
    	instruction => loadBuffersInstructionIn, --from decoded circuit
    	lastExcutedAluDestName => ALUTag,
    	lastExcutedAluDestNameValue => ALUout,
    	lastExcutedMemDestName => dataMEMtag,
    	lastExcutedMemDestNameValue => dataMEMout,
    	validAlu => AluTagValid,
    	validMemRob => dataMEMtagValid,
    	full => loadBuffersFull
    );

    arithUnit: entity work.arithmaticUnitIntegration 
	port map (
		clk => clk,
        issue => ALUissue,
        reset => flush,
        setFlags => ROBwritePC, 
        robFlags => ROBflagsOut, --start from here, make signals
        instruction => ALUinstructionIn,
        lastExcutedAluDestName => ALUtag,
        lastExcutedAluDestNameValue => ALUout,
        lastExcutedMemDestName => dataMEMtag,
        lastExcutedMemDestNameValue => dataMEMout,
        validAlu => AluTagValid,
        validMem => dataMEMtagValid,
        flags => flags,
        full => ALUfull
	);



    rob: entity work.ReorderBuffer --Not all signals are connected to ROB
	port map(
		instruction => instQueueOut,
		instQueueWritten => instQueueWritten,
        aluValue => ALUout,
        aluTag => ALUtag,
        mememoryValue => dataMEMout,
        memoryTag => dataMEMtag,
        aluTagValid => ALUtagValid,
        memoryTagValid => dataMEMtagValid,
        flagsIn => flags,

        reset => reset,
        clk => clk,
        inPort => inputPort,
        ROBFull => ROBFull,

        pcWriteOut => ROBwritePC,
        pcValueOut => ROBnewPC,
        destRegisterOut => ROBdestRegister,
        registerWriteEnableOut => ROBwriteRegisterEnable,
        outputValueOut => ROBOutputValue,
        addressOut => ROBOutputAddress,
        memoryWriteEnableOut => ROBmemWriteEnable,
        portWriteEnableOut => ROBportWriteEnable,
        portReadEnableOut => ROBportReadEnable,
        isPushOut => ROBisPush,
        isPopOut => ROBisPop,
		flagsOut => ROBflagsOut,
		tagToMemory => ROBtagToMem,
		isRet => ROBisRet,
        instQueueShiftEnable => ROBEnableQueue,
        instQueueShiftMode => instQueueMode,
        instructionToALU => ALUinstructionIn,
        instructionToMEM => loadBuffersInstructionIn,
        ALUissue => ALUissue,
        MEMissue => issueLoadBuffers,

        aluRsFull => ALUfull,
        memRsFull => loadBuffersFull,
        currentPc => pcOut,
        instQueueNumberOfElements => instQueueNumberOfElements
    );
		
	
end architecture rtl;