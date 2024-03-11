.include "assembler.macros"
.include "unix_functions.macros"
.include "asUnit.macros"
.include "dictionary.macros"


.global _start

.text
.p2align 2

_start:
	str lr, [sp, #-16]!

	TEST_ALL "replTests"

	bl eval_of_empty_string_just_stops
	bl eval_of_just_push42_leaves_42_on_stack
	bl eval_of_three_words_puts_84_on_stack

	bl eval_calls_syntax_error_routine_for_unknown_word

	unix_exit
	ldr lr, [sp], #16
	ret


.data
.p2align 3

L_empty_string:
	.ascii "\0"

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

TEST_START eval_of_empty_string_just_stops
	// Arrange
	bl dict_init

	LOAD_ADDRESS x19, L_eval_test_stack

	LOAD_ADDRESS x0, L_empty_string

	// Act
	bl eval

	// Assert
	mov x0, x19
	LOAD_ADDRESS x1, L_eval_test_stack
	bl assertEqual
TEST_END

TEST_START eval_of_just_push42_leaves_42_on_stack
	// Arrange
	bl dict_init
	DICT_HEADER "push42", push42

	LOAD_ADDRESS x19, L_eval_test_stack

	LOAD_ADDRESS x0, L_input_buffer
	LOAD_ADDRESS x22, L_input_buffer

	// Act
	bl eval

	// Assert
	LOAD_ADDRESS x0, L_eval_test_stack
	ldr x0, [x0]
	mov x1, #42
	bl assertEqual

	mov x0, x19
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

.text
.align 2
TEST_START eval_of_three_words_puts_84_on_stack
	// Arrange
	bl dict_init
	DICT_HEADER "push42", push42
	DICT_HEADER "add", add

	LOAD_ADDRESS x19, L_eval_test_stack

	LOAD_ADDRESS x0, L_input_three_words
	LOAD_ADDRESS x22, L_input_three_words

	// Act
	bl eval

	// Assert
	LOAD_ADDRESS x0, L_eval_test_stack
	ldr x0, [x0]
	mov x1, #84
	bl assertEqual

	mov x0, x19
	LOAD_ADDRESS x1, L_eval_test_stack
	add x1, x1, #8
	bl assertEqual

TEST_END


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

	LOAD_ADDRESS x0, L_missing_word
	mov x22, x0

	// Act
	bl eval1

	// Assert
	LOAD_ADDRESS x0, L_captured
	ldrb w0, [x0]
	mov x1, #67		// "C" of "CAP"
	bl assertEqual
TEST_END
