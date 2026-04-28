#
# Topological sort using an adjacency matrix. Maximum 4 nodes.
# 
# The expected output of this program is that the 1st 4 addresses of the data segment
# are [4,0,3,2]. should take ~2000 cycles in a single cycle procesor.
#

# Adapted to RISC-V by Connor J. Link (3.1.2025)
# Per testing [3, 0, 2, 1] is the expected output (matches the original grendel.s in MARS)

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
        # NEW RISCV                # ORIGINAL MIPS
	li   sp, 0x10011000        # li $sp, 0x10011000
	li   fp, 0                 # li $fp, 0
	la   ra, pump              # la $ra pump
	j    main
pump:
        j end
	ebreak                     # halt


main:
        addi sp,    sp, -40        # addiu   $sp,$sp,-40
        		addi x0, x0, 0	# nop
        		addi x0, x0, 0	# nop
        		addi x0, x0, 0	# nop 
        sw   ra, 36(sp)            # sw      $31,36($sp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   fp, 32(sp)            # sw      $fp,32($sp)
        add  fp,    sp, x0         # add     $fp,$sp,$zero
        sw   x0, 24(sp)            # sw      $0,24($fp)
        j    main_loop_control
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop

main_loop_body:
        lw   t4, 24(fp)            # lw      $4,24($fp)
        la   ra,    trucks         # la      $ra, trucks
        j    is_visited
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	
trucks:

        xori t2,    t2, 1          # xori    $2,$2,0x1
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        andi t2,    t2, 0xff       # andi    $2,$2,0x00ff
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        beq  t2,    x0, kick       # beq     $2,$0,kick
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop

        lw   t4, 24(fp)            # lw      $4,24($fp)
                                   # ; addi    $k0, $k0,1# breakpoint
        la   ra,    billowy        # la      $ra, billowy
        j    topsort
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
billowy:

kick:
        lw   t2, 24(fp)            # lw      $2,24($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        addi t2,    t2, 1          # addiu   $2,$2,1
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t2, 24(fp)            # sw      $2,24($fp)
main_loop_control:
		addi x0, x0, 0	# nop
		addi x0, x0, 0	# nop
		addi x0, x0, 0	# nop
        lw   t2, 24(fp)            # lw      $2,24($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        slti t2,    t2, 4          # slti    $2,$2, 4
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        beq  t2,    x0, hew        # beq     $2, $zero, hew # beq, j to simulate bne 
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        j    main_loop_body
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
hew:
        sw   x0, 28(fp)            # sw      $0,28($fp)
        j    welcome
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop

wave:
        lw   t2, 28(fp)            # lw      $2,28($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        addi t2,    t2, 1          # addiu   $2,$2,1
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t2, 28(fp)            # sw      $2,28($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
welcome:
        lw   t2, 28(fp)            # lw      $2,28($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        slti t2,    t2, 4          # slti    $2,$2,4
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        xori t2,    t2, 1          # xori    $2,$2,1 # xori 1, beq to simulate bne where val in [0,1]
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        beq  t2,    x0, wave       # beq     $2,$0,wave
		addi x0, x0, 0	# nop
		addi x0, x0, 0	# nop
		addi x0, x0, 0	# nop
        mv   t2,    x0             # move    $2,$0
        mv   sp,    fp             # move    $sp,$fp
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   ra, 36(sp)            # lw      $31,36($sp)
        lw   fp, 32(sp)            # lw      $fp,32($sp)
        addi sp, sp, 40            # addiu   $sp,$sp,40
        	addi x0, x0, 0	# nop
        jr   ra                    # jr      $ra
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        
interest:
        lw   t4, 24(fp)            # lw      $4,24($fp)
        la   ra,    new            # la      $ra, new
        j    is_visited
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
new:
        xori t2,    t2, 1          # xori    $2,$2,0x1
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        andi t2,    t2, 0x0ff      # andi    $2,$2,0x00ff
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        beq  t2,    x0, tasteful   # beq     $2,$0,tasteful
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop

        lw   t4, 24(fp)            # lw      $4,24($fp)
        la   ra,    partner        # la      $ra, partner
        j    topsort
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
partner:

tasteful:
        addi t2,    fp, 28         # addiu   $2,$fp,28
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        mv   t4,    t2             # move    $4,$2
        la   ra,    badge          # la      $ra, badge
        j    next_edge
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
badge:
        sw   t2, 24(fp)            # sw      $2,24($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
turkey:
        lw   t3, 24(fp)            # lw      $3,24($fp)
        li   t2, -1                # li      $2,-1
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        beq  t3,    t2, telling    # beq     $3,$2,telling # beq, j to simulate bne
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        j    interest
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
telling:
        # NOTE: $v0 === $2
	la   t2,    res_idx        # la      $v0, res_idx
		addi x0, x0, 0	# nop
		addi x0, x0, 0	# nop
		addi x0, x0, 0	# nop
	lw   t2,  0(t2)            # lw      $v0, 0($v0)
		addi x0, x0, 0	# nop
		addi x0, x0, 0	# nop
		addi x0, x0, 0	# nop
        addi t4,    t2, -1         # addiu   $4,$2,-1
        la   t3,    res_idx        # la      $3, res_idx
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t4,  0(t3)            # sw      $4, 0($3)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        la   t4,    res            # la      $4, res
                                   # ; lui     $3,%hi(res_idx)
                                   # ; sw      $4,%lo(res_idx)($3)
                                   # ; lui     $4,%hi(res)
        slli t3,    t2, 2          # sll     $3,$2,2
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        srli t3,    t3, 1          # srl     $3,$3,1
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        srai t3,    t3, 1          # sra     $3,$3,1
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        slli t3,    t3, 2          # sll     $3,$3,2
       
       	xor  t6,    ra, t2         # xor     $at, $ra, $2 # does nothing 
        or   t6,    ra, t2         # nor     $at, $ra, $2 # does nothing 
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        neg  t6,    t6
        la   t2,    res            # la      $2, res
        li   a1,    0x0000ffff
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        and  t6,    t2, a1         # andi    $at, $2, 0xffff # -1 will sign extend (according to assembler), but 0xffff won't
        add  t2,    t4, t6         # addu    $2, $4, $at
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        add  t2,    t3, t2         # addu    $2,$3,$2
        lw   t3, 48(fp)            # lw      $3,48($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t3,  0(t2)            # sw      $3,0($2)
        mv   sp,    fp             # move    $sp,$fp
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   ra, 44(sp)            # lw      $31,44($sp)
        lw   fp, 40(sp)            # lw      $fp,40($sp)
        addi sp,    sp, 48         # addiu   $sp,$sp,48
        jr   ra                    # jr      $ra
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
   
topsort:
        addi sp,    sp, -48        # addiu   $sp,$sp,-48
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   ra, 44(sp)            # sw      $31,44($sp)
        sw   fp, 40(sp)            # sw      $fp,40($sp)
        mv   fp,    sp             # move    $fp,$sp
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t4, 48(fp)            # sw      $4,48($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   t4, 48(fp)            # lw      $4,48($fp)
        la   ra,    verse          # la      $ra, verse
        j    mark_visited
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
verse:

        addi t2,    fp, 28         # addiu   $2,$fp,28
        lw   t5, 48(fp)            # lw      $5,48($fp)
        mv   t4,    t2             # move    $4,$2
        la   ra,    joyous         # la      $ra, joyous
        j    iterate_edges
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
joyous:

        addi t2,    fp, 28         # addiu   $2,$fp,28
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        mv   t4,    t2             # move    $4,$2
        la   ra,    whispering     # la      $ra, whispering
        j    next_edge
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
whispering:

        sw   t2, 24(fp)            # sw      $2,24($fp)
        j    turkey
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop

iterate_edges:
        addi sp,    sp, -24        # addiu   $sp,$sp,-24
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   fp, 20(sp)            # sw      $fp,20($sp)
        mv   fp,    sp             # move    $fp,$sp
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sub  t6,    fp, sp         # subu    $at, $fp, $sp
        sw   t4, 24(fp)            # sw      $4,24($fp)
        sw   t5, 28(fp)            # sw      $5,28($fp)
        lw   t2, 28(fp)            # lw      $2,28($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t2,  8(fp)            # sw      $2,8($fp)
        sw   x0, 12(fp)            # sw      $0,12($fp)
        lw   t2, 24(fp)            # lw      $2,24($fp)
        lw   t4,  8(fp)            # lw      $4,8($fp)
        lw   t3, 12(fp)            # lw      $3,12($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t4,  0(t2)            # sw      $4,0($2)
        sw   t3,  4(t2)            # sw      $3,4($2)
        lw   t2, 24(fp)            # lw      $2,24($fp)
        mv   sp,    fp             # move    $sp,$fp
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   fp, 20(sp)            # lw      $fp,20($sp)
        addi sp,    sp, 24         # addiu   $sp,$sp,24
        jr   ra                    # jr      $ra
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        
next_edge:
        addi sp,    sp, -32        # addiu   $sp,$sp,-32
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   ra, 28(sp)            # sw      $31,28($sp)
        sw   fp, 24(sp)            # sw      $fp,24($sp)
        add  fp,    x0, sp         # add     $fp,$zero,$sp
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t4, 32(fp)            # sw      $4,32($fp)
        j    waggish
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop

snail:
        lw   t2, 32(fp)            # lw      $2,32($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   t3,  0(t2)            # lw      $3,0($2)
        lw   t2, 32(fp)            # lw      $2,32($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   t2,  4(t2)            # lw      $2,4($2)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        mv   t5,    t2             # move    $5,$2
        mv   t4,    t3             # move    $4,$3
        la   ra,    induce         # la      $ra,induce
        j    has_edge
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
induce:
        beq  t2,    x0, quarter    # beq     $2,$0,quarter
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   t2, 32(fp)            # lw      $2,32($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   t2,  4(t2)            # lw      $2,4($2)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        addi t4,    t2, 1          # addiu   $4,$2,1
        lw   t3, 32(fp)            # lw      $3,32($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t4,  4(t3)            # sw      $4,4($3)
        j    cynical
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop

quarter:
        lw   t2, 32(fp)            # lw      $2,32($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   t2,  4(t2)            # lw      $2,4($2)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        addi t3,    t2, 1          # addiu   $3,$2,1
        lw   t2, 32(fp)            # lw      $2,32($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t3,  4(t2)            # sw      $3,4($2)

waggish:
        lw   t2, 32(fp)            # lw      $2,32($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   t2,  4(t2)            # lw      $2,4($2)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        slti t2,    t2, 4          # slti    $2,$2,4
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        beq  t2,    x0, mark       # beq     $2,$zero,mark # beq, j to simulate bne 
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        j    snail
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
mark:
        li   t2, -1                # li      $2,-1

cynical:
        mv   sp,    fp             # move    $sp,$fp
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   ra, 28(sp)            # lw      $31,28($sp)
        lw   fp, 24(sp)            # lw      $fp,24($sp)
        addi sp,    sp, 32         # addiu   $sp,$sp,32
        jr   ra                    # jr      $ra
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
has_edge:
        addi sp,    sp, -32        # addiu   $sp,$sp,-32
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   fp, 28(sp)            # sw      $fp,28($sp)
        mv   fp,    sp             # move    $fp,$sp
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t4, 32(fp)            # sw      $4,32($fp)
        sw   t5, 36(fp)            # sw      $5,36($fp)
        la   t2,    adjacencymatrix# la      $2,adjacencymatrix
        lw   t3, 32(fp)            # lw      $3,32($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        slli t3,    t3, 2          # sll     $3,$3,2
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        add  t2,    t3, t2         # addu    $2,$3,$2
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   t2,  0(t2)            # lw      $2,0($2)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t2, 16(fp)            # sw      $2,16($fp)
        li   t2,  1                # li      $2,1
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t2,  8(fp)            # sw      $2,8($fp)
        sw   x0, 12(fp)            # sw      $0,12($fp)
        j    measley
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop

look:
        lw   t2,  8(fp)            # lw      $2,8($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        slli t2,    t2, 1          # sll     $2,$2,1
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t2,  8(fp)            # sw      $2,8($fp)
        lw   t2, 12(fp)            # lw      $2,12($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        addi t2,    t2, 1          # addiu   $2,$2,1
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t2, 12(fp)            # sw      $2,12($fp)
measley:
        lw   t3, 12(fp)            # lw      $3,12($fp)
        lw   t2, 36(fp)            # lw      $2,36($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        slt  t2,    t3, t2         # slt     $2,$3,$2
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        beq  t2,    x0, experience # beq     $2,$0,experience # beq, j to simulate bne 
        j    look
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
experience:
        lw   t3,  8(fp)            # lw      $3,8($fp)
        lw   t2, 16(fp)            # lw      $2,16($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        and  t2,    t3, t2         # and     $2,$3,$2
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        slt  t2,    x0, t2         # slt     $2,$0,$2
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        andi t2,    t2, 0xff       # andi    $2,$2,0x00ff
        mv   sp,    fp             # move    $sp,$fp
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   fp, 28(sp)            # lw      $fp,28($sp)
        addi sp,    sp, 32         # addiu   $sp,$sp,32
        jr   ra                    # jr      $ra
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        
mark_visited:
        addi sp,    sp, -32        # addiu   $sp,$sp,-32
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   fp, 28(sp)            # sw      $fp,28($sp)
        mv   fp,    sp             # move    $fp,$sp
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t4, 32(fp)            # sw      $4,32($fp)
        li   t2,  1                # li      $2,1
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t2,  8(fp)            # sw      $2,8($fp)
        sw   x0, 12(fp)            # sw      $0,12($fp)
        j    recast
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop

example:
        lw   t2,  8(fp)            # lw      $2,8($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        slli t2,    t2, 8          # sll     $2,$2,8
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t2,  8(fp)            # sw      $2,8($fp)
        lw   t2, 12(fp)            # lw      $2,12($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        addi t2,    t2, 1          # addiu   $2,$2,1
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t2, 12(fp)            # sw      $2,12($fp)
recast:
        lw   t3, 12(fp)            # lw      $3,12($fp)
        lw   t2, 32(fp)            # lw      $2,32($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        slt  t2,    t3, t2         # slt     $2,$3,$2
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        beq  t2,    x0, pat        # beq     $2,$zero,pat # beq, j to simulate bne
        j    example
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
pat:

       	la   t2, visited             # la      $2, visited
       		addi x0, x0, 0	# nop
       		addi x0, x0, 0	# nop
       		addi x0, x0, 0	# nop
        sw   t2, 16(fp)              # sw      $2,16($fp)
        lw   t2, 16(fp)              # lw      $2,16($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   t3,  0(t2)              # lw      $3,0($2)
        lw   t2,  8(fp)              # lw      $2,8($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        or   t3,    t3, t2           # or      $3,$3,$2
        lw   t2, 16(fp)              # lw      $2,16($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t3,  0(t2)              # sw      $3,0($2)
        mv   sp,    fp               # move    $sp,$fp
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   fp, 28(sp)              # lw      $fp,28($sp)
        addi sp,    sp, 32           # addiu   $sp,$sp,32
        jr   ra                      # jr      $ra
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        
is_visited:
        addi sp,    sp, -32          # addiu   $sp,$sp,-32
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   fp, 28(sp)              # sw      $fp,28($sp)
        mv   fp,    sp               # move    $fp,$sp
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t4, 32(fp)              # sw      $4,32($fp)
        ori  t2,    x0, 1            # ori     $2,$zero,1
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t2,  8(fp)              # sw      $2,8($fp)
        sw   x0, 12(fp)              # sw      $0,12($fp)
        j    evasive
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop

justify:
        lw   t2,  8(fp)              # lw      $2,8($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        slli t2,    t2, 8            # sll     $2,$2,8
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t2,  8(fp)              # sw      $2,8($fp)
        lw   t2, 12(fp)              # lw      $2,12($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        addi t2,    t2, 1            # addiu   $2,$2,1
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t2, 12(fp)              # sw      $2,12($fp)
evasive:
        lw   t3, 12(fp)              # lw      $3,12($fp)
        lw   t2, 32(fp)              # lw      $2,32($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        slt  t2,    t3, t2           # slt     $2,$3,$2
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        beq  t2,    x0,representative# beq $2,$0,representitive # beq, j to simulate bne
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        j    justify
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
representative:

        la   t2,    visited          # la      $2,visited
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   t2,  0(t2)              # lw      $2,0($2)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        sw   t2, 16(fp)              # sw      $2,16($fp)
        lw   t3, 16(fp)              # lw      $3,16($fp)
        lw   t2,  8(fp)              # lw      $2,8($fp)
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        and  t2,    t3, t2           # and     $2,$3,$2
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        slt  t2,    x0, t2           # slt     $2,$0,$2
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        andi t2,    t2, 0xff         # andi    $2,$2,0x00ff
        mv   sp,    fp               # move    $sp,$fp
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        	addi x0, x0, 0	# nop
        lw   fp, 28(sp)              # lw      $fp,28($sp)
        addi sp,    sp, 32           # addiu   $sp,$sp,32
        jr   ra                      # jr      $ra

end:
	addi x0, x0, 0	# nop
	addi x0, x0, 0	# nop
	addi x0, x0, 0	# nop
        wfi
