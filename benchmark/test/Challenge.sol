// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Challenge, AirdropLike} from "../src/Challenge.sol";
import {BadSolution} from "../src/BadSolution.sol";

contract CounterTest is Test {
    function setUp() public {}

    function test_Increment() public {
        Challenge challenge_ = new Challenge();
        challenge_.deposit{value: 500 ether}();
        address challenge = address(challenge_);
        // Now I got the address 
        BadSolution badSolution = new BadSolution(challenge);
        uint256 score = challenge_.submit(AirdropLike(address(badSolution)));
        console2.log("Score: ");
        console2.logUint(score);
    }
}
