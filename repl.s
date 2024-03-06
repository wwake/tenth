.include "assembler.macros"
.include "unix_functions.macros"
.include "dictionary.macros"

.global tokenize
.global eval
.global repl

.equ INPUT_BUFFER_SIZE, 250
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

// eval - evaluate a line of input
// Inputs:
//   x0 - input, words separated by \0 bytes
//   x10 - points to current word
//
eval:
	str lr, [sp, #-16]!
	str x10, [sp, #8]

	mov x10, x0

	L_eval_while_nonempty:
		ldrb w0, [x0]
		cmp w0, #0
		b.eq L_end_eval

		mov x0, x10
		bl eval1

		mov x0, x10
		bl strlen

		add x10, x10, x0
		add x10, x10, #1
		mov x0, x10
	b L_eval_while_nonempty

	L_end_eval:
	ldr x10, [sp, #8]
	ldr lr, [sp], #16
ret


eval1:
	str lr, [sp, #-16]!

	bl dict_search
	ldr x0, [x0]
	blr x0

	ldr lr, [sp], #16
	ret

.data
L_prompt:
	.asciz "10> "

L_input_buffer:
	.align 2
	.fill 250, 8, 0
	.byte 0

L_data_top_prefix:
	.asciz ">>>> Top of stack: "
L_data_top_suffix:
	.asciz "\n"

.text
.align 2

// repl
//
repl:
	str lr, [sp, #-16]!
	str x10, [sp, #8]

	L_repl_loop:
	// prompt
		LOAD_ADDRESS x0, L_prompt
		bl print

	// read
	unix_read #0, L_input_buffer, INPUT_BUFFER_SIZE
	
	LOAD_ADDRESS x0, L_input_buffer
	bl tokenize

	// eval + print
	LOAD_ADDRESS x0, L_input_buffer
	bl eval

	LOAD_ADDRESS x0, L_data_top_prefix
	bl print

	DATA_TOP x0
	bl printnum

	LOAD_ADDRESS x0, L_data_top_suffix
	bl print

	// loop
	b L_repl_loop

	ldr x10, [sp, #8]
	ldr lr, [sp], #16

	ret
