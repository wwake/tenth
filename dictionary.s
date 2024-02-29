.include "assembler.macros"
.include "unix_functions.macros"
.include "asUnit.macros"
.include "dictionary.macros"

.global systemDictionary
.global dict_init

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


