library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
library work;
use work.constants.all;

--length n and width m

entity ReorderBuffer is
    generic ( length: integer := 16;
    		 width: integer  := 49 
    		 );
    port (
        instruction:	in      	std_logic_vector(width-1 downto 0) := (others => '0');
        aluValue:       in          std_logic_vector(width-1 downto 0) := (others => '0');
        aluTag:        in          std_logic_vector(3 downto 0) := (others => '0');
        mememoryValue:  in          std_logic_vector(width-1 downto 0) := (others => '0');
        memoryTag:     in          std_logic_vector(3 downto 0) := (others => '0');
        aluTagValid:    in          std_logic := '0';
        memoryTagValid: in          std_logic := '0';
        flags:          in          std_logic_vector(2 downto 0) := (others => '0'); 
        --memory and alu tags from the CBD
       	---------------------------------------------------------------------
        reset:			in      	std_logic := '0';
        clk:			in      	std_logic := '0';
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
        pcWriteEnableOut:       out        std_logic := '0';
        isPushOut:              out        std_logic := '0';
        isPopOut:               out        std_logic := '0';
        output: 		out     	std_logic_vector(width-1 downto 0) := (others => '0')
    );
end entity ReorderBuffer;

architecture rtl of ReorderBuffer is
	type qType is array(0 to length-1) of std_logic_vector(width-1 downto 0);
    signal q:	 					qType := (others => (others => '0'));
    signal readPointer: 			std_logic_vector(3 downto 0) := (others => '0');
    signal readPointerRotated:		std_logic := '0';
    signal writePointer: 			std_logic_vector(3 downto 0) := (others => '0');
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

    ----------------------------------------------------------------------------
    procedure updateTagAluMemory(variable    entry:             inout       std_logic_vector(width-1 downto 0);
                                 signal    aluValue:          in          std_logic_vector(width-1 downto 0);
                                 signal    aluTag:            in          std_logic_vector(3 downto 0) ;
                                 signal    mememoryValue:      in          std_logic_vector(width-1 downto 0);
                                 signal    memoryTag:         in          std_logic_vector(3 downto 0);
                                 signal    aluTagValid:       in          std_logic;
                                 variable  index:             in          integer;
                                 signal    memoryTagValid:    in          std_logic;
                                 signal    flags:             in          std_logic_vector(2 downto 0);
                                 variable jumpZeroTrue:      out         std_logic;
                                 variable jumpNegativeTrue:  out         std_logic;
                                 variable jumpCarryTrue:     out         std_logic) is
        variable OPcode:    std_logic_vector(4 downto 0);
        variable doneBit:   std_logic;
        variable validBit:  std_logic;
        variable aluTagInt: integer;
        variable memoryTagInt: integer;

        --for store case, I'm sad :(
        variable firstTag: std_logic_vector(3 downto 0);
        variable secondTag: std_logic_vector(3 downto 0);
        begin
            aluTagInt  := to_integer(unsigned(aluTag));
            memoryTagInt := to_integer(unsigned(memoryTag));
            OPcode := getOpCode(entry);

            if (isTypeZero(OPcode) or isTypeOne(OPcode) or OPcode = LDD_OPCODE or OPcode = LDM_OPCODE) then
                if ((aluTagInt = index and aluTagValid = '1') or 
                    (memoryTagInt = index and memoryTagValid = '1')) then --no check on op code just the tag

                    if(aluTagInt = index )then
                        entry(42 downto 27) := aluValue; --value
                    else
                        entry(42 downto 27) := mememoryValue;
                    end if;
                    entry(26) := '1'; --value valid bit
                    validBit := '1';
                    entry(1) := '1'; -- done bit
                    doneBit := '1';
                end if;
            end if;
            
            if (isJmpFamily(OPcode)) then

                if(aluTagInt = WaitingTag(entry) and aluTagValid = '1') then

                    --Decision of jump
                    --If 1, jmp is taken, 
                    --else untaken
                    if(OPcode = JC_OPCODE and isCarrySet(flags)) then 
                        entry(2) := '1'; --Execute/Wait 
                    elsif (OPcode = JZ_OPCODE and isZeroSet(flags)) then
                        entry(2) := '1';
                    elsif (OPcode = JN_OPCODE and isNegativeSet(flags)) then
                        entry(2) := '1';

                    end if;

                end if;

            end if;

            -- note that isJmpFamily doesn't include unconditional jmp
            -- so I added it explicitly
            if (isJmpFamily(OPcode) or OPcode = JMP_OPCODE) then

                if (aluTagValid = '1' or memoryTagValid = '1') then 

                    firstTag := DestinationAddress(entry)(3 downto 0);

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

            if (OPcode = CALL_OPCODE or Opcode = LDD_OPCODE) then 

                if (aluTagValid = '1' or memoryTagValid = '1') then 

                    firstTag := DestinationAddress(entry)(3 downto 0);

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

            if (OPcode = PUSH_OPCODE) then 

                if (aluTagValid = '1' or memoryTagValid = '1') then 

                    firstTag := Value(entry)(3 downto 0);

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

                    firstTag := Value(entry)(3 downto 0);
                    secondTag := DestinationAddress(entry)(3 downto 0);

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
            --------------------------------------------------------------------
            --******************************JUMPS-------------------------------
            --if(checkJMPFamily(OPcode) = '1' and validBit = '1' and doneBit = '1') then--check if any type of jumps except for unconidtional one
            --        if(OPcode = JZ_OPCODE) then --jump zero
            --            if(flags(2) = '1') then --if zero flag is one
            --                jumpZeroTrue := '1';
            --            end if;
            --        elsif (OPcode = JN_OPCODE) then --jump negative
            --            if(flags(1) = '1') then --if zero flag is one
            --                jumpNegativeTrue := '1';
            --            end if;
            --        elsif (OPcode = JC_OPCODE) then --jump carry
            --            if(flags(0) = '1') then --if zero flag is one
            --                jumpCarryTrue := '1';
            --            end if;
            --        end if;
            --    end if;
            --------------------------------------------------------------------
        --OPcode := OpCode(entry => entry);
        end updateTagAluMemory;
    ----------------------------------------------------------------------------
    procedure inputParser(variable    entry:          inout       std_logic_vector(width-1 downto 0);
                          signal    q:			    inout	    qType;
                          signal readPointer: 		in	        std_logic_vector(3 downto 0);
                          signal writePointer: 		in	        std_logic_vector(3 downto 0);
                          signal    ROBEmptySignal:  in          std_logic )is
                    
    --for looping
    variable l: integer;
    variable r: integer;
    variable temp: integer;

    --temp variables
    variable entryOpCode: std_logic_vector(4 downto 0); --opcode from decoding circuit
    variable loopOpCode: std_logic_vector(4 downto 0);  --opcode of an element in reorder buffer

    begin
        entryOpCode := getOpCode(entry=> entry);

        if (isLoopFamily(entryOpCode)) then

            if(isLoad(entryOpCode)) then --case store find load

                l := to_integer(unsigned(readPointer));
                r := to_integer(unsigned(writePointer));
                
                entry(2) := '1'; --Assume execute/wait bit is valid

                while( ROBEmptySignal = '0' ) loop


                    loopOpCode := getOpCode(entry => q(r));

                    if(isStore(opCode => loopOpCode)) then
                        entry(6 downto 3) := std_logic_vector(to_unsigned(r , 4));
                        entry(2) := '0'; --Execute/wait bit is not valid
                        exit;
                    end if;

                    if (l = r) then 
                        exit;
                    end if;

                    if( r = 0 ) then
                        r := 15;
                    else
                        r := r - 1; 
                    end if;

                end loop;

            elsif(isStackFamily(entryOpCode)) then -- jmp case

                l := to_integer(unsigned(readPointer));
                r := to_integer(unsigned(writePointer));
                
                entry(2) := '1'; --Assume execute/wait bit is valid

                while( ROBEmptySignal = '0' ) loop

                    loopOpCode := getOpCode(entry => q(r));

                    if(isStackFamily(opCode => loopOpCode)) then
                        entry(6 downto 3) := std_logic_vector(to_unsigned(r , 4));
                        entry(2) := '0'; --Execute/wait bit is not valid
                        exit;
                    end if;

                    if (l = r) then 
                        exit;
                    end if;

                    if( r = 0 ) then
                        r := 15;
                    else
                        r := r - 1;
                    end if;

                end loop;

            elsif(isJMPFamily(entryOpCode)) then --case jump

                l := to_integer(unsigned(readPointer));
                r := to_integer(unsigned(writePointer));

                entry(2) := '1'; --Assume execute/wait bit is valid

                while(ROBEmptySignal = '0') loop

                    loopOpCode := getOpCode(entry => q(r) );

                    if (entryOpCode = JC_OPCODE) then 

                        if (isArithmeticFamily(loopOpCode) or isShiftFamily(loopOpCode) or
                            loopOpCode = SETC_OPCODE or loopOpCode = CLC_OPCODE) then

                            entry(6 downto 3) := std_logic_vector(to_unsigned(r , 4));
                            entry(2) := '0'; --Execute/wait bit is not valid    
                            exit;

                        end if;

                    else 
                        if (isArithmeticFamily(loopOpCode) or isShiftFamily(loopOpCode)
                            or isLogicalFamily(loopOpCode) ) then

                            entry(6 downto 3) := std_logic_vector(to_unsigned(r , 4));
                            entry(2) := '0'; --Execute/wait bit is not valid    
                            exit;

                        end if;

                    end if;

                    if (l = r) then 
                        exit;
                    end if;

                    if( r = 0 ) then
                        r := 15;
                    else
                        r := r - 1;
                    end if;

                end loop;

            end if;

        end if;          

    end inputParser;

    procedure commitInstruction(variable    entry:                  inout   std_logic_vector(width-1 downto 0);
                                signal      destRegister:    out     std_logic_vector(2 downto 0);
                                variable    registerWriteEnable:    out     std_logic;
                                signal      outputValue:            out     std_logic_vector(15 downto 0);
                                signal      address:                out     std_logic_vector(15 downto 0);
                                variable    memoryWriteEnable:      out     std_logic;
                                variable    portWriteEnable:        out     std_logic;
                                variable    pcWriteEnable:          out     std_logic;
                                variable    isPush:                 out     std_logic;
                                variable    isPop:                  out     std_logic;
                                variable    commited:               out     boolean) is
    
    variable entryOpCode: std_logic_vector(4 downto 0);

    begin
        entryOpCode := getOpCode(entry);

        registerWriteEnable := '0';
        memoryWriteEnable := '0';
        portWriteEnable := '0';
        pcWriteEnable := '0';
        isPush := '0';
        isPop := '0';
        commited := false;

        if (isStackFamily(entryOpCode) or isLoad(entryOpCode) or entryOpCode = STD_OPCODE) then
            --Memory instructions

            if (entryOpCode = POP_OPCODE) then
                if (ValueValid(entry) = '1') then 
                    commited := true;
                    destRegister <= DestinationRegister(entry);
                    registerWriteEnable := '1';
                    isPop := '1';
                end if;

            --elsif () then

            end if;

        elsif (isJmpFamily(entryOpCode) or entryOpCode = JMP_OPCODE) then --jumps
            if (DestinationAddressValid(entry) = '1') then
                commited := true;
                if (Execute(entry) = '1') then --branch taken
                    outputValue <= DestinationAddress(entry);
                    pcWriteEnable := '1';
                end if;
            end if;

        elsif (entryOpCode = NOP_OPCODE) then --no commit
            commited := true; 

        elsif (entryOpCode = OUT_OPCODE) then
            if(ValueValid(entry) = '1') then 
                commited := true;
                outputValue <= Value(entry);
                portWriteEnable := '1';
            end if;

        else 
            if(ValueValid(entry) = '1') then 
                commited := true;
                outputValue <= Value(entry);
                registerWriteEnable := '1';
                destRegister <= DestinationRegister(entry);
            end if;
        end if;
    end commitInstruction;

begin
    output <= q(to_integer(unsigned(readPointer)));
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
    pcValueOut <= outputValueSignal;
    isPushOut <= isPushSignal;
    isPopOut <= isPopSignal;

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
    --            r := 15;
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
    
    process (clk,reset)
        variable    destinationRegisterV:         std_logic_vector(2 downto 0);
        variable    registerWriteEnableV:         std_logic;
        variable    outputValueV:                 std_logic_vector(15 downto 0);
        variable    address:                      std_logic_vector(15 downto 0);
        variable    memoryWriteEnableV:           std_logic;
        variable    portWriteEnableV:             std_logic;
        variable    pcWriteEnableV:               std_logic;
        variable    isPushV:                      std_logic;
        variable    isPopV:                       std_logic;
        variable    commitedV:                    boolean;
        variable    inp:                          std_logic_vector(width-1 downto 0);
    begin
        inp := q(to_integer(unsigned(readPointer)));
        if (reset = '1') then 
            q <= (others => (others => '0'));
            readPointer <= (others => '0');
            ReadPointerRotated <= '0';
            writePointer <= (others => '0');
            writePointerRotated <= '0';
            ROBFullSignal <= '0';
            --ROBEmptySignal <= '1';

        elsif(clk'event and clk = '1') then
            --inputParser(inp,q,readPointer,writePointer,ROBEmptySignal);
            --q(to_integer(unsigned(writePointer))) <= inp;
            --writePointer <= writePointer + 1;
            --if (pcWriteEnableSignal = '1') then
            --    pcWriteEnableSignal <= '0';
            --end if;
            null;

        elsif (clk'event and clk = '0') then
            if(ROBEmptySignal /= '1')then
                report "Plz";
                commitInstruction(
                    inp,
                    destRegisterOut,
                    registerWriteEnableV,
                    outputValueSignal,
                    addressOut,
                    memoryWriteEnableV,
                    portWriteEnableV,
                    pcWriteEnableV,
                    isPushV,
                    isPopV,
                    commitedV
                    );
                
                registerWriteEnableSignal <= registerWriteEnableV;
                memoryWriteEnableSignal <= memoryWriteEnableV;
                portWriteEnableSignal <= portWriteEnableV;
                pcWriteEnableSignal <= pcWriteEnableV;
                isPushSignal <= isPushV;
                isPopSignal <= isPopV;
                if (commitedV) then 
                    readPointer <= readPointer + 1;
                    --Todo rotate

                end if;
                if(pcWriteEnableV = '1') then 
                    report "God Please Help me";
                    q <= (others => (others => '0'));
                    readPointer <= (others => '0');
                    ReadPointerRotated <= '0';
                    writePointer <= (others => '0');
                    writePointerRotated <= '0';
                    ROBFullSignal <= '0';
                    --pcValueSignal <= outputValueSignal;
                    --ROBEmptySignal <= '1';
                end if;
            end if;
            

        end if;
    end process;
    
end architecture rtl;


