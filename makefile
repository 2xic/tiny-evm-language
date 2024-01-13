.PHONY: example_programs

example_programs:
	zig build  
	./zig-out/bin/cli ./programs/your_first_program.golf
	./zig-out/bin/cli ./programs/your_second_program.golf
