.include "assembler.macros"

.global nl
.global _push
.global add
.global _if_true
.global _jump

.align 2

.ascii "nl\0....."  // Name - 16 bytes
.align 4
.quad 0xdeadbeef

.quad 0			 // Link to previous entry
.quad .+8		 // Offset to code

.p2align 2
// code
nl:
	str   lr, [sp, #-16]!
	
	adr x0, L_nl_character
	bl print
	
	ldr lr, [sp], #16
	ret

L_nl_character:
	.asciz "\n"
	
.p2align 2


table:
	bl nl
	bl nl
	bl print
	bl _start
.quad 0

.p2align 2

_push:
	ldr x0, [x20], #8
	DATA_PUSH x0
	ret


add: 
	DATA_POP x1
	DATA_POP x0
	add x0, x0, x1
	DATA_PUSH x0
	ret
	
_if_true:
	DATA_POP x0
	CMP x0, #0
	b.eq L_skip_if
		add x20, x20, #8
	b L_end_if_true
L_skip_if:
		ldr x20, [x20]
L_end_if_true:
	ret


_jump:
	ldr x20, [x20]
	ret
