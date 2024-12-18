// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { YapesStaking } from "./YapesStaking.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./libs/SignatureChecker.sol";

contract RevenueShareContract is Initializable, UUPSUpgradeable, OwnableUpgradeable, PausableUpgradeable {
  using SafeERC20 for IERC20;

  using EnumerableSet for EnumerableSet.AddressSet;
  using SignatureChecker for EnumerableSet.AddressSet;

  uint256 public fee;
  address public yapesStakingAddress;
  IERC20 public yapes;

  EnumerableSet.AddressSet private _signers;
  mapping(bytes32 => bool) public usedNonce;

  event Tip(address sender, address author, uint256 amount);

  /**
   * @dev Initializes the contract and sets key parameters
   * @param _fee the platform fee
   * @param _yapesStakingAddress Yapes staking contract
   */
  function initialize(uint256 _fee, address _yapesStakingAddress, address _yapesAddress) external initializer {
    __Pausable_init_unchained();
    __Ownable_init_unchained(_msgSender());
    __UUPSUpgradeable_init();

    fee = _fee;
    yapesStakingAddress = _yapesStakingAddress;
    yapes = IERC20(_yapesAddress);
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

  function setFee(uint256 _fee) external onlyOwner {
    fee = _fee;
  }

  function addSigner(address _signer) external onlyOwner {
    require(_signer != address(0), "invalid address");
    _signers.add(_signer);
  }

  function removeSigner(address _signer) external onlyOwner {
    require(_signer != address(0), "invalid address");
    _signers.remove(_signer);
  }

  function setYapesStakingAddress(address _yapesStakingAddress) external onlyOwner {
    require(_yapesStakingAddress != address(0), "invalid address");
    yapesStakingAddress = _yapesStakingAddress;
  }

  /**
   * @dev To tip author using Yapes
   * @param authorAddress address of author will receive yapes tip
   * @param amount no of amount of Yapes tokens
   * @param timestamp unix timestamp in seconds
   */
  function tip(
    address authorAddress,
    uint256 amount,
    uint256 timestamp,
    bytes calldata signature
  ) external whenNotPaused {
    require(authorAddress != address(0), "invalid address");
    require(amount > 0, "invalid amount");
    bytes32 message = _getHashMsg(authorAddress, amount, timestamp);
    _validateSignature(message, signature);

    // take fee
    uint256 feeAmount = (amount * fee) / 10000;
    if (feeAmount > 0) {
      // Transfer fee Yapes tokens to the staking contract
      yapes.transferFrom(_msgSender(), yapesStakingAddress, feeAmount);

      // increase sharing amount
      YapesStaking(yapesStakingAddress).addFee(feeAmount);
    }

    // Transfer remaining amount to author
    uint256 remainingAmount = amount - feeAmount;
    yapes.transferFrom(_msgSender(), authorAddress, remainingAmount);

    emit Tip(_msgSender(), authorAddress, amount);
  }

  function _getHashMsg(
    address authorAddress,
    uint256 amount,
    uint256 timestamp
  ) internal view returns (bytes32 message) {
    message = keccak256(abi.encodePacked(authorAddress, amount, timestamp, _msgSender()));
  }

  function _validateSignature(bytes32 message, bytes calldata signature) internal {
    require(usedNonce[message] == false, "already used");
    usedNonce[message] = true;
    _signers.requireValidSignature(message, signature);
  }

  function _authorizeUpgrade(address) internal override onlyOwner {}
}
