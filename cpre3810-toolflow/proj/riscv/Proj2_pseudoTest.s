# Very small hazard test focused on:
#   la, jr, mv, neg
#
# Pseudos:
#   la   rd, label   -> usually expands to auipc/addi
#   mv   rd, rs      -> addi rd, rs, 0
#   neg  rd, rs      -> sub  rd, x0, rs
#   jr   rs          -> jalr x0, 0(rs)
#
# Goal:
#   Stress the exact things you care about:
#   - la creating an address
#   - using that address through mv
#   - using mv result immediately
#   - using neg result immediately
#   - returning with jr using an address made by la

.data
some_data:
    .word 1234

.text
.globl main

main:
    ########################################################
    # 1) Test la on a DATA label, then use it immediately
    ########################################################
    la   s0, some_data      # build address of some_data
    mv   s1, s0             # use la result immediately
    neg  s2, s1             # use mv result immediately
    mv   s3, s2             # use neg result immediately

    ########################################################
    # 2) Test la on a CODE label, then return with jr
    ########################################################
    la   ra, return_one     # manually build return address
    j    func_one           # jump away; func_one must jr back

return_one:
    mv   t0, ra             # use returned ra immediately
    neg  t1, t0             # use mv result immediately
    mv   t2, t1             # use neg result immediately

    ########################################################
    # 3) Do it again so each target instruction is used
    #    more than once
    ########################################################
    la   ra, return_two     # second code-label la
    j    func_two

return_two:
    mv   a0, ra             # second mv after a return
    neg  a1, a0             # second neg
    mv   a2, a1             # another immediate dependency

    j end                   # stop here

############################################################
# Function 1
# Tests:
#   - mv using ra
#   - neg using that moved value
#   - mv putting address back into ra
#   - jr ra returning with that value
############################################################
func_one:
    mv   t3, ra             # copy return address
    neg  t4, t3             # use mv result immediately
    mv   ra, t3             # put original return address back
    jr   ra                 # return

############################################################
# Function 2
# Same idea again, with a different return label
############################################################
func_two:
    mv   t5, ra             # copy return address
    neg  t6, t5             # use mv result immediately
    mv   ra, t5             # restore return address
    jr   ra                 # return
    
end:
    wfi
