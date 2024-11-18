// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";
import { BaseScript } from "../Base.s.sol";
import { Deployed } from "../Deployed.s.sol";
import { YapesStaking } from "../../src/revenue/YapesStaking.sol";

import { Yoints } from "../../src/tokens/Yoints.sol";

contract YapesStakingDeployScript is BaseScript {
  bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    // 1. deploy yapes staking
    YapesStaking yapesStaking = new YapesStaking(Deployed.yapesToken(), Deployed.yointsToken());
    console.log("yapesStaking is deployed to %s", address(yapesStaking));

    // 2. grant admin role
    Yoints yoints = Yoints(payable(Deployed.yointsToken()));
    yoints.grantRole(ADMIN_ROLE, address(yapesStaking));

    vm.stopBroadcast();
  }
}
