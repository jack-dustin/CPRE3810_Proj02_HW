# linear_search.s (Problem)
# Analyze the following code to identify and mitigate software scheduled pipeline hazards.

.text
.globl _start
_start:
    lui x10, 0x10010      # Initialize base memory address to 0x10010000
    addi x11, x0, 42      # Value to search for
    addi x12, x0, 5       # Number of elements in array
    sw x0, 0(x10)         # Zero-init array elements for linear search
    sw x0, 4(x10)
    sw x0, 8(x10)
    sw x0, 12(x10)
    sw x0, 16(x10)
    addi x15, x0, 0       # Current index counter
    addi x14, x0, 4       # Byte offset multiplier (stride)
    add x17, x0, x0       # Found flag (0 = not found)

loop:
    addi x15, x15, 1      # Increment index counter
    lw x13, 0(x10)        # Load current element from memory
    add x10, x10, x14     # Increment memory address pointer to next word
    sub x16, x12, x15     # Calculate difference between max elements and current index
    beq x13, x11, found   # Check if current element matches search value
    nop
    bne x16, x0, loop     # If difference is not zero, continue loop
    nop
    j end
    nop

found:
    addi x17, x0, 1       # Set Found flag to 1
end:
    wfi