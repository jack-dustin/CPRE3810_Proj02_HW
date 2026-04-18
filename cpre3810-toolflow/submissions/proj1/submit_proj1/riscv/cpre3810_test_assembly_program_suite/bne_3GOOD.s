.text
.globl main
main:
    # Initialize registers
    addi x5, x0, 0          # x5 = 0
    addi x6, x0, 1          # x6 = 1

    # Test 1: bne with positive offset
    # Expected: branch taken, so x28 stays 1
    addi x28, x0, 1
    bne  x5, x6, pos_done
    addi x28, x0, 0         # only runs if branch is NOT taken

    # Padding to increase positive offset if desired
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    # add more nop lines here if you want a larger offset

pos_done:
    # Test 2: bne with negative offset
    # Expected: backward branch taken, so x29 becomes 1
    addi x29, x0, 0
    addi x30, x0, 0
    addi x31, x0, 1

    # Skip over backward_target on the first pass
    bne  x30, x31, branch_site

backward_target:
    addi x29, x0, 1
    bne  x30, x31, done

    # Padding to increase negative offset if desired
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    # add more nop lines here if you want a larger negative offset

branch_site:
    bne  x5, x6, backward_target
    addi x29, x0, 0         # only runs if backward branch is NOT taken

done:
    wfi
