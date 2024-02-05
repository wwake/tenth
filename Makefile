all: unitTestDemo.out cLikeTests.out coreTests.out

LD=ld -macos_version_min 14.0.0 -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64

%.o: %.int
	as -o $@ $^

%.out: %.o
	$(LD) -o $@ $^

core.o: core.s
	as -o $@ $^

coreTests.int: unix_functions.macros asUnit.macros coreTests.s
	cat $^ >$@

coreTests.out: asUnit.o cLike.o core.o coreTests.o

asUnit.o: asUnit.s

unitTestDemo.int: unix_functions.macros asUnit.macros unitTestDemo.s
	cat $^ >$@

unitTestDemo.out: asUnit.o cLike.o core.o unitTestDemo.o
	$(LD) -o $@ $^


cLike.o: unix_functions.macros cLike.s
	cat $^ >cLike.int
	as -o $@ cLike.int

cLikeTests.int: unix_functions.macros asUnit.macros cLikeTests.s
	cat $^ >$@

cLikeTests.out: asUnit.o cLike.o cLikeTests.o
	$(LD) -o $@ $^

clean:
	rm -f *.o *.int *.out
    
