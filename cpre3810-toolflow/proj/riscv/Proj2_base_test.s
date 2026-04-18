# Isaiah Pridie, Jack Dustin
# CprE 3810 - Assembly Base program for sw scheduled pipeline
# Start Date: 4.11.2026, 6:44 PM

.data
word_val:  .word  0x00000F0F
byte_val:  .byte  0xAB, 0, 0, 0
half_val:  .half  0x1234, 0
store_buf: .word  0

.text
.globl _start

_start:
# -----------------------------
# 1. Setup (independent)
# -----------------------------
lui   s0, 1
lui   s1, 0x10
auipc s2, 0
auipc s3, 1

addi  s4, zero, 100
addi  s5, zero, 55
addi  s8, zero, -1

# -----------------------------
# 2. Logical ops (no deps yet)
# -----------------------------
addi  t0, zero, 0xFF
addi  t7, zero, 0x0F

# now s4/s5 ready
add   s6, s4, s5
sub   s7, s4, s5

and   t1, s4, t0
andi  t2, s4, 0x0F

or    t3, s4, t7
ori   t4, s4, 3

xor   t5, s4, s5
xori  t6, s4, 0xFF

# -----------------------------
# 3. SLT group
# -----------------------------
slt   s0, s5, s4
slt   s1, s8, zero
slti  s2, s4, 200
slti  s3, s4, 50
sltiu s4, s4, 200
sltiu s5, s8, 1

# -----------------------------
# 4. Shift group
# -----------------------------
addi  t0, zero, 1
addi  t1, zero, 4

sll   t2, t0, t1
slli  t3, t0, 8
slli  t4, s6, 2

addi  t5, zero, 0x7F
srl   t6, t5, t1
srli  s0, t5, 3

lui   s1, 0x80000
addi  t0, zero, 1

sra   s2, s1, t0
srai  s3, s1, 4

# -----------------------------
# 5. Memory (scheduled cleanly)
# -----------------------------
lui   t0, %hi(store_buf)
lui   t8, %hi(byte_val)
lui   t9, %hi(half_val)

addi  t0, t0, %lo(store_buf)
addi  t8, t8, %lo(byte_val)
addi  t9, t9, %lo(half_val)

addi  t1, zero, 0xABC
addi  t2, zero, 7

sw    t1, 0(t0)

# fill gap before lw
addi  t3, zero, 1
addi  t4, zero, 2

lw    t2, 0(t0)

# byte / half loads
lb    t3, 0(t8)
lbu   t4, 0(t8)
lh    t5, 0(t9)
lhu   t6, 0(t9)

lui   t0, %hi(word_val)
addi  t0, t0, %lo(word_val)
lw    s4, 0(t0)

# -----------------------------
# 6. Branches (minimal padding)
# -----------------------------
addi  t0, zero, 42
addi  t1, zero, 42

beq   t0, t1, beq_taken
addi  s5, zero, -1
nop
beq_taken:
addi  s5, zero, 1

addi  t0, zero, 10
addi  t1, zero, 20

bne   t0, t1, bne_taken
addi  s6, zero, -1
nop
bne_taken:
addi  s6, zero, 2

addi  t0, zero, -5
addi  t1, zero, 5

blt   t0, t1, blt_taken
addi  s7, zero, -1
nop
blt_taken:
addi  s7, zero, 3

addi  t0, zero, 10
addi  t1, zero, 10

bge   t0, t1, bge_taken
addi  s8, zero, -1
nop
bge_taken:
addi  s8, zero, 4

addi  t0, zero, 1
addi  t1, zero, -1

bltu  t0, t1, bltu_taken
addi  s9, zero, -1
nop
bltu_taken:
addi  s9, zero, 5

addi  t0, zero, -1
addi  t1, zero, 1

bgeu  t0, t1, bgeu_taken
addi  s10, zero, -1
nop
bgeu_taken:
addi  s10, zero, 6

# -----------------------------
# 7. JAL
# -----------------------------
jal   ra, jal_target
addi  s11, zero, -1
nop

jal_return:
addi  s11, zero, 7
jal   zero, jalr_test

jal_target:
addi  a0, zero, 8
jalr  zero, ra, 0

# -----------------------------
# 8. JALR
# -----------------------------
jalr_test:
auipc a1, 0
addi  a1, a1, 12

jalr  ra, a1, 0
addi  a2, zero, -1
nop

addi  a2, zero, 9

# -----------------------------
# 9. HALT
# -----------------------------
wfi