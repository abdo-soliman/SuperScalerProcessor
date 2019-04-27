library IEEE;
USE IEEE.std_logic_1164.all;
package Constants is    

--------------- PC Controller CONSTANTS ----------------------
constant PCCONTROLLER_NOP:    std_logic_vector(1 downto 0)			:= "00";
constant PCCONTROLLER_NORMAL:    std_logic_vector(1 downto 0)		:= "01";
constant PCCONTROLLER_ROB:    std_logic_vector(1 downto 0)			:= "10";




end Constants;