#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "asUnit.macros"
.include "coreTests.macros"
.include "repl.macros"

.global _start


.p2align 2

_start:
	STD_PROLOG

	TEST_ALL "stackTests"

	// Stack
	bl push_pushes_one_item
	bl dup_duplicates_top_item
	bl push_0

	unix_exit
	STD_EPILOG
	ret


.data

.p2align 3
L_push_test_stack: .quad 0, 99, 0, 0

.text
L_data: .quad 142, 58


TEST_START push_pushes_one_item
	LOAD_ADDRESS VSP, L_push_test_stack
	adr VPC, L_data

	bl _push

	mov x0, VPC
	adr x1, L_data
	add x1, x1, #8		// expect VPC to increment
	bl assertEqual

	mov x0, VSP

	LOAD_ADDRESS x1, L_push_test_stack
	add x1, x1, #8		// Expect original stack+8

	bl assertEqual

	LOAD_ADDRESS x0, L_push_test_stack

	ldr x0, [x0]
	mov x1, #142		// Expected stack contents
	bl assertEqual

TEST_END


TEST_START dup_duplicates_top_item
	// Arrange:
	LOAD_ADDRESS VSP, L_push_test_stack

	adr VPC, L_data
	bl _push

	// Act:
	bl dup

	// Assert:
	DATA_POP_AB x0, x1
	mov x28, x0
	bl assertEqual

	mov x0, x28
	mov x1, #142
	bl assertEqual

TEST_END


TEST_START push_0
	// Arrange:
	LOAD_ADDRESS VSP, L_push_test_stack
	str VSP, [VSP]

	// Act:
	bl push0

	// Assert:
	LOAD_ADDRESS x0, L_push_test_stack
	ldr x0, [x0]
	mov x1, #0
	bl assertEqual

	mov x0, VSP
	LOAD_ADDRESS x1, L_push_test_stack
	add x1, x1, #8
	bl assertEqual
TEST_END
