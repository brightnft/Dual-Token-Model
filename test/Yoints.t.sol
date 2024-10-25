// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/tokens/Yoints.sol";
import "../src/BP/AddLiquidityPrevention.sol";

contract YointsTest is Test {
  address CALLER = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38; // default address of foundry

  AddLiquidityPrevention bp;
  Yoints yoints;

  function setUp() public {
    // deploy add liquidity prevention
    bp = new AddLiquidityPrevention();

    // deploy yapes
    yoints = new Yoints(address(bp));

    // disable bp
    yoints.setEnableBP(false);
  }

  function testConfiguration() public view {
    assertEq(yoints.decimals(), uint8(18));
    assertEq(yoints.isEnableBP(), false);
    assertEq(yoints.bpAddr(), address(bp));
  }
}
