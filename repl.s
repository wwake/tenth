#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "dictionary.macros"
.include "repl.macros"

.global eval
.global evalAll
.global repl
.global global_word_not_found_handler
.global wordNotFoundError
.global compile

// eval - evaluates one instruction
// Input:
//   x0 - word to execute
//   x22 - next word in input
// Uses:
//   x28 - temp
// Assumes - first dictionary entry is the syntax error routine (uses x22)
// Output:
//   side effect from execution
//
eval:
	STD_PROLOG
	str x28, [sp, #8]

	mov x28, x0

	bl dict_search
	cmp x0, #0
	b.eq L_check_for_numeric
		// Handle a known word
		ldr x28, [sp, #8]
		ldr x1, [x0]			// load ptr to code
		blr x1					// call code
	b L_eval_exiting

L_check_for_numeric:
	mov x0, x28
	bl str2positive
	cmp x0, #0
	b.eq L_word_not_found
		// Push the number on the data stack
		DATA_PUSH x0
	b L_eval_exiting

L_word_not_found:
	WORD_NOT_FOUND x28

L_eval_exiting:
	str x28, [sp, #8]
	STD_EPILOG
	ret


.text
.align 2
// evalAll: evaluate or compile
// Input: x0 - current word
// Uses: x28 - temp pointing to the current word
//
evalAll:
	STD_PROLOG
	str x28, [sp, #8]

	mov x28, x0

	and x1, FLAGS, COMPILE_MODE
	cmp x1, COMPILE_MODE
	b.ne L_evaluate

	bl isMeta
	cmp x0, #1
	b.eq L_evaluate
		mov x0, x28
		bl compile
		b L_end_evalAll

	L_evaluate:
		mov x0, x28
		bl eval

L_end_evalAll:
	ldr x28, [sp, #8]
	STD_EPILOG
	ret


.text
.align 2

// compile - put word address for a name into the currently-building secondary
// Input: x0 = pointer to string name
// Uses: x0 = temp
// Output:
//   If word is found, it's added to current secondary
//   Else: print an error message
// 
compile:
	STD_PROLOG
	str x29, [sp, #8]

	mov x29, x0

	bl dict_search
	cmp x0, #0
	b.eq L_compile_check_for_number
		// word was found, store in secondary
		str x0, [SEC_SPACE], #8
		b L_exiting_compile

L_compile_check_for_number:
	mov x0, x29
	bl str2positive
	cmp x0, #0
	b.eq L_compile_word_not_found
		// Write push_word_address and number to the secondary
		LOAD_ADDRESS x1, _push_word_address
		str x1, [SEC_SPACE], #8		// push_word_address
		str x0, [SEC_SPACE], #8		// number
		b L_exiting_compile

L_compile_word_not_found:
	WORD_NOT_FOUND x29

L_exiting_compile:
	ldr x29, [sp, #8]
	STD_EPILOG
	ret

.text
.align 2

// repl
//
repl:
	STD_PROLOG
	str x22, [sp, #8]

	bl inputInit

	LOAD_ADDRESS READ_LINE_ROUTINE, readLine
	mov FLAGS, RUN_MODE

L_repl_loop:
	// read
	bl readWord

	// eval
	bl evalAll

	// no print - use "." if you want it

	// loop
	b L_repl_loop

	ldr x22, [sp, #8]
	STD_EPILOG

	ret

.data
.p2align 3
wordNotFoundMessage:
	.asciz "Word not found: "

wordNotFoundSuffix:
	.asciz "\n"

.p2align 3
global_word_not_found_handler:
	.quad wordNotFoundError

L_enter_red_mode:
	.asciz "\033[31m"

L_exit_red_mode:
	.asciz "\033[0m"

.text
.align 2
// wordNotFoundError - prints error message and word that wasn't found
// Input: x0 = points to the not-found word
// Output:
//   Prints error message
//
wordNotFoundError:
	STD_PROLOG
	str x29, [sp, #8]

	mov x29, x0

	LOAD_ADDRESS x0, L_enter_red_mode
	bl print

	LOAD_ADDRESS x0, wordNotFoundMessage
	bl print

	mov x0, x29
	bl print

	LOAD_ADDRESS x0, L_exit_red_mode
	bl print

	LOAD_ADDRESS x0, wordNotFoundSuffix
	bl print

	ldr x29, [sp, #8]
	STD_EPILOG
	ret
