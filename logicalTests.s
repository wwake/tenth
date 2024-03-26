#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "asUnit.macros"
.include "coreTests.macros"

.global _start

.data
.p2align 3

L_test_data_stack: .quad 0, 99, 0, 0

.text
.p2align 3
L_data: .quad 142, 58, -7


.align 2

_start:
	STD_PROLOG

	TEST_ALL "logicalTests"

	bl and_puts_a_logical_and_b_on_stack
	bl or_puts_a_logical_or_b_on_stack

	unix_exit
	STD_EPILOG
	ret


.macro BINOP_TEST test_name, routine_to_test, expected
TEST_START \test_name
	// Arrange:
	LOAD_ADDRESS VSP, L_test_data_stack
	adr VPC, L_data
	bl _push

	adr VPC, L_data + 8
	bl _push

	// Act:
	bl \routine_to_test

	// Assert:
	DATA_POP x0
	mov x1, \expected
	bl assertEqual
TEST_END
.endm

.macro UNARY_OP_TEST test_name, data_offset, routine_to_test, expected
TEST_START \test_name
	// Arrange:
	LOAD_ADDRESS VSP, L_test_data_stack
	adr VPC, L_data + \data_offset
	bl _push

	// Act:
	bl \routine_to_test

	// Assert:
	DATA_POP x0
	mov x1, \expected
	bl assertEqual
TEST_END
.endm


BINOP_TEST and_puts_a_logical_and_b_on_stack, andRoutine, 10

BINOP_TEST or_puts_a_logical_or_b_on_stack, orRoutine, 190
