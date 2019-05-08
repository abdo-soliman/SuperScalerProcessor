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
sim:/cpu/rob/instruction \
sim:/cpu/arithUnit/reservationStations/busies \
sim:/cpu/arithUnit/reservationStations/readies \
sim:/cpu/arithUnit/reservationStations/outEnables
add wave -position end  sim:/cpu/inputPort
add wave -position end  sim:/cpu/outputPort
add wave -position end  sim:/cpu/interrupt
add wave -position end  sim:/cpu/inputPortReady
add wave -position end  sim:/cpu/rob/readPointer
mem load -i /home/abdo/Desktop/SuperScalerProcessor/MEM.txt -format binary /cpu/insRam/ram
force -freeze sim:/cpu/reset 1 0
force -freeze sim:/cpu/clk 0 0, 1 {50 ps} -r 100
run
# ** Warning: There is an 'U'|'X'|'W'|'Z'|'-' in an arithmetic operand, the result will be 'X'(es).
#    Time: 0 ps  Iteration: 0  Instance: /cpu/arithUnit
# ** Warning: There is an 'U'|'X'|'W'|'Z'|'-' in an arithmetic operand, the result will be 'X'(es).
#    Time: 0 ps  Iteration: 0  Instance: /cpu/arithUnit
# ** Warning: There is an 'U'|'X'|'W'|'Z'|'-' in an arithmetic operand, the result will be 'X'(es).
#    Time: 0 ps  Iteration: 0  Instance: /cpu/arithUnit
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 0  Instance: /cpu/arithUnit/alu/su_inst
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 2  Instance: /cpu/dataRam/memoryUnit/ram
force -freeze sim:/cpu/reset 0 0
force -freeze sim:/cpu/inputPort 16#0019 0
run
# ** Note: 000
#    Time: 200 ps  Iteration: 2  Instance: /cpu/rob
force -freeze sim:/cpu/inputPort 16#FFFF 0
run
# ** Note: 1001100000000000011001100000000000000000100000001
#    Time: 250 ps  Iteration: 0  Instance: /cpu/rob
# ** Note: Plz
#    Time: 300 ps  Iteration: 0  Instance: /cpu/rob
# ** Note: 001
#    Time: 300 ps  Iteration: 2  Instance: /cpu/rob
force -freeze sim:/cpu/inputPort 16#F320 0
run
