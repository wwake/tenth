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

arithmeticTests.out: arithmeticTests.o arithmetic.o asUnit.o cLike.o compile.o interpreter.o input.o stack.o


asUnit.o: asUnit.s


cLike.o: cLike.s unix_functions.macros

cLikeTests.o: cLikeTests.s $(MACROS) $(TEST_MACROS)

cLikeTests.out: cLikeTests.o cLike.o asUnit.o


compile.o: compile.s assembler.macros core.defines

compileTests.o: compileTests.s $(MACROS) $(TEST_MACROS)

compileTests.out: compileTests.o asUnit.o cLike.o compile.o interpreter.o input.o relational.o stack.o


control.o: control.s assembler.macros core.defines

controlTests.o: controlTests.s $(MACROS) $(TEST_MACROS)

controlTests.out: controlTests.o asUnit.o cLike.o control.o interpreter.o input.o io.o relational.o stack.o


dictionary.o: dictionary.s dictionary.macros unix_functions.macros assembler.macros core.defines

dictionaryTests.o: dictionaryTests.s dictionary.o $(MACROS) $(TEST_MACROS)

dictionaryTests.out: dictionaryTests.o dictionary.o arithmetic.o asUnit.o interpreter.o compile.o cLike.o input.o io.o stack.o


input.o: input.s $(MACROS)

inputTests.o: inputTests.s $(MACROS) $(TEST_MACROS)

inputTests.out: inputTests.o asUnit.o cLike.o input.o


io.o: io.s core.defines assembler.macros


interpreter.o: interpreter.s unix_functions.macros assembler.macros core.defines

interpreterTests.o: interpreterTests.s interpreter.o $(MACROS) $(TEST_MACROS)

interpreterTests.out: interpreterTests.o interpreter.o arithmetic.o asUnit.o cLike.o compile.o control.o input.o relational.o stack.o


logical.o: logical.s unix_functions.macros assembler.macros core.defines

logicalTests.o: logicalTests.s logical.o $(MACROS) $(TEST_MACROS)

logicalTests.out: logicalTests.o logical.o cLike.o asUnit.o stack.o



main.o: main.s core.defines


relational.o: relational.s $(MACROS)

relationalTests.o: relationalTests.s $(MACROS) $(TEST_MACROS)

relationalTests.out: relationalTests.o relational.o asUnit.o asUnit.o cLike.o stack.o


repl.o: repl.s core.defines

replTests.o: replTests.s $(MACROS) $(TEST_MACROS)

replTests.out: replTests.o repl.o asUnit.o cLike.o compile.o control.o dictionary.o input.o interpreter.o stack.o

repl.out: repl.o arithmetic.o cLike.o compile.o control.o dictionary.o input.o interpreter.o io.o logical.o main.o relational.o stack.o variables.o


stack.o: stack.s $(MACROS)

stackTests.o: stackTests.s $(MACROS) $(TEST_MACROS)

stackTests.out: stackTests.o stack.o asUnit.o cLike.o


unitTestDemo.o: unitTestDemo.s $(MACROS) $(TEST_MACROS)

unitTestDemo.out: unitTestDemo.o cLike.o compile.o asUnit.o


variables.o: variables.s $(MACROS)

variablesTests.o: variablesTests.s $(MACROS) $(TEST_MACROS)

variablesTests.out: variablesTests.o variables.o asUnit.o cLike.o compile.o input.o interpreter.o stack.o


clean:
	rm -f *.o *.out *.post


repl: repl.out
	./repl.out

tests: arithmeticTests.out cLikeTests.out compileTests.out controlTests.out dictionaryTests.out inputTests.out interpreterTests.out logicalTests.out relationalTests.out replTests.out stackTests.out variablesTests.out
	./arithmeticTests.out ; ./cLikeTests.out ; ./compileTests.out ; ./controlTests.out ;  ./dictionaryTests.out; ./inputTests.out; ./interpreterTests.out; ./logicalTests.out; ./relationalTests.out; ./replTests.out; ./stackTests.out; ./variablesTests.out

playground: unitTestDemo.out
	./unitTestDemo.out
