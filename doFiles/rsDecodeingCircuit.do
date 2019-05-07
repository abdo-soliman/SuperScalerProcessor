add wave -position insertpoint  \
sim:/decodingcircuit/robFull \
sim:/decodingcircuit/aluRsFull \
sim:/decodingcircuit/memRsFull \
sim:/decodingcircuit/clk \
sim:/decodingcircuit/instruction \
sim:/decodingcircuit/immediateValue \
sim:/decodingcircuit/lastStore \
sim:/decodingcircuit/lastStoreValid \
sim:/decodingcircuit/rsDestName \
sim:/decodingcircuit/src1state \
sim:/decodingcircuit/src1tag \
sim:/decodingcircuit/regSrc1value \
sim:/decodingcircuit/robSrc1value \
sim:/decodingcircuit/src2state \
sim:/decodingcircuit/src2tag \
sim:/decodingcircuit/regSrc2value \
sim:/decodingcircuit/robSrc2value \
sim:/decodingcircuit/src1 \
sim:/decodingcircuit/src2 \
sim:/decodingcircuit/sigValueSrc2 \
sim:/decodingcircuit/sigValueSrc1 \
sim:/decodingcircuit/sigValidSrc2 \
sim:/decodingcircuit/sigValidSrc1 \
sim:/decodingcircuit/sigDestTag \
sim:/decodingcircuit/opcodeType \
sim:/decodingcircuit/opcode \
sim:/decodingcircuit/rsAluInstruction \
sim:/decodingcircuit/rsAluValid \
sim:/decodingcircuit/rsMemInstruction \
sim:/decodingcircuit/rsMemValid \
sim:/decodingcircuit/robInstruction \
sim:/decodingcircuit/robValid \
sim:/decodingcircuit/outSrc2 \
sim:/decodingcircuit/outSrc1 \
sim:/decodingcircuit/instQueueMode \
sim:/decodingcircuit/instQueueEnable
force -freeze sim:/decodingcircuit/robFull 2#0 0
force -freeze sim:/decodingcircuit/aluRsFull 2#0 0
force -freeze sim:/decodingcircuit/memRsFull 2#0 0
force -freeze sim:/decodingcircuit/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/decodingcircuit/instruction 16#6340 0
force -freeze sim:/decodingcircuit/immediateValue 16#0000 0
force -freeze sim:/decodingcircuit/lastStore 2#000 0
force -freeze sim:/decodingcircuit/lastStoreValid 2#0 0
force -freeze sim:/decodingcircuit/src1state 2#00 0
force -freeze sim:/decodingcircuit/src1tag 2#000 0
force -freeze sim:/decodingcircuit/rsDestName 2#000 0
force -freeze sim:/decodingcircuit/regSrc1value 16#F0F0 0
force -freeze sim:/decodingcircuit/robSrc1value 16#0000 0
force -freeze sim:/decodingcircuit/src2state 2#00 0
force -freeze sim:/decodingcircuit/src2tag 2#000 0
force -freeze sim:/decodingcircuit/regSrc2value 16#0101 0
force -freeze sim:/decodingcircuit/robSrc2value 16#0000 0
run
force -freeze sim:/decodingcircuit/instruction 16#6960 0
force -freeze sim:/decodingcircuit/src1state 2#1 0
force -freeze sim:/decodingcircuit/src1tag 2#001 0
force -freeze sim:/decodingcircuit/rsDestName 2#010 0
force -freeze sim:/decodingcircuit/src2state 2#01 0
force -freeze sim:/decodingcircuit/src2tag 2#000 0
run
force -freeze sim:/decodingcircuit/src1state 2#10 0
force -freeze sim:/decodingcircuit/regSrc1value 16#0000 0
force -freeze sim:/decodingcircuit/src2state 2#10 0
force -freeze sim:/decodingcircuit/robSrc2value 16#1032 0
force -freeze sim:/decodingcircuit/rsDestName 2#011 0
force -freeze sim:/decodingcircuit/instruction 16#B400 0
force -freeze sim:/decodingcircuit/immediateValue 16#1032 0
run
force -freeze sim:/decodingcircuit/instruction 16#9140 0
force -freeze sim:/decodingcircuit/rsDestName 2#000 0
force -freeze sim:/decodingcircuit/robSrc2value 16#0001 0
run
force -freeze sim:/decodingcircuit/lastStore 2#100 0
force -freeze sim:/decodingcircuit/lastStoreValid 2#1 0
force -freeze sim:/decodingcircuit/rsDestName 2#011 0
force -freeze sim:/decodingcircuit/src2state 2#01 0
force -freeze sim:/decodingcircuit/src2tag 2#010 0
force -freeze sim:/decodingcircuit/instruction 16#9260 0
run
