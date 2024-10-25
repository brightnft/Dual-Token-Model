// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/tokens/Yapes.sol";
import "../src/BP/BotPrevention.sol";

contract YapesTest is Test {
  address CALLER = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38; // default address of foundry

  BotPrevention bp;
  Yapes yapes;

  function setUp() public {
    // deploy bot prevention
    bp = new BotPrevention();

    // deploy yapes
    yapes = new Yapes(address(bp));

    // disable bp
    yapes.setEnableBP(false);
  }

  function testConfiguration() public view {
    assertEq(yapes.decimals(), uint8(18));
    assertEq(yapes.isEnableBP(), false);
    assertEq(yapes.bpAddr(), address(bp));
  }
}
