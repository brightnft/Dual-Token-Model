// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";
import { BaseScript } from "../Base.s.sol";
import { Deployed } from "../Deployed.s.sol";
import { Yapes } from "../../src/tokens/Yapes.sol";
import { LiquidityPrevention } from "../../src/BP/LiquidityPrevention.sol";

contract LiquidityPreventionCheckDataScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    LiquidityPrevention lp = LiquidityPrevention(payable(Deployed.lp()));
    console.log(
      "isBlacklist[%s] = %s",
      0xdB9f5dd645992Bb776Cca7Fed0a3879B9a29563D,
      lp.isBlacklist(0xdB9f5dd645992Bb776Cca7Fed0a3879B9a29563D)
    );

    vm.stopBroadcast();
  }
}

contract LiquidityPreventionAddRoutersScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    LiquidityPrevention lp = LiquidityPrevention(payable(Deployed.lp()));
    lp.addRouters(Deployed.routers());

    vm.stopBroadcast();
  }
}

contract AddLiquidityPreventionRemoveRoutersScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    LiquidityPrevention lp = LiquidityPrevention(payable(Deployed.lp()));
    lp.removeRouters(Deployed.routers());

    vm.stopBroadcast();
  }
}

contract LiquidityPreventionAddBlacklistScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    LiquidityPrevention lp = LiquidityPrevention(payable(Deployed.lp()));
    lp.addBlacklist(Deployed.blacklist());

    vm.stopBroadcast();
  }
}

contract LiquidityPreventionRemoveBlacklistScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    LiquidityPrevention lp = LiquidityPrevention(payable(Deployed.lp()));
    lp.removeBlacklist(Deployed.blacklist());

    vm.stopBroadcast();
  }
}
