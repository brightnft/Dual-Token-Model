// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

library Deployed {
  uint256 public constant METIS_SEPOLIA = 59902;
  uint256 public constant METIS_ANDROMEDA = 1088;

  function bp() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0xf848cd5EaD8F7bee0Cc87553D170891b13B0fc97);
    }

    return address(0x0);
  }

  function lp() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0xd7B833b5bBd59C00f020c72d9B7EABE5C663d7bb);
    }

    return address(0x0);
  }

  function yapesToken() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0xdd38F7e58621A25F616F03851440f8d932D58753);
    }

    return address(0x0);
  }

  function yointsToken() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0x663A16A1c4Bb84A5f43a7CF4b761Feb2cC4c64b5);
    }

    return address(0x0);
  }

  function yapesStaking() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0x530e61D5201c5683Ce443f8fdc6Bb46b41066489);
    }

    return address(0x0);
  }

  function yapesYieldFarming() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0x0);
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

  function blacklist() public view returns (address[] memory) {
    address[] memory r = new address[](1);

    if (block.chainid == METIS_SEPOLIA) {
      r[0] = address(0x0);
      return r;
    }

    r[0] = address(0x0);
    return r;
  }
}
