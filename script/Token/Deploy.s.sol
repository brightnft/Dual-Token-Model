// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";
import { BaseScript } from "../Base.s.sol";
import { Deployed } from "../Deployed.s.sol";
import { Yapes } from "../../src/tokens/Yapes.sol";
import { Yoints } from "../../src/tokens/Yoints.sol";
import { BotPrevention } from "../../src/BP/BotPrevention.sol";
import { LiquidityPrevention } from "../../src/BP/LiquidityPrevention.sol";

contract YapesDeployScript is BaseScript {
  bytes32 public constant PROTECTED_ROLE = keccak256("PROTECTED_ROLE");

  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    // 1. deploy bot prevention
    BotPrevention bp = new BotPrevention();
    console.log("BotPrevention is deployed to %s", address(bp));

    // 2. deploy yapes token
    Yapes yapes = new Yapes(address(bp));
    console.log("Yapes is deployed to %s", address(yapes));

    // 3. grant role
    bp.grantRole(PROTECTED_ROLE, address(yapes));

    vm.stopBroadcast();
  }
}

contract YointsDeployScript is BaseScript {
  bytes32 public constant PROTECTED_ROLE = keccak256("PROTECTED_ROLE");

  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    // 1. deploy liquidity prevention
    // 1.1. deploy contract
    LiquidityPrevention lp = new LiquidityPrevention();
    console.log("LiquidityPrevention is deployed to %s", address(lp));

    // 1.2. add Hecules routers
    lp.addRouters(Deployed.routers());

    // 2. deploy yoints token
    Yoints yoints = new Yoints(address(lp));
    console.log("Yoints is deployed to %s", address(yoints));

    // 3. grant role
    lp.grantRole(PROTECTED_ROLE, address(yoints));

    vm.stopBroadcast();
  }
}
