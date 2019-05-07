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
        destRegisterOut:    out     std_logic_vector(2 downto 0);
        registerWriteEnableOut:    out         std_logic := '0';
        outputValueOut:            out     std_logic_vector(15 downto 0);
        addressOut:                out     std_logic_vector(15 downto 0);
        memoryWriteEnableOut:   out        std_logic := '0';
        portWriteEnableOut:     out        std_logic := '0';
        portReadEnableOut:      out        std_logic := '0';
        isPushOut:              out        std_logic := '0';
        isPopOut:               out        std_logic := '0';
        flagsOut:               out        std_logic_vector (2 downto 0) := (others => '0');
        tagToMemory:            out        std_logic_vector (2 downto 0) := (others => '0');
        isRet:                  out        std_logic := '0';
        --may be removed when decoding circuit is in @Ahmed
        lastStore:              out        std_logic_vector(2 downto 0) := (others => '0'); 
        lastStoreValid:         out        std_logic := '0';
        ------------------------------------------------------------------------
        --Decoding signals out
        firstSourceRegister:          out        std_logic_vector(2 downto 0) := (others => '0');
        secondSourceRegister:         out        std_logic_vector(2 downto 0) := (others => '0');
        firstSourceValue:             in         std_logic_vector(15 downto 0) := (others => '0');
        secondSourceValue:             in         std_logic_vector(15 downto 0) := (others => '0');
        instQueueShiftEnable:           out        std_logic := '0';
        instQueueShiftMode:           out        std_logic := '0';
        instructionToALU: 		    out     	std_logic_vector(41 downto 0) := (others => '0');
        ALUissue:                   out         std_logic := '0'
        --------------------------------------------------------------------------------

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
    signal firstSourceValueDecoded:           std_logic_vector(15 downto 0) := (others => '0');
    signal secondSourceValueDecoded:           std_logic_vector(15 downto 0) := (others => '0');
    signal ROBEntry:                     std_logic_vector(width-1 downto 0);
    signal firstSourceInt:                        integer := 0;
    signal secondSourceInt:                       integer := 0;
    signal valueValidDecoded:                   std_logic := '0';

    signal ROBentryToBeWritten:                    std_logic_vector(width-1 downto 0) := (others => '0');
    signal ALUentryToBeWritten:                    std_logic_vector(41 downto 0) := (others => '0');

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
                elsif (ValueValid(entry) = '1') then 
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
    signal fakes:           std_logic := '0';
begin
    --outputRS <= q(to_integer(unsigned(readPointer)));
    opCodeSignal <= getOpCode(q(to_integer(unsigned(readPointer))));
    --ROBFullSignal <= '1' when tail = head
    --				else '0';
    ROBFull <= ROBFullSignal;

    ROBEmptySignal <= '1' when (readPointer = writePointer and ROBFullSignal = '0')
                    else '0';

    outputValueOut <= outputValueSignal;
    registerWriteEnableOut <= registerWriteEnableSignal;
    memoryWriteEnableOut <= memoryWriteEnableSignal;
    portWriteEnableOut <= portWriteEnableSignal;
    pcWriteOut <= pcWriteEnableSignal;
    lastStore <= lastStoreSignal;
    lastStoreValid <= lastStoreValidSignal;
    --pcValueOut <= pcValueOutSignal;
    isPushOut <= isPushSignal;
    isPopOut <= isPopSignal;

    ----------------------------------------------------------------------------
    --Decoding
    --firstSourceRegister <= instruction(26 downto 24);
    --secondSourceRegister <= instruction(23 downto 21);

    --firstSourceInt <= to_integer(unsigned(instruction(26 downto 24)));
    --secondSourceInt <= to_integer(unsigned(instruction(23 downto 21)));

    --firstSourceValueDecoded <= firstSourceValue when registerState(firstSourceInt) = AVAILABLE
    --                        else q(to_integer(unsigned(waitingROB(firstSourceInt))))(42 downto 27) when registerState(firstSourceInt) = FLIGHT
    --                        else waitingROB(firstSourceInt) & (11 downto 0 => '0') when registerState(firstSourceInt) = INEXECUTE;


    --secondSourceValueDecoded <= secondSourceValue when registerState(secondSourceInt) = AVAILABLE
    --                        else q(to_integer(unsigned(waitingROB(secondSourceInt))))(42 downto 27) when registerState(secondSourceInt) = FLIGHT
    --                        else waitingROB(secondSourceInt) & (11 downto 0 => '0') when registerState(secondSourceInt) = INEXECUTE;


    ----NOP
    --ROBEntry(48) <= '1'
    ----Opcode
    --ROBEntry(47 downto 43) <= instruction(31 downto 27);
    ----Value bit
    --ROBEntry(42 downto 27) <= inPort when instruction(31 downto 27) = IN_OPCODE
    --                    else  


    ----------------------------------------------------------------------------
    --process(clk,reset)
    --variable l: integer;
    --variable r: integer;
    
    --begin

    --    l := to_integer(unsigned(readPointer));
    --    r := to_integer(unsigned(writePointer-1));
       
    --    while(ROBEmptySignal = '0') loop
    --        --setDone(q(l)); 
    --        report "R=";   
    --        report integer'image(r);

    --        if (l=r) then
    --            exit;
    --        end if;

    --        if( r = 0 ) then
    --            r := 7;
    --        else
    --            r := r - 1;
    --        end if;

           

    --    end loop;

    --	if(reset = '1') then
    --		q <= (others => (others => '0'));
    --		readPointer <= (others => '0');
    --		ReadPointerRotated <= '0';
    --		writePointer <= (others => '0');
    --		writePointerRotated <= '0';
    --		ROBFullSignal <= '0';
    --		--ROBEmptySignal <= '1';

    --   	elsif (clk'event and clk = '1') then
    --   		--read from decoding circuit
    --   		if (ROBFullSignal = '0') then
    --   			q(to_integer(unsigned(writePointer))) <= instruction;
    --   			writePointer <= writePointer + 1;

    --   			if (writePointer = length-1) then
    --   				writePointerRotated <= not writePointerRotated;
    --   			end if;

    --   			if (writePointer + 1 = readPointer) then
    --   				ROBFullSignal <= '1';
    --   			else
    --   				ROBFullSignal <= '0';
    --   			end if;

    --   		end if;

    --   --elsif (clk'event and clk = '1') then
    --   		--some thing to be done

    --  	end if;
    --end process;
    

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

        variable    destRegisterV:                std_logic_vector(2 downto 0);
        variable    destRegisterGotValueV:        boolean := false;
        variable    lastStoreV:                   std_logic_vector(2 downto 0);
        variable    lastStoreValidV:              std_logic := '0';
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
            portReadEnableOut <= portReadEnableV;
            isPushSignal <= isPushV;
            isPopSignal <= isPopV;
            flagsOut <= flagsOutV;

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
                portReadEnableOut <= portReadEnableV;
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
                        tempRegisters(to_integer(unsigned(destRegisterV))) <= mememoryValue;
                        outputValueSignal <= mememoryValue;

                        if (registerState(to_integer(unsigned(destinationRegisterV))) = INEXECUTE
                            and waitingROB(to_integer(unsigned(destinationRegisterV))) = readPointer) then 

                                registerState(to_integer(unsigned(destinationRegisterV))) <= AVAILABLE;

                        end if;

                    elsif(isPopV = '0')then
                        tempRegisters(to_integer(unsigned(destRegisterV))) <= outputValueV;
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
        elsif(fakes = '1' and instQueueWritten'event and instQueueWritten = '1') then

            --May god be with you;
            report "Ramadan Kareem";

            ROBentryToBeWritten <= (others => '0');

            ROBentryToBeWritten(47 downto 43) <= "01000";

            ROBentryToBeWritten(9 downto 7) <= "001";

            ALUentryToBeWritten <= (others => '0');

            --ALUentryToBeWritten()
            instructionToALU <= "010000000000000000001100010000000000011001";

            ALUissue <= '1';


        end if;
        --------------------------------------------------------------------
        if(reset = '0') then 
            fakes <= '1';
        end if;
    end process;
    
end architecture rtl;


