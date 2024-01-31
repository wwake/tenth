.global assertEqual

.align 2
// assertEqual: prints pass if x0 == x1, or fail message if x0 != x1
assertEqual:
    str lr, [sp, #-16]!
            
    cmp x0, x1
    bne L_failed
    
    adr x0, passMessage
    b L_exiting
    
L_failed:
    adr x0, failedMessage

L_exiting:
    bl print

    ldr lr, [sp], #16
    ret

passMessage:
    .asciz "Pass\n"

failedMessage:
    .ascii "Failed\n"
