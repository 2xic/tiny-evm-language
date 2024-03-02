
## Your second program
We also have custom syntax! Sometimes you might want to 

```
if(sighash == 0xdeadbeef){
    assembly {
        PUSH0;
    }
} else {
    assembly {
        STOP;
    }
}
```

Sighash is a keyword and will extract the first 4 bytes of the calldata.

Run the the program with
```bash
./zig-out/bin/cli programs/your_second_program.golf
```
