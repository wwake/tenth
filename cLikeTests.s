.include "assembler.macros"
.include "unix_functions.macros"
.include "asUnit.macros"

.global _start

.text
.p2align 2

_start:
	str lr, [sp, #-16]!

	TEST_ALL "cLikeTests"

	bl empty_string_length_0
	bl knows_length_for_nonempty_string

	bl streq_for_empty_strings
	bl streq_for_empty_vs_nonempty_strings
	bl streq_for_nonempty_vs_empty_strings
	bl streq_for_differing_nonempty_strings
	bl streq_for_identical_strings
	bl streq_for_string_vs_itself

	bl strcpyz_copies_empty_string_plus_null_byte
	bl strcpyz_copies_non_empty_string_plus_null_byte

	bl dec2str_converts_positive
	bl dec2str_converts_zero
	bl dec2str_converts_negative

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
L_strcpyz_empty:
	.asciz ""

L_strcpyz_non_empty:
	.asciz "dup"

L_strcpyz_target:
	.fill 20, 1, 0xff
.align 2

.text
.align 2

TEST_START strcpyz_copies_empty_string_plus_null_byte
	LOAD_ADDRESS x0, L_strcpyz_empty
	LOAD_ADDRESS x1, L_strcpyz_target

	bl strcpyz

	LOAD_ADDRESS x0, L_strcpyz_target
	ldrb w0, [x0]
	mov x1, #0
	bl assertEqual

	LOAD_ADDRESS x0, L_strcpyz_target
	ldrb w0, [x0, #1]
	mov x1, #0
	bl assertEqual
TEST_END

TEST_START strcpyz_copies_non_empty_string_plus_null_byte
	LOAD_ADDRESS x0, L_strcpyz_non_empty
	LOAD_ADDRESS x1, L_strcpyz_target

	bl strcpyz

	LOAD_ADDRESS x0, L_strcpyz_target
	LOAD_ADDRESS x1, L_strcpyz_non_empty
	bl streq
	mov x1, #1
	bl assertEqual

	LOAD_ADDRESS x0, L_strcpyz_target
	ldrb w0, [x0, #4]		// one past the string's \0 byte
	mov x1, #0
	bl assertEqual
TEST_END

.data
L_string_zero: .asciz "0"
L_string_positive: .asciz "65535"
L_string_negative: .asciz "-65535"

.text
.p2align 2

TEST_START dec2str_converts_zero
	mov x0, #0
	bl dec2str

	LOAD_ADDRESS x1, L_string_zero
	bl streq

	mov x1, #1
	bl assertEqual
TEST_END


TEST_START dec2str_converts_positive
	mov x0, #65535
	bl dec2str

	LOAD_ADDRESS x1, L_string_positive
	bl streq

	mov x1, #1
	bl assertEqual
TEST_END

TEST_START dec2str_converts_negative
	mov x0, #65535
	neg x0, x0
	bl dec2str

	LOAD_ADDRESS x1, L_string_negative
	bl streq

	mov x1, #1
	bl assertEqual
TEST_END

