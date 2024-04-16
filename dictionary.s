#include "core.defines"
#include "assembler.macros"
#include "dictionary.macros"

.include "unix_functions.macros"
.include "asUnit.macros"

.global systemDictionary
.global dict_init
.global dict_search

.global metaNext
.global metaList
.global isMeta

.data
.p2align 3

systemDictionary:
	.quad 0
	.quad 0
	.quad 0

	.fill 800, 8, 0


metaNext:		// pointer to next slot in metaList
	.quad 0

metaList:
	.fill 160, 8, 0

.text

dict_init:
	LOAD_ADDRESS SYS_DICT, systemDictionary

	LOAD_ADDRESS x0, metaNext
	LOAD_ADDRESS x1, metaList
	str x1, [x0]
	ret


// dict_search: try to find string in dictionary
// Inputs:
//   x0 - address of search string
// Uses:
//   x28 - temp to walk through dictionary
//   x11 - temp - holds address of search string
// Outputs:
//   x0 = 0 if not found, -or-
//   word address of found entry

dict_search:
	STD_PROLOG
	str x28, [sp, #8]
	str x11, [sp, #-16]!

	mov x11, x0   // hold addr of target
	mov x28, SYS_DICT

L_keep_looking:
	LOAD_ADDRESS x1, systemDictionary
	cmp x28, x1		// at end of dict.?
	b.eq L_not_found

	mov x0, x11		// match?
	ldr x1, [x28, #8]
	bl streq

	cmp x0, #1
	b.eq L_found
		ldr x28, [x28]	// move to next
	b L_keep_looking	// repeat

L_found:
	add x0, x28, #16 // return word addr.
	b L_exit_search

L_not_found:
	mov x0, #0		// return 0 on fail

L_exit_search:
	ldr x11, [sp], #16
	ldr x28, [sp, #8]
	STD_EPILOG
	ret


// isMeta - search for string in meta list; return 0 if missing, 1 if found
// Input: x0 - pointer to string to search for
//        x1 - type of input (word, number, or string)
// Output: x0 is 0 or 1 (false or true)
//
isMeta:
	STD_PROLOG
	str x28, [sp, #8]
	str x27, [sp, #-16]!

	// Strings cannot be meta - return 0
	cmp x1, STRING_FOUND
	b.ne L_meta_start_looking
		mov x0, #0
	b L_isMetaEnd

L_meta_start_looking:
	mov x27, x0
	LOAD_ADDRESS x28, metaList

L_meta_keep_looking:
	ldr x1, [x28]
	cmp x1, #0
	b.ne L_compare_string
		mov x0, #0
		b L_isMetaEnd

L_compare_string:
	bl streq
	cmp x0, #0
	b.ne L_meta_found
		add x28, x28, #8
		mov x0, x27
		b L_meta_keep_looking

L_meta_found:
	mov x0, #1

L_isMetaEnd:
	ldr x27, [sp], #16
	ldr x28, [sp, #8]
	STD_EPILOG
	ret
