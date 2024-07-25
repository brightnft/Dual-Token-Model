// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IPrevention } from "../BP/interfaces/IPrevention.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

// Note: Since the contract has activeTrading disabled by default, we can remove blacklisting functionality

/// @title Yoints Token ($YOINTS)
/// @notice ERC-20 Token with management features for trading control, overflow handling, and administrative actions
/// @dev Extends OpenZeppelin's ERC20, Ownable
contract Yoints is ERC20, Ownable {
  address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
  address public bpAddr;
  bool public isEnableBP;

  // 100 million tokens with 18 decimals
  uint256 public constant INITIAL_SUPPLY = 100_000_000 * (10 ** 18);

  /// @notice Constructs the Yoints Token
  constructor(address bpAddr_) ERC20("YOINTS Token", "YOINTS") Ownable(_msgSender()) {
    _mint(_msgSender(), INITIAL_SUPPLY);
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

  /// @notice Allows recovery of ERC-20 tokens sent to this contract by mistake
  /// @param tokenAmount Amount of tokens to recover
  /// @dev Can only be called by the owner
  function claimOverflow(uint256 tokenAmount) external onlyOwner {
    super._transfer(address(this), _msgSender(), tokenAmount);
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
}
