.include "assembler.macros"
.include "unix_functions.macros"
.include "dictionary.macros"

.global _start

.text
.align 2

_start:
	str lr, [sp, #-16]!
	str x22, [sp, #8]

	bl data_stack_init

	bl L_load_system_dictionary

	// Initialize registers
	// TBD

	// Run
	bl repl

	ldr x22, [sp, #8]
	ldr lr, [sp], #16

	ret


L_load_system_dictionary:
	str lr, [sp, #-16]!

	bl dict_init
	DICT_HEADER "_wordNotFoundError", wordNotFoundError
	DICT_HEADER "1", push1
	DICT_HEADER "add", add
	DICT_HEADER "dup", dup
	DICT_HEADER "mul", mul
	DICT_HEADER "neq", neq
	DICT_HEADER "nl", nl
	DICT_HEADER "sub", sub

	ldr lr, [sp], #16

	ret
