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
//   x10 - points to current word
//
eval:
	str lr, [sp, #-16]!

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
	ldr lr, [sp], #16
ret

// eval1 - evaluates one instruction
// Input:
//   x0 - word to execute
//   x10 - current word from input
// Assumes - first dictionary entry is the syntax error routine (uses x10)
// Output:
//   side effect from execution
//
eval1:
	str lr, [sp, #-16]!

	bl dict_search
	cmp x0, #0
	b.ne L_call_found_routine
		LOAD_ADDRESS x0, systemDictionary
		add x0, x0, #40		// skip all-0 header, get first word address

L_call_found_routine:
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

	ldr x10, [sp, #8]
	ldr lr, [sp], #16

	ret


wordNotFoundMessage:
	.asciz "Word not found: "

wordNotFoundSuffix:
	.asciz "\n"

.align 2
// wordNotFoundError - prints error message and word that wasn't found
// Input: x10 - points to string, the not-found word
// Output:
//   Prints error message
//
wordNotFoundError:
	str lr, [sp, #-16]!

	LOAD_ADDRESS x0, wordNotFoundMessage
	bl print

	mov x0, x10
	bl print

	LOAD_ADDRESS x0, wordNotFoundSuffix
	bl print

	ldr lr, [sp], #16
	ret
