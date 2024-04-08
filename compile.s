#include "core.defines"
#include "assembler.macros"

.include "repl.macros"

.global sec_space_init
.global define_string
.global define_word
.global colon
.global semicolon

.data
.p2align 3

L_secondary_space:
	.fill 20000, 8, 0


.text
.p2align 2

sec_space_init:
	// Setup SEC_SPACE
	LOAD_ADDRESS SEC_SPACE, L_secondary_space
	ret


// define_string:
// Input: x0 = ptr to string
// Effect: store word string to secondary, 
//   adjust SEC_SPACE to a 64-bit boundary
define_string:
	STD_PROLOG

	// Put word string after last secondary
	mov x1, SEC_SPACE
	bl strcpyz

	// Adjust SEC_SPACE to a 64-bit boundary
	mov x0, SEC_SPACE
	bl strlen
	add x0, x0, #8
	and x0, x0, #-8

	add SEC_SPACE, SEC_SPACE, x0

	STD_EPILOG
	ret


// define_word:
// Input: x0 = ptr to word string
// Effects: store word string to secondary, create first two slots of header
//   (ptr to previous dictionary, ptr to word string)
//   DICT_PTR is updated, SEC_SPACE points to not-yet-filled third slot of header
//
define_word:
	STD_PROLOG
	str x28, [sp, #8]

	mov x28, SEC_SPACE	// save old value of SEC_SPACE for string pointer

	bl define_string

	// Put old dictionary at first slot; update dictionary
	STORE_SEC SYS_DICT
	sub SYS_DICT, SEC_SPACE, #8

	// Put pointer to word string in 2d slot
	STORE_SEC x28

	ldr x28, [sp, #8]
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

