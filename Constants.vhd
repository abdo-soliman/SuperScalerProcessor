library IEEE;
USE IEEE.std_logic_1164.all;
package Constants is    

--------------- PC Controller CONSTANTS ----------------------
constant PCCONTROLLER_NOP:    std_logic_vector(1 downto 0)			:= "00";
constant PCCONTROLLER_NORMAL:    std_logic_vector(1 downto 0)		:= "01";
constant PCCONTROLLER_ROB:    std_logic_vector(1 downto 0)			:= "10";
constant STD_OPCODE:        std_logic_vector(4 downto 0)			:= "10011";
constant LDD_OPCODE:        std_logic_Vector(4 downto 0)            := "10010";
constant JMPZ_OPCODE:        std_logic_vector(4 downto 0)	    := "11100";
constant JMPN_OPCODE:        std_logic_vector(4 downto 0)	    := "11101";
constant JMPC_OPCODE:        std_logic_vector(4 downto 0)	        := "11110";
constant CALL_OPCODE:            std_logic_vector(4 downto 0)	    := "11000";
constant RET_OPCODE:        std_logic_vector(4 downto 0)	    := "11100";
constant RTI_OPCODE:        std_logic_vector(4 downto 0)	    := "11010";
constant PUSH_OPCODE:        std_logic_vector(4 downto 0)	    := "10000";
constant POP_OPCODE:        std_logic_vector(4 downto 0)	    := "10001";
constant ADD_OPCODE:        std_logic_vector(4 downto 0)	    := "00100";
constant SUB_OPCODE:        std_logic_vector(4 downto 0)	    := "00101";








end Constants;