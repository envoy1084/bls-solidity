// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./PrecompileTestBase.sol";

import {BlsPrecompiles} from "src/BlsPrecompiles.sol";

contract MapFpToG1Test is PrecompileTestBase {
    function mapFpToG1(bytes memory input) external view returns (bytes memory result) {
        return BlsPrecompiles.mapFpToG1(input);
    }

    function test_mapFpToG1_validVectors() public {
        vm.pauseGasMetering();
        string memory path = "test/vectors/map_fp_to_G1_bls.json";
        string memory json = vm.readFile(path);

        CaseValid[] memory cases = abi.decode(vm.parseJson(json), (CaseValid[]));

        for (uint256 i = 0; i < cases.length; i++) {
            CaseValid memory _case = cases[i];
            bytes memory input = vm.parseBytes(string.concat("0x", _case.Input));
            bytes memory expected = vm.parseBytes(string.concat("0x", _case.Expected));
            bytes memory result = this.mapFpToG1(input);

            assertEq(result, expected);
        }

        vm.resumeGasMetering();
    }

    function test_mapFpToG1_invalidVectors() public {
        vm.pauseGasMetering();
        string memory path = "test/vectors/fail-map_fp_to_G1_bls.json";
        string memory json = vm.readFile(path);

        CaseInvalid[] memory cases = abi.decode(vm.parseJson(json), (CaseInvalid[]));

        for (uint256 i = 0; i < cases.length; i++) {
            CaseInvalid memory _case = cases[i];
            bytes memory input = vm.parseBytes(string.concat("0x", _case.Input));

            vm.expectRevert();
            this.mapFpToG1(input);
        }

        vm.resumeGasMetering();
    }
}
