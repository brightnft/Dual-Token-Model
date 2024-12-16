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
    address depositToken = Deployed.lpToken(); // LP Token or Yoints Token
    address rewardToken = Deployed.yapesToken();
    uint256 rewardPerBlock = 4.62962962963 * 10**18;
    uint256 startBlock = 7174000;
    uint256 endBlock = 7390000;

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
