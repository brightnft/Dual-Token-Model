// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";
import { BaseScript } from "../Base.s.sol";
import { Deployed } from "../Deployed.s.sol";
import { Yapes } from "../../src/tokens/Yapes.sol";
import { Yoints } from "../../src/tokens/Yoints.sol";
import { BotPrevention } from "../../src/BP/BotPrevention.sol";
import { AddLiquidityPrevention } from "../../src/BP/AddLiquidityPrevention.sol";

contract YapesDeployScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    // 1. deploy bot prevention
    BotPrevention bp = new BotPrevention();
    console.log("BotPrevention is deployed to %s", address(bp));

    // 2. deploy yapes token
    Yapes yapes = new Yapes(address(bp));
    console.log("Yapes is deployed to %s", address(yapes));

    vm.stopBroadcast();
  }
}

contract YointsDeployScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    // 1. deploy add liquidity prevention
    // 1.1. deploy contract
    AddLiquidityPrevention bp = new AddLiquidityPrevention();
    console.log("AddLiquidityPrevention is deployed to %s", address(bp));

    // 1.2. add Hecules routers
    bp.addRouters(Deployed.routers());

    // 2. deploy yoints token
    Yoints yoints = new Yoints(address(bp));
    console.log("Yoints is deployed to %s", address(yoints));

    vm.stopBroadcast();
  }
}
