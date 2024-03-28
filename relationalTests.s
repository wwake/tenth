#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "asUnit.macros"

.global _start

_start:
	STD_PROLOG

	TEST_ALL "relationalTests"

	bl neq_true_if_values_different
	bl neq_false_if_values_same

	bl eq_true_if_values_same
	bl eq_false_if_values_differ

	unix_exit
	STD_EPILOG
	ret


.data
.p2align 3

L_push_test_stack: .quad 0, 99, 0, 0

L_data: .quad 142, 58

.text
.p2align 3


.macro TEST_RELATION name, relop, a, b, expected
TEST_START \name
	// Arrange:
	LOAD_ADDRESS VSP, L_push_test_stack
	
	mov x0, \a
	DATA_PUSH x0

	mov x0, \b
	DATA_PUSH x0

	// Act:
	bl \relop

	// Assert:
	DATA_POP x0
	mov x1, \expected
	bl assertEqual
TEST_END
.endm

TEST_RELATION neq_true_if_values_different, neq, 142, 58, 1
TEST_RELATION neq_false_if_values_same, neq, 142, 142, 0

TEST_RELATION eq_true_if_values_same, eq, 142, 142, 1
TEST_RELATION eq_false_if_values_differ, eq, 142, 143, 0
