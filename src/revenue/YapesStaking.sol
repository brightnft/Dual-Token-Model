// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";

import { Yoints } from "../tokens/Yoints.sol";

contract YapesStaking is Ownable, AccessControl, Pausable {
  ERC20 public yapesToken; // Yapes token
  Yoints public yointsToken; // Yoints token

  uint256 public totalYapesStaked; // total Yapes tokens staked
  uint256 public feeYapesAdded; // track fee Yapes tokens added

  bytes32 private constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

  // Info of each user that stakes Yapes tokens.
  mapping(address user => UserInfo info) public userInfo;

  // Info of each user.
  struct UserInfo {
    uint256 amount; // How many Yapes tokens the user has provided.
    uint256 lastDeposit; // The last block user deposits
    bool inBlackList;
  }

  // Depositor's money is only withdrawn after the locking period timestamp (in UNIX)
  uint256 public lockingPeriod;

  event Stake(address sender, uint256 amount);
  event UnStake(address sender, uint256 amount);
  event EmergencyWithdraw(address sender, uint256 amount);

  constructor(address _yapesToken, address _yointsToken) Ownable(_msgSender()) {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());

    yapesToken = ERC20(_yapesToken);
    yointsToken = Yoints(_yointsToken);
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

  function setLockingPeriod(uint256 _lockingPeriod) external onlyOwner {
    lockingPeriod = _lockingPeriod;
  }

  function setBlackList(address _blacklistAddress) external onlyOwner {
    userInfo[_blacklistAddress].inBlackList = true;
  }

  function removeBlackList(address _blacklistAddress) external onlyOwner {
    userInfo[_blacklistAddress].inBlackList = false;
  }

  // Stake Yapes tokens and mint Yoints
  function stake(uint256 amount) external whenNotPaused {
    require(amount > 0, "Amount must be greater than zero");

    UserInfo storage user = userInfo[_msgSender()];
    require(!user.inBlackList, "in black list");

    // Transfer Yapes tokens to the contract
    yapesToken.transferFrom(_msgSender(), address(this), amount);

    // Store the deposit time + amount for user
    user.amount += amount;
    user.lastDeposit = block.timestamp;

    // Calculate Yoints to mint based on current staking ratio
    uint256 YointsToMint = (yointsToken.totalSupply() == 0)
      ? amount
      : (amount * yointsToken.totalSupply()) / totalYapesStaked;

    // Mint Yoints tokens to the user
    yointsToken.mint(_msgSender(), YointsToMint);

    // Update total staked
    totalYapesStaked += amount;

    emit Stake(_msgSender(), amount);
  }

  // Unstake Yapes tokens and burn Yoints
  function unstake(uint256 yointsAmount) external whenNotPaused {
    require(yointsToken.balanceOf(_msgSender()) >= yointsAmount, "Insufficient Yoints");

    UserInfo storage user = userInfo[_msgSender()];

    require(!user.inBlackList, "in black list");
    require(block.timestamp >= user.lastDeposit + lockingPeriod, "in locking time");

    // Calculate Yapes to return based on the ratio
    uint256 yapesToReturn = (yointsAmount * totalYapesStaked) / yointsToken.totalSupply();

    // Burn Yoints tokens
    yointsToken.burn(_msgSender(), yointsAmount);

    // Transfer Yapes back to the user
    yapesToken.transfer(_msgSender(), yapesToReturn);

    // Update total staked
    totalYapesStaked -= yapesToReturn;

    emit Stake(_msgSender(), yapesToReturn);
  }

  // Withdraw $Yapes. EMERGENCY ONLY.
  function emergencyWithdraw() external onlyOwner {
    uint256 amount = yapesToken.balanceOf(address(this));
    yapesToken.transfer(_msgSender(), amount);
    emit EmergencyWithdraw(_msgSender(), amount);
  }

  // Add Yapes tokens as fees (increases Yoints value)
  function addFee(uint256 feeAmount) external onlyRole(TRANSFER_ROLE) {
    require(feeAmount > 0, "Fee amount must be greater than zero");

    // Update total staked with the fee amount
    totalYapesStaked += feeAmount;
    feeYapesAdded += feeAmount;
  }
}
