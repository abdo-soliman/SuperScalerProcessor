add wave -position insertpoint  \
sim:/memunitintegration/reset \
sim:/memunitintegration/clk \
sim:/memunitintegration/issue \
sim:/memunitintegration/validAlu \
sim:/memunitintegration/instruction \
sim:/memunitintegration/robPopIssue \
sim:/memunitintegration/robPushIssue \
sim:/memunitintegration/robStoreIssue \
sim:/memunitintegration/robTag \
sim:/memunitintegration/robAddress \
sim:/memunitintegration/robValue \
sim:/memunitintegration/lastExcutedAluDestName \
sim:/memunitintegration/lastExcutedAluDestNameValue \
sim:/memunitintegration/lastExcutedMemDestName \
sim:/memunitintegration/lastExcutedMemDestNameValue \
sim:/memunitintegration/enableLoadOut \
sim:/memunitintegration/mode \
sim:/memunitintegration/tempDataIn \
sim:/memunitintegration/tempDestTag \
sim:/memunitintegration/validLoadBuffers \
sim:/memunitintegration/address \
sim:/memunitintegration/validMem \
sim:/memunitintegration/validMemRob \
sim:/memunitintegration/full
add wave -position insertpoint  \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/src1Tag \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/src2Tag \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/src1Valid \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/src2Valid
add wave -position insertpoint  \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/inEnables \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/outEnable \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegTagInput1 \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegTagEnable1 \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegTagReset1 \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegTagOutput1 \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegTagInput2 \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegTagEnable2 \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegTagReset2 \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegTagOutput2 \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegValidInput1 \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegValidEnable1 \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegValidReset1 \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegValidOutput1 \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegValidInput2 \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegValidEnable2 \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegValidReset2 \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/srcRegValidOutput2
add wave -position insertpoint  \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/busyRegInput \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/busyRegEnable \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/busyRegReset \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/busyRegOutput
add wave -position insertpoint  \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/validAlu \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/validMem
add wave -position insertpoint  \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/lastExcutedMemDestName \
sim:/memunitintegration/loadBuffers/genRs(0)/rsx/lastExcutedMemDestNameValue
mem load -filltype value -filldata F0F0 -fillradix hexadecimal /memunitintegration/memoryUnit/ram/ram(2)
force -freeze sim:/memunitintegration/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/memunitintegration/reset 2#1 0
force -freeze sim:/memunitintegration/issue 2#0 0
force -freeze sim:/memunitintegration/validAlu 2#0 0
force -freeze sim:/memunitintegration/instruction 16#0000 0
force -freeze sim:/memunitintegration/robPopIssue 2#0 0
force -freeze sim:/memunitintegration/robPushIssue 2#0 0
force -freeze sim:/memunitintegration/robStoreIssue 2#0 0
force -freeze sim:/memunitintegration/robTag 2#000 0
force -freeze sim:/memunitintegration/robAddress 16#0000 0
force -freeze sim:/memunitintegration/robValue 16#0000 0
force -freeze sim:/memunitintegration/lastExcutedAluDestName 2#000 0
force -freeze sim:/memunitintegration/lastExcutedAluDestNameValue 16#0000 0
run
force -freeze sim:/memunitintegration/reset 2#0 0
force -freeze sim:/memunitintegration/issue 2#1 0
force -freeze sim:/memunitintegration/instruction 16#12200028 0
run
force -freeze sim:/memunitintegration/issue 2#0 0
run
force -freeze sim:/memunitintegration/robStoreIssue 2#1 0
force -freeze sim:/memunitintegration/robTag 2#001 0
force -freeze sim:/memunitintegration/robAddress 16#0001 0
force -freeze sim:/memunitintegration/robValue 16#0F0F 0
run
force -freeze sim:/memunitintegration/robStoreIssue 2#0 0
run
