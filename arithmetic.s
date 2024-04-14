#include "core.defines"
#include "assembler.macros"

.global add
.global sub
.global mul
.global div
.global mod
.global divmod

.global min
.global max

.global neg
.global abs

.global random


.text
.align 2

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


// div - replace top a,b with b/a (signed integer division)
// Input: Data stack with two values on top
// Process: x0, x1 - temp
// Output: Data stack has popped two values and pushed their dividend
div:
	DATA_POP_AB x1, x0
	sdiv x0, x0, x1
	DATA_PUSH x0
	ret


// mod - replace top a,b with b%a (signed mod)
// Input: Data stack with two values on top
// Process: x0, x1 - temp
// Output: Data stack has popped two values and pushed their remainder
mod:
	DATA_POP_AB x1, x0
	sdiv x2, x0, x1
	msub x0, x1, x2, x0
	DATA_PUSH x0
	ret


// min - replace top a,b with min(b,a)
// Input: Data stack with two values on top
// Process: x0, x1 - temp
// Output: Data stack has popped two values and pushed their minimum
min:
	DATA_POP_AB x1, x0
	cmp x0, x1
	csel x0, x0, x1, LE
	DATA_PUSH x0
	ret


// max - replace top a,b with max(b,a)
// Input: Data stack with two values on top
// Process: x0, x1 - temp
// Output: Data stack has popped two values and pushed their maximum
max:
	DATA_POP_AB x1, x0
	cmp x0, x1
	csel x0, x0, x1, GE
	DATA_PUSH x0
	ret


// divmod - replace a,b,c with (a%b)(a/b)c
// Input: Data stack with two values on top
// Process: x0, x1 - temp
// Output: Data stack has popped two values and pushed their quotient then remainder
divmod:
	DATA_POP_AB x1, x0
	sdiv x2, x0, x1
	msub x0, x1, x2, x0
	DATA_PUSH x2
	DATA_PUSH x0
	ret

// neg - replace a,b with (-a)b
// Input: Data stack with two values on top
// Process: x0 - temp
// Output: Data stack has replaced top value with its negative
neg:
	DATA_POP x0
	neg x0, x0
	DATA_PUSH x0
	ret

// abs - replace a,b with (|a|)b
// Input: Data stack with two values on top
// Process: x0 - temp
// Output: Data stack has replaced top value with its absolute value
abs:
	DATA_POP x0
	cmp x0, #0
	csneg x0, x0, x0, GE
	DATA_PUSH x0
	ret



.data

L_seed:
	.quad 3459173429

.text
.align 2

// random - replace a with random number in range 0..<a
// Input: a = max of range
// Output: top of stack = number in range 0..<a
random:
	STD_PROLOG

	LOAD_ADDRESS x0, L_seed
	ldr x1, [x0]

	// equivalent to "mov w2, #910230123"
	// Add "weird" number -> random-ish
	mov w2, #0x026b
	movk w2, #0x3641, lsl #16

	add w1, w1, w2
	str x1, [x0]	// save last generated

	DATA_PUSH x1	// push random #

	bl swap			// swap random and modulo base
	bl mod			// modulo

	STD_EPILOG
	ret
