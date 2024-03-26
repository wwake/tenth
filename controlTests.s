#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "asUnit.macros"
.include "coreTests.macros"

.global _start


.p2align 2

_start:
	STD_PROLOG

	TEST_ALL "controlTests"

	bl if_zero_does_not_jump_for_non_zero_value
	bl if_zero_jumps_for_zero_value

	bl jump_skips_over_code

	unix_exit
	STD_EPILOG
	ret

.data
.p2align 8

debugData:
L_test_dictionary:
	.quad 1
	.quad 2
	.quad 3
	.quad 5
	.quad 7
	.quad 11
	.quad 13
	.quad 17

L_test_secondary:
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0
	.quad 0

.text


TEST_START if_zero_does_not_jump_for_non_zero_value
// Arrange
	DICT_START L_test_dictionary
	DICT_ADD _jump_if_false	// 0
	DICT_ADD _push			// 1
	DICT_ADD end2d			// 2

	SECONDARY_START L_test_secondary, L_test_dictionary, start2d
	SECONDARY_ADD 1
	SECONDARY_DATA #7
	SECONDARY_ADD 0
	SECONDARY_TARGET 7
	SECONDARY_ADD 1
	SECONDARY_DATA #42
	SECONDARY_ADD 2

// Act
	LOAD_ADDRESS x0, L_test_secondary
	bl runInterpreter

// Assert
	DATA_TOP x0
	mov x1, #42
	bl assertEqual
TEST_END

TEST_START if_zero_jumps_for_zero_value
	// Arrange
	DICT_START L_test_dictionary
	DICT_ADD _jump_if_false
	DICT_ADD _push
	DICT_ADD end2d

	SECONDARY_START L_test_secondary, L_test_dictionary, start2d
	SECONDARY_ADD 1
	SECONDARY_DATA #0
	SECONDARY_ADD 0
	SECONDARY_TARGET 7
	SECONDARY_ADD 1
	SECONDARY_DATA #42
	SECONDARY_ADD 2

// Act
	LOAD_ADDRESS x0, L_test_secondary
	bl runInterpreter

// Assert
	mov x0, VSP
	LOAD_ADDRESS x1, data_stack
	bl assertEqual			// check that VSP is back to original place
TEST_END


TEST_START jump_skips_over_code
// Arrange
	DICT_START L_test_dictionary
	DICT_ADD _jump  //0
	DICT_ADD _push  //1
	DICT_ADD end2d  //2

	SECONDARY_START L_test_secondary, L_test_dictionary, start2d
	SECONDARY_ADD 0
	SECONDARY_TARGET 5
	SECONDARY_ADD 1
	SECONDARY_DATA #17
	SECONDARY_ADD 2

	// Act
	LOAD_ADDRESS x0, L_test_secondary
	bl runInterpreter

// Assert
	mov x0, VSP
	LOAD_ADDRESS x1, data_stack
	bl assertEqual			// check that VSP is back to original place
TEST_END