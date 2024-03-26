#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "asUnit.macros"
.include "coreTests.macros"
.include "repl.macros"

.global _start

.data
.p2align 3

test_data_stack: .quad 0, 99, 0, 0

.text
.p2align 3
L_data: .quad 142, 58


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

	unix_exit
	STD_EPILOG
	ret


.macro BINOP_TEST test_name, routine_to_test, expected
TEST_START \test_name
	// Arrange:
	LOAD_ADDRESS VSP, test_data_stack
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


BINOP_TEST "add_b_plus_a_is_a", add, 200
BINOP_TEST "sub_b_minus_a_is_difference", sub, 84
BINOP_TEST "mul_b_by_a_is_product", mul, 8236
BINOP_TEST "div_b_by_a_is_dividend", div, 2
BINOP_TEST "mod_b_by_a_is_dividend", mod, 26

BINOP_TEST "m_b_a_is_minimum", min, 58
BINOP_TEST "m_b_a_is_maximum", max, 142
