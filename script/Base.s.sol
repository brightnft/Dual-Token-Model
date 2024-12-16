// SPDX-License-Identifier: MIT
pragma solidity >=0.8.25 <0.9.0;

import "../lib/forge-std/src/Script.sol";

contract BaseScript is Script {
  uint256 public constant METIS_SEPOLIA = 59902;
  uint256 public constant METIS_ANDROMEDA = 1088;
  uint256 public constant OP_SEPOLIA = 11155420;

  function get_pk() public view returns (uint256) {
    if (block.chainid == METIS_SEPOLIA) {
      return vm.envUint("METIS_SEPOLIA");
    } if (block.chainid == METIS_ANDROMEDA) {
      return vm.envUint("METIS_ANDROMEDA");
    } else{
      return vm.envUint("OP_SEPOLIA");
    }
  }
}
