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
//        BadSolution badSolution = new BadSolution(challenge);
//        uint256 score = challenge_.submit(AirdropLike(address(badSolution)));
//        console2.log("Bad soloution score: ");
//        console2.logUint(score);

        // Update the seed of the challenge
        vm.roll(10);

        // Good soloution ?
        bytes memory _bytecode = hex"60f6566038565b5f516020511415600f57005b5f51600101805f526020028060405101358160605101355f5f5f5f84865af1586007016003565b565b5f3560e01c63c1a380061460885801575f3560e01c6382947abe1460385801575f3560e01c632d4be47014601f5801575f3560e01c638c10f4fc146008580157602b5f55005b6004355f55005b5f545f5260205ff35b7f23b872dd000000000000000000000000000000000000000000000000000000005f525f54600452306024526064356044526004355f5f60805f5f855af1005b5f600152600480350160405260243560040160605260405135602052586007016003565b5b60f3600360003960f36000f3";
        bytes memory bytecode = abi.encodePacked(_bytecode, abi.encode(challenge));
        
        console2.logBytes(abi.encode(challenge));
        console2.logBytes(bytecode);
        address golfSoloution = deployBytecodeContract(bytecode);

        GoodDropper(golfSoloution).setDropper(challenge);
        console2.log(GoodDropper(golfSoloution).getDropper());

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
