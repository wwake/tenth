.include "assembler.macros"

.global nl
.global _push
.global add
.global _jump
.global _jump_if_false

.align 2

.ascii "nl\0....."  // Name - 16 bytes
.align 4
.quad 0xdeadbeef

.quad 0			 // Link to previous entry
.quad .+8		 // Offset to code

.p2align 2
// code

// nl - print a newline
// Input: none
// Process:
//   x0 - used as temp to refer to NL character
// Output:
//   value is printed
nl:
	str   lr, [sp, #-16]!
	
	adr x0, L_nl_character
	bl print
	
	ldr lr, [sp], #16
	ret

L_nl_character:
	.asciz "\n"
	
.p2align 2


// _push - push the following word on the stack
// Input: x20 - VPC pointing to data vaue (in secondary)
// Process:
// Output:
//   X19 - VSP, updated as value was pushed
//   x20 - VPC, updated to word after data value
//
_push:
	ldr x0, [x20], #8
	DATA_PUSH x0
	ret

// dup - duplicate the item on top of the data stack
// Input: x19, VSP points to top of stack
// Output:
//   stack has top element duplicated
//   x19 increased
//
dup:
	ret

// add - replace top two values with their sum
// Input: Data stack with two values on top
// Process: x0 - temp
// Output: Data stack has two values replaced by sum
add:
	DATA_POP x1
	DATA_POP x0
	add x0, x0, x1
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
		add x20, x20, #8	// skip past the address
	b L_end_jump_if_false
L_skip_if:
		ldr x20, [x20]		// transfer to the address
L_end_jump_if_false:
	ret

// _jump: jump to target value
// Input:
//   x20 points to address value (word in secondary)
// Output:
//   x20 changed to address value it formerly pointed to (=> a jump)
//
_jump:
	ldr x20, [x20]
	ret
