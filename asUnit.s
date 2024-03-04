.global assertEqual

.text
.align 2
L_passMessage:
.asciz "\033[32mPass\033[0m\n"

L_failedMessage:
.asciz "\033[31mFail\033[0m\n"

.align 2

// assertEqual: prints pass if x0 == x1, or fail message if x0 != x1
assertEqual:
	str lr, [sp, #-16]!
			
	cmp x0, x1
	bne L_failed
	
	adr x0, L_passMessage
	b L_exiting
	
L_failed:
	adr x0, L_failedMessage

L_exiting:
	bl print

	ldr lr, [sp], #16
	ret

.align 2
