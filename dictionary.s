.include "assembler.macros"
.include "unix_functions.macros"
.include "asUnit.macros"
.include "dictionary.macros"

.global systemDictionary
.global dict_init
.global dict_search

.global metaNext
.global metaList

.data
.p2align 3

systemDictionary:
	.quad 0
	.quad 0
	.quad 0

	.fill 300, 8, 0


metaNext:		// pointer to next slot in metaList
	.quad 0

metaList:
	.fill 160, 8, 0

.text

dict_init:
	LOAD_ADDRESS x21, systemDictionary

	LOAD_ADDRESS x0, metaNext
	LOAD_ADDRESS x1, metaList
	str x1, [x0]
	ret


// dict_search: try to find string in dictionary
// Inputs:
//   x0 - address of search string
// Uses:
//   x22 - temp to walk through dictionary
//   x11 - holds address of search string
// Outputs:
//   0 if not found, -or-
//   word address of found entry

dict_search:
	str lr, [sp, #-16]!
	str x22, [sp, #8]
	str x11, [sp, #-16]!

	mov x11, x0   // hold addr of target
	mov x22, x21  // ptr to search dict.

L_keep_looking:
	LOAD_ADDRESS x1, systemDictionary
	cmp x22, x1		// at end of dict.?
	b.eq L_not_found

	mov x0, x11		// match?
	ldr x1, [x22, #8]
	bl streq

	cmp x0, #1
	b.eq L_found
		ldr x22, [x22]	// move to next
	b L_keep_looking	// repeat

L_found:
	add x0, x22, #16 // return word addr.
	b L_exit_search

L_not_found:
	mov x0, #0		// return 0 on fail

L_exit_search:
	ldr x11, [sp], #16
	ldr x22, [sp, #8]
	ldr lr, [sp], #16
	ret
