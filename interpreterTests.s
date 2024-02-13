.include "assembler.macros"
.include "unix_functions.macros"
.include "asUnit.macros"
.include "coreTests.macros"

.global _start

.text
.p2align 2

_start:
	str lr, [sp, #-16]!

	TEST_ALL "interpreterTests"

	bl interpret_empty_program
	bl secondary_runs_yielding_result_on_stack

	unix_exit
	ldr lr, [sp], #16
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
	mov x0, x20
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
	.quad 0	 // _push
	.quad 1	 // data: 1
	.quad 0	 // _push
	.quad 2	 // data: 2
	.quad 0	 // add
	.quad 0	 // end2d

.text


TEST_START secondary_runs_yielding_result_on_stack
// Arrange - build our secondary
	LOAD_ADDRESS x0, L_add2_dictionary
	LOAD_ADDRESS x1, start2d
	LOAD_ADDRESS x2, _push
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
.p2align 3

L_test_dictionary:
	.fill 10

L_secondary1:
	.fill 10

L_secondary2:
	.fill 10


.text
.p2align 3
TEST_START secondary_calls_another secondary
// Arrange - build dictionary and two secondaries

	DICT_START L_test_dictionary
	DICT_ADD start2d
	DICT_ADD _push
	DICT_ADD L_secondary2
	DICT_ADD end2d

	SECONDARY_START L_secondary1, L_test_dictionary
	SECONDARY_ADD 0
	SECONDARY_ADD 2
	SECONDARY_ADD 3

	SECONDARY_START L_secondary2, L_test_dictionary
	SECONDARY_ADD 0
	SECONDARY_ADD 1
	SECONDARY_DATA #5
	SECONDARY_ADD 3

// Act - pass the secondary to the interpreter
// TBD
LOAD_ADDRESS x0, add2
bl runInterpreter

//  Assert: check that stack contains right answer
LOAD_ADDRESS x0, data_stack
ldr x0, [x0]
mov x1, #3
bl assertEqual
TEST_END

