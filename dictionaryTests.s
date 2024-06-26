#include "core.defines"
#include "dictionary.macros"
#include "assembler.macros"

.include "unix_functions.macros"
.include "asUnit.macros"

.global _start

.text
.p2align 2

_start:
	STD_PROLOG

	TEST_ALL "dictionaryTests"

	bl empty_dictionary_has_zeros

	bl adding_to_dictionary_adds_item
	bl adding_meta_to_dictionary
	bl isMeta_finds_only_metas
	bl isMeta_always_false_for_strings

	bl search_empty_dictionary
	bl search_word_found_returns_word_address
	bl search_word_not_found_returns_0

	unix_exit
	STD_EPILOG
ret

TEST_START empty_dictionary_has_zeros
	// Act:
	bl dict_init

	// Assert:
	mov x0, SYS_DICT
	LOAD_ADDRESS x1, systemDictionary
	bl assertEqual

	ldr x0, [SYS_DICT]
	mov x1, #0
	bl assertEqual
TEST_END


.data
.p2align 3
L_nl_string: .asciz "nl"
L_colon_string: .asciz ":"
L_semicolon_string: .asciz ";"
L_notmeta_string: .asciz "dup"

.text
TEST_START adding_to_dictionary_adds_item
	// Arrange:
	bl dict_init

	// Act:
	DICT_HEADER "nl", nl
	DICT_END

	// Assert:
	mov x0, SYS_DICT
	LOAD_ADDRESS x1, systemDictionary
	add x1, x1, #24
	bl assertEqual

	ldr x0, [SYS_DICT]
	LOAD_ADDRESS x1, systemDictionary
	bl assertEqual

	ldr x0, [SYS_DICT, #8]
	LOAD_ADDRESS x1, L_nl_string
	bl streq
	mov x1, #1
	bl assertEqual

	ldr x0, [SYS_DICT, #16]
	LOAD_ADDRESS x1, nl
	bl assertEqual
TEST_END

TEST_START adding_meta_to_dictionary
	// Arrange:
	bl dict_init

	// Act:
	DICT_HEADER ":", colon, META
	DICT_END

	// Assert:
	LOAD_ADDRESS x0, metaList
	ldr x0, [x0]
	LOAD_ADDRESS x1, L_colon_string
	bl assertEqualStrings

	LOAD_ADDRESS x0, metaNext
	ldr x0, [x0]
	LOAD_ADDRESS x1, metaList
	add x1, x1, #8
	bl assertEqual

	LOAD_ADDRESS x0, metaNext
	ldr x0, [x0]
	ldr x0, [x0]
	mov x1, #0
	bl assertEqual
TEST_END

TEST_START isMeta_finds_only_metas
	bl dict_init
	DICT_HEADER ":", colon, META
	DICT_HEADER ";", semicolon, META
	DICT_END

	LOAD_ADDRESS x0, L_colon_string
	mov x1, WORD_FOUND
	bl isMeta
	bl assertTrue

	LOAD_ADDRESS x0, L_semicolon_string
	mov x1, WORD_FOUND
	bl isMeta
	bl assertTrue

	LOAD_ADDRESS x0, L_notmeta_string
	mov x1, WORD_FOUND
	bl isMeta
	bl assertFalse
TEST_END

TEST_START isMeta_always_false_for_strings
	// Arrange
	bl dict_init
	DICT_HEADER ";", semicolon, META
	DICT_END

	LOAD_ADDRESS x0, L_semicolon_string
	mov x1, STRING_FOUND

	// Act
	bl isMeta

	// Assert
	bl assertFalse
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
	DICT_END

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
	DICT_END

	// Act:
	LOAD_ADDRESS x0, L_nl_string
	bl dict_search

	// Assert:
	add x1, SYS_DICT, #-8
	bl assertEqual
TEST_END
