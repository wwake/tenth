.global nl

.align 2

// PRIMARY
.ascii "nl\0....."  // Name - 16 bytes
.align 2
.quad 0xdeadbeef

.quad 0             // Link to previous entry
.quad .+8         // Offset to code

.align 2
// code
nl:
    str   lr, [sp, #-16]!
    
    adr x0, L_nl_character
    bl print
    
    ldr lr, [sp], #16
    ret

L_nl_character:
    .asciz "\n"
    
.align 2


table:
    bl nl
    bl nl
    bl print
    bl _start
.quad 0

