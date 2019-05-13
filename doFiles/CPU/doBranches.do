vsim work.cpu
add wave -position end  sim:/cpu/clk
add wave -position end  sim:/cpu/reset
add wave -position end  sim:/cpu/inputPort
add wave -position end  sim:/cpu/outputPort
add wave -position end  sim:/cpu/interrupt
add wave -position end  sim:/cpu/inputPortReady
add wave -position end  sim:/cpu/pcOut
add wave -position end  sim:/cpu/rob/readPointer
add wave -position end  sim:/cpu/flags
mem load -i {/SuperScalerProcessor/Assembler/Compiled Files/jumps.txt} -format binary /cpu/insRam/ram
force -freeze sim:/cpu/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/cpu/reset 1 0
run
force -freeze sim:/cpu/reset 0 0
force -freeze sim:/cpu/inputPort 0030 0
run
force -freeze sim:/cpu/inputPort 0050 0
run
force -freeze sim:/cpu/inputPort 0100 0
run
force -freeze sim:/cpu/inputPort 0300 0
run
run
run
force -freeze sim:/cpu/inputPort 0200 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run


