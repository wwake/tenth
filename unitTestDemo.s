
.global _start             // Provide program starting address to linker
.align 2

_start:
  bl test1

  mov     X0, #0      // Use 0 return code
  mov     X16, #1     // Service command code 1 terminates this program
  svc     0           // Call MacOS to terminate the program
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
  .ascii "Here   "
