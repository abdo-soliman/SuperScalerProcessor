add wave -position insertpoint  \
sim:/arithmaticunitintegration/reset \
sim:/arithmaticunitintegration/clk \
sim:/arithmaticunitintegration/issue \
sim:/arithmaticunitintegration/setFlags \
sim:/arithmaticunitintegration/robFlags \
sim:/arithmaticunitintegration/validAlu \
sim:/arithmaticunitintegration/validMem \
sim:/arithmaticunitintegration/instruction \
sim:/arithmaticunitintegration/lastExcutedAluDestName \
sim:/arithmaticunitintegration/lastExcutedAluDestNameValue \
sim:/arithmaticunitintegration/lastExcutedMemDestName \
sim:/arithmaticunitintegration/lastExcutedMemDestNameValue \
sim:/arithmaticunitintegration/tempValidAlu \
sim:/arithmaticunitintegration/flagsEnable \
sim:/arithmaticunitintegration/inFlags \
sim:/arithmaticunitintegration/outFlags \
sim:/arithmaticunitintegration/op1 \
sim:/arithmaticunitintegration/op2 \
sim:/arithmaticunitintegration/currentFlags \
sim:/arithmaticunitintegration/flags \
sim:/arithmaticunitintegration/full
force -freeze sim:/arithmaticunitintegration/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/arithmaticunitintegration/reset 2#0 0
force -freeze sim:/arithmaticunitintegration/reset 2#1 0
force -freeze sim:/arithmaticunitintegration/issue 2#0 0
force -freeze sim:/arithmaticunitintegration/setFlags 2#0 0
force -freeze sim:/arithmaticunitintegration/robFlags 2#000 0
force -freeze sim:/arithmaticunitintegration/validMem 2#0 0
force -freeze sim:/arithmaticunitintegration/instruction 16#19E1E101018 0
force -freeze sim:/arithmaticunitintegration/lastExcutedMemDestName 2#000 0
force -freeze sim:/arithmaticunitintegration/lastExcutedMemDestNameValue 16#0000 0
run
force -freeze sim:/arithmaticunitintegration/reset 2#0 0
force -freeze sim:/arithmaticunitintegration/issue 2#1 0
run
force -freeze sim:/arithmaticunitintegration/issue 2#0 0
run
force -freeze sim:/arithmaticunitintegration/issue 2#1 0
force -freeze sim:/arithmaticunitintegration/instruction 16#1A000200002 0
run
force -freeze sim:/arithmaticunitintegration/instruction 16#2C00011032B 0
run
force -freeze sim:/arithmaticunitintegration/issue 2#0 0
run
run
run
force -freeze sim:/arithmaticunitintegration/lastExcutedMemDestName 2#001 0
force -freeze sim:/arithmaticunitintegration/lastExcutedMemDestNameValue 16#0011 0
force -freeze sim:/arithmaticunitintegration/validMem 2#1 0
run
force -freeze sim:/arithmaticunitintegration/validMem 2#0 0
run
run
run
