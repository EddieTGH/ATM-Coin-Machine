nop             # Sort
nop             # Author: Jack Proudfoot
nop             
nop
init:
addi $sp, $zero, 256        # $sp = 256
nop
nop
nop
addi $27, $zero, 3840       # $27 = 3840 address for bottom of heap
nop
nop
nop
addi $t0, $zero, 50
nop
nop
nop
addi $t1, $zero, 3
nop
nop
nop
sw $t1, 0($t0)
nop
nop
nop
addi $t1, $zero, 1
nop
nop
nop
sw $t1, 1($t0)
nop
nop
nop
addi $t1, $zero, 4
nop
nop
nop
sw $t1, 2($t0)
nop
nop
nop
addi $t1, $zero, 2
nop
nop
nop
sw $t1, 3($t0)
nop
nop
nop
add $a0, $zero, $t0
nop
nop
nop
j main
nop
nop
nop
malloc:                     # $a0 = number of words to allocate
nop
nop
nop
sub $27, $27, $a0           # allocate $a0 words of memory
nop
nop
nop
blt $sp, $27, mallocep      # check for heap overflow
nop
nop
nop
mallocep:
nop
nop
nop
add $v0, $27, $zero
nop
nop
nop
jr $ra
nop
nop
nop
buildlist:                  # $a0 = memory address of input data
nop
nop
nop
sw $ra, 0($sp)
nop
nop
nop
addi $sp, $sp, 1
nop
nop
nop
add $t0, $a0, $zero         # index of input data
nop
nop
nop
add $t1, $zero, $zero       # current list pointer
nop
nop
nop
addi $a0, $zero, 0
nop
nop
nop
jal malloc
nop
nop
nop
addi $t3, $v0, -3           # list head pointer
nop
nop
nop
lw $t2, 0($t0)              # load first data value
nop
nop
nop
j blguard
nop
nop
nop
blstart:
addi $a0, $zero, 3
nop
nop
nop
jal malloc
nop
nop
nop
sw $t2, 0($v0)              # set new[0] = data
nop
nop
nop
sw $t1, 1($v0)              # set new[1] = prev
nop
nop
nop
sw $zero, 2($v0)            # set new[2] = next
nop
nop
nop
sw $v0, 2($t1)              # set curr.next = new
nop
nop
nop
addi $t0, $t0, 1            # increment input data index
nop
nop
nop
lw $t2, 0($t0)              # load next input data value
nop
nop
nop
add $t1, $zero, $v0         # set curr = new
nop
nop
nop
blguard:
nop
nop
nop
bne $t2, $zero, blstart
nop
nop
nop
add $v0, $t3, $zero         # set $v0 = list head
nop
nop
nop
addi $sp, $sp, -1
nop
nop
nop
lw $ra, 0($sp)
nop
nop
nop
jr $ra
nop
nop
nop
sort:                       # $a0 = head of list
nop
nop
nop
sw $ra, 0($sp)
nop
nop
nop
addi $sp, $sp, 1
nop
nop
nop
sortrecur:
nop
nop
nop
addi $t7, $zero, 0          # $t7 = 0
nop
nop
nop
add $t0, $a0, $zero         # $t0 = head
nop
nop
nop
add $t1, $t0, $zero         # $t1 = current
nop
nop
nop
j siguard
nop
nop
nop
sortiter:
nop
nop
nop
lw $t2, 0($t1)              # $t2 = current.data
nop
nop
nop
lw $t3, 0($t6)              # $t3 = current.next.data
nop
nop
nop
blt $t2, $t3, sinext
nop
nop
nop
addi $t7, $zero, 1          # $t7 = 1
nop
nop
nop
lw $t4, 1($t1)              # $t4 = current.prev
nop
nop
nop
bne $t4, $zero, supprev
nop
nop
nop
j supprevd
nop
nop
nop
supprev:
nop
nop
nop
sw $t6, 2($t4)              # current.prev.next = current.next
nop
nop
nop
supprevd:
nop
nop
nop
sw $t4, 1($t6)              # current.next.prev = current.prev
nop
nop
nop
lw $t5, 2($t6)              # $t5 = current.next.next
nop
nop
nop
bne $t5, $zero, supnnprev
nop
nop
nop
j supnnprevd
nop
nop
nop
supnnprev:
nop
nop
nop
sw $t1, 1($t5)              # current.next.next.prev = current
nop
nop
nop
supnnprevd:
nop
nop
nop
sw $t5, 2($t1)              # current.next = current.next.next
nop
nop
nop
sw $t1, 2($t6)              # current.next.next = current
nop
nop
nop
sw $t6, 1($t1)              # current.prev = current.next
nop
nop
nop
bne $t0, $t1, sinext
nop
nop
nop
add $t0, $t6, $zero         # head = current.next
nop
nop
nop
sinext:
nop
nop
nop
add $t1, $t6, $zero         # $t1 = current.next
nop
nop
nop
siguard:
nop
nop
nop
lw $t6, 2($t1)              # $t6 = current.next
nop
nop
nop
bne $t6, $zero, sortiter
nop
nop
nop
add $a0, $t0, $zero
nop
nop
nop
bne $t7, $zero, sortrecur
nop
nop
nop
add $v0, $t0, $zero         # $v0 = head
nop
nop
nop
addi $sp, $sp, -1
nop
nop
nop
lw $ra, 0($sp)
nop
nop
nop
jr $ra
nop
nop
nop
main:
nop
nop
nop
jal buildlist
nop
nop
nop
add $t0, $v0, $zero         # $t0 = head of list
nop
nop
nop
add $a0, $t0, $zero         # $a0 = head of list
nop
nop
nop
jal sort
nop
nop
nop
add $t0, $v0, $zero         # $t0 = head of sorted list
nop
nop
nop
add $t5, $zero, $zero
nop
nop
nop
add $t6, $zero, $zero
nop
nop
nop
add $t1, $t0, $zero
nop
nop
nop
j procguard
nop
nop
nop
proclist:
nop
nop
nop
lw $t2, 0($t1)
nop
nop
nop
add $t5, $t5, $t2
nop
nop
nop
sll $t6, $t6, 3
nop
nop
nop
add $t6, $t6, $t5
nop
nop
nop
lw $t1, 2($t1)
nop
nop
nop
procguard:
nop
nop
nop
bne $t1, $zero, proclist
nop
nop
nop
stop:
nop
nop
nop
j stop