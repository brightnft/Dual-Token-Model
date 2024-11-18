// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { IPrevention } from "../BP/interfaces/IPrevention.sol";

/// @title Yoints Token ($YOINTS)
/// @notice ERC-20 Token with management features for trading control, overflow handling, and administrative actions
/// @dev Extends OpenZeppelin's ERC20, Ownable
contract Yoints is ERC20Votes, ERC20Permit, Ownable, AccessControl {
  bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

  address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
  address public bpAddr;
  bool public isEnableBP;

  // 100 million tokens with 18 decimals
  uint256 public constant TOTAL_SUPPLY = 100_000_000 * (10 ** 18);

  constructor(address bpAddr_) ERC20("Yoints Token", "YOINTS") ERC20Permit("Yoints Token") Ownable(_msgSender()) {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _grantRole(ADMIN_ROLE, _msgSender());

    bpAddr = bpAddr_;
    isEnableBP = true;
  }

  /// @notice Function to enable/disable blacklist prevention
  function setEnableBP(bool isEnableBP_) external onlyOwner {
    isEnableBP = isEnableBP_;
  }

  /// @notice Function to update blacklist prevention address
  function setBPAddress(address bpAddr_) external onlyOwner {
    bpAddr = bpAddr_;
  }

  function nonces(address owner) public view virtual override(ERC20Permit, Nonces) returns (uint256) {
    return super.nonces(owner);
  }

  function _update(address from, address to, uint256 value) internal virtual override(ERC20, ERC20Votes) {
    super._update(from, to, value);
  }

  /// @notice Be cautious when using this feature, as it may affect revenue share calculations from YapesStaking
  function mint(address to, uint256 amount) external onlyRole(ADMIN_ROLE) {
    require(totalSupply() + amount <= TOTAL_SUPPLY, "exceed total supply");
    super._mint(to, amount);
  }

  /// @notice Be cautious when using this feature, as it may affect revenue share calculations from YapesStaking
  function burn(address from, uint256 amount) external onlyRole(ADMIN_ROLE) {
    super._burn(from, amount);
  }

  /// @notice Overrides the transfer function to include trading controls
  /// @param recipient Recipient of the tokens
  /// @param amount Amount of tokens to transfer
  /// @return A boolean that indicates if the operation was successful.
  function transfer(address recipient, uint256 amount) public override returns (bool) {
    _transferToken(_msgSender(), recipient, amount);
    return true;
  }

  /// @notice Overrides the transferFrom function to include trading controls
  /// @param sender Source of the tokens
  /// @param recipient Recipient of the tokens
  /// @param amount Amount of tokens to be transferred
  /// @return A boolean that indicates if the operation was successful.
  function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    uint256 currentAllowance = allowance(sender, _msgSender());
    require(currentAllowance >= amount, "exceed allowance");
    unchecked {
      _approve(sender, _msgSender(), currentAllowance - amount);
    }

    _transferToken(sender, recipient, amount);
    return true;
  }

  /// @dev overrides transfer function to meet tokenomics
  function _transferToken(address sender, address recipient, uint256 amount) internal {
    require(amount > 0, "amount is zero");

    if (recipient == BURN_ADDRESS) {
      // Burn all the amount
      super._burn(sender, amount);
      return;
    }

    if (isEnableBP && bpAddr != address(0x0)) {
      IPrevention(bpAddr).protect(sender, recipient, amount);
    }

    // Transfer all the amount
    _transfer(sender, recipient, amount);
  }

  function delegate(address delegatee) public virtual override {
    _delegate(_msgSender(), delegatee);
  }
}
