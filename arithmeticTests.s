#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "asUnit.macros"
.include "coreTests.macros"
.include "repl.macros"

.global _start

.data
.p2align 3

L_push_test_stack: .quad 0, 99, 0, 0

.text
.p2align 3
L_data: .quad 142, 58


.align 2

_start:
	STD_PROLOG

	TEST_ALL "arithmeticTests"

	// Arithmetic
	bl add_b_plus_a_is_a
	bl sub_b_minus_a_is_difference
	bl mul_b_by_a_is_product

	unix_exit
	STD_EPILOG
	ret


TEST_START add_b_plus_a_is_a
	LOAD_ADDRESS VSP, L_push_test_stack

	adr VPC, L_data

	bl _push
	bl _push

	bl add

	mov x0, VSP
	LOAD_ADDRESS x1, L_push_test_stack
	add x1, x1, #8		// Expect original stack+8
	bl assertEqual

	LOAD_ADDRESS x0, L_push_test_stack
	ldr x0, [x0]
	mov x1, #200		// Expected stack contents
	bl assertEqual

TEST_END

TEST_START sub_b_minus_a_is_difference
	// Arrange:
	LOAD_ADDRESS VSP, L_push_test_stack
	adr VPC, L_data
	bl _push

	adr VPC, L_data + 8
	bl _push

	// Act:
	bl sub

	// Assert:
	DATA_POP x0
	mov x1, #84
	bl assertEqual
TEST_END

TEST_START mul_b_by_a_is_product
	// Arrange:
	LOAD_ADDRESS VSP, L_push_test_stack
	adr VPC, L_data
	bl _push

	adr VPC, L_data + 8
	bl _push

	// Act:
	bl mul

	// Assert:
	DATA_POP x0
	mov x1, #8236
	bl assertEqual
TEST_END
