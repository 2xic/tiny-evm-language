I just want to create a simple golfing language that solves [dropper](https://github.com/paradigmxyz/paradigm-ctf-2023/blob/main/dropper/challenge/project/src/Challenge.sol) CTF challenge from paradigmxyz (and also a reason to play with zig)

See [docs](./docs/readme.md) for some example programs


![Bytecode is the way](http://web.archive.org/web/20221229034822if_/https://pbs.twimg.com/profile_banners/706491515527364610/1663160614/1500x500)

(photo from [@high_byte](https://twitter.com/high_byte))

## Install (Ubuntu)

```
snap install zig --classic --beta
```

## Build
```
zig build --summary all
```

## Run
```
./zig-out/bin/cli [path] 
```

## Test 

```
zig build test
```



## Nice Resources used 
- https://nathancraddock.com/blog/thoughts-on-zig-test/
