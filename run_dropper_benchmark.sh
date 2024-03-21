#!/bin/bash
set -e
rm -rf ./zig-cache
zig build --summary all
./zig-out/bin/cli ./programs/dropper_soloution.golf "deploy"
OPCODE=$(cat deploy.txt)
#CODE=$(cat ./benchmark/test/Challenge_template.sol)
sed -e "s/<TINY_EVM_LANGUAGE_OPCODE>/$OPCODE/g" ./benchmark/Challenge_template.sol > ./benchmark/test/Challenge.sol
#echo $CODE
cd benchmark && forge test -vvv
