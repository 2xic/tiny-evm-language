// USE TEMPLATE FILE TO MODIFY

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Challenge, AirdropLike} from "../src/Challenge.sol";
import {BadSolution} from "../src/BadSolution.sol";
import {stdStorage, StdStorage} from "forge-std/Test.sol";              

interface GoodDropper {
    function getDropper() external returns (address);
    function setDropper(address) external;
}

contract CounterTest is Test { 
    function setUp() public { }

    function testSoloutions() public {
        Challenge challenge_ = new Challenge();
        challenge_.deposit{value: 500 ether}();
        address challenge = address(challenge_);

        // Bad soloution ?
        BadSolution badSolution = new BadSolution(challenge);
        uint256 score = challenge_.submit(AirdropLike(address(badSolution)));
        console2.log("Solc score: ");
        console2.logUint(score);
        // Update the seed of the challenge
        vm.roll(10);

        testCustomBytecode(challenge_, "Tiny evm language score: ", hex"<TINY_EVM_LANGUAGE_OPCODE>");
    }

    function testCustomBytecode(Challenge challenge_, string memory name, bytes memory bytecode) internal {
        address golfSoloution = deployBytecodeContract(bytecode);

        GoodDropper(golfSoloution).setDropper(address(challenge_));

        uint256 score = challenge_.submit(AirdropLike(golfSoloution));
        console2.log(name);
        console2.logUint(score);
        vm.roll(1);
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
