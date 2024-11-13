// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

library Deployed {
  uint256 public constant METIS_SEPOLIA = 59902;
  uint256 public constant METIS_ANDROMEDA = 1088;

  function bp() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0xe69A1F8462727a1c9c15bEA538caFE4B7963C4A5);
    }

    return address(0x0);
  }

  function addLiquidityBP() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0x0);
    }

    return address(0x0);
  }

  function yapesToken() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0x2ead3DDBbaE6147D53C1d5423a684530d568802C);
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

  function whitelist() public view returns (address[] memory) {
    address[] memory r = new address[](1);

    if (block.chainid == METIS_SEPOLIA) {
      r[0] = address(0xdB9f5dd645992Bb776Cca7Fed0a3879B9a29563D);
      return r;
    }

    r[0] = address(0x0);
    return r;
  }
}
