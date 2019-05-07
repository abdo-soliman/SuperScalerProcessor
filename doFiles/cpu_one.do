add wave -position insertpoint  \
sim:/cpu/reset
add wave -position insertpoint  \
sim:/cpu/clk
add wave -position insertpoint  \
sim:/cpu/ALUissue
add wave -position insertpoint  \
sim:/cpu/ALUout
add wave -position insertpoint  \
sim:/cpu/ALUtag
add wave -position insertpoint  \
sim:/cpu/ALUtag \
sim:/cpu/ALUtagValid
add wave -position insertpoint  \
sim:/cpu/flags
add wave -position insertpoint  \
sim:/cpu/inputPort
add wave -position insertpoint  \
sim:/cpu/pcOut
add wave -position insertpoint  \
sim:/cpu/ramOut
add wave -position insertpoint  \
sim:/cpu/ALUinstructionIn
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
