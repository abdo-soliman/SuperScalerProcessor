add wave -position insertpoint  \
sim:/alureservationstations/reset \
sim:/alureservationstations/clk \
sim:/alureservationstations/issue \
sim:/alureservationstations/validAlu \
sim:/alureservationstations/validMem \
sim:/alureservationstations/opcode \
sim:/alureservationstations/tag1 \
sim:/alureservationstations/valid1 \
sim:/alureservationstations/tag2 \
sim:/alureservationstations/valid2 \
sim:/alureservationstations/issueDestName \
sim:/alureservationstations/lastExcutedAluDestName \
sim:/alureservationstations/lastExcutedAluDestNameValue \
sim:/alureservationstations/lastExcutedMemDestName \
sim:/alureservationstations/lastExcutedMemDestNameValue \
sim:/alureservationstations/resets \
sim:/alureservationstations/enablesOpcode \
sim:/alureservationstations/enablesTag1 \
sim:/alureservationstations/enablesValid1 \
sim:/alureservationstations/enablesTag2 \
sim:/alureservationstations/enablesValid2 \
sim:/alureservationstations/enablesDestName \
sim:/alureservationstations/busies \
sim:/alureservationstations/readies \
sim:/alureservationstations/outEnables \
sim:/alureservationstations/aluOp \
sim:/alureservationstations/op1 \
sim:/alureservationstations/op2 \
sim:/alureservationstations/valid \
sim:/alureservationstations/full \
sim:/alureservationstations/issuedLastCycle
force -freeze sim:/alureservationstations/reset 2#1 0
force -freeze sim:/alureservationstations/issue 2#0 0
force -freeze sim:/alureservationstations/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/alureservationstations/validAlu 2#0 0
force -freeze sim:/alureservationstations/validMem 2#0 0
force -freeze sim:/alureservationstations/opcode 16#00 0
force -freeze sim:/alureservationstations/tag1 16#0000 0
force -freeze sim:/alureservationstations/valid1 2#0 0
force -freeze sim:/alureservationstations/tag2 16#0000 0
force -freeze sim:/alureservationstations/valid2 2#0 0
force -freeze sim:/alureservationstations/issueDestName 2#000 0
force -freeze sim:/alureservationstations/lastExcutedAluDestNameValue 16#0000 0
force -freeze sim:/alureservationstations/lastExcutedMemDestName 2#000 0
force -freeze sim:/alureservationstations/lastExcutedMemDestNameValue 16#0000 0
run
force -freeze sim:/alureservationstations/reset 2#0 0
force -freeze sim:/alureservationstations/issue 2#1 0
force -freeze sim:/alureservationstations/opcode 16#0C 0
force -freeze sim:/alureservationstations/tag1 16#F0F0 0
force -freeze sim:/alureservationstations/valid1 2#1 0
force -freeze sim:/alureservationstations/tag2 16#0101 0
force -freeze sim:/alureservationstations/valid2 2#1 0
force -freeze sim:/alureservationstations/issueDestName 2#000 0
force -freeze sim:/alureservationstations/lastExcutedAluDestNameValue 16#0000 0
force -freeze sim:/alureservationstations/lastExcutedMemDestName 2#000 0
force -freeze sim:/alureservationstations/lastExcutedMemDestNameValue 16#0000 0
run
force -freeze sim:/alureservationstations/issue 2#0 0
run
force -freeze sim:/alureservationstations/issue 2#1 0
force -freeze sim:/alureservationstations/tag1 16#0001 0
force -freeze sim:/alureservationstations/valid1 2#0 0
force -freeze sim:/alureservationstations/tag2 16#0000 0
force -freeze sim:/alureservationstations/valid2 2#0 0
force -freeze sim:/alureservationstations/issueDestName 2#010 0
force -freeze sim:/alureservationstations/lastExcutedAluDestNameValue 16#F1F1 0
force -freeze sim:/alureservationstations/lastExcutedMemDestName 2#001 0
force -freeze sim:/alureservationstations/lastExcutedMemDestNameValue 16#1010 0
force -freeze sim:/alureservationstations/opcode 16#0D 0
force -freeze sim:/alureservationstations/validAlu 2#1 0
force -freeze sim:/alureservationstations/validMem 2#1 0
run
force -freeze sim:/alureservationstations/opcode 16#16 0
force -freeze sim:/alureservationstations/tag1 16#0000 0
force -freeze sim:/alureservationstations/valid1 2#1 0
force -freeze sim:/alureservationstations/tag2 16#1032 0
force -freeze sim:/alureservationstations/valid2 2#1 0
force -freeze sim:/alureservationstations/issueDestName 2#011 0
force -freeze sim:/alureservationstations/validAlu 2#0 0
force -freeze sim:/alureservationstations/validMem 2#0 0
run
force -freeze sim:/alureservationstations/issue 2#0 0
run
