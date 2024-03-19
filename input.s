#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"

.global inputInit
.global readWord
.global readLine
.global inputBuffer

.equ INPUT_BUFFER_SIZE, 250

.data
L_prompt:
	.asciz "10> "

.align 2
inputBuffer:
   .fill 250, 8, 0
   .byte 0

.text
.align 2

inputInit:
	LOAD_ADDRESS WORD_PTR, inputBuffer
	strb wzr, [WORD_PTR]
	ret


// readLine - print prompt and read next line
// Input: none
// Uses x0, x1, x2 - temp
// Output: x0 - number of characters read
//
readLine:
	// prompt
	LOAD_ADDRESS x0, L_prompt
	bl print

	// Read a new line
	mov x0, #0
	LOAD_ADDRESS x1, inputBuffer
	mov x2, INPUT_BUFFER_SIZE

	unix_read #0, L_input_buffer, INPUT_BUFFER_SIZE

	ret

// readWord - get next word, reading new lines if necessary
// Inputs:
//   READ_LINE_ROUTINE (register) - address of the routine to call to read a line
// Output:
//   x0 - ptr to start of returned word (0-terminated string)
//   WORD_PTR (register) - updated WORD_PTR
//
readWord:
	str lr, [sp, #-16]!

	// Check for WORD_PTR at \0
L_check_if_at_end:
	ldrb w0, [WORD_PTR]
	cmp w0, #0
	b.ne L_find_word_start
		blr READ_LINE_ROUTINE

		LOAD_ADDRESS WORD_PTR, inputBuffer

L_find_word_start:
		ldrb w0, [WORD_PTR]
		cmp w0, #0x20		// space (skip)
		b.ne not_a_space
			add WORD_PTR, WORD_PTR, #1
			b L_find_word_start
not_a_space:
		mov x0, WORD_PTR			// Set the return to point to this word

		ldrb w1, [WORD_PTR]
		cmp w1, 0x0a
		b.ne find_trailing_space_or_nl	// At end of line - go back & read more
		add WORD_PTR, WORD_PTR, #1
		b L_check_if_at_end

find_trailing_space_or_nl:
		ldrb w1, [WORD_PTR], #1
		cmp w1, 0x0a		// newline
		b.eq exit_space_or_nl
		cmp w1, 0x20		// space
		b.eq exit_space_or_nl
		b find_trailing_space_or_nl

exit_space_or_nl:
	strb wzr, [WORD_PTR, #-1]

	ldr lr, [sp], #16
	ret

