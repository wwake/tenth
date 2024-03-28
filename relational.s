#include "core.defines"
#include "assembler.macros"

.global neq
.global eq

.text
.p2align 2

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

// eq - pop a, b and push replace top a,b with boolean
// Input: Data stack with two values on top
// Process: x0, x1 - temp
// Output: Data stack has popped two values and pushed 0 if equal else 1
//
eq:
	DATA_POP_AB x1, x0
	cmp x0, x1
	cset x0, eq
	DATA_PUSH x0
	ret
