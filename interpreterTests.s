.include "unix_functions.macros"
.include "core.macros"
.include "asUnit.macros"

.global _start

.text
.p2align 2

_start:
	str lr, [sp, #-16]!

	bl interpret_empty_program

	unix_exit
	ldr lr, [sp], #16
	ret


runInterpreter:
	LOAD_ADDRESS x19, data_stack
	add x20, x0, #8
	br x0
	
start2d:
	add x20, x20, #8
  	ret

end2d:
  	ret

.data
.p2align 3
data_stack:
	.fill 10000

.data
.p2align 2
L_empty_header:
.asciz "Test"	// Routine name
.quad 0		 // dictionary link
L_empty:
	.quad 0	 // address of start2d
	.quad 0	 // end2d

.text

TEST_START interpret_empty_program
// Arrange: Populate table
	LOAD_ADDRESS x0, L_empty
	LOAD_ADDRESS x1, start2d
	LOAD_ADDRESS x2, end2d
	
	str x1, [x0], #8
	str x2, [x0]

// Act:	
	LOAD_ADDRESS x0, L_empty
	bl runInterpreter
	
// Assert:
	mov x0, x20
	LOAD_ADDRESS x1, L_empty
	add x1, x1, #16
	bl assertEqual
TEST_END

.data
.asciz "Add2"	// Routine name
.p2align 2
.quad 0		 // dictionary link
add2:
	.quad 0	 // address of start2d
	.quad 0	 // _push
	.quad 1	 // data: 1
	.quad 0	 // push
	.quad 2	 // data: 2
	.quad 0	 // add
	.quad 0	 // end2d

.text


TEST_START secondary_runs_yielding_result_on_stack
// Arrange - build our secondary
//	LOAD_ADDRESS x0, add2
//	LOAD_ADDRESS x1, start2d
//	LOAD_ADDRESS x2, _push
//	LOAD_ADDRESS x3, add
//	LOAD_ADDRESS x4, end2d
	
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

TEST_END

