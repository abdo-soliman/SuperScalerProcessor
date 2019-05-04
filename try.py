


import re
from numpy import binary_repr
opcode  = {}
opcode['LDM'] = '10110'

registers =  {}
# register 
registers['R0'] = '000'
registers['R1'] = '001'
outFile = open("output.txt","w+")
mynum = 0
with open("instruction.txt") as f:
    for line in f:
        line = line.strip()
        line = line.upper()
        line = line.split(' ')

        instruction = line[0]
        print(instruction)
        line = line[1]
        if (len(line) != 2):   # 2 operand  and immediate value
            register1 = line.split(',')[0]
            print(register1)
            print(registers[register1])
            number = int(line.split(',')[1])
            if (instruction == 'LDM') or (instruction == 'SHR') or (instruction == 'SHL'):
                line = opcode[instruction] +registers[register1]
                line = line [::-1]
                line = line.zfill(16)
                line = line [::-1]
                outFile.write(line)
                outFile.write("\n")
                outFile.write(str(binary_repr(number,width=None)).zfill(16))
                outFile.write("\n")                
        