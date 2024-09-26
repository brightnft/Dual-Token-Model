// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";
import { BaseScript } from "../Base.s.sol";
import { Deployed } from "../Deployed.s.sol";
import { YapesStaking } from "../../src/staking/YapesStaking.sol";

contract YapesStakingScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    address yapesStakingAddress = Deployed.yapesStaking();
    YapesStaking mb = YapesStaking(payable(yapesStakingAddress));

    vm.stopBroadcast();
  }
}
