#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "asUnit.macros"
.include "coreTests.macros"
.include "repl.macros"

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

	TEST_ALL "arithmeticTests"

	bl add_b_plus_a_is_a
	bl sub_b_minus_a_is_difference
	bl mul_b_by_a_is_product
	bl div_b_by_a_is_dividend
	bl mod_b_by_a_is_dividend

	bl m_b_a_is_minimum
	bl m_b_a_is_maximum

	bl divmod_puts_mod_on_top_then_dividend

	bl neg_a_goes_to_positive_a
	bl pos_a_goes_to_negative_a

	bl abs_of_neg_a_goes_to_positive_a
	bl abs_of_pos_a_goes_to_positive_a

	unix_exit
	STD_EPILOG
	ret


.macro BINOP_TEST test_name, routine_to_test, expected
TEST_START \test_name
	// Arrange:
	LOAD_ADDRESS VSP, L_test_data_stack
	adr VPC, L_data
	bl push

	adr VPC, L_data + 8
	bl push

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
	bl push

	// Act:
	bl \routine_to_test

	// Assert:
	DATA_POP x0
	mov x1, \expected
	bl assertEqual
TEST_END
.endm


BINOP_TEST "add_b_plus_a_is_a", add, 200
BINOP_TEST "sub_b_minus_a_is_difference", sub, 84
BINOP_TEST "mul_b_by_a_is_product", mul, 8236
BINOP_TEST "div_b_by_a_is_dividend", div, 2
BINOP_TEST "mod_b_by_a_is_dividend", mod, 26

BINOP_TEST "m_b_a_is_minimum", min, 58
BINOP_TEST "m_b_a_is_maximum", max, 142


TEST_START divmod_puts_mod_on_top_then_dividend
	// Arrange:
	LOAD_ADDRESS VSP, L_test_data_stack
	adr VPC, L_data
	bl push

	adr VPC, L_data + 8
	bl push

	// Act:
	bl divmod

	// Assert:
	DATA_POP x0
	mov x1, #26
	bl assertEqual

	DATA_POP x0
	mov x1, #2
	bl assertEqual
TEST_END


UNARY_OP_TEST "neg_a_goes_to_positive_a", 16, neg, 7
UNARY_OP_TEST "pos_a_goes_to_negative_a", 8, neg, -58

UNARY_OP_TEST "abs_of_neg_a_goes_to_positive_a", 16, abs, 7
UNARY_OP_TEST "abs_of_pos_a_goes_to_positive_a", 8, abs, 58

