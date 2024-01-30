all: unitTestDemo.out

unitTestDemo.int: unix_functions.macros asUnit.macros unitTestDemo.s
	cat $^ >$@

cLike.o: cLike.s
	as -o $@ $^

%.o: %.int
	as -o $@ $^

unitTestDemo.out: cLike.o unitTestDemo.o
	ld -macos_version_min 14.0.0 -o $@ $^ -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64


clean:
		rm -f *.o *.int *.out
