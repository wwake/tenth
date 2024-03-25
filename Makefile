all: tests

LD=ld -macos_version_min 14.0.0 -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64

MACROS=unix_functions.macros assembler.macros dictionary.macros repl.macros core.defines
TEST_MACROS=asUnit.macros coreTests.macros

%.o: %.s
	gcc -E -P -C $< -o $@.post
	as -o $@ $@.post

%.out: %.o
	$(LD) -o $@ $^

arithmetic.o: arithmetic.s core.defines assembler.macros

arithmeticTests.o: arithmeticTests.s $(MACROS) $(TEST_MACROS)

arithmeticTests.out: arithmeticTests.o arithmetic.o asUnit.o cLike.o core.o interpreter.o input.o


asUnit.o: asUnit.s


cLike.o: cLike.s unix_functions.macros

cLikeTests.o: cLikeTests.s $(MACROS) $(TEST_MACROS)

cLikeTests.out: cLikeTests.o cLike.o asUnit.o


core.o: core.s assembler.macros core.defines

coreTests.o: coreTests.s $(MACROS) $(TEST_MACROS)

coreTests.out: coreTests.o asUnit.o cLike.o core.o interpreter.o input.o


dictionary.o: dictionary.s dictionary.macros unix_functions.macros assembler.macros core.defines

dictionaryTests.o: dictionaryTests.s dictionary.o $(MACROS) $(TEST_MACROS)

dictionaryTests.out: dictionaryTests.o dictionary.o arithmetic.o asUnit.o interpreter.o core.o cLike.o input.o


input.o: input.s $(MACROS)

inputTests.o: inputTests.s $(MACROS) $(TEST_MACROS)

inputTests.out: inputTests.o asUnit.o cLike.o input.o


io.o: io.s core.defines assembler.macros


interpreter.o: interpreter.s unix_functions.macros assembler.macros core.defines

interpreterTests.o: interpreterTests.s interpreter.o $(MACROS) $(TEST_MACROS)

interpreterTests.out: interpreterTests.o interpreter.o arithmetic.o asUnit.o cLike.o core.o input.o


main.o: main.s core.defines


repl.o: repl.s core.defines

replTests.o: replTests.s $(MACROS) $(TEST_MACROS)

replTests.out: replTests.o repl.o asUnit.o cLike.o core.o dictionary.o input.o interpreter.o

repl.out: repl.o arithmetic.o core.o cLike.o dictionary.o input.o interpreter.o io.o main.o


unitTestDemo.o: unitTestDemo.s $(MACROS) $(TEST_MACROS)

unitTestDemo.out: unitTestDemo.o cLike.o core.o asUnit.o


clean:
	rm -f *.o *.out *.post


repl: repl.out
	./repl.out

tests: arithmeticTests.out cLikeTests.out coreTests.out dictionaryTests.out inputTests.out interpreterTests.out replTests.out
	./arithmeticTests.out ; ./cLikeTests.out ; ./coreTests.out ; ./dictionaryTests.out; ./inputTests.out; ./interpreterTests.out; ./replTests.out

playground: unitTestDemo.out
	./unitTestDemo.out
