.include "assembler.macros"
.include "unix_functions.macros"

.global data_stack

.global runInterpreter
.global start2d
.global end2d

.data
.p2align 3

// data_stack: Run-time data stack, pointed to by X19 (VSP)
// VSP points to the next place to write
data_stack:
.fill 20

// --------------------------

.text
.p2align 2

// runInterpreter: startup method for the interpreter
// Input: x0 - word address of the method to run
// Output:
//   x19 - the data stack (VSP)
//   x20 - the position in the current block (VPC)
//
runInterpreter:
	str lr, [sp, #-16]!

	LOAD_ADDRESS x19, data_stack
	add x20, x0, #8
	ldr x1, [x0]
	blr x1

	ldr lr, [sp], #16
ret

// start2d: starting point for secondaries
//    Note: this has no "ret"; it relies on end2d being at the end of the sec. list
// Input: x20 is the starting point of the secondary list
// Process:
// Output:
//
start2d:
	str lr, [sp, #-16]!		// push LR and...
	str x20, [sp, #8]		// VPC to system stack

	L_interpreter_loop:
		ldr x1, [x20], #8	 // Load method address, increment VPC
		blr x1				 // Call method
		b L_interpreter_loop // Repeat


end2d:
	ldr x20, [sp, #8]		// Restore VPC and...
	ldr lr, [sp], #16		// LR from system stack
	ret						// Return

