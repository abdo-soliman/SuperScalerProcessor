add wave -position insertpoint  \
sim:/cpu/reset \
sim:/cpu/clk \
sim:/cpu/ALUissue \
sim:/cpu/ALUout \
sim:/cpu/ALUtag \
sim:/cpu/ALUtag \
sim:/cpu/ALUtagValid \
sim:/cpu/flags \
sim:/cpu/inputPort \
sim:/cpu/pcOut \
sim:/cpu/ramOut \
sim:/cpu/ALUinstructionIn \
sim:/cpu/rob/readPointer \
sim:/cpu/rob/writePointer \
sim:/cpu/rob/instruction
mem load -i /home/abdo/Desktop/SuperScalerProcessor/ONEoutput.txt -format binary /cpu/insRam/ram
force -freeze sim:/cpu/reset 2#1 0
force -freeze sim:/cpu/clk 0 0, 1 {50 ps} -r 100
run
force -freeze sim:/cpu/reset 2#0 0
run
run
run
run
run
