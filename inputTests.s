#include "core.defines"
#include "assembler.macros"
.include "unix_functions.macros"
.include "asUnit.macros"
.include "dictionary.macros"


.global _start

.text
.p2align 2

_start:
	str lr, [sp, #-16]!

	TEST_ALL "inputTests"

	bl read_with_word_at_start
	bl read_with_word_starting_with_spaces
	bl read_read_multiple_words_separated_by_spaces

	bl read_from_newline_only_line_causes_readLine

	unix_exit
	ldr lr, [sp], #16
	ret

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


L_read_source4a:
	.asciz "\n"

L_read_source4b:
	.asciz "mul\n"

L_expect_source4:
	.asciz "mul"


L_read_multiline_empty:
	.asciz "\n"

L_read_multiline_nonempty:
	.asciz "1\n"

L_expect_read_multiline_1:
	.asciz "1"

.data
.p2align 3

L_read_index:
	.quad 0

L_read_source:
	.quad 0, 0, 0, 0, 0

.text
.align 2

// READ_STUB_INIT - resets stub array index, leaves x0 pointing to L_read_source array
// Output: x0 points to array
//
.macro READ_STUB_INIT
	LOAD_ADDRESS x0, L_read_index
	str xzr, [x0], #8
.endm

.macro READ_STUB_ADD label
	LOAD_ADDRESS x1, \label
	str x1, [x0], #8
.endm

.macro READ_STUB_READY
	str xzr, [x0]
.endm

// stub_readLine - simulate line read
// Input: None
// Output:
//   Next line written to global inputBuffer
//   x0 = # char's "read"
//
stub_readLine:
	str lr, [sp, #-16]!

	// Get the read index
	LOAD_ADDRESS x9, L_read_index
	ldr x9, [x9]

	// Copy the current string 
	LOAD_ADDRESS x0, L_read_source
	ldr x0, [x0, x9, LSL #3]
	LOAD_ADDRESS x1, inputBuffer
	bl strcpyz

	// Set string length as return value
	bl strlen

	// Move to next string in the input array
	LOAD_ADDRESS x9, L_read_index
	ldr x10, [x9]
	add x10, x10, #1
	str x10, [x9]

	ldr lr, [sp], #16
	ret

TEST_START read_with_word_at_start
	bl inputInit

	READ_STUB_INIT
	READ_STUB_ADD L_read_source1
	READ_STUB_READY

	LOAD_ADDRESS READ_LINE_ROUTINE, stub_readLine
	bl readWord

	LOAD_ADDRESS x1, L_expect_source1
	bl assertEqualStrings
TEST_END

TEST_START read_with_word_starting_with_spaces
	bl inputInit

	READ_STUB_INIT
	READ_STUB_ADD L_read_source2
	READ_STUB_READY

	LOAD_ADDRESS READ_LINE_ROUTINE, stub_readLine
	bl readWord

	LOAD_ADDRESS x1, L_expect_source2
	bl assertEqualStrings
TEST_END

TEST_START read_read_multiple_words_separated_by_spaces
	bl inputInit

	READ_STUB_INIT
	READ_STUB_ADD L_read_source3
	READ_STUB_READY

	LOAD_ADDRESS READ_LINE_ROUTINE, stub_readLine
	bl readWord

	LOAD_ADDRESS x1, L_expect_source3a
	bl assertEqualStrings


	LOAD_ADDRESS READ_LINE_ROUTINE, stub_readLine
	bl readWord

	LOAD_ADDRESS x1, L_expect_source3b
	bl assertEqualStrings


	LOAD_ADDRESS READ_LINE_ROUTINE, stub_readLine
	bl readWord

	LOAD_ADDRESS x1, L_expect_source3c
	bl assertEqualStrings
TEST_END


TEST_START read_from_newline_only_line_causes_readLine
	READ_STUB_INIT
	READ_STUB_ADD L_read_multiline_empty
	READ_STUB_ADD L_read_multiline_nonempty
	READ_STUB_READY

	LOAD_ADDRESS READ_LINE_ROUTINE, stub_readLine
	bl readWord

	LOAD_ADDRESS x1, L_expect_read_multiline_1
	bl assertEqualStrings
TEST_END
