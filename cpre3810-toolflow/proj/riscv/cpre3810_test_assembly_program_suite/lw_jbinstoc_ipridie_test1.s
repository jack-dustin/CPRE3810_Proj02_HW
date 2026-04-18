.data
val_zero:   .word 0x00000000
val_one:    .word 0x00000001
val_low12:  .word 0x00000FFF
val_upper:  .word 0x12345000
val_full:   .word 0x12345678

.text
.globl main

main:

# Base address of .data = 0x10010000
lui x1, 0x10010

#Test 1: Load 0x00000000
#Verifies lw returns all zero bits and no random 1s
lw x3, 0(x1)         # x3 = result   = 0x00000000
addi x2, x0, 0       # x2 = expected = 0x00000000

#Test 2: Load the smallest non zero value 0x00000001
#Ensures bit 0 is wired through correctly and lw does not zero out or ignore the lowest bit
lw x5, 4(x1)         # x5 = result   = 0x00000001
addi x4, x0, 1       # x4 = expected = 0x00000001

#Test 3: Load lower 12 bits 0x00000FFF
#Verifies bits [11:0] are all loaded correctly
lw x7, 8(x1)         # x7 = result   = 0x00000FFF
addi x6, x0, -1
srli x6, x6, 20      # x6 = expected = 0x00000FFF

#Test 4: Load upper 20 bits 0x12345000
#Confirms bits [31:12] are fetched properly
lw x9, 12(x1)        # x9 = result   = 0x12345000
lui x8, 0x12345      # x8 = expected = 0x12345000

#Test 5: Load full 32 bits 0x12345678
#Catches byte-drop or byte-swap bugs by requiring all 32 bits to be correct at once
lw x11, 16(x1)       # x11 = result   = 0x12345678
lui x10, 0x12345
addi x10, x10, 0x678 # x10 = expected = 0x12345678

wfi
