#.data
#result: .word 0      # to store the result

.text
.globl main
main:
   #la t2, result
    addi t0, x0, 0x0F 	# li t0, 0x0F       # t0 = 0x0F
    ori t1, t0, 0xF0  # t1 = t0 | 0xF0 → 0xFF

   #sw t1, 0(t2)   # store result
    wfi                # end / wait for interrupt
