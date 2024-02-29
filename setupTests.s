.include "assembler.macros"
.include "unix_functions.macros"
.include "asUnit.macros"

.global _start

.text
.p2align 2

_start:
	str lr, [sp, #-16]!

	TEST_ALL "setupTests"

	bl empty_dictionary_has_zeros

	unix_exit
	ldr lr, [sp], #16
ret

.data
.p2align 3

systemDictionary:
	.quad 0
	.quad 0
	.quad 0

.text
dict_init:

	LOAD_ADDRESS x21, systemDictionary
	ret


.text

TEST_START empty_dictionary_has_zeros
	// Arrange:

	// Act:
	bl dict_init

	// Assert:
	mov x0, x21
	LOAD_ADDRESS x1, systemDictionary
	bl assertEqual

	ldr x0, [x21]
	mov x1, #0
	bl assertEqual
TEST_END

