# tenth
A threaded interpreter for a Forth-like language, in Arm64 assembler; for demo purposes only!

[![No Maintenance Intended](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)

## Project Documentation
* `tenth.key` - day-by-day notes
* `EnvironmentNotes.key` - notes about ARM64 assembler programming (and related tools)
* `DesignNotes.key` - overview of design of the interpreter and compiler
* `asUnit.key` - notes about the assembly unit-testing package we developed. 


# The Tenth Programming Language
In these descriptions, a, b, and c represent the first, second, and third elements on the stack, respectively.

## Arithmetic Words
* + &emsp;&emsp;&emsp;&emsp;abc ⇒ (b+a)c
* - &emsp;&emsp;&emsp;&emsp;abc ⇒ (b-a)c
* * &emsp;&emsp;&emsp;&emsp;abc ⇒ (b*a)c
* / &emsp;&emsp;&emsp;&emsp;abc ⇒ (b/a)c
* % &emsp;&emsp;&emsp;&emsp;abc ⇒ (b%a)c
* /% &emsp;&emsp;&emsp;&emsp;abc ⇒ (b%a)(b/a)c
* min &emsp;&emsp;&emsp;&emsp;abc ⇒ (min(a,b))c
* max &emsp;&emsp;&emsp;&emsp;abc ⇒ (max(a,b))c
* abs &emsp;&emsp;&emsp;&emsp;ab ⇒ (|a|)b
* neg &emsp;&emsp;&emsp;&emsp;ab ⇒ (-a)b

## Logical Words
* and  abc ⇒ (b & a)c
* or   abc ⇒ (b | a)c
* not  abc ⇒ (~a)bc
* eor  abc ⇒ (b ^ a)c

## Relational Words
* &lt;0   a&lt;0
* ==0  a==0
* ==   b == a
* !=   b != a
* &lt;    b &lt; a
* &lt;=   b &lt;= a
* >    b > a
* >=   b >= a

*Note: 0 = false, non-zero = true. Operations yield 0 or 1.*

## Stack Words
* 0    push 0 on data stack
* 1    push 1 on data stack
* n    push n on the data stack (call neg afterwards if a negative number is needed)
* pop    ab⇒b
* swap  ab⇒ba
* dup   a⇒aa 
* cab  abc⇒cab
* cba  abc⇒cba
* bab  ab⇒bab

## Memory - TBD
* Variables - TBD
* !   mem[a] = b
* @   a = mem[a]

## I/O
* nl - print newline
* . - pop and print number on top of stack (destructive)

## Control - somewhat TBD
* flag if [else] endif
* do.. flag while
* repeat.. flag until
* flag while .. flag end
* end start FOR.. NEXT

