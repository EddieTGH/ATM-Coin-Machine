nop
nop
nop
nop
init:
j main

main:
addi $1, $1, 1 # $1 = 1 (set led value)
addi $13, $13, 13 # $13 = 13 (no key pressed)
addi $21, $21, 21 # $21 = 21
addi $18, $18, 18 # $18 = memory address for storing current keypad NUMBER
addi $4, $4, 100000000 # $4 = 100000000 (debounce counter)
j waitKeyLoop

waitKeyLoop:
lw $3, 0($0) # $3 = get keypad data
bne $13, $3, recordNum # if GOT A NUMBER, add 1 to counter
j waitKeyLoop # else, keep checking for key

recordNum: 
sw $3, 0($18) # set LSB memory address 18
addi $18, $18, 1 # add 1 to memory address
sw $1, 16($0) # turn led on
j debounceLoop

debounceLoop:
addi $2, $2, 1 # add 1 to debounce counter
bne $2, $4, debounceLoop # if debounce counter is not 100000000, keep looping
j finishRecordNum

finishRecordNum:
sw $0, 16($0) # turn led ooff
bne $21, $18, waitKeyLoop # if memory address is not 21, go back to checking for key
j turnLedOn # if 4 digits have been hit (memory address is 21), turn led on

turnLedOn:
#sw $1, 16($0) # set led to 1
j finish

finish:
nop
nop
nop
j finish