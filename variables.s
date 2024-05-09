#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"

.global loadAddress

.global variable
.global at
.global assign

.global array
.global array_at
.global array_assign

.text
.align 2


// loadAddress - given address of secondary, push the following address
// Input: x0 = address of secondary
//
loadAddress:
	add x0, x0, #16		// skip over size value
	DATA_PUSH x0
	ret


// make_passive_word - read word and make passive word
// Inputs: x0=size of array (1 for a simple variable) [secondary space is implicit]
make_passive_word:
	STD_PROLOG
	str x28, [sp, #8]
	mov x28, x0

	bl readWord
	bl define_word

	LOAD_ADDRESS x0, loadAddress
	STORE_SEC x0

	STORE_SEC x28
	STORE_SEC xzr

	ldr x28, [sp, #8]
	STD_EPILOG
	ret

// Variable - meta word that takes the following name and makes a
//   passive word for it.
//
variable:
	STD_PROLOG

	mov x0, #1
	bl make_passive_word

	STD_EPILOG
	ret


// At - pop address of variable, push its contents
//
at:
	DATA_POP x0
	ldr x0, [x0]
	DATA_PUSH x0
	ret


// Assign - pop value, then pop address of variable, store value at variable
//
assign:
	DATA_POP x1
	DATA_POP x2
	str x1, [x2]
	ret


// Array - pop value, use that as number of cells to create. a array name - creates header for name as a variable
//
array:
	STD_PROLOG
	str x28, [sp, #8]

	DATA_POP x28	// number of cells
	mov x0, x28

	bl make_passive_word	// make header

	// write n-1 zeroes to secondary

array_loop:
		sub x28, x28, #1
		cmp x28, #0
		b.eq array_after
		STORE_SEC xzr
	b array_loop

array_after:
	ldr x28, [sp, #8]
	STD_EPILOG
	ret


// array_at - pop index and address, push mem[address + 8 * index]
//
array_at:
	DATA_POP x1  // index
	DATA_POP x2  // variable address
	sub x3, x2, #8			// count precedes array
	ldr x3, [x3]	// count
	sub x3, x3, #1
	cmp x1, x3
	b.ls L_access_array
		mov x1, 0
L_access_array:
	ldr x0, [x2, x1, lsl #3]
	DATA_PUSH x0
	ret


// array_assign - pop value, index, and address; store mem[address + 8 * index] = value
//
array_assign:
	DATA_POP x1		// value
	DATA_POP x2		// index
	DATA_POP x3		// address
	str x1, [x3, x2, lsl #3]
	ret
