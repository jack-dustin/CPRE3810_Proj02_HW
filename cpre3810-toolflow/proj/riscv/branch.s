# for tesing branching

.text

    addi x1, x0, 15	# Make x1 00..001111
    addi x2, x0, 25	# Make x2 25
    addi x3, x0, 35	# Make x3 35
    addi x4, x0, 45	# Make x4 45
    addi x5, x0, 55	# Make x5 55
    addi x6, x0, 65	# Make x6 65
    addi x7, x0, 75	# Make x7 75
    addi x8, x0, 85	# Make x8 85
    addi x9, x0, 95	# Make x9 95
    lui  x10, 0xFFFFF	# Make x10 either a negative, or very big number

TOP_0:
    beq x1, x2, TOP_1	# Should not branch
    beq x2, x3, TOP_1	# Should not branch 
    beq x3, x4,	TOP_1	# Should not branch
    
    bne x4, x5, TOP_1	# Should branch to TOP_1	
    j END
    
TOP_1: 
    bne x0, x0, TOP_2	# Should not branch
    bne x1, x1, TOP_2	# Should not branch
    bne x2, x2, TOP_2	# Should not branch
 
    blt x1, x2,	TOP_2	# Should branch to TOP_2 
    j END

TOP_2:
    blt x2, x1, TOP_3	# Should not branch
    blt x4, x2, TOP_3	# Should not branch
    blt x6, x10, TOP_3 	# Should not branch
    
    bltu x9, x10, TOP_3	# Should branch to TOP_3    -- small < VERY big
    j END
    
TOP_3:
    bltu x5, x1, TOP_4	# Should not branch
    bltu x6, x3, TOP_4	# Should not branch
    bltu x7, x4, TOP_4	# Should not branch
    
    bge x8, x6, TOP_4	# Should branch to TOP_4
    j END
    
TOP_4: 
    bge x2, x7, TOP_5	# Should not branch
    bge x3, x8, TOP_5	# Should not branch
    bge x10, x9, TOP_5	# Should not branch
    
TOP_5_0: bgeu x10, x9, TOP_5	# Should branch to TOP_5
    j END
    
TOP_5:
    bgeu x9, x10, TOP_6	# Should not branch
    bgeu x1, x10, TOP_6	# Should not branch
    bgeu x0, x10, TOP_6	# Should not branch
    bgeu x10, x0, TOP_6	# Should branch to TOP_6
    j TOP_0	# Cause inifite loop on purpose if the test above fails. ToolFlow will stop it
    
    
    beq x0, x0, TOP_7
    TOP_7: j TOP_8
    
    TOP_8: blt x3, x7, TOP_9
    TOP_9: j TOP_6
    
    
    

TOP_6: j END

END:
wfi

