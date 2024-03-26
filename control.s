#include "core.defines"
#include "assembler.macros"

.global _jump
.global _jump_if_false

.text
.p2align 2


// _jump_if_false: evaluate top of stack, branch around code if false
// Input:
//   data value on top of stack
//   x20 points to address value (in secondary) following _jump_if_false word
// Process:
//   x0 - temp
// Output:
//   Original data value is popped
//   x20 - VPC, updated to either move past address value or jump to where it says
//
_jump_if_false:
	DATA_POP x0
	CMP x0, #0
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
