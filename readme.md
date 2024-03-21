![Bytecode is the way](http://web.archive.org/web/20221229034822if_/https://pbs.twimg.com/profile_banners/706491515527364610/1663160614/1500x500)
*Photo credit: [@high_byte](https://twitter.com/high_byte)*


## Preface
This compiler is kinda wack as it was more a golfing exercise and reason to play with Zig. I put more love into my [C compiler](https://github.com/2xic/tiny-c-compiler).

## Goal
I just wanted to create a simple golfing language that solves [dropper](https://github.com/paradigmxyz/paradigm-ctf-2023/blob/main/dropper/challenge/project/src/Challenge.sol) CTF challenge from [paradigm.xyz](https://ctf.paradigm.xyz/) and also a reason to play with zig. The best solutions requires [pre-computation](https://twitter.com/orenyomtov/status/1718856711887339863), but that isn't what we are trying to do here. The point is not to create the best solution, but create a **golfing** solution.

See [docs](./docs/readme.md) for some example programs.

| Solution on Dropper                                  | Score  |
| ---------------------------------------------------- | ------ |
| [Tiny evm language](programs/dropper_soloution.golf) | 955188 |
| [Naive solc](benchmark/src/BadSolution.sol)          | 970992 |

See [benchmark](./benchmark/) or run it yourself `./run_dropper_benchmark.sh`


## Todos 
These todo's will likely never happen, you want a good evm language ? Use [huff](https://docs.huff.sh/).

1. Code generation
   1. Nested functions call doesn't really work (the fallthrough logic is not optimal)
   2. If conditional jump destination can sometimes generate bad / invalid JUMPs.
   3. Validation / padding of PUSH argument values.
2. Zig code can likely be made more modular.

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
Note that we don't have any real unit tests
```
zig build test
```

We have some compiler tests
```
./e2e_test.sh
```
