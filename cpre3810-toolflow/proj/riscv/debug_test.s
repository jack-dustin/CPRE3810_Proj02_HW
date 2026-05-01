# hazard_forwarding_locator_rars_safe.s
# x31 tells you which hazard/forwarding test failed.
#
# 0x11 = EX/MEM -> EX forwarding into rs1 broken
# 0x12 = EX/MEM -> EX forwarding into rs2 broken
# 0x21 = MEM/WB -> EX forwarding broken
# 0x31 = forwarding priority broken
# 0x41 = load-use stall / load forwarding broken
# 0x42 = store-data forwarding broken
# 0x51 = branch depending on ALU result broken
# 0x52 = branch depending on load result broken
# 0x61 = taken branch flush broken
# 0x62 = jal flush broken
# 0x63 = jalr flush broken
# 0x7F = all tests passed

.data
.align 2
test_data:
    .word 0
    .word 0
    .word 0
    .word 0

.text
.globl main

main:
    addi x31, x0, 0
    addi x20, x0, 0
    addi x21, x0, 0
    addi x22, x0, 0

    # Load data base address.
    # Kept separated from real tests so address setup is not the hazard being tested.
    lui  x28, %hi(test_data)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x28, x28, %lo(test_data)

############################################################
# Test 1A: EX/MEM -> EX forwarding into rs1
############################################################
test_ex_forward_rs1:
    addi x5, x0, 7
    add  x6, x5, x0

    addi x7, x0, 7
    sub  x29, x6, x7

    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0

    beq  x29, x0, test_ex_forward_rs2
    addi x31, x0, 0x11
    beq  x0, x0, done

############################################################
# Test 1B: EX/MEM -> EX forwarding into rs2
############################################################
test_ex_forward_rs2:
    addi x5, x0, 9
    add  x6, x0, x5

    addi x7, x0, 9
    sub  x29, x6, x7

    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0

    beq  x29, x0, test_memwb_forward
    addi x31, x0, 0x12
    beq  x0, x0, done

############################################################
# Test 2: MEM/WB -> EX forwarding
############################################################
test_memwb_forward:
    addi x5, x0, 13
    addi x10, x0, 1
    add  x6, x5, x0

    addi x7, x0, 13
    sub  x29, x6, x7

    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0

    beq  x29, x0, test_forward_priority
    addi x31, x0, 0x21
    beq  x0, x0, done

############################################################
# Test 3: Forwarding priority
# Newer EX/MEM value must beat older MEM/WB value.
############################################################
test_forward_priority:
    addi x5, x0, 1
    addi x5, x5, 1
    add  x6, x5, x0

    addi x7, x0, 2
    sub  x29, x6, x7

    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0

    beq  x29, x0, test_load_use
    addi x31, x0, 0x31
    beq  x0, x0, done

############################################################
# Test 4: Load-use hazard
############################################################
test_load_use:
    addi x5, x0, 99
    sw   x5, 0(x28)

    lw   x8, 0(x28)
    add  x9, x8, x8

    addi x7, x0, 198
    sub  x29, x9, x7

    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0

    beq  x29, x0, test_store_forward
    addi x31, x0, 0x41
    beq  x0, x0, done

############################################################
# Test 5: Store-data forwarding
############################################################
test_store_forward:
    addi x10, x0, 77
    sw   x10, 4(x28)

    lw   x11, 4(x28)

    addi x7, x0, 77
    sub  x29, x11, x7

    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0

    beq  x29, x0, test_branch_alu_dep
    addi x31, x0, 0x42
    beq  x0, x0, done

############################################################
# Test 6: Branch depending on ALU result
# Branch resolves in Decode in your design.
############################################################
test_branch_alu_dep:
    addi x12, x0, 1
    beq  x12, x0, branch_alu_bad

    beq  x0, x0, test_branch_load_dep

branch_alu_bad:
    addi x31, x0, 0x51
    beq  x0, x0, done

############################################################
# Test 7: Branch depending on load result
############################################################
test_branch_load_dep:
    addi x5, x0, 5
    sw   x5, 8(x28)

    lw   x13, 8(x28)
    beq  x13, x0, branch_load_bad

    beq  x0, x0, test_taken_branch_flush

branch_load_bad:
    addi x31, x0, 0x52
    beq  x0, x0, done

############################################################
# Test 8: Taken branch flush
############################################################
test_taken_branch_flush:
    beq  x0, x0, branch_target

    # Wrong path. Must be flushed.
    addi x20, x0, 66

branch_target:
    addi x7, x0, 0
    sub  x29, x20, x7

    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0

    beq  x29, x0, test_jal_flush
    addi x31, x0, 0x61
    beq  x0, x0, done

############################################################
# Test 9: jal flush
############################################################
test_jal_flush:
    jal  x1, jal_target

    # Wrong path. Must be flushed.
    addi x21, x0, 77

jal_target:
    addi x7, x0, 0
    sub  x29, x21, x7

    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0

    beq  x29, x0, test_jalr_flush
    addi x31, x0, 0x62
    beq  x0, x0, done

############################################################
# Test 10: jalr flush
############################################################
test_jalr_flush:
    lui  x5, %hi(jalr_target)
    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0
    addi x5, x5, %lo(jalr_target)

    jalr x0, 0(x5)

    # Wrong path. Must be flushed.
    addi x22, x0, 88

jalr_target:
    addi x7, x0, 0
    sub  x29, x22, x7

    addi x0, x0, 0
    addi x0, x0, 0
    addi x0, x0, 0

    beq  x29, x0, pass
    addi x31, x0, 0x63
    beq  x0, x0, done

pass:
    addi x31, x0, 0x7F

done:
    wfi