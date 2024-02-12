.include "assembler.macros"
.include "unix_functions.macros"

.align 2

.global strlen
.global streq

.global print
.global printnum
.global dec2str

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
	str lr, [sp, #-16]!

	bl dec2str
	bl print

	ldr lr, [sp], #16
	ret


.data
L_dec2str_out:
.fill 32

.text
.p2align 2

// dec2str: return a pointer to a string containing the
//   string value of a number

//   WARNING: the returned string is only valid until the next call;
//   move the string elsewhere if you want to retain it.

// Input: x0 - value to convert
// Process:
//		x0 - pointer to result (working right to left)
// 		x1 - value remaining to convert
//		x2 - value / 10
// 		x3 - value % 10, converted to ASCII
//		x4 - constant 10
//		x5 - 1 if negative, 0 if >= 0
//
// Ouput: x0 - pointer to null-terminated string
//
dec2str:
	mov x4, #10			// X4 = 10

	mov x1, x0
	
	mov x5, #0
	cmp x1, #0
	b.pl L_no_sign
		mov x5, #1
		neg x1, x1

  L_no_sign:

	LOAD_ADDRESS x0, L_dec2str_out
	add x0, x0, #31
	strb wzr, [x0]

	L_dec2str_loop:
		sdiv x2, x1, x4		// x2 = x1 / 10
		mul x3, x2, x4		// x3 = x2 * 10
		sub x3, x1, x3		// x3 = x1 - x3   ie x1 mod 10
		add x3, x3, 0x30	// x3 = x3 + '0'
		sub x0, x0, #1
		strb w3, [x0]
		mov x1, x2
		cmp x1, #0
	b.ne L_dec2str_loop

	cmp x5, #1
	b.ne L_dec2str_end
		sub x0, x0, #1
		mov w3, #0x2d		// '-'
		strb w3, [x0]

L_dec2str_end:
	ret
