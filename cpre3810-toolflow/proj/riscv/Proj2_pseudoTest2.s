# Same test as before, but using x-register names explicitly
#
# Register mapping used here:
#   x1  = ra
#   x5  = t0
#   x6  = t1
#   x7  = t2
#   x8  = s0
#   x9  = s1
#   x10 = a0
#   x11 = a1
#   x12 = a2
#   x18 = s2
#   x19 = s3
#   x28 = t3
#   x29 = t4
#   x30 = t5
#   x31 = t6
#
# Pseudos:
#   la   rd, label
#   mv   rd, rs
#   neg  rd, rs
#   jr   rs

.data
some_data:
    .word 1234

.text
.globl main

main:
    ########################################################
    # 1) Test la on a DATA label, then use it immediately
    ########################################################
    la   x8, some_data      # x8  = address of some_data
    mv   x9, x8             # use la result immediately
    neg  x18, x9            # use mv result immediately
    mv   x19, x18           # use neg result immediately

    ########################################################
    # 2) Test la on a CODE label, then return with jr
    ########################################################
    la   x1, return_one     # x1 = manually built return address
    j    func_one           # jump away; func_one must jr back

return_one:
    mv   x5, x1             # use returned x1 immediately
    neg  x6, x5             # use mv result immediately
    mv   x7, x6             # use neg result immediately

    ########################################################
    # 3) Do it again so each target instruction is used
    #    more than once
    ########################################################
    la   x1, return_two     # second code-label la
    j    func_two

return_two:
    mv   x10, x1            # second mv after a return
    neg  x11, x10           # second neg
    mv   x12, x11           # another immediate dependency

    j end                   # stop here

############################################################
# Function 1
# Tests:
#   - mv using x1
#   - neg using that moved value
#   - mv putting address back into x1
#   - jr x1 returning with that value
############################################################
func_one:
    mv   x28, x1            # copy return address
    neg  x29, x28           # use mv result immediately
    mv   x1, x28            # put original return address back
    jr   x1                 # return

############################################################
# Function 2
# Same idea again, with a different return label
############################################################
func_two:
    mv   x30, x1            # copy return address
    neg  x31, x30           # use mv result immediately
    mv   x1, x30            # restore return address
    jr   x1                 # return

end:
    wfi
