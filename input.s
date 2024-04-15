#include "core.defines"
#include "assembler.macros"

.include "unix_functions.macros"
.include "repl.macros"

.global inputInit
.global readWord
.global readLine
.global inputBuffer

.equ INPUT_BUFFER_SIZE, 250

.data
L_compile_prompt:
	.asciz "\033[31mⒸ 10>\033[0m "

L_run_prompt:
	.asciz "\033[32mⓇ 10>\033[0m "

.align 2
inputBuffer:
   .fill 250, 8, 0
   .byte 0

.text
.align 2

inputInit:
	LOAD_ADDRESS NEXT_WORD, inputBuffer
	strb wzr, [NEXT_WORD]
	ret


// readLine - print prompt and read next line
// Input: none
// Uses x0, x1, x2 - temp
// Output: x0 - number of characters read
//
readLine:
	STD_PROLOG

	// prompt (with © first if in compile mode)
	and x1, FLAGS, COMPILE_MODE
	cmp x1, COMPILE_MODE
	b.ne L_print_prompt
		LOAD_ADDRESS x0, L_compile_prompt
		bl print
		b L_reading

L_print_prompt:
	LOAD_ADDRESS x0, L_run_prompt
	bl print

	// Read a new line
L_reading:
	mov x0, #0
	LOAD_ADDRESS x1, inputBuffer
	mov x2, INPUT_BUFFER_SIZE

	unix_read #0, L_input_buffer, INPUT_BUFFER_SIZE

	STD_EPILOG
	ret

// readWord - get next word, reading new lines if necessary
// Inputs:
//   READ_LINE_ROUTINE (register) - address of the routine to call to read a line
// Output:
//   x0 - ptr to start of returned word (0-terminated string)
//   x1 - 0 for word, 1 for a string, 2 for a number
//   NEXT_WORD (register) - updated NEXT_WORD
//
readWord:
	STD_PROLOG

	// Check for NEXT_WORD at \0
L_check_if_at_end:
	ldrb w0, [NEXT_WORD]
	cmp w0, #0
	b.ne L_find_word_start
		blr READ_LINE_ROUTINE

		LOAD_ADDRESS NEXT_WORD, inputBuffer

L_find_word_start:
	ldrb w0, [NEXT_WORD]
	cmp w0, #0x20		// space (skip)
	b.eq L_move_forward
	cmp w0, #0x09		// tab (skip)
	b.eq L_move_forward
	b L_look_for_string

L_move_forward:
		add NEXT_WORD, NEXT_WORD, #1
		b L_find_word_start

L_look_for_string:
		cmp w0, #34		// double quote
		b.ne L_word_start
			bl read_string
			b L_exit_word

L_word_start:
			// Look for a regular word or number
		mov x0, NEXT_WORD			// Set the return to point to this word
		mov x1, WORD_FOUND

		ldrb w2, [NEXT_WORD]
		cmp w2, 0x60	// backtick
		b.eq L_handle_backtick
		cmp w2, 0x0a		// newline
		b.ne find_trailing_space_or_nl	// At end of line - go back & read more
		add NEXT_WORD, NEXT_WORD, #1
		b L_check_if_at_end

L_handle_backtick:
		strb wzr, [NEXT_WORD], #1
		strb wzr, [NEXT_WORD]
		b L_check_if_at_end


find_trailing_space_or_nl:
		ldrb w2, [NEXT_WORD], #1
		cmp w2, 0x0a		// newline
		b.eq L_exit_word
		cmp w2, 0x60		// backtick
		b.eq L_exit_word
		cmp w2, 0x20		// space
		b.eq L_exit_word
		b find_trailing_space_or_nl

L_exit_word:
	strb wzr, [NEXT_WORD, #-1]

	STD_EPILOG
	ret


// read_string - look for contents of quoted string
// Output:
//   x0 = pointer to unterminated string
//   x1 = STRING_FOUND code
//   NEXTWORD - points one past terminating character
//
read_string:
	// Skip past the first quote
	add NEXT_WORD, NEXT_WORD, #1
	mov x0, NEXT_WORD			// Set the return to point to this word
	mov x1, STRING_FOUND

L_loop_string:
		ldrb w2, [NEXT_WORD], #1
//		cmp w2, 0x0a		// newline
//		b.eq L_exit_string
		cmp w2, #34			// double quote
		b.eq L_exit_string
		b L_loop_string

L_exit_string:

	ret
