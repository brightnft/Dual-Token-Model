// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

library Deployed {
  uint256 public constant METIS_SEPOLIA = 97;
  uint256 public constant METIS_ANDROMEDA = 660279;

  function bp() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0x5F0614F6Bd87Da34eB39f9242Fa57DbDBA910a98);
    }

    return address(0x0);
  }

  function yapesToken() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0xc08181aA5C0483BAd0C63Cd4f52bC584467e3f30);
    }

    return address(0x0);
  }

  function yointsToken() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0x2db66F65352872Bb679501324F4bC6264A7f496c);
    }

    return address(0x0);
  }

  function yapesYieldFarming() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0x6858a6c3484b7b033B748261e550FC20c479b063);
    }

    return address(0x0);
  }

  function routers() public view returns (address[] memory) {
    address[] memory r = new address[](1);

    if (block.chainid == METIS_SEPOLIA) {
      r[0] = address(0x0);
      return r;
    }

    r[0] = address(0x14679D1Da243B8c7d1A4c6d0523A2Ce614Ef027C);
    return r;
  }
}
