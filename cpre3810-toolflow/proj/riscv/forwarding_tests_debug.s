# no forwarding needed, passes
# .text
# .globl _start
# _start:
#     addi x5, x0, 10
#     addi x6, x0, 20
#     add  x7, x5, x6
#     wfi

# forwarding needed to allow for reduced CPI 10 cycles -> 8 cycles
.text
.globl _start
_start:
    addi x5, x0, 10
    add  x6, x5, x0
    wfi

