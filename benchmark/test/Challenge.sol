// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Challenge, AirdropLike} from "../src/Challenge.sol";
import {BadSolution} from "../src/BadSolution.sol";

contract CounterTest is Test { 
    function setUp() public { }

    function testSoloutions() public {
        Challenge challenge_ = new Challenge();
        challenge_.deposit{value: 500 ether}();
        address challenge = address(challenge_);

        // Bad soloution ?
        BadSolution badSolution = new BadSolution(challenge);
        uint256 score = challenge_.submit(AirdropLike(address(badSolution)));
        console2.log("Bad soloution score: ");
        console2.logUint(score);

        // Update the seed of the challenge
        vm.roll(10);

        // Good soloution ?
        bytes memory bytecode = hex"6060566038565b5f516020511415600f57005b5f51600101805f526020028060405101358160605101355f5f5f5f84865af1586007016003565b565b5f600152600480350160405260243560040160605260405135602052586007016003565b5b605d6003600039605d6000f3";
        address golfSoloution = deployBytecodeContract(bytecode);

        uint256 goodScore = challenge_.submit(AirdropLike(golfSoloution));
        console2.log("Good soloution score: ");
        console2.logUint(goodScore);
    }

    function deployBytecodeContract(bytes memory bytecode) internal returns (address) {
        address golfSoloution;
        assembly {
            golfSoloution := create(0, add(bytecode, 0x20), mload(bytecode))
            if iszero(extcodesize(golfSoloution)) {
                revert(0, 0)
            }
        }
        
        return golfSoloution;
    }
}
