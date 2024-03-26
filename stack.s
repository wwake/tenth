#include "core.defines"
#include "assembler.macros"

.global data_stack
.global data_stack_init

.global _push_word_address
.global _push
.global push0
.global push1

.global dup


.equ DATA_STACK_SIZE, 10000

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


// _push - push the following word on the stack
// Input: VPC (register), pointing to data vaue (in secondary)
// Process:
// Output:
//   VSP (register), updated as value was pushed
//   VPC (register), updated to word after data value
//
.data
.p2align 3
_push_word_address:
	.quad _push

.text
.align 2

_push:
	ldr x0, [VPC], #8
	DATA_PUSH x0
	ret

push0:
	DATA_PUSH xzr
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

