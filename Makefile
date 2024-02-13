all: tests

LD=ld -macos_version_min 14.0.0 -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64

%o: %.s
	as -o $@ $^

%.out: %.o
	$(LD) -o $@ $^

asUnit.o: asUnit.s


core.o: assembler.macros core.s

coreTests.o: coreTests.s unix_functions.macros assembler.macros asUnit.macros

coreTests.out: coreTests.o asUnit.o cLike.o core.o interpreter.o


unitTestDemo.o: unitTestDemo.s unix_functions.macros asUnit.macros assembler.macros

unitTestDemo.out: unitTestDemo.o cLike.o core.o asUnit.o


cLike.o: cLike.s unix_functions.macros

cLikeTests.o: cLikeTests.s unix_functions.macros asUnit.macros assembler.macros

cLikeTests.out: cLikeTests.o cLike.o asUnit.o


interpreter.o: interpreter.s unix_functions.macros assembler.macros

interpreterTests.o: interpreterTests.s interpreter.o unix_functions.macros assembler.macros asUnit.macros

interpreterTests.out: interpreterTests.o interpreter.o asUnit.o cLike.o core.o


clean:
	rm -f *.o *.out

tests: cLikeTests.out coreTests.out unitTestDemo.out interpreterTests.out
	./cLikeTests.out ; ./coreTests.out ; ./unitTestDemo.out ; ./interpreterTests.out

