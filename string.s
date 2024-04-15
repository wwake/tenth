#include "core.defines"
#include "assembler.macros"

.global make_string
.global head_string

.text
.align 2

// make_string: convert array to string
// Input:
//   a - top of stack has address of array
// Output:
//   a - top of stack replaced with address of string
//
make_string:
	DATA_POP x0

	DATA_PUSH SEC_SPACE

L_make_loop:
	ldr x1, [x0], #8
	cmp x1, #0
	b.eq L_make_exiting
		strb w1, [SEC_SPACE], #1
	b L_make_loop

L_make_exiting:
	strb wzr, [SEC_SPACE], #1
	ROUND_UP_8 SEC_SPACE

	ret


// head_string - pop address of string, push address of string with first character removed, and push that character (as an integer)
//
head_string:
	DATA_POP x0
	ldrb w1, [x0], #1
	
	cmp w1, #0
	b.ne L_end_head_string
		sub x0, x0, #1

L_end_head_string:
	DATA_PUSH x0
	DATA_PUSH x1
	ret
