#include "core.defines"
#include "assembler.macros"

.global assertEqual
.global assertEqualStrings
.global assertTrue
.global assertFalse

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
	STD_PROLOG
	str NEXT_WORD, [sp, #8]
	str x11, [sp, #-16]!

	mov NEXT_WORD, x0
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

	mov x0, NEXT_WORD
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
	ldr NEXT_WORD, [sp, #8]
	STD_EPILOG
	ret

.align 2

L_stringdiff1:
	.asciz "  x0=>"

L_stringdiff2:
	.asciz "\n  x1=>"

L_newline:
	.asciz "\n"

.align 2


// assertEqualString -
// Inputs:
//   x0 - actual string
//   x1 - expected string
assertEqualStrings:
	STD_PROLOG

	str x0, [sp, #-16]!
	str x1, [sp, #8]

	bl streq
	mov x1, #1
	bl assertEqual

	cmp x0, #1
	b.eq exit_assertEqualString

	LOAD_ADDRESS x0, L_stringdiff1
	bl print

	ldr x0, [sp]			// saved x0
	bl print

	LOAD_ADDRESS x0, L_stringdiff2
	bl print

	ldr x0, [sp, #8]		// saved x1
	bl print

	LOAD_ADDRESS x0, L_newline
	bl print

exit_assertEqualString:
	ldr x1, [sp, #8]
	ldr x0, [sp], #16
	STD_EPILOG
	ret



// assertTrue - check that x0 == 1 (true)
// Uses x0
// Returns result in x0; prints message if x0 == 0
//
assertTrue:
	STD_PROLOG

	mov x1, #1
	bl assertEqual

	STD_EPILOG
	ret


// assertFalse - check that x0 == 0 (false)
// Uses x0, x1
// Returns result in x0; prints message if x0 <> 0
//
assertFalse:
	STD_PROLOG

	mov x1, #0
	bl assertEqual

	STD_EPILOG
	ret
