// Copyright 2021-2022, Offchain Labs, Inc.
// For license information, see https://github.com/OffchainLabs/nitro-contracts/blob/main/LICENSE
// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.25;

/**
 * @title iOVM_L1BlockNumber
 * MetisProtocol/mvm/tree/dc06a69c06cc2f224a98c8e13e4eb223d98ef5a1/packages/contracts/contracts/L2/predeploys
 */
interface iOVM_L1BlockNumber {
  /********************
   * Public Functions *
   ********************/

  /**
   * @return Block number of L1
   */
  function getL1BlockNumber() external view returns (uint256);
}
