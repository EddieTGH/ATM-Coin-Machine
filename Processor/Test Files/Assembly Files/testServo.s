nop
nop
nop
nop
init:
j main

main:
addi $1, $1, 1 # $1 = 1 (set led value)
addi $4, $4, 10000 # $4 = 10000 (debounce counter)
j servoLeft

servoLeft:
sw $1, 23($0) # Turn Servo all the way to the left
j incrementCounter

incrementCounter:
addi $2, $2, 1 # add 1 to debounce counter
sw $1, 17($0) #turn LED 15 on to signal DEBOUNCE ON for servoLeft
bne $2, $4, incrementCounter # if debounce counter is not 10000, keep looping
sw $0, 17($0) #turn LED 15 off to signal DEBOUNCE OFF for servoLeft
sub $2, $2, $2
j servoRight

servoRight:
sw $0, 23($0) # Turn Servo all the way to the right
j incrementCounter2

incrementCounter2: 
addi $2, $2, 1 # add 1 to debounce counter
sw $1, 16($0) #turn LED 14 on to signal DEBOUNCE ON for servoRight
bne $2, $4, incrementCounter2 # if debounce counter is not 10000, keep looping
sw $0, 16($0) #turn LED 14 on to signal DEBOUNCE OFF for servoRight
sub $2, $2, $2
j servoLeft
