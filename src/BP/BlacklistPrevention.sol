// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IPrevention } from "./interfaces/IPrevention.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

contract BlacklistPrevention is IPrevention, Ownable, AccessControl {
  bytes32 public constant PROTECTED_ROLE = keccak256("PROTECTED_ROLE");

  mapping(address wallet => bool disable) public isBlacklist;
  mapping(address wallet => AddressReputation reputation) public addressReputationMap;
  bool public isActiveTrading = false;

  struct AddressReputation {
    bool isWhitelist;
    bool isRouter;
  }

  constructor() Ownable(_msgSender()) {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }

  event AddBlackListEvent(address[] _blacklistAddress);
  event RemoveBlacklistEvent(address[] _blacklistAddress);
  event AddWhiteListEvent(address[] _whitelistAddress);
  event RemoveWhitelistEvent(address[] _whitelistAddress);
  event AddRoutersEvent(address[] _routerAddresses);
  event RemoveRoutersEvent(address[] _routerAddresses);

  function addBlacklist(address[] calldata _blacklistAddress) external onlyOwner {
    require(_blacklistAddress.length > 0, "length > 0");
    for (uint256 i = 0; i < _blacklistAddress.length; i++) {
      isBlacklist[_blacklistAddress[i]] = true;
    }

    emit AddBlackListEvent(_blacklistAddress);
  }

  function removeBlacklist(address[] calldata _blacklistAddress) external onlyOwner {
    require(_blacklistAddress.length > 0, "length > 0");
    for (uint256 i = 0; i < _blacklistAddress.length; i++) {
      isBlacklist[_blacklistAddress[i]] = false;
    }

    emit RemoveBlacklistEvent(_blacklistAddress);
  }

  function addWhitelist(address[] calldata _whitelistAddress) public onlyOwner {
    require(_whitelistAddress.length > 0, "_whitelistAddress must have length > 0");

    for (uint256 i = 0; i < _whitelistAddress.length; i++) {
      address targetAddress = _whitelistAddress[i];
      AddressReputation storage addressReputation = addressReputationMap[targetAddress];

      require(!addressReputation.isRouter, "Cannot set whitelist for a router");

      addressReputation.isWhitelist = true;
    }

    emit AddWhiteListEvent(_whitelistAddress);
  }

  function removeWhitelist(address[] calldata _whitelistAddress) public onlyOwner {
    require(_whitelistAddress.length > 0, "_whitelistAddress must have length > 0");

    for (uint256 i = 0; i < _whitelistAddress.length; i++) {
      address targetAddress = _whitelistAddress[i];

      AddressReputation storage addressReputation = addressReputationMap[targetAddress];

      addressReputation.isWhitelist = false;
    }

    emit RemoveWhitelistEvent(_whitelistAddress);
  }

  function addRouters(address[] calldata _routerAddresses) public onlyOwner {
    require(_routerAddresses.length > 0, "_routerAddresses must have length > 0");

    for (uint256 i = 0; i < _routerAddresses.length; i++) {
      address targetAddress = _routerAddresses[i];
      AddressReputation storage addressReputation = addressReputationMap[targetAddress];

      require(!addressReputation.isWhitelist, "Cannot set router for a whitelist");
      addressReputation.isRouter = true;
    }

    emit AddRoutersEvent(_routerAddresses);
  }

  function removeRouters(address[] calldata _routerAddresses) public onlyOwner {
    require(_routerAddresses.length > 0, "_routerAddresses must have length > 0");

    for (uint256 i = 0; i < _routerAddresses.length; i++) {
      address targetAddress = _routerAddresses[i];
      AddressReputation storage addressReputation = addressReputationMap[targetAddress];

      addressReputation.isRouter = false;
    }

    emit RemoveRoutersEvent(_routerAddresses);
  }

  function protect(
    address sender,
    address receiver,
    uint256 /* amount */
  ) external view override onlyRole(PROTECTED_ROLE) {
    require(!isBlacklist[sender] && !isBlacklist[receiver], "BL - contact support");

    if (!isActiveTrading) {
      AddressReputation storage senderReputation = addressReputationMap[sender];
      AddressReputation storage receiverReputation = addressReputationMap[receiver];

      bool isBuyTx = senderReputation.isRouter;
      if (isBuyTx) {
        require(receiverReputation.isWhitelist, "Only whitelist can buy");
      }
    }
  }
}
