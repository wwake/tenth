.include "unix_functions.macros"
.include "core.macros"
.include "asUnit.macros"

.global _start

_start:
	str lr, [sp, #-16]!

	bl empty_string_length_0
	bl knows_length_for_nonempty_string

	bl streq_for_empty_strings
	bl streq_for_empty_vs_nonempty_strings
	bl streq_for_nonempty_vs_empty_strings
	bl streq_for_differing_nonempty_strings
	bl streq_for_identical_strings
	bl streq_for_string_vs_itself

	bl dec2str_converts_positive

	unix_exit
	ldr lr, [sp], #16
	ret


TEST_START empty_string_length_0
	adr x0, L_empty_string

	bl strlen

	mov x1, #0
	adr x2, L_TS_empty_string_length_0
	bl assertEqual
TEST_END

L_empty_string:
.asciz ""


TEST_START knows_length_for_nonempty_string
	adr x0, L_data_hello

	bl strlen

	mov x1, #13
	bl assertEqual
TEST_END

L_data_hello:
.asciz "Hello world!\n"

.data
L_string1_empty: .asciz ""
L_string2_empty: .asciz ""
L_string3_nonempty: .asciz "not empty"
L_string4_same1: .asciz "Hello world!"
L_string4_same2: .asciz "Hello world!"
L_string5_different: .asciz "Hello"
.text
.p2align 2

TEST_START streq_for_empty_strings
	LOAD_ADDRESS x0, L_string1_empty
	LOAD_ADDRESS x1, L_string2_empty
	bl streq

	mov x1, #1
	bl assertEqual
TEST_END


TEST_START streq_for_empty_vs_nonempty_strings
	LOAD_ADDRESS x0, L_string1_empty
	LOAD_ADDRESS x1, L_string3_nonempty
	bl streq

	mov x1, #0
	bl assertEqual
TEST_END

TEST_START streq_for_nonempty_vs_empty_strings
	LOAD_ADDRESS x0, L_string3_nonempty
	LOAD_ADDRESS x1, L_string1_empty
	bl streq

	mov x1, #0
	bl assertEqual
TEST_END

TEST_START streq_for_differing_nonempty_strings
	LOAD_ADDRESS x0, L_string4_same1
	LOAD_ADDRESS x1, L_string5_different
	bl streq

	mov x1, #0
	bl assertEqual
TEST_END

TEST_START streq_for_identical_strings
	LOAD_ADDRESS x0, L_string4_same1
	LOAD_ADDRESS x1, L_string4_same2
	bl streq

	mov x1, #1
	bl assertEqual
TEST_END

TEST_START streq_for_string_vs_itself
	LOAD_ADDRESS x0, L_string4_same1
	LOAD_ADDRESS x1, L_string4_same1
	bl streq

	mov x1, #1
	bl assertEqual
TEST_END


.data
L_string_number: .asciz "65535"

.text
.p2align 2

TEST_START dec2str_converts_positive
	mov x0, #65535
	bl dec2str

stop:
	LOAD_ADDRESS x1, L_string_number
	bl streq

	mov x1, #1
	bl assertEqual
TEST_END

