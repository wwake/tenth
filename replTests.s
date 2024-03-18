#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "asUnit.macros"
.include "dictionary.macros"
.include "repl.macros"

.global _start

.text
.p2align 2

_start:
	str lr, [sp, #-16]!

	TEST_ALL "replTests"

	bl eval_of_just_push42_leaves_42_on_stack
	bl eval_calls_syntax_error_routine_for_unknown_word

	bl evalAll_calls_eval_in_run_mode
	bl evalAll_calls_compile_x23_in_compile_mode
	bl evalAll_calls_meta_even_in_compile_mode

	unix_exit
	ldr lr, [sp], #16
	ret


.data
.p2align 3

L_input_buffer:
	.asciz "push42"
	.fill 10

.p2align 3

L_eval_test_stack:
.fill 80

.text
.align 2

push42:
	mov x0, #42
	DATA_PUSH x0
ret

TEST_START eval_of_just_push42_leaves_42_on_stack
	// Arrange
	bl dict_init
	DICT_HEADER "push42", push42
	DICT_END

	LOAD_ADDRESS VSP, L_eval_test_stack

	LOAD_ADDRESS x0, L_input_buffer
	LOAD_ADDRESS x22, L_input_buffer

	// Act
	bl eval

	// Assert
	LOAD_ADDRESS x0, L_eval_test_stack
	ldr x0, [x0]
	mov x1, #42
	bl assertEqual

	mov x0, VSP
	LOAD_ADDRESS x1, L_eval_test_stack
	add x1, x1, #8
	bl assertEqual

TEST_END


.data
.p2align 3

L_input_three_words:
	.asciz "push42"
	.asciz "push42"
	.asciz "add"
	.asciz ""
	.fill 10

.data
.align 2
L_missing_word:
  .asciz "CAP"

L_captured:
  .ascii "?"

.text
.align 2

// Assumes x22 points to a string
captureError:
	LOAD_ADDRESS x0, L_captured
	ldrb w1, [x22]
	strb w1, [x0]
	ret

TEST_START eval_calls_syntax_error_routine_for_unknown_word
	// Arrange
	bl dict_init
	DICT_HEADER "_syntaxError", captureError
	DICT_END

	LOAD_ADDRESS x0, L_missing_word
	mov x22, x0

	// Act
	bl eval

	// Assert
	LOAD_ADDRESS x0, L_captured
	ldrb w0, [x0]
	mov x1, #67		// "C" of "CAP"
	bl assertEqual
TEST_END


L_eval_word:
	.asciz "1"


TEST_START evalAll_calls_eval_in_run_mode
	bl dict_init
	DICT_HEADER "1", push1
	DICT_END

	LOAD_ADDRESS VSP, L_eval_test_stack
	str xzr, [VSP]
	mov FLAGS, RUN_MODE
	LOAD_ADDRESS x0, L_eval_word
	
	bl evalAll

	ldr x0, [VSP, #-8]
	mov x1, #1
	bl assertEqual
TEST_END


.data
L_capture:
	.fill 10, 8, 0

.text
.align 2

// x0 = input word
L_test_compile:
	str lr, [sp, #-16]!

	LOAD_ADDRESS x1, L_capture
	bl strcpyz

	ldr lr, [sp], #16
	ret

TEST_START evalAll_calls_compile_x23_in_compile_mode
	LOAD_ADDRESS x23, L_test_compile
	LOAD_ADDRESS VSP, L_eval_test_stack
	str xzr, [VSP]
	mov FLAGS, COMPILE_MODE
	LOAD_ADDRESS x0, L_eval_word

	bl evalAll

	LOAD_ADDRESS x0, L_capture
	LOAD_ADDRESS x1, L_eval_word
	bl assertEqualStrings
TEST_END

L_semicolon:
	.asciz ";"

TEST_START evalAll_calls_meta_even_in_compile_mode
	bl dict_init
	DICT_HEADER ";", _semicolon, META
	DICT_END

	mov FLAGS, COMPILE_MODE
	LOAD_ADDRESS x0, L_semicolon

	bl evalAll

	mov x0, FLAGS
	mov x1, RUN_MODE
	bl assertEqual
TEST_END
