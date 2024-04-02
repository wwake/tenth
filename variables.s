#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"

.global loadAddress
.global variable

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
