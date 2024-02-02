.global _start                         // Provide program starting address to linker

.extern nl

.align 2

_start:
    str     lr, [sp, #-16]!
    
    bl nl
    
    ADR x0, hello
    bl print

    bl test1
    bl test2

    unix_exit
    ldr lr, [sp], #16
    ret

hello:
.asciz "Hello!\n"
.align 2

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

