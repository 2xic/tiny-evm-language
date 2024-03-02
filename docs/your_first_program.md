
## Your first program
We support the option to run all the EVM opcodes by wrapping it in a `assembly` block.

```
// This is an assembly code block. All high level code will be compiled down to these blocks with associated comments with the context.
assembly {
    PUSH0;
}
```

This will just `PUSH0` onto the stack.

Run the the program with
```bash
./zig-out/bin/cli programs/your_first_program.golf
```
