
    .text
    .globl _start

_start:
    # ------------------------------------------------------------
    # Basic setup
    # ------------------------------------------------------------
    lui   x20, 0x10010          # x20 = 0x10010000  (data base)
    addi  x2,  x0, -128         # x2 = 0xFFFFFF80
    addi  x3,  x0, 5            # x3 = 5
    addi  x4,  x0, 3            # x4 = 3
    addi  x5,  x0, -8           # x5 = -8
    lui   x1,  0x00012          # x1 = 0x00012000

    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    addi  x1,  x1, 52           # x1 = 0x00012034

    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    # ------------------------------------------------------------
    # Stores
    # ------------------------------------------------------------
    sw    x1,  0(x20)           # word  = 0x00012034
    sw    x2,  4(x20)
    sw    x3,  8(x20)
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    # ------------------------------------------------------------
    # Loads
    # ------------------------------------------------------------
    lb    x10, 0(x20)
    lh    x11, 4(x20)
    lw    x12, 8(x20)
    lbu   x13, 0(x20)
    lhu   x14, 4(x20)

    # ------------------------------------------------------------
    # I-type ALU instructions
    # ------------------------------------------------------------
    addi  x15, x4, 10
    slli  x16, x4, 2
    slti  x17, x5, 0
    sltiu x18, x5, 1
    xori  x19, x4, 12
    srli  x21, x1, 4
    srai  x22, x5, 1
    ori   x23, x4, 8
    andi  x24, x1, 255
    auipc x25, 0

    # ------------------------------------------------------------
    # R-type ALU instructions
    # ------------------------------------------------------------
    add   x26, x3, x4
    sub   x27, x3, x4
    sll   x28, x4, x4
    slt   x29, x5, x4
    sltu  x30, x4, x3
    xor   x31, x3, x4
    srl   x6,  x1, x4
    sra   x7,  x5, x4
    or    x8,  x3, x4
    and   x9,  x3, x4

    # ------------------------------------------------------------
    # Branches
    # 3 nops after each branch so you do not need a flush
    # ------------------------------------------------------------
    beq   x3,  x3,  BEQ_OK
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
BEQ_OK:

    bne   x3,  x4,  BNE_OK
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
BNE_OK:

    blt   x5,  x4,  BLT_OK
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
BLT_OK:

    bge   x3,  x4,  BGE_OK
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
BGE_OK:

    bltu  x4,  x3,  BLTU_OK
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
BLTU_OK:

    bgeu  x3,  x4,  BGEU_OK
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
BGEU_OK:

    # ------------------------------------------------------------
    # JAL
    # 3 nops after jump so you do not need a flush
    # ------------------------------------------------------------
    jal   x18, JAL_OK
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
JAL_OK:

    # ------------------------------------------------------------
    # JALR
    # Build target without pseudo instructions.
    # x19 = address of JALR_OK
    # ------------------------------------------------------------
    auipc x19, 0

    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    addi  x19, x19, 48

    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0

    jalr  x21, 0(x19)
    addi  x0,  x0, 0
    addi  x0,  x0, 0
    addi  x0,  x0, 0
JALR_OK:

    # ------------------------------------------------------------
    # End
    # ------------------------------------------------------------
    bne x0, x0, JALR_OK
    bne x0, x0, JALR_OK
    bne x0, x0, JALR_OK
    bne x0, x0, JALR_OK
    bne x0, x0, JALR_OK
    wfi
