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
	bl eval_pushes_number_on_data_stack

	bl evalAll_calls_eval_in_run_mode
	bl evalAll_calls_compiler_in_compile_mode
	bl evalAll_calls_meta_even_in_compile_mode

	bl compile_puts_found_word_into_sec_space
	bl compile_emits_push_when_number_found
	bl compile_writes_error_message_if_not_found

	bl compile_string_puts_it_after_jumps_with_padding

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
	LOAD_ADDRESS x1, test_error_handler
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

.data
.p2align 3
L_push_test_stack:
	.quad 0, 99, 0, 0

L_numeric_string:
	.asciz "321"

.text
.align 2

TEST_START eval_pushes_number_on_data_stack
	// Arrange:
	bl dict_init

	LOAD_ADDRESS VSP, L_push_test_stack

	LOAD_ADDRESS x0, L_numeric_string

	// Act:
	bl eval

	// Assert:
	LOAD_ADDRESS x0, L_push_test_stack
	ldr x0, [x0]
	mov x1, #321
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
	DICT_HEADER ";", semicolon, META
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

L_compile_number_to_find:
	.asciz "42"

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

TEST_START compile_emits_push_when_number_found
	// Arrange:
	LOAD_ADDRESS SEC_SPACE, L_compile_test_space
	LOAD_ADDRESS x0, L_compile_number_to_find

	// Act:
	bl compile

	// Assert:
	LOAD_ADDRESS x0, L_compile_test_space
	ldr x0, [x0]
	LOAD_ADDRESS x1, push_word_address
	bl assertEqual

	LOAD_ADDRESS x0, L_compile_test_space
	add x0, x0, #8
	ldr x0, [x0]
	mov x1, #42
	bl assertEqual
TEST_END

// x0 = word not found
test_error_handler:
	STD_PROLOG

	LOAD_ADDRESS x1, L_capture_error_message
	bl strcpyz

	STD_EPILOG
	ret

TEST_START compile_writes_error_message_if_not_found
	// Arrange:
	LOAD_ADDRESS x0, global_word_not_found_handler
	LOAD_ADDRESS x1, test_error_handler
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


.p2align 3
L_string_to_compile:
	.asciz "wee"


.text
.align 2

TEST_START compile_string_puts_it_after_jumps_with_padding
	str x28, [sp, #8]		// x28 - Points to initial SEC_SPACE

	// Arrange:
	bl init_control_stack

	bl sec_space_init
	mov x28, SEC_SPACE

	LOAD_ADDRESS x0, L_string_to_compile
	mov x1, STRING_FOUND

	// Act:
	bl compile

	// Assert:
	// Check for push
	mov x0, x28
	ldr x0, [x0]
	LOAD_ADDRESS x1, push_word_address
	bl assertEqual

	// Check that push gets the string's address
	mov x0, x28
	add x0, x0, #8
	ldr x0, [x0]
	add x1, x28, #32
	bl assertEqual

	// Check for jump
	mov x0, x28
	add x0, x0, #16
	ldr x0, [x0]
	LOAD_ADDRESS x1, jump_word_address
	bl assertEqual

	// Check target of jump goes after string (rounded to 8 bytes)
	mov x0, x28
	add x0, x0, #24
	ldr x0, [x0]
	add x1, x28, #40
	bl assertEqual

	// Check that string is put in secondary
	mov x0, x28
	add x0, x0, #32
	LOAD_ADDRESS x1, L_string_to_compile
	bl assertEqualStrings

	ldr x28, [sp, #8]
TEST_END
