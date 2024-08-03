// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import { Script } from "forge-std/Script.sol";

contract BaseScript is Script {
  uint256 public constant METIS_SEPOLIA = 59902;
  uint256 public constant METIS_ANDROMEDA = 1088;

  function get_pk() public view returns (uint256) {
    if (block.chainid == METIS_SEPOLIA) {
      return vm.envUint("METIS_SEPOLIA");
    } else {
      return vm.envUint("METIS_ANDROMEDA");
    }
  }
}
