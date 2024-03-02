
## Your third program
Up until now things have been easy! We also support function calls. Remember to clear up the stack if you mess with it.

```
function push_stack {
    assembly {
        PUSH0;
        POP;
    }
}

push_stack;
```

Run the the program with
```bash
./zig-out/bin/cli programs/your_third_program.golf
```
