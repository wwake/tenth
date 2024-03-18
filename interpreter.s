#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"

.global runInterpreter
.global start2d
.global end2d


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

	LOAD_ADDRESS VSP, data_stack
	mov x20, x0
	bl start2d

	ldr lr, [sp], #16
	ret

// start2d: header routine (starting point) for all secondaries
//    Note: this has no "ret"; it relies on end2d being at the end of the sec. list
// Input: x0 is the starting point of the secondary list
// Process:
//   x20 - VPC, starts at initial x0, then moves through the secondary list
//   x0 - temp: set to input of next secondary to call
//   x1 - temp: holds word address of next secondary to cal
// Output:
//   x19 - VSP - may be updated by secondaries caled
//   x20 - VPC - remains mutated (end2d must restore)
//
start2d:
	str lr, [sp, #-16]!		// push LR and...
	str x20, [sp, #8]		// VPC to system stack

	add x20, x0, #8			// start VPC just past start2d call

	L_interpreter_loop:
		ldr x0, [x20], #8	 // Load word address, increment VPC
		ldr x1, [x0]		// Load address of code
		blr x1				 // Call method
		b L_interpreter_loop // Repeat


// end2d - footer routine for all secondaries; handles the return
// Input: none
// Output:
//   x19 - remains altered if changed by other routines
//   x20 - restored (as pushed by start2d)
//   LR - restored (as pushed by start2d)
//
end2d:
	ldr x20, [sp, #8]		// Restore VPC and...
	ldr lr, [sp], #16		// LR from system stack
	ret						// Return

