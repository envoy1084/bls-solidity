// SPDX-License-Identifier: MIT
pragma solidity >=0.8.30 <0.9.0;

import {BLS} from "src/BLS.sol";

import {Test} from "forge-std/Test.sol";

import {console2 as console} from "forge-std/console2.sol";

contract BLSGasTest is Test {
    struct GasReport {
        string operation;
        uint256 gasUsed;
        uint256 precompileCost;
    }

    GasReport[] public gasReports;

    function _benchmarkG1Add() public {
        BLS.G1 memory _a = BLS.g1Generator();
        uint256 gasBefore = gasleft();
        BLS.g1Add(_a, _a);
        uint256 gasUsed = gasBefore - gasleft();

        gasReports.push(GasReport("g1Add", gasUsed, 375));
    }

    function _benchmarkG2Add() public {
        BLS.G2 memory _b = BLS.g2Generator();

        uint256 gasBefore = gasleft();
        BLS.g2Add(_b, _b);
        uint256 gasUsed = gasBefore - gasleft();
        gasReports.push(GasReport("g2Add", gasUsed, 600));
    }

    function _benchmarkG1MSM() public {
        BLS.G1[] memory points = new BLS.G1[](1);
        points[0] = BLS.g1Generator();
        BLS.Fr[] memory scalars = new BLS.Fr[](1);
        scalars[0] = BLS.Fr.wrap(2);

        uint256 gasBefore = gasleft();
        BLS.g1MSM(points, scalars);
        uint256 gasUsed = gasBefore - gasleft();

        gasReports.push(GasReport("g1MSM", gasUsed, 12000));
    }

    function _benchmarkG2MSM() public {
        BLS.G2[] memory points = new BLS.G2[](1);
        points[0] = BLS.g2Generator();
        BLS.Fr[] memory scalars = new BLS.Fr[](1);
        scalars[0] = BLS.Fr.wrap(2);

        uint256 gasBefore = gasleft();
        BLS.g2MSM(points, scalars);
        uint256 gasUsed = gasBefore - gasleft();

        gasReports.push(GasReport("g2MSM", gasUsed, 22500));
    }

    function _benchmarkPairing() public {
        BLS.G1[] memory g1Points = new BLS.G1[](1);
        g1Points[0] = BLS.g1Infinity();
        BLS.G2[] memory g2Points = new BLS.G2[](1);
        g2Points[0] = BLS.g2Infinity();

        uint256 gasBefore = gasleft();
        BLS.pairing(g1Points, g2Points);
        uint256 gasUsed = gasBefore - gasleft();
        gasReports.push(GasReport("pairing", gasUsed, 70300));
    }

    function _benchmarkMapToG1() public {
        BLS.Fp memory x = BLS.g1Generator().x;

        uint256 gasBefore = gasleft();
        BLS.mapToG1(x);
        uint256 gasUsed = gasBefore - gasleft();
        gasReports.push(GasReport("mapToG1", gasUsed, 5500));
    }

    function _benchmarkMapToG2() public {
        BLS.Fp2 memory x = BLS.g2Generator().x;

        uint256 gasBefore = gasleft();
        BLS.mapToG2(x);
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

        console.log("Gas Reports (BLS.sol):");
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
