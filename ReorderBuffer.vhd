library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.constants.all;

--length n and width m

entity ReorderBuffer is
    generic ( length: integer := 16;
    		 width: integer  := 48 
    		 );
    port (
        instruction:	in      	std_logic_vector(width-1 downto 0) := (others => '0');
        aluValue:       in          std_logic_vector(width-1 downto 0) := (others => '0');
        aluTag:        in          std_logic_vector(3 downto 0) := (others => '0');
        mememoryValue:  in          std_logic_vector(width-1 downto 0) := (others => '0');
        memoryTag:     in          std_logic_vector(3 downto 0) := (others => '0');
        aluTagValid:    in          std_logic := '0';
        memoryTagValid: in          std_logic := '0';
        flags:          in          std_logic_vector(2 downto 0); 
        --memory and alu tags from the CBD
       	---------------------------------------------------------------------
        reset:			in      	std_logic := '0';
        clk:			in      	std_logic := '0';
        ROBFull:		out 		std_logic := '0';
        ROBEmpty:		out 		std_logic := '0';
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
    -----------------------------Helper Functions-------------------------------
    function getOpCode(entry : std_logic_vector(width-1 downto 0) := (others => '0')) 	
    					return  std_logic_vector is
    begin
        return entry(47 downto 43);
    end getOpCode;
    ----------------------------------------------------------------------------
    function Value(entry : std_logic_vector(width-1 downto 0) := (others => '0')) 	
    					return  std_logic_vector is
    begin
        return entry(42 downto 27);
    end Value;
    ----------------------------------------------------------------------------
    function ValueValid(entry : std_logic_vector(width-1 downto 0) := (others => '0')) 	
    					return  std_logic is
    begin
        return entry(26);
    end ValueValid;
    ----------------------------------------------------------------------------
    function DestinationAddress(entry : std_logic_vector(width-1 downto 0) := (others => '0')) 	
    					return  std_logic_vector is
    begin
        return entry(25 downto 10);
    end DestinationAddress;
    ----------------------------------------------------------------------------
    function DestinationRegister(entry : std_logic_vector(width-1 downto 0) := (others => '0')) 	
    					return  std_logic_vector is
    begin
        return entry(9 downto 7);
    end DestinationRegister;
    ----------------------------------------------------------------------------
    function WaitingTag(entry : std_logic_vector(width-1 downto 0) := (others => '0')) 	
    					return  std_logic_vector is
    begin
        return entry(6 downto 3);
    end WaitingTag;
    ----------------------------------------------------------------------------
    function Execute(entry : std_logic_vector(width-1 downto 0) := (others => '0')) 	
    					return  std_logic is
    begin
        return entry(2);
    end Execute;
    ----------------------------------------------------------------------------
    function Done(entry : std_logic_vector(width-1 downto 0) := (others => '0')) 	
    					return  std_logic is
    begin
        return entry(1);
    end Done;
    ----------------------------------------------------------------------------
    procedure setDone(signal entry:    inout   std_logic_vector(width-1 downto 0);
                   signal OPcode:   in      std_logic_vector(4 downto 0);
                   signal valueValid:   inout  std_logic) is
    begin
        if(OPcode(0) = '1' and OPcode(1)= '1' and OPcode(2)= '1' and OPcode(3)= '1' and OPcode(4)= '1')then
            entry(1) <= '1'; --case NOP done bit is always one
        elsif( (OPcode(4) = '0' and OPcode(3) = '1') or ( OPcode(4) = '0' and OPcode(3) = '0' and OPcode(2) = '0' and OPcode(1) = '1' ) or ( ( OPcode(4) = '1' and OPcode(3) = '0') and(( OPcode(2) = '1' and OPcode(1) = '1'  and  OPcode(0) = '1') or ( OPcode(2) = '0' and OPcode(1) = '1'  and  OPcode(0) = '1') or ( OPcode(2) = '0' and OPcode(1) = '0'  and  OPcode(0) = '1')) ))then
            entry(1) <= valueValid; --case when the op goes to the alu and outputs a value so we check the valid value bit
        end if;
        --entry(0) <= '1' when OPcode(0) = '1'
        --    else '0';-- and( OPcode(2) )= '0' and( OPcode(3) )= '0' and ( OPcode(4) )= '0' );
    end setDone;
    ----------------------------------------------------------------------------
    function isStackFamily(opCode:   std_logic_vector(4 downto 0))
                                return boolean is
    begin
        if(opCode = PUSH_OPCODE or opCode = POP_OPCODE or opCode = RET_OPCODE or opCode = RTI_OPCODE or opCode = CALL_OPCODE) then
            return true;
        else
            return false;
        end if;
    end isStackFamily;
    ----------------------------------------------------------------------------
    function isJmpFamily(opCode:   std_logic_vector(4 downto 0))
                                return boolean is
    begin
        if(opCode = JC_OPCODE or opCode = JN_OPCODE or opCode = JZ_OPCODE) then
            return true;
        else
            return false;
        end if;
    end isJmpFamily;
    ----------------------------------------------------------------------------
    function isArithmeticFamily(opCode:   std_logic_vector(4 downto 0))
                                return boolean is
    begin
        if(opCode = ADD_OPCODE or opCode = SUB_OPCODE) then
            return true;
        else
            return false;
        end if;
    end isArithmeticFamily;
    ----------------------------------------------------------------------------
    function isLogicalFamily(opCode:   std_logic_vector(4 downto 0))
                                return boolean is
    begin
        if(opCode = NOT_OPCODE or opCode = AND_OPCODE or opCode = OR_OPCODE) then
            return true;
        else
            return false;
        end if;
    end isLogicalFamily;
    ----------------------------------------------------------------------------
    function isShiftFamily(opCode:   std_logic_vector(4 downto 0))
                                return boolean is
    begin
        if(opCode = SHL_OPCODE or opCode = SHR_OPCODE) then
            return true;
        else
            return false;
        end if;
    end isShiftFamily;
    ----------------------------------------------------------------------------
    function isLoad(opCode:   std_logic_vector(4 downto 0))
                                return boolean is
    begin
        if(opCode = LDD_OPCODE) then
            return true;
        else
            return false;
        end if;
    end isLoad;
    ----------------------------------------------------------------------------
    function isStore(opCode:   std_logic_vector(4 downto 0))
                                return boolean is
    begin
        if(opCode = STD_OPCODE) then
            return true;
        else
            return false;
        end if;
    end isStore;
    ----------------------------------------------------------------------------
    function isTypeOne(opCode:   std_logic_vector(4 downto 0))
                                return boolean is
    begin
        if(opCode = MOV_OPCODE or opCode = AND_OPCODE or opCode = OR_OPCODE or 
           opCode = ADD_OPCODE or opCode = SUB_OPCODE or opCode = SHL_OPCODE or
           opCode = SHR_OPCODE) then
            return true;
        else
            return false;
        end if;
    end isTypeOne;
    ----------------------------------------------------------------------------
    function isTypeZero(opCode:   std_logic_vector(4 downto 0))
                                return boolean is
    begin
        if(opCode = NOP_OPCODE or opCode = NOT_OPCODE or opCode = SETC_OPCODE or 
           opCode = CLC_OPCODE or opCode = INC_OPCODE or opCode = DEC_OPCODE or
           opCode = IN_OPCODE  or opCode = OUT_OPCODE) then
            return true;
        else
            return false;
        end if;
    end isTypeZero;
    ----------------------------------------------------------------------------
    function isLoopFamily(opCode:   std_logic_vector(4 downto 0))
                                return boolean is
    begin
        if(isStackFamily(opCode) or isJMPFamily(opCode) or isLoad(opCode)) then
            return true;
        else
            return false;
        end if;
    end isLoopFamily;
    ----------------------------------------------------------------------------
    procedure updateTagAluMemory(variable    entry:             inout       std_logic_vector(width-1 downto 0);
                                 signal    aluValue:          in          std_logic_vector(width-1 downto 0);
                                 signal    aluTag:            in          std_logic_vector(3 downto 0) ;
                                 signal    mememoryValue:      in          std_logic_vector(width-1 downto 0);
                                 signal    memoryTag:         in          std_logic_vector(3 downto 0);
                                 signal    aluTagValid:       in          std_logic;
                                 variable  index:             in          integer;
                                 signal    memoryTagValid:    in          std_logic;
                                 signal    flags:             in          std_logic_vector(3 downto 0);
                                 variable jumpZeroTrue:      out         std_logic;
                                 variable jumpNegativeTrue:  out         std_logic;
                                 variable jumpCarryTrue:     out         std_logic) is
        variable OPcode:    std_logic_vector(4 downto 0);
        variable doneBit:   std_logic;
        variable validBit:  std_logic;
        variable aluTagInt: integer;
        variable memoryTagInt: integer;
        begin
            aluTagInt  := to_integer(unsigned(aluTag));
            memoryTagInt := to_integer(unsigned(memoryTag));
            OPcode := getOpCode(entry);

            if (isTypeZero(OPcode)) then
                if ((aluTagInt = index and aluTagValid = '1') or 
                    (memoryTagInt = index and memoryTagValid = '1')) then --no check on op code just the tag

                    if(aluTagInt = index )then
                        entry(42 downto 27) := aluValue;
                    else
                        entry(42 downto 27) := mememoryValue;
                    end if;
                    entry(26) := '1'; --value valid bit
                    validBit := '1';
                    entry(1) := '1'; -- done bit
                    doneBit := '1';
                end if;
            end if;

            if (isTypeOne(OPcode)) then

                if ((aluTagInt = index and aluTagValid = '1') or 
                    (memoryTagInt = index and memoryTagValid = '1')) then --no check on op code just the tag

                    if(aluTagInt = index )then
                        entry(42 downto 27) := aluValue;
                    else
                        entry(42 downto 27) := mememoryValue;
                    end if;
                    entry(26) := '1'; --value valid bit
                    validBit := '1';
                    entry(1) := '1'; -- done bit
                    doneBit := '1';
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

                        if (isArithmeticFamily(loopOpCode) or isShiftFamily(loopOpCode)) then

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



begin
    output <= q(to_integer(unsigned(readPointer)));
    opCodeSignal <= getOpCode(q(to_integer(unsigned(readPointer))));
    --ROBFullSignal <= '1' when tail = head
    --				else '0';
    ROBFull <= ROBFullSignal;

    ROBEmptySignal <= '1' when (readPointer = writePointer and ROBFullSignal = '0')
                    else '0';

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
    
    process (clk)
        variable inp:     std_logic_vector(width-1 downto 0);
    begin
        inp := instruction;
        if(clk'event and clk = '1') then
            inputParser(inp,q,readPointer,writePointer,ROBEmptySignal);
            q(to_integer(unsigned(writePointer))) <= inp;
            writePointer <= writePointer + 1;
        end if;

    end process;
    
end architecture rtl;


