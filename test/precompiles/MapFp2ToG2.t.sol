// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./PrecompileTestBase.sol";

import {BlsPrecompiles} from "src/BlsPrecompiles.sol";

contract MapFp2ToG2Test is PrecompileTestBase {
    function mapFp2ToG2(bytes memory input) external view returns (bytes memory result) {
        return BlsPrecompiles.mapFp2ToG2(input);
    }

    function test_mapFp2ToG2_validVectors() public {
        vm.pauseGasMetering();
        string memory path = "test/vectors/map_fp2_to_G2_bls.json";
        string memory json = vm.readFile(path);

        CaseValid[] memory cases = abi.decode(vm.parseJson(json), (CaseValid[]));

        for (uint256 i = 0; i < cases.length; i++) {
            CaseValid memory _case = cases[i];
            bytes memory input = vm.parseBytes(string.concat("0x", _case.Input));
            bytes memory expected = vm.parseBytes(string.concat("0x", _case.Expected));
            bytes memory result = this.mapFp2ToG2(input);

            assertEq(result, expected);
        }

        vm.resumeGasMetering();
    }

    function test_mapFp2ToG2_invalidVectors() public {
        vm.pauseGasMetering();
        string memory path = "test/vectors/fail-map_fp2_to_G2_bls.json";
        string memory json = vm.readFile(path);

        CaseInvalid[] memory cases = abi.decode(vm.parseJson(json), (CaseInvalid[]));

        for (uint256 i = 0; i < cases.length; i++) {
            CaseInvalid memory _case = cases[i];
            bytes memory input = vm.parseBytes(string.concat("0x", _case.Input));

            vm.expectRevert();
            this.mapFp2ToG2(input);
        }

        vm.resumeGasMetering();
    }
}
