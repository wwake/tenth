.include "assembler.macros"
.include "unix_functions.macros"

.global readWord

.equ INPUT_BUFFER_SIZE, 250

.data

L_input_buffer:
.align 2
   .fill 250, 8, 0
   .byte 0

.text
.align 2
readWord:
	str lr, [sp, #-16]!

	unix_read #0, L_input_buffer, INPUT_BUFFER_SIZE

	LOAD_ADDRESS x0, L_input_buffer
	bl tokenize

	LOAD_ADDRESS x0, L_input_buffer

	ldr lr, [sp], #16
	ret

