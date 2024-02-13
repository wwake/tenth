.include "assembler.macros"
.include "unix_functions.macros"
.include "asUnit.macros"

.global _start

// DICT_START - start writing a dictionary block
// uses x0, leaves it pointing to next entry to write
.macro DICT_START dict_label
	LOAD_ADDRESS x0, \dict_label
.endm

// DICT_ADD - adds the next dictionary entry
// Uses x1 as a temp
// Leaves x0 pointing to next entry to write
.macro DICT_ADD entry
	LOAD_ADDRESS x1, \entry
	str x1, [x0], #8
.endm


// SECONDARY_START - sets up x0 and x1 to point to initial secondary & dictionary
.macro SECONDARY_START secondary, dictionary
LOAD_ADDRESS x0, \secondary
LOAD_ADDRESS x1, \dictionary
.endm

// SECONDARY_ADD - stores dictionary address at x0; updates x0
// Uses x0-x2
.macro SECONDARY_ADD dictionaryIndex
	add x2, x1, #8*\dictionaryIndex
	str x2, [x0], #8
.endm

// SECONDARY_SKIP - skips over one secondary cell
// Uses x0
.macro SECONDARY_SKIP
	add x0, x0, #8
.endm


// SECONDARY_DATA - stores value in the next secondary cell
// Uses x0 and x2
.macro SECONDARY_DATA value
	mov x2, \value
	str x2, [x0], #8
.endm


.p2align 2

_start:
	str lr, [sp, #-16]!

	TEST_ALL "coreTests"

	bl push_pushes_one_item

	bl add_b_plus_a_is_a

	bl if_zero_does_not_jump_for_non_zero_value
	bl if_zero_jumps_for_zero_value

	bl jump_skips_over_code

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

L_test_dictionary:
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0

L_test_secondary:
	.quad 0	 	// start2d
	.quad 0	 	// _if_true
	.quad -1	// data: 1 or 0
	.quad 0	 	// push
	.quad 42	//  data
	.quad 0	 // end2d

.text


TEST_START if_zero_does_not_jump_for_non_zero_value
// Arrange
	DICT_START L_test_dictionary
	DICT_ADD start2d
	DICT_ADD _if_true
	DICT_ADD _push
	DICT_ADD end2d

	SECONDARY_START L_test_secondary, L_test_dictionary
	SECONDARY_ADD 0
	SECONDARY_ADD 1
	SECONDARY_SKIP
	SECONDARY_ADD 2
	SECONDARY_DATA #42
	SECONDARY_ADD 3

	LOAD_ADDRESS x0, L_test_secondary
	add x0, x0, #16
	add x1, x0, #24
	str x1, [x0]

// Act
	LOAD_ADDRESS x19, data_stack
	mov x1, #1						// Data is 1 - should not skip
	str x1, [x19], #8
	LOAD_ADDRESS x20, L_test_secondary
	add x20, x20, #8
	bl start2d

// Assert
	LOAD_ADDRESS x0, data_stack
	ldr x0, [x0]
	mov x1, #42
	bl assertEqual
TEST_END

TEST_START if_zero_jumps_for_zero_value
// Arrange
	DICT_START L_test_dictionary
	DICT_ADD start2d
	DICT_ADD _if_true
	DICT_ADD _push
	DICT_ADD end2d

	SECONDARY_START L_test_secondary, L_test_dictionary
	SECONDARY_ADD 0
	SECONDARY_ADD 1
	SECONDARY_SKIP
	SECONDARY_ADD 2
	SECONDARY_SKIP
	SECONDARY_ADD 3

	LOAD_ADDRESS x0, L_test_secondary
	add x0, x0, #16
	add x1, x0, #24
	str x1, [x0]

// Act
	LOAD_ADDRESS x19, data_stack
	mov x1, #0					// Data is 0 - should skip
	str x1, [x19], #8
	LOAD_ADDRESS x20, L_test_secondary
	add x20, x20, #8
	bl start2d

// Assert
	mov x0, x19
	LOAD_ADDRESS x1, data_stack
	bl assertEqual			// check that VSP is back to original place
TEST_END


TEST_START jump_skips_over_code
// Arrange
	DICT_START L_test_dictionary
	DICT_ADD start2d
	DICT_ADD _jump
	DICT_ADD _push
	DICT_ADD end2d

	SECONDARY_START L_test_secondary, L_test_dictionary
	SECONDARY_ADD 0
	SECONDARY_ADD 1
	SECONDARY_SKIP
	SECONDARY_ADD 2
	SECONDARY_DATA #17
	SECONDARY_ADD 3

	LOAD_ADDRESS x0, L_test_secondary
	add x0, x0, #16
	add x1, x0, #24
	str x1, [x0]

	// Act
	LOAD_ADDRESS x19, data_stack
	LOAD_ADDRESS x20, L_test_secondary
	add x20, x20, #8
	bl start2d

// Assert
	mov x0, x19
	LOAD_ADDRESS x1, data_stack
	bl assertEqual			// check that VSP is back to original place
TEST_END
