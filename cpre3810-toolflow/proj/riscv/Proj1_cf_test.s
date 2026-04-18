# ============================================================
# Proj1_cf_test.s
# RISC-V Single-Cycle Processor — Control Flow Test
#
# Call depth demonstration (activation records on stack):
#   _start  (depth 1)
#     -> run_tests  (depth 2)
#          -> branch_demo  (depth 3)
#               -> factorial  (depth 4)  factorial(5)
#                    -> factorial  (depth 5)  factorial(4)
#                         -> ...  (depth 6, 7, 8)
#
# Control-flow instructions exercised:
#   beq, bne, blt, bge, bltu, bgeu   (all 6 branch types)
#   jal                               (direct call / jump)
#   jalr                              (indirect call / return)
# ============================================================

.data
result:   .word  0           # stores final factorial result
expected: .word  120         # 5! = 120

.text
# _start — depth 1
# Calls run_tests, then checks the stored result.
_start:
      lui   sp, 0x7FFFF      # sp = 0x7FFFF000
      addi  sp, sp, -8       # allocate frame: ra, s0
      sw    ra,  4(sp)
      sw    s0,  0(sp)

      jal   ra, run_tests    # depth 1 -> 2

      # Check result == 120 using beq
      la    t0, result
      lw    s0, 0(t0)        # s0 = computed factorial
      li    t1, 120
      beq   s0, t1, pass     # if correct, branch to pass
      # fall-through means wrong answer — skip to die anyway
      jal   zero, die

pass:
      lw    ra,  4(sp)
      lw    s0,  0(sp)
      addi  sp, sp, 8
      jal   zero, die        # all done

# run_tests — depth 2
# Exercises bltu / bgeu with unsigned sentinels, then calls branch_demo.
run_tests:
      addi  sp, sp, -8       # allocate frame: ra, s0
      sw    ra,  4(sp)
      sw    s0,  0(sp)

      # --- BLTU test ---
      # 1 <u 0xFFFFFFFF  =>  branch taken
      li    t0, 1
      li    t1, -1           # t1 = 0xFFFFFFFF (max unsigned)
      bltu  t0, t1, bltu_ok
      jal   zero, die        # POISON: should not reach here
bltu_ok:

      # --- BGEU test ---
      # 0xFFFFFFFF >=u 1  =>  branch taken
      bgeu  t1, t0, bgeu_ok
      jal   zero, die        # POISON
bgeu_ok:

      # Call branch_demo (depth 2 -> 3)
      jal   ra, branch_demo

      lw    ra,  4(sp)
      lw    s0,  0(sp)
      addi  sp, sp, 8
      jalr  zero, ra, 0      # return to _start

# branch_demo — depth 3
# Exercises beq, bne, blt, bge in a small counting loop, then calls factorial(5).
branch_demo:
      addi  sp, sp, -12      # allocate frame: ra, s0, s1
      sw    ra,  8(sp)
      sw    s0,  4(sp)
      sw    s1,  0(sp)

      # --- counting loop using bne and blt ---
      # counts i from 0 to 4 (5 iterations)
      li    s0, 0            # i = 0
      li    s1, 5            # limit = 5

count_loop:
      bge   s0, s1, count_done   # if i >= 5, exit loop  (BGE)
      addi  s0, s0, 1            # i++
      bne   s0, s1, count_loop   # if i != 5, keep looping  (BNE)

count_done:
      # s0 should now equal 5; verify with beq
      beq   s0, s1, blt_test     # if s0 == 5, continue  (BEQ)
      jal   zero, die            # POISON

blt_test:
      # --- BLT test: -3 < 2 (signed) ---
      li    t0, -3
      li    t1, 2
      blt   t0, t1, blt_ok       # -3 < 2 signed  (BLT)
      jal   zero, die            # POISON
blt_ok:

      # --- Call factorial(5) via jalr to exercise indirect jump ---
      li    a0, 5            # argument: n = 5
      la    t2, factorial    # load address of factorial into register
      jalr  ra, t2, 0        # indirect call  (JALR used as call)
                             # depth 3 -> 4

      # Store result
      la    t0, result
      sw    a0, 0(t0)        # result = factorial(5)

      lw    ra,  8(sp)
      lw    s0,  4(sp)
      lw    s1,  0(sp)
      addi  sp, sp, 12
      jalr  zero, ra, 0      # return to run_tests

# factorial(n) — depths 4-8
# Recursive factorial: n * factorial(n-1); base case returns 1
# Arguments: a0 = n, Returns: a0 = n!
factorial:
      addi  sp, sp, -12      # allocate frame: ra, s0 (n), s1 (scratch)
      sw    ra,  8(sp)
      sw    s0,  4(sp)
      sw    s1,  0(sp)

      add   s0, a0, zero     # s0 = n  (save argument)

      # Base case: if n <= 1, return 1
      li    t0, 1
      bge   t0, s0, base_case    # if 1 >= n (i.e. n <= 1), branch  (BGE)

      # Recursive case: factorial(n-1)
      addi  a0, s0, -1       # a0 = n - 1
      jal   ra, factorial    # recurse  (JAL)  depth increases by 1

      # a0 now holds factorial(n-1); multiply by n
      # multiply via repeated addition: s1 = a0 * s0
      add   s1, zero, zero   # s1 = 0  (accumulator)
      add   t1, zero, zero   # t1 = loop counter = 0

mul_loop:
      bge   t1, s0, mul_done     # if counter >= n, done  (BGE)
      add   s1, s1, a0           # s1 += factorial(n-1)
      addi  t1, t1, 1            # counter++
      bne   t1, s0, mul_loop     # loop  (BNE)

mul_done:
      add   a0, s1, zero     # return value = n * factorial(n-1)
      jal   zero, fact_ret

base_case:
      li    a0, 1            # return 1

fact_ret:
      lw    ra,  8(sp)
      lw    s0,  4(sp)
      lw    s1,  0(sp)
      addi  sp, sp, 12
      jalr  zero, ra, 0      # return to caller  (JALR used as return)

# HALT
die:
      wfi