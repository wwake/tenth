# tenth
A threaded interpreter for a Forth-like language, in Arm64 assembler; for demo purposes only!


## More documentation
* tenth.key - day-by-day notes
* Design Notes.key - overview of design of the interpreter and compiler
* EnvironmentNotes.key - notes about ARM64 assembler programming (and related tools)
* *TODO* - asUnit.key - notes about the assembly unit-testing package we developed. 


# The Tenth Programming Language
In these descriptions, a, b, and c represent the first, second, and third elements on the stack, respectively.

## Arithmetic Words
* +    b+a
* -    b-a
* *    b*a
* /    b/a
* MOD   b%a
* DIVMOD  b%a,b/a
* MIN   min(a,b)
* MAX   max(a,b)
* ABS   |a|
* NEG   -a

## Logical Words
* AND a = b & a
* OR  a = b | a
* NOT  a = ~a
* XOR  a = b ^ a

## Relational Words
* <     a<0
* 0=     a==0
* <       b < a
* ==     b == a
* >       b > a
* !=      b != a

*Note: 0 = false, non-zero = true. Operations yield 0 or 1.*

## Stack Words
* PUSH n  abc⇒nabc
* POP    ab⇒b
* SWAP  ab⇒ba
* DUP   a⇒aa 
* CAB  abc⇒cab
* CBA  abc⇒cba
* BAB  ab⇒bab

## Memory - TBD
* Variables - TBD
* !   mem[a] = b
* @ a = mem[a]

## I/O
* nl - print newline
* print - print number on top of stack (non-destructive)

## Control - somewhat TBD
* flag if [else] endif
* loop..flag while
* repeat.. flag until
* flag while .. flag 
  end
* end start FOR.. NEXT

