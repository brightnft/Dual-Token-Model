// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";

contract YapesStaking is ERC20, Ownable, AccessControl, Pausable {
  ERC20 public yapesToken; // Yapes token
  uint256 public totalYapesStaked; // total Yapes tokens staked
  uint256 public feeYapessAdded; // track fee Yapes tokens added

  bytes32 private constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

  event Stake(address sender, uint256 amount);
  event UnStake(address sender, uint256 amount);

  constructor(ERC20 _yapesToken) ERC20("xYapes", "XYAPES") Ownable(_msgSender()) {
    yapesToken = _yapesToken;
  }

  /**
   * @dev To pause the presale
   */
  function pause() external onlyOwner {
    _pause();
  }

  /**
   * @dev To unpause the presale
   */
  function unpause() external onlyOwner {
    _unpause();
  }

  // Stake Yapes tokens and mint xYapes
  function stake(uint256 amount) external whenNotPaused {
    require(amount > 0, "Amount must be greater than zero");

    // Transfer Yapes tokens to the contract
    yapesToken.transferFrom(_msgSender(), address(this), amount);

    // Calculate xYapes to mint based on current staking ratio
    uint256 xYapesToMint = (totalSupply() == 0) ? amount : (amount * totalSupply()) / totalYapesStaked;

    // Mint xYapes tokens to the user
    _mint(_msgSender(), xYapesToMint);

    // Update total staked
    totalYapesStaked += amount;

    emit Stake(_msgSender(), amount);
  }

  // Unstake Yapes tokens and burn xYapes
  function unstake(uint256 xYapesAmount) external whenNotPaused {
    require(balanceOf(_msgSender()) >= xYapesAmount, "Insufficient xYapes");

    // Calculate Yapes to return based on the ratio
    uint256 YapesToReturn = (xYapesAmount * totalYapesStaked) / totalSupply();

    // Burn xYapes tokens
    _burn(_msgSender(), xYapesAmount);

    // Transfer Yapes back to the user
    yapesToken.transfer(_msgSender(), YapesToReturn);

    // Update total staked
    totalYapesStaked -= YapesToReturn;

    emit Stake(_msgSender(), YapesToReturn);
  }

  // Add Yapes tokens as fees (increases xYapes value)
  function addFee(uint256 feeAmount) external onlyRole(TRANSFER_ROLE) {
    require(feeAmount > 0, "Fee amount must be greater than zero");

    // Update total staked with the fee amount
    totalYapesStaked += feeAmount;
    feeYapessAdded += feeAmount;
  }
}
