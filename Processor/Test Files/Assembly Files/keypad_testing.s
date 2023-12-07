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

beamBreak:
lw $4, 1($0) #get beam break data
bne $1, $4, beamBreak
sw $1, 17($0)

finish:
nop
nop
nop
j finish

