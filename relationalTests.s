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

	bl lt_true_if_value_less
	bl lt_false_if_values_equal
	bl lt_false_if_value_greater

	bl le_true_if_value_less
	bl le_true_if_values_equal
	bl le_false_if_value_greater

	bl gt_false_if_value_less
	bl gt_false_if_values_equal
	bl gt_true_if_value_greater

	bl ge_false_if_value_less
	bl ge_true_if_values_equal
	bl ge_true_if_value_greater

	bl lt0_when_value_negative
	bl lt0_when_value_zero
	bl lt0_when_value_positive

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

.macro TEST_UNARY_RELATION name, relop, a, expected
	TEST_RELATION \name, \relop, 99, \a, \expected
.endm

TEST_RELATION neq_true_if_values_different, neq, 142, 58, 1
TEST_RELATION neq_false_if_values_same, neq, 142, 142, 0

TEST_RELATION eq_true_if_values_same, eq, 142, 142, 1
TEST_RELATION eq_false_if_values_differ, eq, 142, 143, 0

TEST_RELATION lt_true_if_value_less, lt, 142, 143, 1
TEST_RELATION lt_false_if_values_equal, lt, 142, 142, 0
TEST_RELATION lt_false_if_value_greater, lt, 143, 142, 0

TEST_RELATION le_true_if_value_less, le, 142, 143, 1
TEST_RELATION le_true_if_values_equal, le, 142, 142, 1
TEST_RELATION le_false_if_value_greater, le, 143, 142, 0

TEST_RELATION gt_false_if_value_less, gt, 142, 143, 0
TEST_RELATION gt_false_if_values_equal, gt, 142, 142, 0
TEST_RELATION gt_true_if_value_greater, gt, 143, 142, 1

TEST_RELATION ge_false_if_value_less, ge, 142, 143, 0
TEST_RELATION ge_true_if_values_equal, ge, 142, 142, 1
TEST_RELATION ge_true_if_value_greater, ge, 143, 142, 1

TEST_UNARY_RELATION lt0_when_value_negative, lt0, -1,  1
TEST_UNARY_RELATION lt0_when_value_zero, lt0, 0, 0
TEST_UNARY_RELATION lt0_when_value_positive, lt0, 1, 0
