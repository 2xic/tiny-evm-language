
## Your third program
You can push things on the stack like this.

```
function push_stack {
    assembly {
        PUSH1 0xff;
        POP;
    }
}

push_stack;
```

Run the the program with
```bash
./zig-out/bin/cli programs/your_forth_program.golf
```
