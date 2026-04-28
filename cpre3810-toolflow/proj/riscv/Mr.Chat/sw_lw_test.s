.text
.globl _start
_start:
    addi x1, x0, 0	# Clear
    lui  x1, 0x10010
    addi x1, x1, 100
    addi x5, x0, 42
    sw   x5, 0(x1)
    lw   x6, 0(x1)

    addi x7, x0, 77
    add  x8, x7, x0
    sw   x8, 4(x1)
    lw   x9, 4(x1)

    wfi
