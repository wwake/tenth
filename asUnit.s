.global assertEqual

.align 2
// assertEqual: prints pass if x0 == x1, or fail message if x0 != x1
assertEqual:
    str lr, [sp, #-16]!
            
    cmp x0, x1
    bne failed
    
    adr x0, passMessage
    bl print
    
    ldr lr, [sp], #16
    ret

failed:
    adr x0, failedMessage
    bl print

    ldr lr, [sp], #16
    ret

passMessage:
    .asciz "Pass\n"

failedMessage:
    .ascii "Failed\n"
