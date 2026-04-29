# Isaiah Pridie, Jack Dustin
# CprE 3810 - Assembly Merge Sort
# SOFTWARE-SCHEDULED for 5-stage RISC-V pipeline (IF/ID/EX/MEM/WB)
# No hardware forwarding assumed.
#
# ============================================================
# HAZARD MODEL (no forwarding):
#   ALU -> USE : producer writes RF at end of WB (5 cycles after issue).
#                Consumer reads RF at ID (2 cycles after issue).
#                Need 2 intervening instructions (2 NOPs if no useful work).
#   LOAD -> USE: lw data available end of MEM (4th cycle); stored to RF
#                at WB (5th cycle).  Consumer needs 3 intervening instructions.
#   BRANCH/JAL : branch/jump resolves at end of EX (3rd cycle).
#                2 instructions already fetched → 2 NOP slots.
#   JALR       : same 2-slot penalty as JAL/branch.
#
# Comment legend per instruction:
#   [D n/2 src->dst] = data hazard, nth of 2 NOP slots
#   [L n/3 lw->dst]  = load hazard, nth of 3 NOP slots
#   [C n/2]          = control hazard, nth of 2 NOP slots
#   RESCHEDULED      = useful instruction moved here to fill a hazard slot
#   NOP              = bare nop required (no useful instruction available)
# ============================================================

.data
arr:
    .word 31, 5, 100, 92, 73, 50
end_arr:
temp:
    .space 24          # 6 words * 4 bytes

.text
.global main

main:
    lui   a0, 0x10010       # a0 = &arr (data segment base)
    lui   sp, 0x80000       # [D 1/2 lui a0->slli] RESCHEDULED: init sp upper bits
    addi  a1, x0, 6         # [D 2/2 lui a0->slli] RESCHEDULED: a1 = 6 elements
                            # NOTE: lui a0 has no consumer until slli a2 many steps later; slots free
    nop
    nop
    slli  a2, a1, 2         # a2 = 24 bytes total
    # a1 written by addi above (1 inst ago) → 2-NOP penalty for a1->slli
    addi  sp, sp, -4        # [D 1/2 addi a1 -> slli a2] RESCHEDULED: sp -= 4
                            # sp from lui sp (2 insts ago) → need 2 NOPs for lui sp -> addi sp
                            # lui sp is 2 insts before addi sp → D 2/2 for lui sp IS THIS INST
                            # So: addi sp fills D1/2 for a1->slli AND is safe itself (lui sp was 2 ago → D2/2 slot)
    nop                     # [D 2/2 addi a1 -> slli a2] NOP
    slli  a2, a1, 2         # a2 = 24  (a1 now 3 insts past → safe)
    add   s11, a2, x0       # s11 = 24 (save byte count for temp offset)
    # a2 written 1 inst ago → 2-NOP penalty before s11 can be used? s11 written here; 
    # s11 not used until Merge, many instructions away → no hazard on CONSUMER of s11 here.
    # But add s11 READS a2 (written 1 inst ago): HAZARD.
    nop                     # [D 1/2 slli a2 -> add s11]
    nop                     # [D 2/2 slli a2 -> add s11]
    add   s11, a2, x0       # s11 = 24  (a2 safe now)
    add   a2, a0, a2        # a2 = base + 24 = one-past-last; reads a0(safe), a2(safe)
                            # [D 1/2 add s11 -> (s11 not used soon)] RESCHEDULED as useful work
    nop                     # [D 1/2 add a2 -> addi a2]
    nop                     # [D 2/2 add a2 -> addi a2]
    addi  a2, a2, -4        # a2 = address of last element  (a2 safe)
    nop                     # [D 1/2 addi a2]
    nop                     # [D 2/2 addi a2]
    jal   x1, MergeSortRecurse
    nop                     # [C 1/2 jal]
    nop                     # [C 2/2 jal]
    beq   x0, x0, EXIT      # unconditional branch to EXIT
    nop                     # [C 1/2 beq]
    nop                     # [C 2/2 beq]


MergeSortRecurse:
    # a0=first addr, a1=size, a2=last addr, x1/ra=return addr
    bltu  a0, a2, Continue  # if a0 < a2: chunk has > 1 element → keep splitting
    nop                     # [C 1/2 bltu]
    nop                     # [C 2/2 bltu]
        jalr  x0, x1, 0    # base case: single element, return
        nop                 # [C 1/2 jalr]
        nop                 # [C 2/2 jalr]
    Continue:

    # ---- Save frame ----
    addi  sp, sp, -16       # reserve 16 bytes
    nop                     # [D 1/2 addi sp -> sw (address calc uses sp)]
    nop                     # [D 2/2 addi sp -> sw]
    sw    ra, 12(sp)        # save return address
    sw    a0,  8(sp)        # save first addr      [D 1/2 sw ra -> (no RAW on result)] FREE
    sw    a1,  4(sp)        # save chunk size      [D 2/2 sw ra] FREE (sw has no output reg)
    sw    a2,  0(sp)        # save last addr       FREE

    # ---- Compute left-half parameters ----
    srli  a4, a1, 1         # a4 = left_size = total / 2
    nop                     # [D 1/2 srli a4]
    nop                     # [D 2/2 srli a4]
    slli  a5, a4, 2         # a5 = left bytes = left_size * 4  (a4 safe)
    nop                     # [D 1/2 slli a5]
    nop                     # [D 2/2 slli a5]
    add   a6, a0, a5        # a6 = right-half first addr  (a0 safe, a5 safe)
    nop                     # [D 1/2 add a6]
    nop                     # [D 2/2 add a6]
    addi  a7, a6, -4        # a7 = left-half last addr  (a6 safe)
    sub   t0, a1, a4        # t0 = right_size = total - left  [D 1/2 addi a7->nothing immed] RESCHEDULED
                            # a1 safe, a4 safe (srli was 6+ insts ago)
    nop                     # [D 2/2 addi a7; D 1/2 sub t0]
    nop                     # [D 2/2 sub t0]

    # ---- Recurse left ----
    add   a1, a4, x0        # a1 = left_size  (a4 safe)
    nop                     # [D 1/2 add a1]
    add   a2, a7, x0        # [D 2/2 add a1] RESCHEDULED: a2 = left last  (a7 safe)
    nop                     # [D 1/2 add a2]
    nop                     # [D 2/2 add a2]
    jal   ra, MergeSortRecurse
    nop                     # [C 1/2 jal]
    nop                     # [C 2/2 jal]

    # ---- Restore for right recursion ----
    lw    a0,  8(sp)
    lw    a1,  4(sp)        # [L 1/3 lw a0] RESCHEDULED
    lw    a2,  0(sp)        # [L 2/3 lw a0; L 1/3 lw a1] RESCHEDULED
    nop                     # [L 3/3 lw a0; L 2/3 lw a1; L 1/3 lw a2]
    nop                     # [L 3/3 lw a1; L 2/3 lw a2]
    nop                     # [L 3/3 lw a2]

    # ---- Recompute split for right half ----
    srli  a4, a1, 1         # a4 = left_size  (a1 safe)
    nop                     # [D 1/2 srli a4]
    nop                     # [D 2/2 srli a4]
    slli  a5, a4, 2         # a5 = left bytes  (a4 safe)
    nop                     # [D 1/2 slli a5]
    sub   t0, a1, a4        # [D 2/2 slli a5] RESCHEDULED: t0 = right_size  (a1,a4 safe)
    nop                     # [D 1/2 sub t0]
    add   a6, a0, a5        # [D 2/2 sub t0] RESCHEDULED: a6 = right first  (a0,a5 safe)

    # ---- Recurse right ----
    nop                     # [D 1/2 add a6]
    nop                     # [D 2/2 add a6]
    add   a0, a6, x0        # a0 = right first addr  (a6 safe)
    nop                     # [D 1/2 add a0]
    add   a1, t0, x0        # [D 2/2 add a0] RESCHEDULED: a1 = right_size  (t0 safe)
    nop                     # [D 1/2 add a1]
    nop                     # [D 2/2 add a1]
    jal   ra, MergeSortRecurse
    nop                     # [C 1/2 jal]
    nop                     # [C 2/2 jal]

    # ---- Restore for merge ----
    lw    ra,  12(sp)
    lw    a0,   8(sp)       # [L 1/3 lw ra] RESCHEDULED
    lw    a1,   4(sp)       # [L 2/3 lw ra; L 1/3 lw a0] RESCHEDULED
    lw    a2,   0(sp)       # [L 3/3 lw ra; L 2/3 lw a0; L 1/3 lw a1] RESCHEDULED
    nop                     # [L 3/3 lw a0; L 2/3 lw a1; L 1/3 lw a2]
    nop                     # [L 3/3 lw a1; L 2/3 lw a2]
    nop                     # [L 3/3 lw a2]
    addi  sp, sp, 16        # free stack frame  (sp written, not used for 3+ cycles → safe consumer)

    # ---- Recompute split for merge ----
    srli  a4, a1, 1         # a4 = left_size  (a1 safe, loaded 6+ insts ago)
    nop                     # [D 1/2 srli a4]
    nop                     # [D 2/2 srli a4]
    slli  a5, a4, 2         # a5 = left bytes  (a4 safe)
    nop                     # [D 1/2 slli a5]
    sub   t0, a1, a4        # [D 2/2 slli a5] RESCHEDULED: t0 = right_size
    nop                     # [D 1/2 sub t0]
    add   a6, a0, a5        # [D 2/2 sub t0] RESCHEDULED: a6 = right first
    nop                     # [D 1/2 add a6]
    nop                     # [D 2/2 add a6]
    addi  a7, a6, -4        # a7 = left last  (a6 safe)
    nop                     # [D 1/2 addi a7]
    nop                     # [D 2/2 addi a7]
    # Fall through to Merge


Merge:
    # LEFT:  first=a0, size=a4, last=a7
    # RIGHT: first=a6, size=t0, last=a2

    add   t1, a0, x0        # t1 = left ptr
    add   t2, a6, x0        # t2 = right ptr  [D 1/2 add t1 -> (t1 not used 2 insts)] RESCHEDULED
    add   t4, a7, x0        # t4 = left end   [D 2/2 add t1; D 1/2 add t2 -> (t2 not yet used)] RESCHEDULED
    add   t5, a2, x0        # t5 = right end  [D 2/2 add t2; D 1/2 add t4 -> (t4 not used 2 insts)] RESCHEDULED
    lui   t6, 0x10010       # t6 = data base  [D 2/2 add t4; D 1/2 add t5] RESCHEDULED
    nop                     # [D 2/2 add t5; D 1/2 lui t6]
    nop                     # [D 2/2 lui t6]
    add   t6, t6, s11       # t6 = &temp  (t6 safe, s11 safe)
    nop                     # [D 1/2 add t6]
    nop                     # [D 2/2 add t6]
    add   t3, t6, x0        # t3 = temp write ptr  (t6 safe)


MergeLoopCheck:
    bltu  t4, t1, CopyRightRemainder  # left exhausted?
    nop                     # [C 1/2 bltu]
    nop                     # [C 2/2 bltu]
    bltu  t5, t2, CopyLeftRemainder   # right exhausted?
    nop                     # [C 1/2 bltu]
    nop                     # [C 2/2 bltu]
    lw    a3, 0(t1)         # a3 = *left
    lw    a5, 0(t2)         # a5 = *right  [L 1/3 lw a3] RESCHEDULED: independent load
    nop                     # [L 2/3 lw a3; L 1/3 lw a5]
    nop                     # [L 3/3 lw a3; L 2/3 lw a5]
    nop                     # [L 3/3 lw a5]
    blt   a5, a3, TakeRight # if *right < *left → take right
    nop                     # [C 1/2 blt]
    nop                     # [C 2/2 blt]

TakeLeft:
    sw    a3, 0(t3)         # *temp++ = *left
    addi  t1, t1, 4         # left ptr++
    addi  t3, t3, 4         # temp ptr++  [D 1/2 addi t1 -> bltu uses t1 later] RESCHEDULED
    nop                     # [D 2/2 addi t1; D 1/2 addi t3]
    nop                     # [D 2/2 addi t3]
    beq   x0, x0, MergeLoopCheck
    nop                     # [C 1/2 beq]
    nop                     # [C 2/2 beq]

TakeRight:
    sw    a5, 0(t3)         # *temp++ = *right
    addi  t2, t2, 4         # right ptr++
    addi  t3, t3, 4         # temp ptr++  [D 1/2 addi t2] RESCHEDULED
    nop                     # [D 2/2 addi t2; D 1/2 addi t3]
    nop                     # [D 2/2 addi t3]
    beq   x0, x0, MergeLoopCheck
    nop                     # [C 1/2 beq]
    nop                     # [C 2/2 beq]


CopyLeftRemainder:
    bltu  t4, t1, CopyBackStart   # left already exhausted?
    nop                     # [C 1/2 bltu]
    nop                     # [C 2/2 bltu]
CopyLeftLoop:
    lw    a3, 0(t1)         # a3 = *left
    nop                     # [L 1/3 lw a3]
    nop                     # [L 2/3 lw a3]
    nop                     # [L 3/3 lw a3]
    sw    a3, 0(t3)         # *temp++ = a3
    addi  t1, t1, 4         # left ptr++
    addi  t3, t3, 4         # temp ptr++  [D 1/2 addi t1] RESCHEDULED
    nop                     # [D 2/2 addi t1; D 1/2 addi t3]
    nop                     # [D 2/2 addi t3]
    bgeu  t4, t1, CopyLeftLoop
    nop                     # [C 1/2 bgeu]
    nop                     # [C 2/2 bgeu]
    beq   x0, x0, CopyBackStart
    nop                     # [C 1/2 beq]
    nop                     # [C 2/2 beq]


CopyRightRemainder:
    bltu  t5, t2, CopyBackStart   # right already exhausted?
    nop                     # [C 1/2 bltu]
    nop                     # [C 2/2 bltu]
CopyRightLoop:
    lw    a5, 0(t2)         # a5 = *right
    nop                     # [L 1/3 lw a5]
    nop                     # [L 2/3 lw a5]
    nop                     # [L 3/3 lw a5]
    sw    a5, 0(t3)         # *temp++ = a5
    addi  t2, t2, 4         # right ptr++
    addi  t3, t3, 4         # temp ptr++  [D 1/2 addi t2] RESCHEDULED
    nop                     # [D 2/2 addi t2; D 1/2 addi t3]
    nop                     # [D 2/2 addi t3]
    bgeu  t5, t2, CopyRightLoop
    nop                     # [C 1/2 bgeu]
    nop                     # [C 2/2 bgeu]


CopyBackStart:
    lui   t6, 0x10010       # t6 = data base
    nop                     # [D 1/2 lui t6]
    nop                     # [D 2/2 lui t6]
    add   t6, t6, s11       # t6 = &temp  (t6 safe, s11 safe)
    nop                     # [D 1/2 add t6]
    add   t1, a0, x0        # [D 2/2 add t6] RESCHEDULED: t1 = chunk write ptr
    add   t2, a1, x0        # t2 = elements to copy  [D 1/2 add t1] RESCHEDULED
    nop                     # [D 2/2 add t1; D 1/2 add t2]
    nop                     # [D 2/2 add t2]

CopyBackLoop:
    beq   t2, x0, MergeDone
    nop                     # [C 1/2 beq]
    nop                     # [C 2/2 beq]
    lw    a3, 0(t6)         # a3 = temp[i]
    nop                     # [L 1/3 lw a3]
    nop                     # [L 2/3 lw a3]
    nop                     # [L 3/3 lw a3]
    sw    a3, 0(t1)         # arr[i] = temp[i]
    addi  t6, t6, 4         # temp ptr++
    addi  t1, t1, 4         # arr ptr++  [D 1/2 addi t6] RESCHEDULED
    addi  t2, t2, -1        # count--    [D 2/2 addi t6; D 1/2 addi t1] RESCHEDULED
    nop                     # [D 2/2 addi t1; D 1/2 addi t2]
    nop                     # [D 2/2 addi t2]
    beq   x0, x0, CopyBackLoop
    nop                     # [C 1/2 beq]
    nop                     # [C 2/2 beq]


MergeDone:
    jalr  x0, 0(ra)         # return  (ra safe: restored from stack 6+ insts ago)
    nop                     # [C 1/2 jalr]
    nop                     # [C 2/2 jalr]


EXIT:
    wfi