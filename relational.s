#include "core.defines"
#include "assembler.macros"

.global neq
.global eq
.global lt
.global le
.global gt
.global ge

.text
.p2align 2

.macro BINARY_RELOP name, condition, description
\name:
	DATA_POP_AB x1, x0
	cmp x0, x1
	cset x0, \condition
	DATA_PUSH x0
	ret
.endm

BINARY_RELOP eq, eq, "equals"
BINARY_RELOP neq, ne, "not equals"
BINARY_RELOP lt, lt, "less than"
BINARY_RELOP le, le, "less than or equals"
BINARY_RELOP gt, gt, "greater than"
BINARY_RELOP ge, ge, "greater than or equals"
