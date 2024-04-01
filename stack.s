#include "core.defines"
#include "assembler.macros"

.global data_stack
.global data_stack_init

.global push_word_address
.global push
.global push0
.global push1

.global pop
.global dup
.global swap
.global cab

.global countData

.equ DATA_STACK_SIZE, 10000

.data
.p2align 3

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
push_word_address:
	.quad push

.text
.align 2

push:
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
// Input: VSP (register) points one past the top of stack
// Output:
//   stack has top element duplicated
//   VSP increased
//
dup:
	DATA_TOP x0
	DATA_PUSH x0
	ret



stack_count_label:
	.asciz "Stack size: "

stack_count_suffix:
	.asciz "\n"

.align 2

countData:
	STD_PROLOG

	LOAD_ADDRESS x0, stack_count_label
	bl print

	LOAD_ADDRESS x0, data_stack
	sub x0, VSP, x0
	asr x0, x0, #3
	bl printnum

	LOAD_ADDRESS x0, stack_count_suffix
	bl print

	STD_EPILOG
	ret


// Pop - pop top item on data stack
//
pop:
	DATA_POP x0
	ret

// Swap - swap top two items on stack
swap:
	DATA_POP_AB x0, x1
	DATA_PUSH x0
	DATA_PUSH x1
	ret

// CAB - put third item on top
cab:
	DATA_POP_ABC x0, x1, x2
	DATA_PUSH_ABC x2, x0, x1
	ret
