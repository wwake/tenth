all: tests

LD=ld -macos_version_min 14.0.0 -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64

MACROS=unix_functions.macros assembler.macros asUnit.macros dictionary.macros

%o: %.s
	as -o $@ $^

%.out: %.o
	$(LD) -o $@ $^

asUnit.o: asUnit.s


core.o: assembler.macros core.s

coreTests.o: coreTests.s unix_functions.macros assembler.macros asUnit.macros coreTests.macros

coreTests.out: coreTests.o asUnit.o cLike.o core.o interpreter.o


unitTestDemo.o: unitTestDemo.s unix_functions.macros asUnit.macros assembler.macros coreTests.macros

unitTestDemo.out: unitTestDemo.o cLike.o core.o asUnit.o


cLike.o: cLike.s unix_functions.macros

cLikeTests.o: cLikeTests.s unix_functions.macros asUnit.macros assembler.macros

cLikeTests.out: cLikeTests.o cLike.o asUnit.o


interpreter.o: interpreter.s unix_functions.macros assembler.macros

interpreterTests.o: interpreterTests.s interpreter.o unix_functions.macros assembler.macros asUnit.macros coreTests.macros

interpreterTests.out: interpreterTests.o interpreter.o asUnit.o cLike.o core.o

dictionary.o: dictionary.s dictionary.macros unix_functions.macros assembler.macros

dictionaryTests.o: dictionaryTests.s unix_functions.macros assembler.macros asUnit.macros dictionary.o

dictionaryTests.out: dictionaryTests.o dictionary.o asUnit.o interpreter.o core.o cLike.o

clean:
	rm -f *.o *.out

tests: cLikeTests.out coreTests.out unitTestDemo.out interpreterTests.out dictionaryTests.out
	./cLikeTests.out ; ./coreTests.out ; ./unitTestDemo.out ; ./interpreterTests.out; ./dictionaryTests.out

