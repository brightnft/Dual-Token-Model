// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";
import { BaseScript } from "../Base.s.sol";
import { Deployed } from "../Deployed.s.sol";
import { RevenueShareContract } from "../../src/revenue/RevenueShareContract.sol";
import { YapesStaking } from "../../src/revenue/YapesStaking.sol";


contract RevenueShareContractDeployScript is BaseScript {
  bytes32 private constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    uint256 _fee = 1;

    YapesStaking yapesStaking = YapesStaking(payable(Deployed.yapesStaking()));

    // 1. deploy RevenueShareContract
    RevenueShareContract revenueShare = new RevenueShareContract();
    console.log("Revenue Share Contract is deployed to %s", address(revenueShare));

    revenueShare.initialize(_fee, address(Deployed.yapesStaking()), address(Deployed.yapesToken()));

    // 2. grant role to RevenueShareContract
    yapesStaking.grantRole(TRANSFER_ROLE, address(revenueShare));
    console.log("Role is granted to Revenue Share Contract");


    vm.stopBroadcast();
  }
}
