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

        testCustomBytecode(challenge_, "Tiny evm language score: ", hex"610219566038565b5f516020511415600f57005b5f51600101805f526020028060405101358160605101355f5f5f5f84865af1586007016003565b565b607e565b5f516020511415604857005b5f51600101805f5260200280604051013560a45280606051013560c45260a0515f5f604460a05f6080515af158600701603c565b565b60c4565b5f516020511415608e57005b5f51600101805f5260200280604051013560c45280606051013560e45260a0515f5f60c860a05f6080515af1586007016082565b565b5f3560e01c63c1a380061461011d5801575f3560e01c6382947abe1460845801575f3560e01c632d4be47014606b5801575f3560e01c638c10f4fc1460545801575f5f5260243560040180604052604435600401606052356020527f23b872dd0000000000000000000000000000000000000000000000000000000060a0525f5460a452600435608052586007016082565b5b6004355f55005b5f545f5260205ff35b7f23b872dd000000000000000000000000000000000000000000000000000000005f525f5460045230602452606435604452600435806080525f5f60805f5f855af15f5f5260243560040180604052604435600401606052356020527fa9059cbb0000000000000000000000000000000000000000000000000000000060a05258600701603c565b5b5f600152600480350160405260243560040160605260405135602052586007016003565b5b61021560046000396102156000f3");
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
