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
add wave -position insertpoint  \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/inEnables
add wave -position insertpoint  \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/outEnable
add wave -position insertpoint  \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/src1Tag
add wave -position insertpoint  \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/src2Tag
add wave -position insertpoint  \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/src1Valid
add wave -position insertpoint  \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/src2Valid
add wave -position insertpoint  \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/srcRegTagEnable1 \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/srcRegTagInput1 \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/srcRegTagOutput1 \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/srcRegTagEnable2 \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/srcRegTagInput2 \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/srcRegTagOutput2 \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/srcRegValidEnable1 \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/srcRegValidInput1 \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/srcRegValidOutput1 \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/srcRegValidEnable2 \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/srcRegValidInput2 \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/srcRegValidOutput2 \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/busyRegEnable \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/busyRegInput \
sim:/cpu/arithUnit/reservationStations/genRs(0)/rsx/busyRegOutput
mem load -i /home/abdo/Desktop/SuperScalerProcessor/twoOp.txt -format binary /cpu/insRam/ram
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
