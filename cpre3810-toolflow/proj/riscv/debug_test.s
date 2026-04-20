# data section
.data
    test2_val: .word 0x00000005
# code/instruction section
.text
#Test 1
#addi x1, x0, 5    # x1 = 5
#addi x2, x1, 3    # x2 = x1 + 3 — RAW on x1

#Test 2
# la   x2, test2_val    # x2 = actual address of test2_val in .data segment
# lw   x1, 0(x2)        # x1 = 5  — load-use hazard on next instruction
# addi x3, x1, 1        # x3 should = 6   (= 1 if stall failed, x1 was still 0)



#Test 3 
lui   x3, 0x10000     # x3 = 0x10000000
addi  x3, x3, 0x41    # x3 = 0x10000041  (note: RARS uses 0x41, not 0x041)
addi  x1, x0, 99      # x1 = 99  — producer; bits[24:20] of next instr = 00001 = x1
                        # before fix: hazard unit sees rs2-field=x1, false stall fires
                        # after fix:  no stall (I-type masked out)
xori  x4, x3, 0x41    # x4 = 0x10000041 XOR 0x41 = 0x10000000
                        # encoding: imm[4:0]=00001, which matches x1 above
wfi