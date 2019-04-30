library IEEE;
USE IEEE.std_logic_1164.all;
package constants is    

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
constant JZ_OPCODE:     std_logic_vector(4 downto 0) := "11100";
constant JN_OPCODE:     std_logic_vector(4 downto 0) := "11101";
constant JC_OPCODE:     std_logic_vector(4 downto 0) := "11110";
constant JMP_OPCODE:    std_logic_vector(4 downto 0) := "11111";
--------------------------------------------------------------------------------

------------------------ALU Opcodes---------------------------------------------
constant MOV_ALU_CODE: std_logic_vector(4 downto 0) := "00000";
constant SUB_ALU_CODE: std_logic_vector(4 downto 0) := "00001";
constant DEC_ALU_CODE: std_logic_vector(4 downto 0) := "00010";
constant INC_ALU_CODE: std_logic_vector(4 downto 0) := "00011";
constant ADD_ALU_CODE: std_logic_vector(4 downto 0) := "00100";
constant AND_ALU_CODE: std_logic_vector(4 downto 0) := "01000";
constant OR_ALU_CODE:  std_logic_vector(4 downto 0) := "01001";
constant NOT_ALU_CODE: std_logic_vector(4 downto 0) := "01010";
constant SHL_ALU_CODE: std_logic_vector(4 downto 0) := "10000";
constant SHR_ALU_CODE: std_logic_vector(4 downto 0) := "10001";
--------------------------------------------------------------------------------

end Constants;