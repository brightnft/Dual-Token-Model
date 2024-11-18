// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";
import { BaseScript } from "../Base.s.sol";
import { Deployed } from "../Deployed.s.sol";
import { Yoints } from "../../src/tokens/Yoints.sol";
import { LiquidityPrevention } from "../../src/BP/LiquidityPrevention.sol";

contract YointsCheckDataScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    Yoints yoints = Yoints(payable(Deployed.yointsToken()));
    console.log("totalSupply = %d", yoints.totalSupply());

    vm.stopBroadcast();
  }
}
