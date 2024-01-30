.align 2

.global strlen

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
