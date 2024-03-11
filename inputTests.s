.include "assembler.macros"
.include "unix_functions.macros"
.include "asUnit.macros"
.include "dictionary.macros"


.global _start

.text
.p2align 2

_start:
	str lr, [sp, #-16]!

	TEST_ALL "inputTests"

	bl tokenize_does_nothing_with_empty_string
	bl tokenize_replaces_newline_with_0
	bl tokenize_replaces_spaces_and_appends_0

	unix_exit
	ldr lr, [sp], #16
	ret

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
L_nl_input: .asciz "x\ny\n\0"
L_expect_x: .asciz "x"
L_expect_y: .asciz "y"

.text
.align 2

TEST_START tokenize_replaces_newline_with_0
	// Arrange
	LOAD_ADDRESS x0, L_nl_input

	// Act
	bl tokenize

	// Assert
	LOAD_ADDRESS x0, L_nl_input
	LOAD_ADDRESS x1, L_expect_x
	bl streq
	mov x1, #1
	bl assertEqual

	LOAD_ADDRESS x0, L_nl_input
	add x0, x0, 2
	LOAD_ADDRESS x1, L_expect_y
	bl streq
	mov x1, #1
	bl assertEqual

	LOAD_ADDRESS x0, L_nl_input
	add x0, x0, #4
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

TEST_START read_with_word_at_start
	// define stub readLine
	// call readword
	// verify first word found

TEST_END

