all: HelloWorld.out unitTestDemo.out

#HelloWorld: HelloWorld.o
#	ld -macos_version_min 14.0.0 -o HelloWorld HelloWorld.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64

#HelloWorld.o: HelloWorld.s
#	as -o HelloWorld.o HelloWorld.s

%.out: %.o
	ld -macos_version_min 14.0.0 -o $@ $< -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64

unitTestDemo.int: unix_functions.S unitTestDemo.s
	cat $^ >$@

%.o: %.int
	as -o $@ $^

clean:
		rm -f *.o *.out
