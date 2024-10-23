// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

/// @title Yoints Token ($YOINTS)
/// @notice ERC-20 Token with management features for trading control, overflow handling, and administrative actions
/// @dev Extends OpenZeppelin's ERC20, Ownable
contract Yoints is ERC20Votes, ERC20Permit, Ownable, AccessControl {
  bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

  // 100 million tokens with 18 decimals
  uint256 public constant TOTAL_SUPPLY = 100_000_000 * (10 ** 18);

  constructor() ERC20("Yoints Token", "YOINTS") ERC20Permit("Yoints Token") Ownable(_msgSender()) {
    _mint(_msgSender(), 100_000_000 * 10 ** decimals());
    _grantRole(ADMIN_ROLE, _msgSender());
  }

  function nonces(address owner) public view virtual override(ERC20Permit, Nonces) returns (uint256) {
    return super.nonces(owner);
  }

  function _update(address from, address to, uint256 value) internal virtual override(ERC20, ERC20Votes) {
    super._update(from, to, value);
  }

  function mint(address to, uint256 amount) external onlyRole(ADMIN_ROLE) {
    require(totalSupply() + amount <= TOTAL_SUPPLY, "exceed total supply");
    super._mint(to, amount);
  }

  function burn(address from, uint256 amount) external onlyRole(ADMIN_ROLE) {
    super._burn(from, amount);
  }

  function delegate(address delegatee) public virtual override {
    _delegate(_msgSender(), delegatee);
  }
}
