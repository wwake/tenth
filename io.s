#include "core.defines"
#include "assembler.macros"
#include "unix_functions.macros"

.global dotprint
.global dot_print_string

.global nl

.global clear_bits_at
.global set_bits_at

.global enter_raw_mode
.global exit_raw_mode

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

// clear_bits_at: clear bits in a given word
// Input:
//   x0 - pointer to word array
//   x1 - word offset from x0
//   x2 - bits to clear
//
clear_bits_at:
	ldr x3, [x0, x1, lsl #3]
	mvn x2, x2
	and x3, x3, x2
	str x3, [x0, x1, lsl #3]
	ret


// set_bits_at: clear bits in a given word
// Input:
//   x0 - pointer to word array
//   x1 - word offset from x0
//   x2 - bits to set
//
set_bits_at:
	ldr x3, [x0, x1, lsl #3]
	orr x3, x3, x2
	str x3, [x0, x1, lsl #3]
	ret


// Entering raw mode -
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

.data
L_termios:
  .fill 100, 8, 0

.text
.align 2


// tcgetattrs - Call ioctl to get terminal attributes
// Input:
//   fileDescriptor number (0=stdin, 1=stdout, 2=stderr)
//   termiosStruct - address to write to
// Note:
	// The code 0x40487413 specifies that it's get:
	//    0x40 = '@' sign (marker??) (read mode?)
	//    0x48 = 72 base 10 = size of termios struct
	//    0x74 = 't' = code to say it's terminal control
	//    0x13 = 19 = code for get attributes
//
.macro get_terminal_attributes fileDescriptor, termiosStruct
	mov x0, \fileDescriptor
	mov w1, #0x7413	// see above
	movk w1, #0x4048, lsl #16
	LOAD_ADDRESS x2, \termiosStruct
	unix_ioctl
.endm


// set_terminal_attributes

// The code 0x80487414 specifies set terminal attributes
//		0x80 = 128 decimal (marker?) (write mode?)
//     0x48 = 72 base 10 = size of termios struct
//     0x74 = 't' = code to say it's terminal control
//     0x14 = 20 = code for set attributes
//
.macro set_terminal_attributes fileDescriptor, termiosStruct
	mov x0, \fileDescriptor
	mov w1, #0x7414	// see above
	movk w1, #0x8048, lsl #16
	LOAD_ADDRESS x2, \termiosStruct
	unix_ioctl

.endm

.equ index_of_lflag, 24
.equ echo_flag, 0x8
.equ icanon_flag, 0x100


// enter_raw_mode - sets terminal mode to raw (ish) - clear echo & icanon
//
enter_raw_mode:
	STD_PROLOG

	get_terminal_attributes #0, L_termios

	// Clear echo and icanon flags
	LOAD_ADDRESS x0, L_termios
	mov x1, index_of_lflag
	mov x2, (echo_flag + icanon_flag)
	bl clear_bits_at

	set_terminal_attributes #0, L_termios

	STD_EPILOG
	ret

exit_raw_mode:
	STD_PROLOG

	get_terminal_attributes #0, L_termios

	// Clear echo and icanon flags
	LOAD_ADDRESS x0, L_termios
	mov x1, index_of_lflag
	mov x2, (echo_flag + icanon_flag)
	bl clear_bits_at

	set_terminal_attributes #0, L_termios

	STD_EPILOG
	ret

