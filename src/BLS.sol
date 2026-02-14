// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BLSInternal} from "./BLSInternal.sol";

library BLS {
    error LengthMismatch();
    error EmptyInput();

    struct Fp {
        uint256 a0;
        uint256 a1;
    }

    struct Fp2 {
        Fp c0;
        Fp c1;
    }

    struct G1 {
        Fp x;
        Fp y;
    }

    struct G2 {
        Fp2 x;
        Fp2 y;
    }

    type Fr is uint256;

    function g1Generator() internal pure returns (G1 memory) {
        return G1({
            x: Fp({
                a0: 0x0000000000000000000000000000000017f1d3a73197d7942695638c4fa9ac0fc,
                a1: 0x3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb
            }),
            y: Fp({
                a0: 0x0000000000000000000000000000000008b3f481e3aaa0f1a09e30ed741d8ae4,
                a1: 0xfcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1
            })
        });
    }

    function g2Generator() internal pure returns (G2 memory) {
        return G2({
            x: Fp2({
                c0: Fp({
                    a0: 0x00000000000000000000000000000000024aa2b2f08f0a91260805272dc51051,
                    a1: 0xc6e47ad4fa403b02b4510b647ae3d1770bac0326a805bbefd48056c8c121bdb8
                }),
                c1: Fp({
                    a0: 0x0000000000000000000000000000000013e02b6052719f607dacd3a088274f65,
                    a1: 0x596bd0d09920b61ab5da61bbdc7f5049334cf11213945d57e5ac7d055d042b7e
                })
            }),
            y: Fp2({
                c0: Fp({
                    a0: 0x000000000000000000000000000000000ce5d527727d6e118cc9cdc6da2e351a,
                    a1: 0xadfd9baa8cbdd3a76d429a695160d12c923ac9cc3baca289e193548608b82801
                }),
                c1: Fp({
                    a0: 0x000000000000000000000000000000000606c4a02ea734cc32acd2b02bc28b99,
                    a1: 0xcb3e287e85a763af267492ab572e99ab3f370d275cec1da1aaa9075ff05f79be
                })
            })
        });
    }

    function g1Infinity() internal pure returns (G1 memory) {
        return G1({x: Fp({a0: 0, a1: 0}), y: Fp({a0: 0, a1: 0})});
    }

    function g2Infinity() internal pure returns (G2 memory) {
        return G2({
            x: Fp2({c0: Fp({a0: 0, a1: 0}), c1: Fp({a0: 0, a1: 0})}),
            y: Fp2({c0: Fp({a0: 0, a1: 0}), c1: Fp({a0: 0, a1: 0})})
        });
    }

    function g1Add(G1 memory a, G1 memory b) internal view returns (G1 memory result) {
        uint256 ptr;
        assembly {
            ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x100))
        }

        _writeG1ToMemory(a, ptr);
        _writeG1ToMemory(b, ptr + 128);

        BLSInternal.g1Add(ptr);

        return _readG1FromMemory(ptr);
    }

    function g2Add(G2 memory a, G2 memory b) internal view returns (G2 memory result) {
        uint256 ptr;
        assembly {
            // Allocate 512 bytes scratch space for two G2 points
            ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x200))
        }

        _writeG2ToMemory(a, ptr);
        _writeG2ToMemory(b, ptr + 256);

        BLSInternal.g2Add(ptr);

        return _readG2FromMemory(ptr);
    }

    function g1MSM(G1[] memory points, Fr[] memory scalars) internal view returns (G1 memory result) {
        uint256 len = points.length;
        if (len != scalars.length) revert LengthMismatch();
        if (len == 0) revert EmptyInput();

        uint256 ptr;

        assembly {
            // Total size of input:
            // G1 point (128 bytes) * k
            // Scalar (32 bytes) * k
            // Total size: 160 * k bytes, (k=len)
            let totalSize := mul(len, 160)

            ptr := mload(0x40)
            mstore(0x40, add(ptr, totalSize))
        }

        unchecked {
            uint256 currentDest = ptr;
            for (uint256 i = 0; i < len; i++) {
                // Copy G1 point
                _writeG1ToMemory(points[i], currentDest);
                // Copy Scalar s[i] to currentDest + 128
                // Note: scalars are simple uint256, so we just mstore
                uint256 s = Fr.unwrap(scalars[i]);
                assembly {
                    mstore(add(currentDest, 128), s)
                }

                // Advance cursor by 160 bytes
                currentDest += 160;
            }
        }

        BLSInternal.g1MSM(ptr, len);

        return _readG1FromMemory(ptr);
    }

    function g2MSM(G2[] memory points, Fr[] memory scalars) internal view returns (G2 memory result) {
        uint256 len = points.length;
        if (len != scalars.length) revert LengthMismatch();
        if (len == 0) revert EmptyInput();

        uint256 ptr;

        assembly {
            // Total size needed: len * 288 bytes
            let totalSize := mul(len, 288)

            // Allocate scratch space
            ptr := mload(0x40)
        }

        unchecked {
            uint256 currentDest = ptr;

            for (uint256 i = 0; i < len; i++) {
                _writeG2ToMemory(points[i], currentDest);
                uint256 s = Fr.unwrap(scalars[i]);

                assembly {
                    mstore(add(currentDest, 256), s)
                }

                currentDest += 288;
            }
        }

        BLSInternal.g2MSM(ptr, len);

        return _readG2FromMemory(ptr);
    }

    function pairing(G1[] memory a, G2[] memory b) internal view returns (bool) {
        uint256 len = a.length;
        if (len != b.length) revert LengthMismatch();
        if (len == 0) revert EmptyInput();

        uint256 ptr;

        assembly {
            // Total size needed: len * 384 bytes
            let totalSize := mul(len, 384)

            // Allocate scratch space
            ptr := mload(0x40)
            mstore(0x40, add(ptr, totalSize))
        }

        unchecked {
            uint256 currentDest = ptr;

            for (uint256 i = 0; i < len; i++) {
                _writeG1ToMemory(a[i], currentDest);
                _writeG2ToMemory(b[i], currentDest + 128);

                // Move forward by 384 bytes (128 + 256)
                currentDest += 384;
            }
        }

        BLSInternal.pairing(ptr, len);

        bool isValid;
        assembly {
            isValid := eq(mload(ptr), 1)
        }

        return isValid;
    }

    function mapToG1(Fp memory x) internal view returns (G1 memory result) {
        uint256 ptr;

        assembly {
            // Allocate Scratch space
            // Input size: 64 bytes
            // Output size: 128 bytes
            // Allocate 128 bytes, first 64 bytes will be used for input
            ptr := mload(0x40)
            mstore(0x40, add(ptr, 128))

            // Fp is a struct of two uint256s. We dereference the struct pointer
            // and copy the two words into the first 64 bytes of our scratch space.
            mstore(ptr, mload(x)) // x.a0 -> ptr
            mstore(add(ptr, 32), mload(add(x, 32))) // x.a1 -> ptr + 32
        }

        BLSInternal.mapFpToG1(ptr);

        return _readG1FromMemory(ptr);
    }

    function mapToG2(Fp2 memory x) internal view returns (G2 memory result) {
        uint256 ptr;

        assembly {
            // Allocate Scratch space
            // Input size: 128 bytes
            // Output size: 256 bytes
            // We allocate 256 bytes, first 128 bytes will be used for input
            ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x100))

            // 2. ENCODE INPUT (Fp2 -> Memory)
            // Fp2 contains two Fp structs (c0, c1).
            // We load their pointers, then copy their actual values (a0, a1).
            let c0_ptr := mload(x) // Pointer to x.c0
            let c1_ptr := mload(add(x, 32)) // Pointer to x.c1

            // Write x.c0 (64 bytes)
            mstore(ptr, mload(c0_ptr)) // x.c0.a0 -> ptr
            mstore(add(ptr, 32), mload(add(c0_ptr, 32))) // x.c0.a1 -> ptr + 32

            // Write x.c1 (64 bytes)
            mstore(add(ptr, 64), mload(c1_ptr)) // x.c1.a0 -> ptr + 64
            mstore(add(ptr, 96), mload(add(c1_ptr, 32))) // x.c1.a1 -> ptr + 96
        }

        // Reads the 128 bytes we just wrote, and overwrites with 256 bytes of G2 data.
        BLSInternal.mapFp2ToG2(ptr);

        return _readG2FromMemory(ptr);
    }

    function _writeG1ToMemory(G1 memory p, uint256 dest) internal pure {
        assembly {
            // Dereference struct pointers to get raw Fp data locations
            let x_ptr := mload(p)
            let y_ptr := mload(add(p, 0x20))

            // Write x-coordinate (64 bytes)
            mstore(dest, mload(x_ptr))
            mstore(add(dest, 0x20), mload(add(x_ptr, 0x20)))

            // Write y-coordinate (64 bytes)
            mstore(add(dest, 0x40), mload(y_ptr))
            mstore(add(dest, 0x60), mload(add(y_ptr, 0x20)))
        }
    }

    function _readG1FromMemory(uint256 ptr) internal pure returns (G1 memory result) {
        assembly {
            // Allocate 64 bytes for G1 struct (two pointers)
            result := mload(0x40)
            mstore(0x40, add(result, 0x40))

            // Set result.x to point to data at ptr
            mstore(result, ptr)

            // Set result.y to point to data at ptr+0x40
            mstore(add(result, 0x20), add(ptr, 0x40))
        }
    }

    function _writeG2ToMemory(G2 memory p, uint256 dest) internal pure {
        assembly {
            // Load Fp2 pointers from G2 struct
            let x_ptr := mload(p)
            let y_ptr := mload(add(p, 0x20))

            // Serialize x-coordinate (Fp2 = 128 bytes)
            // x.c0 (real part)
            let c0_ptr := mload(x_ptr)
            let c1_ptr := mload(add(x_ptr, 0x20))
            mstore(dest, mload(c0_ptr))
            mstore(add(dest, 0x20), mload(add(c0_ptr, 0x20)))
            // x.c1 (imaginary part)
            mstore(add(dest, 0x40), mload(c1_ptr))
            mstore(add(dest, 0x60), mload(add(c1_ptr, 0x20)))

            // Serialize y-coordinate (Fp2 = 128 bytes) at dest+0x80
            c0_ptr := mload(y_ptr)
            c1_ptr := mload(add(y_ptr, 0x20))
            let y_dest := add(dest, 0x80)
            mstore(y_dest, mload(c0_ptr))
            mstore(add(y_dest, 0x20), mload(add(c0_ptr, 0x20)))
            mstore(add(y_dest, 0x40), mload(c1_ptr))
            mstore(add(y_dest, 0x60), mload(add(c1_ptr, 0x20)))
        }
    }

    function _readG2FromMemory(uint256 ptr) internal pure returns (G2 memory result) {
        assembly {
            // Allocate 192 bytes for struct hierarchy:
            // - 64 bytes for G2 struct
            // - 64 bytes for x Fp2 struct
            // - 64 bytes for y Fp2 struct
            let freeMem := mload(0x40)
            mstore(0x40, add(freeMem, 0xC0))

            // Layout pointers
            result := freeMem
            let x_struct := add(freeMem, 0x40)
            let y_struct := add(freeMem, 0x80)

            // Link G2 -> Fp2 structs
            mstore(result, x_struct)
            mstore(add(result, 0x20), y_struct)

            // Link x Fp2 -> data at ptr
            mstore(x_struct, ptr)
            mstore(add(x_struct, 0x20), add(ptr, 0x40))

            // Link y Fp2 -> data at ptr+0x80
            mstore(y_struct, add(ptr, 0x80))
            mstore(add(y_struct, 0x20), add(ptr, 0xC0))
        }
    }
}
