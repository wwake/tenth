#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "asUnit.macros"
.include "coreTests.macros"

.global _start

.text
.p2align 2

_start:
	STD_PROLOG

	TEST_ALL "variablesTests"

	bl loadAddress_pushes_address_of_secondary
	bl variable_writes_header_and_value_to_secondary
	bl at_replaces_variable_with_value
	bl assign_stores_a_at_b

	bl array_writes_header_and_values_to_secondary
	bl array_at_replaces_variable_and_index_with_value

	unix_exit
	STD_EPILOG
	ret

.data
.p2align 3

L_test_address:
	.quad 0

.text
.align 2


TEST_START loadAddress_pushes_address_of_secondary
	// Arrange:
	LOAD_ADDRESS x0, L_test_address

	// Act
	bl loadAddress

	// Assert:
	DATA_POP x0
	LOAD_ADDRESS x1, L_test_address
	add x1, x1, #8
	bl assertEqual
TEST_END



.data
.p2align 3

L_test_secondary_area:
	.fill 16, 8, 0

.p2align 3
L_variable_test_string:
	.asciz "name "

L_variable_test_string_final:
	.asciz "name"


// variable name -> creates name as a variable with default value 0

// Structure in secondary space:
// 0: name string
// 8: ptr to previous dictionary
// 16: ptr to named string
// 24: ptr to routine to run
// 32: 0 = default value
// 40:

.text
.align 2
// L_readWords - read words for test
// Input: x0=#0, x1=addr of buffer, x2=#chars max to read
//
L_readWords:
	STD_PROLOG

	// Copy test string to real inputBuffer
	LOAD_ADDRESS x0, L_variable_test_string
	LOAD_ADDRESS x1, inputBuffer
	bl strcpyz

	STD_EPILOG
	ret

TEST_START variable_writes_header_and_value_to_secondary
	// Arrange:
	LOAD_ADDRESS SEC_SPACE, L_test_secondary_area
	LOAD_ADDRESS READ_LINE_ROUTINE, L_readWords
	mov SYS_DICT, #800	// starting dictionary

	// Act:
	bl variable

	// Assert: String was written to dictionary
	LOAD_ADDRESS x0, L_test_secondary_area
	LOAD_ADDRESS x1, L_variable_test_string_final
	bl assertEqualStrings

	// Assert: SEC_SPACE was adjusted to the right boundary
	// That's 8 bytes for the string, 3*8 bytes for the header cells, 8 bytes for the variable initial value
	mov x0, SEC_SPACE
	LOAD_ADDRESS x1, L_test_secondary_area
	add x1, x1, #40
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

	// Assert: Third cell points to loadAddress
	ldr x0, [SYS_DICT, #16]
	LOAD_ADDRESS x1, loadAddress
	bl assertEqual

	// Assert: Fourth cell contains initial value (0)
	ldr x0, [SYS_DICT, #24]
	mov x1, #0
	bl assertEqual
TEST_END


.data
.p2align 3

L_at_variable:
	.quad 42
	.quad 2
	.quad 3

.text
.align 2

TEST_START at_replaces_variable_with_value
	// Arrange
	bl data_stack_init
	LOAD_ADDRESS x0, L_at_variable
	DATA_PUSH x0

	// Act
	bl at

	// Assert
	DATA_POP x0
	mov x1, #42
	bl assertEqual
TEST_END


TEST_START assign_stores_a_at_b
	// Arrange
	bl data_stack_init

	// Push guard value
	mov x0, #999
	DATA_PUSH x0

	// Push variable address on stack
	LOAD_ADDRESS x0, L_at_variable
	DATA_PUSH x0

	// Push value to assign
	mov x0, #27
	DATA_PUSH x0

	// Act
	bl assign

	// Assert
	// Right value stored to variable
	LOAD_ADDRESS x0, L_at_variable
	ldr x0, [x0]
	mov x1, #27
	bl assertEqual

	// Check that stack was popped twice
	DATA_POP x0
	mov x1, #999
	bl assertEqual
TEST_END


// number array name -> creates name as an array with number of cells
// defined by number on stack, default values all 0

// Structure in secondary space:
// 0: name string
// 8: ptr to previous dictionary
// 16: ptr to named string
// 24: ptr to routine to run
// 32: 0 = default value
// 40: 0
// 48: 0
// 56:


TEST_START array_writes_header_and_values_to_secondary
	// Arrange:
	bl data_stack_init

	LOAD_ADDRESS SEC_SPACE, L_test_secondary_area
	LOAD_ADDRESS READ_LINE_ROUTINE, L_readWords
	mov SYS_DICT, #800	// starting dictionary

	// Act:
	mov x0, #3
	DATA_PUSH x0

	bl array

	// Assert: String was written to dictionary
	LOAD_ADDRESS x0, L_test_secondary_area
	LOAD_ADDRESS x1, L_variable_test_string_final
	bl assertEqualStrings

	// Assert: SEC_SPACE was adjusted to the right boundary
	// That's 8 bytes for the string, 3*8 bytes for the header cells, 3*8 bytes for the variable initial value
	mov x0, SEC_SPACE
	LOAD_ADDRESS x1, L_test_secondary_area
	add x1, x1, #56
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

	// Assert: Third cell points to loadAddress
	ldr x0, [SYS_DICT, #16]
	LOAD_ADDRESS x1, loadAddress
	bl assertEqual

	// Assert: Fourth cell contains initial value (0)
	ldr x0, [SYS_DICT, #24]
	mov x1, #0
	bl assertEqual

	// Assert: Fifth cell contains initial value (0)
	ldr x0, [SYS_DICT, #32]
	mov x1, #0
	bl assertEqual

	// Assert: Sixth cell contains initial value (0)
	ldr x0, [SYS_DICT, #40]
	mov x1, #0
	bl assertEqual
TEST_END


TEST_START array_at_replaces_variable_and_index_with_value
	// Arrange
	bl data_stack_init

	mov x0, #999
	DATA_PUSH x0

	LOAD_ADDRESS x0, L_at_variable
	DATA_PUSH x0

	mov x1, #1
	DATA_PUSH x1

	// Act
	bl array_at

	// Assert
		// Check that returned value is right
	DATA_POP x0
	mov x1, #2
	bl assertEqual

		// Check that right values were popped
	DATA_POP x0
	mov x1, #999
	bl assertEqual
TEST_END


