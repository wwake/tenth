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
	ret
