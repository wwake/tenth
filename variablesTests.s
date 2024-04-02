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

	unix_exit
	STD_EPILOG
	ret

.data
.p2align 3

L_test_address:
	.quad 0

.text
.align 2

//
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

