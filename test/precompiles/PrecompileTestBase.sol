// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";

struct CaseValid {
    string Expected;
    uint256 Gas;
    string Input;
    string Name;
    bool NoBenchmark;
}

struct CaseInvalid {
    string ExpectedError;
    string Input;
    string Name;
}

contract PrecompileTestBase is Test {}
