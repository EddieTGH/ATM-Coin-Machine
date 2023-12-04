nop
nop
nop
nop
init:
j main

main:
addi $1, $1, 1
addi $2, $2, 4

waitKeyLoop:
lw $3, 0($0) #get keypad data
bne $2, $3, waitKeyLoop

turnLedOn:
sw $1, 16($0)
sw $3, 18($0)

finish:
nop
nop
nop
j finish

