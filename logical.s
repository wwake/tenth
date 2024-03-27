#include "core.defines"
#include "assembler.macros"

.global andRoutine
.global orRoutine
.global xorRoutine
.global notRoutine
.global bangRoutine

.text

.align 2

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

// xor - replace top two a,b with b^a
// Input: Data stack with two values on top
// Process: x0, x1 - temp
// Output: Data stack has two values replaced by logical xor
xorRoutine:
	DATA_POP_AB x1, x0
	eor x0, x0, x1
	DATA_PUSH x0
	ret

// not - replace top value with ~a
// Input: Data stack with one value on top
// Process: x0 - temp
// Output: Data stack has one values replaced by logical not
notRoutine:
	DATA_POP x0
	mvn x0, x0
	DATA_PUSH x0
	ret


// bang - replace top value with !a  (0=>1, non-zero=>0)
// Input: Data stack with one value on top
// Process: x0 - temp
// Output: Data stack has value a replaced by !a
bangRoutine:
	DATA_POP x0
	CMP x0, #0
	cset x0, eq
	DATA_PUSH x0
	ret
