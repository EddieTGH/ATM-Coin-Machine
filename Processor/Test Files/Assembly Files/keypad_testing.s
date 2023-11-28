nop
nop
nop
nop
init:
j main

handleKeyPress:


getKey:
#send voltage through row 1, row 2, row 3, row 4. Check each of col 1-3 pins. If 1, branch to a handler with
#the arguments being the row and column where a 1 was found.

main:
