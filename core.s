#include "core.defines"
#include "assembler.macros"

.include "repl.macros"


.global _colon
.global _semicolon

.global neq

.global _jump
.global _jump_if_false


.p2align 2


// _colon (:) - enter compile mode
_colon:
	STD_PROLOG

	// Read the word to be defined
	bl readWord

	// Put word string after last secondary
	mov x1, SEC_SPACE
	bl strcpyz

	// Adjust SEC_SPACE to a 64-bit boundary
	mov x0, SEC_SPACE
	bl strlen
	add x0, x0, #8
	and x0, x0, #-8

	mov x1, SEC_SPACE
	add SEC_SPACE, SEC_SPACE, x0

	// Put old dictionary at first slot; update dictionary
	str SYS_DICT, [SEC_SPACE]
	mov SYS_DICT, SEC_SPACE

	// Put pointer to word string in 2d slot
	str x1, [SYS_DICT, #8]

	// Put pointer to start2d in the third slot
	LOAD_ADDRESS x0, start2d
	str x0, [SYS_DICT, #16]

	// Move SEC_SPACE past the headers
	add SEC_SPACE, SEC_SPACE, #24

	// Change to Compile mode
	mov FLAGS, COMPILE_MODE

	STD_EPILOG
	ret

// _semicolon (;) - exit compile mode
// Write a pointer to end2d's word address as last entry in secondary
//
_semicolon:
	STD_PROLOG

	LOAD_ADDRESS x0, end2d_wordAddress
	str x0, [SEC_SPACE], #8

	mov FLAGS, RUN_MODE

	STD_EPILOG
	ret



// neq - pop a, b and push replace top a,b with boolean
// Input: Data stack with two values on top
// Process: x0, x1 - temp
// Output: Data stack has popped two values and pushed 1 if equal else 0
neq:
	DATA_POP_AB x1, x0
	cmp x0, x1
	cset x0, ne
	DATA_PUSH x0
ret


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
