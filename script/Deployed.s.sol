// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

library Deployed {
  uint256 public constant METIS_SEPOLIA = 97;
  uint256 public constant METIS_ANDROMEDA = 660279;

  function bp() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0xf73AE159d0e7ed58a56FB0b6368f430C126EDdFA);
    }

    return address(0x0);
  }

  function yapesToken() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0x35C31EbbD9b2c6C5C0a0C1413d77706281bE407e);
    }

    return address(0x0);
  }

  function yointsToken() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0x2db66F65352872Bb679501324F4bC6264A7f496c);
    }

    return address(0x0);
  }

  function yapesStaking() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0x6858a6c3484b7b033B748261e550FC20c479b063);
    }

    return address(0x0);
  }
}
