// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";
import { BaseScript } from "../Base.s.sol";
import { Deployed } from "../Deployed.s.sol";
import { Yapes } from "../../src/tokens/Yapes.sol";

contract YapesEnableBotPreventionScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    Yapes yapes = Yapes(payable(Deployed.yapesToken()));
    yapes.setEnableBP(false);

    vm.stopBroadcast();
  }
}

contract YapesSetBotPreventionScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    Yapes yapes = Yapes(payable(Deployed.yapesToken()));
    yapes.setBPAddress(Deployed.bp());

    vm.stopBroadcast();
  }
}

contract YapesClaimOverflowScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    Yapes yapes = Yapes(payable(Deployed.yapesToken()));
    yapes.claimOverflow(yapes.balanceOf(Deployed.yapesToken()));

    vm.stopBroadcast();
  }
}
