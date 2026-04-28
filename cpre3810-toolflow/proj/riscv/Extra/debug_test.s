# data section
    .data
test2_val:
    .word  0x00000005
# code/instruction section
#.text
#Test 1
#addi x1, x0, 5 # x1 = 5
#addi x2, x1, 3 # x2 = x1 + 3 — RAW on x1

#Test 2
# la x2, test2_val # x2 = actual address of test2_val in .data segment
# lw x1, 0(x2) # x1 = 5 — load-use hazard on next instruction
# addi x3, x1, 1 # x3 should = 6 (= 1 if stall failed, x1 was still 0)



#Test 3
# lui x3, 0x10000 # x3 = 0x10000000
# addi x3, x3, 0x41 # x3 = 0x10000041 (note: RARS uses 0x41, not 0x041)
# addi x1, x0, 99 # x1 = 99 — producer; bits[24: 20] of next instr = 00001 = x1
# # before fix: hazard unit sees rs2-field=x1, false stall fires
# # after fix: no stall (I-type masked out)
# xori x4, x3, 0x41 # x4 = 0x10000041 XOR 0x41 = 0x10000000
# # encoding: imm[4: 0]=00001, which matches x1 above

#test 4
#.text
#main:
# addi x1, x0, 1 # x1 = 1
# addi x2, x0, 2 # x2 = 2
# add x3, x1, x2 # x3 = 3 (RAW on x1, x2)
# addi x5, x4, 5 # x5 = 12 (RAW on x4)
#jal x6, target # x6 = PC+4 of this instr, jump to target <-- 6th instruction
# addi x7, x0, 0xFF # x7 = 0xFF -- should be SKIPPED (wrong-path)
# addi x8, x0, 0xFF # x8 = 0xFF -- should be SKIPPED (wrong-path)

#target:
# addi x9, x5, 1 # x9 = 13 (RAW on x5 -- tests that x5 survived the flush)
# ebreak

#.text
#.globl _start
#_start:
# lui ra, 0x00400
# addi ra, ra, 0x010 # RET1 address for this layout
# j FUNC

#FUNC:
# jr ra
#
#RET1:
# addi t0, x0, 1
# j END

#END:
# wfi

#     .data
# res:
#     .word  -1-1-1-1
# nodes:
#     .byte  97
#     .byte  98
#     .byte  99
#     .byte  100
# adjacencymatrix:
#     .word  6
#     .word  0
#     .word  0
#     .word  3
# visited:
#     .byte  0 0 0 0
# res_idx:
#     .word  3

#     .text
#     .globl _start
# _start:
#     lui    sp, 0x10011
#     addi   sp, sp, 0
#     lui    fp, 0x00000
#     addi   fp, fp, 0
#     la     ra, pump
#     j      main

# pump:
#     j      end
#     ebreak

# main:
#     addi   sp, sp, -40
#     sw     ra, 36(sp)
#     sw     fp, 32(sp)
#     add    fp, sp, x0
#     sw     x0, 24(sp)
#     j      main_loop_control

# main_loop_body:
#     lw     t4, 24(fp)
#     la     ra, trucks
#     j      is_visited

# trucks:
#     xori   t2, t2, 1
#     andi   t2, t2, 0xff
#     beq    t2, x0, kick

# kick:
#     lw     t2, 24(fp)
#     addi   t2, t2, 1
#     sw     t2, 24(fp)

# main_loop_control:
#     lw     t2, 24(fp)
#     slti   t2, t2, 4
#     beq    t2, x0, hew
#     j      main_loop_body

# hew:
#     wfi

# is_visited:
#     addi   sp, sp, -32
#     sw     fp, 28(sp)
#     mv     fp, sp
#     sw     t4, 32(fp)
#     ori    t2, x0, 1
#     sw     t2, 8(fp)
#     sw     x0, 12(fp)
#     j      evasive

# justify:
#     lw     t2, 8(fp)
#     slli   t2, t2, 8
#     sw     t2, 8(fp)
#     lw     t2, 12(fp)
#     addi   t2, t2, 1
#     sw     t2, 12(fp)

# evasive:
#     lw     t3, 12(fp)
#     lw     t2, 32(fp)
#     slt    t2, t3, t2
#     beq    t2, x0, representative
#     j      justify

# representative:
#     la     t2, visited
#     lw     t2, 0(t2)
#     sw     t2, 16(fp)
#     lw     t3, 16(fp)
#     lw     t2, 8(fp)
#     and    t2, t3, t2
#     slt    t2, x0, t2
#     andi   t2, t2, 0xff
#     mv     sp, fp
#     lw     fp, 28(sp)
#     addi   sp, sp, 32
#     jr     ra

# end:
#     wfi

# .data
# visited:
#     .word 1

# .text
# .globl _start
# _start:
#     la    t2, visited
#     lw    t2, 0(t2)
#     addi  t3, x0, 1
#     beq   t2, t3, GOOD
#     j     BAD

# GOOD:
#     addi  t0, x0, 1
#     wfi

# BAD:
#     addi  t0, x0, 9
#     wfi

# .data
# visited:
#     .word 1

# .text
# .globl _start
# _start:
#     lui   sp, 0x10011
#     addi  sp, sp, 0
#     addi  fp, sp, 0

#     addi  t2, x0, 1
#     sw    t2, 8(fp)        # mem[fp+8] = 1
#     sw    x0, 12(fp)       # mem[fp+12] = 0
#     addi  t4, x0, 1
#     sw    t4, 32(fp)       # mem[fp+32] = 1

#     j     evasive

# justify:
#     lw    t2, 8(fp)
#     slli  t2, t2, 8
#     sw    t2, 8(fp)
#     lw    t2, 12(fp)
#     addi  t2, t2, 1
#     sw    t2, 12(fp)

# evasive:
#     lw    t3, 12(fp)
#     lw    t2, 32(fp)
#     slt   t2, t3, t2
#     beq   t2, x0, representative
#     j     justify

# representative:
#     la    t2, visited
#     lw    t2, 0(t2)
#     sw    t2, 16(fp)
#     lw    t3, 16(fp)
#     lw    t2, 8(fp)
#     and   t2, t3, t2
#     slt   t2, x0, t2
#     andi  t2, t2, 0xff
#     addi  t0, x0, 1
#     wfi

.text
.globl _start
_start:
    addi  t0, x0, 1
    wfi

AFTER:
    addi  t1, x0, 9
    j     AFTER

