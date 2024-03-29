vsim work.cpu
add wave -position end  sim:/cpu/clk
add wave -position end  sim:/cpu/reset
add wave -position end  sim:/cpu/inputPort
add wave -position end  sim:/cpu/outputPort
add wave -position end  sim:/cpu/interrupt
add wave -position end  sim:/cpu/inputPortReady
add wave -position end  sim:/cpu/rob/readPointer
force -freeze sim:/cpu/reset 1 0
force -freeze sim:/cpu/clk 0 0, 1 {50 ps} -r 100
mem load -i {/SuperScalerProcessor/Assembler/Compiled Files/MEM.txt} -format binary /cpu/insRam/ram
force -freeze sim:/cpu/reset 1 0
force -freeze sim:/cpu/clk 0 0, 1 {50 ps} -r 100
run
force -freeze sim:/cpu/reset 0 0
force -freeze sim:/cpu/inputPort 0019 0
run
force -freeze sim:/cpu/inputPort FFFF 0
run
force -freeze sim:/cpu/inputPort F320 0
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