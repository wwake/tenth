#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"

.include "asUnit.macros"

.global _start

.text
.p2align 2

_start:
	STD_PROLOG

	TEST_ALL "stringTests"

	//bl eval_pushes_string_address_on_data_stack

	unix_exit
	STD_EPILOG
	ret



.data
.p2align 3
L_string:
	.asciz "\"a string \""

L_string_expected:
	.asciz "a string "

.text
.align 2

TEST_START eval_pushes_string_address_on_data_stack
	// Arrange:
	bl data_stack_init

	LOAD_ADDRESS x0, L_string

	// Act:
	bl eval

	// Assert:
	DATA_POP x0
	LOAD_ADDRESS x1, L_string_expected
	bl assertEqualStrings
TEST_END
