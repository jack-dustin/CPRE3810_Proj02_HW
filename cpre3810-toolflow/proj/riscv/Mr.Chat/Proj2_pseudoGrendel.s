# Mini Grendel
#
# Goal:
#   Mimic the grendel-style behavior that seems suspicious:
#   - main manually "calls" topsort with: la x1, label ; j topsort
#   - topsort saves caller x1 on the stack
#   - topsort makes internal pseudo-calls with local return labels:
#         la x1, verse      ; j mark_visited
#         la x1, joyous     ; j has_edge
#         la x1, whispering ; j is_visited
#   - helper functions return with jr x1
#   - topsort branches on returned values
#   - topsort finally restores original x1 and jr x1 back to main
#
# This is much closer to grendel than the tiny pseudo test, but still small.

.data
visited:
    .word 0                # visited[0] = 0 at start

edge_flag:
    .word 1                # pretend there is an edge

stack_mem:
    .space 128             # fake stack area for this test
stack_top:

.text
.globl main

############################################################
# main
############################################################
main:
    la   x2, stack_top     # x2 = sp
    addi x10, x0, 0        # x10 = "node index" argument = 0

    # manual call into topsort
    la   x1, pump
    j    topsort

pump:
    j    end_program

############################################################
# topsort
# Saves caller x1/fp, then does internal la/j helper calls
############################################################
topsort:
    addi x2, x2, -48       # allocate stack frame
    sw   x1, 44(x2)        # save caller return address
    sw   x8, 40(x2)        # save old frame pointer
    mv   x8, x2            # x8 = fp

    sw   x10, 48(x8)       # save incoming argument like grendel
    lw   x10, 48(x8)       # reload it right away

    # mark_visited(node)
    la   x1, verse
    j    mark_visited

verse:
    # has_edge(node)
    lw   x10, 48(x8)       # reload argument again
    la   x1, joyous
    j    has_edge

joyous:
    # if has_edge returned 0, skip next helper
    beq  x6, x0, done_top

    # is_visited(node)
    lw   x10, 48(x8)
    la   x1, whispering
    j    is_visited

whispering:
    # if is_visited returned 0, skip to end
    beq  x6, x0, done_top

    # fall through if visited != 0
    addi x5, x0, 123       # dummy work after nested returns

done_top:
    mv   x2, x8            # tear down frame
    lw   x1, 44(x2)        # restore caller return address
    lw   x8, 40(x2)        # restore old fp
    addi x2, x2, 48
    jr   x1

############################################################
# mark_visited(node)
# visited[0] = 1
############################################################
mark_visited:
    addi x2, x2, -16
    sw   x8, 12(x2)
    mv   x8, x2

    la   x5, visited
    addi x6, x0, 1
    sw   x6, 0(x5)         # visited = 1

    mv   x2, x8
    lw   x8, 12(x2)
    addi x2, x2, 16
    jr   x1

############################################################
# has_edge(node)
# returns x6 = edge_flag
############################################################
has_edge:
    addi x2, x2, -16
    sw   x8, 12(x2)
    mv   x8, x2

    la   x5, edge_flag
    lw   x6, 0(x5)         # x6 = 1

    mv   x2, x8
    lw   x8, 12(x2)
    addi x2, x2, 16
    jr   x1

############################################################
# is_visited(node)
# returns x6 = visited[0]
############################################################
is_visited:
    addi x2, x2, -16
    sw   x8, 12(x2)
    mv   x8, x2

    la   x5, visited
    lw   x6, 0(x5)         # x6 = visited[0]

    mv   x2, x8
    lw   x8, 12(x2)
    addi x2, x2, 16
    jr   x1

############################################################
# End
############################################################
end_program:
    wfi
