// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface IPrevention {
  function protect(address sender, address receiver, uint256 amount) external;
}
