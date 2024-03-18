#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "asUnit.macros"
.include "coreTests.macros"
.include "repl.macros"

.global _start


.p2align 2

_start:
	str lr, [sp, #-16]!

	TEST_ALL "coreTests"

	// Definition
	bl colon_switches_to_compile_mode
	bl semicolon_switches_to_run_mode
	bl semicolon_writes_end2d_in_secondary

	// Stack
	bl push_pushes_one_item
	bl dup_duplicates_top_item

	// Arithmetic
	bl add_b_plus_a_is_a
	bl sub_b_minus_a_is_difference
	bl mul_b_by_a_is_product

	// Logical
	bl neq_true_if_values_differ
	bl neq_false_if_values_the_same

	// Conditional
	bl if_zero_does_not_jump_for_non_zero_value
	bl if_zero_jumps_for_zero_value

	bl jump_skips_over_code

	unix_exit
	ldr lr, [sp], #16
	ret
	

TEST_START colon_switches_to_compile_mode
	mov FLAGS, RUN_MODE

	bl _colon

	mov x0, FLAGS
	mov x1, COMPILE_MODE
	bl assertEqual
TEST_END

TEST_START semicolon_switches_to_run_mode
	mov FLAGS, COMPILE_MODE

	bl _semicolon

	mov x0, FLAGS
	mov x1, RUN_MODE
	bl assertEqual
TEST_END


TEST_START semicolon_writes_end2d_in_secondary
	// set x25 (SEC_SPACE) somewhere
	// call semicolon
	// verify that end2d's word address is in the previous cell
	// verify that SEC_SPACE increased by 8 bytes
	//bl assertEqual
TEST_END

.data

.p2align 2
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


.data
L_VSP_Update: .asciz "VSP should be incremented"
L_stack_update: .asciz "Stack should have data"
L_VPC_Update: .asciz "VPC should be incremented"

.p2align 2

.text
.p2align 2

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

.data
.p2align 8

debugData:
L_test_dictionary:
	.quad 1
	.quad 2
	.quad 3
	.quad 5
	.quad 7
	.quad 11
	.quad 13
	.quad 17

L_test_secondary:
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0

.text


TEST_START if_zero_does_not_jump_for_non_zero_value
// Arrange
	DICT_START L_test_dictionary
	DICT_ADD _jump_if_false	// 0
	DICT_ADD _push			// 1
	DICT_ADD end2d			// 2

	SECONDARY_START L_test_secondary, L_test_dictionary, start2d
	SECONDARY_ADD 1
	SECONDARY_DATA #7
	SECONDARY_ADD 0
	SECONDARY_TARGET 7
	SECONDARY_ADD 1
	SECONDARY_DATA #42
	SECONDARY_ADD 2

// Act
	LOAD_ADDRESS x0, L_test_secondary
	bl runInterpreter

// Assert
	DATA_TOP x0
	mov x1, #42
	bl assertEqual
TEST_END

TEST_START if_zero_jumps_for_zero_value
	// Arrange
	DICT_START L_test_dictionary
	DICT_ADD _jump_if_false
	DICT_ADD _push
	DICT_ADD end2d

	SECONDARY_START L_test_secondary, L_test_dictionary, start2d
	SECONDARY_ADD 1
	SECONDARY_DATA #0
	SECONDARY_ADD 0
	SECONDARY_TARGET 7
	SECONDARY_ADD 1
	SECONDARY_DATA #42
	SECONDARY_ADD 2

// Act
	LOAD_ADDRESS x0, L_test_secondary
	bl runInterpreter

// Assert
	mov x0, VSP
	LOAD_ADDRESS x1, data_stack
	bl assertEqual			// check that VSP is back to original place
TEST_END


TEST_START jump_skips_over_code
// Arrange
	DICT_START L_test_dictionary
	DICT_ADD _jump  //0
	DICT_ADD _push  //1
	DICT_ADD end2d  //2

	SECONDARY_START L_test_secondary, L_test_dictionary, start2d
	SECONDARY_ADD 0
	SECONDARY_TARGET 5
	SECONDARY_ADD 1
	SECONDARY_DATA #17
	SECONDARY_ADD 2

	// Act
	LOAD_ADDRESS x0, L_test_secondary
	bl runInterpreter

// Assert
	mov x0, VSP
	LOAD_ADDRESS x1, data_stack
	bl assertEqual			// check that VSP is back to original place
TEST_END
