.data

.text
.globl main

main:

    # lui x5, 0x10010
    addi x1, x0, 0x1        # Load x1 with 0x000000001
    slli x1, x1, 12         # shift 1 left by 12 bits   -> 0x0000.1001
    addi x1, x1, 1          # Gets us 0x0000.1001
    slli x1, x1, 16         # Shift 0x1001 left by 16 bits -> 0x1001.0000
    add x5, x1, x0         # Move Contents from x1 to x5

	# Test 1: Common case store - storing a word, storing at an offset
	# lui x5, 0x10010 # load base data memory address into x5
	addi x6, x0, 1 	# load a value to store
	sw x6, 0(x5)	# store a word
	sw x6, 4(x5)	# store a word at an offset
	# expect value 1 at 0x10010000 and 0x10010000

exit:
	
wfi
