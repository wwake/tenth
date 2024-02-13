.include "assembler.macros"
.include "unix_functions.macros"
.include "asUnit.macros"

.global _start

.p2align 2

_start:
	str lr, [sp, #-16]!

	TEST_ALL "coreTests"

	bl push_pushes_one_item
	bl add_b_plus_a_is_a
	bl if_zero_does_not_jump_for_non_zero_value
	unix_exit
	ldr lr, [sp], #16
	ret
	
	
	TEST_START push_pushes_one_item
	LOAD_ADDRESS X19, L_push_test_stack
	adr x20, L_data

	bl _push

	mov x0, x20
	adr x1, L_data
	add x1, x1, #8		// expect VPC to increment
	bl assertEqual

	mov x0, x19		 // Current VSP
	
	LOAD_ADDRESS x1, L_push_test_stack
	add x1, x1, #8		// Expect original stack+8
	
	bl assertEqual
	
	LOAD_ADDRESS x0, L_push_test_stack
	
	ldr x0, [x0]
	mov x1, #142		// Expected stack contents
	bl assertEqual
	
TEST_END


L_data: .quad 142, 58

.data

.p2align 2
L_push_test_stack: .quad 0, 99, 0, 0
 
	
L_VSP_Update: .asciz "VSP should be incremented"
L_stack_update: .asciz "Stack should have data"
L_VPC_Update: .asciz "VPC should be incremented"

.p2align 2

.text
.p2align 2

TEST_START add_b_plus_a_is_a
	LOAD_ADDRESS x19, L_push_test_stack

	adr x20, L_data

	bl _push
	bl _push

	bl add

	mov x0, x19		 // Current VSP
	LOAD_ADDRESS x1, L_push_test_stack
	add x1, x1, #8		// Expect original stack+8
	bl assertEqual

	LOAD_ADDRESS x0, L_push_test_stack
	ldr x0, [x0]
	mov x1, #200		// Expected stack contents
	bl assertEqual

TEST_END


.data
.p2align 3

L_dict_if_zero1:
	.quad 0 	// start2d
	.quad 0 	// _if_zero
	.quad 0 	// push
	.quad 0 	// end2d

L_if_zero1:
	.quad 0	 	// start2d
	.quad 0	 	// _if_zero
	.quad -1	// data: 1
	.quad 0	 	// push
	.quad 42	//  data
	.quad 0	 // end2d

.text

TEST_START if_zero_does_not_jump_for_non_zero_value
// Arrange
	LOAD_ADDRESS x0, L_dict_if_zero1
	LOAD_ADDRESS x1, start2d
	LOAD_ADDRESS x2, _if_zero
	LOAD_ADDRESS x3, _push
	LOAD_ADDRESS x4, end2d

	str x1, [x0], #8
	str x2, [x0], #8
	str x3, [x0], #8
	str x4, [x0]

	LOAD_ADDRESS x0, L_if_zero1
	LOAD_ADDRESS x1, L_dict_if_zero1
	str x1, [x0], #8
	add x1, x1, #8
	str x1, [x0], #16
	add x1, x1, #8
	str x1, [x0], #16
	add x1, x1, #8
	str x1, [x0]

	LOAD_ADDRESS x0, L_if_zero1
	add x0, x0, #16
	add x1, x0, #24
	str x1, [x0]

// Act
	LOAD_ADDRESS x19, data_stack
	mov x1, #1
	str x1, [x19], #8
	LOAD_ADDRESS x20, L_if_zero1
	add x20, x20, #8
	bl start2d

// Assert
	LOAD_ADDRESS x0, data_stack
	ldr x0, [x0]
	mov x1, #42
	bl assertEqual
TEST_END
