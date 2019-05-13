add wave -position insertpoint  \
sim:/alu/s \
sim:/alu/a \
sim:/alu/b \
sim:/alu/cin \
sim:/alu/f \
sim:/alu/cout \
sim:/alu/zero \
sim:/alu/negative \
sim:/alu/carry
force -freeze sim:/alu/s 2#00000 0
force -freeze sim:/alu/a 16#FF 0
force -freeze sim:/alu/b 16#13 0
force -freeze sim:/alu/cin 0 0
run
force -freeze sim:/alu/cin 2#1 0
run
force -freeze sim:/alu/s 2#00001 0
run
force -freeze sim:/alu/cin 2#0 0
run
force -freeze sim:/alu/b 16#FF 0
run
force -freeze sim:/alu/s 2#00010 0
run
force -freeze sim:/alu/cin 2#1 0
run
force -freeze sim:/alu/cin 2#0 0
force -freeze sim:/alu/s 2#00011 0
run
force -freeze sim:/alu/s 2#00100 0
force -freeze sim:/alu/b 16#13 0
force -freeze sim:/alu/a 16#14 0
run
force -freeze sim:/alu/cin 2#1 0
run
force -freeze sim:/alu/s 2#00101 0
force -freeze sim:/alu/cin 2#0 0
run
force -freeze sim:/alu/cin 2#1 0
run
force -freeze sim:/alu/s 2#00110 0
force -freeze sim:/alu/a 16#FF 0
force -freeze sim:/alu/b 16#13 0
run
force -freeze sim:/alu/cin 2#0 0
run
force -freeze sim:/alu/s 2#0100 0
run
force -freeze sim:/alu/s 2#01000 0
run
force -freeze sim:/alu/s 2#01001 0
run
force -freeze sim:/alu/s 2#01010 0
run
force -freeze sim:/alu/s 2#01110 0
run
force -freeze sim:/alu/s 2#01011 0
run
force -freeze sim:/alu/a 16#11 0
force -freeze sim:/alu/s 2#01111 0
run
