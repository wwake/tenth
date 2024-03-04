.include "assembler.macros"
.include "unix_functions.macros"
.include "asUnit.macros"
.include "dictionary.macros"

.global systemDictionary
.global dict_init
.global dict_search

.data
.p2align 3

systemDictionary:
	.quad 0
	.quad 0
	.quad 0

	.fill 300, 8, 0

.text

dict_init:
	LOAD_ADDRESS x21, systemDictionary
	ret


// dict_search: try to find string in dictionary
// Inputs:
// 		x0 - address of search string
// Uses:
//   x10 - temp to walk through dictionary
//   x11 - holds address of search string
// Outputs:
//   0 if not found, -or-
//   word address of found entry

dict_search:
	str lr, [sp, #-16]!
	str x10, [sp, #8]
	str x11, [sp, #-16]!

	mov x11, x0
	mov x10, x21

L_keep_looking:
	LOAD_ADDRESS x1, systemDictionary
	cmp x10, x1
	b.eq L_not_found

	mov x0, x11
	ldr x1, [x10, #8]
	bl streq

	cmp x0, #1
	b.eq L_found
		ldr x10, [x10]
	b L_keep_looking

L_found:
	add x0, x10, #16
	b L_exit_search

L_not_found:
	mov x0, #0

L_exit_search:
	ldr x11, [sp], #16
	ldr x10, [sp, #8]
	ldr lr, [sp], #16
	ret
