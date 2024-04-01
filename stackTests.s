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

	bl push_pushes_one_item
	bl push_0

	bl pop_should_remove_one_item
	bl dup_duplicates_top_item
	bl swap_should_swap_top_two_items
	bl cab_puts_third_item_on_top

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

	bl push

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
	bl push

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

TEST_START pop_should_remove_one_item
	// Arrange:
	LOAD_ADDRESS VSP, L_push_test_stack

	mov x0, #21
	DATA_PUSH x0

	mov x0, #17
	DATA_PUSH x0

	// Act:
	bl pop

	// Assert:
	LOAD_ADDRESS x0, L_push_test_stack
	ldr x0, [x0]
	mov x1, #21
	bl assertEqual

	mov x0, VSP
	LOAD_ADDRESS x1, L_push_test_stack
	add x1, x1, #8
	bl assertEqual
TEST_END

TEST_START swap_should_swap_top_two_items
	// Arrange:
	LOAD_ADDRESS VSP, L_push_test_stack

	mov x0, #21
	DATA_PUSH x0

	mov x0, #17
	DATA_PUSH x0

	// Act:
	bl swap

	// Assert:
	LOAD_ADDRESS x0, L_push_test_stack
	ldr x0, [x0]
	mov x1, #17
	bl assertEqual

	LOAD_ADDRESS x0, L_push_test_stack
	ldr x0, [x0, #8]
	mov x1, #21
	bl assertEqual

	mov x0, VSP
	LOAD_ADDRESS x1, L_push_test_stack
	add x1, x1, #16
	bl assertEqual
TEST_END

TEST_START cab_puts_third_item_on_top
	// Arrange:
	LOAD_ADDRESS VSP, L_push_test_stack

	mov x0, #21
	DATA_PUSH x0

	mov x0, #17
	DATA_PUSH x0

	mov x0, #9
	DATA_PUSH x0

	// Act:
	bl cab

	// Assert:
	mov x0, VSP
	LOAD_ADDRESS x1, L_push_test_stack
	add x1, x1, #24
	bl assertEqual

	DATA_POP x0
	mov x1, #21
	bl assertEqual

	DATA_POP x0
	mov x1, #9
	bl assertEqual

	DATA_POP x0
	mov x1, #17
	bl assertEqual

TEST_END
