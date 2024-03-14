.include "assembler.macros"
.include "unix_functions.macros"
.include "asUnit.macros"

.global _start		// Provide program starting address to linker

.extern nl


.data
L_input_buffer:
  .fill 100, 8, 0

.text


.align 2

// 3	AUE_NULL	ALL	{ user_ssize_t read(int fd, user_addr_t cbuf, user_size_t nbyte); }

_start:
	str lr, [sp, #-16]!
	
	mov x0, #0
	LOAD_ADDRESS x1, L_input_buffer
	mov x2, #99
	unix_read #0, L_input_buffer, #99

	bl printnum

	LOAD_ADDRESS x0, L_input_buffer
	bl print

	mov x0, #0
	LOAD_ADDRESS x1, L_input_buffer
	mov x2, INPUT_BUFFER_SIZE
	unix_read #0, L_input_buffer, #99

	bl printnum

	LOAD_ADDRESS x0, L_input_buffer
	bl print

	TEST_ALL "unitTestDemo"

//	bl print_number

//	bl nl

//	adr x0, hello
//	bl print

//	bl testPrint
//	bl print_number

   // bl test1
	// bl test2

	unix_exit
	ldr lr, [sp], #16
	ret

hello:
.asciz "Hello!\n"
.align 2

TEST_START testPrint
	mov x28, #42
	adr x0, hello
	bl print
	
		// check that x28 is not overwritten
	mov x0, x28
	mov x1, #42
	bl assertEqual
TEST_END

TEST_START print_number
	mov x0, #-9223372036854775807
//	neg x0, x0
//	sub x0, x0, #1
	bl printnum
TEST_END


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

