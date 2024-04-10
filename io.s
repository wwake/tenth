#include "core.defines"
#include "assembler.macros"

.global dotprint
.global dot_print_string

.global nl

.global clear_bits_at

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


dot_print_string:
	STD_PROLOG

	DATA_TOP x0
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



.align 2

// clear_bits_at: clear bits in a given byte
// Input:
//   x0 - pointer to byte sequence
//   x1 - index to change
//   w2 - bits to clear
//
clear_bits_at:
	ldrb w3, [x0, x1]
	mvn w2, w2
	and w3, w3, w2
	strb w3, [x0, x1]
	ret
