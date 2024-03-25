#include "core.defines"
#include "assembler.macros"

.global dotprint

.data
L_space:
	.asciz " "

.text
.align 2

dotprint:
	STD_PROLOG

	DATA_POP x0
	bl printnum

	LOAD_ADDRESS x0, L_space
	bl print

	STD_EPILOG
	ret
