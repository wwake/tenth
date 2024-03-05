
.global tokenize
.global eval

.text

.align 2

// tokenize - split line into multiple strings
tokenize:
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
