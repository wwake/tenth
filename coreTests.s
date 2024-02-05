.global _start

_start:
  str lr, [sp, #-16]!

  bl empty_string_length_0
  bl knows_length_for_nonempty_string

  unix_exit
  ldr lr, [sp], #16
  ret
  
  
  TEST_START push_pushes_one_item
    adr x19, L_push_test_stack
    adr x20, L_data

    bl _push

    mov x0, x19         // Current VSP
    adr x1, L_push_test_stack
    add x1, x1, #8      // Expect stack+8
    adr x2, L_VSP_Update
    bl assertEqual
    
    adr x0, L_push_test_stack
    ldr x0, [x0]
    mov x1, #142
    adr x2, L_stack_update
    bl assertEqual
    
    mov x0, x20
    adr x1, L_data
    add x1, x1, #1
    acr x2, L_VPC_Update
    bl assertEqual
  TEST_END
  
L_push_test_stack: .quad 0, #0xdeadbeef, 0, 0
  
L_data: .quad 142, 1
  
L_VSP_Update: .asciz "VSP should be incremented"
L_stack_update: .asciz "Stack should have data"
L_VPC_Update: .asciz "VPC should be incremented"

.align 2