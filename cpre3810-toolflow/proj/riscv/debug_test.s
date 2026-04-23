# data section
.data
    test2_val: .word 0x00000005
# code/instruction section
#.text
#Test 1
#addi x1, x0, 5    # x1 = 5
#addi x2, x1, 3    # x2 = x1 + 3 — RAW on x1

#Test 2
# la   x2, test2_val    # x2 = actual address of test2_val in .data segment
# lw   x1, 0(x2)        # x1 = 5  — load-use hazard on next instruction
# addi x3, x1, 1        # x3 should = 6   (= 1 if stall failed, x1 was still 0)



#Test 3 
# lui   x3, 0x10000     # x3 = 0x10000000
# addi  x3, x3, 0x41    # x3 = 0x10000041  (note: RARS uses 0x41, not 0x041)
# addi  x1, x0, 99      # x1 = 99  — producer; bits[24:20] of next instr = 00001 = x1
#                         # before fix: hazard unit sees rs2-field=x1, false stall fires
#                         # after fix:  no stall (I-type masked out)
# xori  x4, x3, 0x41    # x4 = 0x10000041 XOR 0x41 = 0x10000000
#                         # encoding: imm[4:0]=00001, which matches x1 above

#test 4
#.text
#main:
#    addi x1, x0, 1       # x1 = 1
#    addi x2, x0, 2       # x2 = 2
 #   add  x3, x1, x2      # x3 = 3  (RAW on x1, x2)
  # addi x5, x4, 5       # x5 = 12 (RAW on x4)
    #jal  x6, target       # x6 = PC+4 of this instr, jump to target  <-- 6th instruction
#    addi x7, x0, 0xFF     # x7 = 0xFF  -- should be SKIPPED (wrong-path)
#    addi x8, x0, 0xFF     # x8 = 0xFF  -- should be SKIPPED (wrong-path)

#target:
#    addi x9, x5, 1       # x9 = 13  (RAW on x5 -- tests that x5 survived the flush)
#    ebreak

.text
.globl _start
_start:
    lui  ra, 0x00400
<<<<<<< HEAD
    addi ra, ra, 0x00c   # manually point at RET1
    j    FUNC
RET1:
    addi t0, x0, 1
    wfi
FUNC:
    jr   ra
wfi
=======
    addi ra, ra, 0x010   # RET1 address for this layout
    j    FUNC

FUNC:
    jr   ra

RET1:
    addi t0, x0, 1
    j END

END:
    wfi
>>>>>>> isaiah-branch
