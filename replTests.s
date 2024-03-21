#include "core.defines"
#include "assembler.macros"
#include "dictionary.macros"

.include "unix_functions.macros"
.include "asUnit.macros"
.include "repl.macros"

.global _start

.text
.p2align 2

_start:
	STD_PROLOG

	TEST_ALL "replTests"

	bl eval_of_just_push42_leaves_42_on_stack
	bl eval_calls_syntax_error_routine_for_unknown_word

	bl evalAll_calls_eval_in_run_mode
	bl evalAll_calls_compiler_in_compile_mode
	bl evalAll_calls_meta_even_in_compile_mode

	bl compile_puts_found_word_into_sec_space
	bl compile_writes_error_message_if_not_found

	unix_exit
	STD_EPILOG
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
	LOAD_ADDRESS NEXT_WORD, L_input_buffer

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

.text
.align 2

TEST_START eval_calls_syntax_error_routine_for_unknown_word
	// Arrange
	LOAD_ADDRESS x0, global_word_not_found_handler
	LOAD_ADDRESS x1, L_local_error_handler
	str x1, [x0]

	LOAD_ADDRESS x0, L_missing_word
	mov NEXT_WORD, x0

	// Act
	bl eval

	// Assert
	LOAD_ADDRESS x0, L_capture_error_message
	LOAD_ADDRESS x1, L_missing_word
	bl assertEqualStrings
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
	STD_PROLOG

	LOAD_ADDRESS x1, L_capture
	bl strcpyz

	STD_EPILOG
	ret

TEST_START evalAll_calls_compiler_in_compile_mode
	// Arrange:
	LOAD_ADDRESS VSP, L_eval_test_stack
	str xzr, [VSP]
	mov FLAGS, COMPILE_MODE

	LOAD_ADDRESS SEC_SPACE, L_compile_test_space

	bl dict_init
	DICT_HEADER "1", push1
	DICT_END

	LOAD_ADDRESS x0, L_compile_word_to_find

	// Act:
	bl evalAll

	// Assert
	LOAD_ADDRESS x0, L_compile_word_to_find
	bl dict_search
	mov x1, x0

	LOAD_ADDRESS x0, L_compile_test_space
	ldr x0, [x0]
	bl assertEqual
TEST_END

L_semicolon:
	.asciz ";"

.data
.p2align 3
L_evalAll_test_space:
	.quad 0
	.quad 0

.text
.align 2

TEST_START evalAll_calls_meta_even_in_compile_mode
	LOAD_ADDRESS SEC_SPACE, L_evalAll_test_space

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


.data
.p2align 3

L_compile_test_space:
	.fill 10, 8, 0

L_compile_word_to_find:
	.asciz "1"

.p2align 3

.text
.align 2
TEST_START compile_puts_found_word_into_sec_space
	// Arrange:
	LOAD_ADDRESS SEC_SPACE, L_compile_test_space

	bl dict_init
	DICT_HEADER "1", push1
	DICT_END

	LOAD_ADDRESS x0, L_compile_word_to_find

	// Act:
	bl compile

	// Assert
	LOAD_ADDRESS x0, L_compile_word_to_find
	bl dict_search
	mov x1, x0

	LOAD_ADDRESS x0, L_compile_test_space
	ldr x0, [x0]
	bl assertEqual
TEST_END

// x0 = word not found
L_local_error_handler:
	STD_PROLOG

	LOAD_ADDRESS x1, L_capture_error_message
	bl strcpyz

	STD_EPILOG
	ret

TEST_START compile_writes_error_message_if_not_found
	// Arrange:
	LOAD_ADDRESS x0, global_word_not_found_handler
	LOAD_ADDRESS x1, L_local_error_handler
	str x1, [x0]

	LOAD_ADDRESS x0, L_compile_word_to_not_find

	// Act:
	bl compile

	// Assert:
	LOAD_ADDRESS x0, L_capture_error_message
	LOAD_ADDRESS x1, L_compile_word_to_not_find
	bl assertEqualStrings
TEST_END


.data
.p2align 3
L_compile_word_to_not_find:
	.asciz "NOT_A_REAL_WORD"

.p2align 3
L_capture_error_message:
	.fill 20, 8, 0
