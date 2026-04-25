# Extensive branch / jal / jalr control-flow test
# Success: reaches END with x30 = 8 and x31 = 0
# Failure: x31 contains failure code and loops forever

.text

# -------------------------
# Register setup
# -------------------------
    addi x1,  x0, 15
    addi x2,  x0, 25
    addi x3,  x0, 35
    addi x4,  x0, 45
    addi x5,  x0, 55
    addi x6,  x0, 65
    addi x7,  x0, 75
    addi x8,  x0, 85
    addi x9,  x0, 95

    # x10 = 0xFFFFF000
    # signed: negative
    # unsigned: very large
    lui  x10, 0xFFFFF

    addi x16, x0, 1
    addi x17, x0, 2
    addi x18, x0, 3
    addi x19, x0, 5

    addi x20, x0, 0
    addi x30, x0, 0      # pass counter
    addi x31, x0, 0      # failure code


# ============================================================
# TEST 1: Back-to-back NOT TAKEN branches
# ============================================================
BR_NT_CHAIN:
    beq  x1,  x2,  FAIL_01      # not taken
    bne  x3,  x3,  FAIL_02      # not taken
    blt  x2,  x1,  FAIL_03      # not taken
    bge  x1,  x2,  FAIL_04      # not taken

    bltu x10, x9,  FAIL_05      # unsigned huge < small? false
    bgeu x9,  x10, FAIL_06      # unsigned small >= huge? false

    blt  x1,  x10, FAIL_07      # signed 15 < negative? false
    bge  x10, x1,  FAIL_08      # signed negative >= 15? false

    addi x30, x30, 1


# ============================================================
# TEST 2: Taken branch chain
# Each branch should jump over a fail jump.
# ============================================================
BR_T_CHAIN:
    bne  x1, x2, BR_T_1
    jal  x0, FAIL_11

BR_T_1:
    beq  x3, x3, BR_T_2
    jal  x0, FAIL_12

BR_T_2:
    blt  x1, x2, BR_T_3
    jal  x0, FAIL_13

BR_T_3:
    bge  x2, x1, BR_T_4
    jal  x0, FAIL_14

BR_T_4:
    bltu x9, x10, BR_T_5       # small unsigned < huge unsigned
    jal  x0, FAIL_15

BR_T_5:
    bgeu x10, x9, BR_T_6       # huge unsigned >= small unsigned
    jal  x0, FAIL_16

BR_T_6:
    blt  x10, x1, BR_T_7       # negative < positive
    jal  x0, FAIL_17

BR_T_7:
    bge  x1, x10, BR_T_DONE    # positive >= negative
    jal  x0, FAIL_18

BR_T_DONE:
    addi x30, x30, 1


# ============================================================
# TEST 3: Taken branches followed immediately by bad branches
# This stresses flushing/squashing after taken branches.
# ============================================================
BR_FLUSH_TEST:
    bne x1, x2, BR_FLUSH_1
    jal x0, FAIL_21

BR_FLUSH_1:
    beq x0, x0, BR_FLUSH_2
    bne x1, x2, FAIL_22        # should be flushed/skipped

BR_FLUSH_2:
    blt x1, x2, BR_FLUSH_3
    bge x2, x1, FAIL_23        # should be flushed/skipped

BR_FLUSH_3:
    addi x30, x30, 1


# ============================================================
# TEST 4: Simple jal + jalr return
# jal must jump and write link correctly.
# jalr must return using that link.
# ============================================================
JAL_SIMPLE:
    addi x20, x0, 0

    jal x11, JAL_SIMPLE_FUNC

    # If jal failed to jump, x20 is still 0.
    # If jalr failed to return, we probably never get here.
    beq x20, x16, JAL_SIMPLE_OK
    jal x0, FAIL_31

JAL_SIMPLE_OK:
    addi x30, x30, 1
    jal x0, JAL_NESTED

JAL_SIMPLE_FUNC:
    addi x20, x20, 1
    jalr x0, x11, 0


# ============================================================
# TEST 5: Nested jal / jalr returns
# Expected x20 count:
# A enter = 1
# B enter = 2
# C enter = 3
# B after C = 4
# A after B = 5
# ============================================================
JAL_NESTED:
    addi x20, x0, 0

    jal x11, NEST_A

    beq x20, x19, JAL_NESTED_OK
    jal x0, FAIL_32

JAL_NESTED_OK:
    addi x30, x30, 1
    jal x0, JALR_OFFSET_TEST

NEST_A:
    addi x20, x20, 1
    jal x12, NEST_B
    addi x20, x20, 1
    jalr x0, x11, 0

NEST_B:
    addi x20, x20, 1
    jal x13, NEST_C
    addi x20, x20, 1
    jalr x0, x12, 0

NEST_C:
    addi x20, x20, 1
    jalr x0, x13, 0


# ============================================================
# TEST 6: jalr with immediate offset
# x14 points to the first fail instruction.
# jalr x0, x14, 8 should skip two instructions and land at OK.
# ============================================================
JALR_OFFSET_TEST:
    addi x20, x0, 0

    jal x14, JALR_OFFSET_FUNC

    addi x31, x0, 41
    jal x0, FAIL

JALR_OFFSET_OK:
    beq x20, x16, JALR_OFFSET_PASS
    jal x0, FAIL_42

JALR_OFFSET_PASS:
    addi x30, x30, 1
    jal x0, JALR_LSB_TEST

JALR_OFFSET_FUNC:
    addi x20, x20, 1
    jalr x0, x14, 8


# ============================================================
# TEST 7: jalr clears bit 0 of target address
# x15 = x14 + 1 makes the target odd.
# jalr should clear bit 0 and still land correctly.
# ============================================================
JALR_LSB_TEST:
    addi x20, x0, 0

    jal x14, JALR_LSB_FUNC

    addi x31, x0, 51
    jal x0, FAIL

JALR_LSB_OK:
    beq x20, x16, JALR_LSB_PASS
    jal x0, FAIL_52

JALR_LSB_PASS:
    addi x30, x30, 1
    jal x0, BR_JALR_MIX

JALR_LSB_FUNC:
    addi x20, x20, 1
    addi x15, x14, 1
    jalr x0, x15, 8


# ============================================================
# TEST 8: Branch + jal + jalr mixed together
# Expected x20:
# MIX_FUNC_A enter = 1
# MIX_FUNC_B enter = 2
# MIX_FUNC_A after return from B = 3
# ============================================================
BR_JALR_MIX:
    addi x20, x0, 0

    jal x11, MIX_FUNC_A

    beq x20, x18, BR_JALR_MIX_OK
    jal x0, FAIL_61

BR_JALR_MIX_OK:
    addi x30, x30, 1
    jal x0, END

MIX_FUNC_A:
    addi x20, x20, 1

    bne x1, x2, MIX_A_BRANCH_OK
    jal x0, FAIL_62

MIX_A_BRANCH_OK:
    beq x1, x1, MIX_A_CALL_B
    jal x0, FAIL_63

MIX_A_CALL_B:
    jal x12, MIX_FUNC_B
    addi x20, x20, 1
    jalr x0, x11, 0

MIX_FUNC_B:
    blt x1, x2, MIX_B_RET
    jal x0, FAIL_64

MIX_B_RET:
    addi x20, x20, 1
    jalr x0, x12, 0


# ============================================================
# Failure labels
# x31 tells which check failed.
# ============================================================
FAIL_01:
    addi x31, x0, 1
    jal x0, FAIL
FAIL_02:
    addi x31, x0, 2
    jal x0, FAIL
FAIL_03:
    addi x31, x0, 3
    jal x0, FAIL
FAIL_04:
    addi x31, x0, 4
    jal x0, FAIL
FAIL_05:
    addi x31, x0, 5
    jal x0, FAIL
FAIL_06:
    addi x31, x0, 6
    jal x0, FAIL
FAIL_07:
    addi x31, x0, 7
    jal x0, FAIL
FAIL_08:
    addi x31, x0, 8
    jal x0, FAIL

FAIL_11:
    addi x31, x0, 11
    jal x0, FAIL
FAIL_12:
    addi x31, x0, 12
    jal x0, FAIL
FAIL_13:
    addi x31, x0, 13
    jal x0, FAIL
FAIL_14:
    addi x31, x0, 14
    jal x0, FAIL
FAIL_15:
    addi x31, x0, 15
    jal x0, FAIL
FAIL_16:
    addi x31, x0, 16
    jal x0, FAIL
FAIL_17:
    addi x31, x0, 17
    jal x0, FAIL
FAIL_18:
    addi x31, x0, 18
    jal x0, FAIL

FAIL_21:
    addi x31, x0, 21
    jal x0, FAIL
FAIL_22:
    addi x31, x0, 22
    jal x0, FAIL
FAIL_23:
    addi x31, x0, 23
    jal x0, FAIL

FAIL_31:
    addi x31, x0, 31
    jal x0, FAIL
FAIL_32:
    addi x31, x0, 32
    jal x0, FAIL

FAIL_42:
    addi x31, x0, 42
    jal x0, FAIL
FAIL_52:
    addi x31, x0, 52
    jal x0, FAIL

FAIL_61:
    addi x31, x0, 61
    jal x0, FAIL
FAIL_62:
    addi x31, x0, 62
    jal x0, FAIL
FAIL_63:
    addi x31, x0, 63
    jal x0, FAIL
FAIL_64:
    addi x31, x0, 64
    jal x0, FAIL

FAIL:
    jal x0, FAIL


# ============================================================
# Success
# ============================================================
END:
    addi x31, x0, 0
    wfi
