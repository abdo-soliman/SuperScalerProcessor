add wave -position insertpoint  \
sim:/memreservationstations/reset \
sim:/memreservationstations/clk \
sim:/memreservationstations/issue \
sim:/memreservationstations/validAlu \
sim:/memreservationstations/validMem \
sim:/memreservationstations/outEnable \
sim:/memreservationstations/opcode \
sim:/memreservationstations/waitingTag \
sim:/memreservationstations/tag1 \
sim:/memreservationstations/waitingDone \
sim:/memreservationstations/tag2 \
sim:/memreservationstations/valid2 \
sim:/memreservationstations/issueDestName \
sim:/memreservationstations/lastExcutedAluDestName \
sim:/memreservationstations/lastExcutedAluDestNameValue \
sim:/memreservationstations/lastExcutedMemDestName \
sim:/memreservationstations/lastExcutedMemDestNameValue \
sim:/memreservationstations/enablesDestName \
sim:/memreservationstations/enablesOpcode \
sim:/memreservationstations/enablesTag1 \
sim:/memreservationstations/enablesTag2 \
sim:/memreservationstations/enablesValid1 \
sim:/memreservationstations/enablesValid2 \
sim:/memreservationstations/busies \
sim:/memreservationstations/readies \
sim:/memreservationstations/outEnables \
sim:/memreservationstations/resets \
sim:/memreservationstations/address \
sim:/memreservationstations/valid \
sim:/memreservationstations/full \
sim:/memreservationstations/issuedLastCycle \
sim:/memreservationstations/genRs(0)/rsx/srcRegValidEnable1 \
sim:/memreservationstations/genRs(0)/rsx/srcRegValidInput1 \
sim:/memreservationstations/genRs(0)/rsx/srcRegValidOutput1 \
sim:/memreservationstations/genRs(0)/rsx/srcRegValidReset1 \
sim:/memreservationstations/genRs(0)/rsx/srcRegValidEnable2 \
sim:/memreservationstations/genRs(0)/rsx/srcRegValidInput2 \
sim:/memreservationstations/genRs(0)/rsx/srcRegValidOutput2 \
sim:/memreservationstations/genRs(0)/rsx/srcRegValidReset2
force -freeze sim:/memreservationstations/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/memreservationstations/reset 2#1 0
force -freeze sim:/memreservationstations/issue 2#0 0
force -freeze sim:/memreservationstations/validAlu 2#0 0
force -freeze sim:/memreservationstations/validMem 2#0 0
force -freeze sim:/memreservationstations/outEnable 2#0 0
force -freeze sim:/memreservationstations/opcode 16#12 0
force -freeze sim:/memreservationstations/waitingTag 2#000 0
force -freeze sim:/memreservationstations/waitingDone 2#0 0
force -freeze sim:/memreservationstations/tag2 16#0000 0
force -freeze sim:/memreservationstations/valid2 2#0 0
force -freeze sim:/memreservationstations/issueDestName 2#000 0
force -freeze sim:/memreservationstations/lastExcutedAluDestName 2#000 0
force -freeze sim:/memreservationstations/lastExcutedAluDestNameValue 16#0000 0
force -freeze sim:/memreservationstations/lastExcutedMemDestNameValue 16#0000 0
run
force -freeze sim:/memreservationstations/reset 2#0 0
force -freeze sim:/memreservationstations/waitingDone 2#1 0
force -freeze sim:/memreservationstations/tag2 16#F001 0
force -freeze sim:/memreservationstations/valid2 2#1 0
force -freeze sim:/memreservationstations/issue 2#1 0
run
force -freeze sim:/memreservationstations/issue 2#0 0
run
force -freeze sim:/memreservationstations/issue 2#1 0
force -freeze sim:/memreservationstations/waitingTag 2#010 0
force -freeze sim:/memreservationstations/tag2 2#001 0
force -freeze sim:/memreservationstations/valid2 2#0 0
force -freeze sim:/memreservationstations/issueDestName 2#010 0
force -freeze sim:/memreservationstations/lastExcutedAluDestName 2#001 0
force -freeze sim:/memreservationstations/lastExcutedAluDestNameValue 16#0F0F 0
run
force -freeze sim:/memreservationstations/waitingTag 2#100 0
force -freeze sim:/memreservationstations/waitingDone 2#0 0
force -freeze sim:/memreservationstations/tag2 16#0002 0
force -freeze sim:/memreservationstations/valid2 2#0 0
force -freeze sim:/memreservationstations/issueDestName 2#011 0
run
force -freeze sim:/memreservationstations/issue 2#0 0
run
force -freeze sim:/memreservationstations/outEnable 2#1 0
run
run
run
force -freeze sim:/memreservationstations/validAlu 2#1 0
run
force -freeze sim:/memreservationstations/validAlu 2#0 0
run
force -freeze sim:/memreservationstations/validMem 2#1 0
run
force -freeze sim:/memreservationstations/validMem 2#0 0
run
force -freeze sim:/memreservationstations/lastExcutedMemDestName 2#100 0
force -freeze sim:/memreservationstations/validMem 2#1 0
run
force -freeze sim:/memreservationstations/validMem 2#0 0
run
run
run
run
run
