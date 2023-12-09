nop
nop
nop
nop
init:
j main


startBeamBreak: #a0 is pin to deposit to 
addi $29, $29, -8
sw $31, 0($29)
sw $2, 1($29)
sw $3, 2($29)
sw $4, 3($29)
sw $5, 4($29)
sw $6, 5($29)
sw $7, 6($29)
sw $8, 7($29)

lw $6, 0($26) # $6 = current accountBalance
addi $7, $0, 11 # The number for deposit

sw $1, 16($0)

_beamBreakLoop:
lw $8, 0($0) # $8 = keypad data
blt $8, $7, _beamCheck 
bne $8, $13, _exitDeposit # clicked the deposit

_beamCheck:
lw $2, 1($0) # $2 = beambroken1
lw $3, 2($0) # $3 = beambroken5
lw $4, 3($0) # $4 = beambroken10
lw $5, 4($0) # $5 = beambroken25
bne $2, $0, _oneCent # if beambroken1 is not 0, go to oneCent
bne $3, $0, _fiveCent # if beambroken5 is not 0, go to fiveCent
bne $4, $0, _tenCent # if beambroken10 is not 0, go to tenCent
bne $5, $0, _twentyFiveCent # if beambroken25 is not 0, go to twentyFiveCent
j _beamBreakLoop

_oneCent: #add 1 to accountBalance 
sw $1, 27($0) # acknowledge that beam break has been read: store 1 into memory 27
addi $6, $6, 1 # $6 = accountBalance + 1
j _gotCoin

_fiveCent: #add 5 to accountBalance 
sw $1, 27($0) # acknowledge that beam break has been read: store 1 into memory 27
addi $6, $6, 5 # $6 = accountBalance + 5
j _gotCoin

_tenCent: #add 10 to accountBalance 
sw $1, 27($0) # acknowledge that beam break has been read: store 1 into memory 27
addi $6, $6, 10 # $6 = accountBalance + 10
j _gotCoin

_twentyFiveCent: #add 25 to accountBalance 
sw $1, 27($0) # acknowledge that beam break has been read: store 1 into memory 27
addi $6, $6, 25 # $6 = accountBalance + 25

_gotCoin:
sw $6, 0($26) # store new current balance at pin $a0
sw $0, 27($0) # turn off acknowledge beam break: store 0 into memory 27
jal displayBalance # $26 a0 is still the pin who we are working with
j _beamBreakLoop

_exitDeposit:
sw $1, 22($0) # acknowledge that key has been read: store 1 into memory 22
nop
sw $0, 22($0) # finish that key has been read: store 0 into memory 22
sw $0, 16($0)
lw $31, 0($29)
lw $2, 1($29)
lw $3, 2($29)
lw $4, 3($29)
lw $5, 4($29)
lw $6, 5($29)
lw $7, 6($29)
lw $8, 7($29)
addi $29, $29, 8
jr $31


collect4DigitNumber: # return final result as $v0 ($28)
addi $29, $29, -8
sw $2, 0($29)
sw $17, 1($29)
sw $21, 2($29)
sw $10, 3($29)
sw $11, 4($29)
sw $12, 5($29)
sw $14, 6($29)
sw $22, 7($29)

addi $21, $21, 21 # $21 = 21 (current memory address of seven segment storing at)
addi $17, $17, 17 # $17 = 17 (used for final memory address of seven segment storing at)

_waitKeyLoop:
lw $2, 0($0) # $2 = keypad data
bne $13, $2, _recordNum # if GOT A NUMBER, branch
j _waitKeyLoop # else, keep checking for key

_recordNum:
sw $1, 22($0) # acknowledge that key has been read: store 1 into memory 1
sw $2, 0($21) # set first key pressed
sub $21, $21, $1 # subtract 1 from seven segment memory address storing at
sw $0, 22($0) # turn off acknowledge key: store 0 into memory 1
bne $21, $17, _waitKeyLoop # if memory address is not 21, go back to checking for key

_appendTogether: # if 4 digits have been collected
lw $10, 18($0) # $10 = get 4th most significant digit
lw $11, 19($0) # $11 = get 3rd most significant digit
lw $12, 20($0) # $12 = get 2nd most significant digit
lw $14, 21($0) # $14 = get most significant digit

addi $17, $0, 10 # 17 = 10
addi $21, $0, 100 # 21 = 100
addi $22, $0, 1000 # 22 = 1000

mul $17, $11, $17 # $17 = 3rd most significant digit * 10
mul $21, $12, $21 # $21 = 2nd most significant digit * 100
mul $22, $14, $22 # $22 = most significant digit * 1000

add $10, $10, $17 # $10 = add 2nd digit * 10        FINAL RESULT STORED IN $10
add $10, $10, $21 # $29 = add 3rd digit * 100
add $10, $10, $22 # $29 = add 4th digit * 1000

addi $28, $10, 0 # return final result as $v0 ($28)

lw $2, 0($29)
lw $17, 1($29)
lw $21, 2($29)
lw $10, 3($29)
lw $11, 4($29)
lw $12, 5($29)
lw $14, 6($29)
lw $22, 7($29)
addi $29, $29, 8
jr $31


waitForPin:
addi $29, $29, -1
sw $31, 0($29)

sw $1, 17($0) # turn LED 15 on to indicate waiting for pin
jal collect4DigitNumber
sw $0, 17($0) # turn LED 15 off to indicate done

lw $31, 0($29)
addi $29, $29, 1
jr $31 #return four digit value as $v0 ($28)


displayBalance: #argument is the pin whose balance we want to display
addi $29, $29, -8
sw $2, 0($29)
sw $3, 1($29)
sw $4, 2($29)
sw $5, 3($29)
sw $6, 4($29)
sw $7, 5($29)
sw $8, 6($29)
sw $9, 7($29)

lw $2, 0($26) # $2 = current balance at memory address of the pin passed in

_splitIntoDigits:
addi $3, $0, 0 # $3 = iterator = 0
addi $4, $0, 4 # $4 = max count of iterator
addi $5, $0, 18 # $5 = current seven segment memory address storing at
addi $6, $0, 10 # 10 for dividing

_splitDigitsLoop:
div $7, $2, $6 
mul $8, $7, $6
sub $9, $2, $8 # the digit
sw $9, 0($5)
add $2, $7, $0

addi $3, $3, 1
addi $5, $5, 1
bne $3, $4, _splitDigitsLoop

lw $2, 0($29)
lw $3, 1($29)
lw $4, 2($29)
lw $5, 3($29)
lw $6, 4($29)
lw $7, 5($29)
lw $8, 6($29)
lw $9, 7($29)
addi $29, $29, 8
jr $31


getDepositWithdrawButtons: #returns 0 if deposit 1 if withdraw
addi $29, $29, -3
sw $2, 0($29)
sw $3, 1($29)
sw $4, 2($29)

addi $3, $0, 11 # The number for deposit
addi $4, $0, 10 # The number for withdraw
_waitKeyLoop3:
lw $2, 0($0) # $2 = keypad data
blt $2, $4, _waitKeyLoop3 
blt $2, $3, _gotWith # is a withdraw
bne $2, $13, _gotDep # is a deposit
j _waitKeyLoop3

_gotDep:
sw $1, 22($0) # acknowledge that key has been read: store 1 into memory 22
addi $28, $0, 0
nop
sw $0, 22($0) # turn off acknowledge key: store 0 into memory 22
j _fin

_gotWith:
sw $1, 22($0) # acknowledge that key has been read: store 1 into memory 22
addi $28, $0, 1
nop
sw $0, 22($0) # turn off acknowledge key: store 0 into memory 22

_fin:
lw $2, 0($29)
lw $3, 1($29)
lw $4, 2($29)
addi $29, $29, 3
jr $31


depositOrWithdraw: #returns 0 if deposit 1 if withdraw, turn on LED
addi $29, $29, -1
sw $31, 0($29)

sw $1, 16($0) # turn LED 14 on to indicate waiting deposit or withdraw selection
jal getDepositWithdrawButtons
sw $0, 16($0) # turn LED 14 off 

lw $31, 0($29)
addi $29, $29, 1
jr $31



deposit: #a0 = pin to deposit to
addi $29, $29, -1
sw $31, 0($29)

jal startBeamBreak

lw $31, 0($29)
addi $29, $29, 1
jr $31


servoControl: #a0 ($26) = type of coin (0 = p, 1 = n, 2 = d, 3 = q)
addi $29, $29, -2
sw $31, 0($29)
sw $2, 1($29)

sw $1, 23($26) # store 1 at: start address of servos (23) + a0 ($26), so it is the actual servo address

_waitForBackSignal:
lw $2, 5($26) # load word from: start address of servo back done (5) + a0 ($26), so it is the actual servo back done address
bne $2, $0, _endServo 
j _waitForBackSignal

_endServo:
sw $0, 23($26) # store 0 (go back to initial position) at: 23 (start address of servos) + a0 ($26), so it is the actual servo address

lw $31, 0($29)
lw $2, 1($29)
addi $29, $29, 2
jr $31


withdraw: #a0 = pin to withdraw from
addi $29, $29, -14
sw $2, 0($29)
sw $4, 1($29)
sw $5, 2($29)
sw $6, 3($29)
sw $7, 4($29)
sw $8, 5($29)
sw $9, 6($29)
sw $10, 7($29)
sw $11, 8($29)
sw $12, 9($29)
sw $14, 10($29)
sw $31, 11($29)
sw $15, 12($29)
sw $16, 13($29)

jal displayBalance # pin hasnt changed

addi $12, $26, 0 # $12 = store pin to withdraw from 
lw $2, 0($26) # current balance
sw $1, 17($0) # turn LED 15 on to indicate waiting for amount to withdraw
jal collect4DigitNumber
sw $0, 17($0) # turn LED 15 off to indicate done
addi $4, $28, 0 # $4 = store the amount to withdraw from return value $28
addi $14, $4, 0 # store amount to withdraw again

_determineCoins:
addi $5, $0, 5
addi $6, $0, 10
addi $7, $0, 25

div $8, $4, $7 # $8 = number of quarters
addi $16, $8, 0
blt $8, $1, _dimes
addi $26, $0, 3 #quarter = 3 which is the argument
_quartersLoop:
lw $15, 9($26)
bne $15, $0, _actualQuarter
j _quartersLoop

_actualQuarter:
jal servoControl #a0 = 3
sub $8, $8, $1
bne $8, $0, _quartersLoop

_dimes:
mul $9, $16, $7 
sub $4, $4, $9
div $10, $4, $6 # $10 = number of dimes
addi $16, $10, 0
blt $10, $1, _nickels
addi $26, $0, 2 #dimes = 2 which is the argument
_dimesLoop:
lw $15, 9($26)
bne $15, $0, _actualDimes
j _dimesLoop

_actualDimes:
jal servoControl #a0 = 2
sub $10, $10, $1
bne $10, $0, _dimesLoop

_nickels:
mul $9, $16, $6
sub $4, $4, $9
div $11, $4, $5 # $11 = number of nickels
addi $16, $11, 0
blt $11, $1, _pennies
addi $26, $0, 1 #nickels = 1 which is the argument
_nickelsLoop:
lw $15, 9($26)
bne $15, $0, _actualNickels
j _nickelsLoop

_actualNickels:
jal servoControl #a0 = 1
sub $11, $11, $1
bne $11, $0, _nickelsLoop

_pennies:
mul $9, $16, $5
sub $4, $4, $9 # $4 = number of pennies
blt $4, $1, _endWithdraw
addi $26, $0, 0 #pennies = 0 which is the argument
_penniesLoop:
lw $15, 9($26)
bne $15, $0, _actualPennies
j _penniesLoop

_actualPennies:
jal servoControl #a0 = 0
sub $4, $4, $1
bne $4, $0, _penniesLoop

_endWithdraw:
sub $2, $2, $14 # $2 = currnet balance - amount withdrawn
sw $2, 0($12) #set balance
addi $26, $12, 0
jal displayBalance #a0 is now pin to display

lw $2, 0($29)
lw $4, 1($29)
lw $5, 2($29)
lw $6, 3($29)
lw $7, 4($29)
lw $8, 5($29)
lw $9, 6($29)
lw $10, 7($29)
lw $11, 8($29)
lw $12, 9($29)
lw $14, 10($29)
lw $31, 11($29)
lw $15, 12($29)
lw $16, 13($29)
addi $29, $29, 14 
jr $31



main:
addi $29, $29, 4096 # initialize stack pointer to be 4096 (top of RAM)
addi $1, $1, 1 # $1 = 1 (general purpose 1)
addi $13, $13, 13 # $13 = 13 (general purpose no key pressed)
# $26 = a0, $27= a1, $28 = v0

jal waitForPin # start waiting for a pin

addi $2, $28, 0 # $2 will hold the pin for future use since we may again modify $v0
addi $26, $28, 0 # $26 (a0) for display balance is the pin that was returned through $28 ($v0)
jal displayBalance # display current balance for pin

#MAKE THIS A LOOP
_loopDepositWithdraw:
jal depositOrWithdraw # ask user if want to deposit or withdraw and then collect value to deposit or withdraw

bne $28, $0, _withdrawing # $v0 = 0 if deposit 1 if withdraw
_depositing:
sw $1, 17($0)
jal deposit
j _finishDepositWithdraw

_withdrawing:
addi $26, $2, 0 # $26 (a0) for withdraw is the pin
jal withdraw

_finishDepositWithdraw:
j _loopDepositWithdraw

finish:
nop
nop
nop
j finish