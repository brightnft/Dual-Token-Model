// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IPrevention } from "./interfaces/IPrevention.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

contract AddLiquidityPrevention is IPrevention, Ownable, AccessControl {
  bytes32 public constant PROTECTED_ROLE = keccak256("PROTECTED_ROLE");

  mapping(address wallet => bool disable) public isBlacklist;
  mapping(address wallet => bool isRouter) public routers;

  constructor() Ownable(_msgSender()) {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  event AddBlackListEvent(address[] _blacklistAddress);
  event RemoveBlacklistEvent(address[] _blacklistAddress);
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

  function addRouters(address[] calldata _routerAddresses) public onlyOwner {
    require(_routerAddresses.length > 0, "_routerAddresses must have length > 0");

    for (uint256 i = 0; i < _routerAddresses.length; i++) {
      address targetAddress = _routerAddresses[i];
      routers[targetAddress] = true;
    }

    emit AddRoutersEvent(_routerAddresses);
  }

  function removeRouters(address[] calldata _routerAddresses) public onlyOwner {
    require(_routerAddresses.length > 0, "_routerAddresses must have length > 0");

    for (uint256 i = 0; i < _routerAddresses.length; i++) {
      address targetAddress = _routerAddresses[i];
      routers[targetAddress] = false;
    }

    emit RemoveRoutersEvent(_routerAddresses);
  }

  function protect(
    address sender,
    address receiver,
    uint256 /* amount */
  ) external view override onlyRole(PROTECTED_ROLE) {
    require(!isBlacklist[sender] && !isBlacklist[receiver], "BL - contact support");
    require(routers[sender] == false && routers[receiver] == false, "not support DEX");
  }
}
