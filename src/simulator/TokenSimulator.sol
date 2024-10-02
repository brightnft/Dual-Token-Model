//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenSimulator is ERC20 {
  constructor(string memory name, string memory symbol) ERC20(name, symbol) {
    _mint(_msgSender(), 1_000_000_000 * 10 ** 18);
  }
}
