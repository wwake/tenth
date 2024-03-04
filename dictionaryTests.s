.include "assembler.macros"
.include "unix_functions.macros"
.include "asUnit.macros"
.include "dictionary.macros"

.global _start

.text
.p2align 2

_start:
	str lr, [sp, #-16]!

	TEST_ALL "dictionaryTests"

	bl empty_dictionary_has_zeros

	bl adding_to_dictionary_adds_item

	bl search_empty_dictionary
	bl search_word_found_returns_word_address
	bl search_word_not_found_returns_0

	unix_exit
	ldr lr, [sp], #16
ret

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
	DICT_HEADER "nl", nl

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

TEST_START search_empty_dictionary
	// Arrange:
	bl dict_init

	// Act:
	LOAD_ADDRESS x0, L_nl_string
	bl dict_search

	// Assert:
	mov x1, #0
	bl assertEqual
TEST_END

TEST_START search_word_not_found_returns_0
	// Arrange:
	bl dict_init
	DICT_HEADER "add", add
	DICT_HEADER "sub", sub

	// Act:
	LOAD_ADDRESS x0, L_nl_string
	bl dict_search

	// Assert:
	mov x1, #0
	bl assertEqual
TEST_END

TEST_START search_word_found_returns_word_address
	// Arrange:
	bl dict_init
	DICT_HEADER "add", add
	DICT_HEADER "nl", nl
	DICT_HEADER "sub", sub

	// Act:
	LOAD_ADDRESS x0, L_nl_string
	bl dict_search

	// Assert:
	add x1, x21, #-8
	bl assertEqual
TEST_END
