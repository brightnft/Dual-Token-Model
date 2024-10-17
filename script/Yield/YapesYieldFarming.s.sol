// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";
import { BaseScript } from "../Base.s.sol";
import { Deployed } from "../Deployed.s.sol";
import { YapesYieldFarming } from "../../src/yield/YapesYieldFarming.sol";

contract YapesYieldFarmingScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    address yapesYieldFarmingAddress = Deployed.yapesYieldFarming();
    YapesYieldFarming mb = YapesYieldFarming(payable(yapesYieldFarmingAddress));

    vm.stopBroadcast();
  }
}
