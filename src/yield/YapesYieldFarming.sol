// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { ArbSys } from "./ArbSys.sol";

contract YapesYieldFarming is UUPSUpgradeable, AccessControlUpgradeable, PausableUpgradeable {
  using SafeERC20 for IERC20;

  bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

  // Metis precompile, used to send messages to L1
  ArbSys constant arbsys = ArbSys(address(0x4200000000000000000000000000000000000013));

  // Info of each user.
  struct UserInfo {
    uint256 amount; // How many LP tokens the user has provided.
    uint256 rewardDebt; // Reward debt. See explanation below.
    uint256 lastDeposit; // The last block user deposits
    bool inBlackList;
  }

  // Info of each pool.
  struct PoolInfo {
    IERC20 lpToken; // Address of LP token contract.
    uint256 allocPoint; // How many allocation points assigned to this pool. CAKEs to distribute per block.
    uint256 lastRewardBlock; // Last block number that CAKEs distribution occurs.
    uint256 accCakePerShare; // Accumulated CAKEs per share, times 1e12. See below.
    uint256 startBlock; // The block number when CAKE mining starts.
    uint256 bonusEndBlock; // The block number when CAKE mining ends.
  }

  // The REWARD TOKEN
  IERC20 public rewardToken;

  // CAKE tokens created per block.
  uint256 public rewardPerBlock;

  // Info of each pool.
  PoolInfo[] public poolInfo;
  // Info of each user that stakes LP tokens.
  mapping(address => mapping(uint256 => UserInfo)) public userInfo;
  // Total allocation points. Must be the sum of all allocation points in all pools.
  uint256 public totalAllocPoint;
  // Depositor's money is only withdrawn after the locking block
  uint256 public lockingBlock;
  // Total staked amount of users
  uint256 public totalStaked;

  event Deposit(address indexed user, uint256 amount);
  event Withdraw(address indexed user, uint256 amount);
  event Harvest(address indexed user, uint256 amount);
  event EmergencyWithdraw(address indexed user, uint256 amount);

  function initialize(
    address _lp,
    address _rewardToken,
    uint256 _rewardPerBlock,
    uint256 _startBlock,
    uint256 _bonusEndBlock
  ) public initializer {
    __Context_init_unchained();
    __AccessControl_init_unchained();
    __Pausable_init_unchained();
    __UUPSUpgradeable_init();

    rewardToken = IERC20(_rewardToken);
    rewardPerBlock = _rewardPerBlock;
    lockingBlock = 50400; // 7 days

    _grantRole(ADMIN_ROLE, _msgSender());

    // staking pool
    poolInfo.push(
      PoolInfo({
        lpToken: IERC20(_lp),
        allocPoint: 1000,
        lastRewardBlock: _startBlock,
        accCakePerShare: 0,
        startBlock: _startBlock,
        bonusEndBlock: _bonusEndBlock
      })
    );

    totalAllocPoint = 1000;
  }

  /// create a new pool. no need to update deposit and reward address
  /// @notice to avoid rewards being messed up, the LP token should be unique for each pool
  function createNewPool(
    address _lp,
    uint256 _startBlock,
    uint256 _bonusEndBlock,
    uint256 _allocPoint
  ) external onlyRole(ADMIN_ROLE) {
    massUpdatePools();

    poolInfo.push(
      PoolInfo({
        lpToken: IERC20(_lp),
        allocPoint: _allocPoint,
        lastRewardBlock: _startBlock,
        accCakePerShare: 0,
        startBlock: _startBlock,
        bonusEndBlock: _bonusEndBlock
      })
    );

    totalAllocPoint += _allocPoint;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() external onlyRole(ADMIN_ROLE) whenNotPaused {
    _pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() external onlyRole(ADMIN_ROLE) whenPaused {
    _unpause();
  }

  function setLockingBlock(uint256 _lockingBlock) external onlyRole(ADMIN_ROLE) {
    lockingBlock = _lockingBlock;
  }

  function setBlackList(uint256 _pid, address _blacklistAddress) external onlyRole(ADMIN_ROLE) {
    userInfo[_blacklistAddress][_pid].inBlackList = true;
  }

  function removeBlackList(uint256 _pid, address _blacklistAddress) external onlyRole(ADMIN_ROLE) {
    userInfo[_blacklistAddress][_pid].inBlackList = false;
  }

  // Set the reward per block. i don't recommend to call this method
  // once successfully run the pool
  function setRewardPerBlock(uint256 _rewardPerBlock) external onlyRole(ADMIN_ROLE) {
    massUpdatePools();
    rewardPerBlock = _rewardPerBlock;
  }

  // Return reward multiplier over the given _from to _to block.
  function getMultiplier(uint256 _pid, uint256 _from, uint256 _to) public view returns (uint256) {
    PoolInfo storage pool = poolInfo[_pid];
    if (_to <= pool.bonusEndBlock) {
      return _to - _from;
    } else if (_from >= pool.bonusEndBlock) {
      return 0;
    } else {
      return pool.bonusEndBlock - _from;
    }
  }

  // View function to see pending Reward on frontend.
  function pendingReward(uint256 _pid, address _user) external view returns (uint256) {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_user][_pid];
    uint256 accCakePerShare = pool.accCakePerShare;
    uint256 lpSupply = pool.lpToken.balanceOf(address(this));

    if (arbsys.arbBlockNumber() > pool.lastRewardBlock && lpSupply != 0) {
      uint256 multiplier = getMultiplier(_pid, pool.lastRewardBlock, arbsys.arbBlockNumber());
      uint256 cakeReward = (multiplier * rewardPerBlock * pool.allocPoint) / totalAllocPoint;
      accCakePerShare = accCakePerShare + ((cakeReward * 1e12) / lpSupply);
    }
    return ((user.amount * accCakePerShare) / 1e12) - user.rewardDebt;
  }

  // Update reward variables of the given pool to be up-to-date.
  function updatePool(uint256 _pid) public {
    PoolInfo storage pool = poolInfo[_pid];
    if (arbsys.arbBlockNumber() <= pool.lastRewardBlock) {
      return;
    }
    uint256 lpSupply = pool.lpToken.balanceOf(address(this));
    if (lpSupply == 0) {
      pool.lastRewardBlock = arbsys.arbBlockNumber();
      return;
    }

    uint256 multiplier = getMultiplier(_pid, pool.lastRewardBlock, arbsys.arbBlockNumber());
    uint256 cakeReward = (multiplier * rewardPerBlock * pool.allocPoint) / totalAllocPoint;
    pool.accCakePerShare = pool.accCakePerShare + ((cakeReward * 1e12) / lpSupply);
    pool.lastRewardBlock = arbsys.arbBlockNumber();
  }

  // Update the total allocation points to be accurate
  function unwindPool(uint256 _pid) public {
    PoolInfo storage pool = poolInfo[_pid];
    require(arbsys.arbBlockNumber() > pool.lastRewardBlock, "not expired");

    totalAllocPoint -= pool.allocPoint;
  }

  // Update reward variables for all pools. Be careful of gas spending!
  function massUpdatePools() public {
    uint256 length = poolInfo.length;
    for (uint256 pid = 0; pid < length; ++pid) {
      updatePool(pid);
    }
  }

  // Stake tokens to SmartChef
  function deposit(uint256 _pid, uint256 amount) external whenNotPaused {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_msgSender()][_pid];

    require(arbsys.arbBlockNumber() < pool.bonusEndBlock, "end time");
    require(!user.inBlackList, "in black list");

    updatePool(_pid);
    if (user.amount > 0) {
      uint256 pending = ((user.amount * pool.accCakePerShare) / 1e12) - user.rewardDebt;
      if (pending > 0) {
        require(rewardToken.balanceOf(address(this)) >= pending, "not enough reward");
        rewardToken.safeTransfer(_msgSender(), pending);
      }
    }

    if (amount > 0) {
      user.amount += amount;
      totalStaked += amount;
      pool.lpToken.safeTransferFrom(_msgSender(), address(this), amount);
    }
    user.rewardDebt = (user.amount * pool.accCakePerShare) / 1e12;
    user.lastDeposit = arbsys.arbBlockNumber();

    emit Deposit(_msgSender(), amount);
  }

  // Withdraw tokens from STAKING.
  function withdraw(uint256 _pid, uint256 _amount) external whenNotPaused {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_msgSender()][_pid];

    require(user.amount >= _amount, "withdraw: not good");
    if (arbsys.arbBlockNumber() <= pool.bonusEndBlock) {
      require(arbsys.arbBlockNumber() >= user.lastDeposit + lockingBlock, "must over 7 days");
    }

    updatePool(_pid);
    uint256 pending = ((user.amount * pool.accCakePerShare) / 1e12) - user.rewardDebt;
    if (pending > 0 && !user.inBlackList) {
      require(rewardToken.balanceOf(address(this)) >= pending, "not enough reward");
      rewardToken.safeTransfer(_msgSender(), pending);
    }

    if (_amount > 0) {
      user.amount -= _amount;
      totalStaked -= _amount;
      pool.lpToken.safeTransfer(_msgSender(), _amount);
    }

    user.rewardDebt = (user.amount * pool.accCakePerShare) / 1e12;
    emit Withdraw(_msgSender(), _amount);
  }

  // Harvest tokens from STAKING.
  function harvest(uint256 _pid) external whenNotPaused {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_msgSender()][_pid];

    updatePool(_pid);
    uint256 pending = ((user.amount * pool.accCakePerShare) / 1e12) - user.rewardDebt;
    if (pending > 0 && !user.inBlackList) {
      require(rewardToken.balanceOf(address(this)) >= pending, "not enough reward");
      rewardToken.safeTransfer(_msgSender(), pending);
    }

    user.rewardDebt = (user.amount * pool.accCakePerShare) / 1e12;

    emit Harvest(_msgSender(), pending);
  }

  // Withdraw without caring about rewards. EMERGENCY ONLY.
  function emergencyWithdraw(uint256 _pid) external {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_msgSender()][_pid];
    pool.lpToken.safeTransfer(_msgSender(), user.amount);
    emit EmergencyWithdraw(_msgSender(), user.amount);
    user.amount = 0;
    user.rewardDebt = 0;
    totalStaked -= user.amount;
  }

  // Withdraw reward. EMERGENCY ONLY.
  function emergencyRewardWithdraw(uint256 _amount) external onlyRole(ADMIN_ROLE) {
    require(_amount <= rewardToken.balanceOf(address(this)), "not enough token");
    rewardToken.safeTransfer(_msgSender(), _amount);
  }

  function _authorizeUpgrade(address) internal override onlyRole(ADMIN_ROLE) {}
}
