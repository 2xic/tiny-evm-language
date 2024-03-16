I just want to create a simple golfing language that solves [dropper](https://github.com/paradigmxyz/paradigm-ctf-2023/blob/main/dropper/challenge/project/src/Challenge.sol) CTF challenge from [paradigm.xyz](https://ctf.paradigm.xyz/) (and also a reason to play with zig). The best solutions requires [pre-computation](https://twitter.com/orenyomtov/status/1718856711887339863), but that isn't what we are trying to do here. The point is not to create the best solution, but create a solution.

See [docs](./docs/readme.md) for some example programs.

| Solution                                             | Score  |
| ---------------------------------------------------- | ------ |
| [Tiny evm language](programs/dropper_soloution.golf) | 955284 |
| [Naive solc](benchmark/src/BadSolution.sol)          | 973040 |

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
Note that we don't have any real unit tests
```
zig build test
```

We have some compiler tests
```
./e2e_test.sh
```