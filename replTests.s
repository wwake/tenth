.include "assembler.macros"
.include "unix_functions.macros"
.include "asUnit.macros"
.include "dictionary.macros"


.text
.p2align 2

.global _start

.text
.p2align 2

_start:
	str lr, [sp, #-16]!

	TEST_ALL "replTests"

	bl tokenize_does_nothing_with_empty_string
	bl tokenize_replaces_spaces_and_appends_0

	bl eval_of_empty_string_just_stops
	bl eval_of_just_push42_leaves_42_on_stack
	bl eval_of_three_words_puts_84_on_stack

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
L_empty_input: .ascii "\0A"

.text
.align 2

TEST_START tokenize_does_nothing_with_empty_string
	// Arrange
	LOAD_ADDRESS x0, L_empty_input

	// Act
	bl tokenize

	// Assert
	LOAD_ADDRESS x0, L_empty_input
	ldrb w0, [x0]
	mov x1, #0
	bl assertEqual

	LOAD_ADDRESS x0, L_empty_input
	add x0, x0, #1
	ldrb w0, [x0]
	mov x1, #0
	bl assertEqual
TEST_END

.data
L_nonempty_input: .ascii "a b cc\0ABC\0"

L_expect_a: .asciz "a"
L_expect_b: .asciz "b"
L_expect_cc: .asciz "cc"
L_expect_empty: .asciz ""
.text
.align 2


TEST_START tokenize_replaces_spaces_and_appends_0
	// Arrange
	LOAD_ADDRESS x0, L_nonempty_input

	// Act
	bl tokenize

	// Assert
	LOAD_ADDRESS x0, L_nonempty_input
	LOAD_ADDRESS x1, L_expect_a
	bl streq
	mov x1, #1
	bl assertEqual

	LOAD_ADDRESS x0, L_nonempty_input
	add x0, x0, #2
	LOAD_ADDRESS x1, L_expect_b
	bl streq
	mov x1, #1
	bl assertEqual

	LOAD_ADDRESS x0, L_nonempty_input
	add x0, x0, #4
	LOAD_ADDRESS x1, L_expect_cc
	bl streq
	mov x1, #1
	bl assertEqual

	LOAD_ADDRESS x0, L_nonempty_input
	add x0, x0, #7
	bl strlen
	mov x1, #0
	bl assertEqual
TEST_END



