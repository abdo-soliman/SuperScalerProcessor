
add wave -position insertpoint  \
sim:/decodingcircuit/clk \
sim:/decodingcircuit/robFull \
sim:/decodingcircuit/aluRsFull \
sim:/decodingcircuit/memRsFull \
sim:/decodingcircuit/instruction \
sim:/decodingcircuit/immediateValue \
sim:/decodingcircuit/lastStore \
sim:/decodingcircuit/lastStoreValid \
sim:/decodingcircuit/instQueueEnable \
sim:/decodingcircuit/instQueueMode \
sim:/decodingcircuit/src1state \
sim:/decodingcircuit/src1tag \
sim:/decodingcircuit/rsDestName \
sim:/decodingcircuit/regSrc1value \
sim:/decodingcircuit/robSrc1value \
sim:/decodingcircuit/src2state \
sim:/decodingcircuit/src2tag
sim:/decodingcircuit/regSrc2value \
sim:/decodingcircuit/robSrc2value \
sim:/decodingcircuit/rsAluValid \
sim:/decodingcircuit/rsMemValid \
sim:/decodingcircuit/rsMemInstruction \
sim:/decodingcircuit/robValid \
sim:/decodingcircuit/robInstruction \
sim:/decodingcircuit/outSrc1 \
sim:/decodingcircuit/outSrc2 \
sim:/decodingcircuit/instQueueEnable \
sim:/decodingcircuit/insQueueMode 
force -freeze sim:/decodingcircuit/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/decodingcircuit/immediateValue 16#0003 0
force -freeze sim:/decodingcircuit/robFull 0 0
force -freeze sim:/decodingcircuit/aluRsFull 0 0
force -freeze sim:/decodingcircuit/memRsFull 0 0
force -freeze sim:/decodingcircuit/instruction 01000001010000000 0  
force -freeze sim:/decodingcircuit/lastStore 0 0
force -freeze sim:/decodingcircuit/lastStoreValid 0 0
force -freeze sim:/decodingcircuit/robSrc1value 0000000000001111 0
force -freeze sim:/decodingcircuit/src1state 00 0
force -freeze sim:/decodingcircuit/src1tag 010 0
force -freeze sim:/decodingcircuit/rsDestName 000 0
force -freeze sim:/decodingcircuit/src2state 00 0
force -freeze sim:/decodingcircuit/src2tag 010 0
