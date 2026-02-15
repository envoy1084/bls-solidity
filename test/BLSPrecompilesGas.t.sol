// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30 <0.9.0;

import {BLSPrecompiles} from "src/BLSPrecompiles.sol";

import {Test} from "forge-std/Test.sol";

import {console2 as console} from "forge-std/console2.sol";

contract BLSPrecompilesGas is Test {
    struct GasReport {
        string operation;
        uint256 gasUsed;
        uint256 precompileCost;
    }

    GasReport[] public gasReports;

    function _benchmarkG1Add() public {
        bytes memory input = vm.parseBytes(
            "0x0000000000000000000000000000000017f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb0000000000000000000000000000000008b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e100000000000000000000000000000000112b98340eee2777cc3c14163dea3ec97977ac3dc5c70da32e6e87578f44912e902ccef9efe28d4a78b8999dfbca942600000000000000000000000000000000186b28d92356c4dfec4b5201ad099dbdede3781f8998ddf929b4cd7756192185ca7b8f4ef7088f813270ac3d48868a21"
        );
        uint256 gasBefore = gasleft();
        BLSPrecompiles.g1Add(input);
        uint256 gasUsed = gasBefore - gasleft();

        gasReports.push(GasReport("g1Add", gasUsed, 375));
    }

    function _benchmarkG2Add() public {
        bytes memory input = vm.parseBytes(
            "0x00000000000000000000000000000000024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb80000000000000000000000000000000013e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e000000000000000000000000000000000ce5d527727d6e118cc9cdc6da2e351aadfd9baa8cbdd3a76d429a695160d12c923ac9cc3baca289e193548608b82801000000000000000000000000000000000606c4a02ea734cc32acd2b02bc28b99cb3e287e85a763af267492ab572e99ab3f370d275cec1da1aaa9075ff05f79be00000000000000000000000000000000103121a2ceaae586d240843a398967325f8eb5a93e8fea99b62b9f88d8556c80dd726a4b30e84a36eeabaf3592937f2700000000000000000000000000000000086b990f3da2aeac0a36143b7d7c824428215140db1bb859338764cb58458f081d92664f9053b50b3fbd2e4723121b68000000000000000000000000000000000f9e7ba9a86a8f7624aa2b42dcc8772e1af4ae115685e60abc2c9b90242167acef3d0be4050bf935eed7c3b6fc7ba77e000000000000000000000000000000000d22c3652d0dc6f0fc9316e14268477c2049ef772e852108d269d9c38dba1d4802e8dae479818184c08f9a569d878451"
        );

        uint256 gasBefore = gasleft();
        BLSPrecompiles.g2Add(input);
        uint256 gasUsed = gasBefore - gasleft();
        gasReports.push(GasReport("g2Add", gasUsed, 600));
    }

    function _benchmarkG1MSM() public {
        bytes memory input = vm.parseBytes(
            "0000000000000000000000000000000017f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb0000000000000000000000000000000008b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e10000000000000000000000000000000000000000000000000000000000000002"
        );

        uint256 gasBefore = gasleft();
        BLSPrecompiles.g1MSM(input);
        uint256 gasUsed = gasBefore - gasleft();

        gasReports.push(GasReport("g1MSM", gasUsed, 12000));
    }

    function _benchmarkG2MSM() public {
        bytes memory input = vm.parseBytes(
            "00000000000000000000000000000000024aa2b2f08f0a91260805272dc51051c6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb80000000000000000000000000000000013e02b6052719f607dacd3a088274f65596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e000000000000000000000000000000000ce5d527727d6e118cc9cdc6da2e351aadfd9baa8cbdd3a76d429a695160d12c923ac9cc3baca289e193548608b82801000000000000000000000000000000000606c4a02ea734cc32acd2b02bc28b99cb3e287e85a763af267492ab572e99ab3f370d275cec1da1aaa9075ff05f79be0000000000000000000000000000000000000000000000000000000000000002"
        );

        uint256 gasBefore = gasleft();
        BLSPrecompiles.g2MSM(input);
        uint256 gasUsed = gasBefore - gasleft();

        gasReports.push(GasReport("g2MSM", gasUsed, 22500));
    }

    function _benchmarkPairing() public {
        bytes memory input = vm.parseBytes(
            "0x000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );

        uint256 gasBefore = gasleft();
        BLSPrecompiles.pairing(input);
        uint256 gasUsed = gasBefore - gasleft();
        gasReports.push(GasReport("pairing", gasUsed, 70300));
    }

    function _benchmarkMapToG1() public {
        bytes memory input = vm.parseBytes(
            "0x00000000000000000000000000000000147e1ed29f06e4c5079b9d14fc89d2820d32419b990c1c7bb7dbea2a36a045124b31ffbde7c99329c05c559af1c6cc82"
        );

        uint256 gasBefore = gasleft();
        BLSPrecompiles.mapFpToG1(input);
        uint256 gasUsed = gasBefore - gasleft();
        gasReports.push(GasReport("mapToG1", gasUsed, 5500));
    }

    function _benchmarkMapToG2() public {
        bytes memory input = vm.parseBytes(
            "0x0000000000000000000000000000000007355d25caf6e7f2f0cb2812ca0e513bd026ed09dda65b177500fa31714e09ea0ded3a078b526bed3307f804d4b93b040000000000000000000000000000000002829ce3c021339ccb5caf3e187f6370e1e2a311dec9b75363117063ab2015603ff52c3d3b98f19c2f65575e99e8b78c"
        );

        uint256 gasBefore = gasleft();
        BLSPrecompiles.mapFp2ToG2(input);
        uint256 gasUsed = gasBefore - gasleft();
        gasReports.push(GasReport("mapToG2", gasUsed, 23800));
    }

    function test_benchmarkAll() public {
        _benchmarkG1Add();
        _benchmarkG2Add();
        _benchmarkG1MSM();
        _benchmarkG2MSM();
        _benchmarkPairing();
        _benchmarkMapToG1();
        _benchmarkMapToG2();

        console.log("Gas Reports (BLSPrecompiles.sol):");
        for (uint256 i = 0; i < gasReports.length; i++) {
            GasReport memory _gasReport = gasReports[i];
            console.log(
                string.concat("Operation: ", _gasReport.operation, " | Gas: ", vm.toString(_gasReport.gasUsed)),
                string.concat(
                    " | Precompile Cost: ",
                    vm.toString(_gasReport.precompileCost),
                    " | Overhead: ",
                    vm.toString(_gasReport.gasUsed - _gasReport.precompileCost)
                )
            );
        }
    }
}
