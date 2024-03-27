#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "asUnit.macros"
.include "coreTests.macros"
.include "repl.macros"

.global _start


.p2align 2

_start:
	STD_PROLOG

	TEST_ALL "compileTests"

	// Definition
	bl colon_switches_to_compile_mode
	bl colon_writes_header_to_secondary

	bl semicolon_switches_to_run_mode
	bl semicolon_writes_end2d_in_secondary

	unix_exit
	STD_EPILOG
	ret
	

TEST_START colon_switches_to_compile_mode
	// Arrange:
	LOAD_ADDRESS SEC_SPACE, L_test_secondary_area
	LOAD_ADDRESS READ_LINE_ROUTINE, L_readWords

	mov FLAGS, RUN_MODE

	// Act:
	bl _colon

	// Assert:
	mov x0, FLAGS
	mov x1, COMPILE_MODE
	bl assertEqual
TEST_END

.data
.p2align 3

L_test_secondary_area:
	.fill 16, 8, 0

.p2align 3
L_colon_test_string:
	.asciz "xy34567 "

L_colon_test_string_final:
	.asciz "xy34567"

.text
.align 2
// L_readWords - read words for test
// Input: x0=#0, x1=addr of buffer, x2=#chars max to read
//
L_readWords:
	STD_PROLOG

	// Copy test string to real inputBuffer
	LOAD_ADDRESS x0, L_colon_test_string
	LOAD_ADDRESS x1, inputBuffer
	bl strcpyz

	STD_EPILOG
	ret

TEST_START colon_writes_header_to_secondary
	// Arrange:
	LOAD_ADDRESS SEC_SPACE, L_test_secondary_area
	LOAD_ADDRESS READ_LINE_ROUTINE, L_readWords
	mov SYS_DICT, #800	// starting dictionary

	// Act:
	bl _colon

	// Assert: String was written to dictionary
	LOAD_ADDRESS x0, L_test_secondary_area
	LOAD_ADDRESS x1, L_colon_test_string_final
	bl assertEqualStrings

	// Assert: SEC_SPACE was adjusted to the right boundary
	// That's 8 bytes for the string, 3*8 bytes for the header cells
	mov x0, SEC_SPACE
	LOAD_ADDRESS x1, L_test_secondary_area
	add x1, x1, #32
	bl assertEqual

	// Assert: First cell is pointer to old dictionary
	LOAD_ADDRESS x0, L_test_secondary_area
	add x0, x0, #8
	ldr x0, [x0]
	mov x1, #800		// starting dictionary
	bl assertEqual

	// Assert: Dictionary pointer should be updated
	mov x0, SYS_DICT
	LOAD_ADDRESS x1, L_test_secondary_area
	add x1, x1, #8
	bl assertEqual

	// Assert: Second cell is pointer to new string
	ldr x0, [SYS_DICT, #8]
	LOAD_ADDRESS x1, L_test_secondary_area
	bl assertEqual

	// Assert: Third cell points to start2d
	ldr x0, [SYS_DICT, #16]
	LOAD_ADDRESS x1, start2d
	bl assertEqual
TEST_END


TEST_START semicolon_switches_to_run_mode
	// Arrange:
	LOAD_ADDRESS SEC_SPACE, L_test_secondary_area

	mov FLAGS, COMPILE_MODE

	// Act:
	bl _semicolon

	// Assert:
	mov x0, FLAGS
	mov x1, RUN_MODE
	bl assertEqual
TEST_END


.text
.align 2

TEST_START semicolon_writes_end2d_in_secondary
	// Arrange:
	LOAD_ADDRESS SEC_SPACE, L_test_secondary_area

	// Act:
	bl _semicolon

	// Assert:
	// Check that cell gets end2d's word address
	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0]
	ldr x0, [x0]
	LOAD_ADDRESS x1, end2d_wordAddress
	ldr x1, [x1]
	bl assertEqual

	// Check that SEC_SPACE moved forward after writing
	mov x0, SEC_SPACE
	LOAD_ADDRESS x1, L_test_secondary_area
	add x1, x1, #8
	bl assertEqual
TEST_END
