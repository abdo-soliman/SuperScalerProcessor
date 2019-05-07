add wave -position insertpoint  \
sim:/reservationstation/reset \
sim:/reservationstation/clk \
sim:/reservationstation/invClk \
sim:/reservationstation/validAlu \
sim:/reservationstation/validMem \
sim:/reservationstation/inEnables \
sim:/reservationstation/inOpCode \
sim:/reservationstation/destName \
sim:/reservationstation/src1Tag \
sim:/reservationstation/src1Valid \
sim:/reservationstation/src2Tag \
sim:/reservationstation/src2Valid \
sim:/reservationstation/lastExcutedAluDestName \
sim:/reservationstation/lastExcutedAluDestNameValue \
sim:/reservationstation/lastExcutedMemDestName \
sim:/reservationstation/lastExcutedMemDestNameValue \
sim:/reservationstation/busyRegEnable \
sim:/reservationstation/busyRegInput \
sim:/reservationstation/busyRegOutput \
sim:/reservationstation/destNameRegEnable \
sim:/reservationstation/destNameRegInput \
sim:/reservationstation/destNameRegOutput \
sim:/reservationstation/opCodeRegEnable \
sim:/reservationstation/opCodeRegInput \
sim:/reservationstation/opCodeRegOutput \
sim:/reservationstation/srcRegTagEnable1 \
sim:/reservationstation/srcRegTagInput1 \
sim:/reservationstation/srcRegTagOutput1 \
sim:/reservationstation/srcRegTagEnable2 \
sim:/reservationstation/srcRegTagInput2 \
sim:/reservationstation/srcRegTagOutput2 \
sim:/reservationstation/srcRegValidEnable1 \
sim:/reservationstation/srcRegValidInput1 \
sim:/reservationstation/srcRegValidOutput1 \
sim:/reservationstation/srcRegValidEnable2 \
sim:/reservationstation/srcRegValidInput2 \
sim:/reservationstation/srcRegValidOutput2 \
sim:/reservationstation/ready \
sim:/reservationstation/outOpcode \
sim:/reservationstation/outDestName \
sim:/reservationstation/src1value \
sim:/reservationstation/src2value
force -freeze sim:/reservationstation/reset 1 0
force -freeze sim:/reservationstation/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/reservationstation/invClk 1 0, 0 {50 ps} -r 100
force -freeze sim:/reservationstation/validAlu 0 0
force -freeze sim:/reservationstation/validMem 0 0
force -freeze sim:/reservationstation/inEnables 16#00 0
force -freeze sim:/reservationstation/inOpCode 16#00 0
force -freeze sim:/reservationstation/destName 2#000 0
force -freeze sim:/reservationstation/src1Tag 16#0000 0
force -freeze sim:/reservationstation/src1Valid 0 0
force -freeze sim:/reservationstation/src2Tag 16#0000 0
force -freeze sim:/reservationstation/src2Valid 0 0
force -freeze sim:/reservationstation/lastExcutedAluDestName 2#000 0
force -freeze sim:/reservationstation/lastExcutedAluDestNameValue 16#0000 0
force -freeze sim:/reservationstation/lastExcutedMemDestName 2#000 0
force -freeze sim:/reservationstation/lastExcutedMemDestNameValue 16#0000 0
run
force -freeze sim:/reservationstation/reset 0 0
force -freeze sim:/reservationstation/inEnables 16#11 0
force -freeze sim:/reservationstation/inOpCode 16#0D 0
force -freeze sim:/reservationstation/destName 2#010 0
force -freeze sim:/reservationstation/src1Tag 16#0001 0
run
force -freeze sim:/reservationstation/inEnables 16#00 0
run
force -freeze sim:/reservationstation/lastExcutedAluDestName 2#000 0
force -freeze sim:/reservationstation/lastExcutedAluDestNameValue 16#F1F1 0
force -freeze sim:/reservationstation/lastExcutedMemDestName 2#001 0
force -freeze sim:/reservationstation/lastExcutedMemDestNameValue 16#1526 0
run
force -freeze sim:/reservationstation/validAlu 1 0
run
force -freeze sim:/reservationstation/validAlu 0 0
run
force -freeze sim:/reservationstation/validMem 1 0
run
force -freeze sim:/reservationstation/validMem 0 0
run
