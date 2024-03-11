.include "assembler.macros"
.include "unix_functions.macros"
.include "dictionary.macros"

.global eval
.global eval1
.global repl
.global wordNotFoundError

// eval - evaluate a line of input
// Inputs:
//   x0 - input, words separated by \0 bytes
//   x22 - points to current word
//
eval:
	str lr, [sp, #-16]!

	L_eval_while_nonempty:
		ldrb w0, [x0]
		cmp w0, #0
		b.eq L_end_eval

		mov x0, x22
		bl eval1

		mov x0, x22
		bl strlen

		add x22, x22, x0
		add x22, x22, #1
		mov x0, x22
	b L_eval_while_nonempty

L_end_eval:
	ldr lr, [sp], #16
ret

// eval1 - evaluates one instruction
// Input:
//   x0 - word to execute
//   x22 - current word from input
// Assumes - first dictionary entry is the syntax error routine (uses x22)
// Output:
//   side effect from execution
//
eval1:
	str lr, [sp, #-16]!

	bl dict_search
	cmp x0, #0		// Call
	b.ne L_call_found_routine
		LOAD_ADDRESS x0, systemDictionary
		add x0, x0, #40		// x0 <- ptr to error-handling

L_call_found_routine:
	ldr x0, [x0]			// load ptr to code
	blr x0					// call code

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
	str x22, [sp, #8]

	bl inputInit

L_repl_loop:
	// prompt
		LOAD_ADDRESS x0, L_prompt
		bl print

	// read
	LOAD_ADDRESS x4, readLine
	bl readWord

	// eval
	bl eval1

	// print
	LOAD_ADDRESS x0, L_data_top_prefix
	bl print

	DATA_TOP x0
	bl printnum

	LOAD_ADDRESS x0, L_data_top_suffix
	bl print

	// loop
	b L_repl_loop

	ldr x22, [sp, #8]
	ldr lr, [sp], #16

	ret


wordNotFoundMessage:
	.asciz "Word not found: "

wordNotFoundSuffix:
	.asciz "\n"

.align 2
// wordNotFoundError - prints error message and word that wasn't found
// Input: x22 - points to string, the not-found word
// Output:
//   Prints error message
//
wordNotFoundError:
	str lr, [sp, #-16]!

	LOAD_ADDRESS x0, wordNotFoundMessage
	bl print

	mov x0, x22
	bl print

	LOAD_ADDRESS x0, wordNotFoundSuffix
	bl print

	ldr lr, [sp], #16
	ret
