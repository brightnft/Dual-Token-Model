// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "./MessageHashUtils.sol";

library SignatureChecker {
  using EnumerableSet for EnumerableSet.AddressSet;
  using MessageHashUtils for bytes32;

  /**
    @notice Common validator logic, checking if the recovered signer is
    contained in the signers AddressSet.
    */
  function validSignature(
    EnumerableSet.AddressSet storage signers,
    bytes32 message,
    bytes calldata signature
  ) internal view returns (bool) {
    return signers.contains(ECDSA.recover(message.toEthSignedMessageHash(), signature));
  }

  /**
    @notice Requires that the recovered signer is contained in the signers
    AddressSet.
    @dev Convenience wrapper that reverts if the signature validation fails.
    */
  function requireValidSignature(
    EnumerableSet.AddressSet storage signers,
    bytes32 message,
    bytes calldata signature
  ) internal view {
    require(validSignature(signers, message, signature), "SignatureChecker: Invalid signature");
  }
}
