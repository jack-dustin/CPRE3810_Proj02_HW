.data
    .word 50, 30, 70, 20, 40, 60, 80,  0,  0,  0,  0
    #     0   4   8   12  16  20  24  28  32  36  40
.text


.globl main
main:

    # Initializings
      lui x1, 0x10010

      # Make sure registers are cleared 
      addi x5, x0, 0
      addi x6, x0, 0
      addi x7, x0, 0
      addi x8, x0, 0

    # Ex / Ex  data dependency     # Expecting no stalls
    addi x5, x5, 95
    slli x5, x5, 1      # multiply by 2
    add  x6, x5, x0     # Move x5 into x6
    srli x6, x6, 2      # Divide x6 (=x5) by 4
    add  x5, x6, x5     # x5 = x6 + x5


    # Load / Ex data  dependency
    lw   x7, 0(x1)      # x7 = 50
    add  x8, x7, x7     # x8 = 2 * x7
    lw   x9, 4(x1)      # x9 = 30
    srli x9, x9, 1      # x9 = 30 / 2


    # Load / Store  data dependency
    lw   x7, 0(x1)      # 50
    sw   x7, 28(x1)     # Store just past declared memory
    lw   x8, 8(x1)      # 70
    sw   x8, 32(x1)     # store just past new space
    lw   x9, 28(x1)     # Bring back value
    sw   x9, 36(x1)     # Basically duplicate again, storing at a different address


    # Ex / Branch  data dependency      # jumps to avoid fall through behavior
    j Label1_in

    bneExBranch:
        addi x8, x0, -200   # Some negative value, or large unsigned value
        bltu x0, x8, Label1_out

    Label1_in:
        addi x10, x0, 5     # x10 = 5
        bne  x10, x0, bneExBranch

    Label1_out:


    # Load / Branch  data dependency
    j Label2_in 

    bltLoadBranch:
        lw   x6, 4(x1)
        bge  x6, x8, Label2_out

    Label2_in:
        lw   x5, 0(x1)
        blt  x8, x5, bltLoadBranch

    Label2_out:


    # Ex / Store  data dependency
    add  x6, x5, x5     # x6 = 50 + 30 = 80
    sw   x8, 28(x1)     # Store first addr past real declared mem
    srli x6, x6, 1      # Divide x6 by 1 --> x6 = 80
    sw   x6, 32(x1)     # Store 1 addr past last store


    # Load / Store addr  data dependency
    sw   x1, 40(x1)    # Put an address in memory
    
    lw   x12, 40(x1)    # Load x1 into x12
    sw   x6,  28(x12)   # Store x6 using pseudo x12

    lw   x8,  40(x1)    # Load x1 into x8
    sw   x12, 36(x8)    # Store x12 with x8

wfi