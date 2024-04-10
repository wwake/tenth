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
	bl set_bits_at_sets_bits

	unix_exit
	STD_EPILOG
	ret


.data
L_clear_bits:
.quad 0x107
.quad 0x200005cb

L_clear_bits_expected:
.quad 0x200004c3

.text
.align 2

TEST_START clear_bits_at_clears_bits
	// Arrange:
	LOAD_ADDRESS x0, L_clear_bits
	mov x1, #8
	mov x2, #0x108		// Bits to flip

	// Act:
	bl clear_bits_at

	// Assert:
	LOAD_ADDRESS x0, L_clear_bits
	add x0, x0, #8
	ldr x0, [x0]
	LOAD_ADDRESS x1, L_clear_bits_expected
	ldr x1, [x1]
	bl assertEqual
TEST_END


.data
L_set_bits:
.quad 0x107
.quad 0x200004c3

L_set_bits_expected:
.quad 0x200005cb

.text
.align 2

TEST_START set_bits_at_sets_bits
	// Arrange:
	LOAD_ADDRESS x0, L_set_bits
	mov x1, #8
	mov x2, #0x108		// Bits to flip

	// Act:
	bl set_bits_at

	// Assert:
	LOAD_ADDRESS x0, L_set_bits
	add x0, x0, #8
	ldr x0, [x0]
	LOAD_ADDRESS x1, L_set_bits_expected
	ldr x1, [x1]
	bl assertEqual
TEST_END
