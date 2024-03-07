all: tests

LD=ld -macos_version_min 14.0.0 -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64

MACROS=unix_functions.macros assembler.macros dictionary.macros
TEST_MACROS=asUnit.macros coreTests.macros

%o: %.s
	as -o $@ $^

%.out: %.o
	$(LD) -o $@ $^

asUnit.o: asUnit.s


cLike.o: cLike.s unix_functions.macros

cLikeTests.o: cLikeTests.s $(MACROS) $(TEST_MACROS)

cLikeTests.out: cLikeTests.o cLike.o asUnit.o


core.o: assembler.macros core.s

coreTests.o: coreTests.s $(MACROS) $(TEST_MACROS)

coreTests.out: coreTests.o asUnit.o cLike.o core.o interpreter.o


dictionary.o: dictionary.s dictionary.macros unix_functions.macros assembler.macros

dictionaryTests.o: dictionaryTests.s dictionary.o $(MACROS) $(TEST_MACROS)

dictionaryTests.out: dictionaryTests.o dictionary.o asUnit.o interpreter.o core.o cLike.o


input.o: input.s $(MACROS)

inputTests.o: inputTests.s $(MACROS) $(TEST_MACROS)

inputTests.out: inputTests.o asUnit.o cLike.o input.o


interpreter.o: interpreter.s unix_functions.macros assembler.macros

interpreterTests.o: interpreterTests.s interpreter.o $(MACROS) $(TEST_MACROS)

interpreterTests.out: interpreterTests.o interpreter.o asUnit.o cLike.o core.o


main.o: main.s


repl.o: repl.s

replTests.o: replTests.s $(MACROS) $(TEST_MACROS)

replTests.out: replTests.o repl.o asUnit.o cLike.o core.o dictionary.o input.o interpreter.o

repl.out: repl.o core.o cLike.o dictionary.o input.o interpreter.o main.o


unitTestDemo.o: unitTestDemo.s $(MACROS) $(TEST_MACROS)

unitTestDemo.out: unitTestDemo.o cLike.o core.o asUnit.o


clean:
	rm -f *.o *.out


repl: repl.out
	./repl.out

tests: cLikeTests.out coreTests.out dictionaryTests.out inputTests.out interpreterTests.out replTests.out
	./cLikeTests.out ; ./coreTests.out ; ./dictionaryTests.out; ./inputTests.out; ./interpreterTests.out; ./replTests.out

playground: unitTestDemo.out
	./unitTestDemo.out
