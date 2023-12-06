nop
nop
nop
nop
init:
j main

#Memory 16: LED1
#Memory 18: Keypad 1st digit
#Memory 19: Keypad 2nd digit
#Memory 20: Keypad 3rd digit
#Memory 21: Keypad 4th digit
#Mmeory 24: Full Number (Appended together)

main:
addi $1, $1, 1 # $1 = 1 (set led value)
addi $13, $13, 13 # $13 = 13 (no key pressed)
addi $22, $22, 22 # 2 = 22
addi $18, $18, 18 # $18 = memory address for storing current keypad NUMBER
addi $4, $4, 7000 # $4 = 100,000 (debounce counter)
j waitKeyLoop

waitKeyLoop:
lw $3, 0($0) # $3 = get keypad data
bne $13, $3, recordNum # if GOT A NUMBER, add 1 to counter
j waitKeyLoop # else, keep checking for key

recordNum: 
sw $3, 0($18) # set LSB memory address 18
addi $18, $18, 1 # add 1 to memory address
j debounceLoop

debounceLoop:
sw $1, 16($0) # START DEBOUNCING: set led0 to 1
addi $29, $29, 1 # add 1 to debounce counter
bne $29, $4, debounceLoop # if debounce counter is not 100000000, keep looping

sw $0, 16($0) # STOP DEBOUNCING: set led0 to 0
sub $29, $29, $29 # reset debounce counter to 0
j finishRecordNum

finishRecordNum:
bne $22, $18, waitKeyLoop # if memory address is not 22, go back to checking for key
j appendTogether # if 4 digits have been hit (memory address is 21), turn led on

appendTogether:
lw $10, 18($0) # $10 = get first digit
lw $11, 19($0) # $11 = get second digit
lw $12, 20($0) # $12 = get third digit
lw $13, 21($0) # $13 = get fourth digit

addi $23, $23, 10
addi $24, $24, 100
addi $25, $25, 1000

mul $26, $11, $23 # $26 = second digit * 10
mul $27, $12, $24 # $27 = third digit * 100
mul $28, $13, $25 # $28 = fourth digit * 1000

#add $29, $29, $10 # $29 = add 1st digit * 1
#add $29, $29, $26 # $29 = add 2nd digit * 10
#add $29, $29, $27 # $29 = add 3rd digit * 100
#add $29, $29, $28 # $29 = add 4th digit * 1000

#sw $29, 24($0) # store the number in memory address 24
sw $1, 17($0) # set led1 to 1 (showcase done and append together)

j finish

finish:
nop
nop
nop
j finish