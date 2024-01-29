

HelloWorld: HelloWorld.o
	ld -macos_version_min 14.0.0 -o HelloWorld HelloWorld.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e _start -arch arm64

HelloWorld.o: HelloWorld.s
	as -o HelloWorld.o HelloWorld.s

clean:
	rm *.o
