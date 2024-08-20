// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";
import { BaseScript } from "../Base.s.sol";
import { Deployed } from "../Deployed.s.sol";
import { Yapes } from "../../src/tokens/Yapes.sol";
import { Yoints } from "../../src/tokens/Yoints.sol";
import { BlacklistPrevention } from "../../src/BP/BlacklistPrevention.sol";

contract YapesDeployScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    // deploy blacklist prevention
    BlacklistPrevention bp = new BlacklistPrevention();
    console.log("BlacklistPrevention is deployed to %s", address(bp));

    // deploy yapes token
    Yapes yapes = new Yapes(address(bp));
    console.log("Yapes is deployed to %s", address(yapes));

    vm.stopBroadcast();
  }
}

contract YointsDeployScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    // deploy yoints token
    Yoints yoints = new Yoints();
    console.log("Yoints is deployed to %s", address(yoints));

    vm.stopBroadcast();
  }
}
