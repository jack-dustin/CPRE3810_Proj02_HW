# Branch hazard stress test for a 5-stage-ish RV32 pipeline
# Expected end state if everything works:
#   x30 = 123
#   x31 = 8
#
# This file intentionally includes:
#   1. ALU -> branch rs1
#   2. ALU -> branch rs2
#   3. ALU -> branch taken
#   4. EX/MEM -> Decode branch forwarding with one gap
#   5. normal load-use
#   6. load -> branch rs1
#   7. load -> branch rs2
#   8. load -> branch taken
#
# No ecall/printing. Ends with WFI.

.text
.globl _start
_start:
    addi x30, x0, 0
    addi x31, x0, 0

    lui sp, 0x7FFFF
    addi sp, sp, -64

# 1. ALU -> branch rs1. Should stall once, then forward EX/MEM -> Decode.
    addi x5, x0, 1
    beq x5, x0, FAIL
    addi x31, x31, 1

# 2. ALU -> branch rs2. Should stall once, then forward EX/MEM -> Decode.
    addi x6, x0, 2
    beq x0, x6, FAIL
    addi x31, x31, 1

# 3. ALU -> branch taken. Should stall once, then branch should take.
    addi x7, x0, 5
    bge x7, x0, TAKE_ALU_BRANCH
    beq x0, x0, FAIL
TAKE_ALU_BRANCH:
    addi x31, x31, 1

# 4. Producer is already in MEM when branch compares. Should forward EX/MEM, ideally no stall.
    addi x8, x0, 3
    addi x1, x0, 0
    beq x8, x0, FAIL
    addi x31, x31, 1

# 5. Normal load-use. Should stall once, then forward into EX.
    addi x11, x0, 11
    sw x11, 0(sp)
    lw x12, 0(sp)
    add x13, x12, x0
    addi x1, x0, 0
    beq x13, x11, TAKE_LOAD_USE
    beq x0, x0, FAIL
TAKE_LOAD_USE:
    addi x31, x31, 1

# 6. Load -> branch rs1. If no MEM/WB -> Decode forward, should stall until regfile has the loaded value.
    addi x14, x0, 12
    sw x14, 4(sp)
    lw x15, 4(sp)
    beq x15, x0, FAIL
    addi x31, x31, 1

# 7. Load -> branch rs2. Same as above but dependency is on rs2.
    addi x16, x0, 13
    sw x16, 8(sp)
    lw x17, 8(sp)
    beq x0, x17, FAIL
    addi x31, x31, 1

# 8. Load -> branch taken. Loaded value is zero, so branch should take.
    addi x18, x0, 0
    sw x18, 12(sp)
    lw x19, 12(sp)
    beq x19, x0, TAKE_LOAD_BRANCH
    beq x0, x0, FAIL
TAKE_LOAD_BRANCH:
    addi x31, x31, 1

PASS:
    addi x30, x0, 123
    wfi

FAIL:
    addi x30, x0, -1
    wfi
