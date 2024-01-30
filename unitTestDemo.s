.global _start             // Provide program starting address to linker
.align 2

.macro print message, length
  mov X0, #1       // stdout
  adr X1, message\@
  mov X2, #\length
  mov X16, #4      // write

  svc 0
  b exit\@

  message\@:
  .ascii "\message"

  .align 2

  exit\@:
    nop

.endm

_start:
  str   lr, [sp, #-16]!
  bl test1
  bl test2
  bl empty_string_length_0
  bl knows_length_for_nonempty_string

  unix_exit
  ldr lr, [sp], #16
  ret

TEST_START test1
  mov x0, #2
  mov x1, #5

  bl add

  mov x1, #7
  adr x2, L_TS_test1
  bl assertEqual
TEST_END


TEST_START test2
  mov x0, #2
  mov x1, #1

  bl add

  mov x1, #3
  adr x2, L_TS_test2
  bl assertEqual
TEST_END


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

.align 2
// strlen
// input: x0 is address of a 0-terminated string
// process: x1 is address of current character
//          w2 is value of current character
// output: x0 is length of string
strlen:
  mov x1, x0
  mov x0, #0

loop:
  ldrb w2, [x1], #1
  cmp w2, #0
  b.eq l_return
  add x0, x0, #1
  b loop

l_return:
  ret

.align 2
// add: x0 = x0 + x1
add:
  add x0, x0 , x1
  ret


.align 2
// assertEqual: prints message if x0 != x1
assertEqual:
  cmp x0, x1
  bne failed
  ret

failed:
  mov X0, #1
  adr X1, failedMessage
  mov X2, #7
  mov X16, #4
  svc 0

  ret

failedMessage:
  .ascii "Failed\n"

hereMessage:
  .ascii "here\n"
