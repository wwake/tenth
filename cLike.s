.include "unix_functions.macros"

.align 2

.global strlen
.global streq

.global print
.global printnum

// strlen
// input: x0 is address of a 0-terminated string
// process: x1 is address of current character
//          w2 is value of current character
// output: x0 is length of string
//
strlen:
	mov x1, x0
	mov x0, #0

loop:
	ldrb w2, [x1], #1
	cmp w2, #0
	b.eq l_return
	add x0, x0, #1
	b loop

l_return:
	ret

// streq: compare strings
// Input: x0 points to first null-terminate string
// 			x1 points to second string
// Output: x0 is 1 if equal, 0 otherwise
//
streq:
	loop_streq:
		ldrb w2, [x0], #1
		ldrb w3, [x1], #1

		cmp w2, w3
		b.ne loop_exit_streq

		cmp w2, #0
		b.ne loop_streq

	loop_exit_streq:
		mov x0, #1
		cmp w2, w3
		b.eq l_exit_streq

		mov x0, #0

l_exit_streq:
	ret


// print
// input: x0 is address of a 0-terminated string
// process:
//   x28 - holds address while strlen called
//   x0 - holds port # for stdout
//   x1 - holds address of string to write
//   x2 - holds length of string
//   x16 - holds service #
// output: none
//
print:
	str lr, [sp, #-16]!
	str x28, [sp, #8]

	mov x28, x0

	bl strlen

	mov x2, x0
	mov x1, x28
	mov x0, #1       // stdout
	mov x16, #4      // write
	svc 0

	ldr x28, [sp, #8]
	ldr lr, [sp], #16
	ret


// printnum: prints a number in x0 as decimal
// Input: x0
// Output: none
printnum:

	ret


dec2str:
	ret
