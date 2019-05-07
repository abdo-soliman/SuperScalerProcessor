library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
library work;
use work.constants.all;

--length n and width m

entity ReorderBuffer is
    generic ( length: integer := 8;
    		 width: integer  := 49 
    		 );
    port (
        instruction:	in      	std_logic_vector(31 downto 0) := (others => '0');
        instQueueWritten: in        std_logic := '0';
        aluValue:       in          std_logic_vector(15 downto 0) := (others => '0');
        aluTag:        in          std_logic_vector(2 downto 0) := (others => '0');
        mememoryValue:  in          std_logic_vector(15 downto 0) := (others => '0');
        memoryTag:     in          std_logic_vector(2 downto 0) := (others => '0');
        aluTagValid:    in          std_logic := '0';
        memoryTagValid: in          std_logic := '0';
        flagsIn:          in          std_logic_vector(2 downto 0) := (others => '0'); 
        --memory and alu tags from the CBD
       	---------------------------------------------------------------------
        reset:			in      	std_logic := '0';
        clk:			in      	std_logic := '0';
        inPort:         in          std_logic_vector(15 downto 0) := (others => '0');
        ROBFull:		out 		std_logic := '0';
        --ROBEmpty:		out 		std_logic := '0';
        pcWriteOut:        out         std_logic := '0';
        pcValueOut:        out         std_logic_vector(15 downto 0) := (others => '0');
        destRegisterOut:    out     std_logic_vector(2 downto 0) := (others => '0');
        registerWriteEnableOut:    out         std_logic := '0';
        outputValueOut:            out     std_logic_vector(15 downto 0) := (others => '0');
        addressOut:                out     std_logic_vector(15 downto 0) := (others => '0');
        memoryWriteEnableOut:   out        std_logic := '0';
        portWriteEnableOut:     out        std_logic := '0';
        portReadEnableOut:      out        std_logic := '0';
        isPushOut:              out        std_logic := '0';
        isPopOut:               out        std_logic := '0';
        flagsOut:               out        std_logic_vector (2 downto 0) := (others => '0');
        tagToMemory:            out        std_logic_vector (2 downto 0) := (others => '0');
        isRet:                  out        std_logic := '0';
        ------------------------------------------------------------------------
        --Decoding signals out
        instQueueShiftEnable:       out        std_logic := '0';
        instQueueShiftMode:         out        std_logic := '0';
        instructionToALU: 		    out     	std_logic_vector(41 downto 0) := (others => '0');
        instructionToMEM:           out         std_logic_vector(28 downto 0) := (others => '0');
        ALUissue:                   out         std_logic := '0';
        MEMissue:                   out         std_logic := '0';

        aluRsFull:                  in          std_logic := '0';
        memRsFull:                  in          std_logic := '0';
        currentPc:                  in          std_logic_vector(15 downto 0) := (others => '0');
        instQueueNumberOfElements:  in          std_logic_vector(3 downto 0) := (others => '0')
        -------------------------------------------------------------------------------------

    );
end entity ReorderBuffer;

architecture rtl of ReorderBuffer is
	type qType is array(0 to length-1) of std_logic_vector(width-1 downto 0);
    signal q:	 					qType := (others => (others => '0'));
    signal readPointer: 			std_logic_vector(2 downto 0) := (others => '0');
    signal readPointerRotated:		std_logic := '0';
    signal writePointer: 			std_logic_vector(2 downto 0) := (others => '0');
    signal writePointerRotated:		std_logic := '0';
    signal ROBFullSignal: 			std_logic := '0';
    signal ROBEmptySignal: 			std_logic := '1';
    signal opCodeSignal:            std_logic_vector(4 downto 0);

    signal destinationRegisterSignal:    std_logic_vector(2 downto 0);
    signal registerWriteEnableSignal:    std_logic := '0';
    signal outputValueSignal:            std_logic_vector(15 downto 0);
    signal addressSignal:                std_logic_vector(15 downto 0);
    signal memoryWriteEnableSignal:      std_logic := '0';
    signal portWriteEnableSignal:        std_logic := '0';
    signal pcWriteEnableSignal:          std_logic := '0';
    signal pcValueSignal:                std_logic_vector(15 downto 0);
    signal isPushSignal:                 std_logic := '0';
    signal isPopSignal:                  std_logic := '0';

    signal lastStoreSignal:              std_logic_vector(2 downto 0) := (others => '0');
    signal lastStoreValidSignal:         std_logic := '0';


    ----------------------------------------------------------------------------
    --Decoding circuit
    signal ROBentryToBeWritten:                    std_logic_vector(width-1 downto 0) := (others => '0');
    signal ROBissue:                               std_logic := '0';
    
    ----------------------------------------------------------------------------
    type STATE_TYPE is (AVAILABLE, INEXECUTE, FLIGHT);  -- Define the states
    type REGISTER_STATE is array(0 to 7) of STATE_TYPE;
    type WAITING_ROB is array(0 to 7) of std_logic_vector(2 downto 0);

    signal registerState:   REGISTER_STATE := (others => AVAILABLE);
    signal waitingROB:      WAITING_ROB := (others => (others => '0'));
    --------------------------------------------------------------------------------
    type rType is array(0 to 7) of std_logic_vector(15 downto 0);
    signal tempRegisters:       rType := (others => (others => '0'));

    ----------------------------------------------------------------------------
    procedure updateTagAluMemory(variable    entry:             inout       std_logic_vector(width-1 downto 0);
                                 signal    aluValue:          in          std_logic_vector(15 downto 0);
                                 signal    aluTag:            in          std_logic_vector(2 downto 0) ;
                                 signal    mememoryValue:      in          std_logic_vector(15 downto 0);
                                 signal    memoryTag:         in          std_logic_vector(2 downto 0);
                                 signal    aluTagValid:       in          std_logic;
                                 variable  index:             in          integer;
                                 signal    memoryTagValid:    in          std_logic;
                                 signal    flags:             in          std_logic_vector(2 downto 0);
                                 variable destRegister:         out       std_logic_vector(2 downto 0);
                                 variable destRegisterGotValue:  out       boolean) is
        variable OPcode:    std_logic_vector(4 downto 0);
        variable doneBit:   std_logic;
        variable validBit:  std_logic;
        variable aluTagInt: integer;
        variable memoryTagInt: integer;

        --for store case, I'm sad :(
        variable firstTag: std_logic_vector(2 downto 0);
        variable secondTag: std_logic_vector(2 downto 0);
        begin
            aluTagInt  := to_integer(unsigned(aluTag));
            memoryTagInt := to_integer(unsigned(memoryTag));
            OPcode := getOpCode(entry);
            destRegisterGotValue := false;

            if ((isTypeZero(OPcode) and OPcode /= OUT_OPCODE) or isTypeOne(OPcode) or OPcode = LDD_OPCODE or OPcode = LDM_OPCODE) then
                
                if ((aluTagInt = index and aluTagValid = '1') or 
                    (memoryTagInt = index and memoryTagValid = '1')) then --no check on op code just the tag

                    report "Hello my lady";
                    report integer'image(index);
                    if(aluTagInt = index )then
                        entry(42 downto 27) := aluValue; --value
                    else
                        entry(42 downto 27) := mememoryValue;
                    end if;

                    if (isTypeZero(OPcode)) then 
                        if (OPcode = NOT_OPCODE or OPcode = INC_OPCODE or OPcode = DEC_OPCODE) then 
                            destRegister := DestinationRegister(entry);
                            destRegisterGotValue := true;
                        end if;
                    else 
                        destRegister := DestinationRegister(entry);
                        destRegisterGotValue := true;
                    end if;
                    entry(26) := '1'; --value valid bit
                    validBit := '1';
                    entry(1) := '1'; -- done bit
                    doneBit := '1';

                end if;
            end if;
            
            if (isTypeThree(OPcode) and OPcode /= RTI_OPCODE) then

                if(Execute(entry) = '0' and aluTagInt = WaitingTag(entry) and aluTagValid = '1') then

                    entry(2) := '1';
                    entry(6 downto 4) := flags;
                    --Done is decision of jump
                    --If 1, jmp is taken, 
                    --else untaken
                    if(OPcode = JC_OPCODE and isCarrySet(flags)) then 
                        entry(1) := '1'; --Done bit
                    elsif (OPcode = JZ_OPCODE and isZeroSet(flags)) then
                        entry(1) := '1';
                    elsif (OPcode = JN_OPCODE and isNegativeSet(flags)) then
                        entry(1) := '1';

                    end if;

                end if;

            end if;

            if(OPcode = RTI_OPCODE) then 
                
                if(Execute(entry) = '0' and memoryTagInt = WaitingTag(entry) and memoryTagValid = '1') then 
                    entry(2) := '1';
                    entry(6 downto 4) := mememoryValue(15 downto 13);
                end if;

            end if;

            -----------------------Dependency resolver---------------------

            -- note that isJmpFamily doesn't include unconditional jmp
            -- so I added it explicitly
            if (isJmpFamily(OPcode) or OPcode = JMP_OPCODE) then

                if (aluTagValid = '1' or memoryTagValid = '1') then 

                    firstTag := DestinationAddressTag(entry);
                    report "In jump";
                    report integer'image(to_integer(unsigned(firstTag)));
                    if (DestinationAddressValid(entry) = '0') then 

                        if(aluTagValid = '1' and aluTag = firstTag) then
                            entry(25 downto 10) := aluValue; --Destination address
                            entry(0) := '1'; ----Destination address valid
                        elsif (memoryTagValid = '1' and memoryTag = firstTag) then
                            entry(25 downto 10) := mememoryValue;
                            entry(0) := '1';
                        end if;

                    end if;

                end if;

            end if;

            if (OPcode = CALL_OPCODE) then 

                if (aluTagValid = '1' or memoryTagValid = '1') then 

                    firstTag := DestinationAddressTag(entry);

                    if (DestinationAddressValid(entry) = '0') then 
                        if(aluTagValid = '1' and aluTag = firstTag) then
                            entry(25 downto 10) := aluValue; --Destination address
                            entry(0) := '1'; --Destination address valid
                        elsif (memoryTagValid = '1' and memoryTag = firstTag) then
                            entry(25 downto 10) := mememoryValue;
                            entry(0) := '1';
                        end if;
                    end if;

                end if;

            end if;

            if (OPcode = OUT_OPCODE or OPcode = PUSH_OPCODE) then 

                if (aluTagValid = '1' or memoryTagValid = '1') then 

                    firstTag := ValueTag(entry);

                    if (ValueValid(entry) = '0') then 
                        if(aluTagValid = '1' and aluTag = firstTag) then
                            entry(42 downto 27) := aluValue; --value
                            entry(26) := '1'; --value valid
                        elsif (memoryTagValid = '1' and memoryTag = firstTag) then
                            entry(42 downto 27) := mememoryValue;
                            entry(26) := '1';
                        end if;
                    end if;

                end if;

            end if;

            if (OPcode = STD_OPCODE) then 
                
                if (aluTagValid = '1' or memoryTagValid = '1') then 

                    firstTag := ValueTag(entry); --value tag
                    secondTag := DestinationAddressTag(entry); --destination tag

                    if (ValueValid(entry) = '0') then 
                        if(aluTagValid = '1' and aluTag = firstTag) then
                            entry(42 downto 27) := aluValue; --value
                            entry(26) := '1'; --value valid
                        elsif (memoryTagValid = '1' and memoryTag = firstTag) then
                            entry(42 downto 27) := mememoryValue;
                            entry(26) := '1';
                        end if;
                    end if;

                    if (DestinationAddressValid(entry) = '0') then 
                        if(aluTagValid = '1' and aluTag = secondTag) then
                            entry(25 downto 10) := aluValue; --Destination address
                            entry(0) := '1'; --Destination address valid
                        elsif (memoryTagValid = '1' and memoryTag = secondTag) then
                            entry(25 downto 10) := mememoryValue;
                            entry(0) := '1';
                        end if;
                    end if;


                end if;
               

            end if;
        end updateTagAluMemory;
    ----------------------------------------------------------------------------
    procedure inputParser(variable    entry:        inout       std_logic_vector(width-1 downto 0);
                          signal       q:			in	    qType;
                          signal readPointer: 		in	        std_logic_vector(2 downto 0);
                          signal writePointer: 		in	        std_logic_vector(2 downto 0);
                          signal flags:             in          std_logic_vector(2 downto 0);
                          signal    ROBEmptySignal:  in          std_logic;
                          variable    lastStore:      out          std_logic_vector(2 downto 0);
                          variable    lastStoreValid:  out         std_logic       )is
                    
    --for looping
    variable l: integer;
    variable r: integer;
    

    --temp variables
    variable temp: integer := 0;
    variable entryOpCode: std_logic_vector(4 downto 0); --opcode from decoding circuit
    variable loopOpCode: std_logic_vector(4 downto 0);  --opcode of an element in reorder buffer

    begin
        lastStoreValid := '0';
        entryOpCode := getOpCode(entry=> entry);

       if(isStore(entryOpCode)) then
            lastStore := writePointer;
            lastStoreValid := '1';

        elsif(isTypeThree(entryOpCode) and entryOpCode /= RTI_OPCODE) then --case jumps

            l := to_integer(unsigned(readPointer));
            r := to_integer(unsigned(writePointer));

            entry(2) := '1'; 

            while(ROBEmptySignal = '0') loop

                loopOpCode := getOpCode(entry => q(r) );

                if (Done(q(r)) = '0' and affectsFlags(loopOpCode) ) then

                    entry(6 downto 4) := std_logic_vector(to_unsigned(r , 3));
                    entry(2) := '0'; --Execute/wait bit is not valid    
                    temp := 1;
                    exit;   

                end if;

                if (l = r) then 
                    exit;
                end if;

                if( r = 0 ) then
                    r := 7;
                else
                    r := r - 1;
                end if;

            end loop;

            if (temp = 0) then 
                
                entry(6 downto 4) := flags;

                if(entryOpCode = JC_OPCODE and isCarrySet(flags)) then 
                    entry(1) := '1'; --Done bit
                elsif (entryOpCode = JZ_OPCODE and isZeroSet(flags)) then
                    entry(1) := '1';
                elsif (entryOpCode = JN_OPCODE and isNegativeSet(flags)) then
                    entry(1) := '1';
                end if;

            end if;

        end if;
      
    end inputParser;

    ----------------------------------------------------------------------------

    procedure commitInstruction(variable    entry:                  inout   std_logic_vector(width-1 downto 0);
                                variable    destRegister:           out     std_logic_vector(2 downto 0);
                                variable    registerWriteEnable:    out     std_logic;
                                variable      outputValue:            out     std_logic_vector(15 downto 0);
                                signal      address:                out     std_logic_vector(15 downto 0);
                                signal      pcOutValue:             out     std_logic_vector(15 downto 0);
                                variable    memoryWriteEnable:      out     std_logic;
                                variable    portWriteEnable:        out     std_logic;
                                variable    portReadEnable:         out     std_logic;
                                variable    pcWriteEnable:          out     std_logic;
                                variable    isPush:                 out     std_logic;
                                variable    isPop:                  out     std_logic;
                                variable    commitPop:              out     std_logic;
                                variable    isStore:                out     std_logic;
                                variable    flags:                  out     std_logic_vector(2 downto 0);
                                variable    commited:               out     boolean) is
                    
    variable entryOpCode: std_logic_vector(4 downto 0);

    begin
        entryOpCode := getOpCode(entry);

        registerWriteEnable := '0';
        memoryWriteEnable := '0';
        portWriteEnable := '0';
        portReadEnable := '0';
        pcWriteEnable := '0';
        isPush := '0';
        isPop := '0';
        commitPop := '0';
        isStore := '0';
        commited := false;

        if (isStackFamily(entryOpCode) or entryOpCode = STD_OPCODE) then
            --Memory instructions

            if (entryOpCode = POP_OPCODE) then
                if(Done(entry) = '1')then
                    commited := true;
                    destRegister := DestinationRegister(entry);
                    registerWriteEnable := '1';
                    commitPop := '1';
                else
                    isPop := '1';
                    entry(1) := '1';
                end if;

            elsif entryOpCode = INT_OPCODE then
                if(Execute(entry) = '1' and Done(entry) = '0') then 
                    -- push return PC 
                    outputValue := Value(entry);
                    isPush := '1';
                    entry(1) := '1';
                elsif(Done(entry) = '1') then 
                    commited := true;
                    -- push flags
                    outputValue := (others => '0');
                    outputValue(15 downto 13) := WaitingTag(entry);
                    -- outputValue := (15 downto 13 => WaitingTag(entry), others => '0');
                    isPush := '1';
                    -- write interrupt address into PC
                    pcOutValue <= DestinationAddress(entry);
                    pcWriteEnable := '1';
                end if;

            elsif (entryOpCode = PUSH_OPCODE) then

                if (ValueValid(entry) = '1') then
                    commited := true;
                    outputValue := Value(entry);
                    isPush := '1';
                end if;

            elsif (entryOpCode = CALL_OPCODE) then
                -- Value is PC (resolved already from decoding circuit)
                -- wait for destination resolving
                if (DestinationAddressValid(entry) = '1') then
                    commited := true;
                    pcWriteEnable := '1';

                    outputValue := Value(entry); --old pc in value

                    pcOutValue <= DestinationAddress(entry);

                    isPush := '1';

                end if;

            -- Add store case
            elsif (entryOpCode = STD_OPCODE) then

                if (ValueValid(entry) = '1') then
                    
                    memoryWriteEnable := '1';
                    address <= DestinationAddress(entry);
                    outputValue := Value(entry);
                    isStore := '1';
                    commited := true;


                end if;


            elsif (entryOpCode = RET_OPCODE) then 

                commited := true;
                isPop := '1';
                pcWriteEnable := '1';

            elsif (entryOpCode = RTI_OPCODE) then

                if(Execute(entry) = '0' and Done(entry) = '0') then 
                    isPop := '1';
                    
                    entry(1) := '1';
                elsif Execute(entry) = '1' and Done(entry) = '1' then    
                    commited := true;
                    isPop := '1';
                    pcWriteEnable := '1';
                    
                end if;
                
            end if;



        elsif (isJmpFamily(entryOpCode) or entryOpCode = JMP_OPCODE) then --jumps
            if (DestinationAddressValid(entry) = '1') then
                commited := true;
                if (Done(entry) = '1') then --branch taken
                    pcOutValue <= DestinationAddress(entry); --TODO change to pc out value
                    pcWriteEnable := '1';
                end if;
            end if;

        elsif (entryOpCode = NOP_OPCODE) then --no commit
            -- Some people don't do anything, but history mentions them
            -- NOP is one of them, may it rest in peace.
            commited := true; 

        elsif (entryOpCode = IN_OPCODE) then 
            commited := true;
            registerWriteEnable := '1';
            portReadEnable := '1';
            destRegister := DestinationRegister(entry);
            outputValue := Value(entry);

        elsif (entryOpCode = OUT_OPCODE) then
            if(ValueValid(entry) = '1') then 
                commited := true;
                outputValue := Value(entry);
                portWriteEnable := '1';
            end if;

        else  --Commit to register
            if(ValueValid(entry) = '1') then 
                commited := true;
                outputValue := Value(entry);
                registerWriteEnable := '1';
                destRegister := DestinationRegister(entry);
            end if;
        end if;

    end commitInstruction;
    ----------------------------------------------------------------------------
   procedure decode(signal        robFull:            in std_logic;
                    signal        aluRsFull:          in std_logic;
                    signal        memRsFull:          in std_logic;
                    signal        instruction:        in std_logic_vector(15 downto 0);
                    signal        immediateValue:     in std_logic_vector(15 downto 0);
                    signal        lastStore:          in std_logic_vector(2 downto 0);
                    signal        lastStoreValid:     in std_logic;
                    signal        rsDestName:         in std_logic_vector(2 downto 0);
                    variable        robSrc1value:       in std_logic_vector(15 downto 0);
                    variable        robSrc2value:       in std_logic_vector(15 downto 0);
                    signal        rsAluValid:         out std_logic;
                    signal       rsAluInstruction:   out std_logic_vector(41 downto 0);
                    signal        rsMemValid:         out std_logic;
                    signal       rsMemInstruction:   out std_logic_vector(28 downto 0);
                    signal       robValid:           out std_logic;
                    signal        robInstruction:     out std_logic_vector(48 downto 0);
                    signal        instQueueEnable:    out std_logic;
                    signal        instQueueMode:      out std_logic;          
                    signal         r:                  in rType;
                    signal         state:              inout REGISTER_STATE;
                    signal         waitingROB:         inout WAITING_ROB;
                    signal         currentPc:          in std_logic_vector(15 downto 0);
                    signal         PortIn:             in std_logic_vector(15 downto 0);
                    signal         numberOfElements:   in std_logic_vector(3 downto 0))is

    variable opcode:          std_logic_vector(4 downto 0) := (others => '0');
    variable opcodeType:      std_logic_vector(1 downto 0) := (others => '0');
    variable src1:            std_logic_vector(2 downto 0) := (others => '0');
    variable src2:            std_logic_vector(2 downto 0) := (others => '0');
    
    variable src1state:   STATE_TYPE;
    variable src1tag:     std_logic_vector(2 downto 0);
    variable regSrc1value: std_logic_vector(15 downto 0);

    variable src2state:   STATE_TYPE;
    variable src2tag:     std_logic_vector(2 downto 0);
    variable regSrc2value: std_logic_vector(15 downto 0);

    variable valueSrc1:   std_logic_vector(15 downto 0);
    variable validSrc1:   std_logic := '0';
    variable valueSrc2:   std_logic_vector(15 downto 0);
    variable validSrc2:   std_logic := '0';
    variable destRegister:     std_logic_vector(2 downto 0);
    variable waitingTag:  std_logic_vector(2 downto 0);
    variable setZeroSrc:  std_logic;
    variable setZeroSrc2: std_logic;

    begin
        

        rsAluInstruction <= (others => '0');
        rsMemInstruction <= (others => '0');
        robInstruction <= (others => '0');
        instQueueEnable <= '1';
        instQueueMode <= '0';

        robValid <= '1';    
        rsAluValid <= '0';
        rsMemValid <= '0';

        setZeroSrc := '0';
        waitingTag := (others => '0');
        valueSrc1 := (others => '0');
        validSrc1 := '0';
        valueSrc2 := (others => '0');
        validSrc2 := '0';
        destRegister := (others => '0');

        opcode := instruction(15 downto 11);
        opcodeType := instruction(15 downto 14);
        src1 := instruction (10 downto 8);
        src2 := instruction (7 downto 5);
        robInstruction(47 downto 43) <= opcode;
        robInstruction(48) <= '1';
        robInstruction(3 downto 1) <= "000";
        destRegister := src1;

        src1state := state(to_integer(unsigned(src1)));
        src1tag :=   waitingROB(to_integer(unsigned(src1)));
        regSrc1value := r(to_integer(unsigned(src1)));

        src2state :=   state(to_integer(unsigned(src2)));
        src2tag :=     waitingROB(to_integer(unsigned(src2)));
        regSrc2value := r(to_integer(unsigned(src2)));

        if(isAlueRSinstruction(instruction(15 downto 11) ) )then
            if(aluRsFull = '1' or robFull = '1')then
                robValid <= '0';
                rsAluValid <= '0';
                instQueueEnable <= '0';
                return;
            end if;
        elsif (isLoad(instruction(15 downto 11) )) then
            if(memRsFull = '1' or robFull = '1')then
                robValid <= '0';
                rsMemValid <= '0';
                instQueueEnable <= '0';
                return;
            end if;
        end if;
        

        if(instruction(15 downto 11) = SHR_OPCODE or instruction(15 downto 11) = SHL_OPCODE or instruction(15 downto 11) = LDM_OPCODE)then
            instQueueMode <= '1';
        end if;
        if (src1state = AVAILABLE) then
            valueSrc1 := regSrc1value;
            validSrc1 := '1';
        elsif (src1state = INEXECUTE) then
            valueSrc1(15 downto 13) := src1tag;
            valueSrc1(12 downto 0) := (others => '0');
            validSrc1 := '0';
        elsif (src1state = FLIGHT) then
            valueSrc1 := robSrc1value;
            validSrc1 := '1';
        end if;

        if (src2state = AVAILABLE) then
            valueSrc2 := regSrc2value;
            validSrc2 := '1';
        elsif (src2state = INEXECUTE) then
            valueSrc2(15 downto 13) := src2tag;
            valueSrc2(12 downto 0) := (others => '0');
            validSrc2 := '0';
        elsif (src2state = FLIGHT) then
            valueSrc2 := robSrc2value;
            validSrc2 := '1';
        end if;

        if (opcodeType = "00") then -- in will have the value of the port
            setZeroSrc2 := '1';
            if (opcode /= NOP_OPCODE and opcode /= IN_OPCODE and opcode /= OUT_OPCODE) then
                rsAluValid <= '1';
                setZeroSrc := '1';
            end if;

            if (opcode = SETC_OPCODE or opcode = CLC_OPCODE) then
                validSrc1 := '1';
                validSrc2 := '1';
            end if;
            if (opcode = NOT_OPCODE or opcode = INC_OPCODE or opcode = DEC_OPCODE) then
                validSrc2 := '1';
            end if;
            -- validSrc2 := '0';
            -- valueSrc2 := (others => '0');
            robValid <= '1';    -- 00 instruction never stall
            if (opcode = NOP_OPCODE) then
                valueSrc1 := (others => '0');
                validSrc1 := '0';
                valueSrc2 := (others => '0');
                validSrc2 := '0';
                destRegister := (others => '0');
                robInstruction(1 downto 0) <= (others => '1'); --set done bit
            elsif (opcode = IN_OPCODE) then --remember adding value at decode stage
                valueSrc1 := PortIn; --will not be zeros will be post value
                validSrc1 := '1';
            elsif(opcode = OUT_OPCODE)then
                valueSrc2 := (others => '0');
                validSrc2 := '0';
            end if;
        elsif (opcodeType = "01") then
            setZeroSrc := '1';
            if (opcode = SHR_OPCODE or opcode = SHL_OPCODE) then
                -- stall <= '1';
                --instQueueMode := '1';
                valueSrc2 := immediateValue;
                validSrc2 := '1';
            else
                rsAluValid <= '1';
                robValid <= '1';    -- only SHR and SHL stall
            end if;
        elsif (opcodeType = "10") then
            if (opcode /= STD_OPCODE or opcode /= PUSH_OPCODE) then
                    setZeroSrc2 := '1';
                end if;

            if (opcode = LDD_OPCODE) then
                rsMemValid <= '1';
                setZeroSrc := '1'; --not really needed
                if (lastStoreValid = '1') then
                    validSrc1 := '0';
                    valueSrc1(2 downto 0) := (others => '0');
                    waitingTag := lastStore;
                    valueSrc1(15 downto 3) := (others => '0');
                else
                    validSrc1 := '1';
                    valueSrc1 := (others => '0');
                end if;
            end if;

            if (opcode = LDM_OPCODE) then
                robValid <= '1';    -- only LDM Stalls
                rsAluValid <= '1';
                setZeroSrc := '1';
                --instQueueMode := '1';
                valueSrc2 := immediateValue;
                validSrc2 := '1';
            end if;

            if (opcode = POP_OPCODE) then
                validSrc1 := '0';
                valueSrc1 := (others => '0');
                setZeroSrc := '1';
            end if;
            --if (opcode = LDD_OPCODE) then
            --    validSrc1 := '0';
            --    valueSrc1 := (others => '0');
            --end if;
        elsif (opcodeType = "11") then
            robValid <= '1';    -- 11 isntructions never stall --malosh lazma
            if (opcode = RET_OPCODE or opcode = RTI_OPCODE) then
                valueSrc1 := (others => '0');
                validSrc1 := '0';
                valueSrc2 := (others => '0');
                validSrc2 := '0';
                destRegister := (others => '0');
                robInstruction(6 downto 1) <= (others => '0'); --all except for the opcode and busy
            elsif (opcode = CALL_OPCODE) then
                valueSrc1 := currentPc - numberOfElements - 1;
                validSrc1 := '1';
            else
                if (src1state = AVAILABLE) then
                    valueSrc2 := regSrc1value;
                    validSrc2 := '1';
                elsif (src1state = INEXECUTE) then
                    valueSrc2(15 downto 13) := src1tag;
                    valueSrc2(12 downto 0) := (others => '0');
                    validSrc2 := '0';
                elsif (src1state = FLIGHT) then
                    valueSrc2 := robSrc1value;
                    validSrc2 := '1';
                end if;

                -- robInstruction(42 downto 26) <= (others => '0');
                valueSrc1 := (others => '0');
                validSrc1 := '0';
            end if;
        end if;


        robInstruction(9 downto 7) <= destRegister; --dest register ya3ny
        robInstruction(6 downto 4) <= waitingTag;
        if(setZeroSrc = '1')then
            robInstruction(0) <= '0';
            robInstruction(25 downto 10) <= (others => '0');
            robInstruction(26) <= '0';
            robInstruction(42 downto 27) <= (others => '0');
        elsif (setZeroSrc2 = '0') then
            robInstruction(0) <= '0';
            robInstruction(25 downto 10) <= (others => '0');
            robInstruction(26) <= validSrc1;
            robInstruction(42 downto 27) <= valueSrc1;
        else
            robInstruction(0) <= validSrc2;
            robInstruction(25 downto 10) <= valueSrc2;
            robInstruction(26) <= validSrc1;
            robInstruction(42 downto 27) <= valueSrc1;
        end if;

        if (src1state = INEXECUTE) then
            valueSrc1(2 downto 0) := valueSrc1(15 downto 13);
            valueSrc1(15 downto 3) := (others => '0');
            validSrc1 := '0';
        end if;

        if (src2state = INEXECUTE) then
            valueSrc2(2 downto 0) := valueSrc2(15 downto 13);
            valueSrc2(15 downto 3) := (others => '0');
            validSrc2 := '0';
        end if;

        if (lastStoreValid = '1' and opcode = LDD_OPCODE) then
            valueSrc1(2 downto 0) := waitingTag;
        end if;
        
        rsAluInstruction(2 downto 0) <= rsDestName;
        rsAluInstruction(3) <= validSrc2;
        rsAluInstruction(19 downto 4) <= valueSrc2;
        rsAluInstruction(20) <= validSrc1;
        rsAluInstruction(36 downto 21) <= valueSrc1;
        rsAluInstruction(41 downto 37) <= opcode;

        rsMemInstruction(2 downto 0) <= rsDestName;
        rsMemInstruction(3) <= validSrc2;
        rsMemInstruction(19 downto 4) <= valueSrc2;
        rsMemInstruction(20) <= validSrc1;
        rsMemInstruction(23 downto 21) <= valueSrc1(2 downto 0);
        rsMemInstruction(28 downto 24) <= opcode;
        
    
        if(writesBack(instruction(15 downto 11)))then
            waitingROB(to_integer(unsigned(destRegister))) <= rsDestName;
            if(instruction(15 downto 11) = IN_OPCODE)then
                state(to_integer(unsigned(destRegister))) <= FLIGHT;
            else 
               state(to_integer(unsigned(destRegister))) <= INEXECUTE;  
            end if;
        end if;


    end decode;
    ----------------------------------------------------------------------------
    procedure resolveLoad(  signal myTag:           in          std_logic_vector(2 downto 0);      
                            signal q:               inout       qType;
                            signal readPointer:     in          std_logic_vector(2 downto 0);
                            signal writePointer:    in          std_logic_vector(2 downto 0);
                            signal ROBEmptySignal:  in          std_logic)is
                    
    --for looping
    variable l: integer;
    variable r: integer;

    --temp variable
    variable loopOpCode: std_logic_vector(4 downto 0);  --opcode of an element in reorder buffer

    begin
        l := to_integer(unsigned(readPointer));
        r := to_integer(unsigned(writePointer));
        
        while( ROBEmptySignal = '0' ) loop

            loopOpCode := getOpCode(q(r));

            -- if load 
            if(isLoad(loopOpCode) and Execute(q(r)) = '0' and WaitingTag(q(r)) = myTag) then
                q(r)(2) <= '1'; --Execute/wait bit is now valid
            end if;

            if (l = r) then 
                exit;
            end if;

            if( r = 0 ) then
                r := 7;
            else
                r := r - 1; 
            end if;

        end loop;

    end resolveLoad;
    ----------------------------------------------------------------------------
begin
    --outputRS <= q(to_integer(unsigned(readPointer)));
    opCodeSignal <= getOpCode(q(to_integer(unsigned(readPointer))));
    --ROBFullSignal <= '1' when tail = head
    --				else '0';
    ROBFull <= ROBFullSignal;

    ROBEmptySignal <= '1' when (readPointer = writePointer and ROBFullSignal = '0')
                    else '0';

    portReadEnableOut <= '1' when instruction(31 downto 27) = IN_OPCODE
                    else '0';

    outputValueOut <= outputValueSignal;
    registerWriteEnableOut <= registerWriteEnableSignal;
    memoryWriteEnableOut <= memoryWriteEnableSignal;
    portWriteEnableOut <= portWriteEnableSignal;
    pcWriteOut <= pcWriteEnableSignal;
    isPushOut <= isPushSignal;
    isPopOut <= isPopSignal;
    

    process (clk,reset,instQueueWritten)
        variable    destinationRegisterV:         std_logic_vector(2 downto 0);
        variable    registerWriteEnableV:         std_logic;
        variable    outputValueV:                 std_logic_vector(15 downto 0);
        variable    address:                      std_logic_vector(15 downto 0);
        variable    memoryWriteEnableV:           std_logic;
        variable    portWriteEnableV:             std_logic;
        variable    pcWriteEnableV:               std_logic;
        variable    portReadEnableV:              std_logic;
        variable    isPushV:                      std_logic;
        variable    isPopV:                       std_logic;
        variable    commitPopV:                    std_logic;
        variable    isStoreV:                     std_logic;
        variable    commitedV:                    boolean;
        variable    inp:                          std_logic_vector(width-1 downto 0);
        variable    flagsOutV:                        std_logic_vector(2 downto 0);
        variable    loopEntry:                    std_logic_vector(width-1 downto 0);
        variable    l:                            integer;
        variable    r:                            integer;

        variable    temp1:                        std_logic_vector(15 downto 0);
        variable    temp2:                        std_logic_vector(15 downto 0);

        variable    destRegisterV:                std_logic_vector(2 downto 0);
        variable    destRegisterGotValueV:        boolean := false;
        variable    lastStoreV:                   std_logic_vector(2 downto 0);
        variable    lastStoreValidV:              std_logic := '0';
    ------decoding-----------------------------------------------------------------------
    begin

        inp := q(to_integer(unsigned(readPointer)));

        if (reset = '1') then 
            q <= (others => (others => '0'));
            readPointer <= (others => '0');
            --ReadPointerRotated <= '0';
            writePointer <= (others => '0');
            --writePointerRotated <= '0';
            ROBFullSignal <= '0';
            --ROBEmptySignal <= '1';

        elsif(clk'event and clk = '1') then
        
            if (ROBissue = '1') then 

                inp := ROBentryToBeWritten;

                report toString(ROBentryToBeWritten);

                inputParser(
                            entry => inp,
                            q => q,
                            readPointer => readPointer,
                            writePointer => writePointer,
                            flags => flagsIn,
                            ROBEmptySignal => ROBEmptySignal,
                            lastStore => lastStoreV,
                            lastStoreValid => lastStoreValidV );

                if (lastStoreValidV = '1') then 
                    lastStoreSignal <= lastStoreV;
                    lastStoreValidSignal <= '1';
                end if;

                q(to_integer(unsigned(writePointer))) <= inp;

                writePointer <= writePointer + 1;

                if(writePointer + 1 = readPointer) then 
                    ROBFullSignal <= '1';
                end if;
            end if;

        elsif (clk'event and clk = '0') then
            ALUissue <= '0';
            isRet <= '0';
            registerWriteEnableV := '0';
            memoryWriteEnableV := '0';
            portWriteEnableV := '0';
            portReadEnableV := '0';
            pcWriteEnableV := '0';
            isPushV := '0';
            isPopV := '0';
            isStoreV := '0';
            commitPopV := '0';
            flagsOutV := (others => '0');
            
            tagToMemory <= readPointer;
            registerWriteEnableSignal <= registerWriteEnableV;
            memoryWriteEnableSignal <= memoryWriteEnableV;
            portWriteEnableSignal <= portWriteEnableV;
            pcWriteEnableSignal <= pcWriteEnableV;
            --portReadEnableOut <= portReadEnableV;
            isPushSignal <= isPushV;
            isPopSignal <= isPopV;
            flagsOut <= flagsOutV;
            destRegisterGotValueV := false;

            if(ROBEmptySignal /= '1')then
                report "Plz";
                commitInstruction(
                    inp,
                    destinationRegisterV,
                    registerWriteEnableV,
                    outputValueV,
                    addressOut,
                    pcValueOut,
                    memoryWriteEnableV,
                    portWriteEnableV,
                    portReadEnableV,
                    pcWriteEnableV,
                    isPushV,
                    isPopV,
                    commitPopV,
                    isStoreV,
                    flagsOutV,
                    commitedV
                    );
                outputValueSignal <= outputValueV;
                destRegisterOut <= destinationRegisterV;
                registerWriteEnableSignal <= registerWriteEnableV;
                memoryWriteEnableSignal <= memoryWriteEnableV;
                portWriteEnableSignal <= portWriteEnableV;
                pcWriteEnableSignal <= pcWriteEnableV;
                --portReadEnableOut <= portReadEnableV;
                isPushSignal <= isPushV;
                isPopSignal <= isPopV;
                flagsOut <= flagsOutV;

                if (commitedV) then 
                    readPointer <= readPointer + 1;
                    ROBFullSignal <= '0';
                else
                    q(to_integer(unsigned(readPointer))) <= inp;    
                end if;
                
                if (commitedV and registerWriteEnableV = '1') then 
                    --TODO add RF Adapter
                    if (commitPopV = '1')then
                        tempRegisters(to_integer(unsigned(destinationRegisterV))) <= mememoryValue;
                        outputValueSignal <= mememoryValue;

                        if (registerState(to_integer(unsigned(destinationRegisterV))) = INEXECUTE
                            and waitingROB(to_integer(unsigned(destinationRegisterV))) = readPointer) then 

                                registerState(to_integer(unsigned(destinationRegisterV))) <= AVAILABLE;

                        end if;

                    elsif(isPopV = '0')then
                        tempRegisters(to_integer(unsigned(destinationRegisterV))) <= outputValueV;
                        if (registerState(to_integer(unsigned(destinationRegisterV))) = FLIGHT
                            and waitingROB(to_integer(unsigned(destinationRegisterV))) = readPointer) then 

                                registerState(to_integer(unsigned(destinationRegisterV))) <= AVAILABLE;

                        end if;
                    end if;
                    



                end if;

                if (isPopV = '0' and pcWriteEnableV = '1') then --RET 
                    isRet <= '1';
                end if;

                if (isStoreV = '1') then --store

                    if (commitedV) then 
                        if (lastStoreValidSignal = '1' and lastStoreSignal = readPointer) then
                            lastStoreValidSignal <= '0';
                        end if; 
                        
                        resolveLoad(readPointer,q,readPointer,writePointer,ROBEmptySignal);

                    end if;

                elsif(pcWriteEnableV = '1') then --jumps
                    report "Kolo raye7";
                    q <= (others => (others => '0'));
                    readPointer <= (others => '0');
                    writePointer <= (others => '0');
                    lastStoreValidSignal <= '0';
                    registerState <= (others => AVAILABLE);
                    ROBFullSignal <= '0';
                    --ReadPointerRotated <= '0';
                    --writePointerRotated <= '0';
                    --pcValueSignal <= outputValueSignal;
                    --ROBEmptySignal <= '1';
                end if;
            end if;
            
            l := to_integer(unsigned(readPointer));
            r := to_integer(unsigned(writePointer));

            while( ROBEmptySignal = '0' and pcWriteEnableV = '0') loop

                loopEntry := q(r);

                updateTagAluMemory(
                            entry => loopEntry,
                            aluValue => aluValue,
                            aluTag => aluTag,
                            mememoryValue => mememoryValue,
                            memoryTag => memoryTag,
                            aluTagValid => aluTagValid,
                            index => r,
                            memoryTagValid => memoryTagValid,
                            flags => flagsIn,
                            destRegister => destRegisterV,
                            destRegisterGotValue => destRegisterGotValueV
                            );

                q(r) <= loopEntry;

                if(destRegisterGotValueV) then 
                  if(registerState(to_integer(unsigned(destRegisterV))) = INEXECUTE
                     and waitingROB(to_integer(unsigned(destRegisterV))) = std_logic_vector(to_unsigned(r,4))) then 

                    registerState(to_integer(unsigned(destRegisterV))) <= FLIGHT;

                  end if;
                end if;

                if (l = r) then 
                    exit;
                end if;

                if( r = 0 ) then
                    r := 7;
                else
                    r := r - 1; 
                end if;

            end loop;
        --end if;

        --------------------------------------------------------------------
        --Decoding
        elsif(instQueueWritten'event and instQueueWritten = '1') then
            temp1 := Value(q(to_integer(unsigned(waitingROB(to_integer(unsigned(instruction(26 downto 24))))))));
            temp2 := Value(q(to_integer(unsigned(waitingROB(to_integer(unsigned(instruction(23 downto 21))))))));
            report toString(writePointer);
            decode(
                robFull => ROBFullSignal,
                aluRsFull => aluRsFull,
                memRsFull => memRsFull,
                instruction => instruction(31 downto 16),
                immediateValue => instruction(15 downto 0),
                lastStore => lastStoreSignal,
                lastStoreValid => lastStoreValidSignal,
                rsDestName => writePointer,
                robSrc1value => temp1,
                robSrc2value => temp2,
                rsAluValid => ALUissue,
                rsAluInstruction => instructionToALU,
                rsMemValid => MEMissue,
                rsMemInstruction => instructionToMEM,
                robValid => ROBissue,
                robInstruction => ROBentryToBeWritten,
                instQueueEnable => instQueueShiftEnable,
                instQueueMode => instQueueShiftMode,
                r => tempRegisters,
                state => registerState,
                waitingROB => waitingROB,
                currentPc => currentPc,
                PortIn => inPort,
                numberOfElements => instQueueNumberOfElements);


        end if;
        --------------------------------------------------------------------
    end process;
    
end architecture rtl;


