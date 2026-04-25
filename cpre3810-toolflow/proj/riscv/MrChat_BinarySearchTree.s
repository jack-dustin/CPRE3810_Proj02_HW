# File made by Mr. ChatGPT 5.4

.data
values: .word 50, 30, 70, 20, 40, 60, 80
count: .word 7
root: .word 0
nodes: .space 84

.text
MAIN:
    la s0, values      # s0 = current input value address
    lw s1, count       # s1 = number of values
    la s2, nodes       # s2 = next free node address
    li s4, 0           # s4 = inserted count

BUILD_LOOP:
    beq s4, s1, DONE

    lw a0, 0(s0)       # a0 = value to insert
    mv a1, s2          # a1 = new node address

    call MAKE_NODE
    call INSERT_NODE

    addi s0, s0, 4     # next input value
    addi s2, s2, 12    # next node slot
    addi s4, s4, 1
    j BUILD_LOOP

MAKE_NODE:
    sw a0, 0(a1)       # node.value = value
    sw zero, 4(a1)     # node.left = 0
    sw zero, 8(a1)     # node.right = 0
    jr ra

INSERT_NODE:
    la t0, root
    lw t1, 0(t0)       # t1 = root pointer

    bne t1, zero, SEARCH_TREE

    sw a1, 0(t0)       # root = new node
    jr ra

SEARCH_TREE:
    lw t2, 0(t1)       # t2 = current node value

    blt a0, t2, GO_LEFT

GO_RIGHT:
    lw t3, 8(t1)       # t3 = current.right
    beq t3, zero, SET_RIGHT
    mv t1, t3
    j SEARCH_TREE

GO_LEFT:
    lw t3, 4(t1)       # t3 = current.left
    beq t3, zero, SET_LEFT
    mv t1, t3
    j SEARCH_TREE

SET_LEFT:
    sw a1, 4(t1)       # current.left = new node
    jr ra

SET_RIGHT:
    sw a1, 8(t1)       # current.right = new node
    jr ra

DONE:
    wfi
