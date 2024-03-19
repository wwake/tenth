#include "core.defines"
#include "assembler.macros"

.include "repl.macros"

.global data_stack
.global data_stack_init

.global nl

.global _colon
.global _semicolon

.global _push
.global push1

.global dup

.global add
.global sub
.global mul

.global neq

.global _jump
.global _jump_if_false

.equ DATA_STACK_SIZE, 1000

.data
.align 2

.quad 0		// empty space in front of stack

// data_stack: Run-time data stack, pointed to by X19 (VSP)
// VSP points to the next place to write
data_stack:
	.fill DATA_STACK_SIZE, 8, 0

// --------------------------


.text
.align 2

// data_stack_init - setup stack and VSP
//
data_stack_init:
	LOAD_ADDRESS x19, data_stack
	ret

// nl - print a newline
// Input: none
// Process:
//   x0 - used as temp to refer to NL character
// Output:
//   value is printed
nl:
	str lr, [sp, #-16]!
	
	adr x0, L_nl_character
	bl print
	
	ldr lr, [sp], #16
	ret

L_nl_character:
	.asciz "\n"
	
L_colon:
	.asciz "in :\n"

L_semicolon:
	.asciz "in ;\n"

.p2align 2


// _colon (:) - enter compile mode
_colon:
	str lr, [sp, #-16]!

	


	mov FLAGS, COMPILE_MODE

	ldr lr, [sp], #16
	ret

// _semicolon (;) - exit compile mode
// Write a pointer to end2d's word address as last entry in secondary
//
_semicolon:
	str lr, [sp, #-16]!

	LOAD_ADDRESS x0, end2d_wordAddress
	str x0, [SEC_SPACE], #8

	mov FLAGS, RUN_MODE

	ldr lr, [sp], #16
	ret

// _push - push the following word on the stack
// Input: x20 - VPC pointing to data vaue (in secondary)
// Process:
// Output:
//   X19 - VSP, updated as value was pushed
//   x20 - VPC, updated to word after data value
//
_push:
	ldr x0, [VPC], #8
	DATA_PUSH x0
	ret


push1:
	mov x0, #1
	DATA_PUSH x0
	ret


// dup - duplicate the item on top of the data stack
// Input: x19, VSP points to top of stack
// Output:
//   stack has top element duplicated
//   x19 increased
//
dup:
	DATA_TOP x0
	DATA_PUSH x0
	ret

// add - replace top two a,b with b+a
// Input: Data stack with two values on top
// Process: x0, x1 - temp
// Output: Data stack has two values replaced by sum
add:
	DATA_POP_AB x1, x0
	add x0, x0, x1
	DATA_PUSH x0
	ret

// sub - replace top a,b with b-a
// Input: Data stack with two values on top
// Process: x0, x1 - temp
// Output: Data stack has popped two values and pushed their difference
sub:
	DATA_POP_AB x1, x0
	sub x0, x0, x1
	DATA_PUSH x0
ret

// mul - replace top a,b with b*a
// Input: Data stack with two values on top
// Process: x0, x1 - temp
// Output: Data stack has popped two values and pushed their product
mul:
	DATA_POP_AB x1, x0
	mul x0, x0, x1
	DATA_PUSH x0
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
