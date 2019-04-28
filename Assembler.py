

import re
from numpy import binary_repr

opcode = {}
# GROUP 1
opcode['NOP'] = '00000'
opcode['SETC'] = '00010'
opcode['CLC'] = '00011'
opcode['INC'] = '00110'
opcode['DEC'] = '00101'
opcode['IN'] = '00110'
opcode['OUT'] = '00111'
opcode['NOT'] = '00001'
# GROUP 2
opcode['MOV'] = '01000'
opcode['ADD'] = '01100'
opcode['SUB'] = '01101'
opcode['AND'] = '01010'
opcode['OR'] =  '01011'
opcode['SHR'] = '01111'
opcode['SHR'] = '01110'
# GROUP 3
opcode['PUSH'] = '10000'
opcode['POP'] = '10001'
opcode['LDD'] = '10010'
opcode['STD'] = '10011'
opcode['LDM'] = '10110'
# GROUP 4
opcode['CALL'] = '11000'
opcode['RET'] = '11001'
opcode['RTL'] = '11010'
opcode['JZ'] = '11100'
opcode['JN'] = '11101'
opcode['JC'] = '11110'
opcode['JMP'] = '11111'

registers =  {}
# register 
registers['R0'] = '000'
registers['R1'] = '001'
registers['R2'] = '010'
registers['R3'] = '011'
registers['R4'] = '100'
registers['R5'] = '101'
registers['R6'] = '011'
registers['R7'] = '111'

userInstructions = []
inputFileName = "instruction.txt"
outFile = open("output.txt","w+")
with open(inputFileName) as f:
    for line in f:
        if line == "\n":
                continue
        if line[0] == '#':
                continue
        if '#' in line:
                line = line[:line.index('#')]
        
        line = line.strip()
        line = line.upper()
        line = line.split(' ')
        
        if '.ORG' in line:
            address = line[1]
            for i inrange (0,address):
                outFile.write("0".zfill(16))
                outFile.write("\n")
            print(address)
            continue
        instruction = line[0]
        print(instruction)
        line = line[1]
        if (len(line) != 2):   # 2 operand  and immediate value
            register1 = line.split(',')[0]
            if (instruction == 'LDM') or (instruction == 'SHR') or (instruction == 'SHL'):
                line = register1 + instruction
                line = line.zfill(16)
                line = line [::-1]
                outFile.write(line)
                outFile.write("\n")
                outFile.write(binary_repr(int(line.split(',')[1]).zfill(16),width=None))
                print(binary_repr(int(line.split(',')[1])).zfill(16))
                outFile.write("\n")                
            else:     # 2 operand 
                register2 = line.split(',')[1]
                line = register2 + register1 + instruction
                line = line.zfill(16)
                line = line [::-1]
                print(line)
                outFile.write(line)
                outFile.write("\n")
                print(register2)   
        elif (len(line)== 2):            # 1 operand 
            register1 = line # TODO Ignore this 
            line = register1 + instruction
            line = line.zfill(16)
            line = line [::-1]
            outFile.write(line)
            outFile.write("\n")
            print(register1)    
        else :   # No operand   
            line = instruction
            line = line.zfill(16)
            line = line [::-1] 
            outFile.write(line)
            outFile.write("\n")