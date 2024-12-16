// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";
import { BaseScript } from "../Base.s.sol";
import { Deployed } from "../Deployed.s.sol";
import { Yapes } from "../../src/tokens/Yapes.sol";

contract YapesCheckDataScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    Yapes yapes = Yapes(payable(Deployed.yapesToken()));

    console.log("isEnableBP = %s", yapes.isEnableBP());
    console.log("bpAddr = %s", yapes.bpAddr());
    console.log("balanceOf Yapes token = %s", yapes.balanceOf(Deployed.yapesToken()));

    vm.stopBroadcast();
  }
}

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

contract YapesSendTokenScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    Yapes yapes = Yapes(payable(Deployed.yapesToken()));
    yapes.transfer(address(0x281853734781e1e57A0a0D3a7198587A8E09b7bC), 100_000 * 10 ** 18);

    vm.stopBroadcast();
  }
}
