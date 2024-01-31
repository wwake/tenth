.global assertEqual

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
