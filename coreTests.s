.global _start

.p2align 2

.macro VSP
x19
.endm

.macro VPC
x20
.endm

.macro LOAD_DATA register, location
    adrp \register, \location@PAGE
    add \register, \register, \location@PAGEOFF
.endm

_start:
  str lr, [sp, #-16]!

  bl push_pushes_one_item
  bl add_b_plus_a_is_a

  unix_exit
  ldr lr, [sp], #16
  ret
  
  
  TEST_START push_pushes_one_item
    LOAD_DATA X19, L_push_test_stack
    adr x20, L_data

    bl _push

    mov x0, x20
    adr x1, L_data
    add x1, x1, #8      // expect VPC to increment
    bl assertEqual

    mov x0, x19         // Current VSP
    
    adrp x1, L_push_test_stack@PAGE
    add x1, x1, L_push_test_stack@PAGEOFF
    add x1, x1, #8      // Expect original stack+8
    
    bl assertEqual
    
    adrp x0, L_push_test_stack@PAGE
    add x0, x0, L_push_test_stack@PAGEOFF
    
    ldr x0, [x0]
    mov x1, #142        // Expected stack contents
    bl assertEqual
    
  TEST_END


L_data: .quad 142, 58

.data

.p2align 2
L_push_test_stack: .quad 0, 99, 0, 0
 
  
L_VSP_Update: .asciz "VSP should be incremented"
L_stack_update: .asciz "Stack should have data"
L_VPC_Update: .asciz "VPC should be incremented"

.p2align 2

.text
.p2align 2

TEST_START add_b_plus_a_is_a
  LOAD_DATA X19, L_push_test_stack

  adr x20, L_data

  bl _push
  bl _push

  bl add

  mov x0, x19         // Current VSP
  LOAD_DATA x1, L_push_test_stack
  add x1, x1, #8      // Expect original stack+8
  bl assertEqual
  
  LOAD_DATA x0, L_push_test_stack  
  ldr x0, [x0]
  mov x1, #200        // Expected stack contents
  bl assertEqual
  
TEST_END

