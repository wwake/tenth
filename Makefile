all: tests

LD=ld -macos_version_min 14.0.0 -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64

%o: %.s
	as -o $@ $^

%.out: %.o
	$(LD) -o $@ $^

asUnit.o: asUnit.s


core.o: core.macros core.s

coreTests.o: coreTests.s unix_functions.macros core.macros asUnit.macros

coreTests.out: coreTests.o asUnit.o cLike.o core.o


unitTestDemo.o: unitTestDemo.s unix_functions.macros asUnit.macros 

unitTestDemo.out: unitTestDemo.o asUnit.o cLike.o core.o


cLike.o: cLike.s unix_functions.macros

cLikeTests.o: cLikeTests.s unix_functions.macros asUnit.macros

cLikeTests.out: cLikeTests.o asUnit.o cLike.o


interpreterTests.o: interpreterTests.s unix_functions.macros core.macros asUnit.macros

interpreterTests.out: interpreterTests.o asUnit.o cLike.o


clean:
	rm -f *.o *.out

tests: cLikeTests.out coreTests.out unitTestDemo.out interpreterTests.out
	./cLikeTests.out ; ./coreTests.out ; ./unitTestDemo.out ; ./interpreterTests.out

