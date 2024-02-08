.include "unix_functions.macros"
.include "asUnit.macros"

.global _start

.text
.p2align 2

_start:
	str lr, [sp, #-16]!

	bl interpret_empty_program
	bl secondary_runs_yielding_result_on_stack

	unix_exit
	ldr lr, [sp], #16
	ret


.data
.p2align 2
L_empty_header:
.ascii "Test\0..."		// Routine name
.p2align 2
.quad 0		 // dictionary link
empty:
	.quad 0	 // address of start2d
	.quad 0	 // end2d

.text

TEST_START interpret_empty_program
// Arrange: Populate table
	LOAD_ADDRESS x0, empty
	LOAD_ADDRESS x1, start2d
	LOAD_ADDRESS x2, end2d
	
	str x1, [x0], #8
	str x2, [x0]

// Act:	
	LOAD_ADDRESS x0, empty
	bl runInterpreter
	
// Assert:
	mov x0, x20
	LOAD_ADDRESS x1, empty
	add x1, x1, #8
	bl assertEqual
TEST_END

.data
.ascii "Add2\0..."	// Routine name
.p2align 2
.quad 0		 // dictionary link
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
	LOAD_ADDRESS x0, add2
	LOAD_ADDRESS x1, start2d
	LOAD_ADDRESS x2, _push
	LOAD_ADDRESS x3, add
	LOAD_ADDRESS x4, end2d
	
	str x1, [x0], #8
	str x2, [x0], #16
	str x2, [x0], #16
	str x3, [x0], #8
	str x4, [x0]

// Act - pass the secondary to the interpreter
	LOAD_ADDRESS x0, add2
	bl runInterpreter

//  Assert: check that stack contains right answer
	LOAD_ADDRESS x0, data_stack
temp:
	ldr x0, [x0]
	mov x1, #3
	bl assertEqual
TEST_END

