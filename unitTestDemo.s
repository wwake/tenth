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


.align 2
// add: x0 = x0 + x1
add:
  add x0, x0 , x1
  ret

