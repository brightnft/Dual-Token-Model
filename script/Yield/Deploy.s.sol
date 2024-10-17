// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";
import { Upgrades, Options } from "openzeppelin-foundry-upgrades/Upgrades.sol";
import { YapesYieldFarming } from "../../src/yield/YapesYieldFarming.sol";
import { BaseScript } from "../Base.s.sol";
import { Deployed } from "../Deployed.s.sol";

contract YapesYieldFarmingDeployScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    // configuration
    address depositToken = Deployed.yapesToken();
    address rewardToken = Deployed.yapesToken();
    uint256 rewardPerBlock = 10_000_000;
    uint256 startBlock = 0;
    uint256 endBlock = 1;

    Options memory opts;
    opts.unsafeSkipAllChecks = true;
    address proxy = Upgrades.deployUUPSProxy(
      "YapesYieldFarming.sol",
      abi.encodeCall(YapesYieldFarming.initialize, (depositToken, rewardToken, rewardPerBlock, startBlock, endBlock)),
      opts
    );

    console.log("YapesYieldFarming is deployed to %s", proxy);

    vm.stopBroadcast();
  }
}
