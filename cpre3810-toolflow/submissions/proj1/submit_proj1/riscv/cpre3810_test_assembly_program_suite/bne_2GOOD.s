.text
.globl main
main:
    # Initialize registers
    lui  x5, 0x7FFFF
    addi x5, x5, -1         # x5 = 0x7FFFFFFF

    lui  x6, 0x80000        # x6 = 0x80000000

    lui  x7, 0x7FFFF
    addi x7, x7, -1         # x7 = 0x7FFFFFFF

    # Test 1: x5 vs x6
    # bne should branch, so x28 should stay 1
    addi x28, x0, 1
    bne  x5, x6, test2
    addi x28, x0, 0

test2:
    # Test 2: x5 vs x7
    # bne should NOT branch, so x29 should become 1
    addi x29, x0, 0
    bne  x5, x7, done
    addi x29, x0, 1

done:
    wfi
