// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import { Upgrades } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import { BaseScript } from "../Base.s.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract YapesStakingDeployScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    vm.stopBroadcast();
  }
}
