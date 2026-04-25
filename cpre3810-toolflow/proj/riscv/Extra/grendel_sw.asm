#
# Topological sort using an adjacency matrix. Maximum 4 nodes.
#
# The expected output of this program is that the 1st 4 addresses of the data segment
# are [4,0,3,2]. should take ~2000 cycles in a single cycle procesor.
#
# Adapted to RISC-V by Connor J. Link (3.1.2025)
# Per testing [3, 0, 2, 1] is the expected output (matches the original grendel.s in MARS)
#
# SOFTWARE-SCHEDULED for 5-stage RISC-V pipeline (IF/ID/EX/MEM/WB)
# No hardware forwarding. Hazard rules:
#   ALU -> USE : 2 NOP slots (rescheduled instructions fill slots where possible)
#   LOAD -> USE: 3 NOP slots
#   BRANCH/JAL/JALR: 2 NOP slots (branch resolves at end of EX)
#
# Comment legend:
#   [D n/2 reg]  = data-hazard NOP slot n of 2 for register reg
#   [L n/3 reg]  = load-hazard NOP slot n of 3 for register reg
#   [C n/2]      = control-hazard NOP slot n of 2
#   RESCHEDULED  = useful instruction moved here to fill a hazard slot
#   FREE         = no extra NOP needed (instruction naturally fills slot)
#

.data
res:
        .word -1-1-1-1
nodes:
        .byte   97 # a
        .byte   98 # b
        .byte   99 # c
        .byte   100 # d
adjacencymatrix:
        .word   6
        .word   0
        .word   0
        .word   3
visited:
        .byte 0 0 0 0
res_idx:
        .word   3
.text
        # Setup: li/la use lasw where result is needed immediately.
        # li sp = lui+addi (pseudo). Result of li needs 2 NOPs before use.
        # la ra = lui+addi (pseudo). Same.
        #li    sp, 0x10011000     # sp = stack base
        lui sp, 0x10011
        nop
        nop
        nop
        addi sp, sp, 0x000
        nop
        nop
        #li    fp, 0              # [D 1/2 li sp -> sw uses sp] RESCHEDULED: fp = 0
        add fp, x0, x0
        nop
        nop
        lasw  ra, pump           # [D 2/2 li sp] lasw: lui+3nop+ori for ra
                                 # lasw itself inserts 3 NOPs between lui and ori,
                                 # so ra is safe immediately after lasw completes.
                                 # lasw also fills D1/2 for fp (fp done 1 inst ago, lasw takes 5 cycles)
        j     main
        nop                      # [C 1/2 j main]
        nop                      # [C 2/2 j main]
pump:
        j     end
        nop                      # [C 1/2 j end]
        nop                      # [C 2/2 j end]
        ebreak                   # halt (unreachable but kept for structure)


main:
        addi  sp, sp, -40        # reserve 40 bytes on stack
        nop                      # [D 1/2 addi sp -> sw ra,36(sp)]
        nop                      # [D 2/2 addi sp -> sw ra,36(sp)]
        sw    ra, 36(sp)         # save return address
        sw    fp, 32(sp)         # [D 1/2 sw ra] FREE: sw has no output reg; fp safe
        add   fp, sp, x0         # fp = sp  [D 2/2 sw ra] RESCHEDULED: fp = sp (sp safe: written 3 ago)
        sw    x0, 24(sp)         # mem[sp+24] = 0 (loop counter i=0)
                                 # [D 1/2 add fp; D 1/2 addi sp->sw x0]
                                 # sw reads sp (safe, 4 insts old), fp (safe, 1 inst old? fp written above)
                                 # add fp writes fp 1 inst ago → sw fp,32(sp) ALREADY EXECUTED above.
                                 # This sw x0 reads sp (safe) not fp → OK.
        j     main_loop_control
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]

main_loop_body:
        lw    t4, 24(fp)         # t4 = i (loop variable)
        lasw  ra, trucks         # [L 1/3 lw t4] lasw fills 3+ slots: lui(1)+nop+nop+nop+ori(5 total)
                                 # After lasw: ra is safe. t4 safe (3 NOPs elapsed inside lasw).
        j     is_visited
        nop                      # [C 1/2 j is_visited]
        nop                      # [C 2/2 j is_visited]
trucks:
        xori  t2, t2, 1          # t2 = t2 ^ 1  (t2 is return from is_visited)
        nop                      # [D 1/2 xori t2]
        nop                      # [D 2/2 xori t2]
        andi  t2, t2, 0xff       # t2 = t2 & 0xff  (t2 safe)
        nop                      # [D 1/2 andi t2 -> beq t2]
        nop                      # [D 2/2 andi t2 -> beq t2]
        beq   t2, x0, kick       # if !visited: go to kick (skip topsort)
        nop                      # [C 1/2 beq]
        nop                      # [C 2/2 beq]

        lw    t4, 24(fp)         # t4 = i
        lasw  ra, billowy        # [L 1/3 lw t4] lasw fills 3 slots for t4
        j     topsort
        nop                      # [C 1/2 j topsort]
        nop                      # [C 2/2 j topsort]
billowy:

kick:
        lw    t2, 24(fp)         # t2 = i
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        addi  t2, t2, 1          # i++
        nop                      # [D 1/2 addi t2 -> sw t2]
        nop                      # [D 2/2 addi t2 -> sw t2]
        sw    t2, 24(fp)         # store i++
main_loop_control:
        lw    t2, 24(fp)         # t2 = i
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        slti  t2, t2, 4          # t2 = (i < 4) ? 1 : 0
        nop                      # [D 1/2 slti t2 -> beq]
        nop                      # [D 2/2 slti t2 -> beq]
        beq   t2, x0, hew        # if i >= 4: exit loop
        nop                      # [C 1/2 beq]
        nop                      # [C 2/2 beq]
        j     main_loop_body
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]
hew:
        sw    x0, 28(fp)         # j = 0
        j     welcome
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]

wave:
        lw    t2, 28(fp)         # t2 = j
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        addi  t2, t2, 1          # j++
        nop                      # [D 1/2 addi t2 -> sw t2]
        nop                      # [D 2/2 addi t2 -> sw t2]
        sw    t2, 28(fp)         # store j++
welcome:
        lw    t2, 28(fp)         # t2 = j
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        slti  t2, t2, 4          # t2 = (j < 4)
        nop                      # [D 1/2 slti t2]
        nop                      # [D 2/2 slti t2]
        xori  t2, t2, 1          # t2 = !(j < 4) = (j >= 4)
        nop                      # [D 1/2 xori t2 -> beq]
        nop                      # [D 2/2 xori t2 -> beq]
        beq   t2, x0, wave       # if j < 4: keep looping
        nop                      # [C 1/2 beq]
        nop                      # [C 2/2 beq]

        mv    t2, x0             # t2 = 0 (return value)
        mv    sp, fp             # sp = fp (restore sp)
        nop                      # [D 1/2 mv sp -> lw ra uses sp]
        nop                      # [D 2/2 mv sp -> lw ra uses sp]
        lw    ra, 36(sp)         # restore ra
        lw    fp, 32(sp)         # [L 1/3 lw ra] RESCHEDULED: independent load
        nop                      # [L 2/3 lw ra; L 1/3 lw fp]
        nop                      # [L 3/3 lw ra; L 2/3 lw fp]
        nop                      # [L 3/3 lw fp]
        addi  sp, sp, 40         # deallocate frame
        nop                      # [D 1/2 addi sp; also ra safe now for jr]
        nop                      # [D 2/2 addi sp]
        jr    ra                 # return
        nop                      # [C 1/2 jr]
        nop                      # [C 2/2 jr]

interest:
        lw    t4, 24(fp)         # t4 = i
        lasw  ra, new            # [L 1/3 lw t4] lasw fills 3+ slots
        j     is_visited
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]
new:
        xori  t2, t2, 1          # flip visited bit
        nop                      # [D 1/2 xori t2]
        nop                      # [D 2/2 xori t2]
        andi  t2, t2, 0x0ff      # mask low byte
        nop                      # [D 1/2 andi t2 -> beq]
        nop                      # [D 2/2 andi t2 -> beq]
        beq   t2, x0, tasteful   # if !visited: go to tasteful
        nop                      # [C 1/2 beq]
        nop                      # [C 2/2 beq]

        lw    t4, 24(fp)         # t4 = i
        lasw  ra, partner        # [L 1/3 lw t4] lasw fills slots
        j     topsort
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]
partner:

tasteful:
        addi  t2, fp, 28         # t2 = &(fp->field_at_28)
        nop                      # [D 1/2 addi t2 -> mv t4]
        nop                      # [D 2/2 addi t2 -> mv t4]
        mv    t4, t2             # t4 = arg to next_edge
        lasw  ra, badge          # [D 1/2 mv t4] lasw fills slots (5 insts, t4 used inside)
                                 # mv t4 written before lasw; lasw is 5 insts → t4 safe when next_edge uses it
        j     next_edge
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]
badge:
        sw    t2, 24(fp)         # mem[fp+24] = t2  (t2 from addi fp,28 — safe, many insts ago)
        # Note: t2 was written by addi t2,fp,28. Many instructions have elapsed → safe.

turkey:
        lw    t3, 24(fp)         # t3 = mem[fp+24]
        nop                      # [L 1/3 lw t3]
        nop                      # [L 2/3 lw t3]
        nop                      # [L 3/3 lw t3]
        #li    t2, -1             # t2 = -1
        xori t2, x0, -1
        nop                      # [D 1/2 li t2 -> beq t3,t2] and [D 1/2 for t3 -> beq]
        nop                      # [D 2/2 li t2; D 2/2 t3 -> beq]
        beq   t3, t2, telling    # if mem[fp+24] == -1: go to telling
        nop                      # [C 1/2 beq]
        nop                      # [C 2/2 beq]
        j     interest
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]
telling:
        lasw  t2, res_idx        # t2 = &res_idx  (lasw: safe after completion)
        nop                      # [D 1/2 lasw t2 -> lw t2]  (lasw finishes with ori; t2 safe after lasw+1?)
                                 # lasw writes t2 with ori at end. Next inst reads t2 in ID → HAZARD.
                                 # Even with lasw, the final ori writes t2; next consumer needs 2 NOPs.
        nop                      # [D 2/2 lasw t2 -> lw t2]
        lw    t2, 0(t2)          # t2 = res_idx value
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        addi  t4, t2, -1         # t4 = res_idx - 1
        nop                      # [D 1/2 addi t4 -> sw t4]
        lasw  t3, res_idx        # [D 2/2 addi t4] RESCHEDULED: t3 = &res_idx (lasw fills slots)
                                 # lasw is 5 insts so t4 will be safe when sw t4,0(t3) executes
        nop                      # [D 1/2 lasw t3 -> sw t4 uses t3]
        nop                      # [D 2/2 lasw t3]
        sw    t4, 0(t3)          # res_idx = res_idx - 1  (t3 and t4 safe)
        lasw  t4, res            # t4 = &res  (fills slots naturally after sw)
        # After lasw t4 (5 insts), t4 is safe.
        # t2 still holds old res_idx value (lw above). t2 is needed for slli below.
        # t2 loaded many instructions ago → safe.
        nop                      # [D 1/2 lasw t4 -> slli t3 uses t4? No: slli uses t2]
        nop                      # [D 2/2 lasw t4]
        slli  t3, t2, 2          # t3 = res_idx * 4  (t2 safe)
        nop                      # [D 1/2 slli t3]
        nop
        srli  t3, t3, 1          # t3 = t3 >> 1
        # srli reads t3 written 1 inst ago → HAZARD
        nop                      # [D 1/2 slli t3 -> srli t3]  insert before srli
        nop                      # [D 2/2 slli t3 -> srli t3]
        srli  t3, t3, 1          # t3 >>= 1  (safe now)
        nop                      # [D 1/2 srli t3]
        nop                      # [D 2/2 srli t3]
        srai  t3, t3, 1          # t3 >>= 1 arithmetic
        nop                      # [D 1/2 srai t3]
        nop                      # [D 2/2 srai t3]
        slli  t3, t3, 2          # t3 <<= 2

        xor   t6, ra, t2         # does nothing useful (from original)  [D 1/2 slli t3] RESCHEDULED
        or    t6, ra, t2         # does nothing useful (from original)   [D 2/2 slli t3] RESCHEDULED
        nop
        nop
        neg   t6, t6             # negate t6 (does nothing useful)       [D 1/2 or t6] FREE? or t6 written 1 ago
        # or writes t6; neg reads t6 (1 inst apart) → HAZARD on t6
        nop                      # [D 1/2 or t6 -> neg t6]
        nop                      # [D 2/2 or t6 -> neg t6]
        neg   t6, t6             # (safe)

        lasw  t2, res            # t2 = &res  (safe after lasw)
        nop                      # [D 1/2 lasw t2]
        nop                      # [D 2/2 lasw t2]
        ##li    a1, 0x0000ffff     # a1 = mask
        #xori a1, x0, -1
        #srli a1, a1, 16
        lui a1, 0x1
        nop
        nop
        addi a1,a1,-1
        nop                      # [D 1/2 li a1 -> and t6]
        nop                      # [D 2/2 li a1 -> and t6]
        nop
        and   t6, t2, a1         # t6 = lower 16 bits of &res
        nop                      # [D 1/2 and t6 -> add t2]
        nop                      # [D 2/2 and t6 -> add t2]
        add   t2, t4, t6         # t2 = &res + lower16
        # t4 = &res from lasw t4 (many insts ago) → safe. t6 safe.
        nop                      # [D 1/2 add t2]
        nop                      # [D 2/2 add t2]
        add   t2, t3, t2         # t2 += offset t3
        nop                      # [D 1/2 add t2 -> lw t3]
        nop                      # [D 2/2 add t2 -> lw t3]
        lw    t3, 48(fp)         # t3 = mem[fp+48]  (node value to store)
        nop                      # [L 1/3 lw t3]
        nop                      # [L 2/3 lw t3]
        nop                      # [L 3/3 lw t3]
        sw    t3, 0(t2)          # res[idx] = node  (t2 safe, t3 safe)
        mv    sp, fp             # restore sp
        nop                      # [D 1/2 mv sp -> lw ra uses sp]
        nop                      # [D 2/2 mv sp -> lw ra uses sp]
        lw    ra, 44(sp)         # restore ra
        lw    fp, 40(sp)         # [L 1/3 lw ra] RESCHEDULED
        nop                      # [L 2/3 lw ra; L 1/3 lw fp]
        nop                      # [L 3/3 lw ra; L 2/3 lw fp]
        nop                      # [L 3/3 lw fp]
        addi  sp, sp, 48         # free frame
        nop                      # [D 1/2 addi sp]
        nop                      # [D 2/2 addi sp]
        jr    ra                 # return
        nop                      # [C 1/2 jr]
        nop                      # [C 2/2 jr]

topsort:
        addi  sp, sp, -48        # reserve 48 bytes
        nop                      # [D 1/2 addi sp -> sw ra]
        nop                      # [D 2/2 addi sp -> sw ra]
        sw    ra, 44(sp)
        sw    fp, 40(sp)         # [D 1/2 sw ra] FREE (sw no output; fp safe)
        mv    fp, sp             # fp = sp  [D 2/2 sw ra] RESCHEDULED
        nop
        nop
        sw    t4, 48(fp)         # mem[fp+48] = arg (t4 = node id)
        # fp written 1 inst ago → sw reads fp (address) 1 inst after mv → HAZARD
        nop                      # [D 1/2 mv fp -> sw t4,48(fp)]
        nop                      # [D 2/2 mv fp -> sw t4,48(fp)]
        sw    t4, 48(fp)         # (fp safe now)
        lw    t4, 48(fp)         # t4 = node id (reload)
        nop                      # [L 1/3 lw t4]
        lasw  ra, verse          # [L 2/3 lw t4] RESCHEDULED: lasw fills 3+ slots; t4 safe after
        nop                      # [L 3/3 lw t4; D 1/2 lasw ra] - but lasw takes 5 cycles so ra is safe
        # lasw writes ra via ori at the end. After lasw, ra needs 2 NOPs before jr ra.
        # But we j mark_visited next (j uses ra indirectly? No: j is a jump, ra set for return).
        # j mark_visited: ra already set by lasw → fine. No hazard on j itself.
        j     mark_visited
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]
verse:

        addi  t2, fp, 28         # t2 = &(fp+28)
        lw    t5, 48(fp)         # [D 1/2 addi t2 -> mv t4] RESCHEDULED: t5 = node
        # lw t5 reads fp (safe). t5 not yet used → fine.
        nop                      # [D 2/2 addi t2; L 1/3 lw t5]
        mv    t4, t2             # t4 = arg0  (t2 safe: addi 3 insts ago)
        # mv reads t2 (3 insts after addi) → safe (need 2)  [FREE SLOT]
        nop                      # [L 2/3 lw t5; D 1/2 mv t4]
        nop                      # [L 3/3 lw t5; D 2/2 mv t4]
        lasw  ra, joyous         # ra = &joyous  (5 insts, fills any remaining slots)
        j     iterate_edges
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]
joyous:

        addi  t2, fp, 28         # t2 = &(fp+28)
        nop                      # [D 1/2 addi t2 -> mv t4]
        nop                      # [D 2/2 addi t2 -> mv t4]
        mv    t4, t2             # t4 = arg
        lasw  ra, whispering     # [D 1/2 mv t4] lasw fills slots
        j     next_edge
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]
whispering:

        sw    t2, 24(fp)         # mem[fp+24] = t2  (t2 safe: many insts old)
        j     turkey
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]

iterate_edges:
        addi  sp, sp, -24        # reserve 24 bytes
        nop                      # [D 1/2 addi sp -> sw fp]
        nop                      # [D 2/2 addi sp -> sw fp]
        sw    fp, 20(sp)         # save fp
        mv    fp, sp             # fp = sp  [D 1/2 sw fp] RESCHEDULED: fp=sp (sp safe)
        nop                      # [D 2/2 sw fp; D 1/2 mv fp -> sw t4,24(fp)]
        nop                      # [D 2/2 mv fp -> sw t4,24(fp)]
        sw    t4, 24(fp)         # arg0 = t4
        sw    t5, 28(fp)         # [D 1/2 sw t4] FREE: independent sw
        lw    t2, 28(fp)         # t2 = t5 (just stored)  [D 2/2 sw t4] FREE
        # lw reads mem[fp+28] just written by sw t5 → memory ordering fine (MEM stage handles it)
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        sw    t2, 8(fp)          # mem[fp+8] = t2
        sw    x0, 12(fp)         # mem[fp+12] = 0  [D 1/2 sw t2] RESCHEDULED: independent
        lw    t2, 24(fp)         # t2 = arg0  [D 2/2 sw t2] RESCHEDULED: independent load
        nop                      # [L 1/3 lw t2]
        lw    t4, 8(fp)          # t4 = mem[fp+8]  [L 2/3 lw t2] RESCHEDULED
        lw    t3, 12(fp)         # t3 = 0  [L 3/3 lw t2; L 1/3 lw t4] RESCHEDULED
        nop                      # [L 2/3 lw t4; L 1/3 lw t3]
        nop                      # [L 3/3 lw t4; L 2/3 lw t3]
        nop                      # [L 3/3 lw t3]
        sw    t4, 0(t2)          # mem[t2] = t4  (t2, t4, t3 all safe)
        sw    t3, 4(t2)          # mem[t2+4] = t3  [D 1/2 sw t4] FREE (sw no output)
        lw    t2, 24(fp)         # t2 = arg0  [D 2/2 sw t4] RESCHEDULED
        nop                      # [L 1/3 lw t2]
        mv    sp, fp             # restore sp  [L 2/3 lw t2] RESCHEDULED
        nop                      # [L 3/3 lw t2; D 1/2 mv sp -> lw fp]
        nop                      # [D 2/2 mv sp -> lw fp]
        lw    fp, 20(sp)         # restore fp
        nop                      # [L 1/3 lw fp]
        nop                      # [L 2/3 lw fp]
        nop                      # [L 3/3 lw fp]
        addi  sp, sp, 24         # free frame
        nop                      # [D 1/2 addi sp]
        nop                      # [D 2/2 addi sp]
        jr    ra                 # return  (ra safe: set by lasw many insts ago)
        nop                      # [C 1/2 jr]
        nop                      # [C 2/2 jr]

next_edge:
        addi  sp, sp, -32        # reserve 32 bytes
        nop                      # [D 1/2 addi sp -> sw ra]
        nop                      # [D 2/2 addi sp -> sw ra]
        sw    ra, 28(sp)
        sw    fp, 24(sp)         # [D 1/2 sw ra] FREE
        nop
        nop
        nop
        add   fp, x0, sp         # fp = sp  [D 2/2 sw ra] RESCHEDULED
        nop                      # [D 1/2 add fp -> sw t4,32(fp)]
        nop                      # [D 2/2 add fp -> sw t4,32(fp)]
        sw    t4, 32(fp)         # mem[fp+32] = arg (t4)
        j     waggish
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]

snail:
        lw    t2, 32(fp)         # t2 = mem[fp+32]
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        lw    t3, 0(t2)          # t3 = mem[t2]  (t2 safe)
        lw    t2, 32(fp)         # [L 1/3 lw t3] RESCHEDULED: reload t2 (independent)
        nop                      # [L 2/3 lw t3; L 1/3 lw t2]
        nop                      # [L 3/3 lw t3; L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        lw    t2, 4(t2)          # t2 = mem[t2+4]  (t2 safe)
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        mv    t5, t2             # t5 = t2  (t2 safe)
        nop                      # [D 1/2 mv t5]
        mv    t4, t3             # [D 2/2 mv t5] RESCHEDULED: t4 = t3 (t3 safe)
        nop                      # [D 1/2 mv t4 -> j has_edge]
        nop                      # [D 2/2 mv t4]
        lasw  ra, induce         # ra = &induce  (fills slots naturally after mv t4)
        j     has_edge
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]
induce:
        beq   t2, x0, quarter    # if edge_idx == 0 → quarter
        nop                      # [C 1/2 beq]
        nop                      # [C 2/2 beq]
        lw    t2, 32(fp)         # t2 = mem[fp+32]
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        lw    t2, 4(t2)          # t2 = mem[t2+4]  (t2 safe)
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        addi  t4, t2, 1          # t4 = t2 + 1
        nop                      # [D 1/2 addi t4 -> sw t4]
        lw    t3, 32(fp)         # [D 2/2 addi t4] RESCHEDULED: t3 = mem[fp+32]
        nop                      # [L 1/3 lw t3; D 1/2 addi t4 already done]
        nop                      # [L 2/3 lw t3]
        nop                      # [L 3/3 lw t3]
        sw    t4, 4(t3)          # mem[t3+4] = t4  (t3 safe, t4 safe)
        j     cynical
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]

quarter:
        lw    t2, 32(fp)         # t2 = mem[fp+32]
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        lw    t2, 4(t2)          # t2 = mem[t2+4]  (t2 safe)
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        addi  t3, t2, 1          # t3 = t2 + 1
        nop                      # [D 1/2 addi t3 -> sw t3]
        lw    t2, 32(fp)         # [D 2/2 addi t3] RESCHEDULED: reload base ptr
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        sw    t3, 4(t2)          # mem[t2+4] = t3  (t2 safe, t3 safe)

waggish:
        lw    t2, 32(fp)         # t2 = mem[fp+32]
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        lw    t2, 4(t2)          # t2 = edge_counter  (t2 safe)
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        slti  t2, t2, 4          # t2 = (counter < 4)
        nop                      # [D 1/2 slti t2 -> beq]
        nop                      # [D 2/2 slti t2 -> beq]
        beq   t2, x0, mark       # if counter >= 4: exit
        nop                      # [C 1/2 beq]
        nop                      # [C 2/2 beq]
        j     snail
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]
mark:
        #li    t2, -1             # t2 = -1 (sentinel)
        addi t2, x0, -1
        nop
        nop

cynical:
        mv    sp, fp             # restore sp
        nop                      # [D 1/2 mv sp -> lw ra]
        nop                      # [D 2/2 mv sp -> lw ra]
        lw    ra, 28(sp)
        lw    fp, 24(sp)         # [L 1/3 lw ra] RESCHEDULED
        nop                      # [L 2/3 lw ra; L 1/3 lw fp]
        nop                      # [L 3/3 lw ra; L 2/3 lw fp]
        nop                      # [L 3/3 lw fp]
        addi  sp, sp, 32
        nop                      # [D 1/2 addi sp]
        nop                      # [D 2/2 addi sp]
        jr    ra
        nop                      # [C 1/2 jr]
        nop                      # [C 2/2 jr]

has_edge:
        addi  sp, sp, -32        # reserve 32 bytes
        nop                      # [D 1/2 addi sp -> sw fp]
        nop                      # [D 2/2 addi sp -> sw fp]
        sw    fp, 28(sp)
        mv    fp, sp             # [D 1/2 sw fp] RESCHEDULED: fp = sp
        nop                      # [D 2/2 sw fp; D 1/2 mv fp -> sw t4,32(fp)]
        nop                      # [D 2/2 mv fp -> sw t4,32(fp)]
        sw    t4, 32(fp)         # arg0 = node (t4)
        sw    t5, 36(fp)         # arg1 = edge_bit (t5)  [D 1/2 sw t4] FREE
        lasw  t2, adjacencymatrix# [D 2/2 sw t4] RESCHEDULED: t2 = &adjacencymatrix
        nop                      # [D 1/2 lasw t2]
        nop                      # [D 2/2 lasw t2]
        lw    t3, 32(fp)         # t3 = node id
        nop                      # [L 1/3 lw t3]
        nop                      # [L 2/3 lw t3]
        nop                      # [L 3/3 lw t3]
        slli  t3, t3, 2          # t3 = node * 4  (t3 safe)
        nop                      # [D 1/2 slli t3 -> add t2]
        nop                      # [D 2/2 slli t3 -> add t2]
        add   t2, t3, t2         # t2 = &adjacencymatrix[node]  (t2 safe, t3 safe)
        nop                      # [D 1/2 add t2 -> lw t2]
        nop                      # [D 2/2 add t2 -> lw t2]
        lw    t2, 0(t2)          # t2 = adjacencymatrix[node]  (t2 safe)
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        sw    t2, 16(fp)         # mem[fp+16] = adjacency word
        #li    t2, 1              # [D 1/2 sw t2] RESCHEDULED: t2 = 1
        addi t2, x0, 1
        nop                      # [D 2/2 sw (no out); D 1/2 li t2 -> sw t2,8(fp)]
        nop                      # [D 2/2 li t2 -> sw t2,8(fp)]
        sw    t2, 8(fp)          # mem[fp+8] = 1 (bitmask)
        sw    x0, 12(fp)         # [D 1/2 sw t2] FREE: x0 is always 0, no hazard
        j     measley
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]

look:
        lw    t2, 8(fp)          # t2 = bitmask
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        slli  t2, t2, 1          # t2 <<= 1  (t2 safe)
        nop                      # [D 1/2 slli t2 -> sw t2]
        nop                      # [D 2/2 slli t2 -> sw t2]
        sw    t2, 8(fp)
        lw    t2, 12(fp)         # t2 = counter  [D 1/2 sw t2] RESCHEDULED
        nop                      # [L 1/3 lw t2; D 2/2 sw t2] - sw has no output, D2/2 is free
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        addi  t2, t2, 1          # counter++
        nop                      # [D 1/2 addi t2 -> sw t2]
        nop                      # [D 2/2 addi t2 -> sw t2]
        sw    t2, 12(fp)
measley:
        lw    t3, 12(fp)         # t3 = counter  [D 1/2 sw t2] RESCHEDULED (sw no output)
        lw    t2, 36(fp)         # t2 = edge_bit  [L 1/3 lw t3] RESCHEDULED
        nop                      # [L 2/3 lw t3; L 1/3 lw t2]
        nop                      # [L 3/3 lw t3; L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        slt   t2, t3, t2         # t2 = (counter < edge_bit)  (t3, t2 safe)
        nop                      # [D 1/2 slt t2 -> beq]
        nop                      # [D 2/2 slt t2 -> beq]
        beq   t2, x0, experience # if !(counter < edge_bit): done
        nop                      # [C 1/2 beq]
        nop                      # [C 2/2 beq]
        j     look
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]
experience:
        lw    t3, 8(fp)          # t3 = bitmask
        lw    t2, 16(fp)         # t2 = adjacency word  [L 1/3 lw t3] RESCHEDULED
        nop                      # [L 2/3 lw t3; L 1/3 lw t2]
        nop                      # [L 3/3 lw t3; L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        and   t2, t3, t2         # t2 = adj & mask  (t3, t2 safe)
        nop                      # [D 1/2 and t2 -> slt]
        nop                      # [D 2/2 and t2 -> slt]
        slt   t2, x0, t2         # t2 = (0 < adj&mask) = has_edge  (t2 safe)
        nop                      # [D 1/2 slt t2 -> andi]
        nop                      # [D 2/2 slt t2 -> andi]
        andi  t2, t2, 0xff       # mask to byte
        mv    sp, fp             # [D 1/2 andi t2] RESCHEDULED: restore sp
        nop                      # [D 2/2 andi t2; D 1/2 mv sp -> lw fp]
        nop                      # [D 2/2 mv sp -> lw fp]
        lw    fp, 28(sp)
        nop                      # [L 1/3 lw fp]
        nop                      # [L 2/3 lw fp]
        nop                      # [L 3/3 lw fp]
        addi  sp, sp, 32
        nop                      # [D 1/2 addi sp]
        nop                      # [D 2/2 addi sp]
        jr    ra                 # return  (ra safe: set by caller many insts ago)
        nop                      # [C 1/2 jr]
        nop                      # [C 2/2 jr]

mark_visited:
        addi  sp, sp, -32        # reserve 32 bytes
        nop                      # [D 1/2 addi sp -> sw fp]
        nop                      # [D 2/2 addi sp -> sw fp]
        sw    fp, 28(sp)
        mv    fp, sp             # [D 1/2 sw fp] RESCHEDULED: fp = sp
        nop                      # [D 2/2 sw fp; D 1/2 mv fp -> sw t4,32(fp)]
        nop                      # [D 2/2 mv fp -> sw t4,32(fp)]
        sw    t4, 32(fp)         # arg = t4
        #li    t2, 1              # t2 = 1 (initial bitmask byte)
        addi t2, x0, 1
        nop                      # [D 1/2 li t2 -> sw t2,8(fp)]
        nop                      # [D 2/2 li t2 -> sw t2,8(fp)]
        sw    t2, 8(fp)          # mem[fp+8] = 1
        sw    x0, 12(fp)         # mem[fp+12] = 0 (counter)  [D 1/2 sw t2] FREE
        j     recast
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]

example:
        lw    t2, 8(fp)          # t2 = bitmask
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        slli  t2, t2, 8          # t2 <<= 8
        nop                      # [D 1/2 slli t2 -> sw]
        nop                      # [D 2/2 slli t2 -> sw]
        sw    t2, 8(fp)
        lw    t2, 12(fp)         # [D 1/2 sw t2] RESCHEDULED (sw no output)
        nop                      # [L 1/3 lw t2; D 2/2 sw (no out)]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        addi  t2, t2, 1          # counter++
        nop                      # [D 1/2 addi t2 -> sw]
        nop                      # [D 2/2 addi t2 -> sw]
        sw    t2, 12(fp)
recast:
        lw    t3, 12(fp)         # t3 = counter  [D 1/2 sw t2] RESCHEDULED (sw no output)
        lw    t2, 32(fp)         # t2 = arg (node id)  [L 1/3 lw t3] RESCHEDULED
        nop                      # [L 2/3 lw t3; L 1/3 lw t2]
        nop                      # [L 3/3 lw t3; L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        slt   t2, t3, t2         # t2 = (counter < node_id)  (t3, t2 safe)
        nop                      # [D 1/2 slt t2 -> beq]
        nop                      # [D 2/2 slt t2 -> beq]
        beq   t2, x0, pat        # if !(counter < node): done
        nop                      # [C 1/2 beq]
        nop                      # [C 2/2 beq]
        j     example
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]
pat:
        lasw  t2, visited        # t2 = &visited
        nop                      # [D 1/2 lasw t2 -> sw t2,16(fp)]
        nop                      # [D 2/2 lasw t2 -> sw t2,16(fp)]
        sw    t2, 16(fp)         # mem[fp+16] = &visited
        lw    t2, 16(fp)         # [D 1/2 sw t2] RESCHEDULED (sw no output)
        nop                      # [L 1/3 lw t2; D 2/2 sw]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        lw    t3, 0(t2)          # t3 = visited word  (t2 safe)
        nop                      # [L 1/3 lw t3]
        lw    t2, 8(fp)          # [L 2/3 lw t3] RESCHEDULED: t2 = bitmask
        nop                      # [L 3/3 lw t3; L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        or    t3, t3, t2         # t3 = visited | bitmask  (t3, t2 safe)
        nop                      # [D 1/2 or t3 -> sw t3]
        nop
        lw    t2, 16(fp)         # [D 2/2 or t3] RESCHEDULED: t2 = &visited (reload)
        nop                      # [L 1/3 lw t2; D 1/2 or t3 already done]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        sw    t3, 0(t2)          # visited |= bitmask  (t2, t3 safe)
        mv    sp, fp             # restore sp  [D 1/2 sw t3] RESCHEDULED (sw no output)
        nop                      # [D 2/2 sw; D 1/2 mv sp -> lw fp]
        nop                      # [D 2/2 mv sp -> lw fp]
        lw    fp, 28(sp)
        nop                      # [L 1/3 lw fp]
        nop                      # [L 2/3 lw fp]
        nop                      # [L 3/3 lw fp]
        addi  sp, sp, 32
        nop                      # [D 1/2 addi sp]
        nop                      # [D 2/2 addi sp]
        jr    ra                 # return
        nop                      # [C 1/2 jr]
        nop                      # [C 2/2 jr]

is_visited:
        addi  sp, sp, -32        # reserve 32 bytes
        nop                      # [D 1/2 addi sp -> sw fp]
        nop                      # [D 2/2 addi sp -> sw fp]
        sw    fp, 28(sp)
        mv    fp, sp             # [D 1/2 sw fp] RESCHEDULED: fp = sp
        nop                      # [D 2/2 sw fp; D 1/2 mv fp -> sw t4,32(fp)]
        nop                      # [D 2/2 mv fp -> sw t4,32(fp)]
        sw    t4, 32(fp)         # arg = t4 (node id)
        ori   t2, x0, 1          # t2 = 1 (initial bitmask)  [D 1/2 sw t4] RESCHEDULED (sw no out)
        nop                      # [D 2/2 sw t4; D 1/2 ori t2 -> sw t2,8(fp)]
        nop                      # [D 2/2 ori t2 -> sw t2,8(fp)]
        sw    t2, 8(fp)
        sw    x0, 12(fp)         # counter = 0  [D 1/2 sw t2] FREE (sw no out)
        j     evasive
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]

justify:
        lw    t2, 8(fp)          # t2 = bitmask
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        slli  t2, t2, 8          # t2 <<= 8
        nop                      # [D 1/2 slli t2 -> sw]
        nop                      # [D 2/2 slli t2 -> sw]
        sw    t2, 8(fp)
        lw    t2, 12(fp)         # counter  [D 1/2 sw t2] RESCHEDULED (sw no out)
        nop                      # [L 1/3 lw t2; D 2/2 sw]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        addi  t2, t2, 1          # counter++
        nop                      # [D 1/2 addi t2 -> sw]
        nop                      # [D 2/2 addi t2 -> sw]
        sw    t2, 12(fp)
evasive:
        lw    t3, 12(fp)         # t3 = counter  [D 1/2 sw t2] RESCHEDULED (sw no out)
        lw    t2, 32(fp)         # t2 = node id  [L 1/3 lw t3] RESCHEDULED
        nop                      # [L 2/3 lw t3; L 1/3 lw t2]
        nop                      # [L 3/3 lw t3; L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        slt   t2, t3, t2         # t2 = (counter < node_id)  (t3, t2 safe)
        nop                      # [D 1/2 slt t2 -> beq]
        nop                      # [D 2/2 slt t2 -> beq]
        beq   t2, x0, representative  # if done: exit loop
        nop                      # [C 1/2 beq]
        nop                      # [C 2/2 beq]
        j     justify
        nop                      # [C 1/2 j]
        nop                      # [C 2/2 j]
representative:
        lasw  t2, visited        # t2 = &visited
        nop                      # [D 1/2 lasw t2 -> lw t2]
        nop                      # [D 2/2 lasw t2 -> lw t2]
        lw    t2, 0(t2)          # t2 = visited word  (t2 safe)
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        sw    t2, 16(fp)         # mem[fp+16] = visited
        lw    t3, 16(fp)         # [D 1/2 sw t2] RESCHEDULED (sw no out)
        nop                      # [L 1/3 lw t3; D 2/2 sw]
        nop                      # [L 2/3 lw t3]
        nop                      # [L 3/3 lw t3]
        lw    t2, 8(fp)          # t2 = bitmask
        nop                      # [L 1/3 lw t2]
        nop                      # [L 2/3 lw t2]
        nop                      # [L 3/3 lw t2]
        and   t2, t3, t2         # t2 = visited & bitmask  (t3, t2 safe)
        nop                      # [D 1/2 and t2 -> slt]
        nop                      # [D 2/2 and t2 -> slt]
        slt   t2, x0, t2         # t2 = (0 < result) = is_visited
        nop                      # [D 1/2 slt t2 -> andi]
        nop                      # [D 2/2 slt t2 -> andi]
        andi  t2, t2, 0xff       # mask to byte
        mv    sp, fp             # [D 1/2 andi t2] RESCHEDULED: restore sp
        nop                      # [D 2/2 andi t2; D 1/2 mv sp -> lw fp]
        nop                      # [D 2/2 mv sp -> lw fp]
        lw    fp, 28(sp)
        nop                      # [L 1/3 lw fp]
        nop                      # [L 2/3 lw fp]
        nop                      # [L 3/3 lw fp]
        addi  sp, sp, 32
        nop                      # [D 1/2 addi sp]
        nop                      # [D 2/2 addi sp]
        jr    ra                 # return  (ra set by caller via lasw, many insts ago → safe)
        nop                      # [C 1/2 jr]
        nop                      # [C 2/2 jr]

end:
        wfi