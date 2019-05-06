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
sim:/memunitintegration/dataOut \
sim:/memunitintegration/validMem \
sim:/memunitintegration/validMemRob \
sim:/memunitintegration/full
mem load -filltype value -filldata F0F0 -fillradix hexadecimal /memunitintegration/memoryUnit/ram/ram(1)
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
force -freeze sim:/memunitintegration/instruction 16#12100018 0
run
force -freeze sim:/memunitintegration/issue 2#0 0
run
force -freeze sim:/memunitintegration/issue 2#0 0
force -freeze sim:/memunitintegration/robPushIssue 2#1 0
force -freeze sim:/memunitintegration/robValue 16#0F0F 0
run
force -freeze sim:/memunitintegration/robPushIssue 2#0 0
run
