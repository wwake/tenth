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
.asciz "Add2"	// Routine name
.p2align 1
.quad 0		 // dictionary link
add2:
	.quad 0	 // address of add2
	.quad 0	 // _push
	.quad 1	 // data: 1
	.quad 0	 // push
	.quad 2	 // data: 2
	.quad 0	 // add
	.quad 0	 // end2d

.text
TEST_START secondary_runs_yielding_result_on_stack
// Phase 1 - store addresses

TEST_END
