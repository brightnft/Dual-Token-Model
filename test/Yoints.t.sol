// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/tokens/Yoints.sol";
import { LiquidityPrevention } from "../src/BP/LiquidityPrevention.sol";

contract YointsTest is Test {
  address CALLER = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38; // default address of foundry

  LiquidityPrevention lp;
  Yoints yoints;

  function setUp() public {
    // deploy add liquidity prevention
    lp = new LiquidityPrevention();

    // deploy yoints
    yoints = new Yoints(address(lp));

    // disable bp
    yoints.setEnableBP(false);
  }

  function testConfiguration() public view {
    assertEq(yoints.decimals(), uint8(18));
    assertEq(yoints.isEnableBP(), false);
    assertEq(yoints.bpAddr(), address(lp));
  }
}
