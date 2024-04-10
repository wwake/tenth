#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "asUnit.macros"

.global _start

.text
.p2align 2

_start:
	STD_PROLOG

	TEST_ALL "ioTests"

	bl clear_bits_at_clears_bits

	unix_exit
	STD_EPILOG
	ret


.data
L_clear_bits:
.asciz "scares"

L_clear_bits_expected:
.asciz "sBares"

.text
.align 2

TEST_START clear_bits_at_clears_bits
	// Arrange:
	LOAD_ADDRESS x0, L_clear_bits
	mov x1, #1
	mov w2, #0x21	// Changes character to lowercase, moves it back by one

	// Act:
	bl clear_bits_at

	// Assert:
	LOAD_ADDRESS x0, L_clear_bits
	LOAD_ADDRESS x1, L_clear_bits_expected
	bl assertEqualStrings
TEST_END

TEST_START ioctl_before_and_after

TEST_END
