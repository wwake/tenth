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
//   x2 - bits to clear
//
clear_bits_at:
	ldr x3, [x0, x1]
	mvn x2, x2
	and x3, x3, x2
	str x3, [x0, x1]
	ret


// The termios structure contains a word each for input, output, control, & local flags, followed by a number of characters for line discipline and other control.
// From examining C code that sets raw mode, and tracing into the unix calls,
// we determined that this is the termios struct we need, before and after:

//Before:
//02 6b 00 00 00 00 00 00
//03 00 00 00 00 00 00 00
//00 4b 00 00 00 00 00 00
//cb 05 00 20 00 00 00 00 *
//04 ff ff 7f 17 15 12 ff
//03 1c 1a 19 11 13 16 0f
//01 00 14 ff 00 00 00 00
//80 25 00 00 00 00 00 00
//80 25 00 00 00 00 00 00
//
//After:
//02 6b 00 00 00 00 00 00
//03 00 00 00 00 00 00 00
//00 4b 00 00 00 00 00 00
//c3 04 00 20 00 00 00 00 *
//04 ff ff 7f 17 15 12 ff
//03 1c 1a 19 11 13 16 0f
//01 00 14 ff 00 00 00 00
//80 25 00 00 00 00 00 00
//80 25 00 00 00 00 00 00

// So, to clear the ECHO and ICANON bits, we need to operate on the starred row.
// See https://codebrowser.dev/glibc/glibc/sysdeps/unix/sysv/linux/bits/termios-c_lflag.h.html
// for "approximate" definitions (can't find Mac-specific documentation)

.equ index_of_lflag, 24
.equ echo_flag, 0x8
.equ icanon_flag, 0x100
