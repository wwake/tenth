#include "core.defines"
#include "assembler.macros"

.global init_control_stack

.global _jump_if_false
.global _jump_if_false_word_address

.global _jump

.global repeat
.global until

.global control_stack

.data
.p2align 3

control_stack: .fill 20, 8, 0


_jump_if_false_word_address:
	.quad _jump_if_false


.text

.p2align 3


// init_control_stack
// Result: CONTROL_STACK now points to control_stack
//
init_control_stack:
	LOAD_ADDRESS CONTROL_STACK, control_stack
	ret


// _jump_if_false: evaluate top of stack, branch to specified address if false
// Input:
//   data value on top of stack
//   VPC (register) points to address value (in secondary) following _jump_if_false word
// Process:
//   x0 - temp
// Output:
//   Original data value is popped
//   VPC (register), updated to either move past address value or jump to where it says
//
_jump_if_false:
	DATA_POP x0
	cmp x0, #0
	b.eq L_skip_if
		add VPC, VPC, #8	// skip past the address
	b L_end_jump_if_false
L_skip_if:
		ldr VPC, [VPC]		// transfer to the address
L_end_jump_if_false:
	ret

// _jump: jump to target value
// Input:
//   x20 points to address value (word in secondary)
// Output:
//   x20 changed to address value it formerly pointed to (=> a jump)
//
_jump:
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
	LOAD_ADDRESS x0, _jump_if_false_word_address
	str x0, [SEC_SPACE], #8

	// Pop control stack and write that address to secondary
	CONTROL_POP x0
	str x0, [SEC_SPACE], #8

	ret
