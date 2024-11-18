// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";
import { BaseScript } from "../Base.s.sol";
import { Deployed } from "../Deployed.s.sol";
import { YapesStaking } from "../../src/revenue/YapesStaking.sol";
import { Yapes } from "../../src/tokens/Yapes.sol";
import { iOVM_L1BlockNumber } from "../../src/yield/iOVM_L1BlockNumber.sol";

contract YapesStakingScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    YapesStaking yapesStaking = YapesStaking(payable(Deployed.yapesStaking()));
    Yapes yapes = Yapes(payable(Deployed.yapesToken()));

    uint256 amount = 100 * 1e18;

    // 1. approve Yapes token
    yapes.approve(address(Deployed.yapesStaking()), amount);

    // 2. stake
    yapesStaking.stake(amount);

    vm.stopBroadcast();
  }
}

contract YapesStakingCheckDataScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    YapesStaking yapesStaking = YapesStaking(payable(Deployed.yapesStaking()));
    console.log("yapes = %s", address(yapesStaking.yapesToken()));
    console.log("yoints = %s", address(yapesStaking.yointsToken()));

    vm.stopBroadcast();
  }
}
