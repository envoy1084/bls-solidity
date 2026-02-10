// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";

import {Counter} from "src/Counter.sol";
import {SetUp} from "test/common/SetUp.sol";

contract CounterFuzzTest is Test, SetUp {
    function setUp() public override {
        super.setUp();
    }

    function testFuzz_setNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
