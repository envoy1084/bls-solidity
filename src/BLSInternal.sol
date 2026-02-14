// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library BLSInternal {
    /// @notice EIP-2537 precompile address for G1 point addition
    uint256 internal constant G1_ADD = 0x0b;

    /// @notice EIP-2537 precompile address for G1 multi-scalar multiplication
    uint256 internal constant G1_MSM = 0x0c;

    /// @notice EIP-2537 precompile address for G2 point addition
    uint256 internal constant G2_ADD = 0x0d;

    /// @notice EIP-2537 precompile address for G2 multi-scalar multiplication
    uint256 internal constant G2_MSM = 0x0e;

    /// @notice EIP-2537 precompile address for pairing check
    uint256 internal constant PAIRING = 0x0f;

    /// @notice EIP-2537 precompile address for Fp to G1 mapping
    uint256 internal constant MAP_FP_G1 = 0x10;

    /// @notice EIP-2537 precompile address for Fp2 to G2 mapping
    uint256 internal constant MAP_FP2_G2 = 0x11;

    function g1Add(uint256 ptr) internal view {
        assembly {
            let success := staticcall(gas(), G1_ADD, ptr, 256, ptr, 128)

            if iszero(success) { revert(0, 0) }

            if iszero(eq(returndatasize(), 128)) { revert(0, 0) }
        }
    }

    function g2Add(uint256 ptr) internal view {
        assembly {
            if iszero(staticcall(gas(), G2_ADD, ptr, 512, ptr, 256)) { revert(0, 0) }

            if iszero(eq(returndatasize(), 256)) { revert(0, 0) }
        }
    }

    function g1MSM(uint256 ptr, uint256 length) internal view {
        assembly {
            // Total size of input:
            // G1 point (128 bytes) * k
            // Scalar (32 bytes) * k
            // Total size: 160 * k bytes
            let inputSize := mul(length, 160)

            // staticcall(gas, address, argsOffset, argsSize, retOffset, retSize)
            // argsOffset: ptr
            // argsSize  : calculated inputSize
            // retOffset : ptr (Write output over input to save memory)
            // retSize   : 128 bytes (Result G1 point)
            if iszero(staticcall(gas(), G1_MSM, ptr, inputSize, ptr, 128)) { revert(0, 0) }

            if iszero(eq(returndatasize(), 128)) { revert(0, 0) }
        }
    }

    function g2MSM(uint256 ptr, uint256 length) internal view {
        assembly {
            // Length of input:
            // G2 point (256 bytes) * k
            // Scalar (32 bytes) * k
            // Total size: 288 * k bytes
            let inputSize := mul(length, 288)

            // staticcall(gas, address, argsOffset, argsSize, retOffset, retSize)
            // argsOffset: ptr
            // argsSize  : inputSize
            // retOffset : ptr (Write output in-place to save memory)
            // retSize   : 256 bytes (Result G2 point)
            if iszero(staticcall(gas(), G2_MSM, ptr, inputSize, ptr, 256)) { revert(0, 0) }

            // Defensive check
            if iszero(eq(returndatasize(), 256)) { revert(0, 0) }
        }
    }

    function pairing(uint256 ptr, uint256 length) internal view {
        assembly {
            // Total size of input:
            // G1 point (128 bytes) * k
            // G2 point (256 bytes) * k
            // Total size: 384 * k bytes
            let inputSize := mul(length, 384)

            // staticcall(gas, address, argsOffset, argsSize, retOffset, retSize)
            // argsOffset: ptr
            // argsSize  : inputSize
            // retOffset : ptr (Write output in-place)
            // retSize   : 32 bytes (The boolean result)
            if iszero(staticcall(gas(), PAIRING, ptr, inputSize, ptr, 32)) { revert(0, 0) } // Precompile failed/out of gas

            if iszero(eq(returndatasize(), 32)) { revert(0, 0) }
        }
    }

    function mapFpToG1(uint256 ptr) internal view {
        assembly {
            // staticcall(gas, address, argsOffset, argsSize, retOffset, retSize)
            // argsSize: 64 bytes (Fp element)
            // retSize:  128 bytes (G1 point)
            if iszero(staticcall(gas(), MAP_FP_G1, ptr, 64, ptr, 128)) { revert(0, 0) }

            if iszero(eq(returndatasize(), 128)) { revert(0, 0) }
        }
    }

    function mapFp2ToG2(uint256 ptr) internal view {
        assembly {
            // staticcall(gas, address, argsOffset, argsSize, retOffset, retSize)
            // argsSize: 128 bytes (Fp2 element)
            // retSize:  256 bytes (G2 point)
            if iszero(staticcall(gas(), MAP_FP2_G2, ptr, 128, ptr, 256)) { revert(0, 0) }

            if iszero(eq(returndatasize(), 256)) { revert(0, 0) }
        }
    }
}
