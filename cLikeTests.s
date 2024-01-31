.global _start             // Provide program starting address to linker

_start:
  str   lr, [sp, #-16]!

  bl empty_string_length_0
  bl knows_length_for_nonempty_string

  unix_exit
  ldr lr, [sp], #16
  ret


TEST_START empty_string_length_0
  B L_after_data
L_empty_string:
.asciz ""
.align 2

L_after_data:
  adr x0, L_empty_string

  bl strlen

  mov x1, #0
  adr x2, L_TS_empty_string_length_0
  bl assertEqual
TEST_END

TEST_START knows_length_for_nonempty_string
  B L_after_data_hello
L_data_hello:
.asciz "Hello world!"
.align 2

L_after_data_hello:
  adr x0, L_data_hello

  bl strlen

  mov x1, #12
  adr x2, L_TS_knows_length_for_nonempty_string
  bl assertEqual
TEST_END
