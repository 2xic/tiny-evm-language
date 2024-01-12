
## Your second program
We also have custom syntax! Sometimes oyu might want to 

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
