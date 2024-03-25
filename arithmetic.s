#include "core.defines"
#include "assembler.macros"

.global add
.global sub
.global mul


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
