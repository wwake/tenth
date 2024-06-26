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

	bl repeat_until_generates_right_code
	bl nested_repeat_until_generates_right_code

	bl if_fi_generates_right_code
	bl if_else_fi_generates_right_code

	bl do_while_od_generates_right_code

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
// 		7 if 42 end
// Arrange
	DICT_START L_test_dictionary
	DICT_ADD jump_if_false	// 0
	DICT_ADD push			// 1
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
// 		0 if 42 end
	// Arrange
	DICT_START L_test_dictionary
	DICT_ADD jump_if_false
	DICT_ADD push
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
	DICT_ADD jump  //0
	DICT_ADD push  //1
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


.data
.p2align 3

L_test_secondary_area:
	.fill 16, 8, 0


.text
.align 2

// The contents at L_test_secondary_area + offset,
// should be address + offset2
.macro ASSERT_SEC_CONTENTS_ADDRESS offset, address, offset2=0
	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0, \offset]
	LOAD_ADDRESS x1, \address
	add x1, x1, \offset2
	bl assertEqual
.endm

TEST_START repeat_until_generates_right_code
	str x28, [sp, #8]

	// Arrange:
	LOAD_ADDRESS SEC_SPACE, L_test_secondary_area
	bl init_control_stack
	mov x28, CONTROL_STACK

	// Act:
	bl repeat

	bl until

	// Assert:
	ASSERT_SEC_CONTENTS_ADDRESS 0, jump_if_false_word_address

	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0]
	ldr x0, [x0]
	LOAD_ADDRESS x1, jump_if_false
	bl assertEqual

	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0, #8]
	mov x1, x0
	bl assertEqual

	// Make sure CONTROL_STACK is back where it started
	mov x0, CONTROL_STACK
	mov x1, x28
	bl assertEqual

	ldr x28, [sp, #8]
TEST_END

TEST_START nested_repeat_until_generates_right_code
	str x28, [sp, #8]

	// Arrange:
	LOAD_ADDRESS SEC_SPACE, L_test_secondary_area
	bl init_control_stack
	mov x28, CONTROL_STACK

	// Act:
	mov x0, #1		// @ space + 0
	STORE_SEC x0

	bl repeat

		mov x0, #2	// @ space + 8
		STORE_SEC x0

		bl repeat

		mov x0, #3	// @ space + 16
		STORE_SEC x0

		bl until

	bl until

	// Assert:
	ASSERT_SEC_CONTENTS_ADDRESS 24, jump_if_false_word_address

	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0, #32]
	LOAD_ADDRESS x1, L_test_secondary_area
	add x1, x1, #16
	bl assertEqual

	ASSERT_SEC_CONTENTS_ADDRESS 40, jump_if_false_word_address

	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0, #48]
	LOAD_ADDRESS x1, L_test_secondary_area
	add x1, x1, #8
	bl assertEqual

	// Make sure CONTROL_STACK is back where it started
	mov x0, CONTROL_STACK
	mov x1, x28
	bl assertEqual

	ldr x28, [sp, #8]
TEST_END

TEST_START if_fi_generates_right_code
	str x28, [sp, #8]

	// Arrange:
	LOAD_ADDRESS SEC_SPACE, L_test_secondary_area
	bl init_control_stack
	mov x28, CONTROL_STACK

	// Act:
	mov x0, #1		// @ space + 0
	STORE_SEC x0

	bl if

	mov x0, #2	// @ space + 24
	STORE_SEC x0

	bl fi

	mov x0, #3	// @ space + 32
	STORE_SEC x0

	// Assert:
	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0, #0]
	mov x1, #1
	bl assertEqual

	ASSERT_SEC_CONTENTS_ADDRESS 8, jump_if_false_word_address

	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0, #16]
	LOAD_ADDRESS x1, L_test_secondary_area
	add x1, x1, #32
	bl assertEqual

	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0, #24]
	mov x1, #2
	bl assertEqual

	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0, #32]
	mov x1, #3
	bl assertEqual

	// Make sure CONTROL_STACK is back where it started
	mov x0, CONTROL_STACK
	mov x1, x28
	bl assertEqual

	ldr x28, [sp, #8]
TEST_END

TEST_START if_else_fi_generates_right_code
	str x28, [sp, #8]

	// Arrange:
	LOAD_ADDRESS SEC_SPACE, L_test_secondary_area
	bl init_control_stack
	mov x28, CONTROL_STACK

	// Act:
	mov x0, #1		// @ space + 0
	STORE_SEC x0

	bl if

	mov x0, #2	// @ space + 24
	STORE_SEC x0

	bl else

	mov x0, #3	// @ space +
	STORE_SEC x0

	bl fi

	mov x0, #4	// @ space +
	STORE_SEC x0

	// Assert:
	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0, #0]
	mov x1, #1
	bl assertEqual

	ASSERT_SEC_CONTENTS_ADDRESS 8, jump_if_false_word_address

	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0, #16]
	LOAD_ADDRESS x1, L_test_secondary_area
	add x1, x1, #48
	bl assertEqual

	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0, #24]
	mov x1, #2
	bl assertEqual

	ASSERT_SEC_CONTENTS_ADDRESS 32, jump_word_address

	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0, #40]
	LOAD_ADDRESS x1, L_test_secondary_area
	add x1, x1, #56
	bl assertEqual

	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0, #48]
	mov x1, #3
	bl assertEqual

	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0, #56]
	mov x1, #4
	bl assertEqual

	// Make sure CONTROL_STACK is back where it started
	mov x0, CONTROL_STACK
	mov x1, x28
	bl assertEqual

	ldr x28, [sp, #8]
TEST_END

.macro ASSERT_SEC_CONTENTS_CONSTANT offset, value
	LOAD_ADDRESS x0, L_test_secondary_area
	ldr x0, [x0, \offset]
	mov x1, \value
	bl assertEqual
.endm

TEST_START do_while_od_generates_right_code
	str x28, [sp, #8]

	// Arrange:
	LOAD_ADDRESS SEC_SPACE, L_test_secondary_area
	bl init_control_stack
	mov x28, CONTROL_STACK

	// Act:
	mov x0, #1		// @ space + 0
	STORE_SEC x0

	bl while

	mov x0, #2	// @ space + 24
	STORE_SEC x0

	bl do

	mov x0, #3	// @ space +
	STORE_SEC x0

	bl od

	mov x0, #4	// @ space +
	STORE_SEC x0

	// Assert:
	ASSERT_SEC_CONTENTS_CONSTANT 0, 1
	ASSERT_SEC_CONTENTS_CONSTANT 8, 2

	ASSERT_SEC_CONTENTS_ADDRESS 16, jump_if_false_word_address
	ASSERT_SEC_CONTENTS_ADDRESS 24, L_test_secondary_area, 56

	ASSERT_SEC_CONTENTS_CONSTANT 32, 3

	ASSERT_SEC_CONTENTS_ADDRESS 40, jump_word_address
	ASSERT_SEC_CONTENTS_ADDRESS 48, L_test_secondary_area, 8

	ASSERT_SEC_CONTENTS_CONSTANT 56, 4

	// Make sure CONTROL_STACK is back where it started
	mov x0, CONTROL_STACK
	mov x1, x28
	bl assertEqual

	ldr x28, [sp, #8]
TEST_END

