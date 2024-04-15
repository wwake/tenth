#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"

.include "asUnit.macros"
.include "repl.macros"

.global _start

.text
.p2align 2

_start:
	STD_PROLOG

	TEST_ALL "stringTests"

	bl eval_pushes_string_address_on_data_stack
	bl make_creates_string_from_array

	bl head_empty_string_pushes_ptr_to_empty_string_and_0
	bl head_splits_first_character_from_string

	unix_exit
	STD_EPILOG
	ret



.data
.p2align 3

L_string:
	.asciz "a string "

.text
.align 2

TEST_START eval_pushes_string_address_on_data_stack
	// Arrange:
	bl sec_space_init
	bl dict_init
	bl data_stack_init

	LOAD_ADDRESS x0, L_string
	mov x1, STRING_FOUND

	// Act:
	bl eval

	// Assert:
	DATA_POP x0
	LOAD_ADDRESS x1, L_string
	bl assertEqualStrings
TEST_END


.data
.p2align 3

L_make_array:
	.quad 65
	.quad 66
	.quad 67
	.quad 0

L_make_expected:
	.asciz "ABC"

.text
.align 2

TEST_START make_creates_string_from_array
	// Arrange:
	bl sec_space_init
	bl dict_init
	bl data_stack_init

	// Push array address on stack
	LOAD_ADDRESS x0, L_make_array
	DATA_PUSH x0

	// Act:
	bl make_string

	// Assert:
	DATA_POP x0
	LOAD_ADDRESS x1, L_make_expected
	bl assertEqualStrings
TEST_END


L_empty_string:
	.asciz ""

.align 2

TEST_START head_empty_string_pushes_ptr_to_empty_string_and_0
	// Arrange
	bl data_stack_init

	LOAD_ADDRESS x0, L_empty_string
	DATA_PUSH x0

	// Act
	bl head_string

	// Assert
	DATA_POP x0
	mov x1, #0   // 0 byte to terminate string
	bl assertEqual

	DATA_POP x0
	LOAD_ADDRESS x1, L_empty_string
	bl assertEqualStrings
TEST_END


L_head_string:
	.asciz "CAB"

L_head_expected:
	.asciz "AB"

.align 2

TEST_START head_splits_first_character_from_string
	// Arrange
	bl data_stack_init

	LOAD_ADDRESS x0, L_head_string
	DATA_PUSH x0

	// Act
	bl head_string

	// Assert
	DATA_POP x0
	mov x1, #67   // letter C
	bl assertEqual

	DATA_POP x0
	LOAD_ADDRESS x1, L_head_expected
	bl assertEqualStrings
TEST_END
