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

	bl read_with_word_at_start
	bl read_with_word_starting_with_spaces
	bl read_read_multiple_words_separated_by_spaces

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

.data
.p2align 3
L_read_source:
	.quad 0

L_read_source1:
	.asciz "dup\n"
L_expect_source1:
	.asciz "dup"

L_read_source2:
	.asciz "  sub\n"
L_expect_source2:
	.asciz "sub"


L_read_source3:
	.asciz "1   dup  add\n"
L_expect_source3a:
	.asciz "1"
L_expect_source3b:
	.asciz "dup"
L_expect_source3c:
	.asciz "add"


.text
.align 2

// L_stub_readLine - simulate line read
// Input:
//   x0 = fd
//   x1 = input buffer
//   x2 = max char's to read
//
stub_readLine:
	str lr, [sp, #-16]!

	LOAD_ADDRESS x0, L_read_source
	ldr x0, [x0]
	bl strcpyz

	ldr lr, [sp], #16
	ret

TEST_START read_with_word_at_start
	bl inputInit

	LOAD_ADDRESS x0, L_read_source
	LOAD_ADDRESS x1, L_read_source1
	str x1, [x0]

	LOAD_ADDRESS x4, stub_readLine
	bl readWord

	LOAD_ADDRESS x1, L_expect_source1
	bl streq
	mov x1, #1
	bl assertEqual
TEST_END

TEST_START read_with_word_starting_with_spaces
	bl inputInit

	LOAD_ADDRESS x0, L_read_source
	LOAD_ADDRESS x1, L_read_source2
	str x1, [x0]

	LOAD_ADDRESS x4, stub_readLine
	bl readWord

	LOAD_ADDRESS x1, L_expect_source2
	bl assertEqualStrings
TEST_END

TEST_START read_read_multiple_words_separated_by_spaces
	bl inputInit

	LOAD_ADDRESS x0, L_read_source
	LOAD_ADDRESS x1, L_read_source3
	str x1, [x0]

	LOAD_ADDRESS x4, stub_readLine
	bl readWord

	LOAD_ADDRESS x1, L_expect_source3a
	bl assertEqualStrings


	LOAD_ADDRESS x4, stub_readLine
	bl readWord

	LOAD_ADDRESS x1, L_expect_source3b
	bl assertEqualStrings


	LOAD_ADDRESS x4, stub_readLine
	bl readWord

	LOAD_ADDRESS x1, L_expect_source3c
	bl assertEqualStrings
TEST_END


L_stringdiff1:
	.asciz "  x0=>"

L_stringdiff2:
	.asciz "\n  x1=>"

L_newline:
	.asciz "\n"

.align 2

// assertEqualString -
// Inputs:
//   x0 - actual string
//   x1 - expected string
assertEqualStrings:
	str lr, [sp, #-16]!

	str x0, [sp, #-16]!
	str x1, [sp, #8]

	bl streq
	mov x1, #1
	bl assertEqual

	cmp x0, #1
	b.eq exit_assertEqualString

	LOAD_ADDRESS x0, L_stringdiff1
	bl print

	ldr x0, [sp]			// saved x0
	bl print

	LOAD_ADDRESS x0, L_stringdiff2
	bl print

	ldr x0, [sp, #8]		// saved x1
	bl print

	LOAD_ADDRESS x0, L_newline
	bl print

exit_assertEqualString:
	ldr x1, [sp, #8]
	ldr x0, [sp], #16
	ldr lr, [sp], #16
	ret


