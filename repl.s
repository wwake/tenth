.include "assembler.macros"
.include "unix_functions.macros"
.include "dictionary.macros"

.global eval
.global evalAll
.global repl
.global wordNotFoundError

.equ RUN_MODE, 0
.equ COMPILE_MODE, 1

// eval - evaluates one instruction
// Input:
//   x0 - word to execute
//   x22 - next word in input
// Assumes - first dictionary entry is the syntax error routine (uses x22)
// Output:
//   side effect from execution
//
eval:
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

L_data_top_prefix:
	.asciz ">>>> Top of stack: "
L_data_top_suffix:
	.asciz "\n"


.text
.align 2
evalAll:
	str lr, [sp, #-16]!

	bl eval

	ldr lr, [sp], #16
	ret

.text
.align 2

// repl
//
repl:
	str lr, [sp, #-16]!
	str x22, [sp, #8]

	bl inputInit

L_repl_loop:
	// read
	LOAD_ADDRESS x4, readLine
	bl readWord

	// eval
	bl evalAll

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
