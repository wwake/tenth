.global _start             // Provide program starting address to linker
.align 2

.macro TEST_START testname
.align 2
\testname:
  str lr, [sp, #-16]!

.endm


.macro TEST_END
ldr lr, [sp], #16
ret
.endm

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

.align 2
test1:
  str   lr, [sp, #-16]!
  mov x0, #2
  mov x1, #5

  bl add

  mov x1, #7
  bl assertEqual

  ldr lr, [sp], #16
  ret

TEST_START test2
  mov x0, #2
  mov x1, #1

  bl add

  mov x1, #3
  bl assertEqual

TEST_END


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
