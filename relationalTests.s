#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "asUnit.macros"

.global _start

_start:
	STD_PROLOG

	TEST_ALL "relationalTests"

	bl neq_true_if_values_differ
	bl neq_false_if_values_the_same

	unix_exit
	STD_EPILOG
	ret


.data
.p2align 3

L_push_test_stack: .quad 0, 99, 0, 0

.text
.p2align 3

L_data: .quad 142, 58


TEST_START neq_true_if_values_differ
	// Arrange:
	LOAD_ADDRESS VSP, L_push_test_stack
	adr VPC, L_data
	bl _push

	adr VPC, L_data + 8
	bl _push

	// Act:
	bl neq

	// Assert:
	DATA_POP x0
	mov x1, #1
	bl assertEqual
TEST_END

TEST_START neq_false_if_values_the_same
	// Arrange:
	LOAD_ADDRESS VSP, L_push_test_stack
	adr VPC, L_data
	bl _push

	adr VPC, L_data
	bl _push

	// Act:
	bl neq

	// Assert:
	DATA_POP x0
	mov x1, #0
	bl assertEqual
TEST_END
