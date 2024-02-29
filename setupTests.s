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
	bl adding_to_dictionary_adds_item

	unix_exit
	ldr lr, [sp], #16
ret

.data
.p2align 3

systemDictionary:
	.quad 0
	.quad 0
	.quad 0

	.fill 300, 8, 0
.text

.macro DICT_ENTRY name, codeAddress
	mov x0, x21
	add x21, x21, #24

	str x0, [x21]

	LOAD_ADDRESS x0, L_dict_entry_\@
	str x0, [x21, #8]

	LOAD_ADDRESS x0, \codeAddress
	str x0, [x21, #16]


	.data
L_dict_entry_\@: .asciz "\name"
	.text
.endm

dict_init:

	LOAD_ADDRESS x21, systemDictionary
	ret


.text

TEST_START empty_dictionary_has_zeros
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


.data
.p2align 3
L_nl_string: .asciz "nl"

.text
TEST_START adding_to_dictionary_adds_item
	// Arrange:
	bl dict_init

	// Act:
	DICT_ENTRY "nl", nl

	// Assert:
	mov x0, x21
	LOAD_ADDRESS x1, systemDictionary
	add x1, x1, #24
	bl assertEqual

	ldr x0, [x21]
	LOAD_ADDRESS x1, systemDictionary
	bl assertEqual

	ldr x0, [x21, #8]
	LOAD_ADDRESS x1, L_nl_string
	bl streq
	mov x1, #1
	bl assertEqual

	ldr x0, [x21, #16]
	LOAD_ADDRESS x1, nl
	bl assertEqual
TEST_END
