#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"

.global runInterpreter
.global start2d
.global end2d
.global end2d_wordAddress

.text
.p2align 2

// runInterpreter: startup method for the interpreter
// Input: x0 - word address of the method to run
// Output:
//   VSP (register) - the data stack
//   VPC (register) - the position in the current block
//
runInterpreter:
	STD_PROLOG

	LOAD_ADDRESS VSP, data_stack
	mov VPC, x0
	bl start2d

	STD_EPILOG
	ret

// start2d: header routine (starting point) for all secondaries
//    Note: this has no "ret"; it relies on end2d being at the end of the sec. list
// Input: x0 is the starting point of the secondary list
// Process:
//   VPC (register), starts at initial x0, then moves through the secondary list
//   x0 - temp: set to input of next secondary to call
//   x1 - temp: holds word address of next secondary to cal
// Output:
//   VSP (register) - may be updated by secondaries caled
//   VPC (register) - remains mutated (end2d must restore)
//
start2d:
	STD_PROLOG		// push LR and...
	str VPC, [sp, #8]		// VPC to system stack

	add VPC, x0, #8			// start VPC just past start2d call

	L_interpreter_loop:
		ldr x0, [VPC], #8	 // Load word address, increment VPC
		ldr x1, [x0]		// Load address of code
		blr x1				 // Call method
		b L_interpreter_loop // Repeat


// end2d - footer routine for all secondaries; handles the return
// Input: none
// Output:
//   VSP (register) - remains altered if changed by other routines
//   VPC (register) - restored (as pushed by start2d)
//   LR - restored (as pushed by start2d)
//
.data
.p2align 3
end2d_wordAddress:
	.quad end2d

.text
.align 2
end2d:
	ldr VPC, [sp, #8]		// Restore VPC and...
	STD_EPILOG				//   ... LR from system stack
	ret						// Return

