//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.25;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract AggregatorSimulator is AccessControlUpgradeable {
  function initialize() public initializer {
    __AccessControl_init();

    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  function latestRoundData()
    external
    pure
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
  {
    return (36893488147419134872, 51610799700, 1710916203, 1710916203, 36893488147419134872);
  }
  function decimals() external pure returns (uint8) {
    return 8;
  }
}
