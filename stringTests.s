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
