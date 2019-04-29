library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

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
    function OpCode(entry : std_logic_vector(width-1 downto 0) := (others => '0')) 	
    					return  std_logic_vector is
    begin
        return entry(47 downto 43);
    end OpCode;
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
    
    procedure updateTagAluMemory(signal    entry:             inout       std_logic_vector(width-1 downto 0);
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
            if (aluTagInt = index or memoryTagInt = index) then --no check on op code just the tag
                if(aluTagInt = index)then
                    entry(42 downto 27) <= aluValue;
                else 
                    entry(42 downto 27) <= mememoryValue;
                end if;
                entry(26) <= '1'; --value valid bit
                validBit := '1';
                entry(1) <= '1'; -- done bit
                doneBit := '1';
                if(OPcode(4) ='1' and OPcode(3) = '1' and OPcode(2) = '1' and OPcode(1) /= '1' and OPcode(0) /= '1' and validBit = '1' and doneBit = '1') then--check if any type of jumos except for unconidtional one
                    if(OPcode(1) = '0' and OPcode(0) = '0') then --jump zero
                        if(flags(2) = '1') then --if zero flag is one
                            jumpZeroTrue := '1';
                        end if;
                    elsif (OPcode(1) = '0' and OPcode(0) = '1') then --jump negative
                        if(flags(1) = '1') then --if zero flag is one
                            jumpNegativeTrue := '1';
                        end if;
                    elsif (OPcode(1) = '1' and OPcode(0) = '0') then --jump carry
                        if(flags(0) = '1') then --if zero flag is one
                            jumpCarryTrue := '1';
                        end if;
                    end if;
                end if;
                  --done bit
            end if;
        --OPcode := OpCode(entry => entry);
        end updateTagAluMemory;

begin
    output <= q(to_integer(unsigned(readPointer)));
    opCodeSignal <= OpCode(q(to_integer(unsigned(readPointer))));
    --ROBFullSignal <= '1' when tail = head
    --				else '0';
    ROBFull <= ROBFullSignal;

    process(clk,reset)
    variable l: integer;
    variable r: integer;
    variable temp: integer := 1;
    begin

        l := to_integer(unsigned(readPointer));
        r := to_integer(unsigned(writePointer));
        temp := to_integer(unsigned'('0' & ROBFullSignal));
        report integer'image(l);
        report integer'image(r);

        while( (l /= r) or temp = 1 ) loop
            if(temp = 1 and r = l+1) then
                temp := 0;
            end if;

            --setDone(q(l)); 
            report "L=";   
            report integer'image(l);
            l := l + 1; 
            if( l = 16 ) then
                l := 0;
            end if;
        end loop;
    	if(reset = '1') then
    		q <= (others => (others => '0'));
    		readPointer <= (others => '0');
    		ReadPointerRotated <= '0';
    		writePointer <= (others => '0');
    		writePointerRotated <= '0';
    		ROBFullSignal <= '0';
    		ROBEmptySignal <= '1';

       	elsif (clk'event and clk = '1') then
       		--read from decoding circuit
       		if (ROBFullSignal = '0') then
       			q(to_integer(unsigned(writePointer))) <= instruction;
       			writePointer <= writePointer + 1;

       			if (writePointer = length-1) then
       				writePointerRotated <= not writePointerRotated;
       			end if;

       			if (writePointer + 1 = readPointer) then
       				ROBFullSignal <= '1';
       			else
       				ROBFullSignal <= '0';
       			end if;

       		end if;

       --elsif (clk'event and clk = '1') then
       		--some thing to be done

      	end if;
    end process;
    
    
end architecture rtl;


