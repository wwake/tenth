#include "core.defines"
#include "assembler.macros"

.global dotprint

.global nl

.data
L_space:
	.asciz " "

.text
.align 2

dotprint:
	STD_PROLOG

	DATA_TOP x0
	bl printnum

	LOAD_ADDRESS x0, L_space
	bl print

	STD_EPILOG
	ret


// nl - print a newline
// Input: none
// Process:
//   x0 - used as temp to refer to NL character
// Output:
//   value is printed
nl:
	STD_PROLOG

	adr x0, L_nl_character
	bl print

	STD_EPILOG
	ret

L_nl_character:
	.asciz "\n"

