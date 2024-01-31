all: unitTestDemo.out cLikeTests.out

LD=ld -macos_version_min 14.0.0 -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64

%.o: %.int
	as -o $@ $^
    
asUnit.o: asUnit.s

unitTestDemo.int: unix_functions.macros asUnit.macros unitTestDemo.s
	cat $^ >$@

unitTestDemo.out: asUnit.o cLike.o unitTestDemo.o
	$(LD) -o $@ $^


cLike.o: cLike.s
	as -o $@ $^

cLikeTests.int: unix_functions.macros asUnit.macros cLikeTests.s
	cat $^ >$@

cLikeTests.out: asUnit.o cLike.o cLikeTests.o
	$(LD) -o $@ $^

clean:
	rm -f *.o *.int *.out
