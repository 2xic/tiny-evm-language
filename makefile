.PHONY: example_programs

build:
	zig build

example_programs: build
	./zig-out/bin/cli ./programs/your_first_program.golf
	./zig-out/bin/cli ./programs/your_second_program.golf
