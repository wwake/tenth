.include "assembler.macros"
.include "unix_functions.macros"
.include "dictionary.macros"

.global _start

.text
.align 2

_start:
	str lr, [sp, #-16]!
	str x10, [sp, #8]

	// Initialize stack
	bl data_stack_init

	// Initialize dictionary
	bl dict_init
	DICT_HEADER "1", push1
	DICT_HEADER "add", add
	DICT_HEADER "dup", dup
	DICT_HEADER "nl", nl
	DICT_HEADER "sub", sub

	// Initialize registers

	// Run
	bl repl

	ldr x10, [sp, #8]
	ldr lr, [sp], #16

	ret
