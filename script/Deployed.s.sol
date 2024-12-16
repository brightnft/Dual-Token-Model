// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

library Deployed {
  uint256 public constant METIS_SEPOLIA = 59902;
  uint256 public constant METIS_ANDROMEDA = 1088;
  uint256 public constant OP_SEPOLIA = 11155420;

  function bp() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0xf848cd5EaD8F7bee0Cc87553D170891b13B0fc97);
    }
    if (block.chainid == OP_SEPOLIA) {
      return address(0x5C24BFda3cbeFcF4B2b3B8572df4388830Cd75D0);
    }

    return address(0x0);
  }

  function lp() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0xd7B833b5bBd59C00f020c72d9B7EABE5C663d7bb);
    }
    if (block.chainid == OP_SEPOLIA) {
      return address(0x31338Eb055fC6D0bD9D1Fd6f6626f862fD68C8e1);
    }

    return address(0x0);
  }

  function yapesToken() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0xdd38F7e58621A25F616F03851440f8d932D58753);
    }
    if (block.chainid == OP_SEPOLIA) {
      return address(0xcE3af7532e7e129fb4858723ac69C27A4165e6F7);
    }

    return address(0x0);
  }

  function yointsToken() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0x663A16A1c4Bb84A5f43a7CF4b761Feb2cC4c64b5);
    }
    if (block.chainid == OP_SEPOLIA) {
      return address(0x391F3543D989d029E2478597692CA3371F9df6EC);
    }

    return address(0x0);
  }

  function yapesStaking() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0x530e61D5201c5683Ce443f8fdc6Bb46b41066489);
    }
    if (block.chainid == OP_SEPOLIA) {
      return address(0x60ca1d9186608f7239E46F0B2A5Bb0571D6de479);
    }

    return address(0x0);
  }

  function yapesYieldFarming() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0x0);
    }
     if (block.chainid == OP_SEPOLIA) {
      return address(0xCFF0D4be1Dfa03766A177010E3fA0303Be6dDC1f);
    }

    return address(0x0);
  }

  function lpToken() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0x0);
    }
    if (block.chainid == OP_SEPOLIA) {
      return address(0x33083699d4F2B36fec128E286c8af99ed153E104);
    }

    return address(0x0);
  }

  function revenueShareContract() public view returns (address) {
    if (block.chainid == METIS_SEPOLIA) {
      return address(0xc5cA77775325d4d7C943daC5312B54980204C861);
    }
    if (block.chainid == OP_SEPOLIA) {
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
    if (block.chainid == OP_SEPOLIA) {
      r[0] = address(0xF0d57611481e1d400972747E3BbA89DaeEb3f3c8);
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
