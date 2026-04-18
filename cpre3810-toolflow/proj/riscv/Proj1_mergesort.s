# Isaiah Pridie, Jack Dustin
# CprE 3810 - Assembly Merge Sort
# Start Date: 4.4.2026, 2:08 PM

# a0 used for first element address of chunck
# a1 used for num elements in (current) chunck
# a2 used for last element address of chunck

# To change Number of Elements, Change:
	# Number of physical elements in .word line
	# The reserved space in .space __ for how many bytes you need
	# Under main: addi a1, x0, __ where __ is the number of elements desired

.data
arr:
    .word 31, 5, 100, 92, 73, 50
end_arr:
temp:
    .space 24          # 6 words * 4 bytes
  
.text
.global main

main:
lui  a0, 0x10010    # start of data/arr
addi a1, x0, 6     # 12 elements
slli a2, a1, 2      # 6 * 4 gets 24 bytes of data
add  s11, a2, x0    # s11 now holds number of bytes declared
add  a2, a0, a2     # a2 = Address of last element + 1
addi a2, a2, -4     # a2 = Address of last element
lui  sp, 0x80000
addi sp, sp, -4
jal  x1, MergeSortRecurse   # Calls MergeSortRecurse. Returns value to register x1 (aka ra)
beq  x0, x0 EXIT	# Unconditional jump to EXIT (wfi at end of file)
	# Even with wfi, code will keep running if wfi is not the last line of the file

MergeSortRecurse: 
    # if left address >= right address, return/end
    bltu a0, a2, Continue      
        jalr x0, x1, 0  # Canonical ret - Ends Recursive Splitting
    Continue:

    # Save initial values/conditions - recursing will overwrite regsiters
    addi sp, sp, -16    # Reserve Space on stack
    sw   ra, 12(sp)     # Return Value
    sw   a0,  8(sp)     # First element address of chunk
    sw   a1,  4(sp)     # Size of chunk 
    sw   a2,  0(sp)     # Last element address of chunk

    srli a4, a1, 1      # a4 = left size = size / 2     # Compute where to split
    slli a5, a4, 2      # a5 = Number of bytes in left half
    add  a6, a0, a5     # a6 = address of first element in right half
    addi a7, a6, -4     # a7 = address of left element in left half
    sub  t0, a1, a4     # t0 = right size = total size - left size

    # Recurse on left half
    add  a1, a4, x0     # a1 = size = left size
    add  a2, a7, x0     # a2 = last = left last
    jal  ra, MergeSortRecurse   # Calls MergeSortRecurse for left side

    # Hits here after returning from jalr MergeSortRecurse above
    # Restore saved initial values to do right half. We need the original array values. That's why we store and call them back
    lw   a0, 8(sp)      # First element address of chunk
    lw   a1, 4(sp)      # Size of chunk
    lw   a2, 0(sp)      # Last element address of chunk

    # Set right-half arguments
    srli a4, a1, 1      # a4 = left size (recomputed)
    sub  t0, a1, a4     # t0 = right size
    slli a5, a4, 2      # a5 = left size in bytes
    add  a6, a0, a5     # a6 = First address of right side

    add  a0, a6, x0     # a0 = first addrss of right side. Put in register a0
    add  a1, t0, x0     # a1 = right chunk size
    jal  ra, MergeSortRecurse    # Right Side Recusrion

    # Restore the original array a second time. 
    # Need this again because merge needs to store the sorted words into the original array addresses
    lw   ra, 12(sp)     # Return value
    lw   a0,  8(sp)     # First address
    lw   a1,  4(sp)     # Size of array/chunk
    lw   a2,  0(sp)     # Last Address
    addi sp, sp, 16     # Resolve reserved stack space (think of it like freeing malloc - Cleaning up our mess)

    # Recompute split for merge
    srli a4, a1, 1      
    slli a5, a4, 2
    add  a6, a0, a5     # right first
    addi a7, a6, -4     # Left last

    # No branch - fall through to Merge

Merge:
    # Inputs at entry:
    # LEFT  half: first=a0, size=a4, last=a7
    # RIGHT half: first=a6, size=t0, last=a2
    #
    # Uses temp[] as merge buffer, then copies back into original chunk.

    add  t1, a0, x0          # t1 = left ptr
    add  t2, a6, x0          # t2 = right ptr
    add  t4, a7, x0          # t4 = left end
    add  t5, a2, x0          # t5 = right end

    # lui  t6, %hi(temp)
    # addi t6, t6, %lo(temp)   # t6 = temp base
    lui  t6, 0x10010
    add  t6, t6, s11
    
    add  t3, t6, x0          # t3 = temp write ptr

MergeLoopCheck:
    # if left exhausted, copy remaining right
    bltu t4, t1, CopyRightRemainder

    # if right exhausted, copy remaining left
    bltu t5, t2, CopyLeftRemainder

    # load current left/right values
    lw   a3, 0(t1)           # a3 = *left
    lw   a5, 0(t2)           # a5 = *right

    # if right < left, take right; else take left
    blt  a5, a3, TakeRight

TakeLeft:
    sw   a3, 0(t3)
    addi t1, t1, 4
    addi t3, t3, 4
    beq  x0, x0, MergeLoopCheck

TakeRight:
    sw   a5, 0(t3)
    addi t2, t2, 4
    addi t3, t3, 4
    beq  x0, x0, MergeLoopCheck


CopyLeftRemainder:
    bltu t4, t1, CopyBackStart
CopyLeftLoop:
    lw   a3, 0(t1)
    sw   a3, 0(t3)
    addi t1, t1, 4
    addi t3, t3, 4
    bgeu t4, t1, CopyLeftLoop
    beq  x0, x0, CopyBackStart


CopyRightRemainder:
    bltu t5, t2, CopyBackStart
CopyRightLoop:
    lw   a5, 0(t2)
    sw   a5, 0(t3)
    addi t2, t2, 4
    addi t3, t3, 4
    bgeu t5, t2, CopyRightLoop


CopyBackStart:
    # lui  t6, %hi(temp)
    # addi t6, t6, %lo(temp)   # t6 = temp read ptr
    lui  t6, 0x10010
    add  t6, t6, s11
    

    add  t1, a0, x0          # t1 = original chunk write ptr
    add  t2, a1, x0          # t2 = number of elements to copy back

CopyBackLoop:
    beq  t2, x0, MergeDone
    lw   a3, 0(t6)
    sw   a3, 0(t1)
    addi t6, t6, 4
    addi t1, t1, 4
    addi t2, t2, -1
    beq  x0, x0, CopyBackLoop


MergeDone:
    # Temporary fix to see if this fixes the program
    # wfi		# end program
    jalr x0, 0(ra)


EXIT:
    wfi
    
    # DEBUGGING
    #addi t5, x0, 10
    #add  t6, x0, x0		# clear t6
    
    # Loop in here 10 times, then exit
    #LOOP_EXIT:
    #addi t6, t6, 1		# increment by 1
    #addi x0, x0, 0		# nop
    #bne t6, t5, LOOP_EXIT	

    #beq  x0, x0, EXIT		# remain inside exit loop
