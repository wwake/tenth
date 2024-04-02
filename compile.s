#include "core.defines"
#include "assembler.macros"

.include "repl.macros"


.global colon
.global semicolon
.global define_word

.text
.p2align 2

// define_word:
// Input: x0 = ptr to word string
// Effects: store word string to secondary, create first two slots of header
//   (ptr to previous dictionary, ptr to word string)
//   DICT_PTR is updated, SEC_SPACE points to not-yet-filled third slot of header
//
define_word:
	STD_PROLOG

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

	STD_EPILOG
	ret

// colon (:) - enter compile mode
colon:
	STD_PROLOG

	// Read the word to be defined
	bl readWord

	// Save word and create first two cells of header
	bl define_word

	// Put pointer to start2d in the third slot
	LOAD_ADDRESS x0, start2d
	STORE_SEC x0

	// Change to Compile mode
	mov FLAGS, COMPILE_MODE

	STD_EPILOG
	ret

// semicolon (;) - exit compile mode
// Write a pointer to end2d's word address as last entry in secondary
//
semicolon:
	STD_PROLOG

	LOAD_ADDRESS x0, end2d_wordAddress
	str x0, [SEC_SPACE], #8

	mov FLAGS, RUN_MODE

	STD_EPILOG
	ret

