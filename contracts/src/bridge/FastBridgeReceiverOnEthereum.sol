// SPDX-License-Identifier: MIT

/**
 *  @authors: [@jaybuidl, @shalzz, @hrishibhat, @shotaronowhere]
 *  @reviewers: []
 *  @auditors: []
 *  @bounties: []
 *  @deployments: []
 */

pragma solidity ^0.8.0;

import "./FastBridgeReceiverBase.sol";
import "./interfaces/arbitrum/IInbox.sol";
import "./interfaces/arbitrum/IOutbox.sol";

/**
 * Fast Bridge Receiver on Ethereum from Arbitrum
 * Counterpart of `FastBridgeSenderToEthereum`
 */
contract FastBridgeReceiverOnEthereum is FastBridgeReceiverBase {
    // ************************************* //
    // *             Storage               * //
    // ************************************* //

    IInbox public immutable inbox; // The address of the Arbitrum Inbox contract.

    /**
     * @dev Constructor.
     * @param _deposit The deposit amount to submit a claim in wei.
     * @param _epochPeriod The duration of the period allowing to challenge a claim.
     * @param _genesis The genesis time to synchronize epochs.
     * @param _inbox The address of the inbox contract on Ethereum.
     * @param _safeRouter The address of the Safe Router on Ethereum.
     */
    constructor(
        uint256 _deposit,
        uint256 _epochPeriod,
        uint256 _genesis,
        address _inbox,
        address _safeRouter
    ) FastBridgeReceiverBase(_deposit, _epochPeriod, _genesis, _safeRouter) {
        inbox = IInbox(_inbox);
    }

    // ************************************* //
    // *              Views                * //
    // ************************************* //

    function isSentBySafeBridge() internal view override returns (bool) {
        IOutbox outbox = IOutbox(inbox.bridge().activeOutbox());
        return outbox.l2ToL1Sender() == safeRouter;
    }
}
