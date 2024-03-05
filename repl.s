
.global tokenize
.global eval

.text

.align 2

// tokenize - split line into multiple strings
// x0 - points to a string with spaces in it
// Output:
//   The string has all spaces replaced with \0,
//   and adds an extra \0 at the end
tokenize:

L_tokenize_loop:
	ldrb w1, [x0]
	cmp w1, #0
	b.eq L_tokenize_exit

	cmp w1, #32	// compare to space
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
		bl dict_search
		ldr x0, [x0]
		blr x0

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
