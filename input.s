.include "assembler.macros"
.include "unix_functions.macros"

.global inputInit
.global readWord
.global readLine
.global tokenize

.equ INPUT_BUFFER_SIZE, 250

.data

inputBuffer:
.align 2
   .fill 250, 8, 0
   .byte 0

.text
.align 2

// tokenize - split line into multiple strings
//   x0 - points to a string with spaces in it
// Output:
//   The string has all spaces or newlines replaced with \0,
//   and adds an extra \0 at the end
tokenize:

L_tokenize_loop:
	ldrb w1, [x0]
	cmp w1, #0
	b.eq L_tokenize_exit

	cmp w1, #32		// compare to space
	b.ne L_replace_newline
		strb wzr, [x0]

L_replace_newline:
	cmp w1, #10		// compare to newline
	b.ne L_tokenize_move_to_next
		strb wzr, [x0]

L_tokenize_move_to_next:
	add x0, x0, #1	// skip forward 1 char.
	b L_tokenize_loop

L_tokenize_exit:	// put extra zero at end
	add x0, x0, 1
	strb wzr, [x0]
	ret


inputInit:
	LOAD_ADDRESS x22, inputBuffer
	strb wzr, [x22]
	ret

// readWord - input and then tokenize
// Inputs:
//   x4 - address of the routine to call to read a line
// Output:
//   x0 - ptr to start of returned word (0-terminated string)
//   x22 - updated
//
readWord:
	str lr, [sp, #-16]!

	// Check for x22 at \0
	ldrb w0, [x22]
	cmp w0, #0
	b.ne L_find_word_start
		// Read a new line
		mov x0, #0
		LOAD_ADDRESS x1, inputBuffer
		mov x2, INPUT_BUFFER_SIZE
		blr x4		// read line

		LOAD_ADDRESS x22, inputBuffer

L_find_word_start:
		ldrb w0, [x22]
		cmp w0, #0x20		// space (skip)
		b.ne not_a_space
			add x22, x22, #1
			b L_find_word_start
not_a_space:
		mov x0, x22

find_trailing_space_or_nl:
		ldrb w1, [x22], #1
		cmp w1, 0x0a		// newline
		b.eq exit_space_or_nl
		cmp w1, 0x20		// space
		b.eq exit_space_or_nl
		b find_trailing_space_or_nl

exit_space_or_nl:
	strb wzr, [x22, #-1]

	ldr lr, [sp], #16
	ret


readLine:
	unix_read #0, L_input_buffer, INPUT_BUFFER_SIZE
	ret
