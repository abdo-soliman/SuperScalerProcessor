add wave -position insertpoint  \
sim:/cpu/reset \
sim:/cpu/clk \
sim:/cpu/flags \
sim:/cpu/inputPort \
sim:/cpu/pcOut \
sim:/cpu/ramOut \
sim:/cpu/ALUinstructionIn \
sim:/cpu/ALUissue \
sim:/cpu/ALUout \
sim:/cpu/ALUtag \
sim:/cpu/ALUtagValid \
sim:/cpu/rob/readPointer \
sim:/cpu/rob/writePointer \
sim:/cpu/rob/instruction \
add wave -position end  sim:/cpu/inputPort
add wave -position end  sim:/cpu/outputPort
add wave -position end  sim:/cpu/interrupt
add wave -position end  sim:/cpu/inputPortReady
add wave -position end  sim:/cpu/rob/readPointer
mem load -i {/SuperScalerProcessor/Assembler/Compiled Files/twoOp.txt} -format binary /cpu/insRam/ram
force -freeze sim:/cpu/reset 1 0
force -freeze sim:/cpu/clk 0 0, 1 {50 ps} -r 100
run
force -freeze sim:/cpu/reset 0 0
force -freeze sim:/cpu/inputPort 16#0005 0
run
force -freeze sim:/cpu/inputPort 16#0019 0
run
force -freeze sim:/cpu/inputPort 16#FFFF 0
run
force -freeze sim:/cpu/inputPort 16#F320 0
run
