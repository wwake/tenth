#include "core.defines"
#include "assembler.macros"

.include "repl.macros"


.global _colon
.global _semicolon

.text
.p2align 2


// _colon (:) - enter compile mode
_colon:
	STD_PROLOG

	// Read the word to be defined
	bl readWord

	// Put word string after last secondary
	mov x1, SEC_SPACE
	bl strcpyz

	// Adjust SEC_SPACE to a 64-bit boundary
	mov x0, SEC_SPACE
	bl strlen
	add x0, x0, #8
	and x0, x0, #-8

	mov x1, SEC_SPACE
	add SEC_SPACE, SEC_SPACE, x0

	// Put old dictionary at first slot; update dictionary
	STORE_SEC SYS_DICT
	sub SYS_DICT, SEC_SPACE, #8

	// Put pointer to word string in 2d slot
	STORE_SEC x1

	// Put pointer to start2d in the third slot
	LOAD_ADDRESS x0, start2d
	STORE_SEC x0

	// Change to Compile mode
	mov FLAGS, COMPILE_MODE

	STD_EPILOG
	ret

// _semicolon (;) - exit compile mode
// Write a pointer to end2d's word address as last entry in secondary
//
_semicolon:
	STD_PROLOG

	LOAD_ADDRESS x0, end2d_wordAddress
	str x0, [SEC_SPACE], #8

	mov FLAGS, RUN_MODE

	STD_EPILOG
	ret

