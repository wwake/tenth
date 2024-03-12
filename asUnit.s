.global assertEqual

.text
.align 2
L_passMessage:
.asciz "\033[32mPass\033[0m\n"

L_failedMessage:
.asciz "\033[31mFail: x0="

L_x1:
.asciz " x1="

L_failMessageEnd:
.asciz "\033[0m\n"

.align 2

// assertEqual: prints pass if x0 == x1, or fail message if x0 != x1
assertEqual:
	str lr, [sp, #-16]!
	str x22, [sp, #8]
	str x11, [sp, #-16]!

	mov x22, x0
	mov x11, x1

	cmp x0, x1
	bne L_failed
	
	adr x0, L_passMessage
	bl print

	mov x0, #1
	b L_exiting
	
L_failed:
	adr x0, L_failedMessage
	bl print

	mov x0, x22
	bl dec2str
	bl print

	adr x0, L_x1
	bl print

	mov x0, x11
	bl dec2str
	bl print

	adr x0, L_failMessageEnd
	bl print

	mov x0, #0

L_exiting:
	ldr x11, [sp], #16
	ldr x22, [sp, #8]
	ldr lr, [sp], #16
	ret

.align 2
