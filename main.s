#include "core.defines"
#include "assembler.macros"
#include "dictionary.macros"

.include "unix_functions.macros"

.global _start

.text
.align 2

_start:
	STD_PROLOG
	str x22, [sp, #8]

	bl data_stack_init

	bl L_sec_space_init

	bl L_load_system_dictionary

	bl L_error_handler_init

	// Run
	bl repl

	ldr x22, [sp, #8]
	STD_EPILOG

	ret


L_sec_space_init:
	// Setup SEC_SPACE
	LOAD_ADDRESS SEC_SPACE, L_secondary_space
	ret

L_load_system_dictionary:
	STD_PROLOG

	bl dict_init
	DICT_HEADER "0", push0
	DICT_HEADER "1", push1

	DICT_HEADER "dup", dup
	DICT_HEADER "neq", neq
	DICT_HEADER "nl", nl

	DICT_HEADER "+", add
	DICT_HEADER "-", sub
	DICT_HEADER "*", mul
	
	DICT_HEADER ":", _colon, META
	DICT_HEADER ";", _semicolon, META
	DICT_HEADER ".", dotprint
	DICT_END

	STD_EPILOG

	ret


L_error_handler_init:
	LOAD_ADDRESS x0, global_word_not_found_handler
	LOAD_ADDRESS x1, wordNotFoundError
	str x1, [x0]
	ret

.data
L_secondary_space:
	.fill 20000, 8, 0
