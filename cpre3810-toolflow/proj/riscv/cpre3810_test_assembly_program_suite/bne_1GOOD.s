.text
.globl main
main:
    # Initialize registers
    addi x5, x0, 0      # x5 = 0
    addi x6, x0, 0      # x6 = 0
    addi x7, x0, 1      # x7 = 1

    # Test 1: equal registers
    # bne should NOT branch, so x28 should become 1
    addi x28, x0, 0
    bne  x5, x6, test2
    addi x28, x0, 1

test2:
    # Test 2: unequal registers
    # bne should branch, so x29 should stay 1
    addi x29, x0, 1
    bne  x5, x7, done
    addi x29, x0, 0

done:
    wfi
