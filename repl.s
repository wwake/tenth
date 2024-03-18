#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "dictionary.macros"
.include "repl.macros"

.global eval
.global evalAll
.global repl
.global wordNotFoundError

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
// evalAll: evaluate or compile
// Input: x0 - next word
//
evalAll:
	str lr, [sp, #-16]!
	str x28, [sp, #8]

	mov x28, x0

	and x1, FLAGS, COMPILE_MODE
	cmp x1, COMPILE_MODE
	b.ne L_evaluate

	bl isMeta
	cmp x0, #1
	b.eq L_evaluate
		mov x0, x28
		blr COMPILER_ROUTINE
		b L_end_evalAll

	L_evaluate:
		mov x0, x28
		bl eval

L_end_evalAll:
	ldr x28, [sp, #8]
	ldr lr, [sp], #16
	ret


.text
.align 2

compile:
	ret

.text
.align 2

// repl
//
repl:
	str lr, [sp, #-16]!
	str x22, [sp, #8]
	LOAD_ADDRESS COMPILER_ROUTINE, compile
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
// Input: x22 = WORD_PTR - points to string, the not-found word
// Output:
//   Prints error message
//
wordNotFoundError:
	str lr, [sp, #-16]!

	LOAD_ADDRESS x0, wordNotFoundMessage
	bl print

	mov x0, WORD_PTR
	bl print

	LOAD_ADDRESS x0, wordNotFoundSuffix
	bl print

	ldr lr, [sp], #16
	ret
