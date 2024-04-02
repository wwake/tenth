#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "asUnit.macros"
.include "coreTests.macros"

.global _start

.text
.p2align 2

_start:
	STD_PROLOG

	TEST_ALL "interpreterTests"

	bl interpret_empty_program
	bl secondary_runs_yielding_result_on_stack
	bl secondary_calls_another_secondary
	bl recursive_factorial

	bl loadAddress_pushes_address_of_secondary

	unix_exit
	STD_EPILOG
	ret


.data
.p2align 2
L_empty_header:
.ascii "Test\0..."		// Routine name
.p2align 3
.quad 0		 // dictionary link

L_pseudo_header:
	.quad 0
	.quad 0

L_empty:
	.quad 0	 // word address of start2d
	.quad 0	 // word address of end2d

.text

TEST_START interpret_empty_program
// Arrange: Populate table
	LOAD_ADDRESS x0, L_pseudo_header
	LOAD_ADDRESS x1, start2d
	LOAD_ADDRESS x2, end2d
	
	str x1, [x0], #8
	str x2, [x0]

	LOAD_ADDRESS x0, L_pseudo_header
	LOAD_ADDRESS x1, L_empty
	str x0, [x1], #8
	add x0, x0, #8
	str x0, [x1]

// Act:
	LOAD_ADDRESS x0, L_empty
	bl runInterpreter
	
// Assert:
	mov x0, VPC
	LOAD_ADDRESS x1, L_empty
	bl assertEqual
TEST_END

.data
.ascii "Add2\0..."	// Routine name
.p2align 2
.quad 0		 // dictionary link

L_add2_dictionary:
	.quad 0
	.quad 0
	.quad 0
	.quad 0

add2:
	.quad 0	 // address of start2d
	.quad 0	 // push
	.quad 1	 // data: 1
	.quad 0	 // push
	.quad 2	 // data: 2
	.quad 0	 // add
	.quad 0	 // end2d

.text

TEST_START secondary_runs_yielding_result_on_stack
// Arrange - build our secondary
	LOAD_ADDRESS x0, L_add2_dictionary
	LOAD_ADDRESS x1, start2d
	LOAD_ADDRESS x2, push
	LOAD_ADDRESS x3, add
	LOAD_ADDRESS x4, end2d

	str x1, [x0], #8
	str x2, [x0], #8
	str x3, [x0], #8
	str x4, [x0]

	LOAD_ADDRESS x0, add2
	LOAD_ADDRESS x1, L_add2_dictionary
	str x1, [x0], #8
	add x1, x1, #8
	str x1, [x0], #16
	str x1, [x0], #16
	add x1, x1, #8
	str x1, [x0], #8
	add x1, x1, #8
	str x1, [x0]

// Act - pass the secondary to the interpreter
	LOAD_ADDRESS x0, add2
	bl runInterpreter

//  Assert: check that stack contains right answer
	LOAD_ADDRESS x0, data_stack
	ldr x0, [x0]
	mov x1, #3
	bl assertEqual
TEST_END

.data
.p2align 8

L_test_dictionary:
	.fill 10, 8, 2

L_secondary1:
	.fill 10, 8, 3

L_secondary2:
	.fill 10, 8, 5

.text
.p2align 3
TEST_START secondary_calls_another_secondary
// Arrange - build dictionary and two secondaries

	DICT_START L_test_dictionary
	DICT_ADD push	// 0
	DICT_ADD end2d	// 1

	SECONDARY_START L_secondary1, L_test_dictionary, start2d
	SECONDARY_ADDRESS L_secondary2
	SECONDARY_ADD 1

	SECONDARY_START L_secondary2, L_test_dictionary, start2d
	SECONDARY_ADD 0
	SECONDARY_DATA #55
	SECONDARY_ADD 1

// Act - pass the secondary to the interpreter
	LOAD_ADDRESS x0, L_secondary1
	bl runInterpreter

//  Assert: check that stack contains right answer
	DATA_TOP x0
	mov x1, #55
	bl assertEqual

TEST_END


.data
.p2align 8

L_factorial:
.fill 16, 8, 2

.text

// FACTORIAL   // S → A
//
// DUP       // S → A A
// 1         // S → 1 A A
// NEQ       // S → bool A
// IF        // S → A
//   DUP       // S → A A
//   1         // S → 1 A A
//   SUB       // S → (A-1) A
//   FACTORIAL // S → (A-1)! A
//   MUL       // S → A*(A-1)!
// END       // S → A!
TEST_START recursive_factorial
	// Arrange:
	DICT_START L_test_dictionary
	DICT_ADD end2d	// 0
	DICT_ADD dup	// 1
	DICT_ADD push	// 2
	DICT_ADD neq	// 3
	DICT_ADD jump_if_false	// 4
	DICT_ADD sub	// 5
	DICT_ADD mul	// 6

	SECONDARY_START L_factorial, L_test_dictionary, start2d
	SECONDARY_ADD 1		// DUP
	SECONDARY_ADD 2		// push
	SECONDARY_DATA 1	// literal 1
	SECONDARY_ADD 3		// NEQ
	SECONDARY_ADD 4		// jump_if_false
	SECONDARY_TARGET 13	// address to jump to
	SECONDARY_ADD 1		// DUP
	SECONDARY_ADD 2		// push
	SECONDARY_DATA 1	// literal 1
	SECONDARY_ADD 5		// SUB
	SECONDARY_ADDRESS L_factorial	// FACTORIAL
	SECONDARY_ADD 6		// MUL
	SECONDARY_ADD 0		// end2d

	// Act:
	mov x0, #6
	DATA_PUSH x0

	LOAD_ADDRESS x0, L_factorial
	mov VPC, x0
	bl start2d

	// Assert
	DATA_POP x0
	mov x1, #720
	bl assertEqual
TEST_END

.data
.p2align 3

L_test_address:
	.quad 0

.text
.align 2

//
TEST_START loadAddress_pushes_address_of_secondary
	// Arrange:
	LOAD_ADDRESS x0, L_test_address

	// Act
	bl loadAddress

	// Assert:
	DATA_POP x0
	LOAD_ADDRESS x1, L_test_address
	add x1, x1, #8
	bl assertEqual
TEST_END
