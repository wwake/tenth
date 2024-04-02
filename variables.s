#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"

.global loadAddress

.global variable
.global at
.global assign

.global array
.global array_at

.text
.align 2


// loadAddress - given address of secondary, push the following address
// Input: x0 = address of secondary
//
loadAddress:
	add x0, x0, #8
	DATA_PUSH x0
	ret


// Variable - meta word that takes the following name and makes a
//   passive word for it.
//
variable:
	STD_PROLOG

	bl readWord
	bl define_word

	LOAD_ADDRESS x0, loadAddress
	STORE_SEC x0

	STORE_SEC xzr

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

	bl variable

	DATA_POP x0		// number of cells

	// write n-1 zeroes to secondary
array_loop:
		sub x0, x0, #1
		cmp x0, #0
		b.eq array_after
		STORE_SEC xzr
	b array_loop

array_after:
	STD_EPILOG
	ret


// array_at - pop index and address, push mem[address + 8 * index]
//
array_at:
	DATA_POP x1  // index
	DATA_POP x2  // variable address
	ldr x0, [x2, x1, lsl #3]
	DATA_PUSH x0
	ret
