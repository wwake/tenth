#include "core.defines"
#include "assembler.macros"

.global andRoutine
.global orRoutine

.text

// and - replace top two a,b with b&a
// Input: Data stack with two values on top
// Process: x0, x1 - temp
// Output: Data stack has two values replaced by logical and
andRoutine:
	DATA_POP_AB x1, x0
	and x0, x0, x1
	DATA_PUSH x0
	ret

// or - replace top two a,b with b|a
// Input: Data stack with two values on top
// Process: x0, x1 - temp
// Output: Data stack has two values replaced by logical or
orRoutine:
	DATA_POP_AB x1, x0
	orr x0, x0, x1
	DATA_PUSH x0
	ret
