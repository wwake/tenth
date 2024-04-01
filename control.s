#include "core.defines"
#include "assembler.macros"

.global init_control_stack

.global jump_if_false_word_address
.global jump_if_false

.global jump_word_address
.global jump

.global repeat
.global until

.global if
.global else
.global fi

.data
.p2align 3

control_stack: .fill 20, 8, 0


jump_if_false_word_address:
	.quad jump_if_false


jump_word_address:
	.quad jump

.text

.p2align 3


// init_control_stack
// Result: CONTROL_STACK now points to control_stack
//
init_control_stack:
	LOAD_ADDRESS CONTROL_STACK, control_stack
	ret


// jump_if_false: evaluate top of stack, branch to specified address if false
// Input:
//   data value on top of stack
//   VPC (register) points to address value (in secondary) following jump_if_false word
// Process:
//   x0 - temp
// Output:
//   Original data value is popped
//   VPC (register), updated to either move past address value or jump to where it says
//
jump_if_false:
	DATA_POP x0
	cmp x0, #0
	b.eq L_skip_if
		add VPC, VPC, #8	// skip past the address
	b L_end_jump_if_false
L_skip_if:
		ldr VPC, [VPC]		// transfer to the address
L_end_jump_if_false:
	ret

// jump: jump to target value
// Input:
//   x20 points to address value (word in secondary)
// Output:
//   x20 changed to address value it formerly pointed to (=> a jump)
//
jump:
	ldr VPC, [VPC]
	ret


// repeat: meta word that is the start of repeat-until loop
// Result: Store current secondary address in the control stack
//
repeat:
	CONTROL_PUSH SEC_SPACE
	ret


// until: meta word
//
until:
	// Write jump_if_false to secondary
	LOAD_ADDRESS x0, jump_if_false_word_address
	STORE_SEC x0

	// Pop control stack and write that 
	//    address to secondary
	CONTROL_POP x0
	STORE_SEC x0

	ret

// if - handles beginning of if statement
// Generate jump_if_false, store addr on control stack
if:
	// Generate jump_if_false
	LOAD_ADDRESS x0, jump_if_false_word_address
	STORE_SEC x0

	// Save addr to backpatch
	CONTROL_PUSH SEC_SPACE

	// Generate -1 as a placeholder
	mov x0, #-1
	STORE_SEC x0

	ret

// else - handles else clause
//
else:
	// Generate the jump
	LOAD_ADDRESS x0, jump_word_address
	STORE_SEC x0

	// Get the patch location
	CONTROL_POP x0

	// Push the current secondary address to the control stack
	CONTROL_PUSH SEC_SPACE

	// Generate placeholder address
	mov x1, #-1
	STORE_SEC x1

	// Store address of else body to the patch location
	str SEC_SPACE, [x0]

	ret

// fi - handles end of if statement
// Pop address from control stack, backpatch current SEC_SPACE there
fi:
	CONTROL_POP x0
	str SEC_SPACE, [x0]

	ret
