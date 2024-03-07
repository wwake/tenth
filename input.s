.include "assembler.macros"
.include "unix_functions.macros"

.global readWord
.global tokenize

.equ INPUT_BUFFER_SIZE, 250

.data

L_input_buffer:
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
	add x0, x0, #1
	b L_tokenize_loop

L_tokenize_exit:	// put extra zero after last word
	add x0, x0, 1
	strb wzr, [x0]
	ret


// readWord - input and then tokenize
readWord:
	str lr, [sp, #-16]!

	unix_read #0, L_input_buffer, INPUT_BUFFER_SIZE

	LOAD_ADDRESS x0, L_input_buffer
	bl tokenize

	LOAD_ADDRESS x0, L_input_buffer

	ldr lr, [sp], #16
	ret

