.data
quarters_dispense: .word 0
dimes_dispense: .word 0
nickels_dispense: .word 0
pennies_dispense: .word 0

.text
.globl main
main:
    # Initialize amount to some value (e.g., 87)
    li $t0, 87

    # Calculate quarters_dispense
    li $t1, 25
    div $t2, $t0, $t1
    sw $t2, quarters_dispense

    # Calculate amountAfterQuarters
    mul $t2, $t2, $t1
    sub $t0, $t0, $t2

    # Calculate dimes_dispense
    li $t1, 10
    div $t2, $t0, $t1
    sw $t2, dimes_dispense

    # Calculate amountAfterDimes
    mul $t2, $t2, $t1
    sub $t0, $t0, $t2

    # Calculate nickels_dispense
    li $t1, 5
    divu $t2, $t0, $t1
    sw $t2, nickels_dispense

    # Calculate amountAfterNickels
    mul $t2, $t2, $t1
    sub $t0, $t0, $t2

    # pennies_dispense is the remainder
    sw $t0, pennies_dispense
