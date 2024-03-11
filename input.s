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
	add x0, x0, #1	// skip forward 1 char.
	b L_tokenize_loop

L_tokenize_exit:	// put extra zero at end
	add x0, x0, 1
	strb wzr, [x0]
	ret


input_init:
	LOAD_ADDRESS x22, L_input_buffer


// readWord - input and then tokenize
readWord:
	str lr, [sp, #-16]!

//	ldr x0, [x22]
	mov x0, #0
	cmp x0, #0
	b.ne L_skip_read
		unix_read #0, L_input_buffer, INPUT_BUFFER_SIZE

		LOAD_ADDRESS x0, L_input_buffer
		bl tokenize

		LOAD_ADDRESS x22, L_input_buffer
		mov x0, x22

L_skip_read:
	ldr lr, [sp], #16
	ret

