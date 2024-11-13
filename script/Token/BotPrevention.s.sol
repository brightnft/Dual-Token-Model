// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/console.sol";
import { BaseScript } from "../Base.s.sol";
import { Deployed } from "../Deployed.s.sol";
import { BotPrevention } from "../../src/BP/BotPrevention.sol";

contract BotPreventionCheckDataScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    BotPrevention bp = BotPrevention(payable(Deployed.bp()));
    console.log("isActiveTrading = %s", bp.isActiveTrading());

    vm.stopBroadcast();
  }
}

contract BotPreventionActiveTradingScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    BotPrevention bp = BotPrevention(payable(Deployed.bp()));
    bp.setActiveTrading(true);

    vm.stopBroadcast();
  }
}

contract BotPreventionAddWhitelistScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    BotPrevention bp = BotPrevention(payable(Deployed.bp()));
    bp.addWhitelist(Deployed.whitelist());

    vm.stopBroadcast();
  }
}

contract BotPreventionRemoveWhitelistScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    BotPrevention bp = BotPrevention(payable(Deployed.bp()));
    bp.removeWhitelist(Deployed.whitelist());

    vm.stopBroadcast();
  }
}

contract BotPreventionAddRoutersScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    BotPrevention bp = BotPrevention(payable(Deployed.bp()));
    bp.addRouters(Deployed.routers());

    vm.stopBroadcast();
  }
}

contract BotPreventionRemoveRoutersScript is BaseScript {
  function run() external {
    uint256 deployerPrivateKey = get_pk();
    vm.startBroadcast(deployerPrivateKey);

    BotPrevention bp = BotPrevention(payable(Deployed.bp()));
    bp.removeRouters(Deployed.routers());

    vm.stopBroadcast();
  }
}
