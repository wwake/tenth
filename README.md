# tenth
A threaded interpreter for a Forth-like language, in Arm64 assembler; for demo purposes only!

[![No Maintenance Intended](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)

## Project Documentation
* `tenth.key` - day-by-day notes
* `EnvironmentNotes.key` - notes about ARM64 assembler programming (and related tools)
* `DesignNotes.key` - overview of design of the interpreter and compiler
* `asUnit.key` - notes about the assembly unit-testing package we developed. 


# The Tenth Programming Language
In these descriptions, *a*, *b*, and *c* represent the first, second, and third elements on the stack, respectively.

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
* random &emsp;&emsp;&emsp;&emsp;a ⇒ r, where r is in the range [0, a)

## Logical Words
* & &emsp;&emsp;&emsp;&emsp;abc ⇒ (b & a)c - and
* | &emsp;&emsp;&emsp;&emsp;abc ⇒ (b | a)c - or
* ^ &emsp;&emsp;&emsp;&emsp;abc ⇒ (b ^ a)c - xor
* ~ &emsp;&emsp;&emsp;&emsp;abc ⇒ (~a)bc - bitwise not
* ! &emsp;&emsp;&emsp;&emsp;abc ⇒ (!a)bc - logical not (0=>1, non-zero=>0)

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

## I/O
* nl - print newline
* . - print number on top of stack (non-destructive)

## Control
* repeat .. flag until - repeats until flag at top of stack is true; consumes flag
* flag if [else] fi
* while .. do .. od

## Memory - 
* variable name - makes 'name' a variable and initializes it to 0
* @   a = mem[a]
* @=   mem[a] = b
* a array name - makes 'name' an array, pops a and initializes that many cells to 0
* @+   a = mem[b[a]]
* @+=   mem[c[b]] = a

## String
* .$ - prints string from address a (non-destructive)
* head$ - takes a string address from stack, moves forward one character and pushes that address, then pushes the character (as an int). However, if the character is 0, the address isn't pushed.
* make$ - a is address of array, with one character number per word, followed by a 0 word; it gets converted to string and the array address replaced by the string address on the stack

