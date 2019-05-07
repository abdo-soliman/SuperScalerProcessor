library IEEE;
USE IEEE.std_logic_1164.all;
package constants is    

--------------- PC Controller CONSTANTS ----------------------
constant PCCONTROLLER_NOP:      std_logic_vector(1 downto 0)  := "00";
constant PCCONTROLLER_NORMAL:   std_logic_vector(1 downto 0)  := "01";
constant PCCONTROLLER_ROB:      std_logic_vector(1 downto 0)  := "10";
constant SP_START:              std_logic_vector(15 downto 0) := (others => '1');
constant PORT_NUMBER:           std_logic_vector(2 downto 0) := "111";

--------------- OPCODES ----------------------
constant NOP_OPCODE:    std_logic_vector(4 downto 0) := "00000";
constant SETC_OPCODE:   std_logic_vector(4 downto 0) := "00010";
constant CLC_OPCODE:    std_logic_vector(4 downto 0) := "00011";
constant INC_OPCODE:    std_logic_vector(4 downto 0) := "00110";
constant DEC_OPCODE:    std_logic_vector(4 downto 0) := "00101";
constant IN_OPCODE:     std_logic_vector(4 downto 0) := "00110";
constant OUT_OPCODE:    std_logic_vector(4 downto 0) := "00111";
constant NOT_OPCODE:    std_logic_vector(4 downto 0) := "00001";
constant MOV_OPCODE:    std_logic_vector(4 downto 0) := "01000";
constant ADD_OPCODE:    std_logic_vector(4 downto 0) := "01100";
constant SUB_OPCODE:    std_logic_vector(4 downto 0) := "01101";
constant AND_OPCODE:    std_logic_vector(4 downto 0) := "01010";
constant OR_OPCODE:     std_logic_vector(4 downto 0) := "01011";
constant SHR_OPCODE:    std_logic_vector(4 downto 0) := "01111";
constant SHL_OPCODE:    std_logic_vector(4 downto 0) := "01110";
constant PUSH_OPCODE:   std_logic_vector(4 downto 0) := "10000";
constant POP_OPCODE:    std_logic_vector(4 downto 0) := "10001";
constant LDD_OPCODE:    std_logic_vector(4 downto 0) := "10010";
constant STD_OPCODE:    std_logic_vector(4 downto 0) := "10011";
constant LDM_OPCODE:    std_logic_vector(4 downto 0) := "10110";
constant CALL_OPCODE:   std_logic_vector(4 downto 0) := "11000";
constant RET_OPCODE:    std_logic_vector(4 downto 0) := "11001";
constant RTI_OPCODE:    std_logic_vector(4 downto 0) := "11010"; --I fixed this from RTL @Ahmed
constant INT_OPCODE:    std_logic_vector(4 downto 0) := "11011"; --I added this @Ahmed
constant JZ_OPCODE:     std_logic_vector(4 downto 0) := "11100";
constant JN_OPCODE:     std_logic_vector(4 downto 0) := "11101";
constant JC_OPCODE:     std_logic_vector(4 downto 0) := "11110";
constant JMP_OPCODE:    std_logic_vector(4 downto 0) := "11111";

------------------------ALU Opcodes---------------------------------------------
constant MOV_ALU_CODE:  std_logic_vector(4 downto 0) := "00000";
constant SUB_ALU_CODE:  std_logic_vector(4 downto 0) := "00001";
constant DEC_ALU_CODE:  std_logic_vector(4 downto 0) := "00010";
constant INC_ALU_CODE:  std_logic_vector(4 downto 0) := "00011";
constant ADD_ALU_CODE:  std_logic_vector(4 downto 0) := "00100";
constant SETC_ALU_CODE: std_logic_vector(4 downto 0) := "00101";
constant CLC_ALU_CODE:  std_logic_vector(4 downto 0) := "00110";
constant AND_ALU_CODE:  std_logic_vector(4 downto 0) := "01000";
constant OR_ALU_CODE:   std_logic_vector(4 downto 0) := "01001";
constant NOT_ALU_CODE:  std_logic_vector(4 downto 0) := "01010";
constant SHL_ALU_CODE:  std_logic_vector(4 downto 0) := "10000";
constant SHR_ALU_CODE:  std_logic_vector(4 downto 0) := "10001";
--------------------------------------------------------------------------------
constant CONST_WIDTH: integer := 49; 

--------------------------------------------------------------------------------
function Busy(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0'))    return  std_logic;
----------------------------------------------------------------------------
function getOpCode(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	return  std_logic_vector;
----------------------------------------------------------------------------
function Value(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	return  std_logic_vector;
----------------------------------------------------------------------------
function ValueTag(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0'))     return  std_logic_vector;
----------------------------------------------------------------------------
function ValueValid(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	return  std_logic;
----------------------------------------------------------------------------
function DestinationAddress(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	return  std_logic_vector;
----------------------------------------------------------------------------
function DestinationAddressTag(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0'))    return  std_logic_vector;
----------------------------------------------------------------------------
function DestinationRegister(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	return  std_logic_vector;
----------------------------------------------------------------------------
function WaitingTag(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	return  std_logic_vector;
----------------------------------------------------------------------------
function Execute(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	return  std_logic;
----------------------------------------------------------------------------
function Done(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	return  std_logic;
----------------------------------------------------------------------------
function DestinationAddressValid(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0'))   return  std_logic;
----------------------------------------------------------------------------
function isZeroSet(flags : std_logic_vector(2 downto 0) := (others => '0')) return  boolean;
    ----------------------------------------------------------------------------
function isNegativeSet(flags : std_logic_vector(2 downto 0) := (others => '0')) return  boolean;
    ----------------------------------------------------------------------------
function isCarrySet(flags : std_logic_vector(2 downto 0) := (others => '0')) return  boolean;
----------------------------------------------------------------------------
function isStackFamily(opCode:   std_logic_vector(4 downto 0)) return boolean;
----------------------------------------------------------------------------
function isJmpFamily(opCode:   std_logic_vector(4 downto 0)) return boolean;
----------------------------------------------------------------------------
function isArithmeticFamily(opCode:   std_logic_vector(4 downto 0)) return boolean;
----------------------------------------------------------------------------
function isLogicalFamily(opCode:   std_logic_vector(4 downto 0)) return boolean;
----------------------------------------------------------------------------
function isShiftFamily(opCode:   std_logic_vector(4 downto 0)) return boolean;
--------------------------------------------------------------------------------
function affectsFlags(opCode:   std_logic_vector(4 downto 0)) return boolean;
----------------------------------------------------------------------------
function isLoad(opCode:   std_logic_vector(4 downto 0)) return boolean;
----------------------------------------------------------------------------
function isStore(opCode:   std_logic_vector(4 downto 0)) return boolean;
----------------------------------------------------------------------------
function isTypeOne(opCode:   std_logic_vector(4 downto 0)) return boolean;
----------------------------------------------------------------------------
function isTypeZero(opCode:   std_logic_vector(4 downto 0)) return boolean;
----------------------------------------------------------------------------
function isTypeThree(opCode:   std_logic_vector(4 downto 0)) return boolean;
----------------------------------------------------------------------------
function isLoopFamily(opCode:   std_logic_vector(4 downto 0)) return boolean;
--------------------------------------------------------------------------------
function toString ( a: std_logic_vector) return string;
--------------------------------------------------------------------------------
function isAlueRSinstruction(opCode:   std_logic_vector(4 downto 0)) return boolean;
--------------------------------------------------------------------------------
function writesBack(opCode:   std_logic_vector(4 downto 0)) return boolean;
--------------------------------------------------------------------------------
end package constants;
-----------------------------Helper Functions-------------------------------
package body constants is 

function Busy(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0'))   
                    return  std_logic is
begin
    return entry(48);
end Busy;
----------------------------------------------------------------------------
function getOpCode(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	
					return  std_logic_vector is
begin
    return entry(47 downto 43);
end getOpCode;
----------------------------------------------------------------------------
function Value(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	
					return  std_logic_vector is
begin
    return entry(42 downto 27);
end Value;
----------------------------------------------------------------------------
function ValueTag(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0'))     
                    return  std_logic_vector is
begin
    return entry(42 downto 40);
end ValueTag;
----------------------------------------------------------------------------
function ValueValid(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	
					return  std_logic is
begin
    return entry(26);
end ValueValid;
----------------------------------------------------------------------------
function DestinationAddress(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	
					return  std_logic_vector is
begin
    return entry(25 downto 10);
end DestinationAddress;
----------------------------------------------------------------------------
function DestinationAddressTag(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0'))    
                    return  std_logic_vector is
begin
    return entry(25 downto 23);
end DestinationAddressTag;
----------------------------------------------------------------------------
function DestinationRegister(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	
					return  std_logic_vector is
begin
    return entry(9 downto 7);
end DestinationRegister;
----------------------------------------------------------------------------
function WaitingTag(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	
					return  std_logic_vector is
begin
    return entry(6 downto 4);
end WaitingTag;
----------------------------------------------------------------------------
function Execute(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	
					return  std_logic is
begin
    return entry(2);
end Execute;
----------------------------------------------------------------------------
function Done(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0')) 	
					return  std_logic is
begin
    return entry(1);
end Done;
----------------------------------------------------------------------------
function DestinationAddressValid(entry : std_logic_vector(CONST_WIDTH-1 downto 0) := (others => '0'))  
                    return  std_logic is
begin
    return entry(0);
end DestinationAddressValid;
----------------------------------------------------------------------------
function isZeroSet(flags : std_logic_vector(2 downto 0) := (others => '0'))    
                    return  boolean is
begin
    if (flags(0) = '1') then
        return true;
    else
        return false;
    end if;

end isZeroSet;
--------------------------------------------------------------------------------
function isNegativeSet(flags : std_logic_vector(2 downto 0) := (others => '0'))    
                    return  boolean is
begin
    if (flags(1) = '1') then
        return true;
    else
        return false;
    end if;
    
end isNegativeSet;
--------------------------------------------------------------------------------
function isCarrySet(flags : std_logic_vector(2 downto 0) := (others => '0'))    
                    return  boolean is
begin
    if (flags(2) = '1') then
        return true;
    else
        return false;
    end if;
    
end isCarrySet;

----------------------------------------------------------------------------
procedure setDone(signal entry:    inout   std_logic_vector(CONST_WIDTH-1 downto 0);
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
    if(opCode = PUSH_OPCODE or opCode = POP_OPCODE or opCode = RET_OPCODE or opCode = RTI_OPCODE or opCode = CALL_OPCODE or opCode = INT_OPCODE) then
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
function affectsFlags(opCode:   std_logic_vector(4 downto 0))
                            return boolean is
begin
    if(isArithmeticFamily(opCode) or isShiftFamily(opCode) or isLogicalFamily(opCode) or
       opCode = SETC_OPCODE or opCode = CLC_OPCODE) then
        return true;
    else
        return false;
    end if;
end affectsFlags;
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
function isTypeThree(opCode:   std_logic_vector(4 downto 0))
                            return boolean is
begin
    if( isJMPFamily(opCode) or opCode = JMP_OPCODE or 
        opCode = CALL_OPCODE or opCode = RET_OPCODE or 
        opCode = RTI_OPCODE) then
        return true;
    else
        return false;
    end if;
end isTypeThree;
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
function isAlueRSinstruction(opCode:   std_logic_vector(4 downto 0))
                            return boolean is
begin
    if( isTypeOne(opCode) or( isTypeZero(opCode) and (opCode /= NOP_OPCODE )and (opCode /= IN_OPCODE) and (opCode /= OUT_OPCODE))) then
        return true;
    else
        return false;
    end if;
end isAlueRSinstruction;
--------------------------------------------------------------------------------
function writesBack(opCode:   std_logic_vector(4 downto 0))
                            return boolean is
begin
    if(opCode = NOT_OPCODE or opCode = INC_OPCODE
     or opCode = DEC_OPCODE or opCode = IN_OPCODE
     or isTypeOne(opCode) or opCode = POP_OPCODE
     or opCode = LDD_OPCODE or opCode = LDM_OPCODE) then
        return true;
    else
        return false;
    end if;
end writesBack;
--------------------------------------------------------------------------------
function toString ( a: std_logic_vector) return string is
variable b : string (1 to a'length) := (others => NUL);
variable stri : integer := 1; 
begin
    for i in a'range loop
        b(stri) := std_logic'image(a((i)))(2);
    stri := stri+1;
    end loop;
return b;
end function;
--------------------------------------------------------------------------------
end package body constants;